IF OBJECT_ID('API_DanhSachTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachTruongGiaoDien;
GO

CREATE PROCEDURE API_DanhSachTruongGiaoDien
    @Keyword nvarchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        FormName, FieldName, CaptionVN, FormatID, CaptionEN, IsRequired, FormPosition, ShowInForm
    FROM SY_FormatFields
    WHERE (@Keyword IS NULL OR @Keyword = '' 
           OR FormName LIKE '%' + @Keyword + '%' 
           OR FieldName LIKE '%' + @Keyword + '%'
           OR CaptionVN LIKE N'%' + @Keyword + '%')
    ORDER BY FormName ASC, FieldName ASC;
END
GO
