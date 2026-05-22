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
    @ShowInEdit bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- Update nếu đã tồn tại FieldName (vì FieldName là UNIQUE)
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FieldName = @FieldName)
    BEGIN
        UPDATE SY_FormatFields
        SET FormName = @FormName,
            CaptionVN = @CaptionVN,
            FormatID = @FormatID,
            CaptionEN = @CaptionEN,
            DataSource = @DataSource,
            IsRequired = @IsRequired,
            FormPosition = @FormPosition,
            ShowInAdd = @ShowInAdd,
            ShowInEdit = @ShowInEdit
        WHERE FieldName = @FieldName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
        VALUES (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN, @DataSource, @IsRequired, @FormPosition, @ShowInAdd, @ShowInEdit);
    END

    -- Trả về dữ liệu vừa lưu
    SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource, IsRequired, FormPosition, ShowInAdd, ShowInEdit
    FROM SY_FormatFields 
    WHERE FieldName = @FieldName;
END
GO
