USE [QLTiec]
GO

-- =====================================================================
-- 1. THÊM CÁC CỘT MỚI VÀO BẢNG TBMK_BIENNHANCOCCHO (NẾU CHƯA CÓ)
-- =====================================================================
PRINT N'Đang cấu hình cấu trúc bảng tbmk_Biennhancoccho...';
IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'TaiKhoanNo' AND Object_ID = Object_ID(N'tbmk_Biennhancoccho'))
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD TaiKhoanNo VARCHAR(50) NULL;
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'TaiKhoanCo' AND Object_ID = Object_ID(N'tbmk_Biennhancoccho'))
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD TaiKhoanCo VARCHAR(50) NULL;
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Kemtheo' AND Object_ID = Object_ID(N'tbmk_Biennhancoccho'))
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD Kemtheo NVARCHAR(255) NULL;
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'Lydo' AND Object_ID = Object_ID(N'tbmk_Biennhancoccho'))
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD Lydo NVARCHAR(255) NULL;
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE Name = N'HinhThuc' AND Object_ID = Object_ID(N'tbmk_Biennhancoccho'))
BEGIN
    ALTER TABLE tbmk_Biennhancoccho ADD HinhThuc NVARCHAR(100) NULL;
END
GO

-- =====================================================================
-- 2. CẬP NHẬT VIEW V_DANHSACHPHIEUCOC
-- =====================================================================
PRINT N'Đang cập nhật View v_DanhSachPhieuCoc...';
GO
IF EXISTS(SELECT * FROM sys.views WHERE name = 'v_DanhSachPhieuCoc' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW [dbo].[v_DanhSachPhieuCoc];
END
GO
CREATE VIEW [dbo].[v_DanhSachPhieuCoc] AS
SELECT 
    b.DocumentID,
    b.DocumentID AS MaChungTu,
    b.DocumentID AS Sohopdong,
    b.Makh AS Makh,
    b.SoBN AS SoPhieu,
    b.Thoigianid,
    b.Loaitiecid,
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmBiennhancoccho' AND tm.Loaitiecid = b.Loaitiecid) AS [TemplateFile],
    b.Nhamngay,
    b.SobanManchinhthuc,
    b.SobanChaychinhthuc,
    b.SobanManduphong,
    b.SobanChayduphong,
    b.Ghichu,
    
    k.Tenchure,
    k.Tencodau,
    k.DTchure,
    k.DTcodau,
    k.Diachi,
    k.Nguoigd,
    k.DienThoaiDaiDien,
    k.Mail,
    
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS TenKhachHang,
    
    -- THÊM CÁC TRƯỜNG THEO CHUẨN MARKDOWN ĐỂ ĐỔ DỮ LIỆU VÀO FILE WORD
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS BenBTenDaiDien,
    
    ISNULL(k.Diachi, '...') AS BenBDiaChi,
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS BenBDienThoai,
    ISNULL(k.Mail, '...') AS BenBEmail,
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS DienThoai,
    
    b.Ngaytochuc AS [NgayToChuc],
    ISNULL(b.Tongsoban, 0) AS SoBan,
    STUFF((
          SELECT N', ' + s.Tensanhtiec
          FROM tbmk_Biennhancocchosanhtiec bs 
          INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
          WHERE bs.DocumentID = b.DocumentID
          ORDER BY bs.IsSanhchinh DESC, s.Tensanhtiec ASC
          FOR XML PATH('')
      ), 1, 2, '') AS [SanhDat],
    ISNULL(b.Tongtien, 0) AS DaCocVND,
    
    b.Solan AS [Solan],
    b.TaiKhoanNo,
    b.TaiKhoanCo,
    b.Kemtheo,
    b.Lydo,
    b.HinhThuc,
    
    STUFF((
          SELECT ',' + Sanhtiecid 
          FROM tbmk_Biennhancocchosanhtiec 
          WHERE DocumentID = b.DocumentID 
            AND Sanhtiecid <> '.' AND Sanhtiecid <> ''
          ORDER BY IsSanhchinh DESC
          FOR XML PATH('')
      ), 1, 1, '') AS [JsonSanhTiec],
    
    
    -- FORMAT NGÀY THÁNG LẬP PHIẾU ĐỂ XUẤT WORD
    RIGHT('0' + CAST(DAY(b.DocumentDate) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(b.DocumentDate) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(b.DocumentDate) AS VARCHAR) AS [NamLapHD],
    
    -- THÔNG TIN XUẤT HÓA ĐƠN GTGT (Nếu phiếu thu dùng chung mẫu với Hợp Đồng)
    N'...' AS [HDTenCty],
    N'...' AS [HDDiaChi],
    N'...' AS [HDMaSoThue],
    ISNULL(k.Mail, N'...') AS [HDEmail],
    
    CASE
        WHEN b.IsHuy = 1 THEN N'Đã Hủy'
        WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
        WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
        ELSE N'Đã cọc lần 1'
    END AS TrangThai,
    
    b.GoiThucDonID AS [GoiThucDonID],
    gd.TenGoiThucDon AS [GoiTiec]

FROM tbmk_Biennhancoccho b
LEFT JOIN dmkhachhang k ON b.Makh = k.Makh
LEFT JOIN dmGoiThucDon gd ON b.GoiThucDonID = gd.GoiThucDonID
WHERE ISNULL(b.IsDeleted, 0) = 0;
GO

-- =====================================================================
-- 3. CẬP NHẬT STORED PROCEDURE API_DANHSACHPHIEUCOC
-- =====================================================================
PRINT N'Đang cập nhật Stored Procedure API_DanhSachPhieuCoc...';
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_DanhSachPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_DanhSachPhieuCoc];
END
GO
CREATE PROCEDURE [dbo].[API_DanhSachPhieuCoc]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.DocumentID AS [DocumentID],
        b.DocumentID AS [MaChungTu],
        b.SoBN AS [SoPhieu],
        
        k.Tenchure AS [Tenchure],
        k.Tencodau AS [Tencodau],
        k.DTchure AS [DTchure],
        k.DTcodau AS [DTcodau],
        k.Diachi AS [Diachi],
        k.Nguoigd AS [Nguoigd],
        k.DienThoaiDaiDien AS [DienThoaiDaiDien],
        k.Mail AS [Mail],
        
        b.Thoigianid AS [Thoigianid],
        b.Loaitiecid AS [Loaitiecid],
        b.Nhamngay AS [Nhamngay],
        b.SobanManchinhthuc AS [SobanManchinhthuc],
        b.SobanManduphong AS [SobanManduphong],
        b.SobanChaychinhthuc AS [SobanChaychinhthuc],
        b.SobanChayduphong AS [SobanChayduphong],
        b.Ghichu AS [Ghichu],
        
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com1') AS [TenNhaHang],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'Com2') AS [DiaChiNhaHang],
        ISNULL(NULLIF(b.Lydo, ''), N'Cọc giữ chỗ lần ' + CAST(ISNULL(b.Solan, 1) AS NVARCHAR(10))) AS [Lydo],
        RIGHT('0' + CAST(d.Ngay AS VARCHAR(2)), 2) AS [Ngay],
        RIGHT('0' + CAST(d.Thang AS VARCHAR(2)), 2) AS [Thang],
        d.Nam AS [Nam],
        CONVERT(VARCHAR(10), d.DDate, 103) AS [NgayThu],
        d.DDate AS [DocumentDate],
        b.DocumentID AS [Sohopdong],
        FORMAT(ISNULL(b.Tongtien, 0), 'N0', 'vi-VN') AS [TongTien],
        ISNULL(b.Tongtien, 0) AS [TongTienRaw],
        [dbo].[fn_DocTienBangChu](ISNULL(b.Tongtien, 0)) AS [SoTienBangChu],
        ISNULL(b.TaiKhoanNo, '') AS [TaiKhoanNo],
        ISNULL(b.TaiKhoanCo, '') AS [TaiKhoanCo],
        ISNULL(b.Kemtheo, '') AS [Kemtheo],
        ISNULL(NULLIF(b.HinhThuc, ''), N'Tiền mặt / Chuyển khoản') AS [HinhThuc],
        
        c.FullName AS [TenKhachHang],
        ISNULL(NULLIF(k.Nguoigd, ''), c.FullName) AS [Nguoinop],
        
        ISNULL(NULLIF(k.Dienthoai, ''), ISNULL(NULLIF(k.DTchure, ''), ISNULL(NULLIF(k.DTcodau, ''), k.DienThoaiDaiDien))) AS [DienThoai],
        
        b.Solan AS [Solan],
        b.Ngaytochuc AS [NgayToChuc],
        ISNULL(b.Tongsoban, 0) AS [SoBan],
        
        STUFF((
            SELECT ', ' + s.Tensanhtiec + CASE WHEN bs.IsSanhchinh = 1 THEN N' (Chính)' ELSE N' (Phụ)' END
            FROM tbmk_Biennhancocchosanhtiec bs 
            INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
            WHERE bs.DocumentID = b.DocumentID
            ORDER BY bs.IsSanhchinh DESC, s.Tensanhtiec ASC
            FOR XML PATH('')
        ), 1, 2, '') AS [SanhDat],
        
        ISNULL(
            CASE 
                WHEN ISNULL(b.Solan, 1) = 2 THEN 
                    ISNULL(
                        (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentID = b.DocumentIDcu),
                        (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE Makh = b.Makh AND Solan = 1 AND ISNULL(IsHuy, 0) = 0)
                    )
                ELSE b.Tongtien 
            END, 0
        ) AS [DaCocVND],
        ISNULL(
            CASE 
                WHEN ISNULL(b.Solan, 1) = 2 THEN b.Tongtien
                ELSE 
                    ISNULL(
                        (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentIDcu = b.DocumentID AND Solan = 2),
                        (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE Makh = b.Makh AND Solan = 2 AND ISNULL(IsHuy, 0) = 0)
                    )
            END, 0
        ) AS [Sotiencochopdong],
        
        STUFF((
          SELECT ',' + Sanhtiecid 
          FROM tbmk_Biennhancocchosanhtiec 
          WHERE DocumentID = b.DocumentID 
            AND Sanhtiecid <> '.' AND Sanhtiecid <> ''
          ORDER BY IsSanhchinh DESC
          FOR XML PATH('')
      ), 1, 1, '') AS [JsonSanhTiec],
        
        CASE
            WHEN b.IsHuy = 1 THEN N'Đã Hủy'
            WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
            WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
            ELSE N'Đã cọc lần 1'
        END AS [TrangThai],
        
        b.GoiThucDonID AS [GoiThucDonID],
        gd.TenGoiThucDon AS [GoiTiec]
        
    FROM 
        tbmk_Biennhancoccho b
    LEFT JOIN 
        dmkhachhang k ON b.Makh = k.Makh
    LEFT JOIN
        dmGoiThucDon gd ON b.GoiThucDonID = gd.GoiThucDonID
    OUTER APPLY (
        SELECT 
            CASE 
                WHEN ISNULL(k.Tenchure, '') <> '' AND ISNULL(k.Tencodau, '') <> '' 
                    THEN k.Tenchure + ' & ' + k.Tencodau
                WHEN ISNULL(k.Tenchure, '') <> ''
                    THEN k.Tenchure
                WHEN ISNULL(k.Tencodau, '') <> ''
                    THEN k.Tencodau
                ELSE ISNULL(NULLIF(k.Tenkh, ''), ISNULL(NULLIF(k.Nguoigd, ''), N'Khách vãng lai'))
            END AS FullName
    ) c
    OUTER APPLY (
        SELECT 
            ISNULL(b.DocumentDate, GETDATE()) AS DDate,
            DAY(ISNULL(b.DocumentDate, GETDATE())) AS Ngay,
            MONTH(ISNULL(b.DocumentDate, GETDATE())) AS Thang,
            YEAR(ISNULL(b.DocumentDate, GETDATE())) AS Nam
    ) d
    WHERE 
        (@Keyword IS NULL OR @Keyword = '' OR b.DocumentID LIKE '%' + @Keyword + '%' OR b.SoBN LIKE '%' + @Keyword + '%' OR k.Dienthoai LIKE '%' + @Keyword + '%' OR k.Tenkh LIKE N'%' + @Keyword + '%' OR k.Tenchure LIKE N'%' + @Keyword + '%' OR k.Tencodau LIKE N'%' + @Keyword + '%')
        AND (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc <= @DenNgay)
        AND ISNULL(b.IsDeleted, 0) = 0
        
    ORDER BY 
        b.Ngaytochuc DESC, b.DocumentDate DESC;
END
GO

-- =====================================================================
-- 4. CẬP NHẬT STORED PROCEDURE API_LUUPHIEUCOC
-- =====================================================================
PRINT N'Đang cập nhật Stored Procedure API_LuuPhieuCoc...';
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_LuuPhieuCoc]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[API_LuuPhieuCoc];
END
GO
CREATE PROCEDURE [dbo].[API_LuuPhieuCoc]
    @DocumentID VARCHAR(50) = NULL OUTPUT,
    @Makh VARCHAR(50) = NULL OUTPUT,
    @Tenchure NVARCHAR(255) = NULL,
    @Tencodau NVARCHAR(255) = NULL,
    @DTchure NVARCHAR(50) = NULL,
    @DTcodau NVARCHAR(50) = NULL,
    @Diachi NVARCHAR(500) = NULL,
    @Nguoigd NVARCHAR(100) = NULL,
    @DienThoaiDaiDien NVARCHAR(50) = NULL,
    @Mail NVARCHAR(100) = NULL,
    
    @DocumentDate DATETIME = NULL,
    @NgayToChuc DATETIME = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL,
    @GoiThucDonID VARCHAR(50) = NULL,
    @SobanManchinhthuc INT = 0,
    @SobanManduphong INT = 0,
    @SobanChaychinhthuc INT = 0,
    @SobanChayduphong INT = 0,
    @Tongtien NVARCHAR(50) = NULL,
    @Solan TINYINT = 1,
    @Ghichu NVARCHAR(500) = NULL,
    @Manv VARCHAR(50) = NULL,
    @UserCreate VARCHAR(50) = 'System',
    
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    
    @MaChungTu VARCHAR(50) = NULL,
    @TongtienRaw NVARCHAR(50) = NULL,
    
    @TaiKhoanNo VARCHAR(50) = NULL,
    @TaiKhoanCo VARCHAR(50) = NULL,
    @Kemtheo NVARCHAR(255) = NULL,
    @Lydo NVARCHAR(255) = NULL,
    @HinhThuc NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    

    
    BEGIN TRY
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

        IF @MaChungTu IS NOT NULL AND (@DocumentID IS NULL OR @DocumentID = '')
            SET @DocumentID = @MaChungTu;
            
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
        IF @Ngaytochuc IS NULL OR @Ngaytochuc <= '1900-01-01'
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
                  AND Ngaytochuc = @Ngaytochuc
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
            IF EXISTS (
                -- 1. Trùng với Hợp đồng khác đang hoạt động
                SELECT 1 
                FROM tbmk_Hopdong h
                INNER JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON hs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE h.Ngaytochuc = @Ngaytochuc 
                  AND h.Thoigianid = @Thoigianid
                  AND ISNULL(h.IsHuy, 0) = 0
                  
                UNION ALL
                
                -- 2. Trùng với Biên nhận cọc chỗ khác đang hoạt động (chưa chuyển thành HĐ)
                SELECT 1 
                FROM tbmk_Biennhancoccho b
                INNER JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID
                INNER JOIN OPENJSON(@JsonSanhTiec) j ON bs.Sanhtiecid = JSON_VALUE(j.value, '$.Sanhtiecid')
                WHERE b.Ngaytochuc = @Ngaytochuc 
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

        IF (@Makh IS NULL OR @Makh = '') AND (@DocumentID IS NOT NULL AND @DocumentID <> '')
        BEGIN
            SELECT @Makh = Makh FROM tbmk_Biennhancoccho WHERE DocumentID = @DocumentID;
        END

        DECLARE @IsNewCustomer BIT = 0;

        IF (@Makh IS NULL OR @Makh = '')
        BEGIN
            DECLARE @SdtTimkiem NVARCHAR(50) = ISNULL(NULLIF(@DTchure, ''), @DTcodau);
            IF (@SdtTimkiem IS NOT NULL AND @SdtTimkiem <> '')
            BEGIN
                SELECT TOP 1 @Makh = Makh
                FROM dmkhachhang
                WHERE (Dienthoai = @SdtTimkiem OR DTchure = @SdtTimkiem OR DTcodau = @SdtTimkiem)
                  AND ISNULL(Tenchure, '') = ISNULL(@Tenchure, '') 
                  AND ISNULL(Tencodau, '') = ISNULL(@Tencodau, '')
                ORDER BY DateCreate ASC;
            END

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

        -- Nếu không phải khách hàng mới tạo, chỉ cập nhật các trường CÓ GIÁ TRỊ MỚI
        -- Dùng ISNULL(NULLIF(...,''), existing_col) để tránh ghi đè rỗng lên dữ liệu cũ
        -- (tránh ảnh hưởng đến các phiếu/hợp đồng khác cùng khách)
        IF (@IsNewCustomer = 0)
        BEGIN
            UPDATE dmkhachhang
            SET 
                Tenkh = CASE 
                            WHEN ISNULL(@Tenchure, '') <> '' AND ISNULL(@Tencodau, '') <> '' THEN @Tenchure + ' & ' + @Tencodau
                            WHEN ISNULL(@Tenchure, '') <> '' THEN @Tenchure
                            WHEN ISNULL(@Tencodau, '') <> '' THEN @Tencodau
                            ELSE Tenkh  -- ← giữ nguyên nếu không truyền
                        END,
                Tenchure         = ISNULL(NULLIF(@Tenchure, ''), Tenchure),
                Tencodau         = ISNULL(NULLIF(@Tencodau, ''), Tencodau),
                DTchure          = ISNULL(NULLIF(@DTchure, ''), DTchure),
                DTcodau          = ISNULL(NULLIF(@DTcodau, ''), DTcodau),
                Dienthoai        = ISNULL(NULLIF(@DTchure, ''), ISNULL(NULLIF(@DTcodau, ''), ISNULL(NULLIF(@DienThoaiDaiDien, ''), Dienthoai))),
                Diachi           = ISNULL(NULLIF(@Diachi, ''), Diachi),
                Nguoigd          = ISNULL(NULLIF(@Nguoigd, ''), Nguoigd),
                DienThoaiDaiDien = ISNULL(NULLIF(@DienThoaiDaiDien, ''), DienThoaiDaiDien),
                Mail             = ISNULL(NULLIF(@Mail, ''), Mail),
                DateUpdate       = @Now,
                UserUpdate       = @UserCreate
            WHERE Makh = @Makh;
        END

        IF (@DocumentID IS NULL OR @DocumentID = '')
        BEGIN
            DECLARE @TodayStr VARCHAR(8) = FORMAT(@Now, 'yyMMdd');
            DECLARE @Counter INT;
            
            SELECT @Counter = COUNT(*) + 1 
            FROM tbmk_Biennhancoccho 
            WHERE CONVERT(DATE, DateCreate) = CONVERT(DATE, @Now);

            DECLARE @SoBN VARCHAR(50) = 'BNCC-' + @TodayStr + '-' + RIGHT('00' + CAST(@Counter AS VARCHAR), 3);
            SET @DocumentID = 'BNCC' + FORMAT(@Now, 'yyMMddHHmmss');

            INSERT INTO tbmk_Biennhancoccho (
                DocumentID, SoBN, DocumentDate, Makh, Solan, Manv, Loaitiecid,
                Ngaytochuc, Nhamngay, Tongtien, Tongsoban, SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong,
                Thoigianid, Ghichu, IsHuy, IsKetthuc, GoiThucDonID, DateCreate, UserCreate,
                TaiKhoanNo, TaiKhoanCo, Kemtheo, Lydo, HinhThuc
            )
            VALUES (
                @DocumentID, @SoBN, ISNULL(@DocumentDate, @Now), @Makh, @Solan, @Manv, @Loaitiecid,
                @Ngaytochuc, @Nhamngay, @TongTienDecimal, @Tongsoban, @SobanManchinhthuc, @SobanManduphong, @SobanChaychinhthuc, @SobanChayduphong,
                @Thoigianid, @Ghichu, 0, 0, ISNULL(@GoiThucDonID, ''), @Now, @UserCreate,
                @TaiKhoanNo, @TaiKhoanCo, @Kemtheo, @Lydo, @HinhThuc
            );
        END
        ELSE
        BEGIN
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

            UPDATE tbmk_Biennhancoccho
            SET 
                Makh = @Makh,
                Solan = @Solan,
                Loaitiecid = @Loaitiecid,
                Ngaytochuc = @Ngaytochuc,
                Nhamngay = @Nhamngay,
                Tongtien = @TongTienDecimal,
                Tongsoban = @Tongsoban,
                SobanManchinhthuc = @SobanManchinhthuc,
                SobanManduphong = @SobanManduphong,
                SobanChaychinhthuc = @SobanChaychinhthuc,
                SobanChayduphong = @SobanChayduphong,
                Thoigianid = @Thoigianid,
                GoiThucDonID = ISNULL(@GoiThucDonID, GoiThucDonID),
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

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            DELETE FROM tbmk_Biennhancocchosanhtiec WHERE DocumentID = @DocumentID;

            INSERT INTO tbmk_Biennhancocchosanhtiec (
                UserAutoid, DocumentID, Sanhtiecid, IsSanhchinh, 
                DateCreate, UserCreate
            )
            SELECT 
                NEWID(), 
                @DocumentID, 
                JSON_VALUE(value, '$.Sanhtiecid'),
                ISNULL(CAST(JSON_VALUE(value, '$.IsSanhchinh') AS BIT), 0),
                @Now,
                @UserCreate
            FROM OPENJSON(@JsonSanhTiec);
        END

        COMMIT TRANSACTION;
        SELECT 1 AS [Success], N'Lưu biên nhận cọc thành công' AS [Message], @DocumentID AS [DocumentID], @Makh AS [Makh];
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT 0 AS [Success], ERROR_MESSAGE() AS [Message], NULL AS [DocumentID], NULL AS [Makh];
    END CATCH
END
GO

-- =====================================================================
-- 5. CẤU HÌNH GIAO DIỆN FORM ĐỘNG (SY_FormatFields)
-- =====================================================================
PRINT N'Đang cấu hình các trường Form và Grid trong SY_FormatFields...';
GO
-- Đổi tên trường trong database nếu đang cấu hình tên cũ Loaihinhtiecid
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaihinhtiecid')
BEGIN
    UPDATE SY_FormatFields SET FieldName = 'Loaitiecid' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaihinhtiecid';
END

DELETE FROM SY_FormatFields 
WHERE FormName = 'frmBiennhancoccho' 
  AND FieldName IN ('TaiKhoanNo', 'TaiKhoanCo', 'Kemtheo', 'Lydo', 'HinhThuc');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, DataSource, ShowInAdd, ShowInEdit)
