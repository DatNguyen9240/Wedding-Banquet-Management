USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== TRIỂN KHAI MODULE BÁO GIÁ (frmBaoGia) ===';
GO

-- Yêu cầu: đã chạy sql/Functions/fn_DOCX_MenuDichVu.sql
IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachDichVu', N'FN') IS NULL
BEGIN
    RAISERROR(N'Chưa có fn_DOCX_DanhSachDichVu. Hãy chạy sql/Functions/fn_DOCX_MenuDichVu.sql trước.', 16, 1);
END
GO

-- =========================================================================
-- 1. STORED PROCEDURE API_DanhSachBaoGia
-- =========================================================================
PRINT N'1. Đang tạo API_DanhSachBaoGia...';
GO

IF OBJECT_ID('API_DanhSachBaoGia', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachBaoGia;
GO

CREATE PROCEDURE [dbo].[API_DanhSachBaoGia]
    @Keyword    NVARCHAR(250) = NULL,
    @Sohopdong  VARCHAR(50)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Keyword = '' SET @Keyword = NULL;
    IF @Sohopdong = '' SET @Sohopdong = NULL;

    SELECT
        h.Sohopdong AS [Id],
        h.Sohopdong,
        h.Sobiennhan,
        h.Makh,

        CASE
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [KhachHang],
        CASE
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [TenKhachHang],

        h.Ngaytochuc AS [NgayToChuc],
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS [NgayToChucFormat],
        ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
        CASE
            WHEN h.IsHuy = 1 THEN N'Đã Hủy'
            WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
            ELSE N'Đang xử lý'
        END AS [TrangThai],

        STUFF((
            SELECT N', ' + s.Tensanhtiec
            FROM tbmk_Hopdongsanhtiec hs
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhDat],

        ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), N'') AS [LoaiHinhSuKien],

        CONVERT(VARCHAR(10), ISNULL(h.Ngayhopdong, GETDATE()), 103) AS [NgayBaoGia],
        RIGHT('0' + CAST(DAY(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR), 2) AS [NgayBaoGiaDay],
        RIGHT('0' + CAST(MONTH(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR), 2) AS [ThangBaoGia],
        CAST(YEAR(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR) AS [NamBaoGia],

        FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongCongTamTinh],
        [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongCongTamTinhBangChu],
        ISNULL(NULLIF(h.Ghichu, ''), N'') AS [LuuYChung],

        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenASDT') AS [BenASDT],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail') AS [BenAEmail],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail') AS [BenAEmailNhanVien],
        ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = h.Manv), ISNULL(h.UserCreate, h.Manv)) AS [BenANhanVienPhuTrach],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'Com3') AS [BenASDTNhanVien],

        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
        ISNULL(k.Diachi, N'...') AS [BenBDiaChi],
        ISNULL(NULLIF(h.TenCtyHoaDon, ''), ISNULL(k.Tenkh, N'')) AS [HDTenCty],

        ISNULL((
            SELECT TOP 1 NULLIF(hs.Ghichuct, '')
            FROM tbmk_Hopdongsanhtiec hs
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        ), N'') AS [GhiChuSanh1],
        ISNULL((
            SELECT Ghichuct FROM (
                SELECT hs.Ghichuct, ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS rn
                FROM tbmk_Hopdongsanhtiec hs
                WHERE hs.Sohopdong = h.Sohopdong
            ) x WHERE x.rn = 2
        ), N'') AS [GhiChuSanh2],
        ISNULL((
            SELECT Ghichuct FROM (
                SELECT hs.Ghichuct, ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS rn
                FROM tbmk_Hopdongsanhtiec hs
                WHERE hs.Sohopdong = h.Sohopdong
            ) x WHERE x.rn = 3
        ), N'') AS [GhiChuSanh3],

        dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong) AS [DanhSachDichVu],

        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS [STT],
                s.Tensanhtiec AS [TenKhuVuc],
                s.Tensanhtiec AS [TenSanh],
                ISNULL(CAST(s.SLBanMin AS NVARCHAR), N'0') AS [SoBanMin],
                ISNULL(CAST(s.SLBanMax AS NVARCHAR), N'0') AS [SoBanMax],
                ISNULL(CAST(s.SLBanMin * 10 AS NVARCHAR), N'0') AS [SucchuaMin],
                ISNULL(CAST(s.SLBanMax * 10 AS NVARCHAR), N'0') AS [SucchuaMax],
                ISNULL(hs.Ghichuct, N'') AS [GhiChu]
            FROM tbmk_Hopdongsanhtiec hs
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
            FOR JSON PATH
        ) AS [DanhSachKhuVuc],

        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY src.sort_order, src.TenHang) AS [STT],
                src.TenHang AS [NoiDung],
                FORMAT(ISNULL(src.Dongia, 0), 'N0', 'vi-VN') AS [DonGia]
            FROM (
                SELECT ISNULL(hh.Tenhang, td.Mahang) AS TenHang, td.Dongia, 1 AS sort_order
                FROM tbmk_Hopdongthucdonman td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = h.Sohopdong
                UNION ALL
                SELECT ISNULL(hh.Tenhang, tu.Mahang), tu.Dongia, 2
                FROM tbmk_Hopdongthucuong tu
                LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
                WHERE tu.Sohopdong = h.Sohopdong
                UNION ALL
                SELECT ISNULL(hh.Tenhang, dv.Mahang), dv.Dongia, 3
                FROM tbmk_Hopdongdichvu dv
                LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
                WHERE dv.Sohopdong = h.Sohopdong
            ) src
            FOR JSON PATH
        ) AS [DanhSachThamKhao]

    FROM tbmk_Hopdong h
    LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
    WHERE ISNULL(h.IsDeleted, 0) = 0
      AND (@Sohopdong IS NULL OR h.Sohopdong = @Sohopdong)
      AND (@Keyword IS NULL OR
           h.Sohopdong LIKE '%' + @Keyword + '%' OR
           k.Tenkh LIKE N'%' + @Keyword + '%' OR
           k.Tenchure LIKE N'%' + @Keyword + '%' OR
           k.Tencodau LIKE N'%' + @Keyword + '%')
    ORDER BY h.Ngaytochuc DESC, h.Sohopdong DESC;
