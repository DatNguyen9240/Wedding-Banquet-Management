USE [QLTiec]
GO

-- Helper tạm thời phục vụ migration
IF OBJECT_ID('SY_FormatFields', 'U') IS NULL
BEGIN
    CREATE TABLE SY_FormatFields (
        AutoID int IDENTITY(1,1) PRIMARY KEY,
        FormatID varchar(50),
        FieldName varchar(50),
        FormName varchar(50),
        CaptionVN nvarchar(255),
        CaptionEN nvarchar(200),
        CaptionCH nvarchar(200),
        AlignX varchar(50),
        MinWidth int,
        MaxWidth int,
        ShowInAdd bit DEFAULT 1,
        ShowInEdit bit DEFAULT 1,
        FormPosition varchar(50),
        IsRequired bit DEFAULT 0,
        OrderNo int,
        DataSource nvarchar(500),
        ValidateRule nvarchar(500),
        DependsOn varchar(50),
        VisibleRule nvarchar(500),
        IsReadOnlyAdd bit DEFAULT 0,
        IsReadOnlyEdit bit DEFAULT 0,
        ShowInFilter bit DEFAULT 0,
        ShowInGrid bit DEFAULT 1
    );
END
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT CẤU TRÚC PHỤ LỤC HỢP ĐỒNG (ALL-IN-ONE) ===';
GO

-- =========================================================================
-- 1. BỔ SUNG CỘT SCHEMA CHO BẢNG tbmk_Thaydoi VÀ tbmk_Hopdong
-- =========================================================================
PRINT N'1. Đang kiểm tra và bổ sung cột cho bảng tbmk_Thaydoi...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'QuyMoBanTu')
    ALTER TABLE tbmk_Thaydoi ADD QuyMoBanTu INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'QuyMoBanTuTD')
    ALTER TABLE tbmk_Thaydoi ADD QuyMoBanTuTD INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'QuyMoBanDen')
    ALTER TABLE tbmk_Thaydoi ADD QuyMoBanDen INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'QuyMoBanDenTD')
    ALTER TABLE tbmk_Thaydoi ADD QuyMoBanDenTD INT NULL;



IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'ThanhToanDot2SoTien')
    ALTER TABLE tbmk_Thaydoi ADD ThanhToanDot2SoTien DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'ThanhToanDot2SoTienTD')
    ALTER TABLE tbmk_Thaydoi ADD ThanhToanDot2SoTienTD DECIMAL(18,2) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'HinhThucThanhToanDot2')
    ALTER TABLE tbmk_Thaydoi ADD HinhThucThanhToanDot2 NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'HinhThucThanhToanDot2TD')
    ALTER TABLE tbmk_Thaydoi ADD HinhThucThanhToanDot2TD NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'HanThanhToanDot2')
    ALTER TABLE tbmk_Thaydoi ADD HanThanhToanDot2 DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'HanThanhToanDot2TD')
    ALTER TABLE tbmk_Thaydoi ADD HanThanhToanDot2TD DATETIME NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DichVuTinhPhiPhuLuc')
    ALTER TABLE tbmk_Thaydoi ADD DichVuTinhPhiPhuLuc NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DichVuTinhPhiPhuLucTD')
    ALTER TABLE tbmk_Thaydoi ADD DichVuTinhPhiPhuLucTD NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'ThoaThuanPhuLucKhac')
    ALTER TABLE tbmk_Thaydoi ADD ThoaThuanPhuLucKhac NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'ThoaThuanPhuLucKhacTD')
    ALTER TABLE tbmk_Thaydoi ADD ThoaThuanPhuLucKhacTD NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DanhSachChiPhi')
    ALTER TABLE tbmk_Thaydoi ADD DanhSachChiPhi NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DanhSachChiPhiTD')
    ALTER TABLE tbmk_Thaydoi ADD DanhSachChiPhiTD NVARCHAR(MAX) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'BenAChucVuDaiDien')
    ALTER TABLE tbmk_Thaydoi ADD BenAChucVuDaiDien NVARCHAR(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'BenAChucVuDaiDienTD')
    ALTER TABLE tbmk_Thaydoi ADD BenAChucVuDaiDienTD NVARCHAR(200) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DonGiaBanTiec')
    ALTER TABLE tbmk_Thaydoi ADD DonGiaBanTiec DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DonGiaBanTiecTD')
    ALTER TABLE tbmk_Thaydoi ADD DonGiaBanTiecTD DECIMAL(18,2) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'SoKhachTrenBan')
    ALTER TABLE tbmk_Thaydoi ADD SoKhachTrenBan INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'SoKhachTrenBanTD')
    ALTER TABLE tbmk_Thaydoi ADD SoKhachTrenBanTD INT NULL;
GO

PRINT N'2. Đang kiểm tra và bổ sung cột cho bảng tbmk_Hopdong...';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'QuyMoBanTu')
    ALTER TABLE tbmk_Hopdong ADD QuyMoBanTu INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'QuyMoBanDen')
    ALTER TABLE tbmk_Hopdong ADD QuyMoBanDen INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'ThanhToanDot2SoTien')
    ALTER TABLE tbmk_Hopdong ADD ThanhToanDot2SoTien DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'HinhThucThanhToanDot2')
    ALTER TABLE tbmk_Hopdong ADD HinhThucThanhToanDot2 NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'HanThanhToanDot2')
    ALTER TABLE tbmk_Hopdong ADD HanThanhToanDot2 DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'DichVuTinhPhiPhuLuc')
    ALTER TABLE tbmk_Hopdong ADD DichVuTinhPhiPhuLuc NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'ThoaThuanPhuLucKhac')
    ALTER TABLE tbmk_Hopdong ADD ThoaThuanPhuLucKhac NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'DanhSachChiPhi')
    ALTER TABLE tbmk_Hopdong ADD DanhSachChiPhi NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'BenAChucVuDaiDien')
    ALTER TABLE tbmk_Hopdong ADD BenAChucVuDaiDien NVARCHAR(200) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'DonGiaBanTiec')
    ALTER TABLE tbmk_Hopdong ADD DonGiaBanTiec DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdong]') AND name = 'SoKhachTrenBan')
    ALTER TABLE tbmk_Hopdong ADD SoKhachTrenBan INT NULL;
GO


-- =========================================================================
-- 1.5. TẠO BẢNG CHI TIẾT THỰC ĐƠN CHO PHỤ LỤC & MIGRATE DỮ LIỆU CŨ
-- =========================================================================
PRINT N'2.5. Đang tạo các bảng chi tiết thực đơn cho Phụ lục và migrate dữ liệu cũ...';
GO

IF OBJECT_ID('[dbo].[tbmk_Thaydoithucdonman]', 'U') IS NULL
    CREATE TABLE [dbo].[tbmk_Thaydoithucdonman](
        [UserAutoid] [varchar](50) NOT NULL PRIMARY KEY,
        [Sothaydoi] [varchar](50) NULL,
        [STTmon] [int] NULL,
        [Mahang] [varchar](50) NULL,
        [Dongia] [decimal](18, 2) NULL,
        [Ghichuthucdonman] [nvarchar](250) NULL,
        [IsKhaividaugio] [bit] NULL,
        [UserCreate] [varchar](50) NULL,
        [DateCreate] [datetime] NULL
    );

IF OBJECT_ID('[dbo].[tbmk_Thaydoithucdonchay]', 'U') IS NULL
    CREATE TABLE [dbo].[tbmk_Thaydoithucdonchay](
        [UserAutoid] [varchar](50) NOT NULL PRIMARY KEY,
        [Sothaydoi] [varchar](50) NULL,
        [STTmon] [int] NULL,
        [Mahang] [varchar](50) NULL,
        [Dongia] [decimal](18, 2) NULL,
        [Ghichuthucdonchay] [nvarchar](250) NULL,
        [IsKhaividaugio] [bit] NULL,
        [UserCreate] [varchar](50) NULL,
        [DateCreate] [datetime] NULL
    );

IF OBJECT_ID('[dbo].[tbmk_Thaydoithucuong]', 'U') IS NULL
    CREATE TABLE [dbo].[tbmk_Thaydoithucuong](
        [UserAutoid] [varchar](50) NOT NULL PRIMARY KEY,
        [Sothaydoi] [varchar](50) NULL,
        [Mahang] [varchar](50) NULL,
        [Dvt] [nvarchar](50) NULL,
        [Soluong] [decimal](18, 2) NULL,
        [Dongia] [decimal](18, 2) NULL,
        [Sotien] [decimal](18, 2) NULL,
        [Giamgia] [decimal](18, 2) NULL,
        [Ghichuthucuong] [nvarchar](500) NULL,
        [IsKhuyenmai] [bit] NULL,
        [STT] [int] NULL,
        [UserCreate] [varchar](50) NULL,
        [DateCreate] [datetime] NULL
    );

IF COL_LENGTH('tbmk_Thaydoithucuong', 'Dvt') IS NULL
BEGIN
    ALTER TABLE tbmk_Thaydoithucuong ADD Dvt NVARCHAR(50) NULL;
END
GO

IF OBJECT_ID('[dbo].[tbmk_Thaydoidichvu]', 'U') IS NULL
    CREATE TABLE [dbo].[tbmk_Thaydoidichvu](
        [UserAutoid] [varchar](50) NOT NULL PRIMARY KEY,
        [Sothaydoi] [varchar](50) NULL,
        [Mahang] [varchar](50) NULL,
        [Soluong] [decimal](18, 2) NULL,
        [Dongia] [decimal](18, 2) NULL,
        [Sotien] [decimal](18, 2) NULL,
        [Ghichudichvu] [nvarchar](500) NULL,
        [IsKhuyenmai] [bit] NULL,
        [STT] [int] NULL,
        [UserCreate] [varchar](50) NULL,
        [DateCreate] [datetime] NULL
    );
