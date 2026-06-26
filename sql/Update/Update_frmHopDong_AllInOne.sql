-- Script Update Hợp Đồng All-in-One

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ensure NguoinhanTT column supports unicode Vietnamese characters
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NguoinhanTT')
BEGIN
    ALTER TABLE tbmk_Hopdong ALTER COLUMN NguoinhanTT NVARCHAR(200) NULL;
END
GO

-- Ensure LoaiHinhSuKien column exists in tbmk_Hopdong
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'LoaiHinhSuKien')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD LoaiHinhSuKien NVARCHAR(250) NULL;
END
GO

-- Ensure IsDeleted column exists in tbmk_Hopdong to prevent view compilation failure
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD IsDeleted BIT NULL;
END
GO
UPDATE tbmk_Hopdong SET IsDeleted = 0 WHERE IsDeleted IS NULL;
GO

-- Ensure DieuKhoanBoSung column exists in tbmk_Hopdong
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'DieuKhoanBoSung')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD DieuKhoanBoSung NVARCHAR(MAX) NULL;
END
GO

-- Thực đơn HĐ: nguồn chuẩn = bảng chi tiết (tbmk_Hopdongthucdon* / thucuong / dichvu).
-- View ghép JSON khi đọc; API không lưu cột Json* trên tbmk_Hopdong nữa.
GO

-- Migrate 1 lần: dữ liệu cũ trong cột Json* → bảng chi tiết (nếu chi tiết đang trống)
IF COL_LENGTH('tbmk_Hopdong', 'JsonBanTiec') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Hopdongthucdonman (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio)
    SELECT NEWID(), h.Sohopdong, ROW_NUMBER() OVER (PARTITION BY h.Sohopdong ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
    FROM tbmk_Hopdong h
    CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
      AND ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%'
      AND NOT EXISTS (SELECT 1 FROM tbmk_Hopdongthucdonman x WHERE x.Sohopdong = h.Sohopdong);

    INSERT INTO tbmk_Hopdongthucdonchay (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio)
    SELECT NEWID(), h.Sohopdong, ROW_NUMBER() OVER (PARTITION BY h.Sohopdong ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
    FROM tbmk_Hopdong h
    CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
      AND ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%'
      AND NOT EXISTS (SELECT 1 FROM tbmk_Hopdongthucdonchay x WHERE x.Sohopdong = h.Sohopdong);
END

IF COL_LENGTH('tbmk_Hopdong', 'JsonThucUong') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Hopdongthucuong (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT)
    SELECT NEWID(), h.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
           ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), 'Migrate', GETDATE(),
           ROW_NUMBER() OVER (PARTITION BY h.Sohopdong ORDER BY j.Mahang)
    FROM tbmk_Hopdong h
    CROSS APPLY OPENJSON(h.JsonThucUong) WITH (
        Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
        IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)
    ) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonThucUong)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonThucUong), 1) = '['
      AND NOT EXISTS (SELECT 1 FROM tbmk_Hopdongthucuong x WHERE x.Sohopdong = h.Sohopdong);
END

IF COL_LENGTH('tbmk_Hopdong', 'JsonDichVu') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Hopdongdichvu (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichudichvu, UserCreate, DateCreate, STT)
    SELECT NEWID(), h.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
           ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, 'Migrate', GETDATE(),
           ROW_NUMBER() OVER (PARTITION BY h.Sohopdong ORDER BY j.Mahang)
    FROM tbmk_Hopdong h
    CROSS APPLY OPENJSON(h.JsonDichVu) WITH (
        Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
        IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)
    ) j
    WHERE NULLIF(LTRIM(RTRIM(h.JsonDichVu)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonDichVu), 1) = '['
      AND NOT EXISTS (SELECT 1 FROM tbmk_Hopdongdichvu x WHERE x.Sohopdong = h.Sohopdong);
END
GO

-- XÓA VIEW CŨ TRƯỚC ĐỂ TRÁNH LỖI INVALID COLUMN KHI COMPILE SP
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO

-- =========================================================================
-- 1. STORED PROCEDURE: API_DanhSachHopDong
-- Mục đích: Lấy danh sách hợp đồng kèm theo các biến in ấn đã format sẵn
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_DanhSachHopDong]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[API_DanhSachHopDong]
GO
CREATE PROCEDURE [dbo].[API_DanhSachHopDong]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL,
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.*
    FROM 
        [dbo].[v_DanhSachHopDong] v
    WHERE 
        -- Bộ lọc theo Khoảng ngày (Dựa theo NgayToChuc)
        (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR v.NgayToChuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR v.NgayToChuc <= @DenNgay)
        
        -- Bộ lọc theo Số hợp đồng
        AND (@Sohopdong IS NULL OR @Sohopdong = '' OR v.Sohopdong = @Sohopdong)
        
        -- Bộ lọc Keyword tìm kiếm tương đđi
        AND (
            @Keyword IS NULL OR @Keyword = ''
            OR v.Sohopdong LIKE '%' + @Keyword + '%'
            OR v.Sobiennhan LIKE '%' + @Keyword + '%'
            OR v.TenKhachHang LIKE N'%' + @Keyword + '%'
            OR v.Tenchure LIKE N'%' + @Keyword + '%'
            OR v.Tencodau LIKE N'%' + @Keyword + '%'
            OR v.DienThoai LIKE '%' + @Keyword + '%'
            OR v.BenBCCCD LIKE '%' + @Keyword + '%'
        )
    ORDER BY 
        v.Sohopdong DESC;
        
END
GO

