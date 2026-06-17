USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lũy kế nhận tiệc trong năm theo nhân viên Sales
-- Lấy tổng số bàn và doanh thu dự kiến từ Hợp Đồng
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_Report_SalesStats]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ISNULL(u.HoTen, h.UserCreate) AS SalesName,
        SUM(ISNULL(h.TongSoBan, 0)) AS TotalTables,
        SUM(ISNULL(h.Tongtienhopdong, 0)) AS EstimatedRevenue
    FROM tbmk_Hopdong h
    LEFT JOIN SY_User u ON h.UserCreate = u.UserName
    WHERE ISNULL(h.IsHuy, 0) = 0
      AND (@TuNgay IS NULL OR h.DateCreate >= @TuNgay)
      AND (@DenNgay IS NULL OR h.DateCreate <= @DenNgay)
    GROUP BY ISNULL(u.HoTen, h.UserCreate)
    ORDER BY EstimatedRevenue DESC;

END
GO
