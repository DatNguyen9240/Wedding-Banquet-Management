USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Khách Tham Quan (Visitor)
-- =============================================
CREATE PROCEDURE [dbo].[API_DanhSachKhachDen]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.DocumentID AS [MaPhieu],
        v.Tenkh AS [TenKhachHang],
        v.Dienthoai AS [DienThoai],
        
        CONVERT(VARCHAR(10), v.Ngaytochuc, 103) AS [NgayDuKien],
        v.Nhamngay AS [NgayAmLich],
        
        -- Dữ liệu ngầm định (Raw fields) phục vụ cho Form Edit binding dữ liệu
        v.DocumentID,
        v.Makh,
        t.GoiThucDonID,
        t.Loaitiecid,
        t.Thoigianid,
        t.SobanMan,
        t.SobanChay,
        t.Ghichu,
        
        -- Thông tin loại tiệc và sảnh
        v.Tenloaitiec AS [GoiTiec],
        (
            SELECT TOP 1 s.Tensanhtiec 
            FROM tbmk_Khachthamquansanhtiec bs 
            INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
            WHERE bs.DocumentID = v.DocumentID
        ) AS [TenSanhTiec],
        
        -- Dành riêng cho Edit Form Binding
        (
            SELECT TOP 1 bs.Sanhtiecid 
            FROM tbmk_Khachthamquansanhtiec bs 
            WHERE bs.DocumentID = v.DocumentID
        ) AS [SanhTiec],
        
        -- Label trạng thái
        CASE
            WHEN t.IsHuy = 1 THEN N'Đã Hủy'
            WHEN t.IsKetthuc = 1 THEN N'Đã Đặt Cọc'
            ELSE N'Đang Tư Vấn'
        END AS [TrangThai]
        
    FROM 
        SelectKhachThamQuanView v
    LEFT JOIN
        tbmk_Khachthamquan t ON v.DocumentID = t.DocumentID
    WHERE 
        -- Filter theo Keyword (Mã Phiếu, Tên Khách, SĐT)
        (@Keyword IS NULL OR v.DocumentID LIKE '%' + @Keyword + '%' OR v.Tenkh LIKE N'%' + @Keyword + '%' OR v.Dienthoai LIKE '%' + @Keyword + '%')
        
        -- Lọc ngày dự kiến tổ chức nếu truyền TuNgay / DenNgay
        AND (@TuNgay IS NULL OR v.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR v.Ngaytochuc <= @DenNgay)
        
    ORDER BY 
        v.DocumentDate DESC, v.Ngaytochuc DESC;
END
GO
