USE [QLTiec]
GO

/*
  Read-only detail for violations of the UI-control key
  (FormID, GridName, ColumnID). Blank GridName is treated as the main form.
*/
;WITH DuplicateKey AS (
    SELECT
        FormID,
        NULLIF(LTRIM(RTRIM(GridName)), '') AS GridName,
        ColumnID,
        COUNT(*) AS DuplicateCount
    FROM dbo.SY_FrmDrdwTbl
    GROUP BY FormID, NULLIF(LTRIM(RTRIM(GridName)), ''), ColumnID
    HAVING COUNT(*) > 1
)
SELECT
    d.FormID,
    d.GridName,
    d.ColumnID,
    d.DuplicateCount,
    dd.UserAutoID,
    dd.Source,
    dd.Type,
    dd.ValueColumn,
    dd.DisplayColumn,
    dd.ColumnArr,
    dd.WidthArr,
    dd.LinkColumn,
    dd.DisableAddNew,
    dd.ParaArr,
    dd.ParaRequireArr,
    dd.KeepValue,
    dd.IsMultiSelect,
    dd.IsNotInList,
    dd.IsDisable,
    dd.isLock,
    dd.isInvisible,
    dd.DefaultValue,
    dd.DefaultValueSQL,
    dd.ManualSQLSearch,
    dd.ManualSQLOrderBy,
    dd.EditType
FROM DuplicateKey d
INNER JOIN dbo.SY_FrmDrdwTbl dd
  ON dd.FormID = d.FormID
 AND ISNULL(NULLIF(LTRIM(RTRIM(dd.GridName)), ''), '') = ISNULL(d.GridName, '')
 AND dd.ColumnID = d.ColumnID
ORDER BY d.FormID, d.GridName, d.ColumnID, dd.UserAutoID;
GO
