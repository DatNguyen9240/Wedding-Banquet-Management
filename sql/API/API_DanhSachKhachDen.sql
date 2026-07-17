USE [QLTiec]
GO

IF OBJECT_ID('dbo.API_DanhSachKhachDen', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachKhachDen;
GO
CREATE PROCEDURE [dbo].[API_DanhSachKhachDen]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        MaPhieu, DocumentID, Makh, TenKhachHang, DienThoai, CCCD,
        NgayDuKien, NgayAmLich, GoiThucDonID, GoiTiec, Loaitiecid,
        Thoigianid, SobanMan, SobanChay, Ghichu, Ngaytochuc, DocumentDate,
        Tenchure, Tencodau, DTchure, DTcodau, Diachi, Mail, Nguoigd,
        DienThoaiDaiDien, SanhTiec, SanhTiecID, TrangThai
    FROM v_DanhSachKhachThamQuan
    WHERE 
        (@Keyword IS NULL OR DocumentID LIKE '%' + @Keyword + '%' OR TenKhachHang LIKE N'%' + @Keyword + '%' OR DienThoai LIKE '%' + @Keyword + '%' OR CCCD LIKE '%' + @Keyword + '%')
        AND (@TuNgay IS NULL OR [Ngaytochuc] >= @TuNgay)
        AND (@DenNgay IS NULL OR [Ngaytochuc] <= @DenNgay)
    ORDER BY 
        DocumentDate DESC, [Ngaytochuc] DESC;
END
GO
