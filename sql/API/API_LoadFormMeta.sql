USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  =============================================================================
  CANONICAL METADATA CONTRACT & FORM RESOLVER
  =============================================================================
  SY_FrmLstTbl  : Ánh xạ FormID (logic) <--> TableName/ViewName (vật lý), PrimaryKey, HideColumnArr...
  SY_FmtFldTbl  : Từ điển cột toàn cục (FieldName, Caption*, FormatID, alignment, widths)
  SY_FmatTbl    : Định nghĩa định dạng dữ liệu (FormatID, masks, ranges, precision)
  SY_FrmDrdwTbl : Hành vi UI Dropdown, LinkColumn, Trigger (FormID + GridName + ColumnID)

  Cơ chế phân giải (Resolver):
  - @FormName nhận vào có thể là FormID logic (VD: 'frmKhachThamQuan', '0530', 'frmBaoGia')
    hoặc Tên Table/View vật lý (VD: 'v_DanhSachKhachThamQuan', 'v_DanhSachBaoGia').
  - Hệ thống tự động tra cứu SY_FrmLstTbl để xác định đúng Table/View cần đọc cấu trúc cột,
    đồng thời lấy cấu hình Dropdown/Trigger từ SY_FrmDrdwTbl theo FormID chuẩn.
  =============================================================================
*/
CREATE OR ALTER PROCEDURE dbo.API_LoadFormMeta
    @FormName SYSNAME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ResolvedTableName SYSNAME = NULL;
    DECLARE @ResolvedFormID SYSNAME = NULL;
    DECLARE @ObjectId INT = NULL;
    DECLARE @PrimaryKey VARCHAR(100) = '';
    DECLARE @MissingFields NVARCHAR(MAX) = '';
    DECLARE @DuplicateFields NVARCHAR(MAX) = '';
    DECLARE @MissingCaptions NVARCHAR(MAX) = '';
    DECLARE @InvalidFormats NVARCHAR(MAX) = '';
    DECLARE @HideColumnArr VARCHAR(MAX) = '';
    DECLARE @AddNewColumnArr VARCHAR(MAX) = '';
    DECLARE @EditorColumnArr VARCHAR(MAX) = '';
    DECLARE @RequiredObjectId INT = NULL;
    DECLARE @HidePrintBtn BIT = 0;

    IF OBJECT_ID('dbo.SY_FmtFldTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FmatTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FrmDrdwTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FrmLstTbl', 'U') IS NULL
    BEGIN
        SELECT -1 AS code, N'Thiếu bảng metadata chuẩn SY_FmtFldTbl, SY_FmatTbl, SY_FrmDrdwTbl hoặc SY_FrmLstTbl.' AS msg;
        RETURN;
    END;

    -- 1. BƯỚC 1: TRA CỨU ÁNH XẠ FORM TỪ BẢNG SY_FrmLstTbl
    SELECT TOP (1)
        @ResolvedFormID = formConfig.FormID,
        @ResolvedTableName = NULLIF(LTRIM(RTRIM(formConfig.TableName)), ''),
        @HideColumnArr = ISNULL(formConfig.HideColumnArr, ''),
        @AddNewColumnArr = ISNULL(formConfig.AddNewColumnArr, ''),
        @EditorColumnArr = ISNULL(formConfig.EditorColumnArr, ''),
        @PrimaryKey = NULLIF(LTRIM(RTRIM(formConfig.PrimaryKey)), ''),
        @HidePrintBtn = ISNULL(formConfig.HidePrintBtn, 0)
    FROM dbo.SY_FrmLstTbl formConfig
    WHERE formConfig.FormID = @FormName
       OR formConfig.TableName = @FormName
    ORDER BY CASE WHEN formConfig.FormID = @FormName THEN 0 ELSE 1 END;

    -- 2. BƯỚC 2: XÁC ĐỊNH OBJECT_ID CHO BẢNG/VIEW
    IF @ResolvedTableName IS NOT NULL
    BEGIN
        SET @ObjectId = OBJECT_ID(@ResolvedTableName);
    END;

    -- Fallback: Nếu không thấy trong SY_FrmLstTbl hoặc ObjectId vẫn NULL, thử trực tiếp OBJECT_ID(@FormName)
    IF @ObjectId IS NULL
    BEGIN
        SET @ObjectId = OBJECT_ID(@FormName);
        IF @ObjectId IS NOT NULL
        BEGIN
            SET @ResolvedTableName = @FormName;
            IF @ResolvedFormID IS NULL SET @ResolvedFormID = @FormName;
        END;
    END;

    IF @ObjectId IS NULL
    BEGIN
        SELECT -1 AS code, N'Không tìm thấy Bảng, View hoặc Cấu hình Form trong SY_FrmLstTbl: ' + ISNULL(@FormName, '') AS msg;
        RETURN;
    END;

    SET @RequiredObjectId = @ObjectId;

    -- Đọc nullability thật từ bảng gốc nếu view là read-model (VD: Hopdong)
    IF @ResolvedTableName = 'v_DanhSachHopDong' OR @FormName = 'v_DanhSachHopDong'
    BEGIN
        IF OBJECT_ID(N'dbo.tbmk_Hopdong', N'U') IS NOT NULL
            SET @RequiredObjectId = OBJECT_ID(N'dbo.tbmk_Hopdong', N'U');
    END;

    /* FieldName là toàn cục. Kiểm tra xem có bị trùng lặp FieldName trong SY_FmtFldTbl không */
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

    /* Kiểm tra các cột trong Table/View chưa được khai báo từ điển */
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

    /* Kiểm tra các cột thiếu CaptionVN */
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

    /* Kiểm tra FormatID không hợp lệ */
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
        SELECT -1 AS code, N'Sai FormatID trong SY_FmtFldTbl: ' + @InvalidFormats AS msg;
        RETURN;
    END;

    -- Tự động tìm PrimaryKey nếu chưa khai báo
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

    -- 3. BƯỚC 3: TRẢ VỀ METADATA SCHEMA ĐẦY ĐỦ CHO FRONTEND
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
    -- Khớp Dropdown ưu tiên: FormID chuẩn > Tên được truyền vào (@FormName) > Tên Table/View
    OUTER APPLY (
        SELECT TOP (1) d.*
        FROM dbo.SY_FrmDrdwTbl d
        WHERE (d.FormID = @ResolvedFormID OR d.FormID = @FormName OR d.FormID = @ResolvedTableName)
          AND NULLIF(LTRIM(RTRIM(d.GridName)), '') IS NULL
          AND d.ColumnID = c.name
        ORDER BY
            CASE
                WHEN d.FormID = @ResolvedFormID THEN 0
                WHEN d.FormID = @FormName THEN 1
                ELSE 2
            END
    ) dd
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
