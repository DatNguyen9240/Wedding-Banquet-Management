IF OBJECT_ID('API_LuuTruongGiaoDien', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuTruongGiaoDien;
GO

CREATE PROCEDURE API_LuuTruongGiaoDien
    @FormName       varchar(50)      = NULL,
    @FieldName      varchar(50)      = NULL,
    @CaptionVN      nvarchar(255)    = NULL,
    @FormatID       varchar(2)       = NULL,
    @CaptionEN      nvarchar(200)    = NULL,
    @DataSource     nvarchar(500)    = NULL,
    @IsRequired     bit              = 0,
    @FormPosition   varchar(50)      = NULL,
    @ShowInAdd      bit              = 1,
    @ShowInEdit     bit              = 1,
    @IsReadOnlyEdit bit              = 0,
    @IsReadOnlyAdd  bit              = 0,
    @ValidateRule   nvarchar(500)    = NULL,
    @DependsOn      varchar(50)      = NULL,
    @VisibleRule    nvarchar(500)    = NULL,
    @OrderNo        int              = NULL,
    @NoResult       bit              = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Lưu tất cả trực tiếp vào SY_FormatFields (không dùng array trong SY_FrmLstTbl nữa)
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FieldName = @FieldName AND FormName = @FormName)
    BEGIN
        UPDATE SY_FormatFields
        SET CaptionVN     = ISNULL(@CaptionVN,     CaptionVN),
            FormatID      = ISNULL(@FormatID,      FormatID),
            CaptionEN     = ISNULL(@CaptionEN,     CaptionEN),
            DataSource    = ISNULL(@DataSource,    DataSource),
            IsRequired    = ISNULL(@IsRequired,    IsRequired),
            FormPosition  = ISNULL(@FormPosition,  FormPosition),
            ShowInAdd     = ISNULL(@ShowInAdd,     ShowInAdd),
            ShowInEdit    = ISNULL(@ShowInEdit,    ShowInEdit),
            IsReadOnlyEdit= ISNULL(@IsReadOnlyEdit,IsReadOnlyEdit),
            IsReadOnlyAdd = ISNULL(@IsReadOnlyAdd, IsReadOnlyAdd),
            ValidateRule  = ISNULL(@ValidateRule,  ValidateRule),
            DependsOn     = ISNULL(@DependsOn,     DependsOn),
            VisibleRule   = ISNULL(@VisibleRule,   VisibleRule),
            OrderNo       = ISNULL(@OrderNo,       OrderNo)
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FormatFields
            (FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource,
             IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd,
             ValidateRule, DependsOn, VisibleRule, OrderNo)
        VALUES
            (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN, @DataSource,
             @IsRequired, @FormPosition, @ShowInAdd, @ShowInEdit, @IsReadOnlyEdit, @IsReadOnlyAdd,
             @ValidateRule, @DependsOn, @VisibleRule, ISNULL(@OrderNo, 0));
    END

    -- Trả về dữ liệu vừa lưu
    IF @NoResult = 0
    BEGIN
        SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, DataSource,
               IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd,
               ValidateRule, DependsOn, VisibleRule, OrderNo
        FROM SY_FormatFields
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
END
GO
