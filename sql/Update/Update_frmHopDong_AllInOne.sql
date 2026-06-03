USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. STORED PROCEDURE: API_DanhSachHopDong
-- Mục đích: Lấy danh sách hợp đồng kèm theo các biến in ấn đã format sẵn
-- =========================================================================
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

        -- Thông tin Bên A (Nhà hàng)
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenA_NguoiDaiDien],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenA_ChucVu],
        ISNULL(h.UserCreate, '...') AS [BenA_NhanVienPhuTrach],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenA_SDT_NhanVien],

        -- Thông tin Bên B (Khách hàng)
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

-- =========================================================================
-- 2. SQL VIEW: v_DanhSachHopDong
-- Mục đích: Làm nguồn dữ liệu hiển thị (Grid/Form) cho màn hình frmHopDong
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [SoHopDong],
    h.Sobiennhan,
    h.Makh,
    
    -- Lấy thông tin khách hàng từ dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenKhachHang],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    
    h.Ngaytochuc AS [NgayToChucGoc],
    CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS [NgayToChuc],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
    ) AS [SanhDat],
    
    ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
    
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
    '' AS [BenB_ChucVu],

    -- Thông tin Tiệc
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
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh;
GO

-- =========================================================================
-- 3. ĐỒNG BỘ CẤU HÌNH GIAO DIỆN (METADATA - SY_FormatFields)
-- =========================================================================

-- Cập nhật Form Hợp Đồng chọc vào View này
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachHopDong', PrimaryKey = 'SoHopDong'
WHERE FormID = 'frmHopDong';
GO

-- Đồng bộ lại cấu hình các cột giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
GO

-- Ẩn các cột chỉ dùng để IN ẤN khỏi giao diện Grid/Form để tránh rối mắt người dùng
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0
WHERE FormName = 'frmHopDong' 
  AND FieldName IN (
    'NgayLapHD', 'ThangLapHD', 'NamLapHD',
    'BenA_NguoiDaiDien', 'BenA_ChucVu', 'BenA_NhanVienPhuTrach', 'BenA_SDT_NhanVien',
    'BenB_TenDaiDien', 'BenB_TenChuTiec', 'BenB_CCCD', 'BenB_DiaChi', 'BenB_DienThoai', 'BenB_ChucVu',
    'Tiec_GioBatDau', 'Tiec_NgayDL', 'Tiec_ThangDL', 'Tiec_NamDL',
    'Tiec_NgayAL', 'Tiec_ThangAL', 'Tiec_NamAL',
    'Tiec_SanhTiec', 'Sanh_QuyMoMin', 'Sanh_QuyMoMax',
    'Tiec_SoBanChinhThuc', 'Tiec_SoBanTang', 'Tiec_SoBanDuPhong', 'Tiec_SoKhach1Ban',
    'Coc_Lan1_SoTien', 'Coc_Lan1_BangChu', 'Coc_Ngay', 'Coc_Thang', 'Coc_Nam',
    'DieuKhoanBoSung', 'DS_KhuyenMai'
  );
GO

-- Cập nhật tiêu đề tiếng Việt thân thiện có dấu cho toàn bộ các cột
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'ThangLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Năm lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NamLapHD';

UPDATE SY_FormatFields SET CaptionVN = N'Người đại diện Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NguoiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_ChucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_SDT_NhanVien';

UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Chủ Tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenChuTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_ChucVu';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_GioBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayDL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangDL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamDL';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayAL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangAL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamAL';

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMin';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMax';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanChinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tặng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanTang';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanDuPhong';
UPDATE SY_FormatFields SET CaptionVN = N'Số khách/Bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoKhach1Ban';

UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Ngay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Thang';
UPDATE SY_FormatFields SET CaptionVN = N'Năm cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Nam';

UPDATE SY_FormatFields SET CaptionVN = N'Điều khoản bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';
UPDATE SY_FormatFields SET CaptionVN = N'Khuyến mãi' WHERE FormName = 'frmHopDong' AND FieldName = 'DS_KhuyenMai';

-- Cập nhật tiêu đề tiếng Việt thân thiện cho các cột gốc (Grid mặc định)
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmHopDong' AND FieldName = 'SoHopDong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã KH' WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
GO
