USE [QLTiec]
GO

/*
  The /customers route uses DynamicFormEngine and therefore must point to a
  physical table. frmKhachHang is a legacy UI alias; dmkhachhang is the
  customer CRUD table. The reporting view v_DanhSachKhachHang remains for
  specialised reports only.
*/
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.dmkhachhang', N'U') IS NULL
        THROW 51050, 'The customer CRUD table dbo.dmkhachhang does not exist.', 1;

    IF (
        SELECT COUNT(*)
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic
          ON ic.object_id = i.object_id
         AND ic.index_id = i.index_id
        WHERE i.object_id = OBJECT_ID(N'dbo.dmkhachhang', N'U')
          AND i.is_primary_key = 1
    ) <> 1
        THROW 51051, 'dbo.dmkhachhang requires exactly one primary-key column for generic CRUD.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0510')
        THROW 51052, 'WA_Menu entry 0510 (customers) does not exist.', 1;

    UPDATE dbo.WA_Menu
    SET FormName = 'dmkhachhang'
    WHERE MenuID = '0510';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