VALUES 
-- Cặp Tài khoản Nợ - Có (Hiện cả trên lưới Grid và có trong Form)
('frmBiennhancoccho', 'TaiKhoanNo', N'Tài khoản Nợ', 't', 'grid', 0, 15, NULL, 1, 1),
('frmBiennhancoccho', 'TaiKhoanCo', N'Tài khoản Có', 't', 'grid', 0, 16, NULL, 1, 1),

-- Hình thức (Chọn 1 trong 2 hoặc hỗn hợp, hiện cả trên lưới Grid và Form)
('frmBiennhancoccho', 'HinhThuc', N'Hình thức', 'sr', 'grid', 0, 17, N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản', 1, 1),

-- Kèm theo (Chỉ hiện trong Form nhập liệu)
('frmBiennhancoccho', 'Kemtheo', N'Kèm theo chứng từ', 't', '6', 0, 33, NULL, 1, 1),

-- Lý do nộp tiền (Chiếm trọn 1 dòng rộng)
('frmBiennhancoccho', 'Lydo', N'Lý do nộp tiền', 't', 'form', 0, 34, NULL, 1, 1);
GO

-- =====================================================================
-- 6. CẬP NHẬT ÁNH XẠ THAM SỐ API TRONG CỔNG WA_API
-- =====================================================================
PRINT N'Đang cấu hình định tuyến tham số API trong WA_API...';
GO
DELETE FROM WA_API WHERE List = 'frmBiennhancoccho' AND Func IN ('View', 'Save', 'Delete');
GO
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES
(
    'frmBiennhancoccho', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@Keyword=N''{Keyword}'', @TuNgay=N''{TuNgay}'', @DenNgay=N''{DenNgay}'''
),
(
    'frmBiennhancoccho', 
    'Save', 
    'API_LuuPhieuCoc', 
    '@DocumentID=N''{DocumentID}'', @Makh=N''{Makh}'', @MaChungTu=N''{MaChungTu}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{NgayToChuc}'', @Nhamngay=N''{Nhamngay}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @GoiThucDonID=N''{GoiThucDonID}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{DaCocVND}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @TaiKhoanNo=N''{TaiKhoanNo}'', @TaiKhoanCo=N''{TaiKhoanCo}'', @Kemtheo=N''{Kemtheo}'', @Lydo=N''{Lydo}'', @HinhThuc=N''{HinhThuc}'''
),
(
    'frmBiennhancoccho', 
    'Delete', 
    'API_XoaPhieuCoc', 
    '@DocumentIDs=N''{DocumentIDs}'', @UserName=N''{User}'''
);
GO

-- Đăng ký API_DanhSachPhieuCoc dùng riêng cho in Word (View)
DELETE FROM WA_API WHERE List = 'API_DanhSachPhieuCoc' AND Func = 'View';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'API_DanhSachPhieuCoc',
    'View',
    'API_DanhSachPhieuCoc',
    '@MaChungTu=N''{MaChungTu}'', @DocumentID=N''{DocumentID}'', @SoPhieu=N''{SoPhieu}'''
);
GO

