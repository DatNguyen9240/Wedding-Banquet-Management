USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-04-29
-- Description: API Lấy danh sách Sảnh Tiệc đang hoạt động
-- =============================================
CREATE PROCEDURE [dbo].[API_DanhSachSanh]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Sanhtiecid,
        Tensanhtiec,
        Succhua,
        SLBanMin,
        SLBanMax
    FROM dmSanhtiec
    WHERE IsTamngung = 0 OR IsTamngung IS NULL
    ORDER BY Tensanhtiec ASC;
END
GO
