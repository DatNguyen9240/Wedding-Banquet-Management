USE [QLTiec]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

-- =========================================================================
-- 1. BẢNG DANH MỤC KIỂU SETUP (dmKieuSetup)
-- =========================================================================
IF OBJECT_ID('dbo.dmKieuSetup', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dmKieuSetup (
        KieuSetupID VARCHAR(50) NOT NULL PRIMARY KEY,
        TenKieuSetup NVARCHAR(100) NOT NULL,
        GhiChu NVARCHAR(255) NULL,
        OrderNo INT NULL,
        IsDeleted BIT DEFAULT 0
    );
END
GO

-- Seed dữ liệu kiểu setup
MERGE INTO dbo.dmKieuSetup AS target
USING (VALUES
    ('ClassRoom', N'Bàn lớp học (Classroom)', N'Bàn dài có ghế ngồi cùng hướng lên sân khấu', 1),
    ('Theater', N'Nhà hát (Theater)', N'Chỉ có ghế ngồi xếp hàng hướng về sân khấu', 2),
    ('Cluster', N'Cụm tròn bán nguyệt (Cluster Half Round)', N'Bàn tròn xếp nửa vầng trăng để khách đều thấy sân khấu', 3),
    ('Banquet', N'Bàn tiệc tròn (Banquet)', N'Bàn tiệc tròn tiêu chuẩn 10-12 người/bàn', 4),
    ('UShape', N'Bàn chữ U (U-Shape)', N'Xếp bàn hình chữ U phục vụ họp/hội thảo tương tác', 5),
    ('Boardroom', N'Phòng họp hội đồng (Boardroom)', N'Bàn họp lớn tập trung ở giữa phòng', 6),
    ('Cocktail', N'Tiệc đứng (Cocktail / Standing)', N'Bàn cocktail cao phục vụ tiệc đứng nhẹ', 7)
) AS source (KieuSetupID, TenKieuSetup, GhiChu, OrderNo)
ON target.KieuSetupID = source.KieuSetupID
WHEN MATCHED THEN
    UPDATE SET target.TenKieuSetup = source.TenKieuSetup,
               target.GhiChu = source.GhiChu,
               target.OrderNo = source.OrderNo
WHEN NOT MATCHED THEN
    INSERT (KieuSetupID, TenKieuSetup, GhiChu, OrderNo, IsDeleted)
    VALUES (source.KieuSetupID, source.TenKieuSetup, source.GhiChu, source.OrderNo, 0);
GO

-- =========================================================================
-- 2. THỦ TỤC API_DanhSachKieuSetup
-- =========================================================================
IF OBJECT_ID('dbo.API_DanhSachKieuSetup', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachKieuSetup;
GO

CREATE PROCEDURE dbo.API_DanhSachKieuSetup
    @Keyword NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        KieuSetupID,
        TenKieuSetup,
        GhiChu
    FROM dbo.dmKieuSetup
    WHERE ISNULL(IsDeleted, 0) = 0
      AND (@Keyword IS NULL OR @Keyword = '' OR TenKieuSetup LIKE N'%' + @Keyword + '%' OR KieuSetupID LIKE '%' + @Keyword + '%')
    ORDER BY OrderNo, TenKieuSetup;
END
GO

-- Vai trò của từng sảnh trong một hợp đồng nhiều phần.
IF OBJECT_ID('dbo.API_DanhSachLoaiDiaDiem', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachLoaiDiaDiem;
GO

CREATE PROCEDURE dbo.API_DanhSachLoaiDiaDiem
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LoaiDiaDiemID, TenLoaiDiaDiem
    FROM (VALUES
        ('TRIEN_LAM', N'Triển lãm', 1),
        ('TIEC', N'Tiệc', 2),
        ('HOI_NGHI', N'Hội nghị', 3)
    ) source(LoaiDiaDiemID, TenLoaiDiaDiem, OrderNo)
    ORDER BY OrderNo;
END
GO

-- =========================================================================
-- 3. MỞ RỘNG BẢNG tbmk_Hopdongsanhtiec
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdongsanhtiec') AND name = 'KieuSetup')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdongsanhtiec ADD KieuSetup NVARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdongsanhtiec') AND name = 'LoaiDiaDiem')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdongsanhtiec ADD LoaiDiaDiem NVARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdongsanhtiec') AND name = 'Thoigianid')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdongsanhtiec ADD Thoigianid VARCHAR(20) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdongsanhtiec') AND name = 'Giatiensanh')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdongsanhtiec ADD Giatiensanh DECIMAL(18,2) NULL;
END
GO

