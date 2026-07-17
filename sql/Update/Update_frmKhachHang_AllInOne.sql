USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHÁCH HÀNG (v_DanhSachKhachHang) ===';
GO

-- Thêm cột IsDeleted vào bảng dmkhachhang nếu chưa có để kích hoạt Soft Delete
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('dmkhachhang') AND name = 'IsDeleted'
)
BEGIN
    ALTER TABLE dmkhachhang ADD IsDeleted BIT NULL;
END
GO
UPDATE dmkhachhang SET IsDeleted = 0 WHERE IsDeleted IS NULL;
GO

-- =========================================================================
-- 1. WA_API
-- =========================================================================
PRINT N'1. Đang đồng bộ WA_API cho v_DanhSachKhachHang...';
GO

DELETE FROM SY_FmtFldTbl WHERE FormName = 'v_DanhSachKhachHang';
GO

DELETE FROM WA_API WHERE List = 'v_DanhSachKhachHang' AND Func IN ('View', 'Save', 'Delete');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachHang',
    'View',
    'API_DanhSachKhachHang',
    '@Keyword=N''{Keyword}'', @Makh=N''{Makh}'', @Tenkh=N''{Tenkh}'', @DTcodau=N''{DTcodau}'', @DienthoaiChung=N''{DienthoaiChung}'', @CCCD=N''{CCCD}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachHang',
    'Save',
    'API_LuuKhachHang',
    '@Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Dienthoai=N''{Dienthoai}'', @Mail=N''{Mail}'', @Diachi=N''{Diachi}'', @Ghichu=N''{Ghichu}'', @CCCD=N''{CCCD}'', @Nguoigd=N''{Nguoigd}'', @UserCreate=N''{User}'', @IsEdit={IsEdit}'
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachHang',
    'Delete',
    'API_XoaDong',
    '@List=N''v_DanhSachKhachHang'', @Ids=N''{Makh}'', @UserName=N''{User}'''
);
GO

-- =========================================================================
-- 2. Đồng bộ cột từ SP → SY_FmtFldTbl
-- =========================================================================
PRINT N'2. Đang đồng bộ SY_FmtFldTbl cho v_DanhSachKhachHang...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'v_DanhSachKhachHang', @ObjectName = 'v_DanhSachKhachHang';
GO

-- =========================================================================
-- 3. Nhãn tiếng Việt có dấu và bố cục giao diện
-- =========================================================================
PRINT N'3. Đang cập nhật nhãn tiếng Việt và bố cục...';
GO

-- Lưới chính & form
UPDATE SY_FmtFldTbl SET CaptionVN = N'Mã khách hàng', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Makh';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Tên khách hàng', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Tenkh';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Tên chú rể', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Tenchure';
UPDATE SY_FmtFldTbl SET CaptionVN = N'SĐT chú rể', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'DTchure';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Tên cô dâu', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Tencodau';
UPDATE SY_FmtFldTbl SET CaptionVN = N'SĐT cô dâu', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'DTcodau';
UPDATE SY_FmtFldTbl SET CaptionVN = N'SĐT đại diện', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Dienthoai';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số CCCD/CMND', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'CCCD';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Người giao dịch', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Nguoigd';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Email', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Mail';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Địa chỉ', FormatID = 't' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Diachi';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Ghi chú', FormatID = 'ta' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'Ghichu';

UPDATE SY_FmtFldTbl SET CaptionVN = N'Số lần tham quan', FormatID = 'n' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'SoLanThamQuan';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số hợp đồng', FormatID = 'n' WHERE FormName = 'v_DanhSachKhachHang' AND FieldName = 'SoHopDong';

-- Cấu hình thuộc tính Khóa chính chỉ đọc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'Makh')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachHang', 'Makh', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isLock = 1 WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'Makh';

-- Ẩn các cột trung gian trên form nhập liệu và lưới
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'DienthoaiChung')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachHang', 'DienthoaiChung', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'DienthoaiChung';

IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'DienThoaiDaiDien')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachHang', 'DienThoaiDaiDien', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'v_DanhSachKhachHang' AND ColumnID = 'DienThoaiDaiDien';
GO

-- =========================================================================
-- 4. Đồng bộ Menu hệ thống
-- =========================================================================
PRINT N'4. Đang đồng bộ Menu hệ thống...';
GO

IF EXISTS (SELECT 1 FROM WA_Menu WHERE FormName = 'v_DanhSachKhachHang' OR URLPara = '#/customers' OR MenuID = 'frmKhachHang')
BEGIN
    UPDATE WA_Menu 
    SET VN = N'Hồ sơ khách hàng', 
        FormName = 'v_DanhSachKhachHang',
        URLPara = '#/customers',
        IconClass = 'person'
    WHERE FormName = 'v_DanhSachKhachHang' OR URLPara = '#/customers' OR MenuID = 'frmKhachHang';
END
ELSE
BEGIN
    INSERT INTO WA_Menu (MenuID, Parent, VN, FormName, URLPara, IconClass, isDisable) 
    VALUES ('frmKhachHang', '', N'Hồ sơ khách hàng', 'v_DanhSachKhachHang', '#/customers', 'person', 0);
END
GO

PRINT N'=== HOÀN THÀNH MODULE KHÁCH HÀNG ===';
GO
