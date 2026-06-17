USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHÁCH THAM QUAN (frmKhachThamQuan) ===';
GO

-- =========================================================================
-- 0. KHỞI TẠO CỘT ShowInGrid TRONG BẢNG SY_FormatFields NẾU CHƯA CÓ
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('SY_FormatFields') AND name = 'ShowInGrid')
BEGIN
    PRINT N'Thêm cột ShowInGrid vào bảng SY_FormatFields...';
    ALTER TABLE SY_FormatFields ADD ShowInGrid BIT NULL CONSTRAINT DF_SY_FormatFields_ShowInGrid DEFAULT 1;
    EXEC('UPDATE SY_FormatFields SET ShowInGrid = 1');
END
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
    '@DocumentID=N''{DocumentID}'', @Makh=N''{Makh}'', @Tenkh=N''{TenKhachHang}'', @Dienthoai=N''{DienThoai}'', @Ngaytochuc=N''{NgayDuKien}'', @Nhamngay=N''{NgayAmLich}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanMan={SobanMan}, @SobanChay={SobanChay}, @Ghichu=N''{Ghichu}'', @GoiThucDonID=N''{GoiThucDonID}'', @SanhTiec=N''{SanhTiecID}'', @CCCD=N''{CCCD}'''
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

-- Cấu hình cột hiển thị LƯỚI GRID & FORM

-- Mã Phiếu hiển thị ngoài lưới danh sách (chỉ đọc)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Mã phiếu', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 0, 
    ShowInGrid = 1,
    OrderNo = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'MaPhieu';

-- DocumentID dùng làm trường chứa khóa chính hiển thị ở Form Sửa
UPDATE SY_FormatFields SET 
    CaptionVN = N'Mã phiếu', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 1, 
    IsReadOnlyAdd = 1, 
    IsReadOnlyEdit = 1, 
    ShowInGrid = 0,
    OrderNo = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'DocumentID';

-- Khách Hàng (Tên in ra lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Tên khách hàng', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 0, 
    ShowInGrid = 1,
    OrderNo = 2 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'TenKhachHang';

-- Khách Hàng (Dropdown cho Form chọn/thêm)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Khách hàng', 
    FormatID = 'sl', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachKhachHang&Func=View', 
    FormPosition = '6', 
    OrderNo = 3, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0,
    IsRequired = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'Makh';

-- Số điện thoại (Hiển thị cả lưới và form)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Số điện thoại', 
    FormatID = 't', 
    FormPosition = '6', 
    OrderNo = 4, 
    ShowInAdd = 1, 
    ShowInEdit = 1, 
    ShowInGrid = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'DienThoai';

-- Số CCCD (Hiển thị cả lưới và form)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Số CCCD/CMND', 
    FormatID = 't', 
    FormPosition = '6', 
    OrderNo = 5, 
    ShowInAdd = 1, 
    ShowInEdit = 1, 
    ShowInGrid = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'CCCD';

-- Ô chọn Ngày dự kiến tổ chức
UPDATE SY_FormatFields SET 
    CaptionVN = N'Ngày dự kiến', 
    FormatID = 'dt', 
    FormPosition = '6', 
    OrderNo = 6, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 1,
    validateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View' 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'NgayDuKien';

-- Ô hiển thị âm lịch tự động (chỉ đọc)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Nhằm ngày (Âm lịch)', 
    FormatID = 't', 
    FormPosition = '6', 
    OrderNo = 7, 
    ShowInAdd = 1, 
    ShowInEdit = 1, 
    IsReadOnlyAdd = 1, 
    IsReadOnlyEdit = 1,
    ShowInGrid = 1 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'NgayAmLich';

-- Gắn Combobox Loại hình tiệc (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Loại hình tiệc', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View', 
    FormPosition = '6', 
    OrderNo = 8, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'Loaitiecid';

-- Gắn Combobox Ca đãi tiệc (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Ca đãi tiệc', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', 
    FormPosition = '6', 
    OrderNo = 9, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'Thoigianid';

-- Gói tiệc (Tên in ra lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Gói tiệc', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 0, 
    ShowInGrid = 1,
    OrderNo = 10 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'GoiTiec';

-- Gắn Combobox Gói tiệc (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Gói tiệc ưu đãi', 
    FormatID = 'sr', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View', 
    FormPosition = '6', 
    OrderNo = 11, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'GoiThucDonID';

-- Sảnh đặt (Tên in ra lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Sảnh đặt', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 0, 
    ShowInGrid = 1,
    OrderNo = 12 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'SanhTiec';

-- Gắn Combobox Sảnh đặt tiệc (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Sảnh đặt', 
    FormatID = 'sl', 
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View', 
    FormPosition = '6', 
    OrderNo = 13, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'SanhTiecID';

-- Số bàn mặn (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Số bàn mặn', 
    FormatID = 'n', 
    FormPosition = '6', 
    OrderNo = 14, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'SobanMan';

-- Số bàn chay (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Số bàn chay', 
    FormatID = 'n', 
    FormPosition = '6', 
    OrderNo = 15, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'SobanChay';

-- Trạng thái (Hiện lưới, ẩn form)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Trạng thái', 
    FormatID = 't', 
    FormPosition = '6', 
    ShowInAdd = 0, 
    ShowInEdit = 0, 
    ShowInGrid = 1,
    OrderNo = 16 
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'TrangThai';

-- Ghi chú (Chỉ hiện form, ẩn lưới)
UPDATE SY_FormatFields SET 
    CaptionVN = N'Ghi chú', 
    FormatID = 'ta', 
    FormPosition = '12', 
    OrderNo = 17, 
    ShowInAdd = 1, 
    ShowInEdit = 1,
    ShowInGrid = 0
WHERE FormName = 'frmKhachThamQuan' AND FieldName = 'Ghichu';

-- Các trường ẩn hoàn toàn không hiện ở đâu cả
UPDATE SY_FormatFields SET FormPosition = 'hidden', ShowInAdd = 0, ShowInEdit = 0, ShowInGrid = 0 WHERE FormName = 'frmKhachThamQuan' AND FieldName IN ('Ngaytochuc', 'DocumentDate');
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