GO

-- Migrate dữ liệu 1 lần: Copy từ cột JsonBanTiec cũ (nếu có) sang bảng con
IF COL_LENGTH('tbmk_Thaydoi', 'JsonBanTiec') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Thaydoithucdonman (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio)
    SELECT NEWID(), h.Sothaydoi, ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
    FROM tbmk_Thaydoi h
    CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
      AND COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 0
      AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman x WHERE x.Sothaydoi = h.Sothaydoi);

    INSERT INTO tbmk_Thaydoithucdonchay (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio)
    SELECT NEWID(), h.Sothaydoi, ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
    FROM tbmk_Thaydoi h
    CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
      AND COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 1
      AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay x WHERE x.Sothaydoi = h.Sothaydoi);
END

IF COL_LENGTH('tbmk_Thaydoi', 'JsonThucUong') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Thaydoithucuong (UserAutoid, Sothaydoi, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT)
    SELECT NEWID(), h.Sothaydoi, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
           ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), 'Migrate', GETDATE(),
           ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang)
    FROM tbmk_Thaydoi h
    CROSS APPLY OPENJSON(h.JsonThucUong) WITH (
        Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
        IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)
    ) j
    LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
    WHERE NULLIF(LTRIM(RTRIM(h.JsonThucUong)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonThucUong), 1) = '['
      AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucuong x WHERE x.Sothaydoi = h.Sothaydoi);
END

IF COL_LENGTH('tbmk_Thaydoi', 'JsonDichVu') IS NOT NULL
BEGIN
    INSERT INTO tbmk_Thaydoidichvu (UserAutoid, Sothaydoi, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichudichvu, UserCreate, DateCreate, STT)
    SELECT NEWID(), h.Sothaydoi, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
           ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, 'Migrate', GETDATE(),
           ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang)
    FROM tbmk_Thaydoi h
    CROSS APPLY OPENJSON(h.JsonDichVu) WITH (
        Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
        IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)
    ) j
    WHERE NULLIF(LTRIM(RTRIM(h.JsonDichVu)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonDichVu), 1) = '['
      AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoidichvu x WHERE x.Sothaydoi = h.Sothaydoi);
END
GO


-- =========================================================================
-- 2. TẠO VIEW DÂN SỰ/PHỤ LỤC v_DanhSachPhuLuc
-- =========================================================================
PRINT N'3. Đang tạo/cập nhật View v_DanhSachPhuLuc...';
GO

IF OBJECT_ID('[dbo].[v_DanhSachPhuLuc]', 'V') IS NOT NULL
    DROP VIEW [dbo].[v_DanhSachPhuLuc];
