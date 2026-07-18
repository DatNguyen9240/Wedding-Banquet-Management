USE [QLTiec]
GO

/* Explicit dictionary configuration for every current dmkhachhang column. */
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.dmkhachhang', N'U') IS NULL
        THROW 51060, 'The customer CRUD table dbo.dmkhachhang does not exist.', 1;

    IF EXISTS (
        SELECT 1
        FROM (VALUES ('t'), ('D'), ('sw')) requiredFormat(FormatID)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = requiredFormat.FormatID
        )
    )
        THROW 51061, 'dmkhachhang requires FormatID t, D and sw in SY_FmatTbl.', 1;

    DECLARE @Fields TABLE (
        FieldName VARCHAR(128) NOT NULL PRIMARY KEY,
        FormatID VARCHAR(20) NOT NULL
    );

    INSERT INTO @Fields (FieldName, FormatID)
    VALUES
        ('Makh', 't'),
        ('Tenkh', 't'),
        ('Tencodau', 't'),
        ('Tenchure', 't'),
        ('Ngaysinhcodau', 'D'),
        ('Ngaysinhchure', 'D'),
        ('DTcodau', 't'),
        ('DTchure', 't'),
        ('Diachi', 't'),
        ('Masothue', 't'),
        ('Nguoigd', 't'),
        ('Dienthoai', 't'),
        ('Fax', 't'),
        ('Mail', 't'),
        ('NhomkhID', 't'),
        ('KhuvucID', 't'),
        ('IsKhachhang', 'sw'),
        ('IsNCC', 'sw'),
        ('IsNhanvien', 'sw'),
        ('IsTinhcongno', 'sw'),
        ('DateCreate', 'D'),
        ('DateUpdate', 'D'),
        ('UserCreate', 't'),
        ('UserUpdate', 't'),
        ('TheVIP', 't'),
        ('Ghichu', 't'),
        ('IsMacdinh', 'sw'),
        ('CMNDchure', 't'),
        ('CMNDcodau', 't'),
        ('CMNDnguoidd', 't'),
        ('Noilamviec', 't'),
        ('IsDiachiChuRe', 'sw'),
        ('IsMailChuRe', 'sw'),
        ('ChucVu', 't'),
        ('TenCty', 't'),
        ('DiaChiCty', 't'),
        ('NguoiLienHeHoaDon', 't'),
        ('DienThoaiHoaDon', 't'),
        ('NgayCap', 'D'),
        ('NoiCap', 't'),
        ('NgayDeLaiThongTin', 'D'),
        ('NguoiPhuTrachID', 't'),
        ('TinhTrangKhachHang', 't'),
        ('LoaiTiecID', 't'),
        ('MakhChamSoc', 't'),
        ('IsGioiTinhNguoidd', 'sw'),
        ('MakhKT', 't'),
        ('isOngBaDaiDien', 'sw'),
        ('CMNDDaiDien', 't'),
        ('DienThoaiDaiDien', 't'),
        ('SoTaiKhoan', 't'),
        ('TaiNganHang', 't'),
        ('BranchID', 't'),
        ('IsDeleted', 'sw'),
        ('DeletedAt', 'D'),
        ('DeletedBy', 't');

    IF EXISTS (
        SELECT 1
        FROM @Fields expected
        WHERE NOT EXISTS (
            SELECT 1
            FROM sys.columns c
            WHERE c.object_id = OBJECT_ID(N'dbo.dmkhachhang', N'U')
              AND c.name = expected.FieldName
        )
    )
        THROW 51062, 'The expected dmkhachhang schema differs from this migration; no metadata was changed.', 1;

    UPDATE f
    SET FormatID = expected.FormatID
    FROM dbo.SY_FmtFldTbl f
    INNER JOIN @Fields expected ON expected.FieldName = f.FieldName;

    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    SELECT
        'dmkhachhang',
        expected.FieldName,
        CASE expected.FieldName
            WHEN 'IsDeleted' THEN N'Da xoa'
            WHEN 'DeletedAt' THEN N'Thoi diem xoa'
            WHEN 'DeletedBy' THEN N'Nguoi xoa'
        END,
        expected.FormatID
    FROM @Fields expected
    WHERE expected.FieldName IN ('IsDeleted', 'DeletedAt', 'DeletedBy')
      AND NOT EXISTS (
          SELECT 1 FROM dbo.SY_FmtFldTbl f WHERE f.FieldName = expected.FieldName
      );

    IF EXISTS (
        SELECT 1
        FROM dbo.SY_FmtFldTbl f
        INNER JOIN @Fields expected ON expected.FieldName = f.FieldName
        WHERE NULLIF(LTRIM(RTRIM(f.CaptionVN)), '') IS NULL
           OR NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = f.FormatID)
    )
        THROW 51063, 'dmkhachhang metadata is incomplete after update.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
