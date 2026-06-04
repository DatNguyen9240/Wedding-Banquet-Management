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
    @DocumentDate NVARCHAR(100) = NULL,
    @Ngaytochuc NVARCHAR(100) = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL, -- Ca tiệc
    @SobanManchinhthuc INT = 0,
    @SobanManduphong INT = 0,
    @SobanChaychinhthuc INT = 0,
    @SobanChayduphong INT = 0,
    @Tongtien NVARCHAR(50) = NULL, -- Số tiền đặt cọc (nhận NVARCHAR từ client để tránh lỗi cast rỗng)
    @Solan TINYINT = 1, -- 1: Cọc lần 1, 2: Cọc lần 2
    @Ghichu NVARCHAR(500) = NULL,
    @Manv VARCHAR(50) = NULL,
    @UserCreate VARCHAR(50) = 'System',
    
    -- Danh sách Sảnh đặt (Dạng JSON: [{"Sanhtiecid":"S01", "IsSanhchinh": 1}, ...])
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    
    -- Mapped fields from DynamicFormEngine (client-side form values)
    @MaChungTu VARCHAR(50) = NULL,
    @_Ngaytochuc NVARCHAR(100) = NULL,
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
    
    DECLARE @DocumentDateParsed DATETIME = NULL;
    DECLARE @NgayToChucParsed DATETIME = NULL;
    DECLARE @_NgayToChucParsed DATETIME = NULL;

    -- Parse @DocumentDate từ các định dạng phổ biến
    IF (@DocumentDate IS NOT NULL AND LTRIM(RTRIM(@DocumentDate)) <> '')
    BEGIN
        SET @DocumentDateParsed = TRY_CAST(@DocumentDate AS DATETIME);
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 103); -- dd/mm/yyyy
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 105); -- dd-mm-yyyy
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 120); -- yyyy-mm-dd
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 111); -- yyyy/mm/dd
        IF (@DocumentDateParsed IS NULL) SET @DocumentDateParsed = TRY_CONVERT(DATETIME, @DocumentDate, 101); -- mm/dd/yyyy
    END

    -- Parse @_Ngaytochuc từ các định dạng phổ biến
    IF (@_Ngaytochuc IS NOT NULL AND LTRIM(RTRIM(@_Ngaytochuc)) <> '')
    BEGIN
        SET @_NgayToChucParsed = TRY_CAST(@_Ngaytochuc AS DATETIME);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 103);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 105);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 120);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 111);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 101);
    END

    -- Parse @Ngaytochuc từ các định dạng phổ biến
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
        -- Map values từ client format fields sang standard parameters
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

        -- ==========================================================
        -- 0. KIỂM TRA ĐIỀU KIỆN CHẶN TRÙNG LỊCH & TRÙNG PHIẾU
        -- ==========================================================
        
        -- Kiểm tra bắt buộc nhập các trường thông tin quan trọng
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

        -- A. Kiểm tra trùng khách hàng đã có cọc hoạt động cùng ngày tổ chức
        DECLARE @CheckMakh VARCHAR(50) = @Makh;
        IF (@CheckMakh IS NULL OR @CheckMakh = '')
        BEGIN
            DECLARE @CheckSdt NVARCHAR(50) = ISNULL(NULLIF(@DTchure, ''), @DTcodau);
            IF (@CheckSdt IS NOT NULL AND @CheckSdt <> '')
            BEGIN
                SELECT TOP 1 @CheckMakh = Makh
                FROM dmkhachhang
                WHERE (Dienthoai = @CheckSdt OR DTchure = @CheckSdt OR DTcodau = @CheckSdt)
                  AND ISNULL(Tenchure, '') = ISNULL(@Tenchure, '') 
                  AND ISNULL(Tencodau, '') = ISNULL(@Tencodau, '')
                ORDER BY DateCreate ASC;
            END
        END

        IF (@CheckMakh IS NOT NULL AND @CheckMakh <> '')
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM tbmk_Biennhancoccho
                WHERE Makh = @CheckMakh
                  AND Ngaytochuc = @NgayToChucParsed
                  AND ISNULL(IsHuy, 0) = 0
                  AND ISNULL(IsKetthuc, 0) = 0
                  AND DocumentID != ISNULL(@DocumentID, '')
            )
            BEGIN
                SELECT 0 AS [Success], N'Lỗi: Khách hàng này đã có một phiếu cọc chỗ đang hoạt động vào ngày tổ chức này. Vui lòng chỉnh sửa phiếu cọc cũ thay vì tạo mới!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
                RETURN;
            END
        END

        -- B. Kiểm tra trùng lịch sảnh (Double Booking)
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DECLARE @JsonSanhTiecTemp NVARCHAR(MAX) = @JsonSanhTiec;
            IF (LEFT(LTRIM(@JsonSanhTiecTemp), 1) != '[')
            BEGIN
                SET @JsonSanhTiecTemp = '[{"Sanhtiecid":"' + @JsonSanhTiecTemp + '", "IsSanhchinh":1}]';
            END

            IF EXISTS (
                -- 1. Trùng với Hợp đồng khác đang hoạt động
                SELECT 1 
                FROM tbmk_Hopdong h
                INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
                INNER JOIN OPENJSON(@JsonSanhTiecTemp) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE h.Ngaytochuc = @NgayToChucParsed 
                  AND h.Thoigianid = @Thoigianid
                  AND ISNULL(h.IsHuy, 0) = 0
                  
                UNION ALL
                
                -- 2. Trùng với Biên nhận cọc chỗ khác đang hoạt động (chưa chuyển thành HĐ)
                SELECT 1 
                FROM tbmk_Biennhancoccho b
                INNER JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID
                INNER JOIN OPENJSON(@JsonSanhTiecTemp) j ON bs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE b.Ngaytochuc = @NgayToChucParsed 
                  AND b.Thoigianid = @Thoigianid
                  AND ISNULL(b.IsHuy, 0) = 0
                  AND ISNULL(b.IsKetthuc, 0) = 0
                  AND b.DocumentID != ISNULL(@DocumentID, '')
            )
            BEGIN
                SELECT 0 AS [Success], N'Lỗi: Sảnh bạn chọn đã được đặt cọc hoặc ký Hợp đồng trước đó trong ca tiệc này. Vui lòng kiểm tra lại!' AS [Message], NULL AS [DocumentID], NULL AS [Makh];
                RETURN;
            END
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

            -- Tự động tìm và liên kết mã cọc cũ (DocumentIDcu) nếu đây là Cọc lần 2
            DECLARE @DocumentIDcu VARCHAR(50) = NULL;
            IF (@Solan = 2)
            BEGIN
                SELECT TOP 1 @DocumentIDcu = DocumentID
                FROM tbmk_Biennhancoccho
                WHERE Makh = @Makh
                  AND Solan = 1
                  AND IsHuy = 0
                ORDER BY DateCreate DESC;
            END

            INSERT INTO tbmk_Biennhancoccho (
                DocumentID, SoBN, DocumentDate, Makh, Solan, DocumentIDcu, Manv, Loaitiecid,
                Ngaytochuc, Nhamngay, Tongtien, Tongsoban, SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong,
                Thoigianid, Ghichu, IsHuy, IsKetthuc, GoiThucDonID, DateCreate, UserCreate,
                TaiKhoanNo, TaiKhoanCo, Kemtheo, Lydo, HinhThuc
            )
            VALUES (
                @DocumentID, @SoBN, ISNULL(@DocumentDateParsed, @Now), @Makh, @Solan, @DocumentIDcu, @Manv, @Loaitiecid,
                @NgayToChucParsed, @Nhamngay, @TongTienDecimal, @Tongsoban, @SobanManchinhthuc, @SobanManduphong, @SobanChaychinhthuc, @SobanChayduphong,
                @Thoigianid, @Ghichu, 0, 0, '', @Now, @UserCreate,
                @TaiKhoanNo, @TaiKhoanCo, @Kemtheo, @Lydo, @HinhThuc
            );
        END
        ELSE
        BEGIN
            -- Tự động tìm và liên kết mã cọc cũ (DocumentIDcu) nếu đây là Cọc lần 2
            DECLARE @DocumentIDcuUpdate VARCHAR(50) = NULL;
            IF (@Solan = 2)
            BEGIN
                SELECT TOP 1 @DocumentIDcuUpdate = DocumentID
                FROM tbmk_Biennhancoccho
                WHERE Makh = @Makh
                  AND Solan = 1
                  AND IsHuy = 0
                  AND DocumentID <> @DocumentID
                ORDER BY DateCreate DESC;
            END
            -- Kiểm tra xem phiếu cọc đã có trạng thái "Đã lên Hợp đồng" hoặc "Đã Hủy" hoặc chốt cứng chưa (Khóa thay đổi)
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

            -- Cập nhật phiếu cọc
            UPDATE tbmk_Biennhancoccho
            SET 
                Makh = @Makh,
                Solan = @Solan,
                DocumentIDcu = @DocumentIDcuUpdate,
                Loaitiecid = @Loaitiecid,
                Ngaytochuc = @NgayToChucParsed,
                Nhamngay = @Nhamngay,
                Tongtien = @TongTienDecimal,
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
