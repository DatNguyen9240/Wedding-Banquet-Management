USE [QLTiec]
GO

/*
  Resolve the four verified duplicate UI controls from
  Report_DropdownDuplicateKeys.sql.

  LichTrucMCFrm deliberately keeps tbmk_BiennhancocchoView (all event types),
  because the form is currently unused and has no wedding/conference rule.
*/
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Remove TABLE (
        UserAutoID VARCHAR(50) NOT NULL PRIMARY KEY,
        FormID VARCHAR(50) NOT NULL,
        ColumnID VARCHAR(50) NOT NULL
    );

    INSERT INTO @Remove (UserAutoID, FormID, ColumnID)
    VALUES
        ('0CC6E60F-C78B-4681-BD3B-11E11330B0B7', 'HopdongdattiecViewFrm', 'Sobiennhan'),
        ('4D376DEA-49FF-470B-B529-40A6AA21D3CF', 'HopdongHoiNghiFrm', 'Sobiennhan'),
        ('EA00AF60-14DD-400E-B6DD-D25FFC4BE523', 'HopdongHoiNghiViewFrm', 'Sobiennhan'),
        ('99B1D8B8-F217-4468-9B16-5908B84E4D85', 'LichTrucMCFrm', 'Sobiennhan');

    IF (
        SELECT COUNT(*)
        FROM dbo.SY_FrmDrdwTbl dd
        INNER JOIN @Remove r ON r.UserAutoID = dd.UserAutoID
                             AND r.FormID = dd.FormID
                             AND r.ColumnID = dd.ColumnID
    ) <> 4
        THROW 51042, 'One or more reviewed duplicate dropdown rows no longer match; no row was deleted.', 1;

    DELETE dd
    FROM dbo.SY_FrmDrdwTbl dd
    INNER JOIN @Remove r ON r.UserAutoID = dd.UserAutoID
                         AND r.FormID = dd.FormID
                         AND r.ColumnID = dd.ColumnID;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
