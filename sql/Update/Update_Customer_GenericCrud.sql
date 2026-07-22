USE [QLTiec]
GO

/*
  The /customers route uses DynamicFormEngine and therefore must point to a
  physical table. frmKhachHang is a legacy UI alias; dmkhachhang is the
  customer CRUD table. The reporting view v_DanhSachKhachHang remains for
  specialised reports only.
*/
SET XACT_ABORT ON
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.dmkhachhang', N'U') IS NULL
        THROW 51050, 'The customer CRUD table dbo.dmkhachhang does not exist.', 1;

    IF (
        SELECT COUNT(*)
        FROM sys.indexes i
        INNER JOIN sys.index_columns ic
          ON ic.object_id = i.object_id
         AND ic.index_id = i.index_id
        WHERE i.object_id = OBJECT_ID(N'dbo.dmkhachhang', N'U')
          AND i.is_primary_key = 1
    ) <> 1
        THROW 51051, 'dbo.dmkhachhang requires exactly one primary-key column for generic CRUD.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.WA_Menu WHERE MenuID = '0510')
        THROW 51052, 'WA_Menu entry 0510 (customers) does not exist.', 1;

    UPDATE dbo.WA_Menu
    SET FormName = 'dmkhachhang'
    WHERE MenuID = '0510';

    -- Update or insert CCCD label in global dictionary
    IF EXISTS (SELECT 1 FROM dbo.SY_FmtFldTbl WHERE FieldName = 'CMNDDaiDien')
    BEGIN
        UPDATE dbo.SY_FmtFldTbl
        SET CaptionVN = N'Số CCCD'
        WHERE FieldName = 'CMNDDaiDien';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID)
        VALUES ('dmkhachhang', 'CMNDDaiDien', N'Số CCCD', 't');
    END

    -- Configure allowed fields for dmkhachhang in SY_FrmLstTbl to hide:
    -- - Makh (id/mã khách hàng)
    -- - Fax (fax)
    -- - IsTinhcongno (tính công nợ)
    -- - KhuvucID (khu vực)
    -- - Masothue (mã số thuế)
    -- - NhomkhID, Ngaysinhcodau, Ngaysinhchure (bỏ 3 cột này khỏi grid)
    -- - Và thêm CMNDDaiDien (Số CCCD) vào grid và forms
    UPDATE dbo.SY_FrmLstTbl
    SET PrimaryKey = 'Makh',
        HideColumnArr = 'IsDeleted;DeletedAt;DeletedBy;Makh;Masothue;Fax;KhuvucID;IsTinhcongno;IsNCC;IsNhanvien;DateCreate;DateUpdate;UserCreate;UserUpdate;TheVIP;Ghichu;IsMacdinh;CMNDchure;CMNDcodau;CMNDnguoidd;Noilamviec;IsDiachiChuRe;IsMailChuRe;ChucVu;TenCty;DiaChiCty;NguoiLienHeHoaDon;DienThoaiHoaDon;NgayCap;NoiCap;NgayDeLaiThongTin;NguoiPhuTrachID;TinhTrangKhachHang;LoaiTiecID;MakhChamSoc;IsGioiTinhNguoidd;MakhKT;isOngBaDaiDien;DienThoaiDaiDien;SoTaiKhoan;TaiNganHang;BranchID;IsKhachhang;NhomkhID;Ngaysinhcodau;Ngaysinhchure',
        AddNewColumnArr = 'Tenkh;Tencodau;Tenchure;Diachi;Nguoigd;Dienthoai;Mail;NhomkhID;CMNDDaiDien;IsKhachhang',
        EditorColumnArr = 'Tenkh;Tencodau;Tenchure;Diachi;Nguoigd;Dienthoai;Mail;NhomkhID;CMNDDaiDien;IsKhachhang'
    WHERE TableName = 'dmkhachhang' OR FormID = 'dmkhachhang';

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.SY_FrmLstTbl (FormID, FormType, CaptionVN, TableName, PrimaryKey, HideColumnArr, AddNewColumnArr, EditorColumnArr)
        VALUES ('dmkhachhang', 'Grid', N'Danh mục Khách hàng', 'dmkhachhang', 'Makh',
                'IsDeleted;DeletedAt;DeletedBy;Makh;Masothue;Fax;KhuvucID;IsTinhcongno;IsNCC;IsNhanvien;DateCreate;DateUpdate;UserCreate;UserUpdate;TheVIP;Ghichu;IsMacdinh;CMNDchure;CMNDcodau;CMNDnguoidd;Noilamviec;IsDiachiChuRe;IsMailChuRe;ChucVu;TenCty;DiaChiCty;NguoiLienHeHoaDon;DienThoaiHoaDon;NgayCap;NoiCap;NgayDeLaiThongTin;NguoiPhuTrachID;TinhTrangKhachHang;LoaiTiecID;MakhChamSoc;IsGioiTinhNguoidd;MakhKT;isOngBaDaiDien;DienThoaiDaiDien;SoTaiKhoan;TaiNganHang;BranchID;IsKhachhang;NhomkhID;Ngaysinhcodau;Ngaysinhchure',
                'Tenkh;Tencodau;Tenchure;Diachi;Nguoigd;Dienthoai;Mail;NhomkhID;CMNDDaiDien;IsKhachhang',
                'Tenkh;Tencodau;Tenchure;Diachi;Nguoigd;Dienthoai;Mail;NhomkhID;CMNDDaiDien;IsKhachhang');
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