GO
CREATE VIEW [dbo].[v_DanhSachPhuLuc] AS
SELECT 
    td.Sothaydoi AS [Id], -- Dùng làm PrimaryKey cho Frontend
    td.Sothaydoi AS [Sothaydoi], 
    td.Sothaydoi AS [SoPhuLuc], -- Biến trong docx
    td.Ngaythaydoi AS [Ngaythaydoi],
    RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL],

    RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL],
    CAST(YEAR(td.Ngaythaydoi) AS VARCHAR) AS [NamLapPL],
    td.Sohopdong AS [Sohopdong],
    td.Sobiennhan AS [Sobiennhan],
    td.Makh AS [Makh],
    td.Manv AS [Manv],
    ISNULL(nv.Tennv, td.Manv) AS [NVLap],
    
    -- Thông tin khách hàng (Bên B)
    kh.Tenkh AS [TenKhachHang],
    kh.Tenchure AS [TenChuRe],
    kh.Tencodau AS [TenCoDau],
    kh.Dienthoai AS [DienThoai],
    kh.Diachi AS [DiaChi],
    kh.Mail AS [Mail],
    kh.CMNDDaiDien AS [BenBCCCD],
    
    -- Bên A (Thông tin nhà hàng)
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'BenASDT') AS [BenASDT],

    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'HNNguoiDaiDien') AS [BenANguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'HNNguoiDaiDien') AS [BenADaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WITH (NOLOCK) WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
    nv.Tennv AS [BenANhanVienPhuTrach],
    nv.Dienthoai AS [BenASDTNhanVien],

    -- Bên B (Thông tin khách hàng)
    kh.Tenkh AS [BenBTenDaiDien],
    kh.Tenkh AS [BenBDaiDien],
    ISNULL(kh.Tenchure, '') + ' & ' + ISNULL(kh.Tencodau, '') AS [BenBTenChuTiec],

    kh.Diachi AS [BenBDiaChi],
    kh.Dienthoai AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],


    -- Hợp đồng gốc ngày lập
    RIGHT('0' + CAST(DAY(hd.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
    RIGHT('0' + CAST(MONTH(hd.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(hd.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Loại hình sự kiện & Sảnh & Ca
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WITH (NOLOCK) WHERE lt.Loaitiecid = ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid)), N'') AS [LoaiHinhSuKien],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs WITH (NOLOCK) INNER JOIN dmSanhtiec s WITH (NOLOCK) ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = td.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [TenSanhTiec],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs WITH (NOLOCK) INNER JOIN dmSanhtiec s WITH (NOLOCK) ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = td.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [Sanh],
    FORMAT(ISNULL(td.NgayToChucTD, hd.Ngaytochuc), 'HH:mm') AS [TiecGioBatDau],
    
    -- Ngày tổ chức Dương lịch & Âm lịch
    CONVERT(VARCHAR(10), ISNULL(td.NgayToChucTD, hd.Ngaytochuc), 103) AS [NgayToChuc],

    RIGHT('0' + CAST(MONTH(ISNULL(td.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [ThangToChuc],
    CAST(YEAR(ISNULL(td.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR) AS [NamToChuc],
    
    -- Âm lịch (Tách thành Ngày, Tháng, Năm Âm Lịch)
    CASE 
        WHEN CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) > 0 
            THEN SUBSTRING(ISNULL(td.NhamNgayTD, hd.Nhamngay), 1, CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) - 1)
        ELSE ISNULL(td.NhamNgayTD, hd.Nhamngay)
    END AS [NgayToChucAmLich],
    CASE 
        WHEN CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) > 0 
            THEN CASE 
                WHEN CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1) > 0 
                    THEN SUBSTRING(ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1, CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1) - CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) - 1)
                ELSE SUBSTRING(ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1, LEN(ISNULL(td.NhamNgayTD, hd.Nhamngay)))
            END
        ELSE '...'
    END AS [ThangToChucAmLich],
    CASE 
        WHEN CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) > 0 AND CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1) > 0
            THEN SUBSTRING(ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(td.NhamNgayTD, hd.Nhamngay)) + 1) + 1, LEN(ISNULL(td.NhamNgayTD, hd.Nhamngay)))
        ELSE '...'
    END AS [NamToChucAmLich],
    ISNULL(td.NhamNgayTD, hd.Nhamngay) AS [Nhamngay],
    
    -- Loại tiệc & Ca
    ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid) AS [LoaiTiecID],
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WITH (NOLOCK) WHERE tm.FormName = 'frmPhuLucHopDong' AND tm.Loaitiecid = ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid)) AS [TemplateFile],
    ISNULL(td.ThoiGianIDTD, hd.Thoigianid) AS [ThoiGianID],
    
    -- Quy mô bàn & Đơn giá
    ISNULL(td.QuyMoBanTuTD, td.QuyMoBanTu) AS [QuyMoBanTu],
    ISNULL(td.QuyMoBanDenTD, td.QuyMoBanDen) AS [QuyMoBanDen],
    ISNULL(td.DonGiaBanTiecTD, td.DonGiaBanTiec) AS [DonGiaBanTiec],
    ISNULL(td.SoKhachTrenBanTD, td.SoKhachTrenBan) AS [SoKhachTrenBan],
    
    ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc) AS [SobanManchinhthuc],
    ISNULL(td.SobanManduphong, hd.SobanManduphong) AS [SobanManduphong],
    ISNULL(td.SobanChaychinhthuc, hd.SobanChaychinhthuc) AS [SobanChaychinhthuc],
    ISNULL(td.SobanChayduphong, hd.SobanChayduphong) AS [SobanChayduphong],
    ISNULL(ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc), 0) + ISNULL(ISNULL(td.SobanChaychinhthuc, hd.SobanChaychinhthuc), 0) AS [SoBanChinhThuc],
    ISNULL(ISNULL(td.SobanManduphong, hd.SobanManduphong), 0) + ISNULL(ISNULL(td.SobanChayduphong, hd.SobanChayduphong), 0) AS [SoBanDuPhong],
    ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [BanTang],
    ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [SoBanTang],
    ISNULL(ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc), 0) + ISNULL(ISNULL(td.SobanChaychinhthuc, hd.SobanChaychinhthuc), 0) + ISNULL(ISNULL(td.SobanManduphong, hd.SobanManduphong), 0) + ISNULL(ISNULL(td.SobanChayduphong, hd.SobanChayduphong), 0) + ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [TongSoBan],
    ISNULL((SELECT SUM(ps.Soluong) FROM tbmk_HopdongPhatSinh ps WITH (NOLOCK) WHERE ps.Sohopdong = td.Sohopdong AND (ps.Mahang LIKE '%BAN%' OR ps.GhiChuPhatSinh LIKE N'%bàn%')), 0) AS [SoBanPhatSinh],
    -- {#MenuTiec}: Lấy từ bảng con (Thaydoithucdonman & Thaydoithucdonchay)
    COALESCE(
        (
            SELECT 
                CASE 
                    WHEN t.Loai = 2 AND LOWER(ISNULL(hh.Tenhang, t.Mahang)) NOT LIKE '%chay%'
                    THEN ISNULL(hh.Tenhang, t.Mahang) + N' (Món chay)'
                    ELSE ISNULL(hh.Tenhang, t.Mahang)
                END AS [TenMonAn],
                FORMAT(ISNULL(t.Dongia, 0), 'N0', 'vi-VN') AS [DonGia]
            FROM (
                SELECT Mahang, Dongia, STTmon, 1 AS Loai FROM tbmk_Thaydoithucdonman WITH (NOLOCK) WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon, 2 AS Loai FROM tbmk_Thaydoithucdonchay WITH (NOLOCK) WHERE Sothaydoi = td.Sothaydoi
            ) t
            LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON t.Mahang = hh.Mahang
            ORDER BY t.Loai, t.STTmon, t.Mahang
            FOR JSON PATH
        ),
        (
            SELECT 
                JSON_VALUE(value, '$.TenHang') AS [TenMonAn],
                FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia]
            FROM OPENJSON(td.JsonBanTiec)
            WHERE td.JsonBanTiec IS NOT NULL AND td.JsonBanTiec <> '' AND td.JsonBanTiec <> '[]'
            FOR JSON PATH
        ),
        (
            SELECT 
                h.Tenhang AS [TenMonAn],
                N'0' AS [DonGia]
            FROM dmHangHoa h WITH (NOLOCK)
            WHERE h.GoiThucDonID = hd.GoiThucDonID AND ISNULL(h.IsNgungSuDung, 0) = 0
            FOR JSON PATH
        ),
        '[]'
    ) AS [MenuTiec],

    FORMAT(ISNULL((SELECT SUM(ISNULL(t.Dongia, 0)) FROM (SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonman
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi) UNION ALL SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonchay
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi)) t), 0), 'N0', 'vi-VN') + N' VNĐ' AS [MenuTongCong],
    -- Menu Man: use the appendix snapshot when either menu is present.
    (SELECT ROW_NUMBER() OVER (ORDER BY t.STTmon, t.Mahang) AS STT,
                ISNULL(hh.Tenhang, t.Mahang) AS TenMonAn,
                FORMAT(ISNULL(t.Dongia, 0), 'N0', 'vi-VN') AS DonGia
         FROM (SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonman
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi)) t
         LEFT JOIN dmHanghoa hh ON hh.Mahang = t.Mahang
         ORDER BY t.STTmon, t.Mahang FOR JSON PATH) AS [MenuMan],
    FORMAT(ISNULL((SELECT SUM(ISNULL(t.Dongia, 0)) FROM (SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonman
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi)) t), 0), 'N0', 'vi-VN') + N' VNĐ' AS [MenuTongCongMan],

    -- Menu Chay: use the appendix snapshot when either menu is present.
    (SELECT ROW_NUMBER() OVER (ORDER BY t.STTmon, t.Mahang) AS STT,
                ISNULL(hh.Tenhang, t.Mahang) AS TenMonAn,
                FORMAT(ISNULL(t.Dongia, 0), 'N0', 'vi-VN') AS DonGia
         FROM (SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonchay
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi)) t
         LEFT JOIN dmHanghoa hh ON hh.Mahang = t.Mahang
         ORDER BY t.STTmon, t.Mahang FOR JSON PATH) AS [MenuChay],
    FORMAT(ISNULL((SELECT SUM(ISNULL(t.Dongia, 0)) FROM (SELECT Mahang, Dongia, STTmon FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon FROM tbmk_Hopdongthucdonchay
                WHERE Sohopdong = hd.Sohopdong
                  AND NULLIF(LTRIM(RTRIM(td.JsonBanTiec)), '') IS NULL
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi)
                  AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi)) t), 0), 'N0', 'vi-VN') + N' VNĐ' AS [MenuTongCongChay],

    -- {#DanhSachChiPhi}{STT}{NoiDung}{DVT}{SoLuong}{DonGia}{ThanhTien}{/DanhSachChiPhi}
    -- Ưu tiên: cột DanhSachChiPhi có sẵn → fallback tổng hợp từ bảng con dịch vụ
    CASE
        WHEN ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) IS NOT NULL
             AND ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) <> ''
             AND ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) <> '[]'
            THEN ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi)
        WHEN EXISTS (SELECT 1 FROM tbmk_Thaydoidichvu WITH (NOLOCK) WHERE Sothaydoi = td.Sothaydoi) 
             OR EXISTS (SELECT 1 FROM tbmk_Thaydoithucuong WITH (NOLOCK) WHERE Sothaydoi = td.Sothaydoi)
            THEN ISNULL((
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY t.SortOrder, t.STT, t.Mahang) AS [STT],
                    t.[NoiDung], t.[DVT], t.[SoLuong], t.[DonGia], t.[ThanhTien]
                FROM (
                    SELECT 
                        1 AS SortOrder, tm.STT, tm.Mahang,
                        ISNULL(hh.Tenhang, tm.Mahang) AS [NoiDung],
                        ISNULL(hh.DVTID, N'Lần') AS [DVT],
                        ISNULL(TRY_CAST(tm.Soluong AS INT), 1) AS [SoLuong],
                        FORMAT(ISNULL(tm.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(tm.Dongia, 0) * ISNULL(tm.Soluong, 1), 'N0', 'vi-VN') AS [ThanhTien]
                    FROM tbmk_Thaydoidichvu tm WITH (NOLOCK)
                    LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON tm.Mahang = hh.Mahang
                    WHERE tm.Sothaydoi = td.Sothaydoi
                    UNION ALL
                    SELECT 
                        2 AS SortOrder, tu.STT, tu.Mahang,
                        ISNULL(hh.Tenhang, tu.Mahang) AS [NoiDung],
                        ISNULL(tu.Dvt, hh.DVTID) AS [DVT],
                        ISNULL(TRY_CAST(tu.Soluong AS INT), 0) AS [SoLuong],
                        FORMAT(ISNULL(tu.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(tu.Dongia, 0) * ISNULL(tu.Soluong, 0), 'N0', 'vi-VN') AS [ThanhTien]
                    FROM tbmk_Thaydoithucuong tu WITH (NOLOCK)
                    LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON tu.Mahang = hh.Mahang
                    WHERE tu.Sothaydoi = td.Sothaydoi
                ) t
                FOR JSON PATH
            ), '[]')
        ELSE
            COALESCE(
                (
                    SELECT 
                        ROW_NUMBER() OVER (ORDER BY items.SortOrder, items.NoiDung) AS [STT],
                        items.NoiDung, items.DVT, items.SoLuong, items.DonGia, items.ThanhTien
                    FROM (
                        -- Dịch vụ
                        SELECT 
                            JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                            ISNULL(JSON_VALUE(value, '$.DvtID'), N'Lần') AS [DVT],
                            ISNULL(TRY_CAST(JSON_VALUE(value, '$.Soluong') AS INT), 0) AS [SoLuong],
                            FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                            FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                            1 AS SortOrder
                        FROM OPENJSON(td.JsonDichVu)
                        WHERE td.JsonDichVu IS NOT NULL AND td.JsonDichVu <> '' AND td.JsonDichVu <> '[]'
                        UNION ALL
                        -- Thức uống
                        SELECT 
                            JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                            ISNULL(JSON_VALUE(value, '$.DvtID'), N'Két/Lon') AS [DVT],
                            ISNULL(TRY_CAST(JSON_VALUE(value, '$.Soluong') AS INT), 0) AS [SoLuong],
                            FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                            FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                            2 AS SortOrder
                        FROM OPENJSON(td.JsonThucUong)
                        WHERE td.JsonThucUong IS NOT NULL AND td.JsonThucUong <> '' AND td.JsonThucUong <> '[]'
                    ) items
                    FOR JSON PATH
                ),
                '[]'
            )
    END AS [DanhSachChiPhi],
    -- ===== KẾT THÚC CỘT DOCX =====
    
    -- Các đợt thanh toán
    ISNULL(td.ThanhToanDot2SoTienTD, td.ThanhToanDot2SoTien) AS [ThanhToanDot2SoTien],
    ISNULL(td.HinhThucThanhToanDot2TD, td.HinhThucThanhToanDot2) AS [HinhThucThanhToanDot2],
    FORMAT(ISNULL(td.HanThanhToanDot2TD, td.HanThanhToanDot2), 'dd/MM/yyyy') AS [HanThanhToanDot2],
    
    -- Dịch vụ & thỏa thuận
    ISNULL(td.DichVuTinhPhiPhuLucTD, td.DichVuTinhPhiPhuLuc) AS [DichVuTinhPhiPhuLuc],
    ISNULL(td.ThoaThuanPhuLucKhacTD, td.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
    
    -- Các trường tiền tệ


    -- Tổng giá trị tạm tính (format VNĐ) - {TongGiaTriTamTinh}
    FORMAT(ISNULL(td.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
    
    -- Trạng thái & metadata
    td.LanThayDoi AS [LanThayDoi],
    td.Ghichu AS [Ghichu],
    td.Ghichu AS [NoiDungPhuLuc],
    td.Status AS [Status],
    CASE 
        WHEN td.Status = 'DRAFT' THEN N'Nháp'
        WHEN td.Status = 'SIGNED' THEN N'Đã Ký'
        WHEN td.Status = 'APPROVED' THEN N'Đã Duyệt'
        WHEN td.Status = 'CANCELLED' THEN N'Đã Hủy'
        ELSE N'Nháp'
    END AS [TrangThai],
    
    td.IsKetthuc AS [IsKetthuc],
    COALESCE((
        SELECT items.Mahang, items.TenHang, items.DvtID, items.Soluong, items.Dongia,
               items.IsChay
        FROM (
            SELECT tm.Mahang, ISNULL(hh.Tenhang, tm.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                   CAST(1 AS DECIMAL(18,2)) AS Soluong, ISNULL(tm.Dongia, 0) AS Dongia,
                   CAST(0 AS BIT) AS IsChay, ISNULL(tm.STTmon, 0) AS SortOrder, 1 AS TableType
            FROM tbmk_Thaydoithucdonman tm WITH (NOLOCK)
            LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON tm.Mahang = hh.Mahang
            WHERE tm.Sothaydoi = td.Sothaydoi
            UNION ALL
            SELECT tc.Mahang, ISNULL(hh.Tenhang, tc.Mahang), ISNULL(hh.DVTID, N'Đĩa'),
                   CAST(1 AS DECIMAL(18,2)), ISNULL(tc.Dongia, 0),
                   CAST(1 AS BIT), ISNULL(tc.STTmon, 0), 2
            FROM tbmk_Thaydoithucdonchay tc WITH (NOLOCK)
            LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON tc.Mahang = hh.Mahang
            WHERE tc.Sothaydoi = td.Sothaydoi
        ) items
        ORDER BY items.TableType, items.SortOrder, items.Mahang
        FOR JSON PATH
    ), td.JsonBanTiec, '[]') AS [JsonBanTiec],

    COALESCE((
        SELECT tu.Mahang, ISNULL(hh.Tenhang, tu.Mahang) AS TenHang, ISNULL(tu.Dvt, hh.DVTID) AS DvtID,
               ISNULL(tu.IsKhuyenmai, 0) AS IsKhuyenmai, ISNULL(tu.Soluong, 0) AS Soluong,
               ISNULL(tu.Dongia, 0) AS Dongia, CAST(0 AS DECIMAL(18,2)) AS Soluongle,
               CAST(0 AS DECIMAL(18,2)) AS Dongiale, ISNULL(tu.Ghichuthucuong, N'') AS Ghichuthucuong
        FROM tbmk_Thaydoithucuong tu WITH (NOLOCK)
        LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON tu.Mahang = hh.Mahang
        WHERE tu.Sothaydoi = td.Sothaydoi
        ORDER BY tu.STT, tu.Mahang
        FOR JSON PATH
    ), td.JsonThucUong, '[]') AS [JsonThucUong],

    COALESCE((
        SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(dv.Soluong, 0) AS Soluong, ISNULL(dv.Dongia, 0) AS Dongia,
               ISNULL(dv.Ghichudichvu, N'') AS Ghichudichvu
        FROM tbmk_Thaydoidichvu dv WITH (NOLOCK)
        LEFT JOIN dmHanghoa hh WITH (NOLOCK) ON dv.Mahang = hh.Mahang
        WHERE dv.Sothaydoi = td.Sothaydoi
        ORDER BY dv.STT, dv.Mahang
        FOR JSON PATH
    ), td.JsonDichVu, '[]') AS [JsonDichVu],

    COALESCE(td.JsonPhatSinh, '[]') AS [JsonPhatSinh],
    td.BenAChucVuDaiDienTD AS [BenAChucVuDaiDien]
FROM tbmk_Thaydoi td WITH (NOLOCK)
INNER JOIN tbmk_Hopdong hd WITH (NOLOCK) ON td.Sohopdong = hd.Sohopdong
LEFT JOIN dmkhachhang kh WITH (NOLOCK) ON hd.Makh = kh.Makh
LEFT JOIN dmNhanvienView nv WITH (NOLOCK) ON nv.NHANVIENID = ISNULL(td.Manv, hd.Manv) OR nv.Manv = ISNULL(td.Manv, hd.Manv)
WHERE ISNULL(td.IsDeleted, 0) = 0;
GO



-- =========================================================================
-- 3. THỦ TỤC LƯU PHỤ LỤC THAY ĐỔI API_LuuThayDoi
-- =========================================================================
PRINT N'4. Đang tạo/cập nhật Procedure API_LuuThayDoi...';
GO

IF OBJECT_ID('[dbo].[API_LuuThayDoi]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[API_LuuThayDoi];
GO
CREATE PROCEDURE [dbo].[API_LuuThayDoi]
    @Sothaydoi VARCHAR(50) = NULL OUTPUT,
    @Sohopdong VARCHAR(50) = NULL,
    @Ngaythaydoi DATETIME = NULL,
    @Ghichu NVARCHAR(MAX) = NULL,
    @Status VARCHAR(20) = 'DRAFT',
    @UserName VARCHAR(50) = 'System',
    @JsonData NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Now DATETIME = GETDATE();
    
    DECLARE @HanThanhToanDot2Parsed DATETIME = NULL;
    DECLARE @HanThanhToanDot2TDParsed DATETIME = NULL;

    -- Giải nén các tham số từ JsonData nếu có
    IF (@JsonData IS NOT NULL AND @JsonData <> '' AND ISJSON(@JsonData) = 1)
    BEGIN
        SET @Sothaydoi = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Sothaydoi'), ''), NULLIF(JSON_VALUE(@JsonData, '$.SoPhuLuc'), ''), @Sothaydoi);
        SET @Sohopdong = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Sohopdong'), ''), @Sohopdong);
        
        DECLARE @NgaythaydoiStr NVARCHAR(100) = COALESCE(JSON_VALUE(@JsonData, '$.Ngaythaydoi'), JSON_VALUE(@JsonData, '$.NgayLap'));
        IF (@NgaythaydoiStr IS NOT NULL AND LTRIM(RTRIM(@NgaythaydoiStr)) <> '')
        BEGIN
            SET @Ngaythaydoi = COALESCE(
                TRY_CAST(@NgaythaydoiStr AS DATETIME),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 126),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 120),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 23),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 103),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 105),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 111),
                TRY_CONVERT(DATETIME, @NgaythaydoiStr, 101)
            );
        END

        SET @Ghichu = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Ghichu'), ''), NULLIF(JSON_VALUE(@JsonData, '$.LyDoDieuChinh'), ''), @Ghichu);
        SET @Status = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Status'), ''), NULLIF(JSON_VALUE(@JsonData, '$.TrangThai'), ''), @Status);

        DECLARE @HanThanhToanDot2Str NVARCHAR(100) = JSON_VALUE(@JsonData, '$.HanThanhToanDot2');
        IF (@HanThanhToanDot2Str IS NOT NULL AND LTRIM(RTRIM(@HanThanhToanDot2Str)) <> '')
            SET @HanThanhToanDot2Parsed = COALESCE(TRY_CAST(@HanThanhToanDot2Str AS DATETIME), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 126), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 120), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 23), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 103), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 105), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 111), TRY_CONVERT(DATETIME, @HanThanhToanDot2Str, 101));

        DECLARE @HanThanhToanDot2TDStr NVARCHAR(100) = JSON_VALUE(@JsonData, '$.HanThanhToanDot2TD');
        IF (@HanThanhToanDot2TDStr IS NOT NULL AND LTRIM(RTRIM(@HanThanhToanDot2TDStr)) <> '')
            SET @HanThanhToanDot2TDParsed = COALESCE(TRY_CAST(@HanThanhToanDot2TDStr AS DATETIME), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 126), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 120), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 23), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 103), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 105), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 111), TRY_CONVERT(DATETIME, @HanThanhToanDot2TDStr, 101));
    END

        DECLARE @JsonBanTiec NVARCHAR(MAX) = COALESCE(JSON_QUERY(@JsonData, '$.JsonBanTiec'), (SELECT x.JsonBanTiec FROM OPENJSON(@JsonData) WITH (JsonBanTiec NVARCHAR(MAX)) x));

    IF @Sohopdong IS NULL OR @Sohopdong = ''
    BEGIN
        SELECT -1 AS code, N'Lỗi: Số hợp đồng không được để trống!' AS msg;
        RETURN;
    END

    -- Tự động sinh mã Phụ lục
    IF @Sothaydoi IS NULL OR @Sothaydoi = '' OR @Sothaydoi = 'NULL'
    BEGIN
        DECLARE @TimeStr VARCHAR(10) = FORMAT(@Now, 'yyMMddHHmm');
        SET @Sothaydoi = 'PL' + @TimeStr;
    END

    IF @Ngaythaydoi IS NULL
        SET @Ngaythaydoi = @Now;

    DECLARE @IsEdit BIT = 0;
    IF EXISTS (SELECT 1 FROM tbmk_Thaydoi WHERE Sothaydoi = @Sothaydoi AND ISNULL(IsDeleted, 0) = 0)
        SET @IsEdit = 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @IsEdit = 0 -- INSERT
        BEGIN
            DECLARE @NextLan INT = 1;
            SELECT @NextLan = ISNULL(MAX(LanThayDoi), 0) + 1 
            FROM tbmk_Thaydoi 
            WHERE Sohopdong = @Sohopdong AND ISNULL(IsDeleted, 0) = 0;

            INSERT INTO tbmk_Thaydoi (
                Sothaydoi, Ngaythaydoi, Sohopdong, Sobiennhan, Makh, Manv, LanThayDoi, Ghichu,
                Status, IsDeleted, UserCreate, DateCreate,
                QuyMoBanTu, QuyMoBanTuTD, QuyMoBanDen, QuyMoBanDenTD,
                ThanhToanDot2SoTien, ThanhToanDot2SoTienTD,
                HinhThucThanhToanDot2, HinhThucThanhToanDot2TD, HanThanhToanDot2, HanThanhToanDot2TD,
                DichVuTinhPhiPhuLuc, DichVuTinhPhiPhuLucTD, ThoaThuanPhuLucKhac, ThoaThuanPhuLucKhacTD,
                DanhSachChiPhi, DanhSachChiPhiTD, BenAChucVuDaiDien, BenAChucVuDaiDienTD,
                DonGiaBanTiec, DonGiaBanTiecTD, SoKhachTrenBan, SoKhachTrenBanTD,
                SobanManchinhthuc, SobanManduphong, SobanChaychinhthuc, SobanChayduphong, SoBanTang,
                JsonBanTiec, JsonThucUong, JsonDichVu, JsonPhatSinh
            )
            VALUES (
                @Sothaydoi, @Ngaythaydoi, @Sohopdong, 
                JSON_VALUE(@JsonData, '$.Sobiennhan'),
                JSON_VALUE(@JsonData, '$.Makh'),
                JSON_VALUE(@JsonData, '$.Manv'),
                @NextLan, @Ghichu,
                @Status, 0, @UserName, @Now,
                
                TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanTu') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanTuTD') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanDen') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanDenTD') AS INT),
                
                TRY_CAST(JSON_VALUE(@JsonData, '$.ThanhToanDot2SoTien') AS DECIMAL(18,2)),
                TRY_CAST(JSON_VALUE(@JsonData, '$.ThanhToanDot2SoTienTD') AS DECIMAL(18,2)),
                
                JSON_VALUE(@JsonData, '$.HinhThucThanhToanDot2'),
                JSON_VALUE(@JsonData, '$.HinhThucThanhToanDot2TD'),
                @HanThanhToanDot2Parsed,
                @HanThanhToanDot2TDParsed,
                
                JSON_VALUE(@JsonData, '$.DichVuTinhPhiPhuLuc'),
                JSON_VALUE(@JsonData, '$.DichVuTinhPhiPhuLucTD'),
                JSON_VALUE(@JsonData, '$.ThoaThuanPhuLucKhac'),
                JSON_VALUE(@JsonData, '$.ThoaThuanPhuLucKhacTD'),
                
                JSON_VALUE(@JsonData, '$.DanhSachChiPhi'),
                JSON_VALUE(@JsonData, '$.DanhSachChiPhiTD'),
                JSON_VALUE(@JsonData, '$.BenAChucVuDaiDien'),
                JSON_VALUE(@JsonData, '$.BenAChucVuDaiDienTD'),
                
                TRY_CAST(JSON_VALUE(@JsonData, '$.DonGiaBanTiec') AS DECIMAL(18,2)),
                TRY_CAST(JSON_VALUE(@JsonData, '$.DonGiaBanTiecTD') AS DECIMAL(18,2)),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SoKhachTrenBan') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SoKhachTrenBanTD') AS INT),
                
                TRY_CAST(JSON_VALUE(@JsonData, '$.SobanManchinhthuc') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SobanManduphong') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SobanChaychinhthuc') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SobanChayduphong') AS INT),
                TRY_CAST(JSON_VALUE(@JsonData, '$.SoBanTang') AS INT),
                
                @JsonBanTiec,
                JSON_QUERY(@JsonData, '$.JsonThucUong'),
                JSON_QUERY(@JsonData, '$.JsonDichVu'),
                JSON_QUERY(@JsonData, '$.JsonPhatSinh')
            );
        END
        ELSE -- UPDATE
        BEGIN
            UPDATE tbmk_Thaydoi
            SET 
                Ngaythaydoi = @Ngaythaydoi,
                Ghichu = @Ghichu,
                Status = @Status,
                UserUpdate = @UserName,
                DateUpdate = @Now,
                
                QuyMoBanTu = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanTu') AS INT), QuyMoBanTu),
                QuyMoBanTuTD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanTuTD') AS INT), QuyMoBanTuTD),
                QuyMoBanDen = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanDen') AS INT), QuyMoBanDen),
                QuyMoBanDenTD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.QuyMoBanDenTD') AS INT), QuyMoBanDenTD),
                
                ThanhToanDot2SoTien = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.ThanhToanDot2SoTien') AS DECIMAL(18,2)), ThanhToanDot2SoTien),
                ThanhToanDot2SoTienTD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.ThanhToanDot2SoTienTD') AS DECIMAL(18,2)), ThanhToanDot2SoTienTD),
                
                HinhThucThanhToanDot2 = COALESCE(JSON_VALUE(@JsonData, '$.HinhThucThanhToanDot2'), HinhThucThanhToanDot2),
                HinhThucThanhToanDot2TD = COALESCE(JSON_VALUE(@JsonData, '$.HinhThucThanhToanDot2TD'), HinhThucThanhToanDot2TD),
                HanThanhToanDot2 = COALESCE(@HanThanhToanDot2Parsed, HanThanhToanDot2),
                HanThanhToanDot2TD = COALESCE(@HanThanhToanDot2TDParsed, HanThanhToanDot2TD),
                
                DichVuTinhPhiPhuLuc = COALESCE(JSON_VALUE(@JsonData, '$.DichVuTinhPhiPhuLuc'), DichVuTinhPhiPhuLuc),
                DichVuTinhPhiPhuLucTD = COALESCE(JSON_VALUE(@JsonData, '$.DichVuTinhPhiPhuLucTD'), DichVuTinhPhiPhuLucTD),
                ThoaThuanPhuLucKhac = COALESCE(JSON_VALUE(@JsonData, '$.ThoaThuanPhuLucKhac'), ThoaThuanPhuLucKhac),
                ThoaThuanPhuLucKhacTD = COALESCE(JSON_VALUE(@JsonData, '$.ThoaThuanPhuLucKhacTD'), ThoaThuanPhuLucKhacTD),
                
                DanhSachChiPhi = COALESCE(JSON_VALUE(@JsonData, '$.DanhSachChiPhi'), DanhSachChiPhi),
                DanhSachChiPhiTD = COALESCE(JSON_VALUE(@JsonData, '$.DanhSachChiPhiTD'), DanhSachChiPhiTD),
                BenAChucVuDaiDien = COALESCE(JSON_VALUE(@JsonData, '$.BenAChucVuDaiDien'), BenAChucVuDaiDien),
                BenAChucVuDaiDienTD = COALESCE(JSON_VALUE(@JsonData, '$.BenAChucVuDaiDienTD'), BenAChucVuDaiDienTD),
                
                DonGiaBanTiec = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.DonGiaBanTiec') AS DECIMAL(18,2)), DonGiaBanTiec),
                DonGiaBanTiecTD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.DonGiaBanTiecTD') AS DECIMAL(18,2)), DonGiaBanTiecTD),
                SoKhachTrenBan = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SoKhachTrenBan') AS INT), SoKhachTrenBan),
                SoKhachTrenBanTD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SoKhachTrenBanTD') AS INT), SoKhachTrenBanTD),
                
                SobanManchinhthuc = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SobanManchinhthuc') AS INT), SobanManchinhthuc),
                SobanManduphong = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SobanManduphong') AS INT), SobanManduphong),
                SobanChaychinhthuc = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SobanChaychinhthuc') AS INT), SobanChaychinhthuc),
                SobanChayduphong = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SobanChayduphong') AS INT), SobanChayduphong),
                SoBanTang = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.SoBanTang') AS INT), SoBanTang),
                
                JsonBanTiec = COALESCE(@JsonBanTiec, JsonBanTiec),
                JsonThucUong = COALESCE(JSON_QUERY(@JsonData, '$.JsonThucUong'), JsonThucUong),
                JsonDichVu = COALESCE(JSON_QUERY(@JsonData, '$.JsonDichVu'), JsonDichVu),
                JsonPhatSinh = COALESCE(JSON_QUERY(@JsonData, '$.JsonPhatSinh'), JsonPhatSinh)
            WHERE Sothaydoi = @Sothaydoi;
        END

        -- Bóc tách dữ liệu JSON từ các trường ẩn (Frontend gửi lên dưới dạng chuỗi JSON escape)

        DECLARE @JsonThucUong NVARCHAR(MAX) = JSON_QUERY(@JsonData, '$.JsonThucUong');
        DECLARE @JsonDichVu NVARCHAR(MAX) = JSON_QUERY(@JsonData, '$.JsonDichVu');

        IF (@JsonBanTiec IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = @Sothaydoi;
            DELETE FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = @Sothaydoi;

            INSERT INTO tbmk_Thaydoithucdonman (
                UserAutoid, Sothaydoi, STTmon, Mahang, Dongia,
                UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio
            )
            SELECT
                NEWID(), @Sothaydoi, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia,
                @UserName, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec)
            WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 0;

            INSERT INTO tbmk_Thaydoithucdonchay (
                UserAutoid, Sothaydoi, STTmon, Mahang, Dongia,
                UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio
            )
            SELECT
                NEWID(), @Sothaydoi, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia,
                @UserName, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec)
            WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 1;
        END

        IF (@JsonThucUong IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoithucuong WHERE Sothaydoi = @Sothaydoi;
            INSERT INTO tbmk_Thaydoithucuong (
                UserAutoid, Sothaydoi, Mahang, Dvt, Soluong, Dongia, Sotien,
                IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT
            )
            SELECT
                NEWID(), @Sothaydoi, j.Mahang, COALESCE(j.Dvt, j.DvtID), j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), @UserName, @Now,
                ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(50), Dvt NVARCHAR(50), DvtID NVARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)
            ) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang;
        END

        IF (@JsonDichVu IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoidichvu WHERE Sothaydoi = @Sothaydoi;
            INSERT INTO tbmk_Thaydoidichvu (
                UserAutoid, Sothaydoi, Mahang, Soluong, Dongia, Sotien,
                IsKhuyenmai, Ghichudichvu, UserCreate, DateCreate, STT
            )
            SELECT
                NEWID(), @Sothaydoi, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, @UserName, @Now,
                ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2),
                IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)
            ) j;
        END

        COMMIT TRANSACTION;
        SELECT 0 AS code, N'Lưu phụ lục thay đổi thành công!' AS msg, @Sothaydoi AS Sothaydoi;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT -1 AS code, N'Lỗi lưu phụ lục: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO


