USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT CSDL CHO PHÂN HỆ CL ===';
GO

-- =========================================================================
-- 1. THÊM CỘT CHO BẢNG DANH MỤC LOẠI HÌNH TIỆC (DinhBienCL)
-- =========================================================================
PRINT N'1. Đang kiểm tra và thêm cột DinhBienCL cho bảng dmLoaihinhtiec...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dmLoaihinhtiec') AND name = 'DinhBienCL')
BEGIN
    ALTER TABLE dmLoaihinhtiec ADD DinhBienCL DECIMAL(5, 2) NULL;
    PRINT N'  + Đã thêm cột DinhBienCL vào dmLoaihinhtiec';
END
ELSE
BEGIN
    PRINT N'  + Cột DinhBienCL đã tồn tại trong dmLoaihinhtiec';
END
GO

-- =========================================================================
-- 2. THÊM CÁC CỘT QUẢN LÝ CL CHO BẢNG HỢP ĐỒNG (tbmk_Hopdong)
-- =========================================================================
PRINT N'2. Đang kiểm tra và thêm các cột CL cho bảng tbmk_Hopdong...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'DinhBienCL')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD DinhBienCL DECIMAL(5, 2) NULL;
    PRINT N'  + Đã thêm cột DinhBienCL vào tbmk_Hopdong';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'SoNVPhanCong')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD SoNVPhanCong INT NULL;
    PRINT N'  + Đã thêm cột SoNVPhanCong vào tbmk_Hopdong';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'CLDeXuat')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD CLDeXuat INT NULL;
    PRINT N'  + Đã thêm cột CLDeXuat vào tbmk_Hopdong';
END

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'CLThucTe')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD CLThucTe INT NULL;
    PRINT N'  + Đã thêm cột CLThucTe vào tbmk_Hopdong';
END
GO

-- =========================================================================
-- 3. THIẾT LẬP ĐỊNH BIÊN MẶC ĐỊNH CHO CÁC LOẠI TIỆC
-- =========================================================================
PRINT N'3. Thiết lập định biên mặc định...';
GO

UPDATE dmLoaihinhtiec SET DinhBienCL = 0.25 WHERE Tenloaitiec LIKE N'%Cưới%' AND DinhBienCL IS NULL;
UPDATE dmLoaihinhtiec SET DinhBienCL = 0.15 WHERE (Tenloaitiec LIKE N'%Hội Nghị%' OR Tenloaitiec LIKE N'%Triển Lãm%') AND DinhBienCL IS NULL;
UPDATE dmLoaihinhtiec SET DinhBienCL = 0.20 WHERE DinhBienCL IS NULL;
GO

-- =========================================================================
-- 4. ĐĂNG KÝ HỆ THỐNG MẪU BIỂU (SY_FrmLstTbl & SY_FormatFields)
-- =========================================================================
PRINT N'4. Đồng bộ SY_FrmLstTbl và SY_FormatFields...';
GO

-- Đăng ký dmLoaihinhtiec để có thể dùng API_LuuDong sửa cấu hình
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'dmLoaihinhtiec')
BEGIN
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('dmLoaihinhtiec', N'Định biên CL theo Loại hình tiệc', 'dmLoaihinhtiec', 'dmLoaihinhtiec', 'Loaitiecid');
    PRINT N'  + Đã đăng ký dmLoaihinhtiec vào SY_FrmLstTbl';
END
GO

-- Đăng ký API Save cho dmLoaihinhtiec vào bảng định tuyến WA_API
IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'WA_API') AND type in (N'U'))
BEGIN
    DELETE FROM WA_API WHERE List = 'dmLoaihinhtiec' AND Func = 'Save';
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('dmLoaihinhtiec', 'Save', 'API_LuuDong', '@List=N''dmLoaihinhtiec'', @Data=N''{JsonData}''');
    PRINT N'  + Đã đăng ký API Save cho dmLoaihinhtiec vào WA_API';
