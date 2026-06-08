USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Booking (Biên nhận cọc chỗ)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_DanhSachPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_DanhSachPhieuCoc];
END
GO
CREATE PROCEDURE [dbo].[API_DanhSachPhieuCoc]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.DocumentID AS [DocumentID],
        b.DocumentID AS [MaChungTu],
        b.DocumentID AS [Sobiennhan], -- Hỗ trợ Workflow mapping tự động sang Hợp đồng
        b.SoBN AS [SoPhieu],
        
        -- Thông tin khách hàng chi tiết
        k.Tenchure AS [Tenchure],
        k.Tencodau AS [Tencodau],
        k.DTchure AS [DTchure],
        k.DTcodau AS [DTcodau],
        k.Diachi AS [Diachi],
        k.Nguoigd AS [Nguoigd],
        k.DienThoaiDaiDien AS [DienThoaiDaiDien],
        k.Mail AS [Mail],
        
        b.Thoigianid AS [Thoigianid],
        b.Loaitiecid AS [Loaitiecid],
        b.Nhamngay AS [Nhamngay],
        b.SobanManchinhthuc AS [SobanManchinhthuc],
        b.SobanManduphong AS [SobanManduphong],
        b.SobanChaychinhthuc AS [SobanChaychinhthuc],
        b.SobanChayduphong AS [SobanChayduphong],
        b.Ghichu AS [Ghichu],
        
        -- Các trường bổ sung phục vụ in mẫu Phiếu Thu (phieu_thu.docx)
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com1') AS [TenNhaHang],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com2') AS [DiaChiNhaHang],

        ISNULL(NULLIF(b.Lydo, ''), N'Cọc giữ chỗ lần ' + CAST(ISNULL(b.Solan, 1) AS NVARCHAR(10))) AS [Lydo],
        RIGHT('0' + CAST(d.Ngay AS VARCHAR(2)), 2) AS [Ngay],
        RIGHT('0' + CAST(d.Thang AS VARCHAR(2)), 2) AS [Thang],
        d.Nam AS [Nam],
        CONVERT(VARCHAR(10), d.DDate, 103) AS [NgayThu],
        d.DDate AS [DocumentDate],
        b.DocumentID AS [Sohopdong],
        FORMAT(ISNULL(b.Tongtien, 0), 'N0', 'vi-VN') AS [Tongtien],
        ISNULL(b.Tongtien, 0) AS [TongtienRaw],
        [dbo].[fn_DocTienBangChu](ISNULL(b.Tongtien, 0)) AS [SoTienBangChu],
        ISNULL(b.TaiKhoanNo, '') AS [TaiKhoanNo],
        ISNULL(b.TaiKhoanCo, '') AS [TaiKhoanCo],
        ISNULL(b.Kemtheo, '') AS [Kemtheo],
        ISNULL(NULLIF(b.HinhThuc, ''), N'Tiền mặt / Chuyển khoản') AS [HinhThuc],
        
        -- Ghép Tên 2 người, hoặc xài Tên Khách chung chung nếu không có
        c.FullName AS [TenKhachHang],
        ISNULL(NULLIF(k.Nguoigd, ''), c.FullName) AS [Nguoinop],
        
        -- Lấy sdt nếu không có bốc số chú rể / cô dâu / đại diện
        ISNULL(NULLIF(k.Dienthoai, ''), ISNULL(NULLIF(k.DTchure, ''), ISNULL(NULLIF(k.DTcodau, ''), k.DienThoaiDaiDien))) AS [DienThoai],
        
        b.Solan AS [Solan], -- Thêm cột Lần cọc để Form Sửa tự động điền (fill) vào dropdown
        b.Ngaytochuc AS [Ngaytochuc],
        b.Ngaytochuc AS [NgayToChuc], -- Hỗ trợ Workflow mapping tự động sang Hợp đồng
        
        ISNULL(b.Tongsoban, 0) AS [SoBan],
        
        -- Lấy Sảnh đặt bằng subquery (Hiển thị tất cả các sảnh được chọn)
        STUFF((
            SELECT ', ' + s.Tensanhtiec + CASE WHEN bs.IsSanhchinh = 1 THEN N' (Chính)' ELSE N' (Phụ)' END
            FROM tbmk_Biennhancocchosanhtiec bs 
            INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
            WHERE bs.DocumentID = b.DocumentID
            ORDER BY bs.IsSanhchinh DESC, s.Tensanhtiec ASC
            FOR XML PATH('')
        ), 1, 2, '') AS [SanhDat],
        
        -- Tiền đã cọc (lấy động theo Lần cọc từ Booking)
        ISNULL(
            CASE 
                WHEN ISNULL(b.Solan, 1) = 2 THEN (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentID = b.DocumentIDcu)
                ELSE b.Tongtien 
            END, 0
        ) AS [DaCocVND],
        ISNULL(
            CASE 
                WHEN ISNULL(b.Solan, 1) = 2 THEN b.Tongtien
                ELSE (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentIDcu = b.DocumentID AND Solan = 2)
            END, 0
        ) AS [Sotiencochopdong],
        
        -- Danh sách chi tiết sảnh
        (
            SELECT Sanhtiecid, IsSanhchinh 
            FROM tbmk_Biennhancocchosanhtiec 
            WHERE DocumentID = b.DocumentID 
            FOR JSON PATH
        ) AS [_JsonSanhTiec],
        (
            SELECT TOP 1 Sanhtiecid 
            FROM tbmk_Biennhancocchosanhtiec 
            WHERE DocumentID = b.DocumentID 
            ORDER BY IsSanhchinh DESC
        ) AS [JsonSanhTiec],
        
        -- Label trạng thái
        CASE
            WHEN b.IsHuy = 1 THEN N'Đã Hủy'
            WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
            WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
            ELSE N'Đã cọc lần 1'
        END AS [TrangThai]
        
    FROM 
        tbmk_Biennhancoccho b
    LEFT JOIN 
        dmkhachhang k ON b.Makh = k.Makh
    OUTER APPLY (
        SELECT 
            CASE 
                WHEN ISNULL(k.Tenchure, '') <> '' AND ISNULL(k.Tencodau, '') <> '' 
                    THEN k.Tenchure + ' & ' + k.Tencodau
                WHEN ISNULL(k.Tenchure, '') <> ''
                    THEN k.Tenchure
                WHEN ISNULL(k.Tencodau, '') <> ''
                    THEN k.Tencodau
                ELSE ISNULL(NULLIF(k.Tenkh, ''), ISNULL(NULLIF(k.Nguoigd, ''), N'Khách vãng lai'))
            END AS FullName
    ) c
    OUTER APPLY (
        SELECT 
            ISNULL(b.DocumentDate, GETDATE()) AS DDate,
            DAY(ISNULL(b.DocumentDate, GETDATE())) AS Ngay,
            MONTH(ISNULL(b.DocumentDate, GETDATE())) AS Thang,
            YEAR(ISNULL(b.DocumentDate, GETDATE())) AS Nam
    ) d
    WHERE 
        -- Nếu có tìm kiếm thì ưu tiên
        (@Keyword IS NULL OR @Keyword = '' OR b.DocumentID LIKE '%' + @Keyword + '%' OR b.SoBN LIKE '%' + @Keyword + '%' OR k.Dienthoai LIKE '%' + @Keyword + '%' OR k.Tenkh LIKE N'%' + @Keyword + '%' OR k.Tenchure LIKE N'%' + @Keyword + '%' OR k.Tencodau LIKE N'%' + @Keyword + '%')
        
        -- Lọc ngày tổ chức nếu truyền TuNgay / DenNgay (bỏ qua nếu là chuỗi rỗng / 1900-01-01)
        AND (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc <= @DenNgay)
        AND ISNULL(b.IsDeleted, 0) = 0
        
    ORDER BY 
        b.Ngaytochuc DESC, b.DocumentDate DESC;
END
GO