-- =========================================================================
-- 4. CẬP NHẬT TRIGGER ĐỒNG BỘ TRG_tbmk_Thaydoi_SyncToHopDong
-- =========================================================================
PRINT N'5. Đang tạo/cập nhật Trigger TRG_tbmk_Thaydoi_SyncToHopDong...';
GO

IF OBJECT_ID('[dbo].[TRG_tbmk_Thaydoi_SyncToHopDong]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRG_tbmk_Thaydoi_SyncToHopDong];
GO
CREATE TRIGGER [dbo].[TRG_tbmk_Thaydoi_SyncToHopDong]
ON [dbo].[tbmk_Thaydoi]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Đồng bộ ngay lập tức khi có thay đổi Phụ lục (không cần đợi ký duyệt)
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE ISNULL(i.IsDeleted, 0) = 0
    )
    BEGIN
        -- Xóa dữ liệu chi tiết cũ trên Hợp đồng
        DELETE td FROM tbmk_Hopdongthucdonman td INNER JOIN inserted i ON td.Sohopdong = i.Sohopdong;
        DELETE tc FROM tbmk_Hopdongthucdonchay tc INNER JOIN inserted i ON tc.Sohopdong = i.Sohopdong;
        DELETE tu FROM tbmk_Hopdongthucuong tu INNER JOIN inserted i ON tu.Sohopdong = i.Sohopdong;
        DELETE dv FROM tbmk_Hopdongdichvu dv INNER JOIN inserted i ON dv.Sohopdong = i.Sohopdong;

        -- Thêm chi tiết thực đơn mặn
        INSERT INTO tbmk_Hopdongthucdonman (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, Ghichuthucdonman, IsKhaividaugio, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, NULL, 0, i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 0;

        -- Thêm chi tiết thực đơn chay
        INSERT INTO tbmk_Hopdongthucdonchay (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, Ghichuthucdonchay, IsKhaividaugio, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, NULL, 0, i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2), TableType INT, IsChay BIT) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND COALESCE(CASE WHEN j.TableType IN (1,2) THEN j.TableType - 1 END, CAST(j.IsChay AS INT), CASE WHEN ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%' THEN 1 ELSE 0 END) = 1;

        -- Thêm chi tiết thức uống
        INSERT INTO tbmk_Hopdongthucuong (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichuthucuong, Giamgia, STT, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia), ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonThucUong)
        WITH (Mahang VARCHAR(50), Dvt NVARCHAR(50), DvtID NVARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)) j
        WHERE i.JsonThucUong IS NOT NULL AND i.JsonThucUong <> '[]';

        -- Thêm chi tiết dịch vụ
        INSERT INTO tbmk_Hopdongdichvu (UserAutoid, Sohopdong, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichudichvu, STT, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia), ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonDichVu)
        WITH (Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)) j
        WHERE i.JsonDichVu IS NOT NULL AND i.JsonDichVu <> '[]';

        -- Cập nhật thông tin mới nhất từ tbmk_Thaydoi sang tbmk_Hopdong
        ;WITH LatestChanges AS (
            SELECT 
                i.Sohopdong,
                i.NgayToChucTD, i.ThoiGianIDTD, i.NhamNgayTD, i.LoaiTiecIDTD,
                i.SobanManchinhthuc, i.SobanManduphong, i.GiabanManTD,
                i.SobanChaychinhthuc, i.SobanChayduphong, i.GiabanChayTD,
                i.Ghichu, i.TongtienBanmanTD, i.TongtienBanchayTD,
                i.Tongtienthucuong, i.TongtienDichvuTD, i.TongtienHopdongTD,
                i.ConLaiTD, i.SoluongKhachTD, i.TongTienPhanChayTD, i.SoBanTang,
                i.SoNguoiTrenBanTD, i.TongSoBanTD, i.SoBanTinhPhiPhucVuTD,
                i.PhiPhucVuTD, i.TongTienPhiPhucVuTD,
                i.TienTTSTD, i.GiamGiaTTSTD, i.TongTienTTSTD,
                i.TienNTLTD, i.GiamGiaNTLTD, i.TongTienNTLTD,
                i.HinhThucSapSepIDTD, i.PhongSanKhauIDTD, i.PhiBuSanhTD,
                i.TenTrenPhongSanKhauTD, i.GhiChuThongBaoTiecTD, i.PhiBuBanTangTD,
                i.MauNoTD, i.DiaDiemToChucTD, i.TuNgaySetupTD, i.DenNgaySetupTD,
                i.TuGioDenGioSetupTD, i.DenGioSetupTD, i.TuNgayThuDonTD, i.DenNgayThuDonTD,
                i.GioKetThucThuDonTD, i.DenGioKetThucThuDonTD, i.GioDienRaSuKienTD,
                i.ChuongTrinhUuDaiTD, i.SoNgayToChucTD, i.GioBanGiaoSanhTiecCuoiTD,
                i.GioTraSanhTiecCuoiTD, i.GioKetThucSuKienTD, i.NgayBanGiaoSanhDVTD,
                i.GioBanGiaoSanhDVTD, i.NgayTraSanhDVTD, i.GioTraSanhDVTD, i.GoiThucDonIDTD,
                
                -- Đồng bộ các cột mới bổ sung
                i.QuyMoBanTuTD, i.QuyMoBanDenTD, i.TenDotThanhToanTD,
                i.ThanhToanDot2SoTienTD, i.HinhThucThanhToanDot2TD, i.HanThanhToanDot2TD,
                i.DichVuTinhPhiPhuLucTD, i.ThoaThuanPhuLucKhacTD, i.DanhSachChiPhiTD,
                i.BenAChucVuDaiDienTD, i.DonGiaBanTiecTD, i.SoKhachTrenBanTD,
                
                ROW_NUMBER() OVER (PARTITION BY i.Sohopdong ORDER BY i.LanThayDoi DESC, i.Ngaythaydoi DESC, i.Sothaydoi DESC) as rn
            FROM tbmk_Thaydoi i
            WHERE ISNULL(i.IsDeleted, 0) = 0
              AND i.Sohopdong IN (SELECT Sohopdong FROM inserted)
        )
        UPDATE h
        SET 
            h.Ngaytochuc = COALESCE(lc.NgayToChucTD, h.Ngaytochuc),
            h.Thoigianid = COALESCE(NULLIF(lc.ThoiGianIDTD, ''), h.Thoigianid),
            h.Nhamngay = COALESCE(NULLIF(lc.NhamNgayTD, ''), h.Nhamngay),
            h.Loaitiecid = COALESCE(NULLIF(lc.LoaiTiecIDTD, ''), h.Loaitiecid),
            h.SobanManchinhthuc = COALESCE(lc.SobanManchinhthuc, h.SobanManchinhthuc),
            h.SobanManduphong = COALESCE(lc.SobanManduphong, h.SobanManduphong),
            h.Giabanman = COALESCE(NULLIF(lc.GiabanManTD, 0), h.Giabanman),
            h.SobanChaychinhthuc = COALESCE(lc.SobanChaychinhthuc, h.SobanChaychinhthuc),
            h.SobanChayduphong = COALESCE(lc.SobanChayduphong, h.SobanChayduphong),
            h.Giabanchay = COALESCE(NULLIF(lc.GiabanChayTD, 0), h.Giabanchay),
            h.Ghichu = COALESCE(NULLIF(lc.Ghichu, ''), h.Ghichu),
            h.Tongtienbanman = COALESCE(NULLIF(lc.TongtienBanmanTD, 0), h.Tongtienbanman),
            h.Tongtienbanchay = COALESCE(NULLIF(lc.TongtienBanchayTD, 0), h.Tongtienbanchay),
            h.Tongtienthucuong = COALESCE(NULLIF(lc.Tongtienthucuong, 0), h.Tongtienthucuong),
            h.Tongtiendichvu = COALESCE(NULLIF(lc.TongtienDichvuTD, 0), h.Tongtiendichvu),
            h.Tongtienhopdong = COALESCE(NULLIF(lc.TongtienHopdongTD, 0), h.Tongtienhopdong),
            h.Conlai = COALESCE(NULLIF(lc.ConLaiTD, 0), h.Conlai),
            h.Soluongkhach = COALESCE(NULLIF(lc.SoluongKhachTD, 0), h.Soluongkhach),
            h.Tongtienphanchay = COALESCE(NULLIF(lc.TongTienPhanChayTD, 0), h.Tongtienphanchay),
            h.SoBanTang = COALESCE(lc.SoBanTang, h.SoBanTang),
            h.SoNguoiTrenBan = COALESCE(NULLIF(lc.SoNguoiTrenBanTD, 0), h.SoNguoiTrenBan),
            h.TongSoBan = COALESCE(NULLIF(lc.TongSoBanTD, 0), h.TongSoBan),
            h.SoBanTinhPhiPhucVu = COALESCE(NULLIF(lc.SoBanTinhPhiPhucVuTD, 0), h.SoBanTinhPhiPhucVu),
            h.PhiPhucVu = COALESCE(NULLIF(lc.PhiPhucVuTD, 0), h.PhiPhucVu),
            h.TongTienPhiPhucVu = COALESCE(NULLIF(lc.TongTienPhiPhucVuTD, 0), h.TongTienPhiPhucVu),
            h.TienTTS = COALESCE(NULLIF(lc.TienTTSTD, 0), h.TienTTS),
            h.GiamGiaTTS = COALESCE(NULLIF(lc.GiamGiaTTSTD, 0), h.GiamGiaTTS),
            h.TongTienTTS = COALESCE(NULLIF(lc.TongTienTTSTD, 0), h.TongTienTTS),
            h.TienNTL = COALESCE(NULLIF(lc.TienNTLTD, 0), h.TienNTL),
            h.GiamGiaNTL = COALESCE(NULLIF(lc.GiamGiaNTLTD, 0), h.GiamGiaNTL),
            h.TongTienNTL = COALESCE(NULLIF(lc.TongTienNTLTD, 0), h.TongTienNTL),
            h.HinhThucSapSepID = COALESCE(NULLIF(lc.HinhThucSapSepIDTD, ''), h.HinhThucSapSepID),
            h.PhongSanKhauID = COALESCE(NULLIF(lc.PhongSanKhauIDTD, ''), h.PhongSanKhauID),
            h.PhiBuSanh = COALESCE(NULLIF(lc.PhiBuSanhTD, 0), h.PhiBuSanh),
            h.TenTrenPhongSanKhau = COALESCE(NULLIF(lc.TenTrenPhongSanKhauTD, ''), h.TenTrenPhongSanKhau),
            h.GhiChuThongBaoTiec = COALESCE(NULLIF(lc.GhiChuThongBaoTiecTD, ''), h.GhiChuThongBaoTiec),
            h.PhiBuBanTang = COALESCE(NULLIF(lc.PhiBuBanTangTD, 0), h.PhiBuBanTang),
            h.MauNo = COALESCE(NULLIF(lc.MauNoTD, ''), h.MauNo),
            h.DiaDiemToChuc = COALESCE(NULLIF(lc.DiaDiemToChucTD, ''), h.DiaDiemToChuc),
            h.TuNgaySetup = COALESCE(lc.TuNgaySetupTD, h.TuNgaySetup),
            h.DenNgaySetup = COALESCE(lc.DenNgaySetupTD, h.DenNgaySetup),
            h.TuGioDenGioSetup = COALESCE(NULLIF(lc.TuGioDenGioSetupTD, ''), h.TuGioDenGioSetup),
            h.DenGioSetup = COALESCE(NULLIF(lc.DenGioSetupTD, ''), h.DenGioSetup),
            h.TuNgayThuDon = COALESCE(lc.TuNgayThuDonTD, h.TuNgayThuDon),
            h.DenNgayThuDon = COALESCE(lc.DenNgayThuDonTD, h.DenNgayThuDon),
            h.GioKetThucThuDon = COALESCE(NULLIF(lc.GioKetThucThuDonTD, ''), h.GioKetThucThuDon),
            h.DenGioKetThucThuDon = COALESCE(NULLIF(lc.DenGioKetThucThuDonTD, ''), h.DenGioKetThucThuDon),
            h.GioDienRaSuKien = COALESCE(NULLIF(lc.GioDienRaSuKienTD, ''), h.GioDienRaSuKien),
            h.ChuongTrinhUuDai = COALESCE(NULLIF(lc.ChuongTrinhUuDaiTD, ''), h.ChuongTrinhUuDai),
            h.SoNgayToChuc = COALESCE(NULLIF(lc.SoNgayToChucTD, 0), h.SoNgayToChuc),
            h.GioBanGiaoSanhTiecCuoi = COALESCE(NULLIF(lc.GioBanGiaoSanhTiecCuoiTD, ''), h.GioBanGiaoSanhTiecCuoi),
            h.GioTraSanhTiecCuoi = COALESCE(NULLIF(lc.GioTraSanhTiecCuoiTD, ''), h.GioTraSanhTiecCuoi),
            h.GioKetThucSuKien = COALESCE(NULLIF(lc.GioKetThucSuKienTD, ''), h.GioKetThucSuKien),
            h.NgayBanGiaoSanhDV = COALESCE(lc.NgayBanGiaoSanhDVTD, h.NgayBanGiaoSanhDV),
            h.GioBanGiaoSanhDV = COALESCE(NULLIF(lc.GioBanGiaoSanhDVTD, ''), h.GioBanGiaoSanhDV),
            h.NgayTraSanhDV = COALESCE(lc.NgayTraSanhDVTD, h.NgayTraSanhDV),
            h.GioTraSanhDV = COALESCE(NULLIF(lc.GioTraSanhDVTD, ''), h.GioTraSanhDV),
            h.GoiThucDonID = COALESCE(NULLIF(lc.GoiThucDonIDTD, ''), h.GoiThucDonID),
            
            -- Đồng bộ các cột mới bổ sung
            h.QuyMoBanTu = COALESCE(NULLIF(lc.QuyMoBanTuTD, 0), h.QuyMoBanTu),
            h.QuyMoBanDen = COALESCE(NULLIF(lc.QuyMoBanDenTD, 0), h.QuyMoBanDen),
            h.TenDotThanhToan = COALESCE(NULLIF(lc.TenDotThanhToanTD, ''), h.TenDotThanhToan),
            h.ThanhToanDot2SoTien = COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), h.ThanhToanDot2SoTien),
            h.HinhThucThanhToanDot2 = COALESCE(NULLIF(lc.HinhThucThanhToanDot2TD, ''), h.HinhThucThanhToanDot2),
            h.HanThanhToanDot2 = COALESCE(lc.HanThanhToanDot2TD, h.HanThanhToanDot2),
            h.DichVuTinhPhiPhuLuc = COALESCE(NULLIF(lc.DichVuTinhPhiPhuLucTD, ''), h.DichVuTinhPhiPhuLuc),
            h.ThoaThuanPhuLucKhac = COALESCE(NULLIF(lc.ThoaThuanPhuLucKhacTD, ''), h.ThoaThuanPhuLucKhac),
            h.DanhSachChiPhi = COALESCE(NULLIF(lc.DanhSachChiPhiTD, ''), h.DanhSachChiPhi),
            h.BenAChucVuDaiDien = COALESCE(NULLIF(lc.BenAChucVuDaiDienTD, ''), h.BenAChucVuDaiDien),
            h.DonGiaBanTiec = COALESCE(NULLIF(lc.DonGiaBanTiecTD, 0), h.DonGiaBanTiec),
            h.SoKhachTrenBan = COALESCE(NULLIF(lc.SoKhachTrenBanTD, 0), h.SoKhachTrenBan),
            
            -- Đồng bộ cọc lần 2 và tổng tiền cọc tương ứng
            h.Sotiencochopdong = COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), h.Sotiencochopdong),
            h.Tongtiencoc = ISNULL(h.Sotiencoccho, 0) + COALESCE(NULLIF(lc.ThanhToanDot2SoTienTD, 0), ISNULL(h.Sotiencochopdong, 0))
        FROM tbmk_Hopdong h
        INNER JOIN LatestChanges lc ON h.Sohopdong = lc.Sohopdong
        WHERE lc.rn = 1;
    END
