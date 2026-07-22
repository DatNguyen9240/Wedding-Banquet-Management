USE [QLTiec]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Cấu hình mẫu dữ liệu cho trường HinhThuc của form frmBiennhancoccho (Biên nhận cọc)
    -- Thiết lập Source là danh sách tĩnh, Type là STATIC và LinkColumn là luật gán tài khoản
    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'frmBiennhancoccho' AND ColumnID = 'HinhThuc')
    BEGIN
        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock, Source, Type, LinkColumn)
        VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmBiennhancoccho', 'HinhThuc', 0, 
                N'Chuyển khoản,Tiền mặt', 'STATIC',
                N'Chuyen khoan:TaiKhoanNo=112,TaiKhoanCo=131|Tien mat:TaiKhoanNo=111,TaiKhoanCo=131');
    END
    ELSE
    BEGIN
        UPDATE dbo.SY_FrmDrdwTbl
        SET Source = N'Chuyển khoản,Tiền mặt',
            Type = 'STATIC',
            LinkColumn = N'Chuyen khoan:TaiKhoanNo=112,TaiKhoanCo=131|Tien mat:TaiKhoanNo=111,TaiKhoanCo=131'
        WHERE FormID = 'frmBiennhancoccho' AND ColumnID = 'HinhThuc';
    END

    -- 2. Cấu hình mẫu dữ liệu cho trường HinhThuc của form v_DanhSachPhieuCoc
    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachPhieuCoc' AND ColumnID = 'HinhThuc')
    BEGIN
        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock, Source, Type, LinkColumn)
        VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachPhieuCoc', 'HinhThuc', 0, 
                N'Chuyển khoản,Tiền mặt', 'STATIC',
                N'Chuyen khoan:TaiKhoanNo=112,TaiKhoanCo=131|Tien mat:TaiKhoanNo=111,TaiKhoanCo=131');
    END
    ELSE
    BEGIN
        UPDATE dbo.SY_FrmDrdwTbl
        SET Source = N'Chuyển khoản,Tiền mặt',
            Type = 'STATIC',
            LinkColumn = N'Chuyen khoan:TaiKhoanNo=112,TaiKhoanCo=131|Tien mat:TaiKhoanNo=111,TaiKhoanCo=131'
        WHERE FormID = 'v_DanhSachPhieuCoc' AND ColumnID = 'HinhThuc';
    END

    COMMIT TRANSACTION;
    PRINT 'HinhThuc dropdown and LinkColumn configured successfully with ASCII keys.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
