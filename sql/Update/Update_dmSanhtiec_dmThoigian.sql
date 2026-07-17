USE [QLTiec]
GO

-- Helper tạm thời phục vụ migration
IF OBJECT_ID('SY_FormatFields', 'U') IS NULL
BEGIN
    CREATE TABLE SY_FormatFields (
        AutoID int IDENTITY(1,1) PRIMARY KEY,
        FormatID varchar(50),
        FieldName varchar(50),
        FormName varchar(50),
        CaptionVN nvarchar(255),
        CaptionEN nvarchar(200),
        CaptionCH nvarchar(200),
        AlignX varchar(50),
        MinWidth int,
        MaxWidth int,
        ShowInAdd bit DEFAULT 1,
        ShowInEdit bit DEFAULT 1,
        FormPosition varchar(50),
        IsRequired bit DEFAULT 0,
        OrderNo int,
        DataSource nvarchar(500),
        ValidateRule nvarchar(500),
        DependsOn varchar(50),
        VisibleRule nvarchar(500),
        IsReadOnlyAdd bit DEFAULT 0,
        IsReadOnlyEdit bit DEFAULT 0,
        ShowInFilter bit DEFAULT 0,
        ShowInGrid bit DEFAULT 1
    );
END
GO

-- =========================================================================
-- 1. ĐĂNG KÝ ĐỊNH TUYẾN WA_API (Save & View)
-- =========================================================================
PRINT N'1. Đang đăng ký API cho dmSanhtiec, dmThoigian, API_DanhSachCaLam...';
GO

-- dmSanhtiec
DELETE FROM WA_API WHERE List = 'dmSanhtiec' AND Func IN ('Save', 'View', 'Delete');
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('dmSanhtiec', 'Save', 'API_LuuDong', '@List=N''dmSanhtiec'', @Data=N''{JsonData}'''),
('dmSanhtiec', 'View', 'API_TruyVanDong', '@List=N''dmSanhtiec'', @Keyword=N''{Keyword}'''),
('dmSanhtiec', 'Delete', 'API_XoaDong', '@List=N''dmSanhtiec'', @Ids=N''{Sanhtiecid}'', @UserName=N''{User}''');

-- dmThoigian
DELETE FROM WA_API WHERE List = 'dmThoigian' AND Func IN ('Save', 'View', 'Delete');
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('dmThoigian', 'Save', 'API_LuuDong', '@List=N''dmThoigian'', @Data=N''{JsonData}'''),
('dmThoigian', 'View', 'API_TruyVanDong', '@List=N''dmThoigian'', @Keyword=N''{Keyword}'''),
('dmThoigian', 'Delete', 'API_XoaDong', '@List=N''dmThoigian'', @Ids=N''{Thoigianid}'', @UserName=N''{User}''');

-- API_DanhSachCaLam
DELETE FROM WA_API WHERE List = 'API_DanhSachCaLam' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('API_DanhSachCaLam', 'Save', 'API_LuuDong', '@List=N''API_DanhSachCaLam'', @Data=N''{JsonData}''');
GO



-- =========================================================================
-- 3. ĐỒNG BỘ CỘT TỰ ĐỘNG (API_DongBoTruongGiaoDien)
-- =========================================================================
PRINT N'3. Đang đồng bộ các cột từ bảng vật lý...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'dmSanhtiec', @ObjectName = 'dmSanhtiec';
EXEC API_DongBoTruongGiaoDien @FormName = 'dmThoigian', @ObjectName = 'dmThoigian';
EXEC API_DongBoTruongGiaoDien @FormName = 'API_DanhSachCaLam', @ObjectName = 'dmThoigian';
GO

-- =========================================================================
-- 4. CẤU HÌNH NHÃN TIẾNG VIỆT VÀ ĐỊNH DẠNG (SY_FormatFields)
-- =========================================================================
PRINT N'4. Đang cấu hình chi tiết hiển thị cho dmSanhtiec...';
GO

UPDATE SY_FormatFields SET CaptionVN = N'Mã Sảnh', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Sanhtiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Sảnh', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Tensanhtiec';
UPDATE SY_FormatFields SET CaptionVN = N'Sức Chứa (Người)', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Succhua';
UPDATE SY_FormatFields SET CaptionVN = N'Đơn Giá Sảnh', FormatID = 'mn', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'Dongia';
UPDATE SY_FormatFields SET CaptionVN = N'Số Bàn Tối Thiểu', FormatID = 'n', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'SLBanMin';
UPDATE SY_FormatFields SET CaptionVN = N'Số Bàn Tối Đa', FormatID = 'n', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'SLBanMax';
UPDATE SY_FormatFields SET CaptionVN = N'Tạm Ngưng', FormatID = 'sw', FormPosition = '6', OrderNo = 7, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'IsTamngung';
UPDATE SY_FormatFields SET CaptionVN = N'Là Sảnh Hoạt Động', FormatID = 'sw', FormPosition = 'hidden', OrderNo = 8, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'isSanh';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi Chú', FormatID = 'ta', FormPosition = '12', OrderNo = 9, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmSanhtiec' AND FieldName = 'GhiChuSanh';

-- Ẩn tất cả các cột hệ thống/kỹ thuật khác ngoài 8 trường chính để giao diện gọn gàng
UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'dmSanhtiec' 
  AND FieldName NOT IN ('Sanhtiecid', 'Tensanhtiec', 'Succhua', 'Dongia', 'SLBanMin', 'SLBanMax', 'IsTamngung', 'GhiChuSanh');
GO

PRINT N'5. Đang cấu hình chi tiết hiển thị cho dmThoigian và API_DanhSachCaLam...';
GO

