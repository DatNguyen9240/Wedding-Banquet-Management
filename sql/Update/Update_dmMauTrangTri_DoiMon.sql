USE [QLTiec]
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

-- =========================================================================
-- 1. BẢNG DANH MỤC MẪU TRANG TRÍ (dmMauTrangTri - REQ-07)
-- =========================================================================
IF OBJECT_ID('dbo.dmMauTrangTri', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.dmMauTrangTri (
        MauTrangTriID VARCHAR(50) NOT NULL PRIMARY KEY,
        TenMau NVARCHAR(255) NOT NULL,
        HinhAnhUrl NVARCHAR(500) NULL,
        DonGia DECIMAL(18,2) DEFAULT 0,
        MoTa NVARCHAR(MAX) NULL,
        OrderNo INT NULL,
        IsDeleted BIT DEFAULT 0
    );
END
GO

-- Seed dữ liệu mẫu trang trí
MERGE INTO dbo.dmMauTrangTri AS target
USING (VALUES
    ('MTT01', N'Mẫu Tiêu Chuẩn (Standard)', N'/assets/images/decor/decor_standard.jpg', 0, N'Gói trang trí bàn tiệc và lối đi tiêu chuẩn của sảnh', 1),
    ('MTT02', N'Mẫu Rustic Garden (Hoa tươi mộc)', N'/assets/images/decor/decor_rustic.jpg', 5000000, N'Phong cách vintage mộc mạc với hoa tươi và nến thơm', 2),
    ('MTT03', N'Mẫu Royal Elegance (Hoàng gia sang trọng)', N'/assets/images/decor/decor_royal.jpg', 10000000, N'Tông vàng gold kết hợp hoa lụa cao cấp và backdrop pha lê', 3),
    ('MTT04', N'Mẫu Luxury Crystal (Pha lê ánh sao)', N'/assets/images/decor/decor_crystal.jpg', 15000000, N'Trần sao ánh sáng lung linh và tháp ly pha lê đặc biệt', 4)
) AS source (MauTrangTriID, TenMau, HinhAnhUrl, DonGia, MoTa, OrderNo)
ON target.MauTrangTriID = source.MauTrangTriID
WHEN MATCHED THEN
    UPDATE SET target.TenMau = source.TenMau,
               target.HinhAnhUrl = source.HinhAnhUrl,
               target.DonGia = source.DonGia,
               target.MoTa = source.MoTa,
               target.OrderNo = source.OrderNo
WHEN NOT MATCHED THEN
    INSERT (MauTrangTriID, TenMau, HinhAnhUrl, DonGia, MoTa, OrderNo, IsDeleted)
    VALUES (source.MauTrangTriID, source.TenMau, source.HinhAnhUrl, source.DonGia, source.MoTa, source.OrderNo, 0);
GO

-- Thêm cột MauTrangTriID và các trường sự kiện triển lãm vào tbmk_Hopdong nếu chưa có
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdong') AND name = 'MauTrangTriID')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdong ADD MauTrangTriID VARCHAR(50) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tbmk_Hopdong') AND name = 'SoKhachThamQuanDuKien')
BEGIN
    ALTER TABLE dbo.tbmk_Hopdong ADD SoKhachThamQuanDuKien INT NULL;
    ALTER TABLE dbo.tbmk_Hopdong ADD GioBatDauTrienLam NVARCHAR(50) NULL;
    ALTER TABLE dbo.tbmk_Hopdong ADD GioKetThucTrienLam NVARCHAR(50) NULL;
END
GO

-- Procedure API_DanhSachMauTrangTri
IF OBJECT_ID('dbo.API_DanhSachMauTrangTri', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachMauTrangTri;
GO

CREATE PROCEDURE dbo.API_DanhSachMauTrangTri
    @Keyword NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        MauTrangTriID,
        TenMau,
        HinhAnhUrl,
        DonGia,
        MoTa
    FROM dbo.dmMauTrangTri
    WHERE ISNULL(IsDeleted, 0) = 0
      AND (@Keyword IS NULL OR @Keyword = '' OR TenMau LIKE N'%' + @Keyword + '%' OR MauTrangTriID LIKE '%' + @Keyword + '%')
    ORDER BY OrderNo, TenMau;
END
GO

-- Đăng ký WA_API cho dmMauTrangTri
DELETE FROM dbo.WA_API WHERE List = 'API_DanhSachMauTrangTri' AND Func = 'View';
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachMauTrangTri', 'View', 'API_DanhSachMauTrangTri', N'@Keyword=N''{Keyword}''');

DELETE FROM dbo.WA_API WHERE List = 'dmMauTrangTri' AND Func IN ('Save', 'View', 'Delete');
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES 
('dmMauTrangTri', 'Save', 'API_LuuDong', '@List=N''dmMauTrangTri'', @Data=N''{JsonData}'''),
('dmMauTrangTri', 'View', 'API_TruyVanDong', '@List=N''dmMauTrangTri'', @Keyword=N''{Keyword}'''),
('dmMauTrangTri', 'Delete', 'API_XoaDong', '@List=N''dmMauTrangTri'', @Ids=N''{MauTrangTriID}'', @UserName=N''{User}''');
GO