-- Đăng ký định tuyến các API danh sách cho dropdown (Ca tiệc, Sảnh, Loại hình tiệc, Tìm người giao dịch)
DELETE FROM WA_API WHERE List IN ('API_DanhSachCaLam', 'API_DanhSachSanh', 'API_DanhSachLoaiHinhTiec', 'API_TimNguoiGiaoDich');
GO
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('API_DanhSachCaLam', 'View', 'API_DanhSachCaLam', NULL),
('API_DanhSachSanh', 'View', 'API_DanhSachSanh', '@Keyword=N''{Keyword}'''),
('API_DanhSachGoiThucDon', 'View', 'API_DanhSachGoiThucDon', '@Keyword=N''{Keyword}'''),
('API_DanhSachLoaiHinhTiec', 'View', 'API_DanhSachLoaiHinhTiec', NULL),
('API_TimNguoiGiaoDich', 'View', 'API_TimNguoiGiaoDich', '@Keyword=N''{Keyword}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}''');
GO

-- Đảm bảo cấu hình Form Đặt cọc trỏ vào đúng View và có Khóa chính là DocumentID
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachPhieuCoc', PrimaryKey = 'DocumentID' 
WHERE FormID = 'frmBiennhancoccho';
GO

EXEC API_DongBoTruongGiaoDien @FormName = 'frmBiennhancoccho', @ObjectName = 'v_DanhSachPhieuCoc';
GO

