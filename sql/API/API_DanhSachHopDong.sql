USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Hợp đồng (Contract)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_DanhSachHopDong]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[API_DanhSachHopDong]
GO
CREATE PROCEDURE [dbo].[API_DanhSachHopDong]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Sohopdong AS [SoHopDong],
        h.Sobiennhan,
        
        CASE 
            WHEN ISNULL(k.Tenchure, '') <> '' AND ISNULL(k.Tencodau, '') <> '' 
                THEN k.Tenchure + ' & ' + k.Tencodau
            WHEN ISNULL(k.Tenchure, '') <> '' THEN k.Tenchure
            WHEN ISNULL(k.Tencodau, '') <> '' THEN k.Tencodau
            ELSE ISNULL(NULLIF(k.Tenkh, ''), ISNULL(NULLIF(k.Nguoigd, ''), N'Khách vãng lai'))
        END AS [TenKhachHang],
        
        -- Lấy sdt nếu không có bốc số chú rể / cô dâu / đại diện
        ISNULL(NULLIF(k.Dienthoai, ''), ISNULL(NULLIF(k.DTchure, ''), ISNULL(NULLIF(k.DTcodau, ''), k.DienThoaiDaiDien))) AS [DienThoai],
        
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS [NgayToChuc],
        
        ISNULL(h.TongSoBan, 0) AS [SoBan],
        
        -- Lấy Sảnh đặt bằng subquery (chỉ lấy 1 sảnh tượng trưng nếu chọn nhiều)
        (
            SELECT TOP 1 s.Tensanhtiec 
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ) AS [SanhDat],
        
        ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
        
        -- Label trạng thái
        CASE
            WHEN h.IsHuy = 1 THEN N'Đã Hủy'
            WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
            ELSE N'Đã Ký'
        END AS [TrangThai],
        
        -- ==========================================
        -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN 
        -- Dùng để binding vào file hop_dong.docx (docxtemplater)
        -- ==========================================
        RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
        RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
        CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

        -- Thông tin Bên A
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenA_NguoiDaiDien],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenA_ChucVu],
        ISNULL(h.UserCreate, '...') AS [BenA_NhanVienPhuTrach],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenA_SDT_NhanVien],

        -- Thông tin Bên B
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [BenB_TenDaiDien],
        ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenB_TenChuTiec],
        ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenB_CCCD],
        ISNULL(k.Diachi, '...') AS [BenB_DiaChi],
        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenB_DienThoai],

        -- Thông tin Tiệc
        N'TIỆC CƯỚI' AS [Tiec_LoaiTiec],
        ISNULL(h.GioDienRaSuKien, '...') AS [Tiec_GioBatDau],
        RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_NgayDL],
        RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_ThangDL],
        CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [Tiec_NamDL],
        CASE 
            WHEN CHARINDEX('/', h.Nhamngay) > 0 THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
            ELSE ISNULL(h.Nhamngay, '...')
        END AS [Tiec_NgayAL],
        CASE 
            WHEN CHARINDEX('/', h.Nhamngay) > 0 THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
            ELSE '...'
        END AS [Tiec_ThangAL],
        '...' AS [Tiec_NamAL],
        
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Tiec_SanhTiec],
        (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMin],
        (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMax],
        
        ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [Tiec_SoBanChinhThuc],
        ISNULL(h.SoBanTang, 0) AS [Tiec_SoBanTang],
        ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [Tiec_SoBanDuPhong],
        ISNULL(h.SoNguoiTrenBan, 10) AS [Tiec_SoKhach1Ban],
        
        -- Thông tin Cọc & Khuyến mãi
        FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [Coc_Lan1_SoTien],
        [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [Coc_Lan1_BangChu],
        RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Ngay],
        RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Thang],
        CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [Coc_Nam],
        
        ISNULL(h.Ghichu, '') AS [DieuKhoanBoSung],
        ISNULL(h.Noidunguudai, '') AS [DS_KhuyenMai]
        
    FROM 
        tbmk_Hopdong h
    LEFT JOIN 
        dmkhachhang k ON h.Makh = k.Makh
    WHERE 
        -- Bộ lọc theo Khoảng ngày (Dựa theo NgayToChuc)
        (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR h.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR h.Ngaytochuc <= @DenNgay)
        
        -- Bộ lọc Keyword tìm kiếm tương đối
        AND (
            @Keyword IS NULL OR @Keyword = ''
            OR h.Sohopdong LIKE '%' + @Keyword + '%'
            OR h.Sobiennhan LIKE '%' + @Keyword + '%'
            OR k.Tenkh LIKE N'%' + @Keyword + '%'
            OR k.Tenchure LIKE N'%' + @Keyword + '%'
            OR k.Tencodau LIKE N'%' + @Keyword + '%'
            OR k.Dienthoai LIKE '%' + @Keyword + '%'
        )
    ORDER BY 
        h.Sohopdong DESC;
        
END
GO
