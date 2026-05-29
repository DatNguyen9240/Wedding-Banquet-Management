USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[API_Report_Revenue]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Sohopdong AS [id],
        ISNULL((SELECT TOP 1 Tenkh FROM dmkhachhang WHERE Makh = h.Makh), N'Khách vãng lai') AS [customer],
        FORMAT(h.Ngaytochuc, 'dd/MM/yyyy') AS [date],
        h.Ngaytochuc AS [rawDate],
        ISNULL(h.Tongtienhopdong, 0) AS [revenue],
        ISNULL(h.TongSoBan, 0) AS [tables],
        ISNULL((
            SELECT TOP 1 s.Tensanhtiec 
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ), N'Chưa xếp sảnh') AS [hall]
    FROM tbmk_Hopdong h
    WHERE ISNULL(h.IsHuy, 0) = 0 
      AND ISNULL(h.IsKetthuc, 0) = 1
      AND (@TuNgay IS NULL OR h.Ngaytochuc >= @TuNgay)
      AND (@DenNgay IS NULL OR h.Ngaytochuc <= @DenNgay)
    ORDER BY h.Ngaytochuc ASC;

END
GO