-- Đảm bảo đổi tên _Ngaytochuc hoặc Ngaytochuc thành NgayToChuc
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc')
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc')
    BEGIN
        DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';
    END
    UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc';
END
GO
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc')
BEGIN
    UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc';
END
GO

-- Đảm bảo trường Nhằm ngày âm lịch (Nhamngay) có FormatID = 't' (text) và đặt Read-Only
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay')
BEGIN
    UPDATE SY_FormatFields SET FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';
END
GO

-- Ẩn/Hiện và khóa (Read-Only) các trường mã tự sinh bởi database
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SoPhieu';

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName IN ('DocumentID', 'MaChungTu', 'Makh');

-- Dọn dẹp trường Sotiencoccho dư thừa khỏi cấu hình Đặt cọc và thêm định nghĩa Tenkh để dịch tiêu đề Tiếng Việt
DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Sotiencoccho';
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tenkh')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, ShowInFilter, OrderNo, FormPosition)
    VALUES ('frmBiennhancoccho', 'Tenkh', N'Người giao dịch', 0, 0, 0, 99, '6');
END
GO

-- Ẩn các trường tính toán hoặc không cần nhập trên Form nhập liệu (Chỉ hiện ở Grid)
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName IN ('TenKhachHang', 'DienThoai', 'SoBan', 'SanhDat');

