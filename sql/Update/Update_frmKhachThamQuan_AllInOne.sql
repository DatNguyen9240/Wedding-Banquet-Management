USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHÁCH THAM QUAN (v_DanhSachKhachThamQuan) ===';
GO

-- =========================================================================
-- 1. Tạo/Cập nhật API_XoaKhachDen...
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
-- 2. WA_API
-- =========================================================================
PRINT N'2. Đang đồng bộ WA_API cho v_DanhSachKhachThamQuan...';
GO

DELETE FROM SY_FmtFldTbl WHERE FormName = 'v_DanhSachKhachThamQuan';
GO

DELETE FROM WA_API WHERE List = 'v_DanhSachKhachThamQuan' AND Func IN ('View', 'Save', 'Delete');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachThamQuan',
    'View',
    'API_DanhSachKhachDen',
    '@Keyword=N''{Keyword}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachThamQuan',
    'Save',
    'API_LuuKhachDen',
    '@DocumentID=N''{DocumentID}'', @Makh=N''{Makh}'', @Tenkh=N''{TenKhachHang}'', @Dienthoai=N''{DienThoai}'', @Ngaytochuc=N''{NgayDuKien}'', @Nhamngay=N''{NgayAmLich}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanMan={SobanMan}, @SobanChay={SobanChay}, @Ghichu=N''{Ghichu}'', @GoiThucDonID=N''{GoiThucDonID}'', @SanhTiec=N''{SanhTiecID}'', @CCCD=N''{CCCD}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'v_DanhSachKhachThamQuan',
    'Delete',
    'API_XoaKhachDen',
    '@Ids=N''{DocumentID}'''
);
GO

-- =========================================================================
-- 3. Đồng bộ cột từ View → SY_FmtFldTbl
-- =========================================================================
PRINT N'3. Đang đồng bộ SY_FmtFldTbl cho v_DanhSachKhachThamQuan...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'v_DanhSachKhachThamQuan', @ObjectName = 'v_DanhSachKhachThamQuan';
GO

-- =========================================================================
-- 4. Nhãn tiếng Việt và cấu hình các trường nhập liệu
-- =========================================================================
PRINT N'4. Đang cập nhật nhãn tiếng Việt và kiểu trường...';
GO

-- Cấu hình cột hiển thị LƯỚI GRID & FORM
UPDATE SY_FmtFldTbl SET CaptionVN = N'Mã phiếu', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'MaPhieu';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Mã phiếu', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'DocumentID';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Tên khách hàng', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'TenKhachHang';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Khách hàng', FormatID = 'sl' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'Makh';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số điện thoại', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'DienThoai';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số CCCD/CMND', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'CCCD';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Ngày dự kiến', FormatID = 'dt' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'NgayDuKien';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Nhằm ngày (Âm lịch)', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'NgayAmLich';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Loại hình tiệc', FormatID = 'sr' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'Loaitiecid';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Ca đãi tiệc', FormatID = 'sr' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'Thoigianid';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Gói tiệc', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'GoiTiec';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Gói tiệc ưu đãi', FormatID = 'sr' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'GoiThucDonID';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Sảnh đặt', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'SanhTiec';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Sảnh đặt', FormatID = 'ml' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'SanhTiecID';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số bàn mặn', FormatID = 'n' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'SobanMan';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Số bàn chay', FormatID = 'n' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'SobanChay';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Trạng thái', FormatID = 't' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'TrangThai';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Ghi chú', FormatID = 'ta' WHERE FormName = 'v_DanhSachKhachThamQuan' AND FieldName = 'Ghichu';

-- Cấu hình Khóa chính chỉ đọc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'DocumentID')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'DocumentID', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isLock = 1 WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'DocumentID';

-- Cấu hình Âm lịch chỉ đọc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'NgayAmLich')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isLock) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'NgayAmLich', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isLock = 1 WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'NgayAmLich';

-- Cấu hình Dropdown khách hàng
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Makh')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'Makh', '/api/API_Gateway_Router?List=v_DanhSachKhachHang&Func=View', 'API', 'Makh', 'Tenkh');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=v_DanhSachKhachHang&Func=View',
        Type = 'API',
        ValueColumn = 'Makh',
        DisplayColumn = 'Tenkh'
    WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Makh';

-- Cấu hình Dropdown Loại hình tiệc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Loaitiecid')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'Loaitiecid', '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View | dmLoaihinhtiec', 'API', 'Loaitiecid', 'TenLoaiHinh');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View | dmLoaihinhtiec',
        Type = 'API',
        ValueColumn = 'Loaitiecid',
        DisplayColumn = 'TenLoaiHinh'
    WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Loaitiecid';

-- Cấu hình Dropdown Ca đãi tiệc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Thoigianid')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'Thoigianid', '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', 'API', 'Thoigianid', 'Thoigian');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View',
        Type = 'API',
        ValueColumn = 'Thoigianid',
        DisplayColumn = 'Thoigian'
    WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Thoigianid';

-- Cấu hình Dropdown Gói tiệc
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'GoiThucDonID')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'GoiThucDonID', '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View', 'API', 'GoiThucDonID', 'GoiTiec');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View',
        Type = 'API',
        ValueColumn = 'GoiThucDonID',
        DisplayColumn = 'GoiTiec'
    WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'GoiThucDonID';

-- Cấu hình Dropdown Sảnh đặt
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'SanhTiecID')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'SanhTiecID', '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View | dmSanhtiec', 'API', 'SanhTiecID', 'Tensanhtiec');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View | dmSanhtiec',
        Type = 'API',
        ValueColumn = 'SanhTiecID',
        DisplayColumn = 'Tensanhtiec'
    WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'SanhTiecID';

-- Ẩn các trường kỹ thuật
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Ngaytochuc')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'Ngaytochuc', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'Ngaytochuc';

IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'DocumentDate')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'v_DanhSachKhachThamQuan', 'DocumentDate', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'v_DanhSachKhachThamQuan' AND ColumnID = 'DocumentDate';
GO

-- =========================================================================
-- 5. Đồng bộ Menu hệ thống
-- =========================================================================
PRINT N'5. Đang đồng bộ Menu hệ thống...';
GO

IF EXISTS (SELECT 1 FROM WA_Menu WHERE FormName = 'v_DanhSachKhachThamQuan' OR URLPara = '#/visitor' OR MenuID = 'frmKhachThamQuan')
BEGIN
    UPDATE WA_Menu 
    SET VN = N'Khách tham quan', 
        FormName = 'v_DanhSachKhachThamQuan',
        URLPara = '#/visitor',
        IconClass = 'chat_bubble'
    WHERE FormName = 'v_DanhSachKhachThamQuan' OR URLPara = '#/visitor' OR MenuID = 'frmKhachThamQuan';
END
ELSE
BEGIN
    INSERT INTO WA_Menu (MenuID, Parent, VN, FormName, URLPara, IconClass, isDisable) 
    VALUES ('frmKhachThamQuan', '', N'Khách tham quan', 'v_DanhSachKhachThamQuan', '#/visitor', 'chat_bubble', 0);
END
GO

PRINT N'=== HOÀN THÀNH MODULE KHÁCH THAM QUAN ===';
GO
