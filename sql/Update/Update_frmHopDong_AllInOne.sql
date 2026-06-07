USE [QLTiec]
GO

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

-- Ensure NoteBaoVe, NoteKyThuat, NoteBieuNgu columns exist on tbmk_Hopdong
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteBaoVe')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteBaoVe NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteKyThuat')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteKyThuat NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteBieuNgu')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteBieuNgu NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'NoteLobby')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD NoteLobby NVARCHAR(1000) NULL;
END
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'JsonLichTrinh')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD JsonLichTrinh NVARCHAR(MAX) NULL;
END
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
    @Keyword NVARCHAR(100) = NULL
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
        
        -- Bộ lọc Keyword tìm kiếm tương đối
        AND (
            @Keyword IS NULL OR @Keyword = ''
            OR v.Sohopdong LIKE '%' + @Keyword + '%'
            OR v.Sobiennhan LIKE '%' + @Keyword + '%'
            OR v.TenKhachHang LIKE N'%' + @Keyword + '%'
            OR v.Tenchure LIKE N'%' + @Keyword + '%'
            OR v.Tencodau LIKE N'%' + @Keyword + '%'
            OR v.DienThoai LIKE '%' + @Keyword + '%'
            OR v.BenB_CCCD LIKE '%' + @Keyword + '%'
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
    @BenB_CCCD NVARCHAR(50) = NULL,
    
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
    
    @NoteBaoVe NVARCHAR(1000) = NULL,
    @NoteKyThuat NVARCHAR(1000) = NULL,
    @NoteBieuNgu NVARCHAR(1000) = NULL,
    @NoteLobby NVARCHAR(1000) = NULL,
    
    -- Danh sach Sanh dat (Dang JSON: [{"Sanhtiecid":"S01", "IsSanhchinh": 1}, ...])
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    
    -- Danh sach Lich trinh BEO (Dang JSON)
    @JsonLichTrinh NVARCHAR(MAX) = NULL
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

    IF (UPPER(LTRIM(RTRIM(@Ngayhopdong))) = 'NULL' OR LTRIM(RTRIM(@Ngayhopdong)) = '') SET @Ngayhopdong = NULL;
    IF (UPPER(LTRIM(RTRIM(@Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@Ngaytochuc)) = '') SET @Ngaytochuc = NULL;
    IF (UPPER(LTRIM(RTRIM(@_Ngaytochuc))) = 'NULL' OR LTRIM(RTRIM(@_Ngaytochuc)) = '') SET @_Ngaytochuc = NULL;

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
    IF (@NgayToChucParsed IS NULL) SET @NgayToChucParsed = @_NgayToChucParsed;

    SET @SobanManchinhthucVal  = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManchinhthuc,  '0'), '.', ''), ',', '') AS INT);
    SET @SobanManduphongVal    = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanManduphong,    '0'), '.', ''), ',', '') AS INT);
    SET @SobanChaychinhthucVal = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChaychinhthuc, '0'), '.', ''), ',', '') AS INT);
    SET @SobanChayduphongVal   = TRY_CAST(REPLACE(REPLACE(ISNULL(@SobanChayduphong,   '0'), '.', ''), ',', '') AS INT);
    SET @TongSoBanVal          = TRY_CAST(REPLACE(REPLACE(ISNULL(@TongSoBan,          '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtienhopdongVal    = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtienhopdong,    '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencocchoVal       = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencoccho,       '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @SotiencochopdongVal   = TRY_CAST(REPLACE(REPLACE(ISNULL(@Sotiencochopdong,   '0'), '.', ''), ',', '') AS DECIMAL(18,2));
    SET @TongtiencocVal        = TRY_CAST(REPLACE(REPLACE(ISNULL(@Tongtiencoc,        '0'), '.', ''), ',', '') AS DECIMAL(18,2));

    IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '' AND LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
        SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';

    IF (@NgayToChucParsed IS NULL AND @Sohopdong IS NOT NULL AND @Sohopdong <> '')
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Hopdong WHERE Sohopdong = @Sohopdong;

    IF (@NgayToChucParsed IS NULL AND @Sobiennhan IS NOT NULL AND @Sobiennhan <> '')
        SELECT TOP 1 @NgayToChucParsed = Ngaytochuc FROM tbmk_Biennhancoccho WHERE DocumentID = @Sobiennhan OR SoBN = @Sobiennhan;

    IF (@NgayToChucParsed IS NULL)
    BEGIN
        SELECT 0 AS [Success], N'Loi: Ngay to chuc khong duoc de trong hoac dinh dang ngay khong hop le.' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
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
                SELECT 0 AS [Success], N'Loi: Sanh ban chon da duoc dat hoac coc truoc do trong ca tiec nay. Vui long kiem tra lai!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
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
                    @Tenchure, @Tencodau, @Dienthoai, @Diachi, @Mail, @BenB_CCCD, @BenB_CCCD, @BenB_CCCD, 1, @Now, @UserCreate);
            END
            ELSE
            BEGIN
                -- Cap nhat khach cu: chi ghi de khi co gia tri moi
                UPDATE dmkhachhang SET
                    Tenchure    = ISNULL(NULLIF(@Tenchure,   ''), Tenchure),
                    Tencodau    = ISNULL(NULLIF(@Tencodau,   ''), Tencodau),
                    Diachi      = ISNULL(NULLIF(@Diachi,     ''), Diachi),
                    Mail        = ISNULL(NULLIF(@Mail,       ''), Mail),
                    CMNDDaiDien = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDDaiDien),
                    CMNDchure   = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDchure),
                    CMNDcodau   = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDcodau),
                    DateUpdate  = @Now, UserUpdate = @UserCreate
                WHERE Makh = @Makh;
            END
        END
        ELSE
        BEGIN
            -- Co Makh truyen vao: chi ghi de khi gia tri moi KHONG rong
            UPDATE dmkhachhang SET
                Tenkh = CASE
                            WHEN ISNULL(@Tencodau,'')='' THEN ISNULL(NULLIF(@Tenchure,''), Tenkh)
                            WHEN ISNULL(@Tenchure,'')='' THEN ISNULL(NULLIF(@Tencodau,''), Tenkh)
                            ELSE @Tenchure + ' & ' + @Tencodau
                        END,
                Tenchure    = ISNULL(NULLIF(@Tenchure,   ''), Tenchure),
                Tencodau    = ISNULL(NULLIF(@Tencodau,   ''), Tencodau),
                Dienthoai   = ISNULL(NULLIF(@Dienthoai,  ''), Dienthoai),
                Diachi      = ISNULL(NULLIF(@Diachi,     ''), Diachi),
                Mail        = ISNULL(NULLIF(@Mail,       ''), Mail),
                CMNDDaiDien = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDDaiDien),
                CMNDchure   = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDchure),
                CMNDcodau   = ISNULL(NULLIF(@BenB_CCCD,  ''), CMNDcodau),
                DateUpdate  = @Now, UserUpdate = @UserCreate
            WHERE Makh = @Makh;
        END

        -- 2. XU LY HOP DONG
        IF (@Sohopdong IS NULL OR @Sohopdong = '')
        BEGIN
            SET @Sohopdong = 'HD' + FORMAT(@Now, 'yyMMddHHmmss');
            INSERT INTO tbmk_Hopdong (
                Sohopdong, Sobiennhan, Ngayhopdong, Ngaytochuc, Nhamngay, Makh, Loaitiecid, Thoigianid,
                SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, TongSoBan,
                Tongtienhopdong, Sotiencoccho, Sotiencochopdong, Tongtiencoc,
                Manv, Ghichu, IsHuy, IsKetthuc, DateCreate, UserCreate, GoiThucDonID,
                NoteBaoVe, NoteKyThuat, NoteBieuNgu, NoteLobby, JsonLichTrinh
            )
            VALUES (
                @Sohopdong, @Sobiennhan, ISNULL(@NgayHopDongParsed,@Now), @NgayToChucParsed, @Nhamngay, @Makh, @Loaitiecid, @Thoigianid,
                @SobanManchinhthucVal, @SobanManduphongVal, @SobanChaychinhthucVal, @SobanChayduphongVal, @TongSoBanVal,
                @TongtienhopdongVal, @SotiencocchoVal, @SotiencochopdongVal, @TongtiencocVal,
                @Manv, @Ghichu, 0, 0, @Now, @UserCreate, '',
                @NoteBaoVe, @NoteKyThuat, @NoteBieuNgu, @NoteLobby, @JsonLichTrinh
            );
            IF (@Sobiennhan IS NOT NULL AND @Sobiennhan != '')
                UPDATE tbmk_Biennhancoccho SET IsKetthuc=1, DateUpdate=@Now, UserUpdate=@UserCreate WHERE DocumentID=@Sobiennhan;
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM tbmk_Hopdong WHERE Sohopdong=@Sohopdong AND (Status IN ('SIGNED','COMPLETED') OR IsKetthuc=1 OR IsHuy=1))
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 0 AS [Success], N'Loi: Khong the chinh sua hop dong da chot. Vui long dung chuc nang Phu luc!' AS [Message], NULL AS [Sohopdong], NULL AS [Makh];
                RETURN;
            END
            UPDATE tbmk_Hopdong SET
                Sobiennhan=@Sobiennhan, Makh=@Makh, Ngayhopdong=@NgayHopDongParsed, Ngaytochuc=@NgayToChucParsed,
                Nhamngay=@Nhamngay, Loaitiecid=@Loaitiecid, Thoigianid=@Thoigianid,
                SobanManchinhthuc=@SobanManchinhthucVal, SobanManduphong=@SobanManduphongVal,
                SobanChaychinhthuc=@SobanChaychinhthucVal, SobanChayduphong=@SobanChayduphongVal,
                TongSoBan=@TongSoBanVal, Tongtienhopdong=@TongtienhopdongVal,
                Sotiencoccho=@SotiencocchoVal, Sotiencochopdong=@SotiencochopdongVal,
                Tongtiencoc=@TongtiencocVal, Ghichu=@Ghichu, DateUpdate=@Now, UserUpdate=@UserCreate,
                NoteBaoVe=@NoteBaoVe, NoteKyThuat=@NoteKyThuat, NoteBieuNgu=@NoteBieuNgu, NoteLobby=@NoteLobby,
                JsonLichTrinh=@JsonLichTrinh
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

        COMMIT TRANSACTION;
        SELECT 1 AS [Success], N'Luu Hop dong Tiec Cuoi thanh cong' AS [Message], @Sohopdong AS [Sohopdong], @Makh AS [Makh];
        
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

    h.Sohopdong AS [Sohopdong], -- Cột khoá chính thật
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
    
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Hopdongsanhtiec hs 
        INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
        WHERE hs.Sohopdong = h.Sohopdong
        ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
    ) AS [SanhDat],
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
    h.JsonLichTrinh,
    
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
    h.NguoinhanTT AS [BenB_TenChuTiec],
    ISNULL(NULLIF(k.CMNDDaiDien, ''), ISNULL(NULLIF(k.CMNDnguoidd, ''), ISNULL(NULLIF(k.CMNDchure, ''), '...'))) AS [BenB_CCCD],
    ISNULL(k.Diachi, '...') AS [BenB_DiaChi],
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenB_DienThoai],
    '' AS [BenB_ChucVu],

    -- Thông tin Tiệc
    (SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = h.Loaitiecid) AS [Tiec_LoaiTiec],
    ISNULL((
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
    ), '') AS [LoaiHinhSuKien],
    ISNULL(h.GioDienRaSuKien, '...') AS [Tiec_GioBatDau],

    -- Các trường lịch trình động dạng JSON phục vụ in ấn BEO mới
    (
        SELECT 
            t.BatDau AS [BatDau],
            t.KetThuc AS [KetThuc],
            t.Sanh AS [Sanh],
            t.NoiDung AS [NoiDung]
        FROM (
            SELECT 
                ISNULL(h.TuGioDenGioSetup, '...') AS BatDau, 
                ISNULL(h.DenGioSetup, '...') AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'Vào hàng hóa' AS NoiDung
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong

            UNION ALL

            SELECT 
                N'13h00' AS BatDau, 
                N'17h00' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                ISNULL(h.GhiChuSetup, N'SETUP: Không máy lạnh') AS NoiDung
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ) t
        FOR JSON PATH
    ) AS [LichTrinhSetup],

    (
        SELECT 
            t.BatDau AS [BatDau],
            t.KetThuc AS [KetThuc],
            t.Sanh AS [Sanh],
            t.NoiDung AS [NoiDung]
        FROM (
            -- RHS (Chạy ở Sảnh chính)
            SELECT 
                ISNULL(h.GioDienRaSuKien, '10h00') AS BatDau, 
                ISNULL(h.GioKetThucSuKien, '12h00') AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'RHS: Có ATAS, Led; không máy lạnh' AS NoiDung
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 1

            UNION ALL

            -- HỘI NGHỊ (Chạy ở Sảnh chính)
            SELECT 
                N'13h00' AS BatDau, 
                N'17h00' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'HỘI NGHỊ' AS NoiDung
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 1

            UNION ALL

            -- TIỆC (Chạy ở Sảnh tiệc / Sảnh 2, nếu không có sảnh 2 thì chạy ở sảnh chính)
            SELECT 
                N'18h00' AS BatDau, 
                N'22h00' AS KetThuc, 
                ISNULL(
                    (SELECT s2.Tensanhtiec 
                     FROM tbmk_Hopdongsanhtiec hs2 
                     INNER JOIN dmSanhtiec s2 ON hs2.Sanhtiecid = s2.Sanhtiecid 
                     WHERE hs2.Sohopdong = h.Sohopdong AND hs2.IsSanhchinh = 0),
                    (SELECT s3.Tensanhtiec 
                     FROM tbmk_Hopdongsanhtiec hs3 
                     INNER JOIN dmSanhtiec s3 ON hs3.Sanhtiecid = s3.Sanhtiecid 
                     WHERE hs3.Sohopdong = h.Sohopdong AND hs3.IsSanhchinh = 1)
                ) AS Sanh, 
                N'TIỆC' AS NoiDung
        ) t
        FOR JSON PATH
    ) AS [LichTrinhToChuc],

    (
        SELECT 
            t.BatDau AS [BatDau],
            t.KetThuc AS [KetThuc],
            t.Sanh AS [Sanh],
            t.NoiDung AS [NoiDung]
        FROM (
            SELECT 
                N'Trước 10h sáng' AS BatDau, 
                N'' AS KetThuc, 
                s.Tensanhtiec AS Sanh, 
                N'Ra hàng hóa' AS NoiDung
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ) t
        FOR JSON PATH
    ) AS [LichTrinhOut],
    
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
    
    RIGHT('0' + CAST(DAY(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_NgayDL],
    RIGHT('0' + CAST(MONTH(h.Ngaytochuc) AS VARCHAR), 2) AS [Tiec_ThangDL],
    CAST(YEAR(h.Ngaytochuc) AS VARCHAR) AS [Tiec_NamDL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 THEN SUBSTRING(h.Nhamngay, 1, CHARINDEX('/', h.Nhamngay) - 1)
        ELSE ISNULL(h.Nhamngay, '...')
    END AS [Tiec_NgayAL],
    CASE 
        WHEN CHARINDEX('/', h.Nhamngay) > 0 THEN SUBSTRING(h.Nhamngay, CHARINDEX('/', h.Nhamngay) + 1, LEN(h.Nhamngay))
        ELSE '...'
    END AS [Tiec_ThangAL],
    '...' AS [Tiec_NamAL],
    
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
    
    -- Các biến phục vụ hiển thị động Phương thức thanh toán (BEO)
    FORMAT(ISNULL(h.Sotiencoccho, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot1_SoTien],
    ISNULL(CONVERT(VARCHAR(10), (
        SELECT TOP 1 b.DocumentDate 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), 103), '...') AS [Dot1_Ngay],
    ISNULL((
        SELECT TOP 1 NULLIF(b.HinhThuc, '') 
        FROM tbmk_Biennhancoccho b 
        WHERE b.DocumentID = h.Sobiennhan
    ), N'Chuyển khoản') AS [Dot1_HinhThuc],
    
    FORMAT(ISNULL(h.Sotiencochopdong, 0), 'N0', 'vi-VN') + ' VNĐ' AS [Dot2_SoTien],
    N'Chuyển khoản' AS [Dot2_HinhThuc],
    
    ISNULL(NULLIF(h.Ghichu, ''), 
        CASE 
            WHEN (SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid) LIKE N'%Hội Nghị%' 
                THEN N'Thanh toán sau tiệc 07 ngày' 
            ELSE N'Thanh toán cuối tiệc.' 
        END
    ) AS [DotCuoi_GhiChu],
    
    ISNULL(h.NoteBaoVe, N'Danh sách vào + ra hàng hóa (BÁO SAU)') AS [NoteBaoVe],
    ISNULL(h.NoteKyThuat, N'Căng banner cổng chính: 8.5m*1.2m' + CHAR(13) + CHAR(10) + N'Căng Background sân khấu: 6m*3.5m (' + ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh ASC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...') + ')') AS [NoteKyThuat],
    ISNULL(h.NoteBieuNgu, N'Phối hợp với khách') AS [NoteBieuNgu],
    ISNULL(h.NoteLobby, N'Bàn Lễ Tân đón khách ' + ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh DESC), '...') + 
        CASE 
            WHEN EXISTS (SELECT 1 FROM tbmk_Hopdongsanhtiec hs WHERE hs.Sohopdong = h.Sohopdong AND hs.IsSanhchinh = 0)
                THEN N' và ' + ISNULL((SELECT s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = h.Sohopdong ORDER BY hs.IsSanhchinh ASC OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY), '...')
            ELSE N'' 
        END
    ) AS [NoteLobby],
    
    ISNULL(h.Ghichu, '') AS [DieuKhoanBoSung],
    ISNULL(h.Noidunguudai, '') AS [DS_KhuyenMai]
    
FROM tbmk_Hopdong h
LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
WHERE ISNULL(h.IsDeleted, 0) = 0;
GO

-- 1. Cập nhật Form Hợp Đồng chọc vào View này
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachHopDong', PrimaryKey = 'Sohopdong'
WHERE FormID = 'frmHopDong';
GO

-- 2. Đồng bộ lại cấu hình các cột giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
GO

-- 3. Đăng ký định tuyến Save trong WA_API
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Save';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Save',
    'API_LuuHopDong',
    '@Sohopdong=N''{Sohopdong}'', @Sobiennhan=N''{Sobiennhan}'', @Makh=N''{Makh}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @Dienthoai=N''{DienThoai}'', @Diachi=N''{Diachi}'', @Mail=N''{Mail}'', @BenB_CCCD=N''{BenB_CCCD}'', @Ngayhopdong=N''{Ngayhopdong}'', @Ngaytochuc=N''{NgayToChuc}'', @Nhamngay=N''{Nhamngay}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @TongSoBan=N''{SoBan}'', @Tongtienhopdong=N''{TongTien}'', @Sotiencoccho=N''{DaCocVND}'', @Sotiencochopdong=N''{Sotiencochopdong}'', @Tongtiencoc=N''{Tongtiencoc}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @JsonLichTrinh=N''{JsonLichTrinh}'''
);
GO

-- 4. Đăng ký định tuyến Delete trong WA_API
-- Truyền {Sohopdong} (khóa chính thực tế từ v_DanhSachHopDong) cho tham số @Ids của API_XoaDong
DELETE FROM WA_API WHERE List = 'frmHopDong' AND Func = 'Delete';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmHopDong',
    'Delete',
    'API_XoaDong',
    '@List=N''frmHopDong'', @Ids=N''{Sohopdong}'', @UserName=N''{User}'''
);
GO

