USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy dữ liệu Báo cáo Chi Phí
-- Do hệ thống chưa có module Định mức Nguyên vật liệu (BOM) hay Phiếu Chi,
-- Báo cáo này sẽ giả lập Tỷ trọng chi phí (Cost Margin) theo tiêu chuẩn ngành F&B:
-- - Food Cost (Chi phí thực đơn): ~ 45% doanh thu
-- - Service Cost (Chi phí dịch vụ/trang trí): ~ 15% doanh thu
-- - Staff Cost (Chi phí nhân sự): ~ 10% doanh thu
-- =============================================
CREATE PROCEDURE [dbo].[API_Report_Cost]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Sohopdong AS [id],
        ISNULL((SELECT TOP 1 Tenkh FROM dmkhachhang WHERE Makh = h.Makh), N'Khách vãng lai') AS [customer],
        FORMAT(h.Ngaytochuc, 'dd/MM/yyyy') AS [date],
        h.Ngaytochuc AS [rawDate],
        ISNULL(h.Tongtienhopdong, 0) AS [revenue],
        
        -- Tính toán chi phí ước tính dựa trên Biên độ lợi nhuận (Margin)
        CAST(ISNULL(h.Tongtienhopdong, 0) * 0.45 AS BIGINT) AS [foodCost],
        CAST(ISNULL(h.Tongtienhopdong, 0) * 0.15 AS BIGINT) AS [serviceCost],
        CAST(ISNULL(h.Tongtienhopdong, 0) * 0.10 AS BIGINT) AS [staffCost],
        
        -- Tổng chi phí = Food + Service + Staff
        CAST(ISNULL(h.Tongtienhopdong, 0) * 0.70 AS BIGINT) AS [totalCost]
        
    FROM tbmk_Hopdong h
    WHERE ISNULL(h.IsHuy, 0) = 0 
      AND ISNULL(h.IsKetthuc, 0) = 1 -- Chỉ tính các tiệc Đã Quyết toán
      AND (@TuNgay IS NULL OR h.Ngaytochuc >= @TuNgay)
      AND (@DenNgay IS NULL OR h.Ngaytochuc <= @DenNgay)
      AND (@Keyword IS NULL OR @Keyword = '' OR h.Sohopdong LIKE '%' + @Keyword + '%')
    ORDER BY h.Ngaytochuc ASC;

END
GO