-- Cập nhật vị trí hiển thị (FormPosition: 12/6/4/3) và thứ tự sắp xếp (OrderNo)
-- Nhóm 1: Thông tin liên hệ
UPDATE SY_FormatFields SET CaptionVN = N'Người giao dịch', FormPosition = '6', OrderNo = 1, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_TimNguoiGiaoDich&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nguoigd';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT đại diện', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, validateRule = 'trigger:/api/API_Gateway_Router?List=API_TimNguoiGiaoDich&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DienThoaiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT chú rể', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTchure';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT cô dâu', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTcodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ', FormPosition = '6', OrderNo = 7, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Email', FormPosition = '6', OrderNo = 8, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Mail';

-- Nhóm 2: Thông tin tiệc và sảnh
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức', FormPosition = '6', OrderNo = 9, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'dt', validateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Nhằm ngày (Âm lịch)', FormPosition = '6', OrderNo = 10, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET CaptionVN = N'Ca tiệc', FormPosition = '6', OrderNo = 11, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Loại tiệc', FormPosition = '6', OrderNo = 12, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaitiecid';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'GoiThucDonID')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, OrderNo, ShowInAdd, ShowInEdit, DataSource)
    VALUES ('frmBiennhancoccho', 'GoiThucDonID', N'Gói tiệc', 'sr', '6', 13, 1, 1, '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View');