-- 4. Cấu hình hiển thị và định dạng cho các trường nhập liệu Hợp đồng trong SY_FormatFields
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = '6'
WHERE FormName = 'frmHopDong'
  AND FieldName IN (
    'Tenchure', 'Tencodau', 'Diachi', 'Mail',
    'Ngayhopdong', 'NgayToChuc', 'Nhamngay', 'Loaitiecid', 'Thoigianid', 'JsonSanhTiec', 'JsonLichTrinh',
    'SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong',
    'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc'
  );

-- Số CCCD Bên B ẩn khỏi giao diện Grid và Form (FormPosition = 'hidden')
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInAdd = 0, ShowInEdit = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

-- Ghi chú bổ sung
UPDATE SY_FormatFields
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, ShowInFilter = 0, FormPosition = 'form'
WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';

-- Ẩn các cột chỉ dùng để IN ẤN khỏi giao diện Grid/Form
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmHopDong' 
  AND FieldName IN (
    'NgayLapHD', 'ThangLapHD', 'NamLapHD',
    'BenA_NhanVienPhuTrach', 'BenA_SDT_NhanVien',
    'BenB_TenDaiDien', 'BenB_TenChuTiec', 'BenB_DiaChi', 'BenB_DienThoai', 'BenB_ChucVu',
    'Tiec_GioBatDau', 'Tiec_NgayDL', 'Tiec_ThangDL', 'Tiec_NamDL',
    'Tiec_NgayAL', 'Tiec_ThangAL', 'Tiec_NamAL',
    'Tiec_SanhTiec', 'Sanh_QuyMoMin', 'Sanh_QuyMoMax',
    'Tiec_SoBanChinhThuc', 'Tiec_SoBanTang', 'Tiec_SoBanDuPhong', 'Tiec_SoKhach1Ban',
    'Coc_Lan1_SoTien', 'Coc_Lan1_BangChu', 'Coc_Ngay', 'Coc_Thang', 'Coc_Nam',
    'Coc_Lan2_SoTien', 'Coc_Lan2_BangChu',
    'DieuKhoanBoSung', 'DS_KhuyenMai',
    'BenB_CCCD', 'BenA_NguoiDaiDien', 'BenA_ChucVu'
  );