-- =========================================================================
-- 2. STORED PROCEDURE: API_LuuHopDong
-- Mục đích: Thêm mới hoặc Cập nhật Hợp Đồng Tiệc Cưới
-- =========================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_LuuHopDong]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[API_LuuHopDong]
GO
CREATE PROCEDURE [dbo].[API_LuuHopDong]
    @Sohopdong VARCHAR(50) = NULL OUTPUT, -- Nếu NULL: Thêm mới HĐ, Ngược lại: Cập nhật
    @Sobiennhan VARCHAR(20) = NULL,       -- ID Biên nhận cọc chỗ
    
    -- Thông tin Khách hàng (Tạo mới hoặc cập nhật nếu có)
    @Makh VARCHAR(20) = NULL OUTPUT,
    @Tenchure NVARCHAR(255) = NULL,
    @Tencodau NVARCHAR(255) = NULL,
    @Dienthoai NVARCHAR(50) = NULL,
    @Diachi NVARCHAR(500) = NULL,
    @Mail NVARCHAR(100) = NULL,
    @BenBCCCD NVARCHAR(50) = NULL,
    @BenBTenDaiDien NVARCHAR(255) = NULL,
    @LoaiHinhSuKien NVARCHAR(250) = NULL,
    
    -- Thông tin Hợp đồng Tiệc
    @Ngayhopdong NVARCHAR(100) = NULL,
    @TuNgaySetup NVARCHAR(100) = NULL,
    @NgayTraSanhDV NVARCHAR(100) = NULL,
    @TenCongTy NVARCHAR(255) = NULL,
    @NgayToChuc NVARCHAR(100) = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(10) = NULL,
    @Thoigianid VARCHAR(20) = NULL,      -- Ca tiệc
    @SetupBatDau NVARCHAR(50) = NULL,     -- Giờ bắt đầu Setup
    @SetupKetThuc NVARCHAR(50) = NULL,    -- Giờ kết thúc Setup
    
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
    @DieuKhoanBoSung NVARCHAR(MAX) = NULL,
    @Manv VARCHAR(20) = NULL,
    @UserCreate VARCHAR(20) = 'System',
    -- Danh sach Sanh dat (Dang JSON: [{"Sanhtiecid":"S01", "IsSanhchinh": 1}, ...])
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    @JsonBanTiec NVARCHAR(MAX) = NULL,
    @JsonThucUong NVARCHAR(MAX) = NULL,
    @JsonDichVu NVARCHAR(MAX) = NULL,
    @JsonPhatSinh NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @NgayToChucParsed DATETIME = NULL;
    DECLARE @SobanManchinhthucVal INT = 0;
    DECLARE @SobanManduphongVal INT = 0;
    DECLARE @SobanChaychinhthucVal INT = 0;
    DECLARE @SobanChayduphongVal INT = 0;
    DECLARE @TongSoBanVal DECIMAL(18,2) = 0;
    DECLARE @TongtienhopdongVal DECIMAL(18,2) = 0;
    DECLARE @SotiencocchoVal DECIMAL(18,2) = 0;
    DECLARE @SotiencochopdongVal DECIMAL(18,2) = 0;
    DECLARE @TongtiencocVal DECIMAL(18,2) = 0;

    DECLARE @NgayHopDongParsed DATETIME = NULL;
    IF (UPPER(LTRIM(RTRIM(@Ngayhopdong))) = 'NULL' OR LTRIM(RTRIM(@Ngayhopdong)) = '') SET @Ngayhopdong = NULL;
    IF (UPPER(LTRIM(RTRIM(@TuNgaySetup))) = 'NULL' OR LTRIM(RTRIM(@TuNgaySetup)) = '') SET @TuNgaySetup = NULL;
    IF (UPPER(LTRIM(RTRIM(@NgayTraSanhDV))) = 'NULL' OR LTRIM(RTRIM(@NgayTraSanhDV)) = '') SET @NgayTraSanhDV = NULL;
    IF (UPPER(LTRIM(RTRIM(@NgayToChuc))) = 'NULL' OR LTRIM(RTRIM(@NgayToChuc)) = '') SET @NgayToChuc = NULL;

    IF (@Ngayhopdong IS NOT NULL)
    BEGIN
        SET @NgayHopDongParsed = TRY_CAST(@Ngayhopdong AS DATETIME);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 103);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 105);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 120);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 23);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 111);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 101);
    END
    IF (@Ngaytochuc IS NOT NULL)
    BEGIN
        SET @NgayToChucParsed = TRY_CAST(@Ngaytochuc AS DATETIME);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 103);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 105);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 120);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 23);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 111);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 101);
    END
    
    DECLARE @TuNgaySetupParsed DATETIME = NULL;
    IF (@TuNgaySetup IS NOT NULL)
    BEGIN
        SET @TuNgaySetupParsed = TRY_CAST(@TuNgaySetup AS DATETIME);
        IF (@TuNgaySetupParsed IS NULL) SET @TuNgaySetupParsed = TRY_CONVERT(DATETIME, @TuNgaySetup, 103);
        IF (@TuNgaySetupParsed IS NULL) SET @TuNgaySetupParsed = TRY_CONVERT(DATETIME, @TuNgaySetup, 23);
    END
    
    DECLARE @NgayTraSanhDVParsed DATETIME = NULL;
    IF (@NgayTraSanhDV IS NOT NULL)
    BEGIN
        SET @NgayTraSanhDVParsed = TRY_CAST(@NgayTraSanhDV AS DATETIME);
        IF (@NgayTraSanhDVParsed IS NULL) SET @NgayTraSanhDVParsed = TRY_CONVERT(DATETIME, @NgayTraSanhDV, 103);
        IF (@NgayTraSanhDVParsed IS NULL) SET @NgayTraSanhDVParsed = TRY_CONVERT(DATETIME, @NgayTraSanhDV, 23);
    END


    SET @SobanManchinhthucVal  = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManchinhthuc,  '0'), '.', ''), ',', '') AS INT);
    SET @SobanManduphongVal    = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManduphong,    '0'), '.', ''), ',', '') AS INT);
    SET @SobanChaychinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChaychinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChayduphongVal   = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChayduphong,   '0'), '.', ''), ',', '') AS INT);
    SET @TongSoBanVal          = TRY_CAST(REPLACE(REPLACE(ISNULL(@TongSoBan,          '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtienhopdongVal    = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtienhopdong,    '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencocchoVal       = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencoccho,       '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencochopdongVal   = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencochopdong,   '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtiencocVal        = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtiencoc,        '0'), '.', ''), ',', '') AS DECIMAL(18,2));

    -- Chuẩn hóa JSON sảnh tiệc nếu là mã đơn lẻ hoặc danh sách phân tách bằng dấu phẩy
    IF (@JsonSanhTiec = '.' OR @JsonSanhTiec = '')
    BEGIN
        SET @JsonSanhTiec = NULL;
    END

    IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
    BEGIN
        IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[' OR ISJSON(@JsonSanhTiec) = 0)
        BEGIN
            SET @JsonSanhTiec = (
                SELECT Sanhtiecid, 1 AS IsSanhchinh
                FROM (
                    SELECT LTRIM(RTRIM(value)) AS Sanhtiecid 
                    FROM STRING_SPLIT(@JsonSanhTiec, ',')
                    WHERE value <> '.' AND value <> ''
                ) s
                WHERE Sanhtiecid <> ''
                FOR JSON PATH
            );
        END
        ELSE
        BEGIN
            -- Nếu đã là JSON array, chuẩn hóa để loại bỏ phần tử rác (nếu có)
            SET @JsonSanhTiec = (
                SELECT Sanhtiecid, IsSanhchinh
                FROM (
                    SELECT 
                        JSON_VALUE(value, '$.Sanhtiecid') AS Sanhtiecid,
                        ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0) AS IsSanhchinh
                    FROM OPENJSON(@JsonSanhTiec)
                ) s
                WHERE Sanhtiecid IS NOT NULL AND Sanhtiecid <> '.' AND Sanhtiecid <> ''
                FOR JSON PATH
            );
        END
    END

    -- Chuẩn hóa các tham số JSON chi tiết thực đơn & dịch vụ
    IF (@JsonBanTiec = '.' OR @JsonBanTiec = '' OR @JsonBanTiec = '[]') SET @JsonBanTiec = NULL;
    IF (@JsonBanTiec IS NOT NULL AND (LEFT(LTRIM(@JsonBanTiec), 1) <> '[' OR ISJSON(@JsonBanTiec) = 0)) SET @JsonBanTiec = '[' + @JsonBanTiec + ']';

    IF (@JsonThucUong = '.' OR @JsonThucUong = '' OR @JsonThucUong = '[]') SET @JsonThucUong = NULL;
    IF (@JsonThucUong IS NOT NULL AND (LEFT(LTRIM(@JsonThucUong), 1) <> '[' OR ISJSON(@JsonThucUong) = 0)) SET @JsonThucUong = '[' + @JsonThucUong + ']';

    IF (@JsonDichVu = '.' OR @JsonDichVu = '' OR @JsonDichVu = '[]') SET @JsonDichVu = NULL;
    IF (@JsonDichVu IS NOT NULL AND (LEFT(LTRIM(@JsonDichVu), 1) <> '[' OR ISJSON(@JsonDichVu) = 0)) SET @JsonDichVu = '[' + @JsonDichVu + ']';

    IF (@JsonPhatSinh = '.' OR @JsonPhatSinh = '' OR @JsonPhatSinh = '[]') SET @JsonPhatSinh = NULL;
    IF (@JsonPhatSinh IS NOT NULL AND (LEFT(LTRIM(@JsonPhatSinh), 1) <> '[' OR ISJSON(@JsonPhatSinh) = 0)) SET @JsonPhatSinh = '[' + @JsonPhatSinh + ']';

    IF (@NgayToChucParsed IS NULL AND @Sohopdong IS NOT NULL AND @Sohopdong <> '')
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Hopdong WHERE Sohopdong = @Sohopdong;

    IF (@NgayToChucParsed IS NULL AND @Sobiennhan IS NOT NULL AND @Sobiennhan <> '')
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Biennhancoccho WHERE DocumentID = @Sobiennhan OR SoBN = @Sobiennhan;

    IF (@NgayToChucParsed IS NULL)
    BEGIN
        SELECT 0 AS [Success], N'Lỗi: Ngày tổ chức không được để trống hoặc định dạng ngày không hợp lệ.' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 0. KIEM TRA TRUNG LICH SANH
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            IF EXISTS (
                SELECT 1 FROM tbmk_Hopdong h
                INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE h.Ngaytochuc = @NgayToChucParsed AND h.Thoigianid = @Thoigianid
                  AND ISNULL(h.IsHuy, 0) = 0 AND h.Sohopdong != ISNULL(@Sohopdong, '')
                UNION ALL
                SELECT 1 FROM tbmk_Biennhancoccho b
                INNER JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON bs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE b.Ngaytochuc = @NgayToChucParsed AND b.Thoigianid = @Thoigianid
                  AND ISNULL(b.IsHuy, 0) = 0 AND ISNULL(b.IsKetthuc, 0) = 0
                  AND b.DocumentID != ISNULL(@Sobiennhan, '')
            )
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS [Success], N'Lỗi: Sảnh bạn chọn đã được đặt hoặc cọc trước đó trong ca tiệc này. Vui lòng kiểm tra lại!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
                RETURN;
            END
        END

        -- 1. XU LY KHACH HANG
        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            IF (@Dienthoai IS NOT NULL AND @Dienthoai <> '')
                SELECT TOP 1 @Makh = Makh FROM dmkhachhang
                WHERE Dienthoai = @Dienthoai AND ISNULL(IsKhachhang, 0) = 1 ORDER BY DateCreate ASC;

            IF (@Makh IS NULL OR @Makh = '')
            BEGIN
                SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');
                INSERT INTO dmkhachhang (Makh, Tenkh, Tenchure, Tencodau, Dienthoai, Diachi, Mail, CMNDDaiDien, CMNDchure, CMNDcodau, Nguoigd, IsKhachhang, DateCreate, UserCreate)
                VALUES (@Makh, CASE WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure,'') ELSE ISNULL(@Tenchure,'') + ' & ' + @Tencodau END,
                    @Tenchure, @Tencodau, @Dienthoai, @Diachi, @Mail, @BenBCCCD, @BenBCCCD, @BenBCCCD, @BenBTenDaiDien, 1, @Now, @UserCreate);
            END
            ELSE
            BEGIN
                -- Cap nhat khach cu: chi ghi de khi co gia tri moi
                UPDATE dmkhachhang SET
                    Tenchure    = ISNULL(NULLIF(@Tenchure,   ''), Tenchure),
                    Tencodau    = ISNULL(NULLIF(@Tencodau,   ''), Tencodau),
                    Diachi      = ISNULL(NULLIF(@Diachi,     ''), Diachi),
                    Mail        = ISNULL(NULLIF(@Mail,       ''), Mail),
                    CMNDDaiDien = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDDaiDien),
                    CMNDchure   = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDchure),
                    CMNDcodau   = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDcodau),
                    Nguoigd     = ISNULL(NULLIF(@BenBTenDaiDien, ''), Nguoigd),
                    DateUpdate  = @Now, UserUpdate = @UserCreate
                WHERE Makh = @Makh;
            END
        END
        ELSE
        BEGIN
            -- Co Makh truyen vao: chi ghi de khi gia tri moi KHONG rong
            UPDATE dmkhachhang SET
                Tenkh = CASE
                            WHEN ISNULL(@TenCongTy,'') <> '' THEN @TenCongTy
                            WHEN ISNULL(@Tencodau,'')='' THEN ISNULL(NULLIF(@Tenchure,''), Tenkh)
                            WHEN ISNULL(@Tenchure,'')='' THEN ISNULL(NULLIF(@Tencodau,''), Tenkh)
                            ELSE @Tenchure + ' & ' + @Tencodau
                        END,
                Tenchure    = ISNULL(NULLIF(@Tenchure,   ''), Tenchure),
                Tencodau    = ISNULL(NULLIF(@Tencodau,   ''), Tencodau),
                Dienthoai   = ISNULL(NULLIF(@Dienthoai,  ''), Dienthoai),
                Diachi      = ISNULL(NULLIF(@Diachi,     ''), Diachi),
                Mail        = ISNULL(NULLIF(@Mail,       ''), Mail),
                CMNDDaiDien = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDDaiDien),
                CMNDchure   = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDchure),
                CMNDcodau   = ISNULL(NULLIF(@BenBCCCD,  ''), CMNDcodau),
                Nguoigd     = ISNULL(NULLIF(@BenBTenDaiDien, ''), Nguoigd),
                DateUpdate  = @Now, UserUpdate = @UserCreate
            WHERE Makh = @Makh;
        END

        -- 2. XU LY HOP DONG
        IF (@Sohopdong IS NULL OR @Sohopdong = '')
        BEGIN
            SET @Sohopdong = 'HD' + FORMAT(@Now, 'yyMMddHHmmss');
            INSERT INTO tbmk_Hopdong (
                Sohopdong, Sobiennhan, Ngayhopdong, Ngaytochuc, Nhamngay, Makh, Loaitiecid, Thoigianid,
                TuNgaySetup, NgayTraSanhDV, TuGioDenGioSetup, DenGioSetup,
                SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, TongSoBan,
                Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongtiencoc,
                Manv, Ghichu, IsHuy, IsKetthuc, DateCreate, UserCreate, GoiThucDonID, LoaiHinhSuKien,
                DieuKhoanBoSung
            )
            VALUES (
                @Sohopdong, @Sobiennhan, ISNULL(@NgayHopDongParsed,@Now), @NgayToChucParsed, @Nhamngay, @Makh, @Loaitiecid, @Thoigianid,
                @TuNgaySetupParsed, @NgayTraSanhDVParsed, @SetupBatDau, @SetupKetThuc,
                @SobanManchinhthucVal, @SobanManduphongVal, @SobanChaychinhthucVal, @SobanChayduphongVal, @TongSoBanVal,
                @TongtienhopdongVal, @SotiencocchoVal, @SotiencochopdongVal, @TongtiencocVal,
                @Manv, @Ghichu, 0, 0, @Now, @UserCreate, '', @LoaiHinhSuKien,
                @DieuKhoanBoSung
            );
            IF (@Sobiennhan IS NOT NULL AND @Sobiennhan != '')
                UPDATE tbmk_Biennhancoccho SET IsKetthuc=1, DateUpdate=@Now, UserUpdate=@UserCreate WHERE DocumentID=@Sobiennhan;
        END
        ELSE
        BEGIN
            /*

            IF EXISTS (SELECT 1 FROM tbmk_Hopdong WHERE Sohopdong=@Sohopdong AND (Status = 'COMPLETED' OR IsKetthuc=1 OR IsHuy=1))
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT -1 AS [Success], N'Lỗi: Không thể chỉnh sửa hợp đồng đã quyết toán hoặc đã kết thúc/hủy!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
                RETURN;
            END
            */
            UPDATE tbmk_Hopdong SET
                Sobiennhan=@Sobiennhan, Makh=@Makh, Ngayhopdong=@NgayHopDongParsed, Ngaytochuc=@NgayToChucParsed,
                TuNgaySetup = ISNULL(@TuNgaySetupParsed, TuNgaySetup),
                NgayTraSanhDV = ISNULL(@NgayTraSanhDVParsed, NgayTraSanhDV),
                TuGioDenGioSetup = @SetupBatDau,
                DenGioSetup = @SetupKetThuc,
                Nhamngay=@Nhamngay, Loaitiecid=@Loaitiecid, Thoigianid=@Thoigianid,
                SobanManchinhthuc=@SobanManchinhthucVal, SobanManduphong=@SobanManduphongVal,
                SobanChaychinhthuc=@SobanChaychinhthucVal, SobanChayduphong=@SobanChayduphongVal,
                TongSoBan=@TongSoBanVal, Tongtienhopdong=@TongtienhopdongVal,
                Sotiencoccho=@SotiencocchoVal, Sotiencochopdong=@SotiencochopdongVal,
                Tongtiencoc=@TongtiencocVal, Ghichu=@Ghichu, DateUpdate=@Now, UserUpdate=@UserCreate,
                LoaiHinhSuKien=@LoaiHinhSuKien, DieuKhoanBoSung=@DieuKhoanBoSung
            WHERE Sohopdong=@Sohopdong;
        END

        -- 3. XU LY SANH TIEC
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DELETE FROM tbmk_Hopdongsanhtiec WHERE Sohopdong=@Sohopdong;
            INSERT INTO tbmk_Hopdongsanhtiec (UserAutoid, Sohopdong, Sanhtiecid, IsSanhchinh, DateCreate, UserCreate)
            SELECT NEWID(), @Sohopdong, JSON_VALUE(value,'$.Sanhtiecid'),
                   ISNULL(CAST(JSON_VALUE(value,'$.IsSanhchinh') AS BIT),0), @Now, @UserCreate
            FROM OPENJSON(@JsonSanhTiec);
        END

        -- 4. ĐỒNG BỘ CHI TIẾT THỰC ĐƠN VÀO BẢNG CON (phục vụ in ấn & view)
        IF (@JsonBanTiec IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Hopdongthucdonman WHERE Sohopdong = @Sohopdong;
            DELETE FROM tbmk_Hopdongthucdonchay WHERE Sohopdong = @Sohopdong;

            INSERT INTO tbmk_Hopdongthucdonman (
                UserAutoid, Sohopdong, STTmon, Mahang, Dongia,
                UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio
            )
            SELECT
                NEWID(), @Sohopdong, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia,
                @UserCreate, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec)
            WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%';

            INSERT INTO tbmk_Hopdongthucdonchay (
                UserAutoid, Sohopdong, STTmon, Mahang, Dongia,
                UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio
            )
            SELECT
                NEWID(), @Sohopdong, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia,
                @UserCreate, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec)
            WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%';
        END

        IF (@JsonThucUong IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Hopdongthucuong WHERE Sohopdong = @Sohopdong;
            INSERT INTO tbmk_Hopdongthucuong (
                UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien,
                IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT
            )
            SELECT
                NEWID(), @Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), @UserCreate, @Now,
                ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)
            ) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang;
        END

        IF (@JsonDichVu IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Hopdongdichvu WHERE Sohopdong = @Sohopdong;
            INSERT INTO tbmk_Hopdongdichvu (
                UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien,
                IsKhuyenmai, Ghichudichvu, UserCreate, DateCreate, STT
            )
            SELECT
                NEWID(), @Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, @UserCreate, @Now,
                ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)
            ) j;
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