END
-- Đăng ký các trường cho dmLoaihinhtiec vào SY_FormatFields
DELETE FROM SY_FormatFields WHERE FormName = 'dmLoaihinhtiec';
GO
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, IsRequired)
VALUES
('dmLoaihinhtiec', 'Loaitiecid',   N'Mã Loại Tiệc',       't',  '6',  1,  1, 1, 0, 1, 1),
('dmLoaihinhtiec', 'Tenloaitiec',   N'Tên Loại Tiệc',       't',  '6',  2,  1, 1, 0, 0, 1),
('dmLoaihinhtiec', 'DinhBienCL',     N'Định Biên CL',       'n',  '6',  3,  1, 1, 0, 0, 0);
PRINT N'  + Đã đăng ký các trường của dmLoaihinhtiec vào SY_FormatFields';
GO


-- Đăng ký 4 cột mới vào phiếu BEO (frmBEO) trong SY_FormatFields
DELETE FROM SY_FormatFields WHERE FormName = 'frmBEO' AND FieldName IN ('DinhBienCL', 'SoNVPhanCong', 'CLDeXuat', 'CLThucTe');
GO

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, IsRequired)
VALUES
('frmBEO', 'DinhBienCL',     N'Định Biên CL',       'n',  '3',  14,  1, 1, 1, 1, 0),
('frmBEO', 'SoNVPhanCong',   N'Số NV Phân Công',    'n',  '3',  15,  1, 1, 0, 0, 0),
('frmBEO', 'CLDeXuat',       N'CL Đề Xuất',         'n',  '3',  16,  1, 1, 1, 1, 0),
('frmBEO', 'CLThucTe',       N'CL Thực Tế',         'n',  '3',  17,  1, 1, 0, 0, 0);
PRINT N'  + Đã đăng ký các cột CL vào SY_FormatFields của frmBEO (kích thước 3/12)';
GO

-- =========================================================================
-- 5. CẬP NHẬT CÁC STORED PROCEDURE
-- =========================================================================
PRINT N'5. Đang cập nhật Stored Procedures...';
GO

