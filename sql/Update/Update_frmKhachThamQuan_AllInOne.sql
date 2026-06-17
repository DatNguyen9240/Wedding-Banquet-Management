USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHÁCH THAM QUAN (frmKhachThamQuan) ===';
GO

-- =========================================================================
-- 1. STORED PROCEDURE API_XoaKhachDen (Hỗ trợ xóa cứng cả bảng con sảnh)
-- =========================================================================
PRINT N'1. Tạo/Cập nhật API_XoaKhachDen...';
GO

CREATE OR ALTER PROCEDURE [dbo].[API_XoaKhachDen]
    @Ids NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Xoá bảng con liên kết sảnh
    DELETE FROM tbmk_Khachthamquansanhtiec 
    WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));
    
    -- Xoá bảng chính khách tham quan
    DELETE FROM tbmk_Khachthamquan 
    WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));
    
    SELECT 0 AS [code], N'Xóa thành công' AS [msg];
END
GO

-- =========================================================================
-- 2. SY_FrmLstTbl + WA_API
-- =========================================================================
PRINT N'2. Đang đồng bộ SY_FrmLstTbl và WA_API cho frmKhachThamQuan...';
GO

DELETE FROM SY_FormatFields WHERE FormName = 'frmKhachThamQuan';
DELETE FROM SY_FrmLstTbl WHERE FormID = 'frmKhachThamQuan';
GO

INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
VALUES ('frmKhachThamQuan', N'Khách tham quan', 'v_DanhSachKhachThamQuan', 'tbmk_Khachthamquan', 'DocumentID');
GO

DELETE FROM WA_API WHERE List = 'frmKhachThamQuan' AND Func IN ('View', 'Save', 'Delete');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachThamQuan',
    'View',
    'API_DanhSachKhachDen',
    '@Keyword=N''{Keyword}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachThamQuan',
    'Save',
    'API_LuuKhachDen',
    '@DocumentID=N''{DocumentID}'', @Makh=N''{_TenKhachHang}'', @Tenkh=N''{TenKhachHang}'', @Dienthoai=N''{DienThoai}'', @Ngaytochuc=N''{NgayDuKien}'', @Nhamngay=N''{NgayAmLich}'', @Loaitiecid=N''{_Loaitiecid}'', @Thoigianid=N''{_Thoigianid}'', @SobanMan={_SobanMan}, @SobanChay={_SobanChay}, @Ghichu=N''{_Ghichu}'', @GoiThucDonID=N''{_GoiTiec}'', @SanhTiec=N''{_SanhTiec}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmKhachThamQuan',
    'Delete',
    'API_XoaKhachDen',
    '@Ids=N''{DocumentID}'''
);
GO

-- =========================================================================
-- 3. Đồng bộ cột từ SP/View → SY_FormatFields
-- =========================================================================
PRINT N'3. Đang đồng bộ SY_FormatFields cho frmKhachThamQuan...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmKhachThamQuan', @ObjectName = 'v_DanhSachKhachThamQuan';
GO

-- =========================================================================
-- 4. Nhãn tiếng Việt và cấu hình các trường nhập liệu
-- =========================================================================
PRINT N'4. Đang cập nhật nhãn tiếng Việt và kiểu trường...';
GO

-- Cấu hình hiển thị lưới & form
UPDATE SY_FormatFields SET CaptionVN = N'Mã phiếu', FormatID = 't', FormPosition = '6', ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, OrderNo = 1 WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'DocumentID';
UPDATE SY_FormatFields SET CaptionVN = N'Mã phiếu', FormatID = 't', FormPosition = 'hidden', ShowInAdd = 0, ShowInEdit = 0, OrderNo = 99 WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'MaPhieu';

-- Gắn Combobox Khách Hàng (Tải danh sách khách hàng và cho phép chọn nhanh)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Khách hàng', 
    FormatID = 'sl', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachKhachHang&Func=View', 
    FormPosition = '6', 
    OrderNo = 2, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    IsRequired = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_TenKhachHang';