END
ELSE
BEGIN
    UPDATE SY_FormatFields SET CaptionVN = N'Gói tiệc', FormPosition = '6', OrderNo = 13, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'GoiThucDonID';
END

UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt', FormPosition = '6', OrderNo = 14, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'ml', DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'JsonSanhTiec';

-- Đảm bảo trường DaCocVND (Số tiền cọc) được hiển thị và cho phép nhập dạng số
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DaCocVND')
BEGIN
    UPDATE SY_FormatFields 
    SET CaptionVN = N'Số tiền cọc',
        FormatID = 'mn',
        ShowInAdd = 1,
        ShowInEdit = 1,
        IsReadOnlyAdd = 0,
        IsReadOnlyEdit = 0,
        FormPosition = '6',
        OrderNo = 14
    WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DaCocVND';
END
ELSE
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmBiennhancoccho', 'DaCocVND', N'Số tiền cọc', 'mn', '6', 1, 15, 1, 1, 0, 0);
END

-- Nhóm 3: Số bàn (mỗi ô chiếm 1/4 dòng = df-col-3 để nằm gọn trên 1 hàng ngang)
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn mặn chính', FormPosition = '3', OrderNo = 15, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng', FormPosition = '3', OrderNo = 16, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chay chính', FormPosition = '3', OrderNo = 17, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng', FormPosition = '3', OrderNo = 18, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChayduphong';

