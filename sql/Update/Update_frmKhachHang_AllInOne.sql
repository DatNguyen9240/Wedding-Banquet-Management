USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHÁCH HÀNG (frmKhachHang) ===';
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
-- 1. SY_FrmLstTbl + WA_API
-- =========================================================================
PRINT N'1. Đang đồng bộ SY_FrmLstTbl và WA_API cho frmKhachHang...';
GO

DELETE FROM SY_FormatFields WHERE FormName = 'frmKhachHang';
DELETE FROM SY_FrmLstTbl WHERE FormID = 'frmKhachHang';
GO

INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
VALUES ('frmKhachHang', N'Hồ sơ khách hàng', 'API_DanhSachKhachHang', 'dmkhachhang', 'Makh');
GO

DELETE FROM WA_API WHERE List = 'frmKhachHang' AND Func IN ('View', 'Save', 'Delete');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachHang',
    'View',
    'API_DanhSachKhachHang',
    '@Keyword=N''{Keyword}'', @Makh=N''{Makh}'', @Tenkh=N''{Tenkh}'', @DTcodau=N''{DTcodau}'', @DienthoaiChung=N''{DienthoaiChung}'', @CCCD=N''{CCCD}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachHang',
    'Save',
    'API_LuuKhachHang',
    '@Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Dienthoai=N''{Dienthoai}'', @Mail=N''{Mail}'', @Diachi=N''{Diachi}'', @Ghichu=N''{Ghichu}'', @CCCD=N''{CCCD}'', @Nguoigd=N''{Nguoigd}'', @UserCreate=N''{User}'', @IsEdit={IsEdit}'
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachHang',
    'Delete',
    'API_XoaDong',
    '@List=N''frmKhachHang'', @Ids=N''{Makh}'', @UserName=N''{User}'''
);
GO

-- =========================================================================
-- 2. Đồng bộ cột từ SP → SY_FormatFields
-- =========================================================================
PRINT N'2. Đang đồng bộ SY_FormatFields cho frmKhachHang...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmKhachHang', @ObjectName = 'API_DanhSachKhachHang';
GO

-- =========================================================================
-- 3. Nhãn tiếng Việt có dấu và bố cục giao diện
-- =========================================================================
PRINT N'3. Đang cập nhật nhãn tiếng Việt và bố cục...';
GO

-- Lưới chính & form
UPDATE SY_FormatFields SET CaptionVN = N'Mã khách hàng', FormatID = 't', FormPosition = '6', ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, OrderNo = 1 WHERE FormName = 'frmKhachHang' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng', FormatID = 't', FormPosition = '6', ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 1, OrderNo = 2 WHERE FormName = 'frmKhachHang' AND FieldName = 'Tenkh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 3 WHERE FormName = 'frmKhachHang' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT chú rể', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 4 WHERE FormName = 'frmKhachHang' AND FieldName = 'DTchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 5 WHERE FormName = 'frmKhachHang' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT cô dâu', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 6 WHERE FormName = 'frmKhachHang' AND FieldName = 'DTcodau';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT đại diện', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 7 WHERE FormName = 'frmKhachHang' AND FieldName = 'Dienthoai';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD/CMND', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 8 WHERE FormName = 'frmKhachHang' AND FieldName = 'CCCD';
UPDATE SY_FormatFields SET CaptionVN = N'Người giao dịch', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 10 WHERE FormName = 'frmKhachHang' AND FieldName = 'Nguoigd';
UPDATE SY_FormatFields SET CaptionVN = N'Email', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 11 WHERE FormName = 'frmKhachHang' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ', FormatID = 't', FormPosition = '6', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 12 WHERE FormName = 'frmKhachHang' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú', FormatID = 'ta', FormPosition = '12', ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 13 WHERE FormName = 'frmKhachHang' AND FieldName = 'Ghichu';

UPDATE SY_FormatFields SET CaptionVN = N'Số lần tham quan', FormatID = 'n', FormPosition = '6', ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, IsReadOnlyEdit = 1, OrderNo = 14 WHERE FormName = 'frmKhachHang' AND FieldName = 'SoLanThamQuan';
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng', FormatID = 'n', FormPosition = '6', ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, IsReadOnlyEdit = 1, OrderNo = 15 WHERE FormName = 'frmKhachHang' AND FieldName = 'SoHopDong';

-- Ẩn các cột trung gian trên form nhập liệu
UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, FormPosition = 'hidden' WHERE FormName = 'frmKhachHang' AND FieldName IN ('DienthoaiChung', 'DienThoaiDaiDien');
GO

-- =========================================================================
-- =========================================================================
-- 4. Đồng bộ Menu hệ thống
-- =========================================================================
PRINT N'4. Đang đồng bộ Menu hệ thống...';
GO

IF EXISTS (SELECT 1 FROM WA_Menu WHERE FormName = 'frmKhachHang' OR URLPara = '#/customers' OR MenuID = 'frmKhachHang')
BEGIN
    UPDATE WA_Menu 
    SET VN = N'Hồ sơ khách hàng', 
        FormName = 'frmKhachHang',
        URLPara = '#/customers',
        IconClass = 'person'
    WHERE FormName = 'frmKhachHang' OR URLPara = '#/customers' OR MenuID = 'frmKhachHang';
END
ELSE
BEGIN
    INSERT INTO WA_Menu (MenuID, Parent, VN, FormName, URLPara, IconClass, isDisable) 
    VALUES ('frmKhachHang', '', N'Hồ sơ khách hàng', 'frmKhachHang', '#/customers', 'person', 0);
END
GO

PRINT N'=== HOÀN THÀNH MODULE KHÁCH HÀNG ===';
GO
