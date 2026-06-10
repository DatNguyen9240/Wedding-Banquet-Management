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

        -- ── Thời gian tổ chức ───────────────────────────────────────────
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103)                 AS [NgayToChuc],
        RIGHT('0' + CAST(DAY  (h.Ngaytochuc) AS VARCHAR), 2)   AS [NgayToChucDay],
        RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2)   AS [ThangToChuc],
        CAST(YEAR(h.Ngaytochuc) AS VARCHAR)                     AS [NamToChuc],
        ISNULL(h.GioDienRaSuKien, N'...')                       AS [GioBatDau],
        ISNULL(h.GioKetThucSuKien, N'...')                      AS [GioKetThuc],
        -- TenCa: lấy từ dmCalam qua Thoigianid
        ISNULL((SELECT TOP 1 c.Tenca FROM dmCalam c WHERE c.Thoigianid = h.Thoigianid), N'') AS [TenCa],

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
                    ISNULL(NULLIF(h.Ghichu, ''), N'Thanh toán cuối tiệc.')
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
        h.Manv

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

-- Đăng ký Save (dùng lại API_LuuHopDong để cập nhật NgayRaBEO, KieuSetup, SoKhachChinhThuc...)
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBEO',
    'Save',
    'API_LuuHopDong',
    '@Sohopdong=N''{Sohopdong}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}'''
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
('ThongTinSetup',   N'Thông Tin Setup',       'ml', NULL,  '12', 20, 1,1,0,0),
('NoteBaoVe',       N'Ghi Chú Bảo Vệ',       'ml', NULL,  '12', 21, 1,1,0,0),
('NoteBieuNgu',     N'Ghi Chú Biểu Ngữ',     'ml', NULL,  '12', 22, 1,1,0,0),
('NoteKyThuat',     N'Ghi Chú Kỹ Thuật',     'ml', NULL,  '12', 23, 1,1,0,0),
('NoteLobby',       N'Ghi Chú Lobby',         'ml', NULL,  '12', 24, 1,1,0,0),
('ChiTietLichTrinh',N'Lịch Trình Chi Tiết',  'js', NULL,  '12', 30, 0,0,1,1),
('LichTrinhThanhToan',N'Lịch Trình Thanh Toán','js',NULL, '12', 31, 0,0,1,1);

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