-- Nhóm 4: Hạch toán và thanh toán (Mỗi ô chiếm 1/3 dòng = df-col-4 nằm gọn trên 1 hàng ngang)
UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thanh toán', FormPosition = '4', OrderNo = 19, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'HinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Tài khoản Nợ', FormPosition = '4', OrderNo = 20, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TaiKhoanNo';
UPDATE SY_FormatFields SET CaptionVN = N'Tài khoản Có', FormPosition = '4', OrderNo = 21, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TaiKhoanCo';

-- Nhóm 5: Ghi chú, lý do và hồ sơ kèm theo
UPDATE SY_FormatFields SET CaptionVN = N'Lý do nộp tiền', FormPosition = '6', OrderNo = 22, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Lydo';
UPDATE SY_FormatFields SET CaptionVN = N'Kèm theo chứng từ', FormPosition = '6', OrderNo = 23, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Kemtheo';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú', FormPosition = '12', OrderNo = 24, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ghichu';

-- Cập nhật lần cọc thành dạng dropdown cho phép chọn (hiển thị ở cả Thêm mới và Sửa)
UPDATE SY_FormatFields SET CaptionVN = N'Lần cọc', FormPosition = '6', OrderNo = 25, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = N'STATIC:1|Cọc lần 1,2|Cọc lần 2' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Solan';

