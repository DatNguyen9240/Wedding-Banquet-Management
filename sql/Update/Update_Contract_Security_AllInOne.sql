USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. CHUẨN HÓA CẤU TRÚC BẢNG (SOFT DELETE COLUMNS)
-- =========================================================================
PRINT N'Đang chuẩn hóa cấu trúc bảng nghiệp vụ...';
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD IsDeleted BIT DEFAULT 0;
    ALTER TABLE tbmk_Hopdong ADD DeletedBy VARCHAR(50) NULL;
    ALTER TABLE tbmk_Hopdong ADD DeletedAt DATETIME NULL;
    PRINT N'Đã thêm cột Soft Delete cho bảng tbmk_Hopdong';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Biennhancoccho]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD IsDeleted BIT DEFAULT 0;
    ALTER TABLE tbmk_Biennhancoccho ADD DeletedBy VARCHAR(50) NULL;
    ALTER TABLE tbmk_Biennhancoccho ADD DeletedAt DATETIME NULL;
    PRINT N'Đã thêm cột Soft Delete cho bảng tbmk_Biennhancoccho';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbPhieuthu]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbPhieuthu ADD IsDeleted BIT DEFAULT 0;
    ALTER TABLE tbPhieuthu ADD DeletedBy VARCHAR(50) NULL;
    ALTER TABLE tbPhieuthu ADD DeletedAt DATETIME NULL;
    PRINT N'Đã thêm cột Soft Delete cho bảng tbPhieuthu';
END
GO

-- =========================================================================
-- 2. CẬP NHẬT CÁC VIEW DANH SÁCH (ẨN DỮ LIỆU ĐÃ SOFT DELETE)
-- =========================================================================
PRINT N'Đang cập nhật View v_DanhSachHopDong...';
GO

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO

CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khoá chính thật
    h.Sobiennhan,
    h.Makh,
    
    -- Lấy thông tin khách hàng từ dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenKhachHang],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
    ) AS [SanhDat],
    
    ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
    
    CASE
        WHEN h.IsHuy = 1 THEN N'Đã Hủy'
        WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
        ELSE N'Đã Ký'
    END AS [TrangThai],

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG (ShowInForm = 1, ShowInGrid = 0)
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
    h.Thoigianid,
    h.SobanManchinhthuc,
    h.SobanManduphong,
    h.SobanChaychinhthuc,
    h.SobanChayduphong,
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong,
    h.Tongtiencoc,
    h.Ghichu,
    (
        SELECT TOP 1 hs.Sanhtiecid 
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN 
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    -- (Đã có sẵn h.Sohopdong ở trên nên không cần tạo SoHopDong nữa, trong Word sẽ dùng biến {Sohopdong})
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Thông tin Bên A
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenA_NguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenA_ChucVu],
    ISNULL(h.UserCreate, '...') AS [BenA_NhanVienPhuTrach],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3') AS [BenA_SDT_NhanVien],

    -- Thông tin Bên B
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [BenB_TenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenB_TenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenB_CCCD],
    ISNULL(k.Diachi, '...') AS [BenB_DiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenB_DienThoai],
    '' AS [BenB_ChucVu],

    -- Thông tin Tiệc
    ISNULL(h.GioDienRaSuKien, '...') AS [Tiec_GioBatDau],
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_NgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_ThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [Tiec_NamDL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
        ELSE ISNULL(h.Nhamngay, '...')
    END AS [Tiec_NgayAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN CASE 
                WHEN CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0 
                    THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) - CHARINDEX('/', h.Nhamngay) - 1)
                ELSE SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
            END
        ELSE '...'
    END AS [Tiec_ThangAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 AND CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0
            THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) + 1, LEN(h.Nhamngay))
        ELSE '...'
    END AS [Tiec_NamAL],
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Tiec_SanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [Sanh_QuyMoMax],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [Tiec_SoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [Tiec_SoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [Tiec_SoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [Tiec_SoKhach1Ban],
    
    -- Thông tin Cọc & Khuyến mãi
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') AS [Coc_Lan1_SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [Coc_Lan1_BangChu],
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [Coc_Lan2_SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [Coc_Lan2_BangChu],
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Ngay],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [Coc_Thang],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [Coc_Nam],
    
    ISNULL(h.Ghichu, '') AS [DieuKhoanBoSung],
    ISNULL(h.Noidunguudai, '') AS [DS_KhuyenMai]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO

PRINT N'Đang cập nhật View v_DanhSachPhieuCoc...';
GO

IF EXISTS(SELECT * FROM sys.views WHERE name = 'v_DanhSachPhieuCoc' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW [dbo].[v_DanhSachPhieuCoc];
END
GO

CREATE VIEW [dbo].[v_DanhSachPhieuCoc] AS
SELECT 
    b.DocumentID,
    b.DocumentID AS MaChungTu,
    b.Makh AS Makh,
    b.SoBN AS SoPhieu,
    b.Thoigianid,
    b.Loaitiecid,
    b.Nhamngay,
    b.SobanManchinhthuc,
    b.SobanChaychinhthuc,
    b.SobanManduphong,
    b.SobanChayduphong,
    b.Ghichu,
    
    -- Lôi thông tin khách hàng từ bảng khác đắp vào đây
    k.Tenchure,
    k.Tencodau,
    k.DTchure,
    k.DTcodau,
    k.Diachi,
    k.Nguoigd,
    k.DienThoaiDaiDien,
    k.Mail,
    
    -- Cột tính toán Tên khách & Điện thoại
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS TenKhachHang,
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS DienThoai,
    
    b.Ngaytochuc AS [NgayToChuc],
    ISNULL(b.Tongsoban, 0) AS SoBan,
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Biennhancocchosanhtiec bs 
        INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
        WHERE bs.DocumentID = b.DocumentID
    ) AS SanhDat,
    ISNULL(
        CASE 
            WHEN ISNULL(b.Solan, 1) = 2 THEN (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentID = b.DocumentIDcu)
            ELSE b.Tongtien 
        END, 0
    ) AS DaCocVND,
    ISNULL(
        CASE 
            WHEN ISNULL(b.Solan, 1) = 2 THEN b.Tongtien
            ELSE (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentIDcu = b.DocumentID AND Solan = 2)
        END, 0
    ) AS Sotiencochopdong,
    
    -- Cột Lần cọc để Form Sửa tự động điền (fill) vào dropdown
    b.Solan AS [Solan],
    
    -- Các cột mới cho việc in phiếu và nhập liệu
    b.TaiKhoanNo,
    b.TaiKhoanCo,
    b.Kemtheo,
    b.Lydo,
    b.HinhThuc,
    
    -- Thay đổi cột JsonSanhTiec thành Scalar ID (lấy sảnh đầu tiên/sảnh chính)
    -- Điều này giúp DynamicFormEngine.js khi mở form Sửa tự động mapping value trùng khớp với Mã sảnh của Dropdown
    (
        SELECT TOP 1 Sanhtiecid 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        ORDER BY IsSanhchinh DESC
    ) AS JsonSanhTiec,
    
    -- Cột JSON đầy đủ dự phòng nếu cần dùng sau này
    (
        SELECT Sanhtiecid, IsSanhchinh 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        FOR JSON PATH
    ) AS [_JsonSanhTiec],
    
    CASE
        WHEN b.IsHuy = 1 THEN N'Đã Hủy'
        WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
        WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
        ELSE N'Đã cọc lần 1'
    END AS TrangThai

FROM tbmk_Biennhancoccho b
LEFT JOIN dmkhachhang k ON b.Makh = k.Makh
WHERE ISNULL(b.IsDeleted, 0) = 0;
GO

-- =========================================================================
-- 3. CẬP NHẬT CÁC STORED PROCEDURE LƯU HỢP ĐỒNG / PHIẾU CỌC (GUARD CHẶN UPDATE)
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_LuuHopDong...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_LuuHopDong]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_LuuHopDong];
END
GO

CREATE PROCEDURE [dbo].[API_LuuHopDong]
    @Sohopdong VARCHAR(50) = NULL OUTPUT,
    @Sobiennhan VARCHAR(20) = NULL,
    @Makh VARCHAR(20) = NULL OUTPUT,
    @Tenchure NVARCHAR(255) = NULL,
    @Tencodau NVARCHAR(255) = NULL,
    @Dienthoai NVARCHAR(50) = NULL,
    @Diachi NVARCHAR(500) = NULL,
    @Mail NVARCHAR(100) = NULL,
    @Ngayhopdong NVARCHAR(100) = NULL,
    @Ngaytochuc NVARCHAR(100) = NULL,
    @_Ngaytochuc NVARCHAR(100) = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(10) = NULL,
    @Thoigianid VARCHAR(20) = NULL,
    @SobanManchinhthuc NVARCHAR(100) = NULL,
    @SobanManduphong NVARCHAR(100) = NULL,
    @SobanChaychinhthuc NVARCHAR(100) = NULL,
    @SobanChayduphong NVARCHAR(100) = NULL,
    @TongSoBan NVARCHAR(100) = NULL,
    @Tongtienhopdong NVARCHAR(100) = NULL,
    @Sotiencoccho NVARCHAR(100) = NULL,
    @Sotiencochopdong NVARCHAR(100) = NULL,
    @Tongtiencoc NVARCHAR(100) = NULL,
    @Ghichu NVARCHAR(1000) = NULL,
    @Manv VARCHAR(20) = NULL,
    @UserCreate VARCHAR(20) = 'System',
    @JsonSanhTiec NVARCHAR(MAX) = NULL 
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @NgayHopDongParsed DATETIME = NULL;
    DECLARE @NgayToChucParsed DATETIME = NULL;
    DECLARE @_NgayToChucParsed DATETIME = NULL;
    DECLARE @SobanManchinhthucVal INT = 0;
    DECLARE @SobanManduphongVal INT = 0;
    DECLARE @SobanChaychinhthucVal INT = 0;
    DECLARE @SobanChayduphongVal INT = 0;
    DECLARE @TongSoBanVal DECIMAL(18,2) = 0;
    DECLARE @TongtienhopdongVal DECIMAL(18,2) = 0;
    DECLARE @SotiencocchoVal DECIMAL(18,2) = 0;
    DECLARE @SotiencochopdongVal DECIMAL(18,2) = 0;
    DECLARE @TongtiencocVal DECIMAL(18,2) = 0;

    IF (UPPER(LTRIM(RTRIM(@Ngayhopdong))) = 'NULL' OR LTRIM(RTRIM(@Ngayhopdong)) = '')
        SET @Ngayhopdong = NULL;
    IF (UPPER(LTRIM(RTRIM(@Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@Ngaytochuc)) = '')
        SET @Ngaytochuc = NULL;
    IF (UPPER(LTRIM(RTRIM(@_Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@_Ngaytochuc)) = '')
        SET @_Ngaytochuc = NULL;

    IF (@Ngayhopdong IS NOT NULL)
    BEGIN
        SET @NgayHopDongParsed = TRY_CAST(@Ngayhopdong AS DATETIME);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 103);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 105);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 120);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 111);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 101);
    END

    IF (@Ngaytochuc IS NOT NULL)
    BEGIN
        SET @NgayToChucParsed = TRY_CAST(@Ngaytochuc AS DATETIME);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 103);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 105);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 120);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 111);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 101);
    END

    IF (@_Ngaytochuc IS NOT NULL)
    BEGIN
        SET @_NgayToChucParsed = TRY_CAST(@_Ngaytochuc AS DATETIME);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 103);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 105);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 120);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 111);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 101);
    END

    IF (@NgayToChucParsed IS NULL)
        SET @NgayToChucParsed = @_NgayToChucParsed;

    SET @SobanManchinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManchinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanManduphongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManduphong, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChaychinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChaychinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChayduphongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChayduphong, '0'), '.', ''), ',', '') AS INT);
    SET @TongSoBanVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@TongSoBan, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtienhopdongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtienhopdong, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencocchoVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencoccho, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencochopdongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencochopdong, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtiencocVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtiencoc, '0'), '.', ''), ',', '') AS DECIMAL(18,2));

    IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
    BEGIN
        IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
            SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';
    END

    IF (@NgayToChucParsed IS NULL AND @Sohopdong IS NOT NULL AND @Sohopdong <> '')
    BEGIN
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Hopdong WHERE Sohopdong = @Sohopdong;
    END

    IF (@NgayToChucParsed IS NULL AND @Sobiennhan IS NOT NULL AND @Sobiennhan <> '')
    BEGIN
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Biennhancoccho WHERE DocumentID = @Sobiennhan OR SoBN = @Sobiennhan;
    END

    IF (@NgayToChucParsed IS NULL)
    BEGIN
        SELECT 0 AS [Success], N'Lỗi: Ngày tổ chức không được để trống hoặc định dạng ngày không hợp lệ!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM tbmk_Hopdong h
                INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE h.Ngaytochuc = @NgayToChucParsed 
                  AND h.Thoigianid = @Thoigianid
                  AND ISNULL(h.IsHuy, 0) = 0
                  AND h.Sohopdong != ISNULL(@Sohopdong, '')
                UNION ALL
                SELECT 1 
                FROM tbmk_Biennhancoccho b
                INNER JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON bs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE b.Ngaytochuc = @NgayToChucParsed 
                  AND b.Thoigianid = @Thoigianid
                  AND ISNULL(b.IsHuy, 0) = 0
                  AND ISNULL(b.IsKetthuc, 0) = 0
                  AND b.DocumentID != ISNULL(@Sobiennhan, '')
            )
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS [Success], N'Lỗi: Sảnh bạn chọn đã được đặt hoặc cọc trước đó trong ca tiệc này. Vui lòng kiểm tra lại!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
                RETURN;
            END
        END

        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            IF (@Dienthoai IS NOT NULL AND @Dienthoai <> '')
            BEGIN
                SELECT TOP 1 @Makh = Makh FROM dmkhachhang WHERE Dienthoai = @Dienthoai AND ISNULL(IsKhachhang, 0) = 1 ORDER BY DateCreate ASC;
            END

            IF (@Makh IS NULL OR @Makh = '')
            BEGIN
                SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');
                INSERT INTO dmkhachhang (Makh, Tenkh, Tenchure, Tencodau, Dienthoai, Diachi, Mail, IsKhachhang, DateCreate, UserCreate)
                VALUES (@Makh, CASE WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '') ELSE ISNULL(@Tenchure, '') + ' & ' + ISNULL(@Tencodau, '') END, @Tenchure, @Tencodau, @Dienthoai, @Diachi, @Mail, 1, @Now, @UserCreate);
            END
            ELSE
            BEGIN
                UPDATE dmkhachhang SET Tenchure = ISNULL(NULLIF(@Tenchure, ''), Tenchure), Tencodau = ISNULL(NULLIF(@Tencodau, ''), Tencodau), Diachi = ISNULL(NULLIF(@Diachi, ''), Diachi), Mail = ISNULL(NULLIF(@Mail, ''), Mail), DateUpdate = @Now, UserUpdate = @UserCreate WHERE Makh = @Makh;
            END
        END
        ELSE
        BEGIN
            UPDATE dmkhachhang SET Tenkh = CASE WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '') ELSE ISNULL(@Tenchure, '') + ' & ' + ISNULL(@Tencodau, '') END, Tenchure = @Tenchure, Tencodau = @Tencodau, Dienthoai = @Dienthoai, Diachi = @Diachi, Mail = @Mail, DateUpdate = @Now, UserUpdate = @UserCreate WHERE Makh = @Makh;
        END

        IF (@Sohopdong IS NULL OR @Sohopdong = '')
        BEGIN
            SET @Sohopdong = 'HD' + FORMAT(@Now, 'yyMMddHHmmss');
            INSERT INTO tbmk_Hopdong (Sohopdong, Sobiennhan, Ngayhopdong, Ngaytochuc, Nhamngay, Makh, Loaitiecid, Thoigianid, SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, TongSoBan, Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongtiencoc, Manv, Ghichu, IsHuy, IsKetthuc, DateCreate, UserCreate, GoiThucDonID)
            VALUES (@Sohopdong, @Sobiennhan, ISNULL(@NgayHopDongParsed, @Now), @NgayToChucParsed, @Nhamngay, @Makh, @Loaitiecid, @Thoigianid, @SobanManchinhthucVal, @SobanManduphongVal, @SobanChaychinhthucVal, @SobanChayduphongVal, @TongSoBanVal, @TongtienhopdongVal, @SotiencocchoVal, @SotiencochopdongVal, @TongtiencocVal, @Manv, @Ghichu, 0, 0, @Now, @UserCreate, '');

            IF (@Sobiennhan IS NOT NULL AND @Sobiennhan != '')
            BEGIN
                UPDATE tbmk_Biennhancoccho SET IsKetthuc = 1, DateUpdate = @Now, UserUpdate = @UserCreate WHERE DocumentID = @Sobiennhan;
            END
        END
        ELSE
        BEGIN
            -- KIỂM TRA TRẠNG THÁI BẤT BIẾN (Đã ký / Quyết toán)
            IF EXISTS (
                SELECT 1 FROM tbmk_Hopdong 
                WHERE Sohopdong = @Sohopdong 
                  AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
            )
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS [Success], N'Lỗi: Không thể chỉnh sửa hợp đồng đã chốt (Đã ký hoặc Quyết toán). Vui lòng dùng chức năng Phụ lục!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
                RETURN;
            END

            UPDATE tbmk_Hopdong SET Sobiennhan = @Sobiennhan, Makh = @Makh, Ngayhopdong = @NgayHopDongParsed, Ngaytochuc = @NgayToChucParsed, Nhamngay = @Nhamngay, Loaitiecid = @Loaitiecid, Thoigianid = @Thoigianid, SobanManchinhthuc = @SobanManchinhthucVal, SobanManduphong = @SobanManduphongVal, SobanChaychinhthuc = @SobanChaychinhthucVal, SobanChayduphong = @SobanChayduphongVal, TongSoBan = @TongSoBanVal, Tongtienhopdong = @TongtienhopdongVal, Sotiencoccho = @SotiencocchoVal, Sotiencochopdong = @SotiencochopdongVal, Tongtiencoc = @TongtiencocVal, Ghichu = @Ghichu, DateUpdate = @Now, UserUpdate = @UserCreate WHERE Sohopdong = @Sohopdong;
        END

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DELETE FROM tbmk_Hopdongsanhtiec WHERE Sohopdong = @Sohopdong;
            INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid, IsSanhchinh, DateCreate, UserCreate)
            SELECT NEWID(), @Sohopdong, JSON_VALUE(value, '$.Sanhtiecid'), ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0), @Now, @UserCreate FROM OPENJSON(@JsonSanhTiec);
        END

        COMMIT TRANSACTION;
        SELECT 1 AS [Success], N'Lưu Hợp đồng Tiệc Cưới thành công' AS [Message], @Sohopdong AS [Sohopdong], @Makh AS [Makh];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
    END CATCH
