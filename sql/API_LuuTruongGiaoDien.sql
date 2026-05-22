IF OBJECT_ID('API_LuuTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuTruongGiaoDien;
GO

CREATE PROCEDURE API_LuuTruongGiaoDien
    @FormName varchar(50) = NULL,
    @FieldName varchar(50) = NULL,
    @CaptionVN nvarchar(255) = NULL,
    @FormatID varchar(2) = NULL,
    @CaptionEN nvarchar(200) = NULL,
    @IsRequired bit = 0,
    @FormPosition varchar(50) = NULL,
    @ShowInForm bit = 0
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
            IsRequired = @IsRequired,
            FormPosition = @FormPosition,
            ShowInForm = @ShowInForm
        WHERE FieldName = @FieldName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, CaptionEN, IsRequired, FormPosition, ShowInForm)
        VALUES (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN, @IsRequired, @FormPosition, @ShowInForm);
    END

    -- Trả về dữ liệu vừa lưu
    SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, IsRequired, FormPosition, ShowInForm
    FROM SY_FormatFields 
    WHERE FieldName = @FieldName;
END
GO
