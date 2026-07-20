USE [QLTiec]
GO

/* Các field mã của hợp đồng phải chọn từ danh mục, không nhập text tự do. */
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @GatewayApis TABLE
(
    ListName VARCHAR(128) NOT NULL PRIMARY KEY,
    ProcedureName SYSNAME NOT NULL,
    Para NVARCHAR(MAX) NULL
);

INSERT INTO @GatewayApis (ListName, ProcedureName, Para)
VALUES
    ('API_DanhSachKhachHang', 'API_DanhSachKhachHang', N'@Keyword=N''{Keyword}'''),
    ('API_DanhSachNhanVien', 'API_DanhSachNhanVien', N'@Keyword=N''{Keyword}'''),
    ('API_DanhSachCaLam', 'API_DanhSachCaLam', N''),
    ('API_DanhSachLoaiHinhTiec', 'API_DanhSachLoaiHinhTiec', N''),
    ('API_DanhSachGoiThucDon', 'API_DanhSachGoiThucDon', N'@Keyword=N''{Keyword}''');

UPDATE gateway
SET gateway.[SQL] = sourceApi.ProcedureName,
    gateway.Para = sourceApi.Para
FROM dbo.WA_API gateway
INNER JOIN @GatewayApis sourceApi ON sourceApi.ListName = gateway.List
WHERE gateway.Func = 'View';

INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
SELECT sourceApi.ListName, 'View', sourceApi.ProcedureName, sourceApi.Para
FROM @GatewayApis sourceApi
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.WA_API gateway
    WHERE gateway.List = sourceApi.ListName
      AND gateway.Func = 'View'
);

DECLARE @Dropdowns TABLE
(
    ColumnID VARCHAR(128) NOT NULL PRIMARY KEY,
    Source NVARCHAR(1000) NOT NULL,
    ValueColumn VARCHAR(128) NOT NULL,
    DisplayColumn VARCHAR(128) NOT NULL,
    Caption NVARCHAR(255) NOT NULL,
    ColumnArr VARCHAR(1000) NULL,
    WidthArr VARCHAR(255) NULL
);

INSERT INTO @Dropdowns
    (ColumnID, Source, ValueColumn, DisplayColumn, Caption, ColumnArr, WidthArr)
VALUES
    ('Makh',
     N'/api/API_Gateway_Router?List=API_DanhSachKhachHang&Func=View',
     'Makh', 'Tenkh', N'Tên khách hàng', 'Makh;Tenkh;DienthoaiChung', '140;240;140'),
    ('Manv',
     N'/api/API_Gateway_Router?List=API_DanhSachNhanVien&Func=View',
     'NHANVIENID', 'TENNHANVIEN', N'Tên nhân viên', 'NHANVIENID;TENNHANVIEN;DIENTHOAI', '130;220;140'),
    ('Thoigianid',
     N'/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View',
     'Thoigianid', 'Thoigian', N'Ca tiệc', 'Thoigianid;Thoigian', '120;260'),
    ('Loaitiecid',
     N'/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View',
     'Loaitiecid', 'Tenloaitiec', N'Tên loại tiệc', 'Loaitiecid;Tenloaitiec', '120;260'),
    ('GoiThucDonID',
     N'/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View',
     'GoiThucDonID', 'TenGoiThucDon', N'Tên gói thực đơn', 'GoiThucDonID;TenGoiThucDon', '130;280');

/* Format sl giúp dictionary thể hiện đúng đây là field chọn danh mục. */
UPDATE dictionary
SET dictionary.FormatID = 'sl'
FROM dbo.SY_FmtFldTbl dictionary
INNER JOIN @Dropdowns sourceConfig ON sourceConfig.ColumnID = dictionary.FieldName
WHERE EXISTS (SELECT 1 FROM dbo.SY_FmatTbl formatDefinition WHERE formatDefinition.FormatID = 'sl');

UPDATE target
SET target.Source = sourceConfig.Source,
    target.Type = 'API',
    target.ValueColumn = sourceConfig.ValueColumn,
    target.DisplayColumn = sourceConfig.DisplayColumn,
    target.Caption = sourceConfig.Caption,
    target.ColumnArr = sourceConfig.ColumnArr,
    target.WidthArr = sourceConfig.WidthArr,
    target.DisableAddNew = 1,
    target.IsMultiSelect = 0,
    target.IsNotInList = 1,
    target.IsDisable = 0,
    target.isInvisible = 0
FROM dbo.SY_FrmDrdwTbl target
INNER JOIN @Dropdowns sourceConfig ON sourceConfig.ColumnID = target.ColumnID
WHERE target.FormID = 'v_DanhSachHopDong'
  AND NULLIF(LTRIM(RTRIM(target.GridName)), '') IS NULL;

INSERT INTO dbo.SY_FrmDrdwTbl
    (UserAutoID, FormID, GridName, ColumnID, Source, Type,
     ValueColumn, DisplayColumn, Caption, ColumnArr, WidthArr,
     DisableAddNew, IsMultiSelect, IsNotInList, IsDisable, isInvisible)
SELECT
    LOWER(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', '')),
    'v_DanhSachHopDong', NULL, sourceConfig.ColumnID, sourceConfig.Source, 'API',
    sourceConfig.ValueColumn, sourceConfig.DisplayColumn, sourceConfig.Caption,
    sourceConfig.ColumnArr, sourceConfig.WidthArr,
    1, 0, 1, 0, 0
FROM @Dropdowns sourceConfig
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.SY_FrmDrdwTbl target
    WHERE target.FormID = 'v_DanhSachHopDong'
      AND NULLIF(LTRIM(RTRIM(target.GridName)), '') IS NULL
      AND target.ColumnID = sourceConfig.ColumnID
);

SELECT
    dropdownConfig.ColumnID,
    dropdownConfig.DisplayColumn,
    dropdownConfig.Source
FROM dbo.SY_FrmDrdwTbl dropdownConfig
WHERE dropdownConfig.FormID = 'v_DanhSachHopDong'
  AND NULLIF(LTRIM(RTRIM(dropdownConfig.GridName)), '') IS NULL
  AND dropdownConfig.ColumnID IN (SELECT ColumnID FROM @Dropdowns)
ORDER BY dropdownConfig.ColumnID;
GO
