USE [QLTiec]
GO

/*
  Read-only classification for invalid global dictionary rows.

  SY_FmtFldTbl is global by FieldName, so this report does not use FormName to
  infer a type. It shows whether each field is backed by one or more physical
  columns, is only a custom UI/dropdown field, or is no longer referenced.
*/
;WITH InvalidField AS (
    SELECT
        f.AutoID,
        f.FieldName,
        f.CaptionVN,
        f.FormatID
    FROM dbo.SY_FmtFldTbl f
    WHERE NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(f.FormatID)), '') IS NULL
       OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID)
), PhysicalUse AS (
    SELECT
        i.AutoID,
        COUNT(DISTINCT c.object_id) AS PhysicalObjectCount,
        COUNT(DISTINCT t.name) AS SqlTypeCount
    FROM InvalidField i
    LEFT JOIN sys.columns c ON c.name = i.FieldName
    LEFT JOIN sys.types t ON t.user_type_id = c.user_type_id
    GROUP BY i.AutoID
), DropdownUse AS (
    SELECT
        i.AutoID,
        COUNT(*) AS DropdownReferenceCount
    FROM InvalidField i
    LEFT JOIN dbo.SY_FrmDrdwTbl dd ON dd.ColumnID = i.FieldName
    GROUP BY i.AutoID
)
SELECT
    i.AutoID,
    i.FieldName,
    i.CaptionVN,
    i.FormatID,
    p.PhysicalObjectCount,
    p.SqlTypeCount,
    d.DropdownReferenceCount,
    CASE
        WHEN p.PhysicalObjectCount = 0 AND d.DropdownReferenceCount = 0 THEN 'ORPHAN: no database or UI reference'
        WHEN p.PhysicalObjectCount = 0 THEN 'UI ONLY: choose an explicit format from business meaning'
        WHEN p.SqlTypeCount > 1 THEN 'CONFLICT: same FieldName has multiple SQL types; resolve explicitly'
        ELSE 'PHYSICAL: assign an explicit FormatID after reviewing the column meaning'
    END AS Resolution
FROM InvalidField i
INNER JOIN PhysicalUse p ON p.AutoID = i.AutoID
INNER JOIN DropdownUse d ON d.AutoID = i.AutoID
ORDER BY Resolution, i.FieldName, i.AutoID;
GO
