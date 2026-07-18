USE [QLTiec]
GO

/* Synchronize all four event-operation read models with the canonical field metadata. */
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (
        SELECT 1
        FROM (VALUES ('t'), ('D'), ('H'), ('N0'), ('sw')) requiredFormat(FormatID)
        WHERE NOT EXISTS (SELECT 1 FROM dbo.SY_FmatTbl WHERE FormatID = requiredFormat.FormatID)
    )
        THROW 51120, 'Required FormatID t, D, H, N0 or sw is missing.', 1;

    DECLARE @Forms TABLE (FormName SYSNAME NOT NULL PRIMARY KEY);
    INSERT INTO @Forms (FormName) VALUES
        ('v_DanhSachPhieuCoc'),
        ('v_DanhSachPhuLuc'),
        ('v_DanhSachBEO'),
        ('v_DanhSachQuyetToan');

    IF EXISTS (SELECT 1 FROM @Forms WHERE OBJECT_ID(FormName, 'V') IS NULL)
        THROW 51121, 'An operation read-model view is missing.', 1;

    DECLARE @Visible TABLE (FormName SYSNAME NOT NULL, FieldName SYSNAME NOT NULL, PRIMARY KEY (FormName, FieldName));
    INSERT INTO @Visible (FormName, FieldName) VALUES
        ('v_DanhSachPhieuCoc', 'DocumentID'), ('v_DanhSachPhieuCoc', 'SoPhieu'),
        ('v_DanhSachPhieuCoc', 'TenKhachHang'), ('v_DanhSachPhieuCoc', 'NgayToChuc'),
        ('v_DanhSachPhieuCoc', 'SoBan'), ('v_DanhSachPhieuCoc', 'SanhDat'),
        ('v_DanhSachPhieuCoc', 'DaCocVND'), ('v_DanhSachPhieuCoc', 'TrangThai'),
        ('v_DanhSachPhuLuc', 'Sothaydoi'), ('v_DanhSachPhuLuc', 'Ngaythaydoi'),
        ('v_DanhSachPhuLuc', 'Sohopdong'), ('v_DanhSachPhuLuc', 'TenKhachHang'),
        ('v_DanhSachPhuLuc', 'TenSanhTiec'), ('v_DanhSachPhuLuc', 'NgayToChuc'),
        ('v_DanhSachBEO', 'Sohopdong'), ('v_DanhSachBEO', 'Sobiennhan'),
        ('v_DanhSachBEO', 'TenKhachHang'), ('v_DanhSachBEO', 'NgayToChuc'),
        ('v_DanhSachBEO', 'LoaiTiecID'), ('v_DanhSachBEO', 'ThoiGianID'),
        ('v_DanhSachBEO', 'SoBan'), ('v_DanhSachBEO', 'SanhDat'),
        ('v_DanhSachQuyetToan', 'DocumentID'), ('v_DanhSachQuyetToan', 'DocumentDate'),
        ('v_DanhSachQuyetToan', 'Sohopdong'), ('v_DanhSachQuyetToan', 'TenKhachHang'),
        ('v_DanhSachQuyetToan', 'Nguoinop'), ('v_DanhSachQuyetToan', 'TongtienHoaDon'),
        ('v_DanhSachQuyetToan', 'Tongtiencoc'), ('v_DanhSachQuyetToan', 'Thanhtoan'),
        ('v_DanhSachQuyetToan', 'Conlai'), ('v_DanhSachQuyetToan', 'IsKetthuc');

    DECLARE @Captions TABLE (FieldName SYSNAME NOT NULL PRIMARY KEY, CaptionVN NVARCHAR(255) NOT NULL);
    INSERT INTO @Captions (FieldName, CaptionVN) VALUES
        ('DocumentID', N'Mã chứng từ'), ('SoPhieu', N'Số phiếu'),
        ('TenKhachHang', N'Tên khách hàng'), ('NgayToChuc', N'Ngày tổ chức'),
        ('SoBan', N'Số bàn'), ('SanhDat', N'Sảnh đặt'), ('DaCocVND', N'Tiền cọc'),
        ('TrangThai', N'Trạng thái'), ('Sothaydoi', N'Số thay đổi'),
        ('Ngaythaydoi', N'Ngày thay đổi'), ('TenSanhTiec', N'Sảnh tiệc'),
        ('LoaiTiecID', N'Loại tiệc'), ('ThoiGianID', N'Ca tiệc'),
        ('DocumentDate', N'Ngày chứng từ'), ('Nguoinop', N'Người nộp'),
        ('TongtienHoaDon', N'Tổng tiền hóa đơn'), ('Tongtiencoc', N'Tổng tiền cọc'),
        ('Thanhtoan', N'Đã thanh toán'), ('Conlai', N'Còn lại'),
        ('IsKetthuc', N'Đã kết thúc');

    DECLARE @FormName SYSNAME;
    DECLARE @ObjectId INT;
    DECLARE @Columns TABLE (FieldName SYSNAME NOT NULL PRIMARY KEY, FormatID VARCHAR(20) NOT NULL, IsGridField BIT NOT NULL);

    WHILE EXISTS (SELECT 1 FROM @Forms)
    BEGIN
        SELECT TOP (1) @FormName = FormName FROM @Forms ORDER BY FormName;
        SELECT @ObjectId = OBJECT_ID(@FormName, 'V');
        DELETE FROM @Columns;

        INSERT INTO @Columns (FieldName, FormatID, IsGridField)
        SELECT
            c.name,
            CASE
                WHEN c.system_type_id = 104 THEN 'sw'
                WHEN c.system_type_id IN (40, 42, 43, 58, 61) THEN 'D'
                WHEN c.system_type_id = 41 THEN 'H'
                WHEN c.system_type_id IN (48, 52, 56, 59, 60, 62, 106, 108, 122, 127) THEN 'N0'
                ELSE 't'
            END,
            CASE WHEN EXISTS (SELECT 1 FROM @Visible v WHERE v.FormName = @FormName AND v.FieldName = c.name) THEN 1 ELSE 0 END
        FROM sys.columns c
        WHERE c.object_id = @ObjectId;

        UPDATE d
        SET d.FormatID = c.FormatID,
            d.CaptionVN = COALESCE(NULLIF(LTRIM(RTRIM(d.CaptionVN)), ''), CONVERT(NVARCHAR(255), c.FieldName))
        FROM dbo.SY_FmtFldTbl d
        INNER JOIN @Columns c ON c.FieldName = d.FieldName;

        INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
        SELECT @FormName, c.FieldName, CONVERT(NVARCHAR(255), c.FieldName), c.FormatID
        FROM @Columns c
        WHERE NOT EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl d WHERE d.FieldName = c.FieldName);

        UPDATE dd
        SET isInvisible = CASE WHEN c.IsGridField = 1 THEN 0 ELSE 1 END
        FROM dbo.SY_FrmDrdwTbl dd
        INNER JOIN @Columns c ON c.FieldName = dd.ColumnID
        WHERE dd.FormID = @FormName
          AND NULLIF(LTRIM(RTRIM(dd.GridName)), '') IS NULL;

        INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible)
        SELECT LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')),
               @FormName,
               c.FieldName,
               CASE WHEN c.IsGridField = 1 THEN 0 ELSE 1 END
        FROM @Columns c
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.SY_FrmDrdwTbl dd
            WHERE dd.FormID = @FormName
              AND NULLIF(LTRIM(RTRIM(dd.GridName)), '') IS NULL
              AND dd.ColumnID = c.FieldName
        );

        DELETE FROM @Forms WHERE FormName = @FormName;
    END;

    UPDATE d
    SET CaptionVN = c.CaptionVN
    FROM dbo.SY_FmtFldTbl d
    INNER JOIN @Captions c ON c.FieldName = d.FieldName;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
