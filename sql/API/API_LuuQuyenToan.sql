USE [QLTiec]
GO

IF OBJECT_ID('API_LuuQuyenToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuQuyenToan;
GO

-- Đảm bảo bảng tbmk_Phieuthuphatsinh tồn tại và đầy đủ cấu trúc cột
IF OBJECT_ID(N'[dbo].[tbmk_Phieuthuphatsinh]', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tbmk_Phieuthuphatsinh] (
        [UserAutoid] VARCHAR(50) NOT NULL PRIMARY KEY,
        [SPthu] VARCHAR(50) NULL,
        [Mahang] VARCHAR(30) NULL,
        [Soluong] DECIMAL(18,2) NULL,
        [Dongia] DECIMAL(18,2) NULL,
        [Sotien] DECIMAL(18,2) NULL,
        [UserCreate] VARCHAR(50) NULL,
        [DateCreate] DATETIME NULL,
        [GhiChuPhatSinh] NVARCHAR(500) NULL
    );
    PRINT N'Đã tạo bảng tbmk_Phieuthuphatsinh mới';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Phieuthuphatsinh]') AND name = 'GhiChuPhatSinh')
    BEGIN
        ALTER TABLE tbmk_Phieuthuphatsinh ADD GhiChuPhatSinh NVARCHAR(500) NULL;
        PRINT N'Đã thêm cột GhiChuPhatSinh cho bảng tbmk_Phieuthuphatsinh';
    END
END
GO


