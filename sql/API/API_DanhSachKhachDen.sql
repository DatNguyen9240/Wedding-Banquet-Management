USE [QLTiec]
GO

CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachKhachDen]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM v_DanhSachKhachThamQuan
    WHERE 
        (@Keyword IS NULL OR DocumentID LIKE '%' + @Keyword + '%' OR TenKhachHang LIKE N'%' + @Keyword + '%' OR DienThoai LIKE '%' + @Keyword + '%')
        AND (@TuNgay IS NULL OR NgayToChucGoc >= @TuNgay)
        AND (@DenNgay IS NULL OR NgayToChucGoc <= @DenNgay)
    ORDER BY 
        _DocumentDate DESC, NgayToChucGoc DESC;
END
GO