-- Cấu hình dmThoigian
UPDATE SY_FormatFields SET CaptionVN = N'Mã Ca', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca Tiệc / Giờ Tổ Chức', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'dmThoigian' AND FieldName = 'Thoigian';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Bắt Đầu', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'GhiBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Kết Thúc', FormatID = 'n', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'GioKetThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Tiệc Cưới', FormatID = 'sw', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'IsTiecCuoi';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Hội Nghị', FormatID = 'sw', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'dmThoigian' AND FieldName = 'IsHoiNghi';

UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'dmThoigian' 
  AND FieldName IN ('UserCreate', 'UserUpdate', 'DateCreate', 'DateUpdate', 'Nhahangid', 'Tenngan', 'IsFullNgay', 'AMPM', 'NhomBCLichTiec');

-- Cấu hình API_DanhSachCaLam (sao chép giống hệt)
UPDATE SY_FormatFields SET CaptionVN = N'Mã Ca', FormatID = 't', FormPosition = 'hidden', OrderNo = 1, ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, IsRequired = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca Tiệc / Giờ Tổ Chức', FormatID = 't', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, IsRequired = 1 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'Thoigian';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Bắt Đầu', FormatID = 'n', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'GhiBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ Kết Thúc', FormatID = 'n', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'GioKetThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Tiệc Cưới', FormatID = 'sw', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'IsTiecCuoi';
UPDATE SY_FormatFields SET CaptionVN = N'Phục vụ Hội Nghị', FormatID = 'sw', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'API_DanhSachCaLam' AND FieldName = 'IsHoiNghi';

UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' 
WHERE FormName = 'API_DanhSachCaLam' 
  AND FieldName IN ('UserCreate', 'UserUpdate', 'DateCreate', 'DateUpdate', 'Nhahangid', 'Tenngan', 'IsFullNgay', 'AMPM', 'NhomBCLichTiec');
GO

-- =========================================================================
-- DI TRÚ DỮ LIỆU TỰ ĐỘNG SANG CÁC BẢNG CHUẨN (SY_FmtFldTbl & SY_FrmDrdwTbl)
-- =========================================================================
PRINT N'Đang di chuyển dữ liệu từ SY_FormatFields sang SY_FmtFldTbl...';
GO

MERGE INTO SY_FmtFldTbl AS target
USING SY_FormatFields AS source
ON (target.FormName = source.FormName AND target.FieldName = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        CaptionVN = ISNULL(source.CaptionVN, target.CaptionVN),
        CaptionEN = ISNULL(source.CaptionEN, target.CaptionEN),
        CaptionCH = ISNULL(source.CaptionCH, target.CaptionCH),
        FormatID  = ISNULL(source.FormatID,  target.FormatID),
        AlignX    = ISNULL(source.AlignX,    target.AlignX),
        MinWidth  = ISNULL(source.MinWidth,  target.MinWidth),
        MaxWidth  = ISNULL(source.MaxWidth,  target.MaxWidth)
WHEN NOT MATCHED THEN
    INSERT (FormName, FieldName, CaptionVN, CaptionEN, CaptionCH, FormatID, AlignX, MinWidth, MaxWidth)
    VALUES (source.FormName, source.FieldName, source.CaptionVN, source.CaptionEN, source.CaptionCH, source.FormatID, source.AlignX, source.MinWidth, source.MaxWidth);
GO

MERGE INTO SY_FrmDrdwTbl AS target
USING (
    SELECT FormName, FieldName, DataSource,
           CASE WHEN ShowInAdd = 0 AND ShowInEdit = 0 THEN 1 ELSE 0 END AS IsInvisibleVal,
           CASE WHEN IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 THEN 1 ELSE 0 END AS IsLockVal
    FROM SY_FormatFields
    WHERE DataSource IS NOT NULL AND DataSource <> ''
) AS source
ON (target.FormID = source.FormName AND target.ColumnID = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        Source = source.DataSource,
        Type = 'API',
        ValueColumn = source.FieldName,
        DisplayColumn = 'Ten',
        isInvisible = source.IsInvisibleVal,
        isLock = source.IsLockVal
WHEN NOT MATCHED THEN
    INSERT (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn, isInvisible, isLock)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), source.FormName, source.FieldName, source.DataSource, 'API', source.FieldName, 'Ten', source.IsInvisibleVal, source.IsLockVal);
GO

MERGE INTO SY_FrmDrdwTbl AS target
USING (
    SELECT FormName, FieldName,
           CASE WHEN ShowInAdd = 0 AND ShowInEdit = 0 THEN 1 ELSE 0 END AS IsInvisibleVal,
           CASE WHEN IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 THEN 1 ELSE 0 END AS IsLockVal
    FROM SY_FormatFields
    WHERE (DataSource IS NULL OR DataSource = '')
      AND (ShowInAdd = 0 OR ShowInEdit = 0 OR IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 OR FormPosition = 'hidden')
) AS source
ON (target.FormID = source.FormName AND target.ColumnID = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        isInvisible = source.IsInvisibleVal,
        isLock = source.IsLockVal
WHEN NOT MATCHED THEN
    INSERT (UserAutoID, FormID, ColumnID, isInvisible, isLock)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), source.FormName, source.FieldName, source.IsInvisibleVal, source.IsLockVal);
GO

IF OBJECT_ID('SY_FormatFields', 'U') IS NOT NULL
    DROP TABLE SY_FormatFields;
GO

PRINT N'=== HOÀN THÀNH CẤU HÌNH CHO SANH TIEC & CA LAM ===';
GO
