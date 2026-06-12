USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- UPDATE_BEO_ALLINONE.SQL
-- Mục đích: Triển khai đầy đủ chức năng xuất phiếu BEO Hội Nghị / Tiệc Cưới
-- Bao gồm: Schema → SP API_DanhSachBEO → WA_API → SY_FormatFields
-- Tương thích: SQL Server 2016+ (không dùng CREATE OR ALTER)
-- =========================================================================

PRINT N'=== BẮT ĐẦU TRIỂN KHAI MODULE BEO ===';
GO

-- =========================================================================
-- 1. BỔ SUNG CÁC CỘT CÒN THIẾU TRONG TBMK_HOPDONG
-- =========================================================================
PRINT N'1. Đang kiểm tra và bổ sung cột cho bảng tbmk_Hopdong...';
GO

-- NgayRaBEO: Ngày xuất phiếu BEO (do nhân viên chốt thủ công, mặc định = ngày lập HĐ)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'NgayRaBEO')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NgayRaBEO DATETIME NULL;
    PRINT N'  + Đã thêm cột NgayRaBEO';
END

-- KieuSetup: Kiểu sắp xếp bàn ghế (Rạp hát / Lớp học / Chữ U / Hội đồng / Tiệc đứng...)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'KieuSetup')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD KieuSetup NVARCHAR(100) NULL;
    PRINT N'  + Đã thêm cột KieuSetup';
END

-- SoKhachChinhThuc: Số khách hội nghị chính thức (khác SoKhachDiemDanh của tiệc)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'SoKhachChinhThuc')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD SoKhachChinhThuc INT NULL;
    PRINT N'  + Đã thêm cột SoKhachChinhThuc';
END

-- ThongTinSetup: Nội dung setup chi tiết (multiline, dùng cho {@ThongTinSetup})
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'ThongTinSetup')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD ThongTinSetup NVARCHAR(MAX) NULL;
    PRINT N'  + Đã thêm cột ThongTinSetup';
END

-- DonViThiCong: đơn vị thi công sự kiện (hội nghị thường có)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'DonViThiCong')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD DonViThiCong NVARCHAR(500) NULL;
    PRINT N'  + Đã thêm cột DonViThiCong';
END

-- TieuSuKhachHang: tiểu sử / ghi chú về khách hàng
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'TieuSuKhachHang')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD TieuSuKhachHang NVARCHAR(MAX) NULL;
    PRINT N'  + Đã thêm cột TieuSuKhachHang';
END

-- DichVuKhuyenMai: các dịch vụ ưu đãi / tặng kèm cho sự kiện
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'DichVuKhuyenMai')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD DichVuKhuyenMai NVARCHAR(MAX) NULL;
    PRINT N'  + Đã thêm cột DichVuKhuyenMai';
END

-- LuuY: lưu ý chung cho sự kiện (khác Ghichu — dành riêng cho BEO)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'LuuY')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD LuuY NVARCHAR(MAX) NULL;
    PRINT N'  + Đã thêm cột LuuY';
END

PRINT N'1. Hoàn thành bổ sung cột.';
GO