-- Cấu hình hiển thị động (VisibleRule) cho các trường Chú rể / Cô dâu
-- Chỉ hiển thị khi chọn loại tiệc là Tiệc cưới (blt000001 hoặc t01)
UPDATE SY_FormatFields
SET VisibleRule = 'Loaitiecid=blt000001|t01'
WHERE FormName = 'frmBiennhancoccho' 
  AND FieldName IN ('Tenchure', 'Tencodau', 'DTchure', 'DTcodau');
GO

-- Đồng bộ hóa lại các trường giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmBiennhancoccho', @ObjectName = 'v_DanhSachPhieuCoc';
GO

-- Ẩn trường Makh khỏi Form nhập liệu nhưng giữ làm input ẩn
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Makh';
GO


-- Ẩn các trường chỉ dùng để IN ẤN hoặc tính toán khỏi giao diện Grid/Form
UPDATE SY_FormatFields
SET ShowInEdit = 0, ShowInAdd = 0, ShowInFilter = 0, FormPosition = 'hidden'
WHERE FormName = 'frmBiennhancoccho'
  AND FieldName IN (
    'DocumentID', 'MaChungTu', 'Sohopdong', 'Makh', 'TemplateFile', 
    'TenKhachHang', 'BenBTenDaiDien', 'BenBDiaChi', 'BenBDienThoai', 'BenBEmail', 
    'DienThoai', 'SoBan', 
    'NgayLapHD', 'ThangLapHD', 'NamLapHD', 
    'HDTenCty', 'HDDiaChi', 'HDMaSoThue', 'HDEmail', 'TrangThai', 'Tenkh', 'GoiTiec'
  );
GO

-- Đảm bảo trường GoiThucDonID hiển thị đúng định dạng Dropdown sau khi đồng bộ
UPDATE SY_FormatFields 
SET CaptionVN = N'Gói tiệc', FormPosition = '6', OrderNo = 13, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_DanhSachGoiThucDon&Func=View' 
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'GoiThucDonID';
GO

PRINT N'Cập nhật toàn bộ phân hệ Đặt cọc thành công!';
GO

-- Tự động gán file mẫu mặc định (phieu_thu.docx) cho tất cả loại tiệc nếu chưa được cấu hình
INSERT INTO tbmk_LoaitiecAddfile (Loaitiecid, FormName, TemplateFile)
SELECT Loaitiecid, 'frmBiennhancoccho', 'phieu_thu.docx'
FROM dmLoaihinhtiec
WHERE Loaitiecid NOT IN (
    SELECT Loaitiecid FROM tbmk_LoaitiecAddfile WHERE FormName = 'frmBiennhancoccho'
);
GO

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SanhDat')
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, OrderNo, ShowInAdd, ShowInEdit)
    VALUES ('frmBiennhancoccho', 'SanhDat', N'Sảnh đãi tiệc', 't', 'hidden', 15, 0, 0);
END
ELSE
BEGIN
    UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đãi tiệc', ShowInAdd = 0, ShowInEdit = 0, FormPosition = 'hidden' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SanhDat';
END
