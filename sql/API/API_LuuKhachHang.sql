USE [QLTiec]
GO

-- =============================================
-- Mô tả: API Lưu (Thêm/Sửa) thông tin Khách hàng
-- IsEdit = 0: Thêm mới | IsEdit = 1: Cập nhật
-- =============================================
CREATE PROCEDURE [dbo].[API_LuuKhachHang]
    @NhomNguoiDangThaoTac NVARCHAR(50) = 'Admin',
    @Makh           VARCHAR(50)    = NULL,
    @Tenchure       NVARCHAR(255)  = NULL,
    @Tencodau       NVARCHAR(255)  = NULL,
    @DTchure        NVARCHAR(50)   = NULL,
    @DTcodau        NVARCHAR(50)   = NULL,
    @Dienthoai      NVARCHAR(50)   = NULL,
    @Mail           NVARCHAR(100)  = NULL,
    @Diachi         NVARCHAR(500)  = NULL,
    @Ghichu         NVARCHAR(2000) = NULL,
    @CCCD           VARCHAR(50)    = NULL,
    @Nguoigd        NVARCHAR(255)  = NULL,
    @UserCreate     VARCHAR(50)    = 'Admin',
    @IsEdit         TINYINT        = 0   -- 0: Thêm mới, 1: Cập nhật
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Now DATETIME = GETDATE();

        IF @IsEdit = 0
        BEGIN
            -- Kiểm tra trùng SĐT trước khi thêm mới (chỉ kiểm tra các SĐT không rỗng/NULL)
            IF EXISTS (
                SELECT 1 FROM dmkhachhang
                WHERE (
                    (@Dienthoai IS NOT NULL AND @Dienthoai <> '' AND (Dienthoai = @Dienthoai OR DTchure = @Dienthoai OR DTcodau = @Dienthoai))
                    OR (@DTchure IS NOT NULL AND @DTchure <> '' AND (Dienthoai = @DTchure OR DTchure = @DTchure OR DTcodau = @DTchure))
                    OR (@DTcodau IS NOT NULL AND @DTcodau <> '' AND (Dienthoai = @DTcodau OR DTchure = @DTcodau OR DTcodau = @DTcodau))
                )
            )
            BEGIN
                SELECT 1 AS [code], N'Số điện thoại đã tồn tại trong hệ thống!' AS [msg], NULL AS [Makh];
                RETURN;
            END

            -- Phát sinh Makh mới
            SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');

            INSERT INTO dmkhachhang (
                Makh, Tenkh, Tenchure, Tencodau,
                DTchure, DTcodau, Dienthoai, Mail, Diachi, Ghichu,
                IsKhachhang, DateCreate, UserCreate,
                CMNDDaiDien, CMNDnguoidd, Nguoigd
            )
            VALUES (
                @Makh,
                CASE
                    WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '')
                    ELSE ISNULL(@Tenchure, '') + ' & ' + @Tencodau
                END,
                @Tenchure, @Tencodau,
                @DTchure, @DTcodau,
                ISNULL(@Dienthoai, ISNULL(@DTchure, @DTcodau)),
                @Mail, @Diachi, @Ghichu,
                1, @Now, @UserCreate,
                @CCCD, @CCCD, @Nguoigd
            );
        END
        ELSE
        BEGIN
            -- Cập nhật
            UPDATE dmkhachhang
            SET
                Tenkh = CASE
                            WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '')
                            ELSE ISNULL(@Tenchure, '') + ' & ' + @Tencodau
                        END,
                Tenchure    = @Tenchure,
                Tencodau    = @Tencodau,
                DTchure     = @DTchure,
                DTcodau     = @DTcodau,
                Dienthoai   = ISNULL(@Dienthoai, ISNULL(@DTchure, @DTcodau)),
                Mail        = @Mail,
                Diachi      = @Diachi,
                Ghichu      = @Ghichu,
                CMNDDaiDien = @CCCD,
                CMNDnguoidd = @CCCD,
                Nguoigd     = @Nguoigd,
                DateUpdate  = @Now,
                UserUpdate  = @UserCreate
            WHERE Makh = @Makh;
        END

        SELECT 0 AS [code], N'Lưu thành công' AS [msg], @Makh AS [Makh];

    END TRY
    BEGIN CATCH
        SELECT 1 AS [code], ERROR_MESSAGE() AS [msg], NULL AS [Makh];
    END CATCH
END
GO