END
GO

PRINT N'Đang cập nhật Stored Procedure API_LuuPhieuCoc...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_LuuPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_LuuPhieuCoc];
END
GO

CREATE PROCEDURE [dbo].[API_LuuPhieuCoc]
    @DocumentID VARCHAR(50) = NULL OUTPUT,
    @Makh VARCHAR(50) = NULL OUTPUT,
    @Tenchure NVARCHAR(255) = NULL,
    @Tencodau NVARCHAR(255) = NULL,
    @DTchure NVARCHAR(50) = NULL,
    @DTcodau NVARCHAR(50) = NULL,
    @Diachi NVARCHAR(500) = NULL,
    @Nguoigd NVARCHAR(100) = NULL,
    @DienThoaiDaiDien NVARCHAR(50) = NULL,
    @Mail NVARCHAR(100) = NULL,
    @DocumentDate NVARCHAR(100) = NULL,
    @Ngaytochuc NVARCHAR(100) = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL,
    @SobanManchinhthuc INT = 0,
    @SobanManduphong INT = 0,
    @SobanChaychinhthuc INT = 0,
    @SobanChayduphong INT = 0,
    @Tongtien NVARCHAR(50) = NULL,
    @Solan TINYINT = 1,
    @Ghichu NVARCHAR(500) = NULL,
    @Manv VARCHAR(50) = NULL,
    @UserCreate VARCHAR(50) = 'System',
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    @MaChungTu VARCHAR(50) = NULL,
    @_Ngaytochuc NVARCHAR(100) = NULL,
    @TongtienRaw NVARCHAR(50) = NULL,
    @TaiKhoanNo VARCHAR(50) = NULL,
    @TaiKhoanCo VARCHAR(50) = NULL,
    @Kemtheo NVARCHAR(255) = NULL,
    @Lydo NVARCHAR(255) = NULL,
    @HinhThuc NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DocumentDateParsed DATETIME = NULL;
    DECLARE @NgayToChucParsed DATETIME = NULL;
    DECLARE @_NgayToChucParsed DATETIME = NULL;

    IF (@DocumentDate IS NOT NULL AND LTRIM(RTRIM(@DocumentDate)) <> '')
    BEGIN
        SET @DocumentDateParsed = TRY_CAST(@DocumentDate AS DATETIME);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 103);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 105);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 120);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 111);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 101);
    END

    IF (@_Ngaytochuc IS NOT NULL AND LTRIM(RTRIM(@_Ngaytochuc)) <> '')
    BEGIN
        SET @_NgayToChucParsed = TRY_CAST(@_Ngaytochuc AS DATETIME);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 103);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 105);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 120);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 111);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 101);
    END

    IF (@Ngaytochuc IS NOT NULL AND LTRIM(RTRIM(@Ngaytochuc)) <> '')
    BEGIN
        SET @NgayToChucParsed = TRY_CAST(@Ngaytochuc AS DATETIME);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 103);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 105);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 120);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 111);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 101);
    END

    BEGIN TRY
        IF @MaChungTu IS NOT NULL AND (@DocumentID IS NULL OR @DocumentID = '')
            SET @DocumentID = @MaChungTu;
        IF @_NgayToChucParsed IS NOT NULL
            SET @NgayToChucParsed = @_NgayToChucParsed;
            
        DECLARE @TongTienDecimal DECIMAL(18,2) = 0;

        IF @Tongtien IS NOT NULL AND LTRIM(RTRIM(@Tongtien)) <> ''
        BEGIN
            DECLARE @CleanedTongTien NVARCHAR(50) = REPLACE(REPLACE(REPLACE(@Tongtien, '.', ''), ',', ''), ' ', '');
            IF TRY_CAST(@CleanedTongTien AS DECIMAL(18,2)) IS NOT NULL
                SET @TongTienDecimal = CAST(@CleanedTongTien AS DECIMAL(18,2));
        END

        IF @TongtienRaw IS NOT NULL AND LTRIM(RTRIM(@TongtienRaw)) <> ''
        BEGIN
            DECLARE @CleanedTongTienRaw NVARCHAR(50) = REPLACE(REPLACE(REPLACE(@TongtienRaw, '.', ''), ',', ''), ' ', '');
            IF TRY_CAST(@CleanedTongTienRaw AS DECIMAL(18,2)) IS NOT NULL
                SET @TongTienDecimal = CAST(@CleanedTongTienRaw AS DECIMAL(18,2));
        END

        IF @NgayToChucParsed IS NULL OR @NgayToChucParsed <= '1900-01-01'
        BEGIN
            SELECT 0 AS [Success], N'Lỗi: Vui lòng chọn Ngày tổ chức tiệc!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
            RETURN;
        END

        IF @Thoigianid IS NULL OR LTRIM(RTRIM(@Thoigianid)) = ''
        BEGIN
            SELECT 0 AS [Success], N'Lỗi: Vui lòng chọn Ca tiệc (Thời gian)!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
            RETURN;
        END

        IF @JsonSanhTiec IS NULL OR LTRIM(RTRIM(@JsonSanhTiec)) = '' OR @JsonSanhTiec = '[]'
        BEGIN
            SELECT 0 AS [Success], N'Lỗi: Vui lòng chọn Sảnh tiệc!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
            RETURN;
        END

        DECLARE @CheckMakh VARCHAR(50) = @Makh;
        IF (@CheckMakh IS NULL OR @CheckMakh = '')
        BEGIN
            DECLARE @CheckSdt NVARCHAR(50) = ISNULL(NULLIF(@DTchure, ''), @DTcodau);
            IF (@CheckSdt IS NOT NULL AND @CheckSdt <> '')
            BEGIN
                SELECT TOP 1 @CheckMakh = Makh FROM dmkhachhang WHERE (Dienthoai = @CheckSdt OR DTchure = @CheckSdt OR DTcodau = @CheckSdt) AND ISNULL(Tenchure, '') = ISNULL(@Tenchure, '') AND ISNULL(Tencodau, '') = ISNULL(@Tencodau, '') ORDER BY DateCreate ASC;
            END
        END

        IF (@CheckMakh IS NOT NULL AND @CheckMakh <> '')
        BEGIN
            IF EXISTS (
                SELECT 1 FROM tbmk_Biennhancoccho WHERE Makh = @CheckMakh AND Ngaytochuc = @NgayToChucParsed AND ISNULL(IsHuy, 0) = 0 AND ISNULL(IsKetthuc, 0) = 0 AND DocumentID != ISNULL(@DocumentID, '')
            )
            BEGIN
                SELECT 0 AS [Success], N'Lỗi: Khách hàng này đã có một phiếu cọc chỗ đang hoạt động vào ngày tổ chức này. Vui lòng chỉnh sửa phiếu cọc cũ thay vì tạo mới!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
                RETURN;
            END
        END

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DECLARE @JsonSanhTiecTemp NVARCHAR(MAX) = @JsonSanhTiec;
            IF (LEFT(LTRIM(@JsonSanhTiecTemp), 1) != '[')
                SET @JsonSanhTiecTemp = '[{"Sanhtiecid":"' + @JsonSanhTiecTemp + '", "IsSanhchinh":1}]';

            IF EXISTS (
                SELECT 1 FROM tbmk_Hopdong h INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong INNER JOIN OPENJSON(@JsonSanhTiecTemp) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid') WHERE h.Ngaytochuc = @NgayToChucParsed AND h.Thoigianid = @Thoigianid AND ISNULL(h.IsHuy, 0) = 0
                UNION ALL
                SELECT 1 FROM tbmk_Biennhancoccho b INNER JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID INNER JOIN OPENJSON(@JsonSanhTiecTemp) j ON bs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid') WHERE b.Ngaytochuc = @NgayToChucParsed AND b.Thoigianid = @Thoigianid AND ISNULL(b.IsHuy, 0) = 0 AND ISNULL(b.IsKetthuc, 0) = 0 AND b.DocumentID != ISNULL(@DocumentID, '')
            )
            BEGIN
                SELECT 0 AS [Success], N'Lỗi: Sảnh bạn chọn đã được đặt cọc hoặc ký Hợp đồng trước đó trong ca tiệc này. Vui lòng kiểm tra lại!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
                RETURN;
            END
        END

        BEGIN TRANSACTION;
        DECLARE @Now DATETIME = GETDATE();
        DECLARE @Tongsoban INT = ISNULL(@SobanManchinhthuc, 0) + ISNULL(@SobanChaychinhthuc, 0);

        IF (@Makh IS NULL OR @Makh = '') AND (@DocumentID IS NOT NULL AND @DocumentID <> '')
        BEGIN
            SELECT @Makh = Makh FROM tbmk_Biennhancoccho WHERE DocumentID = @DocumentID;
        END

        DECLARE @IsNewCustomer BIT = 0;
        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            DECLARE @SdtTimkiem NVARCHAR(50) = ISNULL(NULLIF(@DTchure, ''), @DTcodau);
            IF (@SdtTimkiem IS NOT NULL AND @SdtTimkiem <> '')
            BEGIN
                SELECT TOP 1 @Makh = Makh FROM dmkhachhang WHERE (Dienthoai = @SdtTimkiem OR DTchure = @SdtTimkiem OR DTcodau = @SdtTimkiem) AND ISNULL(Tenchure, '') = ISNULL(@Tenchure, '') AND ISNULL(Tencodau, '') = ISNULL(@Tencodau, '') ORDER BY DateCreate ASC;
            END

            IF (@Makh IS NULL OR @Makh = '')
            BEGIN
                SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');
                SET @IsNewCustomer = 1;
                INSERT INTO dmkhachhang (Makh, Tenkh, Tenchure, Tencodau, DTchure, DTcodau, Dienthoai, Diachi, Nguoigd, DienThoaiDaiDien, Mail, IsKhachhang, DateCreate, UserCreate)
                VALUES (@Makh, CASE WHEN ISNULL(@Tenchure, '') <> '' AND ISNULL(@Tencodau, '') <> '' THEN @Tenchure + ' & ' + @Tencodau WHEN ISNULL(@Tenchure, '') <> '' THEN @Tenchure WHEN ISNULL(@Tencodau, '') <> '' THEN @Tencodau ELSE ISNULL(NULLIF(@Nguoigd, ''), N'Khách vãng lai') END, @Tenchure, @Tencodau, @DTchure, @DTcodau, ISNULL(NULLIF(@DTchure, ''), ISNULL(NULLIF(@DTcodau, ''), @DienThoaiDaiDien)), @Diachi, @Nguoigd, @DienThoaiDaiDien, @Mail, 1, @Now, @UserCreate);
            END
        END

        IF (@IsNewCustomer = 0)
        BEGIN
            UPDATE dmkhachhang SET Tenkh = CASE WHEN ISNULL(@Tenchure, '') <> '' AND ISNULL(@Tencodau, '') <> '' THEN @Tenchure + ' & ' + @Tencodau WHEN ISNULL(@Tenchure, '') <> '' THEN @Tenchure WHEN ISNULL(@Tencodau, '') <> '' THEN @Tencodau ELSE ISNULL(NULLIF(@Nguoigd, ''), N'Khách vãng lai') END, Tenchure = @Tenchure, Tencodau = @Tencodau, DTchure = @DTchure, DTcodau = @DTcodau, Dienthoai = ISNULL(NULLIF(@DTchure, ''), ISNULL(NULLIF(@DTcodau, ''), @DienThoaiDaiDien)), Diachi = @Diachi, Nguoigd = @Nguoigd, DienThoaiDaiDien = @DienThoaiDaiDien, Mail = @Mail, DateUpdate = @Now, UserUpdate = @UserCreate WHERE Makh = @Makh;
        END

        IF (@DocumentID IS NULL OR @DocumentID = '')
        BEGIN
            DECLARE @TodayStr VARCHAR(8) = FORMAT(@Now, 'yyMMdd');
            DECLARE @Counter INT;
            SELECT @Counter = COUNT(*) + 1 FROM tbmk_Biennhancoccho WHERE CONVERT(DATE, DateCreate) = CONVERT(DATE, @Now);
            DECLARE @SoBN VARCHAR(50) = 'BNCC-' + @TodayStr + '-' + RIGHT('00' + CAST(@Counter AS VARCHAR), 3);
            SET @DocumentID = 'BNCC' + FORMAT(@Now, 'yyMMddHHmmss');

            DECLARE @DocumentIDcu VARCHAR(50) = NULL;
            IF (@Solan = 2)
            BEGIN
                SELECT TOP 1 @DocumentIDcu = DocumentID FROM tbmk_Biennhancoccho WHERE Makh = @Makh AND Solan = 1 AND IsHuy = 0 ORDER BY DateCreate DESC;
            END

            INSERT INTO tbmk_Biennhancoccho (DocumentID, SoBN, DocumentDate, Makh, Solan, DocumentIDcu, Manv, Loaitiecid, Ngaytochuc, Nhamngay, Tongtien, Tongsoban, SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, Thoigianid, Ghichu, IsHuy, IsKetthuc, GoiThucDonID, DateCreate, UserCreate, TaiKhoanNo, TaiKhoanCo, Kemtheo, Lydo, HinhThuc)
            VALUES (@DocumentID, @SoBN, ISNULL(@DocumentDateParsed, @Now), @Makh, @Solan, @DocumentIDcu, @Manv, @Loaitiecid, @NgayToChucParsed, @Nhamngay, @TongTienDecimal, @Tongsoban, @SobanManchinhthuc, @SobanManduphong, @SobanChaychinhthuc, @SobanChayduphong, @Thoigianid, @Ghichu, 0, 0, '', @Now, @UserCreate, @TaiKhoanNo, @TaiKhoanCo, @Kemtheo, @Lydo, @HinhThuc);
        END
        ELSE
        BEGIN
            DECLARE @DocumentIDcuUpdate VARCHAR(50) = NULL;
            IF (@Solan = 2)
            BEGIN
                SELECT TOP 1 @DocumentIDcuUpdate = DocumentID FROM tbmk_Biennhancoccho WHERE Makh = @Makh AND Solan = 1 AND IsHuy = 0 AND DocumentID <> @DocumentID ORDER BY DateCreate DESC;
            END

            -- KIỂM TRA TRẠNG THÁI BẤT BIẾN (Đã chốt / Lên Hợp đồng)
            IF EXISTS (
                SELECT 1 FROM tbmk_Biennhancoccho 
                WHERE DocumentID = @DocumentID 
                  AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
            )
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS [Success], N'Lỗi: Không thể chỉnh sửa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
                RETURN;
            END

            UPDATE tbmk_Biennhancoccho SET Makh = @Makh, Solan = @Solan, DocumentIDcu = @DocumentIDcuUpdate, Loaitiecid = @Loaitiecid, Ngaytochuc = @NgayToChucParsed, Nhamngay = @Nhamngay, Tongtien = @TongTienDecimal, Tongsoban = @Tongsoban, SobanManchinhthuc = @SobanManchinhthuc, SobanManduphong = @SobanManduphong, SobanChaychinhthuc = @SobanChaychinhthuc, SobanChayduphong = @SobanChayduphong, Thoigianid = @Thoigianid, Ghichu = @Ghichu, DateUpdate = @Now, UserUpdate = @UserCreate, TaiKhoanNo = @TaiKhoanNo, TaiKhoanCo = @TaiKhoanCo, Kemtheo = @Kemtheo, Lydo = @Lydo, HinhThuc = @HinhThuc WHERE DocumentID = @DocumentID;
        END

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
                SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';

            DELETE FROM tbmk_Biennhancocchosanhtiec WHERE DocumentID = @DocumentID;
            INSERT INTO tbmk_Biennhancocchosanhtiec (UserAutoid, DocumentID, Sanhtiecid, IsSanhchinh, DateCreate, UserCreate)
            SELECT NEWID(), @DocumentID, JSON_VALUE(value, '$.Sanhtiecid'), ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0), @Now, @UserCreate FROM OPENJSON(@JsonSanhTiec);
        END

        COMMIT TRANSACTION;
        SELECT 1 AS [Success], N'Lưu biên nhận cọc thành công' AS [Message], @DocumentID AS [DocumentID], @Makh AS [Makh];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message], NULL AS [DocumentID], NULL AS [Makh];
    END CATCH
