USE [QLTiec]
GO

SET XACT_ABORT ON
GO

/*
  Canonical metadata preflight.

  Runtime contract:
    SY_FmtFldTbl.FieldName             one global dictionary row per column name
    SY_FmatTbl.FormatID                one format row per format id
    SY_FrmDrdwTbl.(FormID, ColumnID)   one optional form-field behaviour row

  This migration never guesses a caption, FormatID, or lookup source. Resolve
  every reported conflict before running it again.
*/
IF OBJECT_ID('dbo.SY_FmtFldTbl', 'U') IS NULL
   OR OBJECT_ID('dbo.SY_FmatTbl', 'U') IS NULL
   OR OBJECT_ID('dbo.SY_FrmDrdwTbl', 'U') IS NULL
    THROW 51000, 'Canonical metadata tables are missing.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SY_FmtFldTbl
    GROUP BY FieldName
    HAVING COUNT(*) > 1 OR NULLIF(LTRIM(RTRIM(FieldName)), '') IS NULL
)
    THROW 51001, 'SY_FmtFldTbl requires exactly one non-empty row per FieldName.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SY_FmatTbl
    GROUP BY FormatID
    HAVING COUNT(*) > 1 OR NULLIF(LTRIM(RTRIM(FormatID)), '') IS NULL
)
    THROW 51002, 'SY_FmatTbl requires exactly one non-empty row per FormatID.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SY_FmtFldTbl f
    WHERE NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(f.FormatID)), '') IS NULL
       OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID)
)
    THROW 51003, 'Every SY_FmtFldTbl row needs CaptionVN and a valid FormatID.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SY_FrmDrdwTbl
    GROUP BY FormID, ColumnID
    HAVING COUNT(*) > 1
       OR NULLIF(LTRIM(RTRIM(FormID)), '') IS NULL
       OR NULLIF(LTRIM(RTRIM(ColumnID)), '') IS NULL
)
    THROW 51004, 'SY_FrmDrdwTbl requires at most one row per non-empty FormID and ColumnID.', 1;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.SY_FrmDrdwTbl dd
    WHERE OBJECT_ID(dd.FormID) IS NULL
       OR NOT EXISTS (
           SELECT 1
           FROM sys.columns c
           WHERE c.object_id = OBJECT_ID(dd.FormID) AND c.name = dd.ColumnID
       )
)
    THROW 51005, 'Every dropdown configuration must point to an existing object column.', 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FmtFldTbl') AND name = 'UX_SY_FmtFldTbl_FieldName')
    CREATE UNIQUE INDEX UX_SY_FmtFldTbl_FieldName ON dbo.SY_FmtFldTbl(FieldName);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FmatTbl') AND name = 'UX_SY_FmatTbl_FormatID')
    CREATE UNIQUE INDEX UX_SY_FmatTbl_FormatID ON dbo.SY_FmatTbl(FormatID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FrmDrdwTbl') AND name = 'UX_SY_FrmDrdwTbl_FormID_ColumnID')
    CREATE UNIQUE INDEX UX_SY_FrmDrdwTbl_FormID_ColumnID ON dbo.SY_FrmDrdwTbl(FormID, ColumnID);
GO
