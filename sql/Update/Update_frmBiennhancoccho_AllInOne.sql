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
CREATE OR ALTER VIEW [dbo].[v_DanhSachPhieuCoc] AS
SELECT 
    b.DocumentID,
    b.DocumentID AS MaChungTu,
    b.SoBN AS SoPhieu,
    b.Thoigianid,
    b.Loaitiecid AS Loaihinhtiecid,
    b.SobanManchinhthuc,
    b.SobanChaychinhthuc,
    b.SobanManduphong,
    b.SobanChayduphong,
    b.Ghichu,
    b.Ngaytochuc AS [_Ngaytochuc],
    
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
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS DienThoai,
    
    CONVERT(VARCHAR(10), b.Ngaytochuc, 103) AS [Ngaytochuc],
    ISNULL(b.Tongsoban, 0) AS SoBan,
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Biennhancocchosanhtiec bs 
        INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
        WHERE bs.DocumentID = b.DocumentID
    ) AS SanhDat,
    ISNULL(b.Tongtien, 0) AS DaCocVND,
    
    b.Solan AS [Solan],
    b.TaiKhoanNo,
    b.TaiKhoanCo,
    b.Kemtheo,
    b.Lydo,
    b.HinhThuc,
    
    (
        SELECT TOP 1 Sanhtiecid 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        ORDER BY IsSanhchinh DESC
    ) AS JsonSanhTiec,
    
    (
        SELECT Sanhtiecid, IsSanhchinh 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        FOR JSON PATH
    ) AS [_JsonSanhTiec],
    
    CASE
        WHEN b.IsHuy = 1 THEN N'Đã Hủy'
        WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
        WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
        ELSE N'Đã cọc lần 1'
    END AS TrangThai

FROM tbmk_Biennhancoccho b
LEFT JOIN dmkhachhang k ON b.Makh = k.Makh;
GO

-- =====================================================================
-- 3. CẬP NHẬT STORED PROCEDURE API_DANHSACHPHIEUCOC
-- =====================================================================
PRINT N'Đang cập nhật Stored Procedure API_DanhSachPhieuCoc...';
GO
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachPhieuCoc]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
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
        b.Loaitiecid AS [Loaihinhtiecid],
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
        FORMAT(ISNULL(b.Tongtien, 0), 'N0', 'vi-VN') AS [Tongtien],
        ISNULL(b.Tongtien, 0) AS [TongtienRaw],
        [dbo].[fn_DocTienBangChu](ISNULL(b.Tongtien, 0)) AS [SoTienBangChu],
        ISNULL(b.TaiKhoanNo, '') AS [TaiKhoanNo],
        ISNULL(b.TaiKhoanCo, '') AS [TaiKhoanCo],
        ISNULL(b.Kemtheo, '') AS [Kemtheo],
        ISNULL(NULLIF(b.HinhThuc, ''), N'Tiền mặt / Chuyển khoản') AS [HinhThuc],
        
        c.FullName AS [TenKhachHang],
        ISNULL(NULLIF(k.Nguoigd, ''), c.FullName) AS [Nguoinop],
        
        ISNULL(NULLIF(k.Dienthoai, ''), ISNULL(NULLIF(k.DTchure, ''), ISNULL(NULLIF(k.DTcodau, ''), k.DienThoaiDaiDien))) AS [DienThoai],
        
        b.Ngaytochuc AS [_Ngaytochuc],
        b.Solan AS [Solan],
        
        CONVERT(VARCHAR(10), b.Ngaytochuc, 103) AS [Ngaytochuc],
        ISNULL(b.Tongsoban, 0) AS [SoBan],
        
        STUFF((
            SELECT ', ' + s.Tensanhtiec + CASE WHEN bs.IsSanhchinh = 1 THEN N' (Chính)' ELSE N' (Phụ)' END
            FROM tbmk_Biennhancocchosanhtiec bs 
            INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
            WHERE bs.DocumentID = b.DocumentID
            ORDER BY bs.IsSanhchinh DESC, s.Tensanhtiec ASC
            FOR XML PATH('')
        ), 1, 2, '') AS [SanhDat],
        
        ISNULL(b.Tongtien, 0) AS [DaCocVND],
        
        (
            SELECT Sanhtiecid, IsSanhchinh 
            FROM tbmk_Biennhancocchosanhtiec 
            WHERE DocumentID = b.DocumentID 
            FOR JSON PATH
        ) AS [_JsonSanhTiec],
        (
            SELECT TOP 1 Sanhtiecid 
            FROM tbmk_Biennhancocchosanhtiec 
            WHERE DocumentID = b.DocumentID 
            ORDER BY IsSanhchinh DESC
        ) AS [JsonSanhTiec],
        
        CASE
            WHEN b.IsHuy = 1 THEN N'Đã Hủy'
            WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
            WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
            ELSE N'Đã cọc lần 1'
        END AS [TrangThai]
        
    FROM 
        tbmk_Biennhancoccho b
    LEFT JOIN 
        dmkhachhang k ON b.Makh = k.Makh
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
        
    ORDER BY 
        b.Ngaytochuc DESC, b.DocumentDate DESC;
END
GO