-- =========================================================================
-- 2. TẠO/CẬP NHẬT STORED PROCEDURE API_DanhSachBEO
-- =========================================================================
PRINT N'2. Đang tạo Stored Procedure API_DanhSachBEO...';
GO

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
        ISNULL(h.NgayRaBEO, h.Ngayhopdong)                     AS [NgayRaBEO],
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

        -- DanhSachSanh: mảng JSON để template dùng vòng lặp {#DanhSachSanh}...{/DanhSachSanh}
        (
            SELECT
                s.Tensanhtiec                           AS [SanhDat],
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
        ISNULL(h.GioDienRaSuKien, N'...')                       AS [GioBatDau],
        ISNULL(h.GioKetThucSuKien, N'...')                      AS [GioKetThuc],
        -- TenCa: lấy từ dmThoigian qua Thoigianid
        ISNULL((SELECT TOP 1 c.Thoigian FROM dmThoigian c WHERE c.Thoigianid = h.Thoigianid), N'') AS [TenCa],

        -- ── Loại hình & số lượng ─────────────────────────────────────────
        ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSuKien],
        -- SoKhachChinhThuc: nhân viên nhập thủ công khi lập BEO, để NULL nếu chưa có
        h.SoKhachChinhThuc                                      AS [SoKhachChinhThuc],
        ISNULL(h.KieuSetup, N'Tiệc ngồi')                      AS [KieuSetup],


        -- ── Số bàn ──────────────────────────────────────────────────────
        ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [SoBanChinhThuc],
        ISNULL(h.SoBanTang, 0)         AS [BanTang],
        ISNULL(h.SobanChaychinhthuc, 0) AS [BanChay],
        ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0)     AS [SoBanDuPhong],
        ISNULL(h.TongSoBan, 0)         AS [TongSoBan],
        ISNULL(h.SoNguoiTrenBan, 10)   AS [SoKhachTrenBan],

        -- ── Thông tin Bên A (từ SY_Setup — giống v_DanhSachHopDong) ──────
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenADiaChi')    AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenASDT')       AS [BenASDT],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAMST')       AS [BenAMST],
        ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = h.Manv), ISNULL(h.UserCreate, h.Manv)) AS [BenANhanVienPhuTrach],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'Com3')          AS [BenASDTNhanVien],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail')     AS [BenAEmailNhanVien],

        -- ── Thông tin Bên B (Khách hàng — từ dmkhachhang) ──────────────
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
        -- BenBDaiDien: tên người giao dịch (alias của BenBTenDaiDien để khớp placeholder {BenBDaiDien})
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [BenBDaiDien],
        ISNULL(k.Diachi, N'...')         AS [BenBDiaChiTemplate], -- backup alias nếu cần

        -- NgayHopDong: ngày ký hợp đồng (template dùng {NgayHopDong})
        ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), N'...') AS [NgayHopDong],

        -- NgaySetup: ngày trước ngày tổ chức 1 ngày (setup sảnh)
        ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, -1, h.Ngaytochuc), 103), N'...') AS [NgaySetup],

        -- DonViThiCong: đơn vị thi công (nếu có), mặc định để trống
        ISNULL(NULLIF(h.DonViThiCong, ''), N'') AS [DonViThiCong],

        -- TieuSuKhachHang: tiểu sử / ghi chú khách hàng  
        ISNULL(NULLIF(h.TieuSuKhachHang, ''), N'') AS [TieuSuKhachHang],

        -- DichVuKhuyenMai: dịch vụ ưu đãi tặng kèm
        ISNULL(NULLIF(h.DichVuKhuyenMai, ''), N'') AS [DichVuKhuyenMai],

        -- LuuY: lưu ý chung (lấy từ ghi chú hợp đồng nếu có)
        ISNULL(NULLIF(h.LuuY, ''), ISNULL(NULLIF(h.Ghichu, ''), N'')) AS [LuuY],

        -- HDTenCty: tên công ty xuất hóa đơn (khớp placeholder {HDTenCty})
        ISNULL(NULLIF(h.TenCtyHoaDon, ''), ISNULL(k.Tenkh, N'')) AS [HDTenCty],

        -- ── Tài chính cơ bản ─────────────────────────────────────────────

        FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
        [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
        FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + N' VNĐ' AS [Dot1SoTien],
        ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), N'...') AS [Dot1Ngay],

        -- ── Lịch trình & ghi chú nghiệp vụ ─────────────────────────────
        ISNULL(NULLIF(h.JsonLichTrinh, ''), '[]') AS [ChiTietLichTrinh],
        ISNULL(NULLIF(h.JsonLichTrinh, ''), '[]') AS [LichTrinh],

        -- Lịch trình thanh toán — computed giống v_DanhSachHopDong
        (
            SELECT STT, SoTien, Ngay, NoiDung
            FROM (
                SELECT 1 AS STT,
                    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS SoTien,
                    ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS Ngay,
                    N'Đặt cọc giữ chỗ' AS NoiDung
                WHERE ISNULL(h.Sotiencoccho, 0) > 0
                UNION ALL
                SELECT 2, FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ',
                    ISNULL(CONVERT(VARCHAR(10), h.Ngayhopdong, 103), '...'),
                    N'Đặt cọc ký hợp đồng'
                WHERE ISNULL(h.Sotiencochopdong, 0) > 0
                UNION ALL
                SELECT CASE WHEN ISNULL(h.Sotiencochopdong, 0) > 0 THEN 3 ELSE 2 END,
                    N'Thanh toán còn lại',
                    ISNULL(CONVERT(VARCHAR(10), h.Ngaytochuc, 103), '...'),
                    N'Thanh toán cuối tiệc.'
            ) t
            FOR JSON PATH
        ) AS [LichTrinhThanhToan],

        -- ── Ghi chú cho các bộ phận (multiline — dùng {@...}) ───────────
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

        -- ── Menu / dịch vụ (fn_DOCX_* — xem sql/Functions/fn_DOCX_MenuDichVu.sql) ──
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


