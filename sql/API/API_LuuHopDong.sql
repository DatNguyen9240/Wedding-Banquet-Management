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
    
    -- Thông tin Hợp đồng Tiệc
    @Ngayhopdong NVARCHAR(100) = NULL,
    @Ngaytochuc NVARCHAR(100) = NULL,
    @_Ngaytochuc NVARCHAR(100) = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(10) = NULL,
    @Thoigianid VARCHAR(20) = NULL,      -- Ca tiệc
    
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

    -- Đưa các chuỗi 'NULL'/'null' hoặc rỗng về NULL thực tế
    IF (UPPER(LTRIM(RTRIM(@Ngayhopdong))) = 'NULL' OR LTRIM(RTRIM(@Ngayhopdong)) = '')
        SET @Ngayhopdong = NULL;
        
    IF (UPPER(LTRIM(RTRIM(@Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@Ngaytochuc)) = '')
        SET @Ngaytochuc = NULL;

    IF (UPPER(LTRIM(RTRIM(@_Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@_Ngaytochuc)) = '')
        SET @_Ngaytochuc = NULL;

    -- Parse @Ngayhopdong từ các định dạng phổ biến
    IF (@Ngayhopdong IS NOT NULL)
    BEGIN
        SET @NgayHopDongParsed = TRY_CAST(@Ngayhopdong AS DATETIME);
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 103); -- dd/mm/yyyy
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 105); -- dd-mm-yyyy
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 120); -- yyyy-mm-dd
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 111); -- yyyy/mm/dd
        IF (@NgayHopDongParsed IS NULL) SET @NgayHopDongParsed = TRY_CONVERT(DATETIME, @Ngayhopdong, 101); -- mm/dd/yyyy
    END

    -- Parse @Ngaytochuc từ các định dạng phổ biến
    IF (@Ngaytochuc IS NOT NULL)
    BEGIN
        SET @NgayToChucParsed = TRY_CAST(@Ngaytochuc AS DATETIME);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 103);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 105);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 120);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 111);
        IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = TRY_CONVERT(DATETIME, @Ngaytochuc, 101);
    END

    -- Parse @_Ngaytochuc từ các định dạng phổ biến
    IF (@_Ngaytochuc IS NOT NULL)
    BEGIN
        SET @_NgayToChucParsed = TRY_CAST(@_Ngaytochuc AS DATETIME);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 103);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 105);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 120);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 111);
        IF (@_NgayToChucParsed IS NULL) SET @_NgayToChucParsed = TRY_CONVERT(DATETIME, @_Ngaytochuc, 101);
    END

    -- Gộp kết quả parse từ các biến ngày tổ chức khác nhau
    IF (@NgayToChucParsed IS NULL)
        SET @NgayToChucParsed = @_NgayToChucParsed;

    -- Chuẩn hóa và parse các tham số số học (bỏ dấu chấm/phẩy phân tách hàng ngàn)
    SET @SobanManchinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManchinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanManduphongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManduphong, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChaychinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChaychinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChayduphongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChayduphong, '0'), '.', ''), ',', '') AS INT);
    
    SET @TongSoBanVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@TongSoBan, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtienhopdongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtienhopdong, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencocchoVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencoccho, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencochopdongVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencochopdong, '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtiencocVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtiencoc, '0'), '.', ''), ',', '') AS DECIMAL(18,2));

    -- Chuẩn hóa JSON sảnh tiệc nếu là mã đơn lẻ (ví dụ: 'S01' -> '[{"Sanhtiecid":"S01", "IsSanhchinh":1}]')
    IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
    BEGIN
        IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
        BEGIN
            SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';
        END
    END

    -- Fallback 1: Nếu rỗng và là cập nhật hợp đồng cũ, lấy từ hợp đồng hiện tại
    IF (@NgayToChucParsed IS NULL AND @Sohopdong IS NOT NULL AND @Sohopdong <> '')
    BEGIN
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc
        FROM tbmk_Hopdong
        WHERE Sohopdong = @Sohopdong;
    END

    -- Fallback 2: Nếu rỗng và có liên kết biên nhận cọc, lấy từ biên nhận cọc
    IF (@NgayToChucParsed IS NULL AND @Sobiennhan IS NOT NULL AND @Sobiennhan <> '')
    BEGIN
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc
        FROM tbmk_Biennhancoccho
        WHERE DocumentID = @Sobiennhan OR SoBN = @Sobiennhan;
    END

    -- Kiểm tra Ngày tổ chức bắt buộc phải hợp lệ
    IF (@NgayToChucParsed IS NULL)
    BEGIN
        SELECT 0 AS [Success], N'Lỗi: Ngày tổ chức không được để trống hoặc định dạng ngày không hợp lệ (Nhập vào: ''' + COALESCE(@Ngaytochuc, @_Ngaytochuc, 'NULL') + ''')' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ==========================================================
        -- 0. KIỂM TRA TRÙNG LỊCH SẢNH (CONFLICT VALIDATION)
        -- ==========================================================
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            IF EXISTS (
                -- Kiểm tra trùng với Hợp đồng khác
                SELECT 1 
                FROM tbmk_Hopdong h
                INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE h.Ngaytochuc = @NgayToChucParsed 
                  AND h.Thoigianid = @Thoigianid
                  AND ISNULL(h.IsHuy, 0) = 0
                  AND h.Sohopdong != ISNULL(@Sohopdong, '')
                  
                UNION ALL
                
                -- Kiểm tra trùng với Cọc chỗ khác (chưa lên Hợp đồng)
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

        -- ==========================================================
        -- 1. XỬ LÝ KHÁCH HÀNG (dmkhachhang)
        -- ==========================================================
        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            -- Tìm khách hàng đã có theo SĐT trước (tránh tạo duplicate)
            IF (@Dienthoai IS NOT NULL AND @Dienthoai <> '')
            BEGIN
                SELECT TOP 1 @Makh = Makh
                FROM dmkhachhang
                WHERE Dienthoai = @Dienthoai
                  AND ISNULL(IsKhachhang, 0) = 1
                ORDER BY DateCreate ASC;  -- Lấy record cũ nhất (gốc)
            END

            -- Không tìm thấy → tạo mới
            IF (@Makh IS NULL OR @Makh = '')
            BEGIN
                SET @Makh = 'KH' + FORMAT(@Now, 'yyMMddHHmmss');

                INSERT INTO dmkhachhang (
                    Makh, Tenkh, Tenchure, Tencodau, Dienthoai, Diachi, Mail, 
                    IsKhachhang, DateCreate, UserCreate
                )
                VALUES (
                    @Makh, 
                    CASE 
                        WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '')
                        ELSE ISNULL(@Tenchure, '') + ' & ' + ISNULL(@Tencodau, '') 
                    END, 
                    @Tenchure, @Tencodau, @Dienthoai, @Diachi, @Mail, 
                    1, @Now, @UserCreate
                );
            END
            ELSE
            BEGIN
                -- Tìm thấy khách cũ → cập nhật thông tin nếu có thay đổi
                UPDATE dmkhachhang
                SET
                    Tenchure    = ISNULL(NULLIF(@Tenchure, ''), Tenchure),
                    Tencodau    = ISNULL(NULLIF(@Tencodau, ''), Tencodau),
                    Diachi      = ISNULL(NULLIF(@Diachi,   ''), Diachi),
                    Mail        = ISNULL(NULLIF(@Mail,     ''), Mail),
                    DateUpdate  = @Now,
                    UserUpdate  = @UserCreate
                WHERE Makh = @Makh;
            END
        END
        ELSE
        BEGIN
            UPDATE dmkhachhang
            SET 
                Tenkh = CASE 
                            WHEN @Tencodau IS NULL OR @Tencodau = '' THEN ISNULL(@Tenchure, '')
                            ELSE ISNULL(@Tenchure, '') + ' & ' + ISNULL(@Tencodau, '') 
                        END,
                Tenchure = @Tenchure,
                Tencodau = @Tencodau,
                Dienthoai = @Dienthoai,
                Diachi = @Diachi,
                Mail = @Mail,
                DateUpdate = @Now,
                UserUpdate = @UserCreate
            WHERE Makh = @Makh;
        END

        -- ==========================================================
        -- 2. XỬ LÝ HỢP ĐỒNG (tbmk_Hopdong)
        -- ==========================================================
        IF (@Sohopdong IS NULL OR @Sohopdong = '')
        BEGIN
            -- Phát sinh mã Hợp Đồng (Max 20 chars)
            SET @Sohopdong = 'HD' + FORMAT(@Now, 'yyMMddHHmmss');

            INSERT INTO tbmk_Hopdong (
                Sohopdong, Sobiennhan, Ngayhopdong, Ngaytochuc, Nhamngay, Makh, Loaitiecid, Thoigianid,
                SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, TongSoBan,
                Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongtiencoc,
                Manv, Ghichu, IsHuy, IsKetthuc, DateCreate, UserCreate, GoiThucDonID
            )
            VALUES (
                @Sohopdong, @Sobiennhan, ISNULL(@NgayHopDongParsed, @Now), @NgayToChucParsed, @Nhamngay, @Makh, @Loaitiecid, @Thoigianid,
                @SobanManchinhthucVal, @SobanManduphongVal, @SobanChaychinhthucVal, @SobanChayduphongVal, @TongSoBanVal,
                @TongtienhopdongVal, @SotiencocchoVal, @SotiencochopdongVal, @TongtiencocVal,
                @Manv, @Ghichu, 0, 0, @Now, @UserCreate, ''
            );

            -- Cập nhật trạng thái phiếu cọc nếu có truyền Sobiennhan
            IF (@Sobiennhan IS NOT NULL AND @Sobiennhan != '')
            BEGIN
                UPDATE tbmk_Biennhancoccho 
                SET IsKetthuc = 1, DateUpdate = @Now, UserUpdate = @UserCreate
                WHERE DocumentID = @Sobiennhan;
            END
        END
        ELSE
        BEGIN
            -- Cập nhật Hợp Đồng
            UPDATE tbmk_Hopdong
            SET 
                Sobiennhan = @Sobiennhan,
                Makh = @Makh,
                Ngayhopdong = @NgayHopDongParsed,
                Ngaytochuc = @NgayToChucParsed,
                Nhamngay = @Nhamngay,
                Loaitiecid = @Loaitiecid,
                Thoigianid = @Thoigianid,
                SobanManchinhthuc = @SobanManchinhthucVal,
                SobanManduphong = @SobanManduphongVal,
                SobanChaychinhthuc = @SobanChaychinhthucVal,
                SobanChayduphong = @SobanChayduphongVal,
                TongSoBan = @TongSoBanVal,
                Tongtienhopdong = @TongtienhopdongVal,
                Sotiencoccho = @SotiencocchoVal,
                Sotiencochopdong = @SotiencochopdongVal,
                Tongtiencoc = @TongtiencocVal,
                Ghichu = @Ghichu,
                DateUpdate = @Now,
                UserUpdate = @UserCreate
            WHERE Sohopdong = @Sohopdong;
        END

        -- ==========================================================
        -- 3. XỬ LÝ CHI TIẾT SẢNH TIỆC (tbmk_Hopdongsanhtiec)
        -- ==========================================================
        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            -- Xóa sảnh cũ
            DELETE FROM tbmk_Hopdongsanhtiec WHERE Sohopdong = @Sohopdong;

            -- Insert sảnh mới từ JSON
            INSERT INTO tbmk_Hopdongsanhtiec (
                UserAutoid, Sohopdong, Sanhtiecid, IsSanhchinh, 
                DateCreate, UserCreate
            )
            SELECT 
                NEWID(), 
                @Sohopdong, 
                JSON_VALUE(value, '$.Sanhtiecid'),
                ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0),
                @Now,
                @UserCreate
            FROM OPENJSON(@JsonSanhTiec);
        END

        COMMIT TRANSACTION;
        
        -- Trả về kết quả
        SELECT 1 AS [Success], N'Lưu Hợp đồng Tiệc Cưới thành công' AS [Message], @Sohopdong AS [Sohopdong], @Makh AS [Makh];
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
    END CATCH
END
GO
