USE [QLTiec]
GO

/*
  SY_FrmLstTbl is the existing dynamic-form registry.
  This migration deliberately does not seed or overwrite form rows: the
  values in that table are the database source of truth.
*/
SET XACT_ABORT ON
GO

IF OBJECT_ID(N'dbo.SY_FrmLstTbl', N'U') IS NULL
    THROW 51100, 'SY_FrmLstTbl is required as the dynamic form registry.', 1;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.SY_FormTbl', N'U') IS NOT NULL
        DROP TABLE dbo.SY_FormTbl;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