PRINT N'2. Hoàn thành tạo API_DanhSachBEO.';
GO


-- =========================================================================
-- 3. ĐỒNG BỘ ĐỊNH TUYẾN GATEWAY (WA_API)
-- =========================================================================
PRINT N'3. Đang đồng bộ định tuyến WA_API cho frmBEO...';
GO

-- Đảm bảo SY_FrmLstTbl có entry cho frmBEO
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmBEO')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('frmBEO', N'Phiếu BEO Hội Nghị / Tiệc Cưới', 'v_DanhSachHopDong', 'tbmk_Hopdong', 'Sohopdong');
ELSE
    UPDATE SY_FrmLstTbl SET CaptionVN = N'Phiếu BEO Hội Nghị / Tiệc Cưới' WHERE FormID = 'frmBEO';
GO

-- Xóa routing cũ nếu có
DELETE FROM WA_API WHERE List = 'frmBEO' AND Func IN ('View', 'Save');
GO

-- Đăng ký View
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBEO',
    'View',
    'API_DanhSachBEO',
    '@Keyword=N''{Keyword}'', @Sohopdong=N''{Sohopdong}'''
);

-- Đăng ký Save (dùng API_LuuDong để cập nhật tự động các cột trong tbmk_Hopdong)
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBEO',
    'Save',
    'API_LuuDong',
    '@List=N''frmBEO'', @Data=N''{JsonData}'''
);
GO

PRINT N'3. Hoàn thành đồng bộ WA_API.';
GO

-- =========================================================================
-- 4. CẤU HÌNH SY_FORMATFIELDS (Nhãn tiếng Việt & hiển thị Form)
-- =========================================================================
PRINT N'4. Đang đồng bộ SY_FormatFields cho frmBEO...';
GO

-- Dùng MERGE để UPSERT (insert nếu chưa có, update nếu đã có)
DECLARE @BEO_Fields TABLE (
    FieldName     VARCHAR(100), CaptionVN NVARCHAR(200),
    FormatID      VARCHAR(10),  DataSource NVARCHAR(MAX),
    FormPosition  VARCHAR(5),   OrderNo INT,
    ShowInAdd     BIT,          ShowInEdit BIT,
    IsReadOnlyAdd BIT,          IsReadOnlyEdit BIT
);

