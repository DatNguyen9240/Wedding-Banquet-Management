USE [QLTiec]
GO

SET XACT_ABORT ON
GO

/*
  Resolve only the duplicate FieldName records reported by
  Report_CrudReadiness.sql. This script does not infer values from a fallback
  source; each conflicting field has an explicit canonical label and FormatID.
*/
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.SY_FmtFldTbl', 'U') IS NULL
       OR OBJECT_ID('dbo.SY_FmatTbl', 'U') IS NULL
        THROW 51020, 'Canonical metadata tables are missing.', 1;

    /* Canonical primitive formats required by the metadata contract. */
    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = 't')
        INSERT INTO dbo.SY_FmatTbl
            (FormatID, FormatName, NumberDecimal, FormatString, MaskString, MaxLength, Type, Params, Align, IsComplex, MinValue, MaxValue)
        VALUES
            ('t', N'Text', 0, NULL, NULL, NULL, 'S', NULL, 'L', 0, NULL, NULL);

    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = 'sl')
        INSERT INTO dbo.SY_FmatTbl
            (FormatID, FormatName, NumberDecimal, FormatString, MaskString, MaxLength, Type, Params, Align, IsComplex, MinValue, MaxValue)
        VALUES
            ('sl', N'Lookup', 0, NULL, NULL, NULL, 'S', NULL, 'L', 0, NULL, NULL);

    IF NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = 'sw')
        INSERT INTO dbo.SY_FmatTbl
            (FormatID, FormatName, NumberDecimal, FormatString, MaskString, MaxLength, Type, Params, Align, IsComplex, MinValue, MaxValue)
        VALUES
            ('sw', N'Switch', 0, NULL, NULL, NULL, 'N', NULL, 'C', 0, 0, 1);

    DECLARE @Canonical TABLE (
        FieldName VARCHAR(128) NOT NULL PRIMARY KEY,
        CaptionVN NVARCHAR(255) NOT NULL,
        FormatID VARCHAR(50) NOT NULL
    );

    INSERT INTO @Canonical (FieldName, CaptionVN, FormatID)
    VALUES
        ('Disable', N'Ngưng sử dụng', 'sw'),
        ('DisableAutoBackup', N'Tắt tự động sao lưu', 'sw'),
        ('EmployeeID', N'Nhân viên liên kết', 'sl'),
        ('GioBatDau', N'Giờ bắt đầu', 't'),
        ('HoTen', N'Họ và tên', 't'),
        ('IsBackupDatabase', N'Quyền sao lưu dữ liệu', 'sw'),
        ('IsBaococcho', N'Quyền xem báo cáo cọc chỗ', 'sw'),
        ('IsBaocongno', N'Quyền xem báo cáo công nợ', 'sw'),
        ('IsBaoHopDong', N'Quyền xem báo cáo hợp đồng', 'sw'),
        ('IsBaoLichTiec', N'Quyền xem lịch tiệc', 'sw'),
        ('IsBaotiec', N'Quyền xem báo cáo tiệc', 'sw'),
        ('IsBaoTrungSanh', N'Cảnh báo trùng sảnh', 'sw'),
        ('IsDuyetDeXuat', N'Quyền duyệt đề xuất', 'sw'),
        ('IsFormBaocao', N'Quyền xem báo cáo doanh thu', 'sw'),
        ('IsPhieuchi', N'Quyền lập phiếu chi', 'sw'),
        ('Manager', N'Tài khoản quản lý', 'sw'),
        ('TenNgan', N'Tên hiển thị (tên ngắn)', 't'),
        ('UserGroupID', N'Nhóm quyền', 'sl'),
        ('UserName', N'Tên đăng nhập', 't');

    DECLARE @MissingFormatIds NVARCHAR(MAX) = N'';
    SELECT @MissingFormatIds = STUFF((
        SELECT N', ' + c.FormatID
        FROM @Canonical c
        WHERE NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = c.FormatID)
        GROUP BY c.FormatID
        ORDER BY c.FormatID
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, N'');

    IF @MissingFormatIds <> N''
    BEGIN
        DECLARE @MissingFormatMessage NVARCHAR(2048) = N'Missing canonical FormatID(s) in SY_FmatTbl: ' + @MissingFormatIds;
        THROW 51021, @MissingFormatMessage, 1;
    END;

    /* The following names are legacy menu labels, not columns in any table. */
    DECLARE @OrphanMenuFields TABLE (FieldName VARCHAR(128) NOT NULL PRIMARY KEY);
    INSERT INTO @OrphanMenuFields (FieldName)
    VALUES
        ('BiennhancocchoFrm'),
        ('HopdongdattiecFrm'),
        ('KhachthamquanFrm'),
        ('QueenBiennhancocchoFrm'),
        ('ThayDoiHopDongDatTiecFrm');

    IF EXISTS (
        SELECT 1
        FROM @OrphanMenuFields o
        INNER JOIN sys.columns c ON c.name = o.FieldName
    )
        THROW 51022, 'A legacy menu field is a real database column; review it manually before deleting metadata.', 1;

    DELETE f
    FROM dbo.SY_FmtFldTbl f
    INNER JOIN @OrphanMenuFields o ON o.FieldName = f.FieldName;

    ;WITH CanonicalRows AS (
        SELECT f.AutoID, c.FieldName, c.CaptionVN, c.FormatID,
               ROW_NUMBER() OVER (PARTITION BY c.FieldName ORDER BY f.AutoID) AS RowNumber
        FROM dbo.SY_FmtFldTbl f
        INNER JOIN @Canonical c ON c.FieldName = f.FieldName
    )
    UPDATE f
    SET f.FieldName = r.FieldName,
        f.CaptionVN = r.CaptionVN,
        f.FormatID = r.FormatID
    FROM dbo.SY_FmtFldTbl f
    INNER JOIN CanonicalRows r ON r.AutoID = f.AutoID
    WHERE r.RowNumber = 1;

    ;WITH DuplicateRows AS (
        SELECT f.AutoID,
               ROW_NUMBER() OVER (PARTITION BY f.FieldName ORDER BY f.AutoID) AS RowNumber
        FROM dbo.SY_FmtFldTbl f
        WHERE EXISTS (SELECT 1 FROM @Canonical c WHERE c.FieldName = f.FieldName)
           OR f.FieldName IN ('Dongia', 'Dongiakhac', 'DongiaVIP')
    )
    DELETE f
    FROM dbo.SY_FmtFldTbl f
    INNER JOIN DuplicateRows d ON d.AutoID = f.AutoID
    WHERE d.RowNumber > 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl f
        WHERE f.FieldName IN ('Dongia', 'Dongiakhac', 'DongiaVIP')
          AND NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID)
    )
        THROW 51023, 'A price field has an invalid FormatID; no metadata was committed.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl f
        WHERE f.FieldName IN (SELECT FieldName FROM @Canonical)
        GROUP BY f.FieldName
        HAVING COUNT(*) <> 1
    )
        THROW 51024, 'Canonical duplicate cleanup did not produce exactly one row per field.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
