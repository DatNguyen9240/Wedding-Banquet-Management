USE [QLTiec];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/*
  =============================================================================
  CẤU HÌNH Ô ÂM LỊCH (Nhamngay / NgayAmLich):
  1. Chuyển FormatID thành 'D' (Định dạng Calendar/Date picker)
  2. Bật isLock = 1 trong SY_FrmDrdwTbl để Disable (khóa không cho nhập tay)
  3. Cập nhật EditorColumnArr trong SY_FrmLstTbl để xếp [Ngaytochuc] & [Nhamngay] nằm sát bên cạnh nhau
  =============================================================================
*/

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. ĐỊNH DẠNG CALENDAR (FormatID = 'D') CHO TỪ ĐIỂN CỘT
    UPDATE dbo.SY_FmtFldTbl
    SET FormatID = 'D',
        CaptionVN = N'Nhằm ngày AL'
    WHERE FieldName IN ('Nhamngay', 'NgayAmLich');

    -- 2. DISABLE Ô ÂM LỊCH (isLock = 1) TRONG CẤU HÌNH DROPDOWN/FIELD UI
    -- Dành cho Form Biên nhận cọc (v_DanhSachPhieuCoc & frmBiennhancoccho)
    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachPhieuCoc' AND ColumnID = 'Nhamngay')
    BEGIN
        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock)
        VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachPhieuCoc', 'Nhamngay', 1);
    END
    ELSE
    BEGIN
        UPDATE dbo.SY_FrmDrdwTbl
        SET isLock = 1
        WHERE FormID = 'v_DanhSachPhieuCoc' AND ColumnID = 'Nhamngay';
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'frmBiennhancoccho' AND ColumnID = 'Nhamngay')
    BEGIN
        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock)
        VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmBiennhancoccho', 'Nhamngay', 1);
    END
    ELSE
    BEGIN
        UPDATE dbo.SY_FrmDrdwTbl
        SET isLock = 1
        WHERE FormID = 'frmBiennhancoccho' AND ColumnID = 'Nhamngay';
    END;

    -- Dành cho Form Hợp đồng (v_DanhSachHopDong & frmHopDong) nếu có NgayAmLich
    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachHopDong' AND ColumnID = 'NgayAmLich')
    BEGIN
        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock)
        VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachHopDong', 'NgayAmLich', 1);
    END
    ELSE
    BEGIN
        UPDATE dbo.SY_FrmDrdwTbl
        SET isLock = 1
        WHERE FormID = 'v_DanhSachHopDong' AND ColumnID = 'NgayAmLich';
    END;

    -- 3. ĐẶT VỊ TRÍ [Ngaytochuc] VÀ [Nhamngay] NẰM CẠNH NHAU TRÊN NGUYÊN HÀNG FORM
    -- Cấu hình thứ tự hiển thị cột EditorColumnArr / AddNewColumnArr trong SY_FrmLstTbl
    UPDATE dbo.SY_FrmLstTbl
    SET EditorColumnArr = 'MaChungTu;Makh;SoPhieu;Thoigianid;LoaiTiecID;Ngaytochuc;Nhamngay;SobanManchinhthuc;SobanChaychinhthuc;SobanManduphong;SobanChayduphong;Ghichu;Solan;HinhThuc;TaiKhoanNo;TaiKhoanCo;',
        AddNewColumnArr = 'MaChungTu;Makh;SoPhieu;Thoigianid;LoaiTiecID;Ngaytochuc;Nhamngay;SobanManchinhthuc;SobanChaychinhthuc;SobanManduphong;SobanChayduphong;Ghichu;Solan;HinhThuc;TaiKhoanNo;TaiKhoanCo;'
    WHERE FormID IN ('v_DanhSachPhieuCoc', 'frmBiennhancoccho') OR TableName = 'v_DanhSachPhieuCoc';

    COMMIT TRANSACTION;
    PRINT N'Cấu hình ô âm lịch thành công: Calendar format, Disable input, Nằm bên cạnh Ngaytochuc.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