-- Đồng bộ hóa tên trường "Ngày tổ chức" về duy nhất "NgayToChuc" (chữ hoa chữ T)
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc')
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc')
        DELETE FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc';
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc';
END
GO
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc')
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc')
        DELETE FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc';
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc';
END
GO

-- Đảm bảo trường NgayToChuc luôn tồn tại trong cấu hình Form kèm Trigger tính lịch âm
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc')
BEGIN
    INSERT INTO SY_FormatFields (
        FormatID, FieldName, FormName, CaptionVN, IsRequired, 
        FormPosition, ShowInForm, OrderNo, ShowInAdd, ShowInEdit, 
        IsReadOnlyAdd, IsReadOnlyEdit, ValidateRule
    )
    VALUES (
        'dt', 'NgayToChuc', 'frmHopDong', N'Ngày tổ chức', 1, 
        '6', 1, 11, 1, 1, 
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

-- Ẩn các trường tính toán tự động khỏi Form (chỉ hiện trên Grid lưới) hoặc cấu hình Read-Only khi sửa
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName IN ('TenKhachHang', 'Tiec_LoaiTiec');

UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('Makh', 'SoBan', 'SanhDat', 'TongTien', 'TrangThai', 'Sohopdong');

-- CCCD Bên B: lấy từ dmkhachhang, ẩn khỏi form
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

-- Bên A (thông tin nhà hàng): ẩn khỏi form HĐ
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName IN ('BenA_NguoiDaiDien', 'BenA_ChucVu');

UPDATE SY_FormatFields SET FormatID = 't' WHERE FormName = 'frmHopDong' AND FieldName IN ('Tenchure', 'Tencodau', 'Diachi', 'Mail', 'BenB_CCCD', 'Ghichu');
UPDATE SY_FormatFields SET FormatID = 'dt' WHERE FormName = 'frmHopDong' AND FieldName IN ('Ngayhopdong', 'NgayToChuc');
UPDATE SY_FormatFields SET FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET FormatID = 'sl' WHERE FormName = 'frmHopDong' AND FieldName IN ('Loaitiecid', 'Thoigianid', 'JsonSanhTiec');
UPDATE SY_FormatFields SET FormatID = 'n' WHERE FormName = 'frmHopDong' AND FieldName IN ('SobanManchinhthuc', 'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong', 'DaCocVND', 'Sotiencochopdong', 'Tongtiencoc');

-- Cấu hình DataSource cho các Dropdown
UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';

UPDATE SY_FormatFields
SET DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';

-- Cập nhật tên tiếng Việt thân thiện
UPDATE SY_FormatFields SET CaptionVN = N'Ngày lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'ThangLapHD';
UPDATE SY_FormatFields SET CaptionVN = N'Năm lập HĐ' WHERE FormName = 'frmHopDong' AND FieldName = 'NamLapHD';

UPDATE SY_FormatFields SET CaptionVN = N'Nhân viên phụ trách' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NhanVienPhuTrach';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT nhân viên' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_SDT_NhanVien';
UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_NguoiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên A' WHERE FormName = 'frmHopDong' AND FieldName = 'BenA_ChucVu';

UPDATE SY_FormatFields SET CaptionVN = N'Đại diện Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Chủ Tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_TenChuTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DiaChi';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Chức vụ Bên B' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_ChucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Số CCCD (Bên B)' WHERE FormName = 'frmHopDong' AND FieldName = 'BenB_CCCD';

UPDATE SY_FormatFields SET CaptionVN = N'Giờ bắt đầu' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_GioBatDau';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayDL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangDL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (DL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamDL';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NgayAL';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_ThangAL';
UPDATE SY_FormatFields SET CaptionVN = N'Năm đãi tiệc (AL)' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_NamAL';

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SanhTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối thiểu' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMin';
UPDATE SY_FormatFields SET CaptionVN = N'Quy mô tối đa' WHERE FormName = 'frmHopDong' AND FieldName = 'Sanh_QuyMoMax';

UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chính thức' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanChinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tặng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanTang';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn dự phòng' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoBanDuPhong';
UPDATE SY_FormatFields SET CaptionVN = N'Số khách/Bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'Tiec_SoKhach1Ban';

UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan1_BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan2_SoTien';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền cọc lần 2 bằng chữ' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Lan2_BangChu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Ngay';
UPDATE SY_FormatFields SET CaptionVN = N'Tháng cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Thang';
UPDATE SY_FormatFields SET CaptionVN = N'Năm cọc' WHERE FormName = 'frmHopDong' AND FieldName = 'Coc_Nam';

UPDATE SY_FormatFields SET CaptionVN = N'Điều khoản bổ sung' WHERE FormName = 'frmHopDong' AND FieldName = 'DieuKhoanBoSung';
UPDATE SY_FormatFields SET CaptionVN = N'Khuyến mãi' WHERE FormName = 'frmHopDong' AND FieldName = 'DS_KhuyenMai';

-- Cập nhật tên tiếng Việt cho các trường mới
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

-- Cập nhật tên tiếng Việt thân thiện cho các cột gốc (Grid mặc định)
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET CaptionVN = N'Mã KH' WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET CaptionVN = N'Tên khách hàng' WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn' WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt' WHERE FormName = 'frmHopDong' AND FieldName = 'SanhDat';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET CaptionVN = N'Trạng thái' WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
-- Cập nhật và tự động thêm CaptionVN cho các cột trường bổ sung của Hợp đồng
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'LoaiHinhSuKien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'LoaiHinhSuKien', N'Loại hình sự kiện', 0, 0, 0, 95, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Loại hình sự kiện' WHERE FormName = 'frmHopDong' AND FieldName = 'LoaiHinhSuKien';

-- Xoá các cột Lịch trình cũ khỏi SY_FormatFields
DELETE FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName IN ('LichTrinhSetup', 'LichTrinhToChuc', 'LichTrinhOut');

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'LichTrinhThanhToan')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, DataSource, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'LichTrinhThanhToan', N'Lịch trình thanh toán (JSON)', 'js', N'[{"key":"STT","label":"Đợt","type":"number","width":"60px"},{"key":"SoTien","label":"Số tiền","type":"text","width":"150px"},{"key":"Ngay","label":"Ngày","type":"text","width":"120px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]', 0, 0, 0, 99, '12');
ELSE
    UPDATE SY_FormatFields 
    SET CaptionVN = N'Lịch trình thanh toán (JSON)',
        FormatID = 'js',
        DataSource = N'[{"key":"STT","label":"Đợt","type":"number","width":"60px"},{"key":"SoTien","label":"Số tiền","type":"text","width":"150px"},{"key":"Ngay","label":"Ngày","type":"text","width":"120px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]'
    WHERE FormName = 'frmHopDong' AND FieldName = 'LichTrinhThanhToan';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_SoTien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1_SoTien', N'Số tiền đợt 1', 0, 0, 0, 100, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Số tiền đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_SoTien';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_Ngay')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1_Ngay', N'Ngày thu đợt 1', 0, 0, 0, 101, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ngày thu đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_Ngay';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_HinhThuc')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot1_HinhThuc', N'Hình thức thu đợt 1', 0, 0, 0, 102, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thu đợt 1' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot1_HinhThuc';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2_SoTien')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot2_SoTien', N'Số tiền đợt 2', 0, 0, 0, 103, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Số tiền đợt 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2_SoTien';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2_HinhThuc')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'Dot2_HinhThuc', N'Hình thức thu đợt 2', 0, 0, 0, 104, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thu đợt 2' WHERE FormName = 'frmHopDong' AND FieldName = 'Dot2_HinhThuc';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'DotCuoi_GhiChu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmHopDong', 'DotCuoi_GhiChu', N'Ghi chú đợt cuối', 0, 0, 0, 105, '6');
