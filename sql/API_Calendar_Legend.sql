USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Chú thích Lịch (Legend) dựa trực tiếp trên dữ liệu thật của DB
-- Phản ánh số lượng thực tế từ các bảng tbmk_Biennhancoccho và tbmk_Hopdong
-- =============================================
CREATE PROCEDURE [dbo].[API_Calendar_Legend]
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Đếm số lượng tiệc mới cọc (chưa lên hợp đồng, chưa hủy) từ bảng tbmk_Biennhancoccho
    DECLARE @CocCount INT = 0;
    SELECT @CocCount = COUNT(*) 
    FROM tbmk_Biennhancoccho 
    WHERE ISNULL(IsHuy, 0) = 0 AND ISNULL(IsKetthuc, 0) = 0;

    -- 2. Đếm số lượng hợp đồng đã ký (chưa hủy) từ bảng tbmk_Hopdong
    DECLARE @HdCount INT = 0;
    SELECT @HdCount = COUNT(*) 
    FROM tbmk_Hopdong 
    WHERE ISNULL(IsHuy, 0) = 0;

    -- 3. Đếm số lượng tiệc có sử dụng sảnh phụ từ bảng tbmk_Hopdongsanhtiec
    DECLARE @SanhPhuCount INT = 0;
    SELECT @SanhPhuCount = COUNT(DISTINCT Sohopdong) 
    FROM tbmk_Hopdongsanhtiec 
    WHERE ISNULL(IsSanhchinh, 1) = 0;

    -- Trả về kết quả legend động hoàn toàn dựa vào DB thực tế
    SELECT 
        1 AS Id, 
        N'Mới Cọc (' + CAST(@CocCount AS NVARCHAR(10)) + N')' AS Label, 
        'success' AS Color, 
        'dot' AS Type, 
        '' AS Icon
    UNION ALL
    SELECT 
        2 AS Id, 
        N'Đã Ký HĐ (' + CAST(@HdCount AS NVARCHAR(10)) + N')' AS Label, 
        'danger' AS Color, 
        'dot' AS Type, 
        '' AS Icon
    UNION ALL
    SELECT 
        3 AS Id, 
        N'Sảnh Phụ (' + CAST(@SanhPhuCount AS NVARCHAR(10)) + N')' AS Label, 
        'secondary' AS Color, 
        'icon' AS Type, 
        'close' AS Icon
END
GO