END
GO

PRINT N'Đang cập nhật Stored Procedure API_XoaPhieuCoc...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_XoaPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_XoaPhieuCoc];
END
GO

CREATE PROCEDURE [dbo].[API_XoaPhieuCoc]
    @DocumentIDs NVARCHAR(MAX) = NULL,
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF (@DocumentIDs IS NULL OR @DocumentIDs = '')
        BEGIN
            SELECT -1 AS [code], 0 AS [Success], N'Thiếu danh sách mã chứng từ (DocumentIDs)' AS [Message], N'Thiếu danh sách mã chứng từ (DocumentIDs)' AS [msg];
            RETURN;
        END

        BEGIN TRANSACTION;
        DECLARE @Dummy INT;
        SELECT @Dummy = 1 FROM tbmk_Biennhancoccho WITH (XLOCK, ROWLOCK) WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));

        IF EXISTS (
            SELECT 1 FROM tbmk_Biennhancoccho WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ',')) AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT -1 AS [code], 0 AS [Success], N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS [Message], N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS [msg];
            RETURN;
        END

        UPDATE tbmk_Biennhancoccho SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ISNULL(@UserName, 'System') WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@DocumentIDs, ','));
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        SELECT 0 AS [code], 1 AS [Success], N'Đã xóa ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu cọc thành công' AS [Message], N'Đã xóa ' + CAST(@RowsAffected AS VARCHAR) + N' phiếu cọc thành công' AS [msg];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT -1 AS [code], 0 AS [Success], ERROR_MESSAGE() AS [Message], ERROR_MESSAGE() AS [msg];
    END CATCH
