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
    @ShowInFilter   bit              = 0,
    @ShowInGrid     bit              = NULL,
    @NoResult       bit              = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Lưu tất cả trực tiếp vào SY_FmtFldTbl (chỉ lưu các cột thực tế tồn tại)
    IF EXISTS (SELECT 1 FROM SY_FmtFldTbl WHERE FieldName = @FieldName AND FormName = @FormName)
    BEGIN
        UPDATE SY_FmtFldTbl
        SET CaptionVN     = ISNULL(@CaptionVN,     CaptionVN),
            FormatID      = ISNULL(@FormatID,      FormatID),
            CaptionEN     = ISNULL(@CaptionEN,     CaptionEN)
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
    ELSE
    BEGIN
        INSERT INTO SY_FmtFldTbl
            (FormName, FieldName, CaptionVN, FormatID, CaptionEN)
        VALUES
            (@FormName, @FieldName, @CaptionVN, @FormatID, @CaptionEN);
    END

    -- Đồng thời lưu các cấu hình bổ trợ (dropdown, ẩn hiện, khóa trường) vào SY_FrmDrdwTbl
    IF @DataSource IS NOT NULL AND @DataSource <> ''
    BEGIN
        IF EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = @FormName AND ColumnID = @FieldName)
        BEGIN
            UPDATE SY_FrmDrdwTbl
            SET Source = @DataSource,
                Type = 'API',
                ValueColumn = @FieldName,
                DisplayColumn = 'Ten',
                isInvisible = CASE WHEN @ShowInAdd = 0 AND @ShowInEdit = 0 THEN 1 ELSE 0 END,
                isLock = CASE WHEN @IsReadOnlyAdd = 1 OR @IsReadOnlyEdit = 1 THEN 1 ELSE 0 END
            WHERE FormID = @FormName AND ColumnID = @FieldName;
        END
        ELSE
        BEGIN
            INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn, isInvisible, isLock)
            VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), @FormName, @FieldName, @DataSource, 'API', @FieldName, 'Ten', 
                    CASE WHEN @ShowInAdd = 0 AND @ShowInEdit = 0 THEN 1 ELSE 0 END,
                    CASE WHEN @IsReadOnlyAdd = 1 OR @IsReadOnlyEdit = 1 THEN 1 ELSE 0 END);
        END
    END
    ELSE
    BEGIN
        -- Cập nhật ẩn/hiện/khóa cho các trường không phải dropdown
        IF EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = @FormName AND ColumnID = @FieldName)
        BEGIN
            UPDATE SY_FrmDrdwTbl
            SET isInvisible = CASE WHEN @ShowInAdd = 0 AND @ShowInEdit = 0 THEN 1 ELSE 0 END,
                isLock = CASE WHEN @IsReadOnlyAdd = 1 OR @IsReadOnlyEdit = 1 THEN 1 ELSE 0 END
            WHERE FormID = @FormName AND ColumnID = @FieldName;
        END
        ELSE
        BEGIN
            IF (@ShowInAdd = 0 AND @ShowInEdit = 0) OR (@IsReadOnlyAdd = 1 OR @IsReadOnlyEdit = 1)
            BEGIN
                INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible, isLock)
                VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), @FormName, @FieldName,
                        CASE WHEN @ShowInAdd = 0 AND @ShowInEdit = 0 THEN 1 ELSE 0 END,
                        CASE WHEN @IsReadOnlyAdd = 1 OR @IsReadOnlyEdit = 1 THEN 1 ELSE 0 END);
            END
        END
    END

    -- Trả về dữ liệu vừa lưu (giả lập các cột No-code để tương thích chữ ký frontend)
    IF @NoResult = 0
    BEGIN
        SELECT FormName, FieldName, CaptionVN, FormatID, CaptionEN, 
               @DataSource AS DataSource,
               @IsRequired AS IsRequired, 
               @FormPosition AS FormPosition, 
               @ShowInAdd AS ShowInAdd, 
               @ShowInEdit AS ShowInEdit, 
               @IsReadOnlyEdit AS IsReadOnlyEdit, 
               @IsReadOnlyAdd AS IsReadOnlyAdd,
               @ValidateRule AS ValidateRule, 
               @DependsOn AS DependsOn, 
               @VisibleRule AS VisibleRule, 
               ISNULL(@OrderNo, 0) AS OrderNo, 
               ISNULL(@ShowInFilter, 0) AS ShowInFilter, 
               ISNULL(@ShowInGrid, 1) AS ShowInGrid
        FROM SY_FmtFldTbl
        WHERE FieldName = @FieldName AND FormName = @FormName;
    END
END
GO
