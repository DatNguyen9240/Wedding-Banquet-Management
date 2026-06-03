USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      Antigravity
-- Create date: 2026-04-29
-- Description: API Lưu (Thêm/Sửa) Biên nhận cọc chỗ (Cọc lần 1 & Lần 2)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_LuuPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_LuuPhieuCoc];
END
GO
CREATE PROCEDURE [dbo].[API_LuuPhieuCoc]
    @DocumentID VARCHAR(50) = NULL OUTPUT, -- Nếu NULL: Thêm mới, Ngược lại: Cập nhật
    -- Thông tin Khách hàng
    @Makh VARCHAR(50) = NULL OUTPUT, -- Nếu NULL: Tạo khách hàng mới
    @Tenchure NVARCHAR(255) = NULL,
    @Tencodau NVARCHAR(255) = NULL,
    @DTchure NVARCHAR(50) = NULL,           -- ĐT riêng chú rể
    @DTcodau NVARCHAR(50) = NULL,           -- ĐT riêng cô dâu
    @Diachi NVARCHAR(500) = NULL,
    @Nguoigd NVARCHAR(100) = NULL,          -- Người đại diện
    @DienThoaiDaiDien NVARCHAR(50) = NULL,  -- ĐT người đại diện
    @Mail NVARCHAR(100) = NULL,
    
    -- Thông tin Phiếu Cọc
    @DocumentDate DATETIME = NULL,
    @Ngaytochuc DATETIME = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL, -- Ca tiệc
    @SobanManchinhthuc INT = 0,
    @SobanManduphong INT = 0,
    @SobanChaychinhthuc INT = 0,
    @SobanChayduphong INT = 0,
    @Tongtien DECIMAL(18,2) = 0, -- Số tiền đặt cọc
    @Solan TINYINT = 1, -- 1: Cọc lần 1, 2: Cọc lần 2
    @Ghichu NVARCHAR(500) = NULL,
    @Manv VARCHAR(50) = NULL,
    @UserCreate VARCHAR(50) = 'System',
    
    -- Danh sách Sảnh đặt (Dạng JSON: [{"Sanhtiecid":"S01", "IsSanhchinh": 1}, ...])
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    
    -- Mapped fields from DynamicFormEngine (client-side form values)
    @MaChungTu VARCHAR(50) = NULL,
    @_Ngaytochuc DATETIME = NULL,
    @TongtienRaw NVARCHAR(50) = NULL,
    
    -- Các trường bổ sung phiếu thu
    @TaiKhoanNo VARCHAR(50) = NULL,
    @TaiKhoanCo VARCHAR(50) = NULL,
    @Kemtheo NVARCHAR(255) = NULL,
    @Lydo NVARCHAR(255) = NULL,
    @HinhThuc NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Map values from client format fields to standard parameters
        IF @MaChungTu IS NOT NULL AND (@DocumentID IS NULL OR @DocumentID = '')
            SET @DocumentID = @MaChungTu;
        IF @_Ngaytochuc IS NOT NULL
            SET @Ngaytochuc = @_Ngaytochuc;
            
        IF @TongtienRaw IS NOT NULL AND LTRIM(RTRIM(@TongtienRaw)) <> ''
        BEGIN
            DECLARE @CleanedTongTien NVARCHAR(50) = REPLACE(REPLACE(REPLACE(@TongtienRaw, '.', ''), ',', ''), ' ', '');
            IF TRY_CAST(@CleanedTongTien AS DECIMAL(18,2)) IS NOT NULL
                SET @Tongtien = CAST(@CleanedTongTien AS DECIMAL(18,2));
        END

        BEGIN TRANSACTION;

        DECLARE @Now DATETIME = GETDATE();
        DECLARE @Tongsoban INT = ISNULL(@SobanManchinhthuc, 0) + ISNULL(@SobanChaychinhthuc, 0);

        -- ==========================================================
        -- 1. XỬ LÝ KHÁCH HÀNG (dmkhachhang)
        -- ==========================================================
        -- Nếu cập nhật mà không truyền Makh, lấy Makh hiện tại từ Phiếu Cọc
        IF (@Makh IS NULL OR @Makh = '') AND (@DocumentID IS NOT NULL AND @DocumentID <> '')
        BEGIN
            SELECT @Makh = Makh FROM tbmk_Biennhancoccho WHERE DocumentID = @DocumentID;
        END

        DECLARE @IsNewCustomer BIT = 0;

        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            -- Tìm khách hàng cũ theo SĐT chú rể hoặc cô dâu (tránh tạo duplicate)
            DECLARE @SdtTimkiem NVARCHAR(50) = ISNULL(NULLIF(@DTchure, ''), @DTcodau);
            IF (@SdtTimkiem IS NOT NULL AND @SdtTimkiem <> '')
            BEGIN
                SELECT TOP 1 @Makh = Makh
                FROM dmkhachhang
                WHERE (Dienthoai = @SdtTimkiem OR DTchure = @SdtTimkiem OR DTcodau = @SdtTimkiem)
                  AND ISNULL(Tenchure, '') = ISNULL(@Tenchure, '') 
                  AND ISNULL(Tencodau, '') = ISNULL(@Tencodau, '')
                ORDER BY DateCreate ASC;  -- Lấy record gốc cũ nhất
            END

            -- Không tìm thấy → tạo mới
            IF (@Makh IS NULL OR @Makh = '')
            BEGIN
                SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');
                SET @IsNewCustomer = 1;

                INSERT INTO dmkhachhang (
                    Makh, Tenkh, Tenchure, Tencodau, DTchure, DTcodau, Dienthoai, Diachi, Nguoigd, DienThoaiDaiDien, Mail,
                    IsKhachhang, DateCreate, UserCreate
                )
                VALUES (
                    @Makh,
                    CASE
                        WHEN ISNULL(@Tenchure, '') <> '' AND ISNULL(@Tencodau, '') <> '' THEN @Tenchure + ' & ' + @Tencodau
                        WHEN ISNULL(@Tenchure, '') <> '' THEN @Tenchure
                        WHEN ISNULL(@Tencodau, '') <> '' THEN @Tencodau
                        ELSE ISNULL(NULLIF(@Nguoigd, ''), N'Khách vãng lai')
                    END,
                    @Tenchure, @Tencodau, @DTchure, @DTcodau, 
                    ISNULL(NULLIF(@DTchure, ''), ISNULL(NULLIF(@DTcodau, ''), @DienThoaiDaiDien)), 
                    @Diachi, @Nguoigd, @DienThoaiDaiDien, @Mail,
                    1, @Now, @UserCreate
                );
            END
        END

        -- Nếu không phải khách hàng mới tạo, cập nhật lại thông tin mới nhất
        IF (@IsNewCustomer = 0)
        BEGIN
            UPDATE dmkhachhang
            SET 
                Tenkh = CASE 
                            WHEN ISNULL(@Tenchure, '') <> '' AND ISNULL(@Tencodau, '') <> '' THEN @Tenchure + ' & ' + @Tencodau
                            WHEN ISNULL(@Tenchure, '') <> '' THEN @Tenchure
                            WHEN ISNULL(@Tencodau, '') <> '' THEN @Tencodau
                            ELSE ISNULL(NULLIF(@Nguoigd, ''), N'Khách vãng lai')
                        END,
                Tenchure = @Tenchure,
                Tencodau = @Tencodau,
                DTchure = @DTchure,
                DTcodau = @DTcodau,
                Dienthoai = ISNULL(NULLIF(@DTchure, ''), ISNULL(NULLIF(@DTcodau, ''), @DienThoaiDaiDien)),
                Diachi = @Diachi,
                Nguoigd = @Nguoigd,
                DienThoaiDaiDien = @DienThoaiDaiDien,
                Mail = @Mail,
                DateUpdate = @Now,
                UserUpdate = @UserCreate
            WHERE Makh = @Makh;
        END

        -- ==========================================================
        -- 2. XỬ LÝ PHIẾU BIÊN NHẬN CỌC CHỖ (tbmk_Biennhancoccho)
        -- ==========================================================
        IF (@DocumentID IS NULL OR @DocumentID = '')
        BEGIN
            -- Phát sinh mã phiếu (DocumentID & SoBN)
            DECLARE @TodayStr VARCHAR(8) = FORMAT(@Now, 'yyMMdd');
            DECLARE @Counter INT;
            
            -- Đếm số phiếu cọc lập trong ngày để sinh số thứ tự tự động (ví dụ: 001, 002, ...)
            SELECT @Counter = COUNT(*) + 1 
            FROM tbmk_Biennhancoccho 
            WHERE CONVERT(DATE, DateCreate) = CONVERT(DATE, @Now);

            -- Ráp thành số phiếu: BNCC-260603-001
            DECLARE @SoBN VARCHAR(50) = 'BNCC-' + @TodayStr + '-' + RIGHT('00' + CAST(@Counter AS VARCHAR), 3);
            
            -- DocumentID vẫn dùng mã thời gian để đảm bảo tính duy nhất tuyệt đối của khóa chính
            SET @DocumentID = 'BNCC' + FORMAT(@Now, 'yyMMddHHmmss');

            INSERT INTO tbmk_Biennhancoccho (
                DocumentID, SoBN, DocumentDate, Makh, Solan, Manv, Loaitiecid,
                Ngaytochuc, Nhamngay, Tongtien, Tongsoban, SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong,
                Thoigianid, Ghichu, IsHuy, IsKetthuc, GoiThucDonID, DateCreate, UserCreate,
                TaiKhoanNo, TaiKhoanCo, Kemtheo, Lydo, HinhThuc
            )
            VALUES (
                @DocumentID, @SoBN, ISNULL(@DocumentDate, @Now), @Makh, @Solan, @Manv, @Loaitiecid,
                @Ngaytochuc, @Nhamngay, @Tongtien, @Tongsoban, @SobanManchinhthuc, @SobanManduphong, @SobanChaychinhthuc, @SobanChayduphong,
                @Thoigianid, @Ghichu, 0, 0, '', @Now, @UserCreate,
                @TaiKhoanNo, @TaiKhoanCo, @Kemtheo, @Lydo, @HinhThuc
            );
        END
        ELSE
        BEGIN
            -- Cập nhật phiếu cọc
            UPDATE tbmk_Biennhancoccho
            SET 
                Makh = @Makh,
                Solan = @Solan,
                Loaitiecid = @Loaitiecid,
                Ngaytochuc = @Ngaytochuc,
                Nhamngay = @Nhamngay,
                Tongtien = @Tongtien,
                Tongsoban = @Tongsoban,
                SobanManchinhthuc = @SobanManchinhthuc,
                SobanManduphong = @SobanManduphong,
                SobanChaychinhthuc = @SobanChaychinhthuc,
                SobanChayduphong = @SobanChayduphong,
                Thoigianid = @Thoigianid,
                Ghichu = @Ghichu,
                DateUpdate = @Now,
                UserUpdate = @UserCreate,
                TaiKhoanNo = @TaiKhoanNo,
                TaiKhoanCo = @TaiKhoanCo,
                Kemtheo = @Kemtheo,
                Lydo = @Lydo,
                HinhThuc = @HinhThuc
            WHERE DocumentID = @DocumentID;
        END

        -- ==========================================================
        -- 3. XỬ LÝ CHI TIẾT SẢNH TIỆC (tbmk_Biennhancocchosanhtiec)
        -- ==========================================================
        -- Chỉ xử lý nếu có truyền danh sách Sảnh
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            -- Nếu không phải dạng mảng JSON (ví dụ: chỉ là mã sảnh 'S01' chọn từ dropdown đơn giản)
            -- thì tự động bọc thành JSON array hợp lệ để OPENJSON không bị lỗi
            IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
            BEGIN
                SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';
            END

            -- Xóa sảnh cũ của phiếu này
            DELETE FROM tbmk_Biennhancocchosanhtiec WHERE DocumentID = @DocumentID;

            -- Parse JSON và Insert sảnh mới (Yêu cầu SQL Server 2016+)
            INSERT INTO tbmk_Biennhancocchosanhtiec (
                UserAutoid, DocumentID, Sanhtiecid, IsSanhchinh, 
                DateCreate, UserCreate
            )
            SELECT 
                NEWID(), -- Tự sinh GUID cho UserAutoid
                @DocumentID, 
                JSON_VALUE(value, '$.Sanhtiecid'),
                ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0),
                @Now,
                @UserCreate
            FROM OPENJSON(@JsonSanhTiec);
        END

        COMMIT TRANSACTION;
        
        -- Trả về kết quả thành công kèm ID
        SELECT 1 AS [Success], N'Lưu biên nhận cọc thành công' AS [Message], @DocumentID AS [DocumentID], @Makh AS [Makh];
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Trả về lỗi
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message], NULL AS [DocumentID], NULL AS [Makh];
    END CATCH
END
GO