-- =========================================================================
-- 3. SQL VIEW: v_DanhSachHopDong
-- Mục đích: Làm nguồn dữ liệu hiển thị (Grid/Form) cho màn hình frmHopDong
-- =========================================================================
IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[v_DanhSachHopDong]'))
    DROP VIEW [dbo].[v_DanhSachHopDong]
GO
CREATE VIEW [dbo].[v_DanhSachHopDong] AS
SELECT 
    h.Sohopdong AS [Id], -- Đóng vai trò là PrimaryKey cho Frontend

    h.Sohopdong AS [Sohopdong], -- Cột khóa chính thật
    h.Sobiennhan,
    h.Makh,
    
    -- Lấy thông tin khách hàng từ dmkhachhang
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenKhachHang],
    
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS [TenCongTy],
    
    CASE 
        WHEN ISNULL((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0), 0) = 0
            THEN N'PHIẾU ĐẶT TIỆC'
        ELSE N'PHIẾU ĐẶT TIỆC THAY ĐỔI LẦN ' + CAST((SELECT MAX(td.LanThayDoi) FROM tbmk_Thaydoi td WHERE td.Sohopdong = h.Sohopdong AND ISNULL(td.IsDeleted, 0) = 0) AS NVARCHAR(10))
    END AS [TieuDePhieu],
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
    h.Ngaytochuc AS [NgayToChuc],
    h.TuNgaySetup AS [TuNgaySetup],
    h.NgayTraSanhDV AS [NgayTraSanhDV],
    
    ISNULL(h.TongSoBan, 0) AS [SoBan],
    
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhDat],
    ISNULL((
        SELECT s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY
    ), '') AS [SanhDat2],
    
    ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
    
    CASE
        WHEN h.IsHuy = 1 THEN N'Đã Hủy'
        WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
        ELSE N'Đã Ký'
    END AS [TrangThai],

    -- CÁC TRƯỜNG THÊM MỚI ĐỂ PHỤC VỤ NHẬP LIỆU/SỬA HỢP ĐỒNG
    k.Tenchure,
    k.Tencodau,
    k.Diachi,
    k.Mail,
    h.Ngayhopdong,
    h.Nhamngay,
    h.Loaitiecid,
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmHopDong' AND tm.Loaitiecid = h.Loaitiecid) AS [TemplateFile],
    h.Thoigianid,
    h.SobanManchinhthuc AS [SobanManchinhthuc],
    h.SobanManduphong AS [SobanManduphong],
    h.SobanChaychinhthuc AS [SobanChaychinhthuc],
    h.SobanChayduphong AS [SobanChayduphong],
    h.Sotiencoccho AS DaCocVND,
    h.Sotiencochopdong AS [Sotiencochopdong],
    h.Giabanman AS [Giabanman],
    h.Tongtiencoc AS [Tongtiencoc],
    h.Ghichu AS [Ghichu],
    h.JsonLichTrinh,

    -- Thực đơn & Dịch vụ: đọc duy nhất từ bảng chi tiết → JSON cho form
    ISNULL((
        SELECT items.Mahang, items.TenHang, items.DvtID, items.Soluong, items.Dongia,
               items.IsChay
        FROM (
            SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                   CAST(1 AS DECIMAL(18,2)) AS Soluong, ISNULL(td.Dongia, 0) AS Dongia,
                   CAST(0 AS BIT) AS IsChay, ISNULL(td.STTmon, 0) AS SortOrder, 1 AS TableType
            FROM tbmk_Hopdongthucdonman td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong
            UNION ALL
            SELECT td.Mahang, ISNULL(hh.Tenhang, td.Mahang), ISNULL(hh.DVTID, N'Đĩa'),
                   CAST(1 AS DECIMAL(18,2)), ISNULL(td.Dongia, 0),
                   CAST(1 AS BIT), ISNULL(td.STTmon, 0), 2
            FROM tbmk_Hopdongthucdonchay td
            LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
            WHERE td.Sohopdong = h.Sohopdong
        ) items
        ORDER BY items.TableType, items.SortOrder, items.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonBanTiec],

    ISNULL((
        SELECT tu.Mahang, ISNULL(hh.Tenhang, tu.Mahang) AS TenHang, ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
               ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai, ISNULL(tu.Soluong, 0) AS Soluong,
               ISNULL(tu.Dongia, 0) AS Dongia, CAST(0 AS DECIMAL(18,2)) AS Soluongle,
               CAST(0 AS DECIMAL(18,2)) AS Dongiale, ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
        FROM tbmk_Hopdongthucuong tu
        LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
        WHERE tu.Sohopdong = h.Sohopdong
        ORDER BY tu.STT, tu.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonThucUong],

    ISNULL((
        SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(dv.Soluong, 0) AS Soluong, ISNULL(dv.Dongia, 0) AS Dongia,
               ISNULL(dv.Ghichudichvu, N'') AS Ghichudichvu
        FROM tbmk_Hopdongdichvu dv
        LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
        WHERE dv.Sohopdong = h.Sohopdong
        ORDER BY dv.STT, dv.Mahang
        FOR JSON PATH
    ), '[]') AS [JsonDichVu],

    ISNULL((
        SELECT ps.Mahang, ISNULL(hh.Tenhang, ps.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(ps.Soluong, 0) AS Soluong, ISNULL(ps.Dongia, 0) AS Dongia,
               ISNULL(ps.GhiChuPhatSinh, N'') AS GhiChuPhatSinh
        FROM tbmk_HopdongPhatSinh ps
        LEFT JOIN dmHanghoa hh ON ps.Mahang = hh.Mahang
        WHERE ps.Sohopdong = h.Sohopdong
        FOR JSON PATH
    ), '[]') AS [JsonPhatSinh],
    (
        SELECT 
            hs.Sanhtiecid AS [Sanhtiecid],
            CAST(ISNULL(hs.IsSanhchinh, 0) AS BIT) AS [IsSanhchinh],
            hs.KieuSetup AS [KieuSetup],
            hs.Ghichuct AS [Ghichuct]
        FROM tbmk_Hopdongsanhtiec hs 
        WHERE hs.Sohopdong = h.Sohopdong 
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [JsonSanhTiec],
    
    -- ==========================================
    -- CÁC CỘT DỮ LIỆU ĐƯỢC FORMAT SẴN CHO IN ẤN
    -- Dùng để binding vào file hop_dong.docx (docxtemplater)
    -- ==========================================
    -- (Đã có sẵn h.Sohopdong ở trên nên không cần tạo SoHopDong nữa, trong Word sẽ dùng biến {Sohopdong})
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Thông tin Bên A (có _ cho hop_dong.docx cũ)
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), N'Nguyễn Văn A') AS [BenANguoiDaiDien],
    ISNULL(NULLIF((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien'), ''), N'Nguyễn Văn A') AS [BenADaiDien],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), N'Giám đốc')) AS [BenAChucVu],
    ISNULL(
        (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = h.Manv OR nv.USERNAME = h.Manv),
        ISNULL(
            (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.USERNAME = h.UserCreate),
            ISNULL(h.UserCreate, h.Manv)
        )
    ) AS [BenANhanVienPhuTrach],
    ISNULL(
        (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.Manv = h.Manv OR nv.USERNAME = h.Manv),
        ISNULL(
            (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.USERNAME = h.UserCreate),
            ISNULL(
                (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com3'),
                ISNULL(
                    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT'),
                    ''
                )
            )
        )
    ) AS [BenASDTNhanVien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAEmail')  AS [BenAEmail],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenAMST') AS [BenAMST],


    -- Thông tin Bên B
    ISNULL(NULLIF(k.Nguoigd, ''), CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
            THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END) AS [BenBTenDaiDien],
    ISNULL(h.NguoinhanTT, CASE WHEN k.Tenchure <> '' AND k.Tencodau <> '' THEN k.Tenchure + ' & ' + k.Tencodau ELSE ISNULL(k.Tenkh, N'Khách vãng lai') END) AS [BenBTenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenBCCCD],
    ISNULL(k.Diachi, '...') AS [BenBDiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],

    -- Thông tin Tiệc
    ISNULL(h.TuGioDenGioSetup, '...') AS [SetupBatDau],
    ISNULL(h.DenGioSetup, '...') AS [SetupKetThuc],
    N'Vào hàng hóa' AS [SetupNoiDung1],
    ISNULL(h.GhiChuSetup, N'SETUP: Không máy lạnh') AS [SetupNoiDung2],
    N'RHS: Có ATAS, Led; không máy lạnh' AS [ToChucNoiDung],
    N'Ra hàng hóa' AS [OutNoiDung],
    ISNULL(h.GioDienRaSuKien, '...') AS [TiecGioBatDau],
    ISNULL(FORMAT(h.NgayTraSanhDV, 'HH:mm'), '') AS [TiecGioKetThuc],
    ISNULL(h.TongSoBan * 10, 0) AS [SoKhachDiemDanh],

    -- Các trường lịch trình động dạng JSON phục vụ in ấn BEO mới
    -- Nếu đã có JsonLichTrinh lưu trong DB thì ưu tiên lấy, ngược lại trả về mảng rỗng []
    ISNULL(NULLIF(h.JsonLichTrinh, ''), '[]') AS [LichTrinh],
    
    (
        SELECT 
            t.STT AS [STT],
            t.SoTien AS [SoTien],
            t.Ngay AS [Ngay],
            t.NoiDung AS [NoiDung]
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
                ISNULL(NULLIF(h.Ghichu, ''), 
                    CASE 
                        WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Hội Nghị%' 
                            THEN N'Thanh toán sau tiệc 07 ngày' 
                        ELSE N'Thanh toán cuối tiệc.' 
                    END
                ) AS NoiDung
        ) t
        ORDER BY t.STT
        FOR JSON PATH
    ) AS [LichTrinhThanhToan],
    
    (
        SELECT 
            CASE WHEN hs.IsSanhchinh = 1 THEN N'Hội nghị / Tiệc chính' ELSE N'Tiệc' END AS [LoaiPhong],
            s.Tensanhtiec AS [TenSanh],
            ISNULL(CAST(s.ChieuRong AS NVARCHAR), '...') AS [ChieuRong],
            ISNULL(CAST(s.ChieuDai AS NVARCHAR), '...') AS [ChieuDai],
            ISNULL(CAST(s.ChieuCaoTran AS NVARCHAR), '...') AS [ChieuCaoTran],
            ISNULL(s.KTSanKhau, '...') AS [KTSanKhau],
            CASE 
                WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0)
                WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0)
                WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0)
                ELSE ISNULL(s.SLBanMax * 10, 0)
            END AS [SucchuaMax],
            ISNULL(s.SLBanMin * 10, 0) AS [SucchuaMin],
            CASE 
                WHEN hs.KieuSetup = 'ClassRoom' THEN N'Lớp học'
                WHEN hs.KieuSetup = 'Theater' THEN N'Nhà hát'
                WHEN hs.KieuSetup = 'Cluster' THEN N'Bàn tròn xoay 1 phía'
                ELSE N'Bàn tròn (Banquet)'
            END + 
            CASE 
                WHEN ISNULL(hs.Ghichuct, '') <> '' THEN N' (' + hs.Ghichuct + N')'
                ELSE N''
            END AS [SetupBanGhe]
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid ASC
        FOR JSON PATH
    ) AS [DanhSachSanh],
    
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecNgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [TiecThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [TiecNamDL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
        ELSE ISNULL(h.Nhamngay, '...')
    END AS [TiecNgayAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 
            THEN CASE 
                WHEN CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0 
                    THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) - CHARINDEX('/', h.Nhamngay) - 1)
                ELSE SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
            END
        ELSE '...'
    END AS [TiecThangAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 AND CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) > 0
            THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1) + 1, LEN(h.Nhamngay))
        ELSE '...'
    END AS [TiecNamAL],
    
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TenSanhTiec],
    (SELECT TOP 1 s.SLBanMin FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMin],
    (SELECT TOP 1 s.SLBanMax FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [SanhQuyMoMax],
    
    -- Tên loại hình tiệc (computed từ dmLoaihinhtiec, dùng cho in ấn Word)
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), '') AS [TiecLoaiTiec],
    ISNULL(h.LoaiHinhSuKien, ISNULL((
        SELECT 
            CASE 
                -- Nếu có sảnh 2 và loại hình tiệc có 2 phần (dấu +)
                WHEN ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '') <> '' 
                     AND CHARINDEX('+', lt.Tenloaitiec) > 0
                    THEN 
                        RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, 1, CHARINDEX('+', lt.Tenloaitiec) - 1))) 
                        + ' ' 
                        + (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid)
                        + ' + ' 
                        + RTRIM(LTRIM(SUBSTRING(lt.Tenloaitiec, CHARINDEX('+', lt.Tenloaitiec) + 1, LEN(lt.Tenloaitiec)))) 
                        + ' ' 
                        + (SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
                -- Nếu chỉ có 1 sảnh
                ELSE 
                    lt.Tenloaitiec 
                    + ' ' 
                    + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid), '')
            END
        FROM dmLoaihinhtiec lt 
        WHERE lt.Loaitiecid = h.Loaitiecid
    ), '')) AS [LoaiHinhSuKien],
    
    ISNULL(h.SobanManchinhthuc, 0) + ISNULL(h.SobanChaychinhthuc, 0) AS [TiecSoBanChinhThuc],
    ISNULL(h.SoBanTang, 0) AS [TiecSoBanTang],
    ISNULL(h.SobanManduphong, 0) + ISNULL(h.SobanChayduphong, 0) AS [TiecSoBanDuPhong],
    ISNULL(h.SoNguoiTrenBan, 10) AS [TiecSoKhach1Ban],
    
    -- Thông tin Cá»c & Khuyến mãi
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') AS [CocLan1SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [CocLan1BangChu],
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [CocLan2SoTien],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencochopdong, 0)) AS [CocLan2BangChu],
    RIGHT('0' + CAST(DAY(h.Ngayhopdong) AS VARCHAR), 2) AS [CocNgay],
    RIGHT('0' + CAST(MONTH(h.Ngayhopdong) AS VARCHAR), 2) AS [CocThang],
    CAST(YEAR(h.Ngayhopdong) AS VARCHAR) AS [CocNam],
    
    -- Các biến phục vụ hiển thị động Phương thức thanh toán (BEO)
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot1SoTien],
    ISNULL(CONVERT(VARCHAR(10), (
        SELECT TOP 1 b.DocumentDate 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), 103), '...') AS [Dot1Ngay],
    ISNULL((
        SELECT TOP 1 NULLIF(b.HinhThuc, '') 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), N'Chuyển khoản') AS [Dot1HinhThuc],
    
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot2SoTien],
    N'Chuyển khoản' AS [Dot2HinhThuc],
    
    ISNULL(NULLIF(h.Ghichu, ''), 
        CASE 
            WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Hội Nghị%' 
                THEN N'Thanh toán sau tiệc 07 ngày' 
            ELSE N'Thanh toán cuối tiệc.' 
        END
    ) AS [DotCuoiGhiChu],
    


    -- Các biến tính tổng tiền
    FORMAT(ISNULL(h.TongTienHopDongChuaVAT, 0) - ISNULL(h.TongTienPhiPhucVu, 0), 'N0', 'vi-VN') AS [TongThanhTien],
    CAST(ISNULL(h.PhiPhucVu, 0) AS VARCHAR) + '%' AS [MucPhiPhucVu],
    FORMAT(ISNULL(h.TongTienPhiPhucVu, 0), 'N0', 'vi-VN') AS [PhiPhucVu],
    FORMAT(ISNULL(h.TongTienHopDongChuaVAT, 0), 'N0', 'vi-VN') AS [TongCongChuaVAT],
    CASE WHEN h.PTThueVAT = 8 THEN FORMAT(ISNULL(h.TienThueVAT, 0), 'N0', 'vi-VN') ELSE '0' END AS [VAT8],
    CASE WHEN h.PTThueVAT = 10 THEN FORMAT(ISNULL(h.TienThueVAT, 0), 'N0', 'vi-VN') ELSE '0' END AS [VAT10],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongTienFormat],

    ISNULL(h.DieuKhoanBoSung, N'- Áp dụng thực đơn tự chọn theo bảng giá lẻ (chưa bao gồm phí phục vụ).
- Áp dụng chương trình đặt 10 bàn tặng 01 bàn (từ 20 bàn trở lên)
Tất cả các chương trình khuyến mãi và ưu đãi trên không quy đổi thành tiền mặt và không thay thế bằng dịch vụ khác nếu quý khách không sử dụng.') AS [DieuKhoanBoSung],
    ISNULL(NULLIF(h.Noidunguudai, ''), 
        ISNULL((
            SELECT STUFF((
                SELECT CHAR(10) + CAST(ROW_NUMBER() OVER(ORDER BY ct.STT) AS VARCHAR(10)) + '. ' + ISNULL(hh.Tenhang, ct.Mahang) + 
                       CASE WHEN ISNULL(ct.Soluong, 1) > 1 THEN ' (SL: ' + CAST(CAST(ct.Soluong AS INT) AS VARCHAR(10)) + ')' ELSE '' END
                FROM tbmk_Banuudaict ct
                LEFT JOIN dmHanghoa hh ON ct.Mahang = hh.Mahang
                WHERE ct.DocumentID = (
                    SELECT TOP 1 ud.DocumentID
                    FROM tbmk_Banuudai ud
                    WHERE ud.Loaitiecid = h.Loaitiecid
                      AND ISNULL(h.TongSoBan, 0) >= ud.Tusoluongban 
                      AND ISNULL(h.TongSoBan, 0) <= ud.Densoluongban
                      AND (ud.IsKetthuc IS NULL OR ud.IsKetthuc = 0)
                    ORDER BY ud.Tusoluongban DESC
                )
                ORDER BY ct.STT ASC
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
        ), '')
    ) AS [DSKhuyenMai],

    -- ==========================================
    -- THÔNG TIN XUẤT HÓA ĐƠN GTGT (Điều 6)
    -- ==========================================
    -- Nếu chưa điền riêng thì tự lấy từ thông tin khách hàng
    ISNULL(NULLIF(h.TenCtyHoaDon, ''),    ISNULL(k.Tenkh,  N'...')) AS [HDTenCty],
    ISNULL(NULLIF(h.DiaChiCtyHoaDon, ''), ISNULL(k.Diachi, N'...')) AS [HDDiaChi],
    ISNULL(NULLIF(h.MaSoThueHoaDon, ''),  N'...') AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [Email],

    -- Menu / dịch vụ cho docx (fn_DOCX_* — sql/Functions/fn_DOCX_MenuDichVu.sql)
    dbo.fn_DOCX_DanhSachMenu(h.Sohopdong)     AS [DanhSachMenu],
    dbo.fn_DOCX_DanhSachThucUong(h.Sohopdong) AS [DanhSachThucUong],
    dbo.fn_DOCX_MenuTiec(h.Sohopdong)         AS [MenuTiec],
    dbo.fn_DOCX_MenuTongCong(h.Sohopdong)     AS [MenuTongCong],
    dbo.fn_DOCX_DichVuTinhPhi(h.Sohopdong)    AS [DichVuTinhPhi],
    dbo.fn_DOCX_DanhSachNgay(h.Sohopdong)     AS [DanhSachNgay],
    dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong)   AS [DanhSachDichVu],

    -- Tổng giá trị tạm tính bằng chữ
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriTamTinhBangChu],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],

    -- Các biến tùy chỉnh ánh xạ trực tiếp đến các file Word mẫu (tránh lệch chữ hoa/thường hoặc thiếu trường)
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong) AS [TiecSanhTiec],
    ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien'), N'Giám đốc')) AS [BenAChucVuDaiDien],
    k.Mail AS [BenBEmail],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Sotiencoccho, 0)) AS [Dot1BangChu],
    ISNULL((SELECT TOP 1 s.SLBanMin * ISNULL(h.SoNguoiTrenBan, 10) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong), 0) AS [KhachToiThieu],
    ISNULL((SELECT TOP 1 CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [KichThuocSanh],
    ISNULL((SELECT CAST(s.ChieuRong AS VARCHAR) + 'm x ' + CAST(s.ChieuDai AS VARCHAR) + 'm' FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [KichThuocSanhPhu],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [KichThuocSanKhau],
    ISNULL((SELECT s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [KichThuocSanKhauPhu],
    STUFF((
        SELECT N', ' + s.Tensanhtiec
        FROM tbmk_Hopdongsanhtiec hs
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhTiec],
    ISNULL((SELECT TOP 1 CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), 0) AS [SucChuaToiDa],
    ISNULL((SELECT CASE WHEN hs.KieuSetup = 'ClassRoom' THEN ISNULL(s.ClassRoom, 0) WHEN hs.KieuSetup = 'Theater' THEN ISNULL(s.Theater, 0) WHEN hs.KieuSetup = 'Cluster' THEN ISNULL(s.ClusterHalfRound, 0) ELSE ISNULL(s.SLBanMax * 10, 0) END FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), 0) AS [SucChuaToiDaPhu],
    ISNULL((SELECT ISNULL(s.SLBanMin * 10, 0) FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), 0) AS [SucChuaToiThieuPhu],
    ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '') AS [TenSanhTiecPhu],
    ISNULL((SELECT TOP 1 s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') AS [TenSanKhau],
    ISNULL((SELECT s.KTSanKhau FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') AS [TenSanKhauPhu],
    FORMAT(ISNULL((SELECT SUM(ISNULL(hd.Sotien, 0)) FROM tbmk_Hopdongdichvu hd WHERE hd.Sohopdong = h.Sohopdong), 0), 'N0', 'vi-VN') AS [TongTienDichVu],
    ISNULL(CONVERT(VARCHAR(10), (SELECT TOP 1 b.DocumentDate FROM tbmk_Biennhancoccho b WHERE b.DocumentID = h.Sobiennhan), 103), '...') AS [NgayThanhToanDatCoc],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [Sanh],
    FORMAT(ISNULL(h.Tongtienhopdong, 0) - ISNULL(h.Sotiencoccho, 0) - ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [SoTienConLai],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0) - ISNULL(h.Sotiencoccho, 0) - ISNULL(h.Sotiencochopdong, 0)) AS [SoTienConLaiBangChu],
    FORMAT(ISNULL(h.Sotiencoccho, 0) + ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') AS [SoTienDaDatCoc],
    FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongGiaTriQuyetToan],
    [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongGiaTriQuyetToanBangChu]

    -- , AS [DanhSachDV], AS [GhiChuChiTiet], AS [KhungGio], AS [TenDichVu], AS [TenMonAn], AS [TenNhomNgay], AS [ThanhTien], AS [UuDai]

FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO


UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachHopDong', SaveTableName = 'tbmk_Hopdong', PrimaryKey = 'Sohopdong'
WHERE FormID = 'frmHopDong';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
GO

-- 4.2. Đăng ký các định tuyến API trong WA_API
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Save',
    'API_LuuHopDong',
    '@Sohopdong=N''{Sohopdong}'', @Sobiennhan=N''{Sobiennhan}'', @Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @Dienthoai=N''{DienThoai}'', @Diachi=N''{Diachi}'', @Mail=N''{Mail}'', @BenBCCCD=N''{BenBCCCD}'', @Ngayhopdong=N''{Ngayhopdong}'', @Ngaytochuc=N''{NgayToChuc}'', @TuNgaySetup=N''{TuNgaySetup}'', @NgayTraSanhDV=N''{NgayTraSanhDV}'', @TenCongTy=N''{TenCongTy}'', @Nhamngay=N''{Nhamngay}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SetupBatDau=N''{SetupBatDau}'', @SetupKetThuc=N''{SetupKetThuc}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @TongSoBan=N''{SoBan}'', @Tongtienhopdong=N''{TongTien}'', @Sotiencoccho=N''{DaCocVND}'', @Sotiencochopdong=N''{Sotiencochopdong}'', @Tongtiencoc=N''{Tongtiencoc}'', @Ghichu=N''{Ghichu}'', @DieuKhoanBoSung=N''{DieuKhoanBoSung}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @JsonBanTiec=N''{JsonBanTiec}'', @JsonThucUong=N''{JsonThucUong}'', @JsonDichVu=N''{JsonDichVu}'', @JsonPhatSinh=N''{JsonPhatSinh}'', @BenBTenDaiDien=N''{BenBTenDaiDien}'', @LoaiHinhSuKien=N''{LoaiHinhSuKien}'''
);

DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Delete';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Delete',
    'API_XoaDong',
    '@List=N''frmHopDong'', @Ids=N''{Sohopdong}'', @UserName=N''{User}'''
);
GO

-- 4.3. Đăng ký API_DanhSachHopDong dùng riêng cho in Word (View)
DELETE FROM WA_API WHERE List = 'API_DanhSachHopDong' AND Func = 'View';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'API_DanhSachHopDong',
    'View',
    'API_DanhSachHopDong',
    '@TuNgay=N''{TuNgay}'', @DenNgay=N''{DenNgay}'', @Keyword=N''{Keyword}'', @Sohopdong=N''{Sohopdong}'''
);
GO

UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '6'
WHERE FormName = 'frmHopDong'
  AND FieldName IN ('Tenchure', 'Tencodau', 'Diachi', 'Mail');

UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '3'
WHERE FormName = 'frmHopDong'
  AND FieldName IN (
    'SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong'
  );

UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '4'
WHERE FormName = 'frmHopDong'
  AND FieldName IN (
    'Ngayhopdong', 'NgayToChuc', 'Nhamngay', 'Loaitiecid', 'Thoigianid',
    'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc'
  );

UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '6', ShowInGrid = 0
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';

-- Ghi chú bổ sung hiển thị ở Form dưới dạng textarea/textbox lớn
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'form'
WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

-- Điều khoản bổ sung hiển thị ở Form dưới dạng textarea/textbox lớn
UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'form', OrderNo = 95, FormatID = 'ta'
WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';

-- Ẩn các cột chỉ dùng để IN ẤN hoặc thông tin phụ khỏi giao diện Grid/Form
UPDATE SY_FormatFields
SET ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmHopDong' 
  AND FieldName IN (
    'NgayLapHD', 'ThangLapHD', 'NamLapHD', 'Id',
    'BenANhanVienPhuTrach', 'BenASDTNhanVien', 'BenAChucVu', 'BenANguoiDaiDien', 'BenADaiDien', 'BenATenCongTy', 'BenADiaChi', 'BenASDT', 'BenAEmail', 'BenAMST',
    'BenBTenChuTiec', 'BenBCCCD', 'BenBDiaChi', 'BenBDienThoai', 'BenBChucVu', 'BenBEmail',
    'TiecGioBatDau', 'TiecGioKetThuc', 'TiecNgayDL', 'TiecThangDL', 'TiecNamDL',
    'TiecNgayAL', 'TiecThangAL', 'TiecNamAL',
    'TenSanhTiec', 'SanhQuyMoMin', 'SanhQuyMoMax',
    'TiecSoBanChinhThuc', 'TiecSoBanTang', 'TiecSoBanDuPhong', 'TiecSoKhach1Ban',
    'CocLan1SoTien', 'CocLan1BangChu', 'CocNgay', 'CocThang', 'CocNam',
    'CocLan2SoTien', 'CocLan2BangChu',
    'DSKhuyenMai',
    'HDTenCty', 'HDDiaChi', 'HDMaSoThue', 'HDEmail',
    'TongGiaTriTamTinh', 'TongGiaTriTamTinhBangChu', 'SoKhachDiemDanh', 'LichTrinh',
    'LichTrinhSetup', 'LichTrinhToChuc', 'LichTrinhOut', 'LichTrinhThanhToan',
    'SetupBatDau', 'SetupKetThuc', 'SetupNoiDung1', 'SetupNoiDung2', 'ToChucNoiDung', 'OutNoiDung',
    'Dot1SoTien', 'Dot1Ngay', 'Dot1HinhThuc', 'Dot2SoTien', 'Dot2HinhThuc', 'DotCuoiGhiChu',
    'TongThanhTien', 'MucPhiPhucVu', 'PhiPhucVu', 'TongCongChuaVAT', 'VAT8', 'VAT10', 'TongTienFormat',
    'TemplateFile', 'JsonLichTrinh', 'SanhDat2', 'Giabanman', 'DanhSachSanh',
    'JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh', 'DanhSachMenu', 'DanhSachThucUong', 'MenuTiec', 'MenuTongCong',
    'DichVuTinhPhi', 'DanhSachNgay', 'DanhSachDichVu', 'Email',
    -- Các trường in ấn mới thêm
    'TiecSanhTiec', 'BenAChucVuDaiDien', 'BenBEmail', 'Dot1BangChu', 'KhachToiThieu',
    'KichThuocSanh', 'KichThuocSanhPhu', 'KichThuocSanKhau', 'KichThuocSanKhauPhu', 'SanhTiec',
    'SucChuaToiDa', 'SucChuaToiDaPhu', 'SucChuaToiThieuPhu', 'TenSanhTiecPhu', 'TenSanKhau',
    'TenSanKhauPhu', 'TongTienDichVu', 'NgayThanhToanDatCoc', 'Sanh', 'SoTienConLai',
    'SoTienConLaiBangChu', 'SoTienDaDatCoc', 'TongGiaTriQuyetToan', 'TongGiaTriQuyetToanBangChu'
  );

-- Cập nhật Label tiếng Việt có dấu cho các trường in ấn mới thêm
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Bên A - Chức vụ đại diện' WHERE FormName = 'frmHopDong' AND FieldName = 'BenAChucVuDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Bên B - Email' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBEmail';
UPDATE SY_FormatFields SET CaptionVN = N'Đợt 1 bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Khách tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'KhachToiThieu';
UPDATE SY_FormatFields SET CaptionVN = N'Kích thước sảnh' WHERE FormName = 'frmHopDong' AND FieldName = 'KichThuocSanh';
UPDATE SY_FormatFields SET CaptionVN = N'Kích thước sảnh phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'KichThuocSanhPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Kích thước sân khấu' WHERE FormName = 'frmHopDong' AND FieldName = 'KichThuocSanKhau';
UPDATE SY_FormatFields SET CaptionVN = N'Kích thước sân khấu phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'KichThuocSanKhauPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Sức chứa tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'SucChuaToiDa';
UPDATE SY_FormatFields SET CaptionVN = N'Sức chứa tối đa phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'SucChuaToiDaPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Sức chứa tối thiểu phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'SucChuaToiThieuPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Tên sảnh tiệc phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'TenSanhTiecPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Tên sân khấu' WHERE FormName = 'frmHopDong' AND FieldName = 'TenSanKhau';
UPDATE SY_FormatFields SET CaptionVN = N'Tên sân khấu phụ' WHERE FormName = 'frmHopDong' AND FieldName = 'TenSanKhauPhu';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền dịch vụ' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTienDichVu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày thanh toán đặt cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayThanhToanDatCoc';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền còn lại' WHERE FormName = 'frmHopDong' AND FieldName = 'SoTienConLai';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền còn lại bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'SoTienConLaiBangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền đã đặt cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'SoTienDaDatCoc';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng giá trị quyết toán' WHERE FormName = 'frmHopDong' AND FieldName = 'TongGiaTriQuyetToan';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng giá trị quyết toán bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'TongGiaTriQuyetToanBangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhTiec';


-- Đảm bảo trường NgayToChuc luôn tồn tại trong cấu hình Form kèm Trigger tính lịch âm
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc')
BEGIN
    INSERT INTO SY_FormatFields (
        FormatID, FieldName, FormName, CaptionVN, IsRequired, 
        FormPosition, OrderNo, ShowInAdd, ShowInEdit, 
        IsReadOnlyAdd, IsReadOnlyEdit, ValidateRule
    )
    VALUES (
        'dt', 'NgayToChuc', 'frmHopDong', N'Ngày tổ chức', 1, 
        '6', 1, 1, 1, 
        0, 0, 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
    );
END
ELSE
BEGIN
    UPDATE SY_FormatFields
    SET ValidateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
    WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
END
GO

-- 4.4. Cấu hình các trường tính toán tự động và chế độ Read-Only
-- Ẩn các trường tính toán tự động khỏi Form (chỉ hiện trên Grid lưới)
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName IN ('TenKhachHang', 'TiecLoaiTiec');

-- Khóa khi sửa đối với các thông tin cốt lõi
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('Makh', 'SoBan', 'SanhDat', 'TongTien', 'TrangThai', 'Sohopdong');

-- CCCD Bên B: lấy từ dmkhachhang, ẩn khỏi form/read-only khi sửa
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'BenBCCCD';

-- Bên A (thông tin nhà hàng): ẩn khỏi form HĐ và khóa nhập liệu
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('BenANguoiDaiDien', 'BenAChucVu');

-- Ẩn/Hiện và khóa (Read-Only) các trường mã tự sinh bởi database
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';

-- Khóa/Ẩn các trường đặt cọc theo đúng quy trình nghiệp vụ (Cọc lần 2 chỉ cập nhật qua Phụ lục)
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';

UPDATE SY_FormatFields
SET ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';

DELETE FROM WA_API WHERE List = 'API_DanhSachPhieuCoc_Dropdown';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachPhieuCoc_Dropdown', 'View', 'API_DanhSachPhieuCoc', '@Keyword=N''{Keyword}''');

UPDATE SY_FormatFields 
SET FormatID = 'sr',
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachPhieuCoc_Dropdown&Func=View',
    IsReadOnlyAdd = 0,
    IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
GO

-- 4.5. Định dạng dữ liệu (FormatID) cho các trường
UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName IN ('Tenchure', 'Tencodau', 'Diachi', 'Mail', 'BenBCCCD', 'Ghichu', 'TenCongTy', 'TieuDePhieu', 'SanhDat2', 'BenBTenDaiDien', 'LoaiHinhSuKien');
UPDATE SY_FormatFields SET FormatID = 'dt' WHERE FormName = 'frmHopDong' AND FieldName IN ('Ngayhopdong', 'NgayToChuc', 'TuNgaySetup', 'NgayTraSanhDV');
UPDATE SY_FormatFields SET FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET FormatID = 'sl' WHERE FormName = 'frmHopDong' AND FieldName IN ('Loaitiecid', 'Thoigianid');
UPDATE SY_FormatFields SET FormatID = 'ml' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET FormatID = 'n' WHERE FormName = 'frmHopDong' AND FieldName IN ('SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong');
UPDATE SY_FormatFields SET FormatID = 'mn' WHERE FormName = 'frmHopDong' AND FieldName IN ('DaCocVND', 'Sotiencochopdong', 'Tongtiencoc', 'TongTien', 'CocLan1SoTien', 'CocLan2SoTien', 'Dot1SoTien', 'Dot2SoTien', 'TongTienDichVu', 'TongGiaTriQuyetToan', 'SoTienConLai');
GO

-- 4.6. Cấu hình DataSource cho các trường dropdown
UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';

UPDATE SY_FormatFields
SET FormatID = 'tm', DataSource = NULL
WHERE FormName = 'frmHopDong' AND FieldName IN ('SetupBatDau', 'SetupKetThuc');

-- Đảm bảo SanhDat hiển thị đẹp trên Grid
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, OrderNo, ShowInAdd, ShowInEdit, ShowInFilter, IsReadOnlyAdd, IsReadOnlyEdit, ShowInGrid)
    VALUES ('frmHopDong', 'SanhDat', N'Sảnh đãi tiệc', 't', 'grid', 15, 0, 0, 1, 1, 1, 1);
END
ELSE
BEGIN
    UPDATE SY_FormatFields SET ShowInAdd = 0, ShowInEdit = 0, CaptionVN = N'Sảnh đãi tiệc', FormPosition = 'grid', OrderNo = 15, ShowInGrid = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
END
GO

-- 4.7. Cập nhật tên hiển thị tiếng Việt (CaptionVN)
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'ThangLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Năm lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NamLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tên công ty/Đơn vị' WHERE FormName = 'frmHopDong' AND FieldName = 'TenCongTy';
UPDATE SY_FormatFields SET CaptionVN = N'Tiêu đề phiếu' WHERE FormName = 'frmHopDong' AND FieldName = 'TieuDePhieu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày bắt đầu Setup' WHERE FormName = 'frmHopDong' AND FieldName = 'TuNgaySetup';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày trả sảnh' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayTraSanhDV';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh phụ (nếu có)' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat2';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu Setup', FormPosition = '3', OrderNo = 80, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'SetupBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Giờ kết thúc Setup', FormPosition = '3', OrderNo = 81, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'SetupKetThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Nội dung Setup 1', FormPosition = '12', OrderNo = 82 WHERE FormName = 'frmHopDong' AND FieldName = 'SetupNoiDung1';
UPDATE SY_FormatFields SET CaptionVN = N'Nội dung Setup 2', FormPosition = '12', OrderNo = 83 WHERE FormName = 'frmHopDong' AND FieldName = 'SetupNoiDung2';
UPDATE SY_FormatFields SET CaptionVN = N'Nội dung Tổ chức', FormPosition = '12', OrderNo = 84 WHERE FormName = 'frmHopDong' AND FieldName = 'ToChucNoiDung';
UPDATE SY_FormatFields SET CaptionVN = N'Nội dung Ra hàng', FormPosition = '12', OrderNo = 85 WHERE FormName = 'frmHopDong' AND FieldName = 'OutNoiDung';

UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmHopDong' AND FieldName = 'BenANhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên' WHERE FormName = 'frmHopDong' AND FieldName = 'BenASDTNhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenANguoiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenAChucVu';

UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên B', ShowInAdd = 1, ShowInEdit = 1, FormPosition = '6', OrderNo = 10 WHERE FormName = 'frmHopDong' AND FieldName = 'BenBTenDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Chủ Tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBTenChuTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBDiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBDienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBChucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD (Bên B)' WHERE FormName = 'frmHopDong' AND FieldName = 'BenBCCCD';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecGioBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNgayDL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecThangDL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNamDL';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNgayAL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecThangAL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecNamAL';

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'TenSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhQuyMoMin';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhQuyMoMax';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanChinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tặng' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanTang';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoBanDuPhong';
UPDATE SY_FormatFields SET CaptionVN = N'Số khách/Bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'TiecSoKhach1Ban';

UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 1' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan1SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan1BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan2SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2 bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'CocLan2BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocNgay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocThang';
UPDATE SY_FormatFields SET CaptionVN = N'Năm cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'CocNam';

UPDATE SY_FormatFields SET CaptionVN = N'Điều khoản bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';
UPDATE SY_FormatFields SET CaptionVN = N'Khuyến mãi' WHERE FormName = 'frmHopDong' AND FieldName = 'DSKhuyenMai';

UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể' WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Email' WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Nhằm ngày âm lịch' WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET CaptionVN = N'Loại hình tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Ca đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc chỗ (Lần 1)' WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc hợp đồng (Lần 2)' WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền cọc', ValidateRule = 'formula:{DaCocVND} + {Sotiencochopdong}' WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã KH' WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
GO

-- 4.8. Khởi tạo/Cập nhật các cột động đặc thù (LoaiHinhSuKien, Lịch trình, Note)
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'LoaiHinhSuKien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition, FormatID)
    VALUES ('frmHopDong', 'LoaiHinhSuKien', N'Loại hình sự kiện', 0, 0, 0, 95, 'hidden', 't');
ELSE
    UPDATE SY_FormatFields 
    SET CaptionVN = N'Loại hình sự kiện',
        ShowInAdd = 0,
        ShowInEdit = 0,
        ShowInFilter = 0,
        FormPosition = 'hidden',
        OrderNo = 95,
        FormatID = 't'
    WHERE FormName = 'frmHopDong' AND FieldName = 'LoaiHinhSuKien';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'LichTrinhThanhToan')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, DataSource, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'LichTrinhThanhToan', N'Lịch trình thanh toán', 'js', N'[{"key":"STT","label":"Đợt","type":"number","width":"60px"},{"key":"SoTien","label":"Số tiền","type":"text","width":"150px"},{"key":"Ngay","label":"Ngày","type":"text","width":"120px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]', 0, 0, 0, 99, '12');
ELSE
    UPDATE SY_FormatFields 
    SET CaptionVN = N'Lịch trình thanh toán',
        FormatID = 'js',
        DataSource = N'[{"key":"STT","label":"Đợt","type":"number","width":"60px"},{"key":"SoTien","label":"Số tiền","type":"text","width":"150px"},{"key":"Ngay","label":"Ngày","type":"text","width":"120px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]'
    WHERE FormName = 'frmHopDong' AND FieldName = 'LichTrinhThanhToan';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1SoTien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1SoTien', N'Số tiền đợt 1', 0, 0, 0, 100, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Số tiền đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1SoTien';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1Ngay')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1Ngay', N'Ngày thu đợt 1', 0, 0, 0, 101, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ngày thu đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1Ngay';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1HinhThuc')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1HinhThuc', N'Hình thức thu đợt 1', 0, 0, 0, 102, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thu đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1HinhThuc';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2SoTien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot2SoTien', N'Số tiền đợt 2', 0, 0, 0, 103, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Số tiền đợt 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2SoTien';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2HinhThuc')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot2HinhThuc', N'Hình thức thu đợt 2', 0, 0, 0, 104, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thu đợt 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2HinhThuc';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'DotCuoiGhiChu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'DotCuoiGhiChu', N'Ghi chú đợt cuối', 0, 0, 0, 105, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú đợt cuối' WHERE FormName = 'frmHopDong' AND FieldName = 'DotCuoiGhiChu';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBaoVe')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'NoteBaoVe', N'Ghi chú bảo vệ', 0, 0, 0, 106, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú bảo vệ' WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBaoVe';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteKyThuat')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'NoteKyThuat', N'Ghi chú kỹ thuật', 0, 0, 0, 107, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú kỹ thuật' WHERE FormName = 'frmHopDong' AND FieldName = 'NoteKyThuat';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBieuNgu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'NoteBieuNgu', N'Ghi chú biểu ngữ', 0, 0, 0, 108, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú biểu ngữ' WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBieuNgu';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteLobby')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'NoteLobby', N'Ghi chú đón khách (Lobby)', 0, 0, 0, 109, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú đón khách (Lobby)' WHERE FormName = 'frmHopDong' AND FieldName = 'NoteLobby';
GO

-- 4.9. Cấu hình thứ tự hiển thị (OrderNo) trên Form
UPDATE SY_FormatFields SET OrderNo = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET OrderNo = 2 WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET OrderNo = 3 WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET OrderNo = 4 WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET OrderNo = 5 WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 6 WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 7 WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET OrderNo = 8 WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 9 WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 10 WHERE FormName = 'frmHopDong' AND FieldName = 'BenBTenDaiDien';
UPDATE SY_FormatFields SET OrderNo = 11 WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET OrderNo = 12 WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 13 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 14 WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 15 WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET OrderNo = 16 WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET OrderNo = 161 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET OrderNo = 17 WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET OrderNo = 18 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET OrderNo = 19 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET OrderNo = 20 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET OrderNo = 21 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET OrderNo = 22 WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET OrderNo = 23 WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET OrderNo = 24 WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET OrderNo = 25 WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET OrderNo = 26 WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET OrderNo = 27 WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';
UPDATE SY_FormatFields SET OrderNo = 28 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonLichTrinh';
GO

-- 4.10. Cấu hình hiển thị động (VisibleRule) cho các trường Chú rể / Cô dâu
-- Chỉ hiển thị khi chọn loại tiệc là Tiệc cưới (BLT000001)
UPDATE SY_FormatFields
SET VisibleRule = 'Loaitiecid=BLT000001|blt000001'
WHERE FormName = 'frmHopDong' 
  AND FieldName IN ('Tenchure', 'Tencodau', 'DTchure', 'DTcodau');
GO

-- 4.11. Cấu hình các trường JSON Thực đơn & Dịch vụ (Cho FoodSelectionPlugin)
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'JsonBanTiec')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition, FormatID)
    VALUES ('frmHopDong', 'JsonBanTiec', N'Thực đơn', 1, 1, 0, 200, '6', 't');
ELSE
    UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonBanTiec';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'JsonThucUong')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition, FormatID)
    VALUES ('frmHopDong', 'JsonThucUong', N'Thức uống', 1, 1, 0, 201, '6', 't');
ELSE
    UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonThucUong';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'JsonDichVu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition, FormatID)
    VALUES ('frmHopDong', 'JsonDichVu', N'Dịch vụ', 1, 1, 0, 202, '6', 't');
ELSE
    UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonDichVu';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'JsonPhatSinh')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition, FormatID)
    VALUES ('frmHopDong', 'JsonPhatSinh', N'Phát sinh', 1, 1, 0, 203, '6', 't');
ELSE
    UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName = 'JsonPhatSinh';
GO

PRINT N'Cập nhật toàn bộ phân hệ Hợp đồng thành công!';
GO

-- Tự động gán file mẫu mặc định (hop_dong.docx) cho tất cả loại tiệc nếu chưa được cấu hình
INSERT INTO tbmk_LoaitiecAddfile (Loaitiecid, FormName, TemplateFile)
SELECT Loaitiecid, 'frmHopDong', 'hop_dong.docx'
FROM dmLoaihinhtiec
WHERE Loaitiecid NOT IN (
    SELECT Loaitiecid FROM tbmk_LoaitiecAddfile WHERE FormName = 'frmHopDong'
);
GO
