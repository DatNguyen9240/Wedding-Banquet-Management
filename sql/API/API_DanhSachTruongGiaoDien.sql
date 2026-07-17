USE [QLTiec]
GO

/*
  Retired endpoint. Metadata is served only by dbo.API_LoadFormMeta.
  Keeping this procedure makes an outdated caller fail explicitly instead of
  reading an incompatible metadata shape.
*/
CREATE OR ALTER PROCEDURE dbo.API_DanhSachTruongGiaoDien
    @Keyword NVARCHAR(100) = NULL,
    @FormName NVARCHAR(100) = NULL,
    @SortColumn VARCHAR(50) = '',
    @SortDir VARCHAR(10) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SELECT -1 AS code, N'API_DanhSachTruongGiaoDien is retired. Use API_LoadFormMeta.' AS msg;
END
GO