END
GO

-- =========================================================================
-- 2. SY_FrmLstTbl + WA_API
-- =========================================================================
PRINT N'2. Đang đồng bộ SY_FrmLstTbl và WA_API cho frmBaoGia...';
GO

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmBaoGia')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('frmBaoGia', N'Báo Giá Dịch Vụ', 'API_DanhSachBaoGia', 'tbmk_Hopdong', 'Sohopdong');
ELSE
    UPDATE SY_FrmLstTbl
    SET CaptionVN = N'Báo Giá Dịch Vụ',
        TableName = 'API_DanhSachBaoGia',
        SaveTableName = 'tbmk_Hopdong',
        PrimaryKey = 'Sohopdong'
    WHERE FormID = 'frmBaoGia';
GO

DELETE FROM WA_API WHERE List = 'frmBaoGia' AND Func IN ('View', 'Save');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBaoGia',
    'View',
    'API_DanhSachBaoGia',
    '@Keyword=N''{Keyword}'', @Sohopdong=N''{Sohopdong}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBaoGia',
    'Save',
    'API_LuuDong',
    '@List=N''frmBaoGia'', @Data=N''{JsonData}'''
);
GO

-- =========================================================================
-- 3. Đồng bộ cột từ SP → SY_FormatFields (chạy trước để có đủ field)
-- =========================================================================
PRINT N'3. Đang đồng bộ SY_FormatFields cho frmBaoGia...';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmBaoGia', @ObjectName = 'API_DanhSachBaoGia';
GO

-- =========================================================================
-- 4. Nhãn tiếng Việt có dấu (ghi đè CaptionVN = tên cột từ DongBo)
-- =========================================================================
PRINT N'4. Đang cập nhật nhãn tiếng Việt...';
GO

UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng'       WHERE FormName = 'frmBaoGia' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận'       WHERE FormName = 'frmBaoGia' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã khách hàng'      WHERE FormName = 'frmBaoGia' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Khách hàng'         WHERE FormName = 'frmBaoGia' AND FieldName = 'KhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng'     WHERE FormName = 'frmBaoGia' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức'       WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức'       WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayToChucFormat';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh tiệc'          WHERE FormName = 'frmBaoGia' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Loại hình sự kiện'  WHERE FormName = 'frmBaoGia' AND FieldName = 'LoaiHinhSuKien';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền'          WHERE FormName = 'frmBaoGia' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái'         WHERE FormName = 'frmBaoGia' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày báo giá'      WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayBaoGia';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày báo giá'      WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayBaoGiaDay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng báo giá'     WHERE FormName = 'frmBaoGia' AND FieldName = 'ThangBaoGia';
UPDATE SY_FormatFields SET CaptionVN = N'Năm báo giá'       WHERE FormName = 'frmBaoGia' AND FieldName = 'NamBaoGia';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng cộng tạm tính' WHERE FormName = 'frmBaoGia' AND FieldName = 'TongCongTamTinh';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng cộng (chữ)'  WHERE FormName = 'frmBaoGia' AND FieldName = 'TongCongTamTinhBangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Lưu ý chung'      WHERE FormName = 'frmBaoGia' AND FieldName = 'LuuYChung';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú sảnh 1'   WHERE FormName = 'frmBaoGia' AND FieldName = 'GhiChuSanh1';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú sảnh 2'   WHERE FormName = 'frmBaoGia' AND FieldName = 'GhiChuSanh2';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú sảnh 3'   WHERE FormName = 'frmBaoGia' AND FieldName = 'GhiChuSanh3';
UPDATE SY_FormatFields SET CaptionVN = N'Tên công ty (Bên A)' WHERE FormName = 'frmBaoGia' AND FieldName = 'BenATenCongTy';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ (Bên A)'  WHERE FormName = 'frmBaoGia' AND FieldName = 'BenADiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại (Bên A)' WHERE FormName = 'frmBaoGia' AND FieldName = 'BenASDT';
UPDATE SY_FormatFields SET CaptionVN = N'Email (Bên A)'      WHERE FormName = 'frmBaoGia' AND FieldName = 'BenAEmail';
UPDATE SY_FormatFields SET CaptionVN = N'Email nhân viên'    WHERE FormName = 'frmBaoGia' AND FieldName = 'BenAEmailNhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmBaoGia' AND FieldName = 'BenANhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên'      WHERE FormName = 'frmBaoGia' AND FieldName = 'BenASDTNhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại (Bên B)' WHERE FormName = 'frmBaoGia' AND FieldName = 'BenBDienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ (Bên B)'   WHERE FormName = 'frmBaoGia' AND FieldName = 'BenBDiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'Tên công ty HĐ'   WHERE FormName = 'frmBaoGia' AND FieldName = 'HDTenCty';
UPDATE SY_FormatFields SET CaptionVN = N'Danh sách dịch vụ' WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachDichVu';
UPDATE SY_FormatFields SET CaptionVN = N'Danh sách khu vực' WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachKhuVuc';
UPDATE SY_FormatFields SET CaptionVN = N'Thực đơn & DV tham khảo' WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachThamKhao';
GO

-- =========================================================================
-- 5. Cấu hình hiển thị lưới JSON (FormatID = js) trên form xem/sửa
-- =========================================================================
PRINT N'5. Đang cấu hình hiển thị JSON...';
GO

