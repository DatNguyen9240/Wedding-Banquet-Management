USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Mô tả: API Lấy danh sách Loại Hình Tiệc (Cưới, Thôi nôi, v.v...)
-- =============================================
CREATE PROCEDURE [dbo].[API_Loaihinhtiec_List]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Loaitiecid AS Loaihinhtiecid,
        Tenloaitiec AS Tenloaihinhtiec
    FROM dmLoaihinhtiec
    ORDER BY Tenloaitiec ASC;
END
GO
