USE [QLTiec]
GO

SET XACT_ABORT ON
GO

/*
  Canonical metadata preflight.

  Runtime contract:
    SY_FmtFldTbl.FieldName             one global dictionary row per column name
    SY_FmatTbl.FormatID                one format row per format id
    SY_FrmDrdwTbl.(FormID, GridName, ColumnID)
                                        one optional UI-control behaviour row

  FormID is a UI form identifier. It is deliberately not required to be a
  database object: custom forms and their detail grids use this same table.
*/
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.SY_FmtFldTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FmatTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FrmDrdwTbl', 'U') IS NULL
        THROW 51000, 'Canonical metadata tables are missing.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl
        GROUP BY FieldName
        HAVING COUNT(*) > 1 OR NULLIF(LTRIM(RTRIM(FieldName)), '') IS NULL
    )
        THROW 51001, 'SY_FmtFldTbl requires exactly one non-empty row per FieldName.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmatTbl
        GROUP BY FormatID
        HAVING COUNT(*) > 1 OR NULLIF(LTRIM(RTRIM(FormatID)), '') IS NULL
    )
        THROW 51002, 'SY_FmatTbl requires exactly one non-empty row per FormatID.', 1;

    /*
      The legacy dictionary also contains custom UI-control names. Do not make
      those unrelated rows block index creation. API_LoadFormMeta validates
      CaptionVN and FormatID strictly for every column of the table it opens;
      there is no runtime default or inferred format.
    */

    /* A blank grid means the main form. Canonicalise it before enforcing the key. */
    UPDATE dbo.SY_FrmDrdwTbl
    SET GridName = NULL
    WHERE NULLIF(LTRIM(RTRIM(GridName)), '') IS NULL
      AND GridName IS NOT NULL;

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FrmDrdwTbl
        GROUP BY FormID, GridName, ColumnID
        HAVING COUNT(*) > 1
           OR NULLIF(LTRIM(RTRIM(FormID)), '') IS NULL
           OR NULLIF(LTRIM(RTRIM(ColumnID)), '') IS NULL
    )
        THROW 51004, 'SY_FrmDrdwTbl requires at most one row per non-empty FormID, GridName and ColumnID.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FmtFldTbl') AND name = 'UX_SY_FmtFldTbl_FieldName')
        CREATE UNIQUE INDEX UX_SY_FmtFldTbl_FieldName ON dbo.SY_FmtFldTbl(FieldName);

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FmatTbl') AND name = 'UX_SY_FmatTbl_FormatID')
        CREATE UNIQUE INDEX UX_SY_FmatTbl_FormatID ON dbo.SY_FmatTbl(FormatID);

    /* Retire the former two-part key: it incorrectly merges detail grids. */
    IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FrmDrdwTbl') AND name = 'UX_SY_FrmDrdwTbl_FormID_ColumnID')
        DROP INDEX UX_SY_FrmDrdwTbl_FormID_ColumnID ON dbo.SY_FrmDrdwTbl;

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SY_FrmDrdwTbl') AND name = 'UX_SY_FrmDrdwTbl_FormID_GridName_ColumnID')
        CREATE UNIQUE INDEX UX_SY_FrmDrdwTbl_FormID_GridName_ColumnID ON dbo.SY_FrmDrdwTbl(FormID, GridName, ColumnID);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