INSERT INTO @BEO_Fields VALUES
('Sohopdong',       N'Số Hợp Đồng',          't',  NULL,  '6',  1,  1,1,1,1),
('KhachHang',       N'Khách Hàng',            't',  NULL,  '6',  2,  1,1,1,1),
('NgayRaBEO',       N'Ngày Ra BEO',           'dt', NULL,  '6',  3,  1,1,0,0),
('NgayToChuc',      N'Ngày Tổ Chức',          'dt', NULL,  '6',  4,  1,1,1,1),
('TenCa',           N'Ca / Thời Gian',        't',  NULL,  '6',  5,  1,1,1,1),
('GioBatDau',       N'Giờ Bắt Đầu',          't',  NULL,  '6',  6,  1,1,0,0),
('GioKetThuc',      N'Giờ Kết Thúc',         't',  NULL,  '6',  7,  1,1,0,0),
('TenSanhTiec',     N'Tên Sảnh',              't',  NULL,  '6',  8,  1,1,1,1),
('LoaiHinhSuKien',  N'Loại Hình Sự Kiện',    't',  NULL,  '6',  9,  1,1,1,1),
('SoKhachChinhThuc',N'Số Khách Chính Thức',  'n',  NULL,  '6',  10, 1,1,0,0),
('KieuSetup',       N'Kiểu Setup',            'sl', N'STATIC:Rạp hát|Rạp hát,Lớp học|Lớp học,Chữ U|Chữ U,Hội đồng|Hội đồng,Tiệc ngồi|Tiệc ngồi,Tiệc đứng|Tiệc đứng', '6', 11, 1,1,0,0),
('SoBanChinhThuc',  N'Bàn Chính Thức',       'n',  NULL,  '6',  12, 1,1,1,1),
('SoBanDuPhong',    N'Bàn Dự Phòng',         'n',  NULL,  '6',  13, 1,1,1,1),
('ThongTinSetup',   N'Thông Tin Setup',       'ta', NULL,  '12', 20, 1,1,0,0),
('NoteBaoVe',       N'Ghi Chú Bảo Vệ',       'ta', NULL,  '12', 21, 1,1,0,0),
('NoteBieuNgu',     N'Ghi Chú Biểu Ngữ',     'ta', NULL,  '12', 22, 1,1,0,0),
('NoteKyThuat',     N'Ghi Chú Kỹ Thuật',     'ta', NULL,  '12', 23, 1,1,0,0),
('NoteLobby',       N'Ghi Chú Lobby',         'ta', NULL,  '12', 24, 1,1,0,0),
('ChiTietLichTrinh',N'Lịch Trình Chi Tiết',  'js', N'[{"key":"BatDau","label":"Bắt đầu","type":"text","width":"80px"},{"key":"KetThuc","label":"Kết thúc","type":"text","width":"80px"},{"key":"Sanh","label":"Sảnh","type":"text","width":"100px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]',  '12', 30, 0,0,1,1),
('LichTrinhThanhToan',N'Lịch Trình Thanh Toán','js', N'[{"key":"STT","label":"Đợt","type":"number","width":"60px"},{"key":"SoTien","label":"Số tiền","type":"text","width":"150px"},{"key":"Ngay","label":"Ngày","type":"text","width":"120px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]', '12', 31, 0,0,1,1);

MERGE SY_FormatFields AS tgt
USING (SELECT 'frmBEO' AS FormName, * FROM @BEO_Fields) AS src
    ON tgt.FormName = src.FormName AND tgt.FieldName = src.FieldName
WHEN MATCHED THEN
    UPDATE SET
        CaptionVN     = src.CaptionVN,
        FormatID      = src.FormatID,
        DataSource    = src.DataSource,
        FormPosition  = src.FormPosition,
        OrderNo       = src.OrderNo,
        ShowInAdd     = src.ShowInAdd,
        ShowInEdit    = src.ShowInEdit,
        IsReadOnlyAdd = src.IsReadOnlyAdd,
        IsReadOnlyEdit= src.IsReadOnlyEdit
WHEN NOT MATCHED THEN
    INSERT (FormName, FieldName, CaptionVN, FormatID, DataSource, FormPosition, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, IsRequired)
    VALUES (src.FormName, src.FieldName, src.CaptionVN, src.FormatID, src.DataSource, src.FormPosition, src.OrderNo, src.ShowInAdd, src.ShowInEdit, src.IsReadOnlyAdd, src.IsReadOnlyEdit, 0);
GO

PRINT N'=== HOÀN THÀNH TRIỂN KHAI MODULE BEO ===';
GO
