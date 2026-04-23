USE [QLTiec]
GO

/****** Object:  StoredProcedure [dbo].[API_WA_LayDanhSachMenuAll] ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[API_WA_LayDanhSachMenuAll]
    @NhomNguoiDangThaoTac NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        MenuID AS [id],
        COALESCE(Parent, '') AS [parent],
        COALESCE(VN, '') AS [label],
        COALESCE(EN, '') AS [en],
        COALESCE(FormName, '') AS [formName],
        COALESCE(IconClass, '') AS [icon],
        COALESCE(isDisable, 0) AS [isDisable]
    FROM WA_Menu
    ORDER BY Parent, MenuID ASC;
END
GO
