const fs = require('fs');
const path = require('path');

const files = [
    'd:\\LamViec\\Wedding-Banquet-Management\\sql\\Update\\Update_frmBiennhancoccho_AllInOne.sql',
    'd:\\LamViec\\Wedding-Banquet-Management\\sql\\Update\\Update_frmHopDong_AllInOne.sql',
    'd:\\LamViec\\Wedding-Banquet-Management\\sql\\Update\\Update_PhuLuc_AllInOne.sql',
    'd:\\LamViec\\Wedding-Banquet-Management\\sql\\Update\\Update_frmThayDoiBoSung_AllInOne.sql'
];

const createTableSql = `
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
`;

const migrationSql = `
-- =========================================================================
-- DI TRÚ DỮ LIỆU TỰ ĐỘNG SANG CÁC BẢNG CHUẨN (SY_FmtFldTbl & SY_FrmDrdwTbl)
-- =========================================================================
PRINT N'Đang di chuyển dữ liệu từ SY_FormatFields sang SY_FmtFldTbl và SY_FrmDrdwTbl...';
GO

-- 1. Thêm hoặc cập nhật dữ liệu vào SY_FmtFldTbl
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

-- 2. Thêm hoặc cập nhật dữ liệu ẩn/hiện/khoá và dropdown vào SY_FrmDrdwTbl
-- 2.1. Đăng ký dropdown (các trường có DataSource)
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

-- 2.2. Đăng ký ẩn/hiện và khoá cho các trường thường (không có DataSource)
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

-- 3. Xoá bảng tạm SY_FormatFields để CSDL luôn sạch sẽ
IF OBJECT_ID('SY_FormatFields', 'U') IS NOT NULL
    DROP TABLE SY_FormatFields;
GO
`;

for (const file of files) {
    if (!fs.existsSync(file)) {
        console.log(`File not found: ${file}`);
        continue;
    }
    let content = fs.readFileSync(file, 'utf8');
    
    // Đảm bảo không xử lý lặp lại
    if (content.includes('Helper tạm thời phục vụ migration')) {
        console.log(`File already modified: ${file}`);
        continue;
    }
    
    // Tìm vị trí thích hợp để chèn createTableSql (Sau USE [QLTiec] GO đầu tiên)
    const goIndex = content.indexOf('GO');
    if (goIndex !== -1) {
        const insertPos = goIndex + 2;
        content = content.slice(0, insertPos) + '\n' + createTableSql + '\n' + content.slice(insertPos);
    } else {
        content = createTableSql + '\n' + content;
    }
    
    // Append migrationSql ở cuối file
    content = content + '\n' + migrationSql;
    
    fs.writeFileSync(file, content, 'utf8');
    console.log(`Successfully updated: ${file}`);
}