ELSE
    UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú đợt cuối' WHERE FormName = 'frmHopDong' AND FieldName = 'DotCuoi_GhiChu';

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

-- Cấu hình thứ tự hiển thị (OrderNo) trên Form
UPDATE SY_FormatFields SET OrderNo = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET OrderNo = 2 WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET OrderNo = 3 WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
UPDATE SY_FormatFields SET OrderNo = 4 WHERE FormName = 'frmHopDong' AND FieldName = 'TenKhachHang';
UPDATE SY_FormatFields SET OrderNo = 5 WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 6 WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 7 WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET OrderNo = 8 WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 9 WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 10 WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET OrderNo = 11 WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 12 WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 13 WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 14 WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET OrderNo = 15 WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET OrderNo = 16 WHERE FormName = 'frmHopDong' AND FieldName = 'SoBan';
UPDATE SY_FormatFields SET OrderNo = 17 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET OrderNo = 18 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET OrderNo = 19 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET OrderNo = 20 WHERE FormName = 'frmHopDong' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET OrderNo = 21 WHERE FormName = 'frmHopDong' AND FieldName = 'DaCocVND';
UPDATE SY_FormatFields SET OrderNo = 22 WHERE FormName = 'frmHopDong' AND FieldName = 'Sotiencochopdong';
UPDATE SY_FormatFields SET OrderNo = 23 WHERE FormName = 'frmHopDong' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET OrderNo = 24 WHERE FormName = 'frmHopDong' AND FieldName = 'TongTien';
UPDATE SY_FormatFields SET OrderNo = 25 WHERE FormName = 'frmHopDong' AND FieldName = 'TrangThai';
UPDATE SY_FormatFields SET OrderNo = 26 WHERE FormName = 'frmHopDong' AND FieldName = 'Ghichu';
GO

