USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  Canonical metadata contract

  SY_FmtFldTbl  : global field dictionary (FieldName, Caption*, FormatID, alignment, widths)
  SY_FmatTbl    : format definition (FormatID, masks, ranges, precision)
  SY_FrmDrdwTbl : UI lookup behaviour (FormID + GridName + ColumnID)
  SY_FrmLstTbl  : form-level grid configuration (HideColumnArr)

  A field must exist in the field dictionary and its FormatID must exist in the
  format dictionary. The procedure deliberately returns a configuration error
  instead of inventing labels or formats at runtime.
*/
CREATE OR ALTER PROCEDURE dbo.API_LoadFormMeta
    @FormName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ObjectId INT = OBJECT_ID(@FormName);
    DECLARE @PrimaryKey VARCHAR(100) = '';
    DECLARE @MissingFields NVARCHAR(MAX) = '';
    DECLARE @DuplicateFields NVARCHAR(MAX) = '';
    DECLARE @DuplicateDropdowns NVARCHAR(MAX) = '';
    DECLARE @MissingCaptions NVARCHAR(MAX) = '';
    DECLARE @InvalidFormats NVARCHAR(MAX) = '';
    DECLARE @HideColumnArr VARCHAR(MAX) = '';
    DECLARE @AddNewColumnArr VARCHAR(MAX) = '';
    DECLARE @EditorColumnArr VARCHAR(MAX) = '';
    DECLARE @RequiredObjectId INT = @ObjectId;
    DECLARE @HidePrintBtn BIT = 0;

    IF @ObjectId IS NULL
    BEGIN
        SELECT -1 AS code, N'Không tìm thấy bảng hoặc view: ' + ISNULL(@FormName, '') AS msg;
        RETURN;
    END;

    IF OBJECT_ID('dbo.SY_FmtFldTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FmatTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FrmDrdwTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FrmLstTbl', 'U') IS NULL
    BEGIN
        SELECT -1 AS code, N'Thiếu bảng metadata chuẩn SY_FmtFldTbl, SY_FmatTbl, SY_FrmDrdwTbl hoặc SY_FrmLstTbl.' AS msg;
        RETURN;
    END;

    /*
      The router calls this procedure with TableName. FormID is also accepted
      for callers that load metadata directly. HideColumnArr is a semicolon-
      separated list, for example: objectName;objectPhone. AddNewColumnArr and
      EditorColumnArr are optional allow-lists for the add/edit modal; when
      populated, every other view column remains available only as a hidden
      input so read-model JSON does not become an editable textbox.
    */
    SELECT TOP (1)
        @HideColumnArr = ISNULL(formConfig.HideColumnArr, ''),
        @AddNewColumnArr = ISNULL(formConfig.AddNewColumnArr, ''),
        @EditorColumnArr = ISNULL(formConfig.EditorColumnArr, ''),
        @PrimaryKey = NULLIF(LTRIM(RTRIM(formConfig.PrimaryKey)), ''),
        @HidePrintBtn = ISNULL(formConfig.HidePrintBtn, 0)
    FROM dbo.SY_FrmLstTbl formConfig
    WHERE formConfig.FormID = @FormName
       OR formConfig.TableName = @FormName
    ORDER BY CASE WHEN formConfig.FormID = @FormName THEN 0 ELSE 1 END;

    /*
      v_DanhSachHopDong là read-model: nullability của view không phản ánh đúng
      cột nhập liệu. Required phải lấy từ bảng ghi thật tbmk_Hopdong.
    */
    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FrmLstTbl formConfig
        WHERE (formConfig.FormID = @FormName OR formConfig.TableName = @FormName)
          AND formConfig.TableName = 'v_DanhSachHopDong'
    )
        SET @RequiredObjectId = OBJECT_ID(N'dbo.tbmk_Hopdong', N'U');

    /* FieldName is global. More than one dictionary row for a name is invalid. */
    SELECT @DuplicateFields = STUFF((
        SELECT N', ' + d.FieldName
        FROM (
            SELECT FieldName
            FROM dbo.SY_FmtFldTbl
            GROUP BY FieldName
            HAVING COUNT(*) > 1
        ) d
        ORDER BY d.FieldName
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF ISNULL(@DuplicateFields, '') <> ''
    BEGIN
        SELECT -1 AS code, N'Trùng FieldName trong SY_FmtFldTbl: ' + @DuplicateFields AS msg;
        RETURN;
    END;

    SELECT @DuplicateDropdowns = STUFF((
        SELECT N', ' + d.ColumnID
        FROM (
            SELECT ColumnID
            FROM dbo.SY_FrmDrdwTbl
            WHERE FormID = @FormName
              AND NULLIF(LTRIM(RTRIM(GridName)), '') IS NULL
            GROUP BY ColumnID
            HAVING COUNT(*) > 1
        ) d
        ORDER BY d.ColumnID
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF ISNULL(@DuplicateDropdowns, '') <> ''
    BEGIN
        SELECT -1 AS code, N'Trung ColumnID trong SY_FrmDrdwTbl: ' + @DuplicateDropdowns AS msg;
        RETURN;
    END;

    SELECT @MissingFields = STUFF((
        SELECT N', ' + c.name
        FROM sys.columns c
        WHERE c.object_id = @ObjectId
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.SY_FmtFldTbl f
              WHERE f.FieldName = c.name
          )
        ORDER BY c.column_id
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF ISNULL(@MissingFields, '') <> ''
    BEGIN
        SELECT -1 AS code, N'Chưa đồng bộ dictionary cho field: ' + @MissingFields AS msg;
        RETURN;
    END;

    SELECT @MissingCaptions = STUFF((
        SELECT N', ' + f.FieldName
        FROM dbo.SY_FmtFldTbl f
        WHERE EXISTS (
            SELECT 1
            FROM sys.columns c
            WHERE c.object_id = @ObjectId AND c.name = f.FieldName
        )
          AND NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL
        ORDER BY f.FieldName
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF ISNULL(@MissingCaptions, '') <> ''
    BEGIN
        SELECT -1 AS code, N'Missing CaptionVN in SY_FmtFldTbl: ' + @MissingCaptions AS msg;
        RETURN;
    END;

    SELECT @InvalidFormats = STUFF((
        SELECT N', ' + f.FieldName + N' (' + ISNULL(f.FormatID, '') + N')'
        FROM dbo.SY_FmtFldTbl f
        WHERE EXISTS (
            SELECT 1
            FROM sys.columns c
            WHERE c.object_id = @ObjectId AND c.name = f.FieldName
        )
          AND (NULLIF(LTRIM(RTRIM(f.FormatID)), '') IS NULL
               OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID))
        ORDER BY f.FieldName
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF ISNULL(@InvalidFormats, '') <> ''
    BEGIN
        SELECT -1 AS code, N'FormatID không hợp lệ: ' + @InvalidFormats AS msg;
        RETURN;
    END;

    IF NULLIF(LTRIM(RTRIM(@PrimaryKey)), '') IS NULL
    BEGIN
        SELECT TOP (1) @PrimaryKey = c.name
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        INNER JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = @ObjectId
          AND i.is_primary_key = 1
        ORDER BY ic.key_ordinal;
    END;

    SELECT
        c.name AS [name],
        f.CaptionVN AS [label],
        f.CaptionEN AS [labelEN],
        f.CaptionCH AS [labelCH],
        f.FormatID AS [formatId],
        f.FormatID AS [renderRule],
        f.AlignX AS [align],
        f.MinWidth AS [minWidth],
        f.MaxWidth AS [maxWidth],
        CASE
            WHEN NULLIF(LTRIM(RTRIM(@EditorColumnArr)), '') IS NULL THEN c.column_id
            ELSE COALESCE(
                NULLIF(CHARINDEX(';' + c.name + ';', ';' + @EditorColumnArr + ';'), 0),
                100000 + c.column_id
            )
        END AS [orderNo],
        '6' AS [position],
        CASE
            WHEN @RequiredObjectId <> @ObjectId AND requiredColumn.column_id IS NULL THEN 0
            WHEN ISNULL(requiredColumn.is_nullable, c.is_nullable) = 0
             AND ISNULL(requiredColumn.is_identity, c.is_identity) = 0
             AND ISNULL(requiredColumn.is_computed, c.is_computed) = 0
             AND ISNULL(requiredColumn.system_type_id, c.system_type_id) <> 189
             AND ISNULL(requiredColumn.default_object_id, c.default_object_id) = 0 THEN 1
            ELSE 0
        END AS [required],
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM STRING_SPLIT(ISNULL(@HideColumnArr, ''), ';') hiddenColumn
                WHERE LTRIM(RTRIM(hiddenColumn.value)) = c.name
            ) THEN 0
            ELSE 1
        END AS [showInGrid],
        CASE
            WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189 THEN 0
            WHEN NULLIF(LTRIM(RTRIM(@AddNewColumnArr)), '') IS NOT NULL
             AND NOT EXISTS (
                 SELECT 1
                 FROM STRING_SPLIT(@AddNewColumnArr, ';') allowedColumn
                 WHERE LTRIM(RTRIM(allowedColumn.value)) = c.name
             ) THEN 0
            ELSE 1
        END AS [showInAdd],
        CASE
            WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189 THEN 0
            WHEN NULLIF(LTRIM(RTRIM(@EditorColumnArr)), '') IS NOT NULL
             AND NOT EXISTS (
                 SELECT 1
                 FROM STRING_SPLIT(@EditorColumnArr, ';') allowedColumn
                 WHERE LTRIM(RTRIM(allowedColumn.value)) = c.name
             ) THEN 0
            ELSE 1
        END AS [showInEdit],
        CASE
            WHEN c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189 THEN 1
            WHEN ISNULL(dd.isLock, 0) = 1 THEN 1
            ELSE 0
        END AS [isReadOnlyAdd],
        CASE
            WHEN c.name = @PrimaryKey OR c.is_identity = 1 OR c.is_computed = 1 OR c.system_type_id = 189 THEN 1
            WHEN ISNULL(dd.isLock, 0) = 1 THEN 1
            ELSE 0
        END AS [isReadOnlyEdit],
        1 AS [showInFilter],
        @PrimaryKey AS [primaryKey],
        t.name AS [dataType],
        fm.FormatName AS [formatName],
        fm.NumberDecimal AS [numberDecimal],
        fm.FormatString AS [formatString],
        fm.MaskString AS [maskString],
        fm.MaxLength AS [maxLength],
        fm.Type AS [formatType],
        fm.Params AS [formatParams],
        ISNULL(@HidePrintBtn, 0) AS [hidePrintBtn],
        fm.Align AS [formatAlign],
        fm.IsComplex AS [isComplex],
        fm.MinValue AS [minValue],
        fm.MaxValue AS [maxValue],
        dd.UserAutoID AS [dropdownId],
        dd.Source AS [dataSource],
        dd.Type AS [dropdownType],
        dd.ValueColumn AS [dropdownValueColumn],
        dd.DisplayColumn AS [dropdownDisplayColumn],
        dd.ColumnArr AS [dropdownColumnArr],
        dd.WidthArr AS [dropdownWidthArr],
        dd.LinkColumn AS [dropdownLinkColumn],
        dd.DisableAddNew AS [dropdownDisableAddNew],
        dd.ParaArr AS [dropdownParaArr],
        dd.ParaRequireArr AS [dropdownParaRequireArr],
        dd.KeepValue AS [dropdownKeepValue],
        dd.SummaryFieldArr AS [dropdownSummaryFieldArr],
        dd.IsMultiSelect AS [dropdownIsMultiSelect],
        dd.IsNotInList AS [dropdownIsNotInList],
        dd.IsDisable AS [dropdownIsDisable],
        dd.ColumnName_Filter AS [dropdownFilterColumn],
        dd.ColumnValue_Filter AS [dropdownFilterValue],
        dd.OnlyValue_Filter AS [dropdownOnlyFilterValue],
        dd.ManualSQLSearch AS [dropdownManualSearch],
        dd.ManualSQLOrderBy AS [dropdownManualOrderBy],
        dd.DefaultValue AS [defaultValue],
        dd.DefaultValueSQL AS [defaultValueSql],
        dd.IsReload AS [dropdownIsReload],
        dd.EditableColumns AS [dropdownEditableColumns],
        dd.Caption AS [dropdownCaption],
        dd.isLock AS [dropdownIsLock],
        dd.isInvisible AS [dropdownIsInvisible],
        dd.isWordWrap AS [dropdownIsWordWrap],
        dd.isMultiValue AS [dropdownIsMultiValue],
        dd.GroupCaption AS [dropdownGroupCaption],
        dd.WordWrapArr AS [dropdownWordWrapArr],
        dd.GroupColumnArr AS [dropdownGroupColumnArr],
        dd.DisplayMember2 AS [dropdownDisplayMember2],
        dd.TreeViewColumn AS [dropdownTreeViewColumn],
        dd.TreeViewColumnParent AS [dropdownTreeViewColumnParent],
        dd.ReloadType AS [dropdownReloadType],
        dd.EditType AS [dropdownEditType],
        dd.TriggerOnOpenForm AS [dropdownTriggerOnOpenForm]
    FROM sys.columns c
    INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
    LEFT JOIN sys.columns requiredColumn
        ON requiredColumn.object_id = @RequiredObjectId
       AND requiredColumn.name = c.name
    INNER JOIN dbo.SY_FmtFldTbl f ON f.FieldName = c.name
    INNER JOIN dbo.SY_FmatTbl fm ON fm.FormatID = f.FormatID
    /* This API describes a table's main editor. Detail-grid metadata is not part
       of this result and is keyed separately by GridName. */
    LEFT JOIN dbo.SY_FrmDrdwTbl dd
      ON dd.FormID = @FormName
     AND NULLIF(LTRIM(RTRIM(dd.GridName)), '') IS NULL
     AND dd.ColumnID = c.name
    WHERE c.object_id = @ObjectId
    ORDER BY
        CASE
            WHEN NULLIF(LTRIM(RTRIM(@EditorColumnArr)), '') IS NULL THEN c.column_id
            ELSE COALESCE(
                NULLIF(CHARINDEX(';' + c.name + ';', ';' + @EditorColumnArr + ';'), 0),
                100000 + c.column_id
            )
        END,
        c.column_id;
END
GO
