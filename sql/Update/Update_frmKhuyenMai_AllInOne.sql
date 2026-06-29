USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE KHUYẾN MÃI (frmKhuyenMai) CHUẨN NO-CODE ===';
GO

-- =========================================================================
-- 1. STORED PROCEDURE API_DanhSachKhuyenMai
-- =========================================================================
PRINT N'1. Đang tạo API_DanhSachKhuyenMai...';
GO

IF OBJECT_ID('API_DanhSachKhuyenMai', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachKhuyenMai;
GO

CREATE PROCEDURE [dbo].[API_DanhSachKhuyenMai]
    @Keyword NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Keyword = '' SET @Keyword = NULL;

    SELECT
        k.DocumentID AS [Id],
        k.DocumentID,
        k.Tenuudai,
        k.Loaitiecid,
        k.Tungay,
        k.Denngay,
        k.Tusoluongban,
        k.Densoluongban,
        k.IsKetthuc,
        k.Ghichu,
        ISNULL(CAST(k.Tusoluongban AS VARCHAR), '0') + ' - ' + ISNULL(CAST(k.Densoluongban AS VARCHAR), 'MAX') AS [ApDungSoBan],
        k.DateCreate
    FROM tbmk_Banuudai k
    WHERE (@Keyword IS NULL OR k.Tenuudai LIKE N'%' + @Keyword + '%' OR k.DocumentID LIKE '%' + @Keyword + '%')
    ORDER BY k.DateCreate DESC, k.DocumentID DESC;
END
GO

-- =========================================================================
-- 2. Đăng ký vào WA_API và SY_FrmLstTbl
-- =========================================================================
PRINT N'2. Đang đồng bộ WA_API và SY_FrmLstTbl...';
GO

-- Cập nhật bảng lưu tự động (SaveTableName) để API_LuuDong biết chỗ lưu
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmKhuyenMai')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, PrimaryKey, SaveTableName)
    VALUES ('frmKhuyenMai', N'Danh sách Khuyến Mãi', 'API_DanhSachKhuyenMai', 'DocumentID', 'tbmk_Banuudai');
ELSE
    UPDATE SY_FrmLstTbl SET TableName = 'API_DanhSachKhuyenMai', PrimaryKey = 'DocumentID', SaveTableName = 'tbmk_Banuudai' WHERE FormID = 'frmKhuyenMai';
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
-- 3. Đồng bộ giao diện (Cột vật lý -> Tiếng Việt)
-- =========================================================================
PRINT N'3. Đang đồng bộ SY_FormatFields...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmKhuyenMai', @ObjectName = 'API_DanhSachKhuyenMai';
GO

-- Gán Label có dấu (CaptionVN)
UPDATE SY_FormatFields SET CaptionVN = N'Mã ưu đãi' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'DocumentID';
UPDATE SY_FormatFields SET CaptionVN = N'Tên ưu đãi' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tenuudai';
UPDATE SY_FormatFields SET CaptionVN = N'Loại hình tiệc', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View | dmLoaihinhtiec' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Từ ngày', FormatID = 'dt' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tungay';
UPDATE SY_FormatFields SET CaptionVN = N'Đến ngày', FormatID = 'dt' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Denngay';
UPDATE SY_FormatFields SET CaptionVN = N'Từ số bàn', FormatID = 'n' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Tusoluongban';
UPDATE SY_FormatFields SET CaptionVN = N'Đến số bàn', FormatID = 'n' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Densoluongban';
UPDATE SY_FormatFields SET CaptionVN = N'Áp dụng số bàn' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'ApDungSoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Đã kết thúc', FormatID = 'sw' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'IsKetthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú' WHERE FormName = 'frmKhuyenMai' AND FieldName = 'Ghichu';

-- Cấu hình hiển thị (Ẩn các trường không cần nhập)
-- ApDungSoBan là cột tính toán -> Chỉ hiện trên lưới, không cho nhập
UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0 WHERE FormName = 'frmKhuyenMai' AND FieldName = 'ApDungSoBan';

-- Tusoluongban, Densoluongban -> Chỉ hiện trong form nhập, ẩn trên lưới
UPDATE SY_FormatFields SET ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmKhuyenMai' AND FieldName IN ('Tusoluongban', 'Densoluongban');

-- Các trường nhập hiển thị đầy đủ trên Form
UPDATE SY_FormatFields SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1 WHERE FormName = 'frmKhuyenMai' AND FieldName IN ('Loaitiecid', 'Tungay', 'Denngay', 'IsKetthuc', 'Ghichu');

-- Ẩn hoàn toàn các cột hệ thống (Id, DateCreate)
UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, FormPosition = 'hidden' WHERE FormName = 'frmKhuyenMai' AND FieldName IN ('Id', 'DateCreate');

PRINT N'=== HOÀN THÀNH ===';
GO
