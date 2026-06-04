USE [QLTiec]
GO

IF OBJECT_ID('API_LuuQuyenToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuQuyenToan;
GO

CREATE PROCEDURE [dbo].[API_LuuQuyenToan]
    @DocumentID VARCHAR(50) = NULL,
    @DocumentDate DATETIME = NULL,
    @Sohopdong VARCHAR(50) = NULL,
    @Nguoinop NVARCHAR(100) = NULL,
    @Tongtiencoc DECIMAL(18,2) = 0,
    @TongtienHoaDon DECIMAL(18,2) = 0,
    @Thanhtoan DECIMAL(18,2) = 0,
    @Conlai DECIMAL(18,2) = 0,
    @IsKetthuc BIT = 0,
    @Ghichu NVARCHAR(500) = NULL,
    @User VARCHAR(50) = NULL,

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
                UserCreate, DateCreate
            )
            VALUES (
                @DocumentID, ISNULL(@DocumentDate, @Now), @SPthu, ISNULL(@DocumentDate, @Now), @Sohopdong, @Nguoinop, @User,
                @Tongtiencoc, @TongtienHoaDon, @Thanhtoan, @Conlai, @IsKetthuc, @Ghichu,
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
                Tongtiencoc = ISNULL(@Tongtiencoc, Tongtiencoc),
                TongtienHoaDon = ISNULL(@TongtienHoaDon, TongtienHoaDon),
                Thanhtoan = ISNULL(@Thanhtoan, Thanhtoan),
                Conlai = ISNULL(@Conlai, Conlai),
                IsKetthuc = ISNULL(@IsKetthuc, IsKetthuc),
                Ghichu = ISNULL(@Ghichu, Ghichu),
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

        -- 6. Tự động cập nhật trạng thái của Hợp đồng nếu phiếu thu báo kết thúc
        IF @IsKetthuc = 1 AND @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET IsKetthuc = 1, Conlai = @Conlai
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
