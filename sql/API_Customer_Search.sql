USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-04-29
-- Description: API Tìm kiếm nhanh thông tin Khách hàng cũ
-- =============================================
CREATE PROCEDURE [dbo].[API_Customer_Search]
    @Keyword NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tìm theo Tên Cô Dâu, Tên Chú Rể, Tên Khách Hàng chung, hoặc Số Điện Thoại
    SELECT TOP 20
        Makh,
        Tenkh,
        Tenchure,
        Tencodau,
        Dienthoai,
        Diachi,
        Mail
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%'
    ORDER BY DateCreate DESC;
END
GO
