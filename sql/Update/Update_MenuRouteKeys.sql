USE [QLTiec]
GO

SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0510')
       OR NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0520')
       OR NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0530')
       OR NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0540')
        THROW 51070, 'Required customer, quote, visitor, or contract menu records are missing.', 1;

    -- FormKey is a database registry key; FormName is always the physical read object.
    UPDATE dbo.WA_Menu SET FormName = 'dmkhachhang', FormKey = '0510' WHERE MenuID = '0510';
    UPDATE dbo.WA_Menu SET FormName = 'v_DanhSachBaoGia', FormKey = '0520' WHERE MenuID = '0520';
    UPDATE dbo.WA_Menu SET FormName = 'v_DanhSachKhachThamQuan', FormKey = '0530' WHERE MenuID = '0530';
    UPDATE dbo.WA_Menu SET FormName = 'v_DanhSachHopDong', FormKey = '0540' WHERE MenuID = '0540';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