-- Gán vai trò mặc định cho dữ liệu cũ theo loại hợp đồng và cờ sảnh chính/phụ.
UPDATE hs
SET LoaiDiaDiem = CASE
    WHEN h.Loaitiecid = 'BLT000002' AND ISNULL(hs.IsSanhchinh, 0) = 1 THEN 'TRIEN_LAM'
    WHEN h.Loaitiecid = 'BLT000002' THEN 'TIEC'
    WHEN h.Loaitiecid = 'BLT000003' THEN 'TRIEN_LAM'
    WHEN h.Loaitiecid = 'BLT000004' AND ISNULL(hs.IsSanhchinh, 0) = 1 THEN 'HOI_NGHI'
    WHEN h.Loaitiecid = 'BLT000004' THEN 'TIEC'
    WHEN h.Loaitiecid = 'BLT000005' THEN 'HOI_NGHI'
    ELSE hs.LoaiDiaDiem
END
FROM dbo.tbmk_Hopdongsanhtiec hs
INNER JOIN dbo.tbmk_Hopdong h ON h.Sohopdong = hs.Sohopdong
WHERE NULLIF(LTRIM(RTRIM(hs.LoaiDiaDiem)), '') IS NULL
  AND h.Loaitiecid IN ('BLT000002', 'BLT000003', 'BLT000004', 'BLT000005');
GO

-- =========================================================================
-- 4. ĐĂNG KÝ ĐỊNH TUYẾN WA_API & DROPDOWN
-- =========================================================================
DELETE FROM dbo.WA_API WHERE List = 'API_DanhSachKieuSetup' AND Func = 'View';
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachKieuSetup', 'View', 'API_DanhSachKieuSetup', N'@Keyword=N''{Keyword}''');

DELETE FROM dbo.WA_API WHERE List = 'API_DanhSachLoaiDiaDiem' AND Func = 'View';
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachLoaiDiaDiem', 'View', 'API_DanhSachLoaiDiaDiem', N'');

-- Đăng ký dmKieuSetup CRUD
DELETE FROM dbo.WA_API WHERE List = 'dmKieuSetup' AND Func IN ('Save', 'View', 'Delete');
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES 
('dmKieuSetup', 'Save', 'API_LuuDong', '@List=N''dmKieuSetup'', @Data=N''{JsonData}'''),
('dmKieuSetup', 'View', 'API_TruyVanDong', '@List=N''dmKieuSetup'', @Keyword=N''{Keyword}'''),
('dmKieuSetup', 'Delete', 'API_XoaDong', '@List=N''dmKieuSetup'', @Ids=N''{KieuSetupID}'', @UserName=N''{User}''');
GO

-- Đăng ký các dropdown theo từng dòng sảnh trong form Hợp đồng.
DELETE FROM dbo.SY_FrmDrdwTbl
WHERE ColumnID IN ('KieuSetup', 'LoaiDiaDiem', 'Thoigianid')
  AND FormID IN ('v_DanhSachHopDong', 'frmHopDong', 'tbmk_Hopdongsanhtiec');
INSERT INTO dbo.SY_FrmDrdwTbl
    (UserAutoID, FormID, GridName, ColumnID, Source, Type,
     ValueColumn, DisplayColumn, Caption, ColumnArr, WidthArr,
     DisableAddNew, IsMultiSelect, IsNotInList, IsDisable, isInvisible)
VALUES
    (NEWID(), 'v_DanhSachHopDong', 'GridSanhTiec', 'KieuSetup',
     N'/api/API_Gateway_Router?List=API_DanhSachKieuSetup&Func=View', 'API',
     'KieuSetupID', 'TenKieuSetup', N'Kiểu setup', 'KieuSetupID;TenKieuSetup', '120;250',
     1, 0, 1, 0, 0),
    (NEWID(), 'v_DanhSachHopDong', 'GridSanhTiec', 'LoaiDiaDiem',
     N'/api/API_Gateway_Router?List=API_DanhSachLoaiDiaDiem&Func=View', 'API',
     'LoaiDiaDiemID', 'TenLoaiDiaDiem', N'Loại địa điểm', 'LoaiDiaDiemID;TenLoaiDiaDiem', '130;220',
     1, 0, 1, 0, 0),
    (NEWID(), 'v_DanhSachHopDong', 'GridSanhTiec', 'Thoigianid',
     N'/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', 'API',
     'Thoigianid', 'Thoigian', N'Ca sử dụng sảnh', 'Thoigianid;Thoigian', '120;260',
     1, 0, 1, 0, 0);
GO
