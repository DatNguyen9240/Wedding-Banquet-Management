USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Mô tả: API Lấy giá trị cài đặt (CodeValue) dựa trên CodeID từ bảng SY_Setup
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_LayGiaTriSetup]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        [CodeID],
        [CodeValue]
    FROM [dbo].[SY_Setup]
    WHERE [CodeID] = 'Com1';
END
GO
