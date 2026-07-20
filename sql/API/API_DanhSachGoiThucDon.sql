USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  API Lấy danh sách Gói Thực Đơn (Gói Tiệc)
  Dùng để làm nguồn dữ liệu (DataSource) cho các Dropdown/Combobox trên giao diện.
*/
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachGoiThucDon]
    @Keyword NVARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        GoiThucDonID,
        TenGoiThucDon

    FROM 
        [dbo].[dmGoiThucDon]
    WHERE 
        (@Keyword = '' OR TenGoiThucDon LIKE N'%' + @Keyword + '%' OR GoiThucDonID LIKE '%' + @Keyword + '%')
    ORDER BY 
        TenGoiThucDon ASC;
END
GO
