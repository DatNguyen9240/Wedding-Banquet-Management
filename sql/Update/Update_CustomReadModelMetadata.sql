USE [QLTiec]
GO

/*
  Explicit global field dictionary for the two custom read models rendered by
  DynamicFormEngine.  No fields or formats are inferred at runtime.
*/
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.v_DanhSachBaoGia', N'V') IS NULL
       OR OBJECT_ID(N'dbo.v_DanhSachKhachThamQuan', N'V') IS NULL
        THROW 51070, 'Create both custom read-model views before their metadata.', 1;

    IF EXISTS (
        SELECT 1
        FROM (VALUES ('t'), ('D'), ('N0')) requiredFormat(FormatID)
        WHERE NOT EXISTS (
            SELECT 1 FROM dbo.SY_FmatTbl fm WHERE fm.FormatID = requiredFormat.FormatID
        )
    )
        THROW 51071, 'Custom read models require FormatID t, D and N0 in SY_FmatTbl.', 1;

    DECLARE @Fields TABLE (
        FieldName VARCHAR(128) NOT NULL PRIMARY KEY,
        CaptionVN NVARCHAR(255) NOT NULL,
        FormatID VARCHAR(20) NOT NULL
    );

    INSERT INTO @Fields (FieldName, CaptionVN, FormatID)
    VALUES
        ('Sohopdong', N'Số hợp đồng', 't'),
        ('Sobiennhan', N'Số biên nhận', 't'),
        ('Makh', N'Mã khách hàng', 't'),
        ('KhachHang', N'Khách hàng', 't'),
        ('TenKhachHang', N'Tên khách hàng', 't'),
        ('NgayToChuc', N'Ngày tổ chức', 'D'),
        ('NgayToChucFormat', N'Ngày tổ chức hiển thị', 't'),
        ('TongTien', N'Tổng tiền', 'N0'),
        ('TrangThai', N'Trạng thái', 't'),
        ('SanhDat', N'Sảnh đặt', 't'),
        ('MaPhieu', N'Mã phiếu', 't'),
        ('DocumentID', N'Mã phiếu', 't'),
        ('DienThoai', N'Điện thoại', 't'),
        ('CCCD', N'Số CCCD/CMND', 't'),
        ('NgayDuKien', N'Ngày dự kiến', 'D'),
        ('NgayAmLich', N'Ngày âm lịch', 't'),
        ('GoiThucDonID', N'Mã gói thực đơn', 't'),
        ('GoiTiec', N'Gói tiệc', 't'),
        ('Loaitiecid', N'Loại hình tiệc', 't'),
        ('Thoigianid', N'Ca đãi tiệc', 't'),
        ('SobanMan', N'Số bàn mặn', 'N0'),
        ('SobanChay', N'Số bàn chay', 'N0'),
        ('Ghichu', N'Ghi chú', 't'),
        ('DocumentDate', N'Ngày lập', 'D'),
        ('Tenchure', N'Tên chú rể', 't'),
        ('Tencodau', N'Tên cô dâu', 't'),
        ('DTchure', N'Điện thoại chú rể', 't'),
        ('DTcodau', N'Điện thoại cô dâu', 't'),
        ('Diachi', N'Địa chỉ', 't'),
        ('Mail', N'Email', 't'),
        ('Nguoigd', N'Người đại diện', 't'),
        ('DienThoaiDaiDien', N'Điện thoại đại diện', 't'),
        ('SanhTiec', N'Sảnh tiệc', 't'),
        ('SanhTiecID', N'Mã sảnh tiệc', 't');

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT c.name
            FROM sys.columns c
            WHERE c.object_id = OBJECT_ID(N'dbo.v_DanhSachBaoGia', N'V')
            UNION ALL
            SELECT c.name
            FROM sys.columns c
            WHERE c.object_id = OBJECT_ID(N'dbo.v_DanhSachKhachThamQuan', N'V')
        ) modelColumn
        WHERE NOT EXISTS (SELECT 1 FROM @Fields expected WHERE expected.FieldName = modelColumn.name)
    )
        THROW 51072, 'A custom read-model column has no explicit dictionary definition.', 1;

    UPDATE fieldDictionary
    SET CaptionVN = expected.CaptionVN,
        FormatID = expected.FormatID
    FROM dbo.SY_FmtFldTbl fieldDictionary
    INNER JOIN @Fields expected ON expected.FieldName = fieldDictionary.FieldName;

    INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
    SELECT 'v_DanhSachBaoGia', expected.FieldName, expected.CaptionVN, expected.FormatID
    FROM @Fields expected
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.SY_FmtFldTbl fieldDictionary WHERE fieldDictionary.FieldName = expected.FieldName
    );

    /* The quotation read model exposes these values for its API contract, not
       as duplicate columns in the shared grid. */
    UPDATE dbo.SY_FrmDrdwTbl
    SET isInvisible = 1
    WHERE FormID = 'v_DanhSachBaoGia'
      AND NULLIF(LTRIM(RTRIM(GridName)), '') IS NULL
      AND ColumnID IN ('KhachHang', 'NgayToChucFormat');

    INSERT INTO dbo.SY_FrmDrdwTbl (UserAutoID, FormID, ColumnID, isInvisible)
    SELECT LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')),
           'v_DanhSachBaoGia', control.ColumnID, 1
    FROM (VALUES ('KhachHang'), ('NgayToChucFormat')) control(ColumnID)
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.SY_FrmDrdwTbl configured
        WHERE configured.FormID = 'v_DanhSachBaoGia'
          AND NULLIF(LTRIM(RTRIM(configured.GridName)), '') IS NULL
          AND configured.ColumnID = control.ColumnID
    );

    IF EXISTS (
        SELECT 1
        FROM @Fields expected
        LEFT JOIN dbo.SY_FmtFldTbl fieldDictionary ON fieldDictionary.FieldName = expected.FieldName
        LEFT JOIN dbo.SY_FmatTbl fm ON fm.FormatID = fieldDictionary.FormatID
        WHERE NULLIF(LTRIM(RTRIM(fieldDictionary.CaptionVN)), '') IS NULL
           OR fm.FormatID IS NULL
    )
        THROW 51073, 'Custom read-model metadata is incomplete after update.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
