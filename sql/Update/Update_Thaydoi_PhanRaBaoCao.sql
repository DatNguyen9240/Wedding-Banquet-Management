USE [QLTiec]
GO

-- =========================================================================
-- 1. TẠO STORED PROCEDURE API_LuuThaydoi (LƯU PHÂN RÃ VÀO CÁC BẢNG CON VẬT LÝ)
-- =========================================================================
IF OBJECT_ID('API_LuuThaydoi', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuThaydoi;
GO

CREATE PROCEDURE [dbo].[API_LuuThaydoi]
    @Sothaydoi NVARCHAR(50),
    @Sohopdong NVARCHAR(50),
    @User NVARCHAR(50),
    @JsonBanTiec NVARCHAR(MAX) = NULL,
    @JsonThucUong NVARCHAR(MAX) = NULL,
    @JsonDichVu NVARCHAR(MAX) = NULL,
    @JsonPhatSinh NVARCHAR(MAX) = NULL,
    @RawData NVARCHAR(MAX) = NULL -- JSON payload gốc từ UI gửi xuống
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- 1. Lưu thông tin bảng mẹ tbmk_Thaydoi (Gọi lại API_LuuDong để tận dụng tính năng low-code)
        DECLARE @Result TABLE (code INT, msg NVARCHAR(MAX));
        
        INSERT INTO @Result
        EXEC [dbo].[API_LuuDong] @List = 'tbmk_Thaydoi', @Data = @RawData;
        
        -- Nếu lưu bảng mẹ thất bại, rollback và trả về lỗi
        IF EXISTS (SELECT 1 FROM @Result WHERE code <> 0)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT * FROM @Result;
            RETURN;
        END

        -- 2. Phân rã chi tiết thực đơn (Món mặn và Món chay)
        IF @JsonBanTiec IS NOT NULL
        BEGIN
            -- Parse toàn bộ danh sách bàn tiệc từ JSON
            SELECT 
                @Sothaydoi AS Sothaydoi,
                j.Mahang,
                j.Soluong,
                j.Dongia,
                (j.Soluong * j.Dongia) AS Sotien,
                ISNULL(j.Giamgia, 0) AS Giamgia,
                ISNULL(j.Sotiengiamgia, 0) AS Sotiengiamgia,
                (j.Soluong * j.Dongia - ISNULL(j.Sotiengiamgia, 0)) AS ThanhTien,
                @User AS UserCreate,
                GETDATE() AS DateCreate,
                h.LoaihangID
            INTO #TempAllBanTiec
            FROM OPENJSON(@JsonBanTiec)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            ) j
            LEFT JOIN dmHangHoa h ON j.Mahang = h.Mahang;

            -- 2a. Lưu vào bảng Món chay (tbmk_ThayDoiThucDonChay)
            IF OBJECT_ID('tbmk_ThayDoiThucDonChay', 'U') IS NOT NULL
            BEGIN
                DELETE FROM tbmk_ThayDoiThucDonChay WHERE Sothaydoi = @Sothaydoi;

                DECLARE @ColsChay NVARCHAR(MAX) = '';
                DECLARE @SelectChay NVARCHAR(MAX) = '';
                
                SELECT 
                    @ColsChay = @ColsChay + CASE WHEN @ColsChay = '' THEN '' ELSE ', ' END + QUOTENAME(name),
                    @SelectChay = @SelectChay + CASE WHEN @SelectChay = '' THEN '' ELSE ', ' END + QUOTENAME(name)
                FROM sys.columns 
                WHERE object_id = OBJECT_ID('tbmk_ThayDoiThucDonChay')
                  AND name IN ('Sothaydoi', 'Mahang', 'Soluong', 'Dongia', 'Sotien', 'Giamgia', 'Sotiengiamgia', 'ThanhTien', 'UserCreate', 'DateCreate');

                IF @ColsChay <> ''
                BEGIN
                    DECLARE @SqlChay NVARCHAR(MAX) = 'INSERT INTO tbmk_ThayDoiThucDonChay (' + @ColsChay + ') SELECT ' + @SelectChay + ' FROM #TempAllBanTiec WHERE LoaihangID = ''MONCHAY'';';
                    EXEC sp_executesql @SqlChay;
                END
            END

            -- 2b. Lưu vào bảng Món mặn (tbmk_ThayDoiThucDonMan)
            IF OBJECT_ID('tbmk_ThayDoiThucDonMan', 'U') IS NOT NULL
            BEGIN
                DELETE FROM tbmk_ThayDoiThucDonMan WHERE Sothaydoi = @Sothaydoi;

                DECLARE @ColsMan NVARCHAR(MAX) = '';
                DECLARE @SelectMan NVARCHAR(MAX) = '';
                
                SELECT 
                    @ColsMan = @ColsMan + CASE WHEN @ColsMan = '' THEN '' ELSE ', ' END + QUOTENAME(name),
                    @SelectMan = @SelectMan + CASE WHEN @SelectMan = '' THEN '' ELSE ', ' END + QUOTENAME(name)
                FROM sys.columns 
                WHERE object_id = OBJECT_ID('tbmk_ThayDoiThucDonMan')
                  AND name IN ('Sothaydoi', 'Mahang', 'Soluong', 'Dongia', 'Sotien', 'Giamgia', 'Sotiengiamgia', 'ThanhTien', 'UserCreate', 'DateCreate');

                IF @ColsMan <> ''
                BEGIN
                    DECLARE @SqlMan NVARCHAR(MAX) = 'INSERT INTO tbmk_ThayDoiThucDonMan (' + @ColsMan + ') SELECT ' + @SelectMan + ' FROM #TempAllBanTiec WHERE ISNULL(LoaihangID, '''') <> ''MONCHAY'';';
                    EXEC sp_executesql @SqlMan;
                END
            END

            DROP TABLE #TempAllBanTiec;
        END

        -- 3. Phân rã chi tiết Thức uống (tbmk_ThayDoiThucUong)
        IF @JsonThucUong IS NOT NULL AND OBJECT_ID('tbmk_ThayDoiThucUong', 'U') IS NOT NULL
        BEGIN
            DELETE FROM tbmk_ThayDoiThucUong WHERE Sothaydoi = @Sothaydoi;

            SELECT 
                @Sothaydoi AS Sothaydoi,
                Mahang,
                Soluong,
                Dongia,
                (Soluong * Dongia) AS Sotien,
                ISNULL(Giamgia, 0) AS Giamgia,
                ISNULL(Sotiengiamgia, 0) AS Sotiengiamgia,
                (Soluong * Dongia - ISNULL(Sotiengiamgia, 0)) AS ThanhTien,
                @User AS UserCreate,
                GETDATE() AS DateCreate
            INTO #TempThucUong
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );

            DECLARE @ColsUong NVARCHAR(MAX) = '';
            DECLARE @SelectUong NVARCHAR(MAX) = '';
            
            SELECT 
                @ColsUong = @ColsUong + CASE WHEN @ColsUong = '' THEN '' ELSE ', ' END + QUOTENAME(name),
                @SelectUong = @SelectUong + CASE WHEN @SelectUong = '' THEN '' ELSE ', ' END + QUOTENAME(name)
            FROM sys.columns 
            WHERE object_id = OBJECT_ID('tbmk_ThayDoiThucUong')
              AND name IN ('Sothaydoi', 'Mahang', 'Soluong', 'Dongia', 'Sotien', 'Giamgia', 'Sotiengiamgia', 'ThanhTien', 'UserCreate', 'DateCreate');

            IF @ColsUong <> ''
            BEGIN
                DECLARE @SqlUong NVARCHAR(MAX) = 'INSERT INTO tbmk_ThayDoiThucUong (' + @ColsUong + ') SELECT ' + @SelectUong + ' FROM #TempThucUong;';
                EXEC sp_executesql @SqlUong;
            END

            DROP TABLE #TempThucUong;
        END

        -- 4. Phân rã chi tiết Dịch vụ (tbmk_ThayDoiDichVu)
        IF @JsonDichVu IS NOT NULL AND OBJECT_ID('tbmk_ThayDoiDichVu', 'U') IS NOT NULL
        BEGIN
            DELETE FROM tbmk_ThayDoiDichVu WHERE Sothaydoi = @Sothaydoi;

            SELECT 
                @Sothaydoi AS Sothaydoi,
                Mahang,
                Soluong,
                Dongia,
                (Soluong * Dongia) AS Sotien,
                ISNULL(Giamgia, 0) AS Giamgia,
                ISNULL(Sotiengiamgia, 0) AS Sotiengiamgia,
                (Soluong * Dongia - ISNULL(Sotiengiamgia, 0)) AS ThanhTien,
                @User AS UserCreate,
                GETDATE() AS DateCreate
            INTO #TempDichVu
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );

            DECLARE @ColsDichVu NVARCHAR(MAX) = '';
            DECLARE @SelectDichVu NVARCHAR(MAX) = '';
            
            SELECT 
                @ColsDichVu = @ColsDichVu + CASE WHEN @ColsDichVu = '' THEN '' ELSE ', ' END + QUOTENAME(name),
                @SelectDichVu = @SelectDichVu + CASE WHEN @SelectDichVu = '' THEN '' ELSE ', ' END + QUOTENAME(name)
            FROM sys.columns 
            WHERE object_id = OBJECT_ID('tbmk_ThayDoiDichVu')
              AND name IN ('Sothaydoi', 'Mahang', 'Soluong', 'Dongia', 'Sotien', 'Giamgia', 'Sotiengiamgia', 'ThanhTien', 'UserCreate', 'DateCreate');

            IF @ColsDichVu <> ''
            BEGIN
                DECLARE @SqlDichVu NVARCHAR(MAX) = 'INSERT INTO tbmk_ThayDoiDichVu (' + @ColsDichVu + ') SELECT ' + @SelectDichVu + ' FROM #TempDichVu;';
                EXEC sp_executesql @SqlDichVu;
            END

            DROP TABLE #TempDichVu;
        END

        COMMIT TRANSACTION;
        SELECT 0 AS code, N'Lưu phiếu thay đổi và phân rã chi tiết thành công!' AS msg;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();
        SELECT -1 AS code, N'Lỗi phân rã SQL: ' + @ErrMsg AS msg;
    END CATCH
END
GO

-- =========================================================================
-- 2. ĐỒNG BỘ ĐỊNH TUYẾN WA_API CHO HÀNH ĐỘNG SAVE CỦA PHIẾU THAY ĐỔI
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình định tuyến Save sang API_LuuThaydoi...';
GO

DELETE FROM WA_API WHERE List = 'tbmk_Thaydoi' AND Func = 'Save';
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'tbmk_Thaydoi',
    'Save',
    'API_LuuThaydoi',
    '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @User=N''{UserName}'', @JsonBanTiec=N''{JsonBanTiec}'', @JsonThucUong=N''{JsonThucUong}'', @JsonDichVu=N''{JsonDichVu}'', @JsonPhatSinh=N''{JsonPhatSinh}'', @RawData=N''{JsonData}'''
);
GO
