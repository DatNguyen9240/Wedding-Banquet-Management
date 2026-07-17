USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHUYẾN MÃI (frmKhuyenMai) ===';
GO

-- =========================================================================
-- 1. WA_API
-- =========================================================================
PRINT N'1. Đang đồng bộ WA_API...';
GO

DELETE FROM WA_API WHERE List = 'frmKhuyenMai' AND Func IN ('View', 'Save', 'Delete');
GO

-- Nạp cấu hình CRUD
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmKhuyenMai', 'View', 'API_DanhSachKhuyenMai', '@Keyword=N''{Keyword}'''),
('frmKhuyenMai', 'Save', 'API_LuuDong', '@List=N''frmKhuyenMai'', @Data=N''{JsonData}'''),
('frmKhuyenMai', 'Delete', 'API_XoaDong', '@List=N''frmKhuyenMai'', @Ids=N''{DocumentID}'', @UserName=N''{User}''');

-- Cập nhật Menu URLPara
UPDATE WA_Menu SET FormName = 'frmKhuyenMai', URLPara = '#/khuyenmai' WHERE URLPara = 'khuyenmai' OR URLPara = '#/khuyenmai';
GO

-- =========================================================================
-- 2. Đồng bộ giao diện (Cột vật lý -> Tiếng Việt)
-- =========================================================================
PRINT N'2. Đang đồng bộ SY_FmtFldTbl...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmKhuyenMai', @ObjectName = 'API_DanhSachKhuyenMai';
GO

-- Gán Label có dấu (CaptionVN)
UPDATE SY_FmtFldTbl SET CaptionVN = N'Mã ưu đãi' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'DocumentID';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Tên ưu đãi' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tenuudai';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Loại hình tiệc', FormatID = 'sl' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Loaitiecid';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Từ ngày', FormatID = 'dt' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tungay';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Đến ngày', FormatID = 'dt' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Denngay';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Từ số bàn', FormatID = 'n' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tusoluongban';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Đến số bàn', FormatID = 'n' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Densoluongban';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Áp dụng số bàn' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'ApDungSoBan';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Đã kết thúc', FormatID = 'sw' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'IsKetthuc';
UPDATE SY_FmtFldTbl SET CaptionVN = N'Ghi chú', FormatID = 'ta' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Ghichu';

-- Cấu hình dropdown Loaitiecid trong SY_FrmDrdwTbl
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'Loaitiecid')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmKhuyenMai', 'Loaitiecid', '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View | dmLoaihinhtiec', 'API', 'Loaitiecid', 'TenLoaiHinh');
ELSE
    UPDATE SY_FrmDrdwTbl 
    SET Source = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View | dmLoaihinhtiec',
        Type = 'API',
        ValueColumn = 'Loaitiecid',
        DisplayColumn = 'TenLoaiHinh'
    WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'Loaitiecid';

-- Ẩn các cột hệ thống hoặc không dùng trong form
IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'ApDungSoBan')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmKhuyenMai', 'ApDungSoBan', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'ApDungSoBan';

IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'Id')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmKhuyenMai', 'Id', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'Id';

IF NOT EXISTS (SELECT 1 FROM SY_FrmDrdwTbl WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'DateCreate')
    INSERT INTO SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible) VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), 'frmKhuyenMai', 'DateCreate', 1);
ELSE
    UPDATE SY_FrmDrdwTbl SET isInvisible = 1 WHERE FormID = 'frmKhuyenMai' AND ColumnID = 'DateCreate';
GO

PRINT N'=== HOÀN THÀNH ===';
GO
