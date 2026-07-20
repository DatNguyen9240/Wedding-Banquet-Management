USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Mô tả: API Lấy danh sách Loại Hình Tiệc (Cưới, Thôi nôi, v.v...)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachLoaiHinhTiec]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Loaitiecid,
        Tenloaitiec
    FROM dmLoaihinhtiec
    ORDER BY Tenloaitiec ASC;
END
GO