CREATE PROCEDURE [dbo].[API_LuuQuyenToan]
    @DocumentID VARCHAR(50) = NULL,
    @DocumentDate DATETIME = NULL,
    @Sohopdong VARCHAR(50) = NULL,
    @Nguoinop NVARCHAR(100) = NULL,
    @Tongtiencoc NVARCHAR(50) = '0',
    @TongtienHoaDon NVARCHAR(50) = '0',
    @Thanhtoan NVARCHAR(50) = '0',
    @Conlai NVARCHAR(50) = '0',
    @IsKetthuc NVARCHAR(50) = '0',
    @Ghichu NVARCHAR(500) = NULL,
    @User VARCHAR(50) = NULL,
    @BanPhatSinh NVARCHAR(50) = '0',
    @Sotienphatsinh NVARCHAR(50) = '0',
    @PhiBuSanh NVARCHAR(50) = '0',
    @PhiBuBantang NVARCHAR(50) = '0',
    @PhiBuTTS NVARCHAR(50) = '0',
    @PhiBuNTL NVARCHAR(50) = '0',
    @PhiPhucVu NVARCHAR(50) = '0',
    @PTThueVAT NVARCHAR(50) = '0',
    @TienThueVAT NVARCHAR(50) = '0',

    -- Các tham số JSON chi tiết gửi từ Frontend
    @JsonBanTiec NVARCHAR(MAX) = NULL,  -- Danh sách chi tiết món ăn/bàn tiệc
    @JsonThucUong NVARCHAR(MAX) = NULL, -- Danh sách chi tiết đồ uống tiêu dùng thực tế
    @JsonDichVu NVARCHAR(MAX) = NULL,   -- Danh sách chi tiết dịch vụ đi kèm
    @JsonPhatSinh NVARCHAR(MAX) = NULL  -- Danh sách chi tiết các phát sinh khác
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SPthu VARCHAR(20);
    DECLARE @Now DATETIME = GETDATE();

    -- Khai báo các biến kiểu số để tính toán/lưu trữ trong DB
    DECLARE @TongtiencocDec DECIMAL(18,2) = 0;
    DECLARE @TongtienHoaDonDec DECIMAL(18,2) = 0;
    DECLARE @ThanhtoanDec DECIMAL(18,2) = 0;
    DECLARE @ConlaiDec DECIMAL(18,2) = 0;
    DECLARE @IsKetthucBit BIT = 0;
    DECLARE @BanPhatSinhInt INT = 0;
    DECLARE @SotienphatsinhDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuSanhDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuBantangDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuTTSDec DECIMAL(18,2) = 0;
    DECLARE @PhiBuNTLDec DECIMAL(18,2) = 0;
    DECLARE @PhiPhucVuDec DECIMAL(18,2) = 0;
    DECLARE @PTThueVATDec DECIMAL(18,2) = 0;
    DECLARE @TienThueVATDec DECIMAL(18,2) = 0;

    -- Xử lý chuẩn hóa và parse số từ các tham số NVARCHAR (xóa bỏ dấu chấm phân tách phần nghìn, khoảng trắng, v.v.)
    SET @Tongtiencoc = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Tongtiencoc, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Tongtiencoc AS DECIMAL(18,2)) IS NOT NULL SET @TongtiencocDec = CAST(@Tongtiencoc AS DECIMAL(18,2));

    SET @TongtienHoaDon = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@TongtienHoaDon, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@TongtienHoaDon AS DECIMAL(18,2)) IS NOT NULL SET @TongtienHoaDonDec = CAST(@TongtienHoaDon AS DECIMAL(18,2));

    SET @Thanhtoan = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Thanhtoan, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Thanhtoan AS DECIMAL(18,2)) IS NOT NULL SET @ThanhtoanDec = CAST(@Thanhtoan AS DECIMAL(18,2));

    SET @Conlai = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Conlai, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Conlai AS DECIMAL(18,2)) IS NOT NULL SET @ConlaiDec = CAST(@Conlai AS DECIMAL(18,2));

    SET @IsKetthuc = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@IsKetthuc, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF @IsKetthuc = '1' OR @IsKetthuc = 'true' SET @IsKetthucBit = 1;

    SET @BanPhatSinh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@BanPhatSinh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@BanPhatSinh AS INT) IS NOT NULL SET @BanPhatSinhInt = CAST(@BanPhatSinh AS INT);

    SET @Sotienphatsinh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@Sotienphatsinh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@Sotienphatsinh AS DECIMAL(18,2)) IS NOT NULL SET @SotienphatsinhDec = CAST(@Sotienphatsinh AS DECIMAL(18,2));

    SET @PhiBuSanh = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuSanh, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuSanh AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuSanhDec = CAST(@PhiBuSanh AS DECIMAL(18,2));

    SET @PhiBuBantang = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuBantang, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuBantang AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuBantangDec = CAST(@PhiBuBantang AS DECIMAL(18,2));

    SET @PhiBuTTS = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuTTS, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuTTS AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuTTSDec = CAST(@PhiBuTTS AS DECIMAL(18,2));

    SET @PhiBuNTL = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiBuNTL, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiBuNTL AS DECIMAL(18,2)) IS NOT NULL SET @PhiBuNTLDec = CAST(@PhiBuNTL AS DECIMAL(18,2));

    SET @PhiPhucVu = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PhiPhucVu, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PhiPhucVu AS DECIMAL(18,2)) IS NOT NULL SET @PhiPhucVuDec = CAST(@PhiPhucVu AS DECIMAL(18,2));

    SET @PTThueVAT = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@PTThueVAT, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@PTThueVAT AS DECIMAL(18,2)) IS NOT NULL SET @PTThueVATDec = CAST(@PTThueVAT AS DECIMAL(18,2));

    SET @TienThueVAT = REPLACE(REPLACE(REPLACE(ISNULL(NULLIF(@TienThueVAT, ''), '0'), '.', ''), ',', ''), ' ', '');
    IF TRY_CAST(@TienThueVAT AS DECIMAL(18,2)) IS NOT NULL SET @TienThueVATDec = CAST(@TienThueVAT AS DECIMAL(18,2));

    -- Chuẩn hóa các tham số JSON chi tiết
    IF (@JsonBanTiec = '.' OR @JsonBanTiec = '' OR @JsonBanTiec = '[]') SET @JsonBanTiec = NULL;
    IF (@JsonBanTiec IS NOT NULL AND (LEFT(LTRIM(@JsonBanTiec), 1) <> '[' OR ISJSON(@JsonBanTiec) = 0)) SET @JsonBanTiec = '[' + @JsonBanTiec + ']';

    IF (@JsonThucUong = '.' OR @JsonThucUong = '' OR @JsonThucUong = '[]') SET @JsonThucUong = NULL;
    IF (@JsonThucUong IS NOT NULL AND (LEFT(LTRIM(@JsonThucUong), 1) <> '[' OR ISJSON(@JsonThucUong) = 0)) SET @JsonThucUong = '[' + @JsonThucUong + ']';

    IF (@JsonDichVu = '.' OR @JsonDichVu = '' OR @JsonDichVu = '[]') SET @JsonDichVu = NULL;
    IF (@JsonDichVu IS NOT NULL AND (LEFT(LTRIM(@JsonDichVu), 1) <> '[' OR ISJSON(@JsonDichVu) = 0)) SET @JsonDichVu = '[' + @JsonDichVu + ']';

    IF (@JsonPhatSinh = '.' OR @JsonPhatSinh = '' OR @JsonPhatSinh = '[]') SET @JsonPhatSinh = NULL;
    IF (@JsonPhatSinh IS NOT NULL AND (LEFT(LTRIM(@JsonPhatSinh), 1) <> '[' OR ISJSON(@JsonPhatSinh) = 0)) SET @JsonPhatSinh = '[' + @JsonPhatSinh + ']';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Lưu hoặc cập nhật bảng mẹ (tbmk_Phieuthu)
        IF @DocumentID IS NULL OR @DocumentID = ''
        BEGIN
            SET @DocumentID = 'QT' + FORMAT(@Now, 'yyMMddHHmmss');
            SET @SPthu = @DocumentID;
            
            INSERT INTO tbmk_Phieuthu (
                DocumentID, DocumentDate, SPthu, Ngaythu, Sohopdong, Nguoinop, Manv, 
                Tongtiencoc, TongtienHoaDon, Thanhtoan, Conlai, IsKetthuc, Ghichu, 
                Sotienphatsinh, PhiBuSanh, PhiBuBantang, PhiBuTTS, PhiBuNTL, PhiPhucVu, PTThueVAT, TienThueVAT,
                UserCreate, DateCreate
            )
            VALUES (
                @DocumentID, ISNULL(@DocumentDate, @Now), @SPthu, ISNULL(@DocumentDate, @Now), @Sohopdong, @Nguoinop, @User,
                @TongtiencocDec, @TongtienHoaDonDec, @ThanhtoanDec, @ConlaiDec, @IsKetthucBit, @Ghichu,
                @SotienphatsinhDec, @PhiBuSanhDec, @PhiBuBantangDec, @PhiBuTTSDec, @PhiBuNTLDec, @PhiPhucVuDec, @PTThueVATDec, @TienThueVATDec,
                @User, @Now
            );
        END
        ELSE
        BEGIN
            SET @SPthu = @DocumentID;
            
            UPDATE tbmk_Phieuthu
            SET DocumentDate = ISNULL(@DocumentDate, DocumentDate),
                Ngaythu = ISNULL(@DocumentDate, Ngaythu),
                Sohopdong = ISNULL(@Sohopdong, Sohopdong),
                Nguoinop = ISNULL(@Nguoinop, Nguoinop),
                Tongtiencoc = @TongtiencocDec,
                TongtienHoaDon = @TongtienHoaDonDec,
                Thanhtoan = @ThanhtoanDec,
                Conlai = @ConlaiDec,
                IsKetthuc = @IsKetthucBit,
                Ghichu = ISNULL(@Ghichu, Ghichu),
                Sotienphatsinh = @SotienphatsinhDec,
                PhiBuSanh = @PhiBuSanhDec,
                PhiBuBantang = @PhiBuBantangDec,
                PhiBuTTS = @PhiBuTTSDec,
                PhiBuNTL = @PhiBuNTLDec,
                PhiPhucVu = @PhiPhucVuDec,
                PTThueVAT = @PTThueVATDec,
                TienThueVAT = @TienThueVATDec,
                UserUpdate = @User,
                DateUpdate = @Now
            WHERE DocumentID = @DocumentID;
        END

        -- 2. Lưu chi tiết món ăn/bàn tiệc (tbmk_Phieuthubantiec)
        IF @JsonBanTiec IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthubantiec WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthubantiec (
                UserAutoid, DocumentID, SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, ThanhTien, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @DocumentID, @SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), (Soluong * Dongia - ISNULL(Sotiengiamgia, 0)), @User, @Now
            FROM OPENJSON(@JsonBanTiec)
            WITH (
                Mahang VARCHAR(30),
                TenHang NVARCHAR(460),
                DvtID NVARCHAR(100),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 3. Lưu chi tiết thức uống (tbmk_Phieuthuthucuong)
        IF @JsonThucUong IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuthucuong WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuthucuong (
                UserAutoid, SPthu, Mahang, IsKhuyenmai, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, Soluongle, Dongiale, Ghichuthucuong, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, ISNULL(IsKhuyenmai, 0), Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), ISNULL(Soluongle, 0), ISNULL(Dongiale, 0), Ghichuthucuong, @User, @Now
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(30),
                IsKhuyenmai BIT,
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2),
                Soluongle DECIMAL(18,2),
                Dongiale DECIMAL(18,2),
                Ghichuthucuong NVARCHAR(500)
            );
        END

        -- 4. Lưu chi tiết dịch vụ (tbmk_PhieuthuDichvu)
        IF @JsonDichVu IS NOT NULL
        BEGIN
            DELETE FROM tbmk_PhieuthuDichvu WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_PhieuthuDichvu (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, Giamgia, Sotiengiamgia, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), @User, @Now
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 5. Lưu chi tiết phát sinh (tbmk_Phieuthuphatsinh)
        IF @JsonPhatSinh IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuphatsinh WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuphatsinh (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, UserCreate, DateCreate, GhiChuPhatSinh
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), @User, @Now, GhiChuPhatSinh
            FROM OPENJSON(@JsonPhatSinh)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                GhiChuPhatSinh NVARCHAR(500)
            );
        END

        IF @IsKetthucBit = 1 AND @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET IsKetthuc = 1, Conlai = @ConlaiDec, BanPhatSinh = @BanPhatSinhInt
            WHERE Sohopdong = @Sohopdong;
        END
        ELSE IF @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET BanPhatSinh = @BanPhatSinhInt
            WHERE Sohopdong = @Sohopdong;
        END

        COMMIT TRANSACTION;

        -- Trả về dòng vừa lưu để Frontend đồng bộ lại giao diện
        SELECT * FROM tbmk_Phieuthu WHERE DocumentID = @DocumentID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
