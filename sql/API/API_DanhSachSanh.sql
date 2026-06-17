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
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachSanh]
    @Keyword NVARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Sanhtiecid AS [Mã sảnh],
        Tensanhtiec AS [Tên sảnh],
        SLBanMin AS [Bàn tối thiểu (Min)],
        SLBanMax AS [Bàn tối đa (Max)],
        SLBanMin AS [SobanManchinhthuc]
    FROM dmSanhtiec
    WHERE (IsTamngung = 0 OR IsTamngung IS NULL)
      AND (@Keyword = '' OR Tensanhtiec LIKE N'%' + @Keyword + '%' OR Sanhtiecid LIKE '%' + @Keyword + '%')
    ORDER BY Tensanhtiec ASC;
END
GO
