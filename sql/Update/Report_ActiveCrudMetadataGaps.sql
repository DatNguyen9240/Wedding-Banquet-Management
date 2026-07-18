USE [QLTiec]
GO

/*
  Exact metadata gaps for menu entries that can use the generic CRUD APIs.
  Only physical user tables are included. Custom form identifiers and legacy
  UI controls are intentionally outside this report.
*/
;WITH GenericMenu AS (
    SELECT DISTINCT m.MenuID, m.FormName, t.object_id
    FROM dbo.WA_Menu m
    INNER JOIN sys.tables t ON t.object_id = OBJECT_ID(m.FormName, 'U')
    WHERE NULLIF(LTRIM(RTRIM(m.FormName)), '') IS NOT NULL
), DictionaryRow AS (
    SELECT
        g.MenuID,
        g.FormName AS TableName,
        c.column_id,
        c.name AS FieldName,
        f.AutoID,
        f.CaptionVN,
        f.FormatID,
        CASE WHEN fm.FormatID IS NULL THEN 0 ELSE 1 END AS HasValidFormat,
        fieldDictionary.DictionaryRowCount
    FROM GenericMenu g
    INNER JOIN sys.columns c ON c.object_id = g.object_id
    LEFT JOIN dbo.SY_FmtFldTbl f ON f.FieldName = c.name
    LEFT JOIN dbo.SY_FmatTbl fm ON fm.FormatID = f.FormatID
    OUTER APPLY (
        SELECT COUNT(*) AS DictionaryRowCount
        FROM dbo.SY_FmtFldTbl dictionaryCount
        WHERE dictionaryCount.FieldName = c.name
    ) fieldDictionary
)
SELECT
    MenuID,
    TableName,
    FieldName,
    CaptionVN,
    FormatID,
    CASE
        WHEN AutoID IS NULL THEN 'Missing SY_FmtFldTbl row'
        WHEN DictionaryRowCount <> 1 THEN 'Duplicate SY_FmtFldTbl FieldName'
        WHEN NULLIF(LTRIM(RTRIM(CaptionVN)), '') IS NULL THEN 'Missing CaptionVN'
        WHEN HasValidFormat = 0 THEN 'Missing or unknown FormatID'
    END AS ValidationError
FROM DictionaryRow
WHERE AutoID IS NULL
   OR DictionaryRowCount <> 1
   OR NULLIF(LTRIM(RTRIM(CaptionVN)), '') IS NULL
   OR HasValidFormat = 0
ORDER BY TableName, column_id;
GO