UPDATE SY_FormatFields SET CaptionVN = N'Số điện thoại', FormatID = 't', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'DienThoai';

-- Ô chọn Ngày dự kiến tổ chức
UPDATE SY_FormatFields SET 
    CaptionVN = N'Ngày dự kiến', 
    FormatID = 'dt', 
    FormPosition = '6', 
    OrderNo = 4, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    validateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View' 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'NgayDuKien';

-- Ô hiển thị âm lịch tự động (chỉ đọc)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Nhằm ngày (Âm lịch)', 
    FormatID = 't', 
    FormPosition = '6', 
    OrderNo = 5, 
    ShowInAdd = 1, 
    ShowInEdit = 1, 
    IsReadOnlyAdd = 1, 
    IsReadOnlyEdit = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'NgayAmLich';

-- Gắn Combobox Loại hình tiệc (Dùng Select Readonly chỉ cho chọn)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Loại hình tiệc', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View', 
    FormPosition = '6', 
    OrderNo = 6, 
    ShowInAdd = 1, 
    ShowInEdit = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_Loaitiecid';

-- Gắn Combobox Ca đãi tiệc (Dùng Select Readonly chỉ cho chọn)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Ca đãi tiệc', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', 
    FormPosition = '6', 
    OrderNo = 7, 
    ShowInAdd = 1, 
    ShowInEdit = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_Thoigianid';

-- Gắn Combobox Gói tiệc (Dùng Select Readonly chỉ cho chọn)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Gói tiệc ưu đãi', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View', 
    FormPosition = '6', 
    OrderNo = 8, 
    ShowInAdd = 1, 
    ShowInEdit = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_GoiTiec';

-- Gắn Combobox Sảnh đặt tiệc
UPDATE SY_FormatFields SET 
    CaptionVN = N'Sảnh đặt', 
    FormatID = 'sl', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View', 
    FormPosition = '6', 
    OrderNo = 9, 
    ShowInAdd = 1, 
    ShowInEdit = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_SanhTiec';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn mặn', FormatID = 'n', FormPosition = '6', OrderNo = 10, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_SobanMan';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chay', FormatID = 'n', FormPosition = '6', OrderNo = 11, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_SobanChay';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú', FormatID = 'ta', FormPosition = '12', OrderNo = 12, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmKhachThamQuan' AND FieldName = '_Ghichu';

-- Cấu hình hiển thị Lưới Grid (Ẩn các cột thừa, chỉ dùng ở form)
UPDATE SY_FormatFields SET FormPosition = 'hidden', ShowInAdd = 0, ShowInEdit = 0 WHERE FormName = 'frmKhachThamQuan' AND FieldName IN ('TenKhachHang', 'GoiTiec', '_Ngaytochuc', '_DocumentDate');
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Gói tiệc' WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'GoiTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt' WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'SanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'TrangThai';
GO

-- =========================================================================
-- 5. Đồng bộ Menu hệ thống
-- =========================================================================
PRINT N'5. Đang đồng bộ Menu hệ thống...';
GO

IF EXISTS (SELECT 1 FROM WA_Menu WHERE FormName = 'frmKhachThamQuan' OR URLPara = '#/visitor' OR MenuID = 'frmKhachThamQuan')
BEGIN
    UPDATE WA_Menu 
    SET VN = N'Khách tham quan', 
        FormName = 'frmKhachThamQuan',
        URLPara = '#/visitor',
        IconClass = 'chat_bubble'
    WHERE FormName = 'frmKhachThamQuan' OR URLPara = '#/visitor' OR MenuID = 'frmKhachThamQuan';
END
ELSE
BEGIN
    INSERT INTO WA_Menu (MenuID, Parent, VN, FormName, URLPara, IconClass, isDisable) 
    VALUES ('frmKhachThamQuan', '', N'Khách tham quan', 'frmKhachThamQuan', '#/visitor', 'chat_bubble', 0);
END
GO

PRINT N'=== HOÀN THÀNH MODULE KHÁCH THAM QUAN ===';
GO