END
GO

PRINT N'Đang cập nhật Stored Procedure API_XoaDong (Xóa động hệ thống)...';
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_XoaDong]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_XoaDong];
END
GO

CREATE PROCEDURE [dbo].[API_XoaDong]
    @List VARCHAR(50),
    @Ids NVARCHAR(MAX),
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(100);
    DECLARE @PrimaryKey VARCHAR(100);
    
    SELECT @TableName = COALESCE(SaveTableName, TableName), @PrimaryKey = PrimaryKey FROM SY_FrmLstTbl WHERE FormID = @List;

    IF @TableName IS NULL OR @TableName = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình TableName cho form ' + @List AS msg;
        RETURN;
    END

    IF @PrimaryKey IS NULL OR @PrimaryKey = ''
    BEGIN
        SELECT -1 AS code, N'Chưa cấu hình PrimaryKey cho form ' + @List AS msg;
        RETURN;
    END

    IF LOWER(@TableName) = 'tbmk_hopdong'
    BEGIN
        IF EXISTS (
            SELECT 1 FROM tbmk_Hopdong WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ',')) AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa hợp đồng đã chốt (Đã ký hoặc Quyết toán). Hệ thống yêu cầu lưu trữ chứng từ pháp lý!' AS msg;
            RETURN;
        END

        BEGIN TRY
            UPDATE tbmk_Hopdong SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ISNULL(@UserName, 'System') WHERE Sohopdong IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));
            DECLARE @RowsHD INT = @@ROWCOUNT;
            IF @RowsHD > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsHD AS VARCHAR) + N' hợp đồng.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy hợp đồng phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa hợp đồng: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    IF LOWER(@TableName) = 'tbmk_biennhancoccho'
    BEGIN
        IF EXISTS (
            SELECT 1 FROM tbmk_Biennhancoccho WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ',')) AND (Status IN ('SIGNED', 'COMPLETED') OR IsKetthuc = 1 OR IsHuy = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu cọc đã chốt hoặc đã lên Hợp đồng!' AS msg;
            RETURN;
        END

        BEGIN TRY
            UPDATE tbmk_Biennhancoccho SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ISNULL(@UserName, 'System') WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));
            DECLARE @RowsPC INT = @@ROWCOUNT;
            IF @RowsPC > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsPC AS VARCHAR) + N' phiếu cọc.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy phiếu cọc phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa phiếu cọc: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    IF LOWER(@TableName) IN ('tbphieuthu', 'tbmk_phieuthu')
    BEGIN
        DECLARE @CheckStatusSQL NVARCHAR(MAX) = 
            N'IF EXISTS (SELECT 1 FROM ' + QUOTENAME(@TableName) + 
            N' WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '','')) AND Status IN (''SIGNED'', ''COMPLETED''))
              SET @HasLocked = 1;';
              
        DECLARE @HasLocked INT = 0;
        
        BEGIN TRY
            EXEC sp_executesql @CheckStatusSQL, N'@Ids NVARCHAR(MAX), @HasLocked INT OUTPUT', @Ids = @Ids, @HasLocked = @HasLocked OUTPUT;
        END TRY
        BEGIN CATCH
            SET @HasLocked = 0;
        END CATCH

        IF @HasLocked = 1
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phiếu thu đã thanh toán hoặc đã chốt!' AS msg;
            RETURN;
        END

        BEGIN TRY
            DECLARE @UpdateSQL NVARCHAR(MAX) = 
                N'UPDATE ' + QUOTENAME(@TableName) + 
                N' SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = @User
                  WHERE DocumentID IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, '',''))';
                  
            EXEC sp_executesql @UpdateSQL, N'@Ids NVARCHAR(MAX), @User VARCHAR(50)', @Ids = @Ids, @User = @UserName;

            DECLARE @RowsPT INT = @@ROWCOUNT;
            IF @RowsPT > 0
                SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsPT AS VARCHAR) + N' phiếu thu/quyết toán.' AS msg;
            ELSE
                SELECT -1 AS code, N'Không tìm thấy phiếu thu/quyết toán phù hợp để xóa.' AS msg;
            RETURN;
        END TRY
        BEGIN CATCH
            SELECT -1 AS code, N'Lỗi xóa phiếu thu: ' + ERROR_MESSAGE() AS msg;
            RETURN;
        END CATCH
    END

    BEGIN TRY
        DECLARE @sql NVARCHAR(MAX) = 'DELETE FROM ' + QUOTENAME(@TableName) + ' WHERE ' + QUOTENAME(@PrimaryKey) + ' IN (SELECT value FROM string_split(@DeleteIds, '',''))';
        EXEC sp_executesql @sql, N'@DeleteIds NVARCHAR(MAX)', @DeleteIds = @Ids;
        DECLARE @RowsAffected INT = @@ROWCOUNT;
        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công ' + CAST(@RowsAffected AS VARCHAR) + N' dòng khỏi bảng ' + @TableName AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy dữ liệu (ID: ' + @Ids + N') để xóa trong bảng ' + @TableName AS msg;
    END TRY
    BEGIN CATCH
        SELECT -1 AS code, N'Lỗi xóa dữ liệu: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO

-- =========================================================================
-- 5. CẤU HÌNH API GATEWAY (WA_API)
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình tham số Delete cho frmBiennhancoccho trong WA_API...';
GO

IF NOT EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmBiennhancoccho' AND Func = 'Delete')
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmBiennhancoccho', 'Delete', 'API_XoaPhieuCoc', '@DocumentIDs=N''{id}'', @UserName=N''{UserName}''');
END
ELSE
BEGIN
    UPDATE WA_API
    SET [SQL] = 'API_XoaPhieuCoc',
        Para = '@DocumentIDs=N''{id}'', @UserName=N''{UserName}'''
    WHERE List = 'frmBiennhancoccho' AND Func = 'Delete';
END
GO

PRINT N'>> TOÀN BỘ CƠ SỞ DỮ LIỆU ĐÃ ĐƯỢC BẢO MẬT IMMUTABLE VÀ SOFT-DELETE THÀNH CÔNG!';
GO
