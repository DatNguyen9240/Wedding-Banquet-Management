USE [QLTiec]
GO

/* Read-only audit for the canonical generic CRUD contract. */

;WITH MenuObject AS (
    SELECT
        m.MenuID,
        m.FormName,
        o.object_id,
        o.type AS ObjectType,
        o.type_desc AS ObjectTypeDesc
    FROM dbo.WA_Menu m
    LEFT JOIN sys.objects o ON o.object_id = OBJECT_ID(m.FormName)
    WHERE NULLIF(LTRIM(RTRIM(m.FormName)), '') IS NOT NULL
), PrimaryKeyInfo AS (
    SELECT
        ic.object_id,
        COUNT(*) AS PrimaryKeyColumnCount
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    WHERE i.is_primary_key = 1
    GROUP BY ic.object_id
), MetadataInfo AS (
    SELECT
        mo.object_id,
        COUNT(c.column_id) AS ColumnCount,
        SUM(CASE WHEN f.FieldName IS NULL THEN 1 ELSE 0 END) AS MissingDictionaryFields,
        SUM(CASE WHEN f.FieldName IS NOT NULL AND (NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL OR fm.FormatID IS NULL) THEN 1 ELSE 0 END) AS InvalidDictionaryFields
    FROM (SELECT DISTINCT object_id FROM MenuObject WHERE object_id IS NOT NULL) mo
    LEFT JOIN sys.columns c ON c.object_id = mo.object_id
    LEFT JOIN dbo.SY_FmtFldTbl f ON f.FieldName = c.name
    LEFT JOIN dbo.SY_FmatTbl fm ON fm.FormatID = f.FormatID
    GROUP BY mo.object_id
)
SELECT
    mo.MenuID,
    mo.FormName,
    mo.ObjectTypeDesc,
    ISNULL(pk.PrimaryKeyColumnCount, 0) AS PrimaryKeyColumnCount,
    ISNULL(mi.ColumnCount, 0) AS ColumnCount,
    ISNULL(mi.MissingDictionaryFields, 0) AS MissingDictionaryFields,
    ISNULL(mi.InvalidDictionaryFields, 0) AS InvalidDictionaryFields,
    CASE
        WHEN mo.object_id IS NULL THEN 'BLOCKED: FormName is not a database object'
        WHEN mo.ObjectType <> 'U' THEN 'CUSTOM: view/procedure; do not use generic CRUD'
        WHEN ISNULL(pk.PrimaryKeyColumnCount, 0) <> 1 THEN 'BLOCKED: generic CRUD needs one primary key'
        WHEN ISNULL(mi.MissingDictionaryFields, 0) > 0 THEN 'BLOCKED: add missing SY_FmtFldTbl rows'
        WHEN ISNULL(mi.InvalidDictionaryFields, 0) > 0 THEN 'BLOCKED: fix CaptionVN or FormatID'
        ELSE 'READY: generic CRUD'
    END AS CrudReadiness
FROM MenuObject mo
LEFT JOIN PrimaryKeyInfo pk ON pk.object_id = mo.object_id
LEFT JOIN MetadataInfo mi ON mi.object_id = mo.object_id
ORDER BY CrudReadiness, mo.FormName;
GO

SELECT FieldName, COUNT(*) AS DuplicateCount
FROM dbo.SY_FmtFldTbl
GROUP BY FieldName
HAVING COUNT(*) > 1
ORDER BY FieldName;
GO

SELECT
    FormID,
    NULLIF(LTRIM(RTRIM(GridName)), '') AS GridName,
    ColumnID,
    COUNT(*) AS DuplicateCount
FROM dbo.SY_FrmDrdwTbl
GROUP BY FormID, NULLIF(LTRIM(RTRIM(GridName)), ''), ColumnID
HAVING COUNT(*) > 1
ORDER BY FormID, GridName, ColumnID;
GO

SELECT
    f.AutoID,
    f.FormName,
    f.FieldName,
    f.CaptionVN,
    f.CaptionEN,
    f.CaptionCH,
    f.FormatID,
    f.AlignX,
    f.MinWidth,
    f.MaxWidth
FROM dbo.SY_FmtFldTbl f
WHERE EXISTS (
    SELECT 1
    FROM dbo.SY_FmtFldTbl d
    WHERE d.FieldName = f.FieldName
    GROUP BY d.FieldName
    HAVING COUNT(*) > 1
)
ORDER BY f.FieldName, f.AutoID;
GO

SELECT
    MenuID,
    Parent,
    VN,
    FormName,
    URLPara,
    isDisable
FROM dbo.WA_Menu
ORDER BY Parent, MenuID;
GO

SELECT
    f.AutoID,
    f.FormName,
    f.FieldName,
    f.CaptionVN,
    f.FormatID,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL THEN 'Missing CaptionVN'
        WHEN NULLIF(LTRIM(RTRIM(f.FormatID)), '') IS NULL THEN 'Missing FormatID'
        WHEN NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID) THEN 'Unknown FormatID'
    END AS ValidationError
FROM dbo.SY_FmtFldTbl f
WHERE NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL
   OR NULLIF(LTRIM(RTRIM(f.FormatID)), '') IS NULL
   OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID)
ORDER BY f.FieldName, f.AutoID;
GO

SELECT
    dd.UserAutoID,
    dd.FormID,
    dd.GridName,
    dd.ColumnID,
    dd.Source,
    dd.Type,
    dd.ValueColumn,
    dd.DisplayColumn,
    CASE
        WHEN NULLIF(LTRIM(RTRIM(dd.FormID)), '') IS NULL THEN 'Missing FormID'
        WHEN NULLIF(LTRIM(RTRIM(dd.ColumnID)), '') IS NULL THEN 'Missing ColumnID'
        WHEN EXISTS (
            SELECT 1
            FROM dbo.SY_FrmDrdwTbl duplicateRow
            WHERE duplicateRow.FormID = dd.FormID
              AND ISNULL(NULLIF(LTRIM(RTRIM(duplicateRow.GridName)), ''), '') = ISNULL(NULLIF(LTRIM(RTRIM(dd.GridName)), ''), '')
              AND duplicateRow.ColumnID = dd.ColumnID
            GROUP BY duplicateRow.FormID, NULLIF(LTRIM(RTRIM(duplicateRow.GridName)), ''), duplicateRow.ColumnID
            HAVING COUNT(*) > 1
        ) THEN 'Duplicate FormID + GridName + ColumnID'
    END AS ValidationError
FROM dbo.SY_FrmDrdwTbl dd
WHERE NULLIF(LTRIM(RTRIM(dd.FormID)), '') IS NULL
   OR NULLIF(LTRIM(RTRIM(dd.ColumnID)), '') IS NULL
   OR EXISTS (
       SELECT 1
       FROM dbo.SY_FrmDrdwTbl duplicateRow
       WHERE duplicateRow.FormID = dd.FormID
         AND ISNULL(NULLIF(LTRIM(RTRIM(duplicateRow.GridName)), ''), '') = ISNULL(NULLIF(LTRIM(RTRIM(dd.GridName)), ''), '')
         AND duplicateRow.ColumnID = dd.ColumnID
       GROUP BY duplicateRow.FormID, NULLIF(LTRIM(RTRIM(duplicateRow.GridName)), ''), duplicateRow.ColumnID
       HAVING COUNT(*) > 1
   )
ORDER BY dd.FormID, dd.GridName, dd.ColumnID, dd.UserAutoID;
GO