END
GO


-- =========================================================================
-- 5. ĐỒNG BỘ ĐỊNH TUYẾN GATEWAY (WA_API)
-- =========================================================================
PRINT N'6. Đang đồng bộ cấu hình Gateway WA_API...';
GO



-- 6.2. Đồng bộ các định tuyến API trong WA_API cho cả 3 form IDs (đảm bảo FE gọi ID nào cũng chạy đúng)
DELETE FROM WA_API WHERE List IN ('frmThayDoiBoSung', 'frmPhuLucHopDong', 'tbmk_Thaydoi') AND Func IN ('View', 'Save', 'Delete');
GO

-- Đăng ký View
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'View', 'API_TruyVanDong', '@List=N''frmThayDoiBoSung'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}'''),
('frmPhuLucHopDong', 'View', 'API_TruyVanDong', '@List=N''frmPhuLucHopDong'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}'''),
('tbmk_Thaydoi', 'View', 'API_Thaydoi', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}'''); -- Giữ nguyên SP cũ cho xuất Word/Detail

-- Đăng ký Save
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}'''),
('frmPhuLucHopDong', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}'''),
('tbmk_Thaydoi', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}''');

-- Đăng ký Delete
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}'''),
('frmPhuLucHopDong', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}'''),
('tbmk_Thaydoi', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}''');
GO

-- 6.3. Tự động đồng bộ các cột từ View sang bảng định dạng trường SY_FormatFields
EXEC API_DongBoTruongGiaoDien @FormName = 'frmThayDoiBoSung', @ObjectName = 'v_DanhSachPhuLuc';
EXEC API_DongBoTruongGiaoDien @FormName = 'frmPhuLucHopDong', @ObjectName = 'v_DanhSachPhuLuc';
EXEC API_DongBoTruongGiaoDien @FormName = 'tbmk_Thaydoi', @ObjectName = 'v_DanhSachPhuLuc';
GO

-- 6.4. Cấu hình nhãn Tiếng Việt, loại hiển thị, datasource và ẩn các trường không dùng trong Form
PRINT N'6.4. Đang cấu hình nhãn tiếng Việt và ẩn các trường không sử dụng trong Form...';
GO

DECLARE @Forms TABLE (FormName VARCHAR(50));
INSERT INTO @Forms VALUES ('frmThayDoiBoSung'), ('frmPhuLucHopDong'), ('tbmk_Thaydoi');

-- Mặc định ẩn toàn bộ trường trong form trước để tránh tràn lan cột metadata/computed
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0 
WHERE FormName IN (SELECT FormName FROM @Forms);

-- Cấu hình chi tiết hiển thị, nhãn, kiểu nhập liệu và thứ tự hiển thị cho các trường nghiệp vụ
-- 1. Khóa chính & Liên kết
UPDATE ff
SET CaptionVN = N'Số Thay Đổi', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, FormPosition = '6', OrderNo = 1
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Sothaydoi';

UPDATE ff
SET CaptionVN = N'Số Hợp Đồng', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, FormPosition = '6', OrderNo = 2
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Sohopdong';

-- 2. Thông tin Phụ lục
UPDATE ff
SET CaptionVN = N'Số Phụ Lục HĐ', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 3
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SoPhuLuc';

UPDATE ff
SET CaptionVN = N'Ngày Lập Phụ Lục', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 4
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'NgayLapPL';

-- 3. Thông tin tiệc thay đổi
UPDATE ff
SET CaptionVN = N'Ngày Tổ Chức Tiệc', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 5
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'NgayToChuc';

UPDATE ff
SET CaptionVN = N'Loại Hình Tiệc', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 6
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'LoaiTiecID';

UPDATE ff
SET CaptionVN = N'Ca Tổ Chức', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 7
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'ThoiGianID';

-- 4. Quy mô & Đơn giá
UPDATE ff
SET CaptionVN = N'Quy Mô Bàn (Từ)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 8
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'QuyMoBanTu';

UPDATE ff
SET CaptionVN = N'Quy Mô Bàn (Đến)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 9
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'QuyMoBanDen';

UPDATE ff
SET CaptionVN = N'Đơn Giá Bàn Tiệc', FormatID = 'mn', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 10
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'DonGiaBanTiec';

UPDATE ff
SET CaptionVN = N'Số Khách / Bàn', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 11
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SoKhachTrenBan';

-- 5. Số bàn tiệc chính thức & dự phòng
UPDATE ff
SET CaptionVN = N'Bàn Mặn (Chính Thức)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 12
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanManchinhthuc';

UPDATE ff
SET CaptionVN = N'Bàn Mặn (Dự Phòng)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 13
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanManduphong';

UPDATE ff
SET CaptionVN = N'Bàn Chay (Chính Thức)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 14
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanChaychinhthuc';

UPDATE ff
SET CaptionVN = N'Bàn Chay (Dự Phòng)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 15
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanChayduphong';

-- 6. Đợt thanh toán 2

UPDATE ff
SET CaptionVN = N'Số Tiền Đợt 2', FormatID = 'mn', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 17
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'ThanhToanDot2SoTien';

UPDATE ff
SET CaptionVN = N'Hình thức thanh toán Đợt 2', FormatID = 'sl', DataSource = N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 18
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'HinhThucThanhToanDot2';

UPDATE ff
SET CaptionVN = N'Hạn Thanh Toán Đợt 2', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 19
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'HanThanhToanDot2';

-- 7. Khác & Ghi chú
UPDATE ff
SET CaptionVN = N'Bên A - Chức Vụ Người Ký', FormatID = 't', ShowInAdd = 0, ShowInEdit = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 20
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'BenAChucVuDaiDien';

UPDATE ff
SET CaptionVN = N'Trạng Thái Phụ Lục', FormatID = 'sl', DataSource = N'STATIC:DRAFT|Đơn nháp,SIGNED|Đã ký (Đang chờ duyệt),APPROVED|Đã duyệt (Sync hợp đồng),CANCELLED|Đã hủy', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 21
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Status';

UPDATE ff
SET CaptionVN = N'Nội dung thỏa thuận', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '12', OrderNo = 22
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Ghichu';
-- 8. Cấu hình các trường JSON Thực đơn & Dịch vụ (Cho FoodSelectionPlugin)
UPDATE SY_FormatFields SET ShowInAdd = 1, ShowInEdit = 1, FormatID = 't', FormPosition = '6' 
WHERE FormName IN (SELECT FormName FROM @Forms) AND FieldName IN ('JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID)
SELECT f.FormName, 'JsonBanTiec', N'Thực đơn', 1, 1, 0, 0, 200, '6', 't'
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'JsonBanTiec');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID)
SELECT f.FormName, 'JsonThucUong', N'Thức uống', 1, 1, 0, 0, 201, '6', 't'
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'JsonThucUong');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID)
SELECT f.FormName, 'JsonDichVu', N'Dịch vụ', 1, 1, 0, 0, 202, '6', 't'
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'JsonDichVu');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID)
SELECT f.FormName, 'JsonPhatSinh', N'Phát sinh', 1, 1, 0, 0, 203, '6', 't'
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'JsonPhatSinh');

-- Đảm bảo có từ điển để dịch cột Sobiennhan và Makh trên popup chọn Hợp đồng
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID, ShowInGrid)
SELECT f.FormName, 'Sobiennhan', N'Số Biên Nhận', 0, 0, 0, 0, 99, '6', 't', 0
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'Sobiennhan');

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, OrderNo, FormPosition, FormatID, ShowInGrid)
SELECT f.FormName, 'Makh', N'Mã Khách Hàng', 0, 0, 0, 0, 100, '6', 't', 0
FROM @Forms f WHERE NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = f.FormName AND FieldName = 'Makh');
GO

PRINT N'=== HOÀN THÀNH CẬP NHẬT CẤU TRÚC PHỤ LỤC HỢP ĐỒNG (ALL-IN-ONE) ===';
GO

-- =========================================================================
-- DI TRÚ DỮ LIỆU TỰ ĐỘNG SANG CÁC BẢNG CHUẨN (SY_FmtFldTbl & SY_FrmDrdwTbl)
-- =========================================================================
PRINT N'Đang di chuyển dữ liệu từ SY_FormatFields sang SY_FmtFldTbl...';
GO

MERGE INTO SY_FmtFldTbl AS target
USING (
    SELECT FieldName, MAX(FormName) AS FormName, MAX(CaptionVN) AS CaptionVN, MAX(CaptionEN) AS CaptionEN, MAX(CaptionCH) AS CaptionCH, MAX(FormatID) AS FormatID, MAX(AlignX) AS AlignX, MAX(MinWidth) AS MinWidth, MAX(MaxWidth) AS MaxWidth
    FROM SY_FormatFields
    GROUP BY FieldName
) AS source
ON (target.FieldName = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        CaptionVN = ISNULL(source.CaptionVN, target.CaptionVN),
        CaptionEN = ISNULL(source.CaptionEN, target.CaptionEN),
        CaptionCH = ISNULL(source.CaptionCH, target.CaptionCH),
        FormatID  = ISNULL(source.FormatID,  target.FormatID),
        AlignX    = ISNULL(source.AlignX,    target.AlignX),
        MinWidth  = ISNULL(source.MinWidth,  target.MinWidth),
        MaxWidth  = ISNULL(source.MaxWidth,  target.MaxWidth)
WHEN NOT MATCHED THEN
    INSERT (FormName, FieldName, CaptionVN, CaptionEN, CaptionCH, FormatID, AlignX, MinWidth, MaxWidth)
    VALUES (source.FormName, source.FieldName, source.CaptionVN, source.CaptionEN, source.CaptionCH, source.FormatID, source.AlignX, source.MinWidth, source.MaxWidth);
GO

MERGE INTO SY_FrmDrdwTbl AS target
USING (
    SELECT FormName, FieldName, DataSource,
           CASE WHEN ShowInAdd = 0 AND ShowInEdit = 0 THEN 1 ELSE 0 END AS IsInvisibleVal,
           CASE WHEN IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 THEN 1 ELSE 0 END AS IsLockVal
    FROM SY_FormatFields
    WHERE DataSource IS NOT NULL AND DataSource <> ''
) AS source
ON (target.FormID = source.FormName AND target.ColumnID = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        Source = source.DataSource,
        Type = 'API',
        ValueColumn = source.FieldName,
        DisplayColumn = 'Ten',
        isInvisible = source.IsInvisibleVal,
        isLock = source.IsLockVal
WHEN NOT MATCHED THEN
    INSERT (UserAutoID, FormID, ColumnID, Source, Type, ValueColumn, DisplayColumn, isInvisible, isLock)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), source.FormName, source.FieldName, source.DataSource, 'API', source.FieldName, 'Ten', source.IsInvisibleVal, source.IsLockVal);
GO

MERGE INTO SY_FrmDrdwTbl AS target
USING (
    SELECT FormName, FieldName,
           CASE WHEN ShowInAdd = 0 AND ShowInEdit = 0 THEN 1 ELSE 0 END AS IsInvisibleVal,
           CASE WHEN IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 THEN 1 ELSE 0 END AS IsLockVal
    FROM SY_FormatFields
    WHERE (DataSource IS NULL OR DataSource = '')
      AND (ShowInAdd = 0 OR ShowInEdit = 0 OR IsReadOnlyAdd = 1 OR IsReadOnlyEdit = 1 OR FormPosition = 'hidden')
) AS source
ON (target.FormID = source.FormName AND target.ColumnID = source.FieldName)
WHEN MATCHED THEN
    UPDATE SET 
        isInvisible = source.IsInvisibleVal,
        isLock = source.IsLockVal
WHEN NOT MATCHED THEN
    INSERT (UserAutoID, FormID, ColumnID, isInvisible, isLock)
    VALUES (LOWER(REPLACE(CAST(NEWID() AS VARCHAR(50)), '-', '')), source.FormName, source.FieldName, source.IsInvisibleVal, source.IsLockVal);
GO

IF OBJECT_ID('SY_FormatFields', 'U') IS NOT NULL
    DROP TABLE SY_FormatFields;
GO