-- =========================================================================
-- 2. BẢNG CHI TIẾT ĐỔI MÓN VÀ BÙ GIÁ (tbmk_HopdongDoiMon - REQ-03, 04)
-- =========================================================================
IF OBJECT_ID('dbo.tbmk_HopdongDoiMon', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbmk_HopdongDoiMon (
        AutoID INT IDENTITY(1,1) PRIMARY KEY,
        Sohopdong VARCHAR(20) NOT NULL,
        MonGocID VARCHAR(50) NULL,
        TenMonGoc NVARCHAR(255) NULL,
        MonMoiID VARCHAR(50) NULL,
        TenMonMoi NVARCHAR(255) NULL,
        DonGiaGoc DECIMAL(18,2) DEFAULT 0,
        DonGiaMoi DECIMAL(18,2) DEFAULT 0,
        ChenhLech DECIMAL(18,2) DEFAULT 0,
        Soluong DECIMAL(18,2) DEFAULT 1,
        ThanhTienChenhLech DECIMAL(18,2) DEFAULT 0,
        GhiChu NVARCHAR(255) NULL,
        DateCreate DATETIME DEFAULT GETDATE(),
        UserCreate VARCHAR(50) NULL
    );
END
GO

-- Procedure lưu đổi món nhanh
IF OBJECT_ID('dbo.API_LuuDoiMonNhanh', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_LuuDoiMonNhanh;
GO

CREATE PROCEDURE dbo.API_LuuDoiMonNhanh
    @Sohopdong VARCHAR(20),
    @JsonDoiMon NVARCHAR(MAX) = NULL,
    @UserCreate VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@Sohopdong IS NULL OR LTRIM(RTRIM(@Sohopdong)) = '')
        THROW 50001, N'Số hợp đồng không được để trống.', 1;

    IF (@JsonDoiMon IS NOT NULL
        AND LTRIM(RTRIM(@JsonDoiMon)) NOT IN ('', '[]')
        AND (ISJSON(@JsonDoiMon) = 0 OR LEFT(LTRIM(@JsonDoiMon), 1) <> '['))
        THROW 50002, N'Dữ liệu đổi món phải là một mảng JSON hợp lệ.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.tbmk_HopdongDoiMon WHERE Sohopdong = @Sohopdong;

        IF (@JsonDoiMon IS NOT NULL AND LTRIM(RTRIM(@JsonDoiMon)) NOT IN ('', '[]'))
        BEGIN
            INSERT INTO dbo.tbmk_HopdongDoiMon (
                Sohopdong, MonGocID, TenMonGoc, MonMoiID, TenMonMoi,
                DonGiaGoc, DonGiaMoi, ChenhLech, Soluong, ThanhTienChenhLech,
                GhiChu, DateCreate, UserCreate
            )
            SELECT
                @Sohopdong,
                JSON_VALUE(sourceRow.value, '$.MonGocID'),
                JSON_VALUE(sourceRow.value, '$.TenMonGoc'),
                JSON_VALUE(sourceRow.value, '$.MonMoiID'),
                JSON_VALUE(sourceRow.value, '$.TenMonMoi'),
                parsed.DonGiaGoc,
                parsed.DonGiaMoi,
                parsed.DonGiaMoi - parsed.DonGiaGoc,
                parsed.Soluong,
                (parsed.DonGiaMoi - parsed.DonGiaGoc) * parsed.Soluong,
                JSON_VALUE(sourceRow.value, '$.GhiChu'),
                GETDATE(),
                @UserCreate
            FROM OPENJSON(@JsonDoiMon) sourceRow
            CROSS APPLY (
                SELECT
                    ISNULL(TRY_CAST(JSON_VALUE(sourceRow.value, '$.DonGiaGoc') AS DECIMAL(18,2)), 0) AS DonGiaGoc,
                    ISNULL(TRY_CAST(JSON_VALUE(sourceRow.value, '$.DonGiaMoi') AS DECIMAL(18,2)), 0) AS DonGiaMoi,
                    ISNULL(TRY_CAST(JSON_VALUE(sourceRow.value, '$.Soluong') AS DECIMAL(18,2)), 1) AS Soluong
            ) parsed;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Đăng ký WA_API cho Đổi món
DELETE FROM dbo.WA_API WHERE List = 'frmHopDong' AND Func = 'SaveDoiMon';
INSERT INTO dbo.WA_API (List, Func, [SQL], Para)
VALUES ('frmHopDong', 'SaveDoiMon', 'API_LuuDoiMonNhanh', N'@Sohopdong=N''{Sohopdong}'', @JsonDoiMon=N''{JsonDoiMon}'', @UserCreate=N''{User}''');
GO