-- 5.1 Cập nhật API_DanhSachLoaiHinhTiec
IF OBJECT_ID('API_DanhSachLoaiHinhTiec', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachLoaiHinhTiec;
GO

CREATE PROCEDURE [dbo].[API_DanhSachLoaiHinhTiec]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        Loaitiecid AS [Mã loại],
        Tenloaitiec AS [Loại hình tiệc],
        DinhBienCL AS [Định biên]
    FROM dmLoaihinhtiec
    ORDER BY Tenloaitiec ASC;
END
GO
PRINT N'  + Đã cập nhật Stored Procedure: API_DanhSachLoaiHinhTiec';
GO

-- 5.2 Cập nhật API_DanhSachBEO để trả về thêm các cột CL
IF OBJECT_ID('API_DanhSachBEO', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachBEO;
GO

CREATE PROCEDURE [dbo].[API_DanhSachBEO]
    @Keyword    NVARCHAR(250) = NULL,
    @Sohopdong  VARCHAR(50)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Keyword = '' SET @Keyword = NULL;
    IF @Sohopdong = '' SET @Sohopdong = NULL;

    SELECT
        -- ── Khóa chính & nhận diện ──────────────────────────────────────
        h.Sohopdong,
        h.Sobiennhan,
        h.Makh,
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [KhachHang],

        -- ── Thông tin xuất BEO ──────────────────────────────────────────
        CONVERT(VARCHAR(10), ISNULL(h.NgayRaBEO, h.Ngayhopdong), 103)          AS [NgayRaBEO],
        RIGHT('0' + CAST(DAY  (ISNULL(h.NgayRaBEO, h.Ngayhopdong)) AS VARCHAR), 2) AS [NgayRaBEODay],
        RIGHT('0' + CAST(MONTH(ISNULL(h.NgayRaBEO, h.Ngayhopdong)) AS VARCHAR), 2) AS [ThangRaBEO],
        CAST(YEAR(ISNULL(h.NgayRaBEO, h.Ngayhopdong)) AS VARCHAR)                  AS [NamRaBEO],

        -- ── Tiêu đề phiếu (computed: Loại hình + Tên sảnh) ──────────────
        ISNULL((
            SELECT TOP 1
                CASE
                    WHEN CHARINDEX('+', lt.Tenloaitiec) > 0
                        THEN RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, 1, CHARINDEX('+', lt.Tenloaitiec) - 1)))
                             + ' ' + (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC)
                             + ' + '
                             + RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, CHARINDEX('+', lt.Tenloaitiec) + 1, LEN(lt.Tenloaitiec))))
                             + ' ' + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 0 ORDER BY hs.Sanhtiecid), '')
                    ELSE lt.Tenloaitiec + ' ' + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '')
                END
            FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid
        ), N'TIỆC CƯỚI')                                        AS [TieuDePhieu],

        -- ── Sảnh tiệc ───────────────────────────────────────────────────
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [TenSanhTiec],
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [SanhDat],
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [Sanh],

        -- DanhSachSanh: mảng JSON để template dùng vòng lặp {#DanhSachSanh}...{/DanhSachSanh}
        (
            SELECT
                s.Tensanhtiec                           AS [SanhDat],
                s.Tensanhtiec                           AS [Sanh],
                ISNULL(h.SoKhachChinhThuc, 0)          AS [SoKhachChinhThuc],
                ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [SoBanDuPhong],
                ISNULL(h.KieuSetup, N'Tiệc ngồi')      AS [KieuSetup]
            FROM tbmk_Hopdongsanhtiec hs
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC
            FOR JSON PATH
        ) AS [DanhSachSanh],

        -- ── Thời gian tổ chức ───────────────────────────────────────────
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103)                 AS [NgayToChuc],
        RIGHT('0' + CAST(DAY  (h.Ngaytochuc) AS VARCHAR), 2)   AS [NgayToChucDay],
        RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2)   AS [ThangToChuc],
        CAST(YEAR(h.Ngaytochuc) AS VARCHAR)                     AS [NamToChuc],
        h.GioDienRaSuKien                                       AS [GioDienRaSuKien],
        h.GioKetThucSuKien                                      AS [GioKetThucSuKien],
        ISNULL(h.GioDienRaSuKien, N'...')                       AS [GioBatDau],
        ISNULL(h.GioKetThucSuKien, N'...')                      AS [GioKetThuc],
        ISNULL(h.GioDienRaSuKien, N'...')                       AS [BatDau],
        ISNULL(h.GioKetThucSuKien, N'...')                      AS [KetThuc],
        -- TenCa: lấy từ dmThoigian qua Thoigianid
        ISNULL((SELECT TOP 1 c.Thoigian FROM dmThoigian c WHERE c.Thoigianid = h.Thoigianid), N'') AS [TenCa],

        -- ── Loại hình & số lượng ─────────────────────────────────────────
        h.Loaitiecid                                            AS [Loaitiecid],
        ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSuKien],
        h.SoKhachChinhThuc                                      AS [SoKhachChinhThuc],
        ISNULL(h.KieuSetup, N'Tiệc ngồi')                      AS [KieuSetup],

        -- ── Số bàn ──────────────────────────────────────────────────────
        ISNULL(h.SobanManchinhthuc, 0) AS [SobanManchinhthuc],
        ISNULL(h.SobanManduphong, 0)   AS [SobanManduphong],
        ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [SoBanChinhThuc],
        ISNULL(h.SoNguoiTrenBan, 10)   AS [SoKhachTrenBan],

        -- ── Casual Labor (CL) Fields ──────────────────────────────────────
        h.DinhBienCL,
        h.SoNVPhanCong,
        h.CLDeXuat,
        h.CLThucTe,

        -- ── Thông tin Bên A (từ SY_Setup) ──────────────────────────────────
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenADiaChi')    AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenASDT')       AS [BenASDT],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAMST')       AS [BenAMST],
        (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv) AS [BenANhanVienPhuTrach],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
        (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv) AS [BenASDTNhanVien],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail')     AS [BenAEmailNhanVien],

        -- ── Thông tin Bên B (Khách hàng) ──────────────────────────────────
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [BenBTenDaiDien],
        ISNULL(k.Diachi, N'...')         AS [BenBDiaChi],
        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
        ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
        ISNULL(k.Mail, N'...')           AS [BenBEmail],

        -- ── Thông tin bổ sung cho template BEO ──────────────────────────
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [BenBDaiDien],
        k.Tenchure AS [Tenchure],
        k.Tencodau AS [Tencodau],
        k.Tenchure AS [BieuNguCR],
        k.Tencodau AS [BieuNguCD],
        k.DTchure AS [Sdtchure],
        k.DTcodau AS [Sdtcodau],
        ISNULL(h.Tentiec, N'LỄ THÀNH HÔN') AS [TenLe],
        ISNULL(k.Diachi, N'...')         AS [BenBDiaChiTemplate],

        -- NgayHopDong
        ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), N'...') AS [NgayHopDong],

        -- NgaySetup
        ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, -1, h.Ngaytochuc), 103), N'...') AS [NgaySetup],

        -- DonViThiCong
        ISNULL(NULLIF(h.DonViThiCong, ''), N'') AS [DonViThiCong],

        -- TieuSuKhachHang
        ISNULL(NULLIF(h.TieuSuKhachHang, ''), N'') AS [TieuSuKhachHang],

        -- DichVuKhuyenMai
        ISNULL(NULLIF(h.DichVuKhuyenMai, ''), N'') AS [DoiTuongKhach],
        
        -- LuuY
        ISNULL(NULLIF(h.LuuY, ''), ISNULL(NULLIF(h.Ghichu, ''), N'')) AS [LuuY],

        -- HDTenCty
        ISNULL(NULLIF(h.TenCtyHoaDon, ''), ISNULL(k.Tenkh, N'')) AS [HDTenCty],

        ISNULL(k.TinhTrangKhachHang, N'Fanpage') AS [KieuSetupBEO],
        ISNULL(h.MauNo, N'Ghế trắng - Nơ hồng')   AS [SetupNoGhe],
        CAST(N'' AS NVARCHAR(100))               AS [AnNheTruocTiec],
        CAST(N'' AS NVARCHAR(100))               AS [BanhManDauGio],

        -- ── Tài chính cơ bản ─────────────────────────────────────────────
        FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
        [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
        FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + N' VNĐ' AS [Dot1SoTien],
        ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), N'...') AS [Dot1Ngay],

        -- ── Lịch trình & ghi chú nghiệp vụ (định dạng text sạch) ──────────
        ISNULL(
            STUFF(
                (SELECT N' | ' + ISNULL(t.BatDau, '...') + N' - ' + ISNULL(t.KetThuc, '...') + 
                        CASE WHEN ISNULL(t.Sanh, '') <> '' THEN N' (' + t.Sanh + N' - ' + ISNULL(t.NoiDung, '') + N')'
                             ELSE N' (' + ISNULL(t.NoiDung, '') + N')' END
                 FROM OPENJSON(h.JsonLichTrinh) WITH (
                     BatDau NVARCHAR(50) '$.BatDau',
                     KetThuc NVARCHAR(50) '$.KetThuc',
                     Sanh NVARCHAR(100) '$.Sanh',
                     NoiDung NVARCHAR(500) '$.NoiDung'
                 ) t
                 FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 3, N''
            ), N''
        ) AS [ChiTietLichTrinh],
        ISNULL(
            STUFF(
                (SELECT N' | ' + ISNULL(t.BatDau, '...') + N' - ' + ISNULL(t.KetThuc, '...') + 
                        CASE WHEN ISNULL(t.Sanh, '') <> '' THEN N' (' + t.Sanh + N' - ' + ISNULL(t.NoiDung, '') + N')'
                             ELSE N' (' + ISNULL(t.NoiDung, '') + N')' END
                 FROM OPENJSON(h.JsonLichTrinh) WITH (
                     BatDau NVARCHAR(50) '$.BatDau',
                     KetThuc NVARCHAR(50) '$.KetThuc',
                     Sanh NVARCHAR(100) '$.Sanh',
                     NoiDung NVARCHAR(500) '$.NoiDung'
                 ) t
                 FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 3, N''
            ), N''
        ) AS [LichTrinh],

        -- Lịch trình thanh toán
        ISNULL(
            STUFF(
                (SELECT N' | ' + CAST(t.STT AS NVARCHAR(5)) + N': ' + t.SoTien + N' (' + t.Ngay + N' - ' + t.NoiDung + N')'
                 FROM (
                     SELECT 
                         1 AS STT, 
                         FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS SoTien, 
                         ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS Ngay,
                         N'Đặt cọc giữ chỗ' AS NoiDung
                     WHERE ISNULL(h.Sotiencoccho, 0) > 0

                     UNION ALL

                     SELECT 
                         2 AS STT, 
                         FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ' AS SoTien, 
                         ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), '...') AS Ngay,
                         N'Đặt cọc ký hợp đồng' AS NoiDung
                     WHERE ISNULL(h.Sotiencochopdong, 0) > 0

                     UNION ALL

                     SELECT 
                         CASE WHEN ISNULL(h.Sotiencochopdong, 0) > 0 THEN 3 ELSE 2 END AS STT, 
                         N'Thanh toán còn lại' AS SoTien, 
                         ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '...') AS Ngay,
                         N'Thanh toán cuối tiệc.' AS NoiDung
                 ) t
                 ORDER BY t.STT
                 FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 3, N''
            ), N''
        ) AS [LichTrinhThanhToan],

        -- ── Ghi chú cho các bộ phận ──────────────────────────────────────
        ISNULL(NULLIF(h.ThongTinSetup, ''), N'Theo bản vẽ sơ đồ sảnh đính kèm') AS [ThongTinSetup],
        ISNULL(NULLIF(h.NoteBaoVe, ''),  N'Danh sách vào + ra hàng hóa (BÁO SAU)')  AS [NoteBaoVe],
        ISNULL(NULLIF(h.NoteBieuNgu, ''), N'Phối hợp với khách')                     AS [NoteBieuNgu],
        ISNULL(NULLIF(h.NoteKyThuat, ''), N'') AS [NoteKyThuat],
        ISNULL(NULLIF(h.NoteLobby, ''),
            N'Bàn Lễ Tân đón khách ' + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), N'...')
        ) AS [NoteLobby],

        -- ── Trạng thái ───────────────────────────────────────────────────
        h.Status,
        h.IsKetthuc,
        h.Manv,

        -- ── Menu / dịch vụ ───────────────────────────────────────────────
        dbo.fn_DOCX_DanhSachMenu(h.Sohopdong)     AS [DanhSachMenu],
        dbo.fn_DOCX_DanhSachThucUong(h.Sohopdong) AS [DanhSachThucUong],
        dbo.fn_DOCX_DichVuTinhPhi(h.Sohopdong)    AS [DichVuTinhPhi],
        dbo.fn_DOCX_DanhSachNgay(h.Sohopdong)     AS [DanhSachNgay],
        dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong)   AS [DanhSachDichVu],
        dbo.fn_DOCX_MenuTiec(h.Sohopdong)         AS [MenuTiec],
        dbo.fn_DOCX_MenuTongCong(h.Sohopdong)     AS [MenuTongCong]

    FROM tbmk_Hopdong h
    LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
    WHERE
        ISNULL(h.IsDeleted, 0) = 0
        AND (@Sohopdong IS NULL OR h.Sohopdong = @Sohopdong)
        AND (@Keyword   IS NULL OR
             h.Sohopdong LIKE '%' + @Keyword + '%' OR
             k.Tenkh     LIKE N'%' + @Keyword + '%')
    ORDER BY h.Ngaytochuc DESC;
END
GO
PRINT N'  + Đã cập nhật Stored Procedure: API_DanhSachBEO';
GO

PRINT N'=== HOÀN THÀNH CẬP NHẬT CSDL CHO PHÂN HỆ CL ===';
GO
