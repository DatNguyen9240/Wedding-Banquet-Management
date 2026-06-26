USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-05-19
-- Description: API Lưu (Thêm/Sửa) Hợp Đồng Tiệc Cưới (LoaiPhieu = 2)
-- =============================================
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
    @Manv VARCHAR(20) = NULL,
    @UserCreate VARCHAR(20) = 'System',
    
    -- Danh sách Sảnh đặt (Dạng JSON: [{"Sanhtiecid":"S01", "IsSanhchinh": 1}, ...])
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    @JsonBanTiec NVARCHAR(MAX) = NULL,
    @JsonThucUong NVARCHAR(MAX) = NULL,
    @JsonDichVu NVARCHAR(MAX) = NULL,
    @JsonPhatSinh NVARCHAR(MAX) = NULL,
    
    -- Các trường mở rộng từ UI form (bỏ trống không lưu hoặc lưu nếu cần)
    @DieuKhoanBoSung NVARCHAR(MAX) = NULL,
    @BenBTenDaiDien NVARCHAR(255) = NULL,
    @LoaiHinhSuKien NVARCHAR(255) = NULL
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
        SET @NgayHopDongParsed = COALESCE(
            TRY_CAST(@Ngayhopdong AS DATETIME),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 126),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 120),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 23),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 103),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 105),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 111),
            TRY_CONVERT(DATETIME, @Ngayhopdong, 101)
        );
    END
    IF (@Ngaytochuc IS NOT NULL)
    BEGIN
        SET @NgayToChucParsed = COALESCE(
            TRY_CAST(@Ngaytochuc AS DATETIME),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 126),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 120),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 23),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 103),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 105),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 111),
            TRY_CONVERT(DATETIME, @Ngaytochuc, 101)
        );
    END
    
    DECLARE @TuNgaySetupParsed DATETIME = NULL;
    IF (@TuNgaySetup IS NOT NULL)
    BEGIN
        SET @TuNgaySetupParsed = COALESCE(
            TRY_CAST(@TuNgaySetup AS DATETIME),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 126),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 120),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 23),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 103),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 105),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 111),
            TRY_CONVERT(DATETIME, @TuNgaySetup, 101)
        );
    END
    
    DECLARE @NgayTraSanhDVParsed DATETIME = NULL;
    IF (@NgayTraSanhDV IS NOT NULL)
    BEGIN
        SET @NgayTraSanhDVParsed = COALESCE(
            TRY_CAST(@NgayTraSanhDV AS DATETIME),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 126),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 120),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 23),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 103),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 105),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 111),
            TRY_CONVERT(DATETIME, @NgayTraSanhDV, 101)
        );
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
                INSERT INTO dmkhachhang (Makh, Tenkh, Tenchure, Tencodau, Dienthoai, Diachi, Mail, CMNDDaiDien, CMNDchure, CMNDcodau, IsKhachhang, DateCreate, UserCreate)
                VALUES (@Makh, CASE WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure,'') ELSE ISNULL(@Tenchure,'') + ' & ' + ISNULL(@Tencodau,'') END,
                    @Tenchure, @Tencodau, @Dienthoai, @Diachi, @Mail, @BenBCCCD, @BenBCCCD, @BenBCCCD, 1, @Now, @UserCreate);
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
                Manv, Ghichu, IsHuy, IsKetthuc, DateCreate, UserCreate, GoiThucDonID
            )
            VALUES (
                @Sohopdong, @Sobiennhan, ISNULL(@NgayHopDongParsed,@Now), @NgayToChucParsed, @Nhamngay, @Makh, @Loaitiecid, @Thoigianid,
                @TuNgaySetupParsed, @NgayTraSanhDVParsed, @SetupBatDau, @SetupKetThuc,
                @SobanManchinhthucVal, @SobanManduphongVal, @SobanChaychinhthucVal, @SobanChayduphongVal, @TongSoBanVal,
                @TongtienhopdongVal, @SotiencocchoVal, @SotiencochopdongVal, @TongtiencocVal,
                @Manv, @Ghichu, 0, 0, @Now, @UserCreate, ''
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
                SELECT 0 AS [Success], N'Lỗi: Không thể chỉnh sửa hợp đồng đã quyết toán hoặc đã kết thúc/hủy!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
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
                Tongtiencoc=@TongtiencocVal, Ghichu=@Ghichu, DateUpdate=@Now, UserUpdate=@UserCreate
            WHERE Sohopdong=@Sohopdong;
        END

        -- 3. XU LY SANH TIEC
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DELETE FROM tbmk_Hopdongsanhtiec WHERE Sohopdong=@Sohopdong;
            INSERT INTO tbmk_Hopdongsanhtiec (
                UserAutoid, Sohopdong, Sanhtiecid, IsSanhchinh, 
                KieuSetup, Ghichuct, DateCreate, UserCreate
            )
            SELECT 
                NEWID(), 
                @Sohopdong, 
                JSON_VALUE(value, '$.Sanhtiecid'),
                ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0),
                JSON_VALUE(value, '$.KieuSetup'),
                JSON_VALUE(value, '$.Ghichuct'),
                @Now,
                @UserCreate
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
                UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio, IsPhan
            )
            SELECT
                NEWID(), @Sohopdong, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia,
                @UserCreate, @Now, NULL, 0, 0
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
                IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT, Dvt
            )
            SELECT
                NEWID(), @Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), @UserCreate, @Now,
                ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), hh.DVTID
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

        -- 5. LƯU MÓN PHÁT SINH TRỰC TIẾP VÀO HỢP ĐỒNG
        IF (@JsonPhatSinh IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_HopdongPhatSinh WHERE Sohopdong = @Sohopdong;
            INSERT INTO tbmk_HopdongPhatSinh (
                UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien,
                GhiChuPhatSinh, UserCreate, DateCreate
            )
            SELECT
                NEWID(), @Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                j.GhiChuPhatSinh, @UserCreate, @Now
            FROM OPENJSON(@JsonPhatSinh)
            WITH (
                Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                GhiChuPhatSinh NVARCHAR(500)
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
