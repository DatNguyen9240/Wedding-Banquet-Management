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
        (@Keyword IS NULL OR DocumentID LIKE '%' + @Keyword + '%' OR TenKhachHang LIKE N'%' + @Keyword + '%' OR DienThoai LIKE '%' + @Keyword + '%' OR CCCD LIKE '%' + @Keyword + '%')
        AND (@TuNgay IS NULL OR [Ngaytochuc] >= @TuNgay)
        AND (@DenNgay IS NULL OR [Ngaytochuc] <= @DenNgay)
    ORDER BY 
        DocumentDate DESC, [Ngaytochuc] DESC;
END
GO