DECLARE @DS_DichVu NVARCHAR(MAX) = N'[{"key":"STT","label":"STT","type":"number","width":"50px"},{"key":"DienGiai","label":"Diễn giải","type":"text","width":"auto"},{"key":"DVT","label":"ĐVT","type":"text","width":"70px"},{"key":"SoLuong","label":"Số lượng","type":"text","width":"90px"},{"key":"DonGia","label":"Đơn giá","type":"text","width":"110px"},{"key":"ThanhTien","label":"Thành tiền","type":"text","width":"110px"}]';
DECLARE @DS_KhuVuc NVARCHAR(MAX) = N'[{"key":"STT","label":"STT","type":"number","width":"50px"},{"key":"TenKhuVuc","label":"Khu vực / Sảnh","type":"text","width":"auto"},{"key":"SoBanMin","label":"Bàn tối thiểu","type":"text","width":"90px"},{"key":"SoBanMax","label":"Bàn tối đa","type":"text","width":"90px"},{"key":"SucchuaMin","label":"Sức chứa min","type":"text","width":"100px"},{"key":"SucchuaMax","label":"Sức chứa max","type":"text","width":"100px"},{"key":"GhiChu","label":"Ghi chú","type":"text","width":"150px"}]';
DECLARE @DS_ThamKhao NVARCHAR(MAX) = N'[{"key":"STT","label":"STT","type":"number","width":"50px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"},{"key":"DonGia","label":"Đơn giá","type":"text","width":"120px"}]';

UPDATE SY_FormatFields SET
    CaptionVN = N'Danh sách dịch vụ', FormatID = 'js', DataSource = @DS_DichVu,
    FormPosition = '12', OrderNo = 30,
    ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1, ShowInFilter = 0,
    IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachDichVu';

UPDATE SY_FormatFields SET
    CaptionVN = N'Danh sách khu vực', FormatID = 'js', DataSource = @DS_KhuVuc,
    FormPosition = '12', OrderNo = 31,
    ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1, ShowInFilter = 0,
    IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachKhuVuc';

UPDATE SY_FormatFields SET
    CaptionVN = N'Thực đơn & DV tham khảo', FormatID = 'js', DataSource = @DS_ThamKhao,
    FormPosition = '12', OrderNo = 32,
    ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1, ShowInFilter = 0,
    IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBaoGia' AND FieldName = 'DanhSachThamKhao';
GO

-- Ghi chú sảnh: textarea chỉ đọc
UPDATE SY_FormatFields SET
    FormatID = 'ta', FormPosition = '12',
    ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1,
    IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, ShowInFilter = 0
WHERE FormName = 'frmBaoGia' AND FieldName IN ('GhiChuSanh1', 'GhiChuSanh2', 'GhiChuSanh3');
GO

-- Lưới chính + form cơ bản
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 1  WHERE FormName = 'frmBaoGia' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 1, OrderNo = 2  WHERE FormName = 'frmBaoGia' AND FieldName = 'KhachHang';
UPDATE SY_FormatFields SET FormatID = 'dt', FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 3  WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 4  WHERE FormName = 'frmBaoGia' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 5  WHERE FormName = 'frmBaoGia' AND FieldName = 'LoaiHinhSuKien';
UPDATE SY_FormatFields SET FormatID = 'n',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 6, IsReadOnlyEdit = 1 WHERE FormName = 'frmBaoGia' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 1, OrderNo = 7  WHERE FormName = 'frmBaoGia' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET FormatID = 'dt', FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 8  WHERE FormName = 'frmBaoGia' AND FieldName = 'NgayBaoGia';
UPDATE SY_FormatFields SET FormatID = 'ta', FormPosition = '12', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 20 WHERE FormName = 'frmBaoGia' AND FieldName = 'LuuYChung';
UPDATE SY_FormatFields SET FormatID = 't',  FormPosition = '6', ShowInForm = 1, ShowInAdd = 0, ShowInEdit = 1, ShowInFilter = 0, OrderNo = 9, IsReadOnlyEdit = 1 WHERE FormName = 'frmBaoGia' AND FieldName = 'TongCongTamTinh';
GO

-- Ẩn cột trùng / chỉ dùng in Word
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmBaoGia'
  AND FieldName IN (
    'Id', 'Makh', 'Sobiennhan', 'TenKhachHang', 'NgayToChucFormat',
    'NgayBaoGiaDay', 'ThangBaoGia', 'NamBaoGia', 'TongCongTamTinhBangChu',
    'BenATenCongTy', 'BenADiaChi', 'BenASDT', 'BenAEmail', 'BenAEmailNhanVien',
    'BenANhanVienPhuTrach', 'BenASDTNhanVien', 'BenBDienThoai', 'BenBDiaChi', 'HDTenCty'
  );
GO

PRINT N'=== HOÀN THÀNH MODULE BÁO GIÁ ===';
GO