-- Ẩn/Hiện và khóa (Read-Only) các trường mã tự sinh bởi database
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';

UPDATE SY_FormatFields 
SET IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName = 'Makh';
GO

-- Đăng ký các cột ghi chú phòng ban (Bảo vệ, Kỹ thuật, Biểu ngữ) vào metadata Form Hợp Đồng
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBaoVe')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, OrderNo, ControlType, Width, IsRequire, IsVisible, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmHopDong', 'NoteBaoVe', N'Ghi chú Bảo Vệ (Hàng hóa)', 30, 'TEXTAREA', 200, 0, 1, 1, 1, 0, 0)
END
GO
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteKyThuat')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, OrderNo, ControlType, Width, IsRequire, IsVisible, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmHopDong', 'NoteKyThuat', N'Ghi chú Kỹ Thuật (Banner/BG)', 31, 'TEXTAREA', 200, 0, 1, 1, 1, 0, 0)
END
GO
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBieuNgu')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, OrderNo, ControlType, Width, IsRequire, IsVisible, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmHopDong', 'NoteBieuNgu', N'Ghi chú Biểu Ngữ Sân Khấu', 32, 'TEXTAREA', 200, 0, 1, 1, 1, 0, 0)
END
GO
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NoteLobby')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, OrderNo, ControlType, Width, IsRequire, IsVisible, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmHopDong', 'NoteLobby', N'Ghi chú Khu vực Đón khách (Lobby)', 33, 'TEXTAREA', 200, 0, 1, 1, 1, 0, 0)
END
GO