-- =====================================================================
-- 4. CẬP NHẬT STORED PROCEDURE API_LUUPHIEUCOC
-- =====================================================================
PRINT N'Đang cập nhật Stored Procedure API_LuuPhieuCoc...';
GO
CREATE OR ALTER PROCEDURE [dbo].[API_LuuPhieuCoc]
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
    @Ngaytochuc DATETIME = NULL,
    @Nhamngay NVARCHAR(100) = NULL,
    @Loaitiecid VARCHAR(50) = NULL,
    @Thoigianid VARCHAR(50) = NULL,
    @SobanManchinhthuc INT = 0,
    @SobanManduphong INT = 0,
    @SobanChaychinhthuc INT = 0,
    @SobanChayduphong INT = 0,
    @Tongtien DECIMAL(18,2) = 0,
    @Solan TINYINT = 1,
    @Ghichu NVARCHAR(500) = NULL,
    @Manv VARCHAR(50) = NULL,
    @UserCreate VARCHAR(50) = 'System',
    
    @JsonSanhTiec NVARCHAR(MAX) = NULL,
    
    @MaChungTu VARCHAR(50) = NULL,
    @_Ngaytochuc DATETIME = NULL,
    @TongtienRaw DECIMAL(18,2) = NULL,
    @Loaihinhtiecid VARCHAR(50) = NULL,
    
    @TaiKhoanNo VARCHAR(50) = NULL,
    @TaiKhoanCo VARCHAR(50) = NULL,
    @Kemtheo NVARCHAR(255) = NULL,
    @Lydo NVARCHAR(255) = NULL,
    @HinhThuc NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @MaChungTu IS NOT NULL AND (@DocumentID IS NULL OR @DocumentID = '')
            SET @DocumentID = @MaChungTu;
        IF @_Ngaytochuc IS NOT NULL
            SET @Ngaytochuc = @_Ngaytochuc;
        IF @TongtienRaw IS NOT NULL
            SET @Tongtien = @TongtienRaw;
        IF @Loaihinhtiecid IS NOT NULL
            SET @Loaitiecid = @Loaihinhtiecid;

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
                @Ngaytochuc, @Nhamngay, @Tongtien, @Tongsoban, @SobanManchinhthuc, @SobanManduphong, @SobanChaychinhthuc, @SobanChayduphong,
                @Thoigianid, @Ghichu, 0, 0, '', @Now, @UserCreate,
                @TaiKhoanNo, @TaiKhoanCo, @Kemtheo, @Lydo, @HinhThuc
            );
        END
        ELSE
        BEGIN
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

        IF (@JsonSanhTiec IS NOT NULL AND @JsonSanhTiec != '[]' AND @JsonSanhTiec != '')
        BEGIN
            IF (LEFT(LTRIM(@JsonSanhTiec), 1) != '[')
            BEGIN
                SET @JsonSanhTiec = '[{"Sanhtiecid":"' + @JsonSanhTiec + '", "IsSanhchinh":1}]';
            END

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
DELETE FROM SY_FormatFields 
WHERE FormName = 'frmBiennhancoccho' 
  AND FieldName IN ('TaiKhoanNo', 'TaiKhoanCo', 'Kemtheo', 'Lydo', 'HinhThuc');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, DataSource, ShowInAdd, ShowInEdit)
VALUES 
-- Cặp Tài khoản Nợ - Có (Hiện cả trên lưới Grid và có trong Form)
('frmBiennhancoccho', 'TaiKhoanNo', N'Tài khoản Nợ', 't', 'grid', 0, 15, NULL, 1, 1),
('frmBiennhancoccho', 'TaiKhoanCo', N'Tài khoản Có', 't', 'grid', 0, 16, NULL, 1, 1),

-- Hình thức (Chọn 1 trong 2 hoặc hỗn hợp, hiện cả trên lưới Grid và Form)
('frmBiennhancoccho', 'HinhThuc', N'Hình thức', 'sl', 'grid', 0, 17, N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản', 1, 1),

-- Kèm theo (Chỉ hiện trong Form nhập liệu)
('frmBiennhancoccho', 'Kemtheo', N'Kèm theo chứng từ', 't', '6', 0, 33, NULL, 1, 1),

-- Lý do nộp tiền (Chiếm trọn 1 dòng rộng)
('frmBiennhancoccho', 'Lydo', N'Lý do nộp tiền', 't', 'form', 0, 34, NULL, 1, 1);
GO

-- =====================================================================
-- 6. CẬP NHẬT ÁNH XẠ THAM SỐ API SAVE TRONG CỔNG WA_API
-- =====================================================================
PRINT N'Đang cấu hình định tuyến tham số API Save trong WA_API...';
GO
UPDATE WA_API
SET Para = '@DocumentID=N''{DocumentID}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{_Ngaytochuc}'', @Loaitiecid=N''{Loaihinhtiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{TongtienRaw}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @TaiKhoanNo=N''{TaiKhoanNo}'', @TaiKhoanCo=N''{TaiKhoanCo}'', @Kemtheo=N''{Kemtheo}'', @Lydo=N''{Lydo}'', @HinhThuc=N''{HinhThuc}'''
WHERE List = 'frmBiennhancoccho' AND Func = 'Save';
GO

PRINT N'Cập nhật toàn bộ phân hệ Đặt cọc thành công!';
GO
