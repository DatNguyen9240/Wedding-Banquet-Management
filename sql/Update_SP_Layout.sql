IF OBJECT_ID('API_LuuTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuTruongGiaoDien;
GO

CREATE PROCEDURE API_LuuTruongGiaoDien
    @FormName varchar(50) = NULL,
    @FieldName varchar(50) = NULL,
    @CaptionVN nvarchar(255) = NULL,
    @FormatID varchar(2) = NULL,
    @CaptionEN nvarchar(200) = NULL,
    @DataSource nvarchar(500) = NULL,
    @IsRequired bit = 0,
    @FormPosition varchar(50) = NULL,
    @ShowInAdd bit = 1,
    @ShowInEdit bit = 1,
    @OrderNo int = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FieldName = @FieldName AND FormName = @FormName)
    BEGIN
        UPDATE SY_FormatFields
        SET CaptionVN = @CaptionVN,
            FormatID = @FormatID,
            CaptionEN = @CaptionEN,
            DataSource = @DataSource,
            IsRequired = @IsRequired,
            FormPosition = @FormPosition,
            ShowInAdd = @ShowInAdd,
            ShowInEdit = @ShowInEdit,
            OrderNo = @OrderNo
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ShowInAdd, ShowInEdit, OrderNo)
        VALUES (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN, @DataSource, @IsRequired, @FormPosition, @ShowInAdd, @ShowInEdit, @OrderNo);
    END

    SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ShowInAdd, ShowInEdit, OrderNo
    FROM SY_FormatFields 
    WHERE FieldName = @FieldName AND FormName = @FormName;
END
GO

IF OBJECT_ID('API_DanhSachTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachTruongGiaoDien;
GO

CREATE PROCEDURE API_DanhSachTruongGiaoDien
    @Keyword nvarchar(100) = NULL,
    @FormName nvarchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        AutoID, FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ShowInAdd, ShowInEdit, OrderNo
    FROM SY_FormatFields
    WHERE 
        (@Keyword IS NULL OR @Keyword = '' 
         OR FormName LIKE '%' + @Keyword + '%' 
         OR FieldName LIKE '%' + @Keyword + '%'
         OR CaptionVN LIKE N'%' + @Keyword + '%')
        AND
        (@FormName IS NULL OR @FormName = '' OR FormName = @FormName)
    ORDER BY FormName ASC, OrderNo ASC, FieldName ASC;
END
GO