-- Configure format for JsonLichTrinh as Master-Detail Grid
UPDATE SY_FormatFields 
SET FormatID = 'js',
    DataSource = N'[{"key":"BatDau","label":"Bắt đầu","type":"text","width":"100px"},{"key":"KetThuc","label":"Kết thúc","type":"text","width":"100px"},{"key":"Sanh","label":"Sảnh","type":"text","width":"180px"},{"key":"NoiDung","label":"Nội dung","type":"text","width":"auto"}]',
    FormPosition = '12',
    CaptionVN = N'Lịch trình BEO (JSON)',
    OrderNo = 27
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonLichTrinh';
GO

UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú Bảo Vệ (Hàng hóa)', OrderNo = 30, ControlType = 'TEXTAREA', IsVisible = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBaoVe';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú Kỹ Thuật (Banner/BG)', OrderNo = 31, ControlType = 'TEXTAREA', IsVisible = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'NoteKyThuat';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú Biểu Ngữ Sân Khấu', OrderNo = 32, ControlType = 'TEXTAREA', IsVisible = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'NoteBieuNgu';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú Khu vực Lobby', OrderNo = 33, ControlType = 'TEXTAREA', IsVisible = 1 WHERE FormName = 'frmHopDong' AND FieldName = 'NoteLobby';
GO
