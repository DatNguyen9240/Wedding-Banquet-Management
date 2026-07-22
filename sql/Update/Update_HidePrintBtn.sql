USE [QLTiec]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Add HidePrintBtn column to SY_FrmLstTbl if not exists
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.SY_FrmLstTbl', N'U') AND name = 'HidePrintBtn')
    BEGIN
        ALTER TABLE dbo.SY_FrmLstTbl ADD HidePrintBtn BIT NULL;
    END

    -- Add isExportDocx column to WA_UserGroupPermisstion if not exists
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.WA_UserGroupPermisstion', N'U') AND name = 'isExportDocx')
    BEGIN
        ALTER TABLE dbo.WA_UserGroupPermisstion ADD isExportDocx BIT NULL;
    END

    COMMIT TRANSACTION;
    PRINT 'Database columns for HidePrintBtn and isExportDocx added successfully.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
