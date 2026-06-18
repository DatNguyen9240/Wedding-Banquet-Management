USE [QLTiec]
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT TOÀN DIỆN PHÂN HỆ THAY ĐỔI BỔ SUNG (ALL-IN-ONE) ===';
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

-- Bổ sung các cột Soft Delete cho tbmk_Thaydoi để hỗ trợ API xóa mềm
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'IsDeleted')
    ALTER TABLE tbmk_Thaydoi ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DeletedAt')
    ALTER TABLE tbmk_Thaydoi ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Thaydoi]') AND name = 'DeletedBy')
    ALTER TABLE tbmk_Thaydoi ADD DeletedBy VARCHAR(50) NULL;
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
-- 2. TẠO CÁC BẢNG CHI TIẾT THỰC ĐƠN VÀ DỊCH VỤ PHỤ LỤC & MIGRATE DỮ LIỆU
-- =========================================================================
PRINT N'3. Đang kiểm tra và khởi tạo các bảng chi tiết Phụ lục...';
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

-- Migrate dữ liệu cũ từ JSON cột gốc sang bảng con (chỉ thực hiện một lần nếu bảng rỗng)
IF COL_LENGTH('tbmk_Thaydoi', 'JsonBanTiec') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman)
    BEGIN
        INSERT INTO tbmk_Thaydoithucdonman (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio)
        SELECT NEWID(), h.Sothaydoi, ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
        FROM tbmk_Thaydoi h
        CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
          AND ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%'
          AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonman x WHERE x.Sothaydoi = h.Sothaydoi);
    END

    IF NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay)
    BEGIN
        INSERT INTO tbmk_Thaydoithucdonchay (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio)
        SELECT NEWID(), h.Sothaydoi, ROW_NUMBER() OVER (PARTITION BY h.Sothaydoi ORDER BY j.Mahang), j.Mahang, j.Dongia, 'Migrate', GETDATE(), NULL, 0
        FROM tbmk_Thaydoi h
        CROSS APPLY OPENJSON(h.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE NULLIF(LTRIM(RTRIM(h.JsonBanTiec)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonBanTiec), 1) = '['
          AND ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%'
          AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucdonchay x WHERE x.Sothaydoi = h.Sothaydoi);
    END
END

IF COL_LENGTH('tbmk_Thaydoi', 'JsonThucUong') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoithucuong)
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
    WHERE NULLIF(LTRIM(RTRIM(h.JsonThucUong)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonThucUong), 1) = '[';
END

IF COL_LENGTH('tbmk_Thaydoi', 'JsonDichVu') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tbmk_Thaydoidichvu)
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
    WHERE NULLIF(LTRIM(RTRIM(h.JsonDichVu)), '') IS NOT NULL AND LEFT(LTRIM(h.JsonDichVu), 1) = '[';
END
GO


-- =========================================================================
-- 3. KHỞI TẠO LẠI VIEW v_DanhSachPhuLuc (MAPPING HOÀN TOÀN CÁC BIẾN DOCX)
-- =========================================================================
PRINT N'4. Đang khởi tạo View v_DanhSachPhuLuc hỗ trợ in ấn DOCX...';
GO

IF OBJECT_ID('[dbo].[v_DanhSachPhuLuc]', 'V') IS NOT NULL
    DROP VIEW [dbo].[v_DanhSachPhuLuc];
GO
CREATE VIEW [dbo].[v_DanhSachPhuLuc] AS
SELECT 
    td.Sothaydoi AS [Id], -- Dùng làm PrimaryKey cho Frontend
    td.Sothaydoi AS [Sothaydoi], 
    td.Sothaydoi AS [SoPhuLuc], -- Biến {SoPhuLuc} trong Word
    td.Ngaythaydoi AS [Ngaythaydoi],
    RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL], -- {NgayLapPL}
    RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL], -- {ThangLapPL}
    CAST(YEAR(td.Ngaythaydoi) AS VARCHAR) AS [NamLapPL], -- {NamLapPL}
    td.Sohopdong AS [Sohopdong], -- {Sohopdong}
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
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'BenASDT') AS [BenASDT],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenANguoiDaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNNguoiDaiDien') AS [BenADaiDien],
    (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],
    ISNULL(nv.Tennv, ISNULL(td.Manv, hd.Manv)) AS [BenANhanVienPhuTrach], -- {BenANhanVienPhuTrach}
    ISNULL(nv.Dienthoai, '') AS [BenASDTNhanVien],

    -- Thông tin liên lạc Bên B
    kh.Tenkh AS [BenBTenDaiDien],
    kh.Tenkh AS [BenBDaiDien], -- Biến {BenBDaiDien} trong Word
    ISNULL(kh.Tenchure, '') + ' & ' + ISNULL(kh.Tencodau, '') AS [BenBTenChuTiec],
    kh.Diachi AS [BenBDiaChi],
    kh.Dienthoai AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],

    -- Hợp đồng gốc ngày lập
    RIGHT('0' + CAST(DAY(hd.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD], -- {NgayLapHD}
    RIGHT('0' + CAST(MONTH(hd.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
    CAST(YEAR(hd.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

    -- Loại hình sự kiện & Sảnh & Ca
    ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid)), N'') AS [LoaiHinhSuKien], -- {LoaiHinhSuKien}
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = td.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [TenSanhTiec],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = td.Sohopdong ORDER BY hs.IsSanhchinh DESC) AS [Sanh], -- {Sanh}
    FORMAT(ISNULL(td.NgayToChucTD, hd.Ngaytochuc), 'HH:mm') AS [TiecGioBatDau],
    
    -- Ngày tổ chức Dương lịch
    RIGHT('0' + CAST(DAY(ISNULL(td.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [NgayToChuc], -- {NgayToChuc}
    RIGHT('0' + CAST(MONTH(ISNULL(td.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [ThangToChuc],
    CAST(YEAR(ISNULL(td.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR) AS [NamToChuc],
    ISNULL(td.NhamNgayTD, hd.Nhamngay) AS [Nhamngay],
    
    -- Ngày tổ chức Âm lịch cho DOCX
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
    
    ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid) AS [LoaiTiecID],
    (SELECT TOP 1 tm.TemplateFile FROM tbmk_LoaitiecAddfile tm WHERE tm.FormName = 'frmPhuLucHopDong' AND tm.Loaitiecid = ISNULL(td.LoaiTiecIDTD, hd.Loaitiecid)) AS [TemplateFile],
    ISNULL(td.ThoiGianIDTD, hd.Thoigianid) AS [ThoiGianID],
    
    -- Quy mô bàn & Đơn giá
    ISNULL(td.QuyMoBanTuTD, td.QuyMoBanTu) AS [QuyMoBanTu],
    ISNULL(td.QuyMoBanDenTD, td.QuyMoBanDen) AS [QuyMoBanDen],
    ISNULL(td.DonGiaBanTiecTD, td.DonGiaBanTiec) AS [DonGiaBanTiec],
    ISNULL(td.SoKhachTrenBanTD, td.SoKhachTrenBan) AS [SoKhachTrenBan],
    
    -- Bàn tiệc
    ISNULL(NULLIF(td.SobanManchinhthuc, 0), hd.SobanManchinhthuc) AS [SobanManchinhthuc],
    ISNULL(NULLIF(td.SobanManduphong, 0), hd.SobanManduphong) AS [SobanManduphong],
    ISNULL(NULLIF(td.SobanChaychinhthuc, 0), hd.SobanChaychinhthuc) AS [SobanChaychinhthuc],
    ISNULL(NULLIF(td.SobanChayduphong, 0), hd.SobanChayduphong) AS [SobanChayduphong],
    ISNULL(NULLIF(td.SobanManchinhthuc, 0), hd.SobanManchinhthuc) + ISNULL(NULLIF(td.SobanChaychinhthuc, 0), hd.SobanChaychinhthuc) AS [SoBanChinhThuc], -- {SoBanChinhThuc}
    ISNULL(NULLIF(td.SobanManduphong, 0), hd.SobanManduphong) + ISNULL(NULLIF(td.SobanChayduphong, 0), hd.SobanChayduphong) AS [SoBanDuPhong], -- {SoBanDuPhong}
    ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [BanTang], -- {BanTang}
    ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [SoBanTang],

    -- Thực đơn {#MenuTiec}
    COALESCE(
        (
            SELECT ISNULL(hh.Tenhang, t.Mahang) AS [TenMonAn],
                   FORMAT(ISNULL(t.Dongia, 0), 'N0', 'vi-VN') AS [DonGia]
            FROM (
                SELECT Mahang, Dongia, STTmon, 1 AS Loai FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Mahang, Dongia, STTmon, 2 AS Loai FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi
            ) t
            LEFT JOIN dmHanghoa hh ON t.Mahang = hh.Mahang
            ORDER BY t.Loai, t.STTmon, t.Mahang
            FOR JSON PATH
        ),
        '[]'
    ) AS [MenuTiec],

    FORMAT(
        ISNULL((
            SELECT SUM(ISNULL(Dongia, 0)) FROM (
                SELECT Dongia FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = td.Sothaydoi
                UNION ALL
                SELECT Dongia FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = td.Sothaydoi
            ) t
        ), 0), 'N0', 'vi-VN'
    ) + N' VNĐ' AS [MenuTongCong],

    -- Danh sách chi phí {#DanhSachChiPhi}
    CASE
        WHEN ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) IS NOT NULL
             AND ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) <> ''
             AND ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) <> '[]'
            THEN ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi)
        ELSE
            COALESCE(
                (
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
                        FROM tbmk_Thaydoidichvu tm
                        LEFT JOIN dmHanghoa hh ON tm.Mahang = hh.Mahang
                        WHERE tm.Sothaydoi = td.Sothaydoi
                        UNION ALL
                        SELECT 
                            2 AS SortOrder, tu.STT, tu.Mahang,
                            ISNULL(hh.Tenhang, tu.Mahang) AS [NoiDung],
                            ISNULL(tu.Dvt, hh.DVTID) AS [DVT],
                            ISNULL(TRY_CAST(tu.Soluong AS INT), 0) AS [SoLuong],
                            FORMAT(ISNULL(tu.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
                            FORMAT(ISNULL(tu.Dongia, 0) * ISNULL(tu.Soluong, 0), 'N0', 'vi-VN') AS [ThanhTien]
                        FROM tbmk_Thaydoithucuong tu
                        LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
                        WHERE tu.Sothaydoi = td.Sothaydoi
                    ) t
                    FOR JSON PATH
                ),
                '[]'
            )
    END AS [DanhSachChiPhi],
    
    -- Các đợt thanh toán
    ISNULL(td.ThanhToanDot2SoTienTD, td.ThanhToanDot2SoTien) AS [ThanhToanDot2SoTien],
    ISNULL(td.HinhThucThanhToanDot2TD, td.HinhThucThanhToanDot2) AS [HinhThucThanhToanDot2],
    FORMAT(ISNULL(td.HanThanhToanDot2TD, td.HanThanhToanDot2), 'dd/MM/yyyy') AS [HanThanhToanDot2],
    
    -- Thỏa thuận khác {@ThoaThuanPhuLucKhac}
    ISNULL(td.DichVuTinhPhiPhuLucTD, td.DichVuTinhPhiPhuLuc) AS [DichVuTinhPhiPhuLuc],
    ISNULL(td.ThoaThuanPhuLucKhacTD, td.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
    
    FORMAT(ISNULL(td.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
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
    
    -- Dữ liệu lưới phụ JSON phản hồi cho Client
    COALESCE((
        SELECT items.Mahang, items.TenHang, items.DvtID, items.Soluong, items.Dongia, items.IsChay
        FROM (
            SELECT tm.Mahang, ISNULL(hh.Tenhang, tm.Mahang) AS TenHang, ISNULL(hh.DVTID, N'Đĩa') AS DvtID,
                   CAST(1 AS DECIMAL(18,2)) AS Soluong, ISNULL(tm.Dongia, 0) AS Dongia,
                   CAST(0 AS BIT) AS IsChay, ISNULL(tm.STTmon, 0) AS SortOrder, 1 AS TableType
            FROM tbmk_Thaydoithucdonman tm
            LEFT JOIN dmHanghoa hh ON tm.Mahang = hh.Mahang
            WHERE tm.Sothaydoi = td.Sothaydoi
            UNION ALL
            SELECT tc.Mahang, ISNULL(hh.Tenhang, tc.Mahang), ISNULL(hh.DVTID, N'Đĩa'),
                   CAST(1 AS DECIMAL(18,2)), ISNULL(tc.Dongia, 0),
                   CAST(1 AS BIT), ISNULL(tc.STTmon, 0), 2
            FROM tbmk_Thaydoithucdonchay tc
            LEFT JOIN dmHanghoa hh ON tc.Mahang = hh.Mahang
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
        FROM tbmk_Thaydoithucuong tu
        LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
        WHERE tu.Sothaydoi = td.Sothaydoi
        ORDER BY tu.STT, tu.Mahang
        FOR JSON PATH
    ), td.JsonThucUong, '[]') AS [JsonThucUong],

    COALESCE((
        SELECT dv.Mahang, ISNULL(hh.Tenhang, dv.Mahang) AS TenHang, ISNULL(hh.DVTID, N'') AS DvtID,
               ISNULL(dv.Soluong, 0) AS Soluong, ISNULL(dv.Dongia, 0) AS Dongia,
               ISNULL(dv.Ghichudichvu, N'') AS Ghichudichvu
        FROM tbmk_Thaydoidichvu dv
        LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
        WHERE dv.Sothaydoi = td.Sothaydoi
        ORDER BY dv.STT, dv.Mahang
        FOR JSON PATH
    ), td.JsonDichVu, '[]') AS [JsonDichVu],

    COALESCE(td.JsonPhatSinh, '[]') AS [JsonPhatSinh],
    td.BenAChucVuDaiDienTD AS [BenAChucVuDaiDien]
FROM tbmk_Thaydoi td
INNER JOIN tbmk_Hopdong hd ON td.Sohopdong = hd.Sohopdong
LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
LEFT JOIN dmNhanvienView nv ON ISNULL(td.Manv, hd.Manv) = nv.Manv
WHERE ISNULL(td.IsDeleted, 0) = 0;
GO


-- =========================================================================
-- 4. THỦ TỤC LƯU PHỤ LỤC THAY ĐỔI API_LuuThayDoi
-- =========================================================================
PRINT N'5. Đang tạo/cập nhật Procedure API_LuuThayDoi...';
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
    
    -- Giải nén các tham số từ JsonData nếu có
    IF (@JsonData IS NOT NULL AND @JsonData <> '' AND ISJSON(@JsonData) = 1)
    BEGIN
        SET @Sothaydoi = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Sothaydoi'), ''), NULLIF(JSON_VALUE(@JsonData, '$.SoPhuLuc'), ''), @Sothaydoi);
        SET @Sohopdong = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Sohopdong'), ''), @Sohopdong);
        SET @Ngaythaydoi = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.Ngaythaydoi') AS DATETIME), TRY_CAST(JSON_VALUE(@JsonData, '$.NgayLap') AS DATETIME), @Ngaythaydoi);
        SET @Ghichu = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Ghichu'), ''), NULLIF(JSON_VALUE(@JsonData, '$.LyDoDieuChinh'), ''), @Ghichu);
        SET @Status = COALESCE(NULLIF(JSON_VALUE(@JsonData, '$.Status'), ''), NULLIF(JSON_VALUE(@JsonData, '$.TrangThai'), ''), @Status);
    END

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
                TRY_CAST(JSON_VALUE(@JsonData, '$.HanThanhToanDot2') AS DATETIME),
                TRY_CAST(JSON_VALUE(@JsonData, '$.HanThanhToanDot2TD') AS DATETIME),
                
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
                
                JSON_QUERY(@JsonData, '$.JsonBanTiec'),
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
                HanThanhToanDot2 = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.HanThanhToanDot2') AS DATETIME), HanThanhToanDot2),
                HanThanhToanDot2TD = COALESCE(TRY_CAST(JSON_VALUE(@JsonData, '$.HanThanhToanDot2TD') AS DATETIME), HanThanhToanDot2TD),
                
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
                
                JsonBanTiec = COALESCE(JSON_QUERY(@JsonData, '$.JsonBanTiec'), JsonBanTiec),
                JsonThucUong = COALESCE(JSON_QUERY(@JsonData, '$.JsonThucUong'), JsonThucUong),
                JsonDichVu = COALESCE(JSON_QUERY(@JsonData, '$.JsonDichVu'), JsonDichVu),
                JsonPhatSinh = COALESCE(JSON_QUERY(@JsonData, '$.JsonPhatSinh'), JsonPhatSinh)
            WHERE Sothaydoi = @Sothaydoi;
        END

        -- Đồng bộ thực đơn & dịch vụ con
        DECLARE @JsonBanTiec NVARCHAR(MAX) = JSON_QUERY(@JsonData, '$.JsonBanTiec');
        DECLARE @JsonThucUong NVARCHAR(MAX) = JSON_QUERY(@JsonData, '$.JsonThucUong');
        DECLARE @JsonDichVu NVARCHAR(MAX) = JSON_QUERY(@JsonData, '$.JsonDichVu');

        IF (@JsonBanTiec IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoithucdonman WHERE Sothaydoi = @Sothaydoi;
            DELETE FROM tbmk_Thaydoithucdonchay WHERE Sothaydoi = @Sothaydoi;

            INSERT INTO tbmk_Thaydoithucdonman (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonman, IsKhaividaugio)
            SELECT NEWID(), @Sothaydoi, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, @UserName, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%';

            INSERT INTO tbmk_Thaydoithucdonchay (UserAutoid, Sothaydoi, STTmon, Mahang, Dongia, UserCreate, DateCreate, Ghichuthucdonchay, IsKhaividaugio)
            SELECT NEWID(), @Sothaydoi, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, @UserName, @Now, NULL, 0
            FROM OPENJSON(@JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
            LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
            WHERE ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%';
        END

        IF (@JsonThucUong IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoithucuong WHERE Sothaydoi = @Sothaydoi;
            INSERT INTO tbmk_Thaydoithucuong (UserAutoid, Sothaydoi, Mahang, Dvt, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichuthucuong, Giamgia, UserCreate, DateCreate, STT)
            SELECT NEWID(), @Sothaydoi, j.Mahang, COALESCE(j.Dvt, j.DvtID), j.Soluong, j.Dongia, (j.Soluong * j.Dongia),
                   ISNULL(j.IsKhuyenmai, 0), j.Ghichuthucuong, ISNULL(j.Giamgia, 0), @UserName, @Now, ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonThucUong)
            WITH (Mahang VARCHAR(50), Dvt NVARCHAR(50), DvtID NVARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichuthucuong NVARCHAR(500), Giamgia DECIMAL(18,2)) j;
        END

        IF (@JsonDichVu IS NOT NULL)
        BEGIN
            DELETE FROM tbmk_Thaydoidichvu WHERE Sothaydoi = @Sothaydoi;
            INSERT INTO tbmk_Thaydoidichvu (UserAutoid, Sothaydoi, Mahang, Soluong, Dongia, Sotien, IsKhuyenmai, Ghichudichvu, UserCreate, DateCreate, STT)
            SELECT NEWID(), @Sothaydoi, j.Mahang, j.Soluong, j.Dongia, (j.Soluong * j.Dongia), ISNULL(j.IsKhuyenmai, 0), j.Ghichudichvu, @UserName, @Now, ROW_NUMBER() OVER(ORDER BY (SELECT NULL))
            FROM OPENJSON(@JsonDichVu)
            WITH (Mahang VARCHAR(50), Soluong DECIMAL(18,2), Dongia DECIMAL(18,2), IsKhuyenmai BIT, Ghichudichvu NVARCHAR(500)) j;
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
-- 5. THỦ TỤC XÓA MỀM PHỤ LỤC API_XoaThayDoi
-- =========================================================================
PRINT N'6. Đang tạo/cập nhật Procedure API_XoaThayDoi...';
GO

IF OBJECT_ID('[dbo].[API_XoaThayDoi]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[API_XoaThayDoi];
GO
CREATE PROCEDURE [dbo].[API_XoaThayDoi]
    @Ids NVARCHAR(MAX), 
    @UserName VARCHAR(50) = 'System'
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF (@Ids IS NULL OR @Ids = '')
        BEGIN
            SELECT -1 AS code, N'Thiếu danh sách số phụ lục (Ids)' AS msg;
            RETURN;
        END

        -- Không cho xóa phụ lục đã duyệt/đã ký
        IF EXISTS (
            SELECT 1 
            FROM tbmk_Thaydoi
            WHERE Sothaydoi IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','))
              AND (Status IN ('SIGNED', 'APPROVED') OR IsKetthuc = 1)
        )
        BEGIN
            SELECT -1 AS code, N'Lỗi: Tuyệt đối không được xóa phụ lục thay đổi đã duyệt hoặc đã ký nhận!' AS msg;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE tbmk_Thaydoi
        SET IsDeleted = 1,
            DeletedAt = GETDATE(),
            DeletedBy = ISNULL(@UserName, 'System')
        WHERE Sothaydoi IN (SELECT LTRIM(RTRIM(value)) FROM string_split(@Ids, ','));

        DECLARE @RowsAffected INT = @@ROWCOUNT;

        COMMIT TRANSACTION;

        IF @RowsAffected > 0
            SELECT 0 AS code, N'Xóa thành công (Soft Delete) ' + CAST(@RowsAffected AS VARCHAR) + N' phụ lục thay đổi.' AS msg;
        ELSE
            SELECT -1 AS code, N'Không tìm thấy phụ lục thay đổi phù hợp để xóa.' AS msg;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT -1 AS code, N'Lỗi xóa phụ lục thay đổi: ' + ERROR_MESSAGE() AS msg;
    END CATCH
END
GO


-- =========================================================================
-- 6. TẠO TRIGGER ĐỒNG BỘ TỰ ĐỘNG TRG_tbmk_Thaydoi_SyncToHopDong
-- =========================================================================
PRINT N'7. Đang tạo/cập nhật Trigger TRG_tbmk_Thaydoi_SyncToHopDong...';
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
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND ISNULL(hh.Tenhang, j.TenHang) NOT LIKE N'%chay%';

        -- Thêm chi tiết thực đơn chay
        INSERT INTO tbmk_Hopdongthucdonchay (UserAutoid, Sohopdong, STTmon, Mahang, Dongia, Ghichuthucdonchay, IsKhaividaugio, UserCreate, DateCreate)
        SELECT NEWID(), i.Sohopdong, ROW_NUMBER() OVER(PARTITION BY i.Sohopdong ORDER BY (SELECT NULL)), j.Mahang, j.Dongia, NULL, 0, i.UserCreate, GETDATE()
        FROM inserted i
        CROSS APPLY OPENJSON(i.JsonBanTiec) WITH (Mahang VARCHAR(50), TenHang NVARCHAR(255), Dongia DECIMAL(18,2)) j
        LEFT JOIN dmHanghoa hh ON j.Mahang = hh.Mahang
        WHERE i.JsonBanTiec IS NOT NULL AND i.JsonBanTiec <> '[]'
          AND ISNULL(hh.Tenhang, j.TenHang) LIKE N'%chay%';

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

        -- Cập nhật thông tin mới nhất sang tbmk_Hopdong
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
                
                i.QuyMoBanTuTD, i.QuyMoBanDenTD,
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
            h.Thoigianid = COALESCE(lc.ThoiGianIDTD, h.Thoigianid),
            h.Nhamngay = COALESCE(lc.NhamNgayTD, h.Nhamngay),
            h.Loaitiecid = COALESCE(lc.LoaiTiecIDTD, h.Loaitiecid),
            h.SobanManchinhthuc = COALESCE(lc.SobanManchinhthuc, h.SobanManchinhthuc),
            h.SobanManduphong = COALESCE(lc.SobanManduphong, h.SobanManduphong),
            h.Giabanman = COALESCE(lc.GiabanManTD, h.Giabanman),
            h.SobanChaychinhthuc = COALESCE(lc.SobanChaychinhthuc, h.SobanChaychinhthuc),
            h.SobanChayduphong = COALESCE(lc.SobanChayduphong, h.SobanChayduphong),
            h.Giabanchay = COALESCE(lc.GiabanChayTD, h.Giabanchay),
            h.Ghichu = COALESCE(lc.Ghichu, h.Ghichu),
            h.Tongtienbanman = COALESCE(lc.TongtienBanmanTD, h.Tongtienbanman),
            h.Tongtienbanchay = COALESCE(lc.TongtienBanchayTD, h.Tongtienbanchay),
            h.Tongtienthucuong = COALESCE(lc.Tongtienthucuong, h.Tongtienthucuong),
            h.Tongtiendichvu = COALESCE(lc.TongtienDichvuTD, h.Tongtiendichvu),
            h.Tongtienhopdong = COALESCE(lc.TongtienHopdongTD, h.Tongtienhopdong),
            h.Conlai = COALESCE(lc.ConLaiTD, h.Conlai),
            h.Soluongkhach = COALESCE(lc.SoluongKhachTD, h.Soluongkhach),
            h.Tongtienphanchay = COALESCE(lc.TongTienPhanChayTD, h.Tongtienphanchay),
            h.SoBanTang = COALESCE(lc.SoBanTang, h.SoBanTang),
            h.SoNguoiTrenBan = COALESCE(lc.SoNguoiTrenBanTD, h.SoNguoiTrenBan),
            h.TongSoBan = COALESCE(lc.TongSoBanTD, h.TongSoBan),
            h.SoBanTinhPhiPhucVu = COALESCE(lc.SoBanTinhPhiPhucVuTD, h.SoBanTinhPhiPhucVu),
            h.PhiPhucVu = COALESCE(lc.PhiPhucVuTD, h.PhiPhucVu),
            h.TongTienPhiPhucVu = COALESCE(lc.TongTienPhiPhucVuTD, h.TongTienPhiPhucVu),
            
            h.QuyMoBanTu = COALESCE(lc.QuyMoBanTuTD, h.QuyMoBanTu),
            h.QuyMoBanDen = COALESCE(lc.QuyMoBanDenTD, h.QuyMoBanDen),
            h.ThanhToanDot2SoTien = COALESCE(lc.ThanhToanDot2SoTienTD, h.ThanhToanDot2SoTien),
            h.HinhThucThanhToanDot2 = COALESCE(lc.HinhThucThanhToanDot2TD, h.HinhThucThanhToanDot2),
            h.HanThanhToanDot2 = COALESCE(lc.HanThanhToanDot2TD, h.HanThanhToanDot2),
            h.DichVuTinhPhiPhuLuc = COALESCE(lc.DichVuTinhPhiPhuLucTD, h.DichVuTinhPhiPhuLuc),
            h.ThoaThuanPhuLucKhac = COALESCE(lc.ThoaThuanPhuLucKhacTD, h.ThoaThuanPhuLucKhac),
            h.DanhSachChiPhi = COALESCE(lc.DanhSachChiPhiTD, h.DanhSachChiPhi),
            h.BenAChucVuDaiDien = COALESCE(lc.BenAChucVuDaiDienTD, h.BenAChucVuDaiDien),
            h.DonGiaBanTiec = COALESCE(lc.DonGiaBanTiecTD, h.DonGiaBanTiec),
            h.SoKhachTrenBan = COALESCE(lc.SoKhachTrenBanTD, h.SoKhachTrenBan)
        FROM tbmk_Hopdong h
        INNER JOIN LatestChanges lc ON h.Sohopdong = lc.Sohopdong
        WHERE lc.rn = 1;
    END
END
GO


-- =========================================================================
-- 6. THỦ TỤC TRUY XUẤT CHI TIẾT PHỤ LỤC API_PhuLucHopDong_Detail
-- =========================================================================
PRINT N'7. Đang tạo/cập nhật Procedure API_PhuLucHopDong_Detail...';
GO

IF OBJECT_ID('[dbo].[API_PhuLucHopDong_Detail]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[API_PhuLucHopDong_Detail];
GO
CREATE PROCEDURE [dbo].[API_PhuLucHopDong_Detail]
    @Keyword NVARCHAR(250),
    @Sothaydoi NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    IF @Sothaydoi = '' OR @Sothaydoi = 'NULL' SET @Sothaydoi = NULL;
    DECLARE @SearchStr VARCHAR(50) = COALESCE(@Sothaydoi, @Keyword);

    SELECT 
        -- Raw columns for Edit Form / Dynamic Form Engine
        pl.Sothaydoi,
        pl.Sohopdong,
        pl.Ngaythaydoi,
        pl.Ghichu,
        pl.Status,
        pl.JsonBanTiec,
        pl.JsonThucUong,
        pl.JsonDichVu,
        pl.JsonPhatSinh,
        pl.LanThayDoi,
        pl.NgayToChucTD,
        pl.ThoiGianIDTD,
        pl.NhamNgayTD,
        pl.LoaiTiecIDTD,
        pl.QuyMoBanTuTD,
        pl.QuyMoBanDenTD,
        pl.ThanhToanDot2SoTienTD,
        pl.HinhThucThanhToanDot2TD,
        pl.HanThanhToanDot2TD,
        pl.DichVuTinhPhiPhuLucTD,
        pl.ThoaThuanPhuLucKhacTD,
        pl.DanhSachChiPhiTD,
        pl.BenAChucVuDaiDienTD,
        pl.DonGiaBanTiecTD,
        pl.SoKhachTrenBanTD,
        pl.UserCreate,
        pl.DateCreate,
        pl.IsKetthuc,

        -- Mã chính (được format cho Word template)
        pl.Sothaydoi AS [SoPhuLuc],
        pl.Sohopdong AS [Sohopdong_Formatted],
        pl.LanThayDoi AS [LanDieuChinh],
        pl.Ghichu AS [NoiDungPhuLuc],
        
        -- Ngày lập Phụ lục
        RIGHT('0' + CAST(DAY(pl.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL],
        RIGHT('0' + CAST(MONTH(pl.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL],
        CAST(YEAR(pl.Ngaythaydoi) AS VARCHAR) AS [NamLapPL],

        -- Ngày lập Hợp đồng
        RIGHT('0' + CAST(DAY(hd.Ngayhopdong) AS VARCHAR), 2) AS [NgayLapHD],
        RIGHT('0' + CAST(MONTH(hd.Ngayhopdong) AS VARCHAR), 2) AS [ThangLapHD],
        CAST(YEAR(hd.Ngayhopdong) AS VARCHAR) AS [NamLapHD],

        -- Ngày tổ chức Dương lịch
        CONVERT(VARCHAR(10), ISNULL(pl.NgayToChucTD, hd.Ngaytochuc), 103) AS [NgayToChuc],
        RIGHT('0' + CAST(DAY(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [NgayToChucDay],
        RIGHT('0' + CAST(MONTH(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR), 2) AS [ThangToChuc],
        CAST(YEAR(ISNULL(pl.NgayToChucTD, hd.Ngaytochuc)) AS VARCHAR) AS [NamToChuc],

        -- Ngày tổ chức Âm lịch
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 
                THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), 1, CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) - 1)
            ELSE ISNULL(pl.NhamNgayTD, hd.Nhamngay)
        END AS [NgayToChucAmLich],
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 
                THEN CASE 
                    WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) > 0 
                        THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1, CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) - CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) - 1)
                    ELSE SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1, LEN(ISNULL(pl.NhamNgayTD, hd.Nhamngay)))
                END
            ELSE '...'
        END AS [ThangToChucAmLich],
        CASE 
            WHEN CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) > 0 AND CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) > 0
                THEN SUBSTRING(ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay), CHARINDEX('/', ISNULL(pl.NhamNgayTD, hd.Nhamngay)) + 1) + 1, LEN(ISNULL(pl.NhamNgayTD, hd.Nhamngay)))
            ELSE '...'
        END AS [NamToChucAmLich],

        -- Thiết lập sảnh & Giờ
        ISNULL((SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pl.Sohopdong), N'Chưa xác định') AS [TenSanhTiec],
        ISNULL(hd.GioDienRaSuKien, N'Chưa xác định') AS [TiecGioBatDau],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSuKien],

        -- Khách hàng (Bên B)
        kh.Tenkh AS [BenBTenDaiDien],
        kh.CMNDDaiDien AS [BenBCCCD],
        kh.Diachi AS [BenBDiaChi],
        kh.Dienthoai AS [BenBDienThoai],
        ISNULL(kh.Tenchure, '') + N' & ' + ISNULL(kh.Tencodau, '') AS [BenBTenChuTiec],

        -- Nhân viên Bên A
        ISNULL(nv.Tennv, hd.Manv) AS [BenANhanVienPhuTrach],
        nv.DIENTHOAI AS [BenASDTNhanVien],
        (SELECT TOP 1 CodeValue FROM [dbo].[SY_Setup] WHERE CodeID = 'HNChucVuNguoiDaiDien') AS [BenAChucVu],

        -- Quy mô bàn & Đơn giá
        ISNULL(pl.QuyMoBanTuTD, pl.QuyMoBanTu) AS [QuyMoBanTu],
        ISNULL(pl.QuyMoBanDenTD, pl.QuyMoBanDen) AS [QuyMoBanDen],
        ISNULL(pl.SoKhachTrenBanTD, pl.SoKhachTrenBan) AS [SoKhachTrenBan],
        FORMAT(ISNULL(pl.DonGiaBanTiecTD, pl.DonGiaBanTiec), 'N0', 'vi-VN') AS [DonGiaBanTiec],

        -- Bàn tiệc
        ISNULL(pl.SobanManchinhthuc, hd.SobanManchinhthuc) AS [SoBanManChinhThuc],
        ISNULL(pl.SobanManduphong, hd.SobanManduphong) AS [SoBanManDuPhong],
        ISNULL(hd.SoBanTang, 0) AS [BanTang],

        -- Đợt thanh toán 2
        ISNULL(pl.TenDotThanhToanTD, pl.TenDotThanhToan) AS [TenDotThanhToan],
        FORMAT(ISNULL(pl.ThanhToanDot2SoTienTD, pl.ThanhToanDot2SoTien), 'N0', 'vi-VN') AS [ThanhToanDot2SoTien],
        ISNULL(pl.HinhThucThanhToanDot2TD, pl.HinhThucThanhToanDot2) AS [HinhThucThanhToanDot2],
        CONVERT(VARCHAR(10), ISNULL(pl.HanThanhToanDot2TD, pl.HanThanhToanDot2), 103) AS [HanThanhToanDot2],

        -- Dịch vụ dạng văn bản
        ISNULL(pl.DichVuTinhPhiPhuLucTD, pl.DichVuTinhPhiPhuLuc) AS [DichVuTinhPhiPhuLuc],
        ISNULL(pl.ThoaThuanPhuLucKhacTD, pl.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
        ISNULL(pl.BenAChucVuDaiDienTD, pl.BenAChucVuDaiDien) AS [BenAChucVuDaiDien],

        -- Chi phí tổng cộng
        FORMAT(ISNULL(pl.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [TongGiaTriTamTinh],
        FORMAT(ISNULL(pl.TongtienHopdongTD, hd.Tongtienhopdong), 'N0', 'vi-VN') AS [MenuTongCong],

        -- VÒNG LẶP MENU TIỆC (Bơm array [{TenMonAn: ...}] từ JsonBanTiec)
        COALESCE(
            (
                SELECT 
                    JSON_VALUE(value, '$.TenHang') AS [TenMonAn]
                FROM OPENJSON(pl.JsonBanTiec)
                WHERE pl.JsonBanTiec IS NOT NULL
                FOR JSON PATH
            ),
            (
                SELECT 
                    h.Tenhang AS [TenMonAn]
                FROM dmHangHoa h
                WHERE h.GoiThucDonID = hd.GoiThucDonID AND ISNULL(h.IsNgungSuDung, 0) = 0
                FOR JSON PATH
            )
        ) AS [MenuTiec],

        -- VÒNG LẶP CHI PHÍ
        COALESCE(
            (
                SELECT 
                    JSON_VALUE(value, '$.NoiDung') AS [NoiDung],
                    JSON_VALUE(value, '$.DVT') AS [DVT],
                    JSON_VALUE(value, '$.SoLuong') AS [SoLuong],
                    JSON_VALUE(value, '$.DonGia') AS [DonGia],
                    JSON_VALUE(value, '$.ThanhTien') AS [ThanhTien]
                FROM OPENJSON(pl.DanhSachChiPhiTD)
                WHERE pl.DanhSachChiPhiTD IS NOT NULL AND pl.DanhSachChiPhiTD <> '' AND pl.DanhSachChiPhiTD <> '[]'
                FOR JSON PATH
            ),
            (
                SELECT 
                    items.NoiDung, items.DVT, items.SoLuong, items.DonGia, items.ThanhTien
                FROM (
                    SELECT 
                        JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                        ISNULL(JSON_VALUE(value, '$.DvtID'), N'Lần') AS [DVT],
                        ISNULL(JSON_VALUE(value, '$.Soluong'), N'0') AS [SoLuong],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                        1 AS SortOrder
                    FROM OPENJSON(pl.JsonDichVu)
                    WHERE pl.JsonDichVu IS NOT NULL AND pl.JsonDichVu <> '' AND pl.JsonDichVu <> '[]'
                    UNION ALL
                    SELECT 
                        JSON_VALUE(value, '$.TenHang') AS [NoiDung],
                        ISNULL(JSON_VALUE(value, '$.DvtID'), N'Két/Lon') AS [DVT],
                        ISNULL(JSON_VALUE(value, '$.Soluong'), N'0') AS [SoLuong],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [DonGia],
                        FORMAT(ISNULL(CAST(JSON_VALUE(value, '$.Soluong') AS DECIMAL(18,2)), 0) * ISNULL(CAST(JSON_VALUE(value, '$.Dongia') AS DECIMAL(18,2)), 0), 'N0', 'vi-VN') AS [ThanhTien],
                        2 AS SortOrder
                    FROM OPENJSON(pl.JsonThucUong)
                    WHERE pl.JsonThucUong IS NOT NULL AND pl.JsonThucUong <> '' AND pl.JsonThucUong <> '[]'
                ) items
                FOR JSON PATH
            ),
            '[]'
        ) AS [DanhSachChiPhi]

    FROM tbmk_Thaydoi pl
    INNER JOIN tbmk_Hopdong hd ON pl.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    LEFT JOIN dmNhanvienView nv ON hd.Manv = nv.Manv
    WHERE (pl.Sohopdong = @SearchStr OR pl.Sothaydoi = @SearchStr)
      AND ISNULL(pl.IsDeleted, 0) = 0;
END;
GO


-- =========================================================================
-- 7. ĐỒNG BỘ ĐỊNH TUYẾN GATEWAY (WA_API) VÀ METADATA GIAO DIỆN (SY_FrmLstTbl)
-- =========================================================================
PRINT N'8. Đang đồng bộ cấu hình Gateway WA_API và Metadata Giao diện...';
GO

-- 7.1. Đăng ký các bảng form trong SY_FrmLstTbl
IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmThayDoiBoSung')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('frmThayDoiBoSung', N'Phụ lục thay đổi bổ sung', 'v_DanhSachPhuLuc', 'tbmk_Thaydoi', 'Sothaydoi');
ELSE
    UPDATE SY_FrmLstTbl 
    SET TableName = 'v_DanhSachPhuLuc', SaveTableName = 'tbmk_Thaydoi', PrimaryKey = 'Sothaydoi' 
    WHERE FormID = 'frmThayDoiBoSung';

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'frmPhuLucHopDong')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('frmPhuLucHopDong', N'Danh sách phụ lục hợp đồng', 'v_DanhSachPhuLuc', 'tbmk_Thaydoi', 'Sothaydoi');
ELSE
    UPDATE SY_FrmLstTbl 
    SET TableName = 'v_DanhSachPhuLuc', SaveTableName = 'tbmk_Thaydoi', PrimaryKey = 'Sothaydoi' 
    WHERE FormID = 'frmPhuLucHopDong';

IF NOT EXISTS (SELECT 1 FROM SY_FrmLstTbl WHERE FormID = 'tbmk_Thaydoi')
    INSERT INTO SY_FrmLstTbl (FormID, CaptionVN, TableName, SaveTableName, PrimaryKey)
    VALUES ('tbmk_Thaydoi', N'Thay đổi hợp đồng', 'v_DanhSachPhuLuc', 'tbmk_Thaydoi', 'Sothaydoi');
ELSE
    UPDATE SY_FrmLstTbl 
    SET TableName = 'v_DanhSachPhuLuc', SaveTableName = 'tbmk_Thaydoi', PrimaryKey = 'Sothaydoi' 
    WHERE FormID = 'tbmk_Thaydoi';
GO

-- 7.2. Đồng bộ các định tuyến API trong WA_API
DELETE FROM WA_API WHERE List IN ('frmThayDoiBoSung', 'frmPhuLucHopDong', 'tbmk_Thaydoi') AND Func IN ('View', 'Save', 'Delete', 'GetDetails');
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'View', 'API_TruyVanDong', '@List=N''frmThayDoiBoSung'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}'''),
('frmPhuLucHopDong', 'View', 'API_TruyVanDong', '@List=N''frmPhuLucHopDong'', @Keyword=N''{Keyword}'', @SortColumn=N''{SortColumn}'', @SortDir=N''{SortDir}'', @Data=N''{JsonData}'''),
('tbmk_Thaydoi', 'View', 'API_Thaydoi', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}''');

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}'''),
('frmPhuLucHopDong', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}'''),
('tbmk_Thaydoi', 'Save', 'API_LuuThayDoi', '@Sothaydoi=N''{Sothaydoi}'', @Sohopdong=N''{Sohopdong}'', @Ngaythaydoi=N''{Ngaythaydoi}'', @Ghichu=N''{Ghichu}'', @Status=N''{Status}'', @UserName=N''{UserName}'', @JsonData=N''{JsonData}''');

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}'''),
('frmPhuLucHopDong', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}'''),
('tbmk_Thaydoi', 'Delete', 'API_XoaThayDoi', '@Ids=N''{Sothaydoi}'', @UserName=N''{UserName}''');

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
('frmThayDoiBoSung', 'GetDetails', 'API_PhuLucHopDong_Detail', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}'''),
('frmPhuLucHopDong', 'GetDetails', 'API_PhuLucHopDong_Detail', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}'''),
('tbmk_Thaydoi', 'GetDetails', 'API_PhuLucHopDong_Detail', '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}''');
GO

-- 7.3. Đồng bộ hóa trường tự động
EXEC API_DongBoTruongGiaoDien @FormName = 'frmThayDoiBoSung', @ObjectName = 'v_DanhSachPhuLuc';
EXEC API_DongBoTruongGiaoDien @FormName = 'frmPhuLucHopDong', @ObjectName = 'v_DanhSachPhuLuc';
EXEC API_DongBoTruongGiaoDien @FormName = 'tbmk_Thaydoi', @ObjectName = 'v_DanhSachPhuLuc';
GO

-- 7.4. Cấu hình nhãn Tiếng Việt & Hiển thị trên Form
PRINT N'9. Đang cập nhật nhãn hiển thị và định dạng trường...';
GO

DECLARE @Forms TABLE (FormName VARCHAR(50));
INSERT INTO @Forms VALUES ('frmThayDoiBoSung'), ('frmPhuLucHopDong'), ('tbmk_Thaydoi');

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0, ShowInGrid = 0
WHERE FormName IN (SELECT FormName FROM @Forms);

-- Bật hiển thị và cấu hình nhãn tiếng Việt chi tiết cho form
UPDATE ff
SET CaptionVN = N'Số Thay Đổi', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, FormPosition = '6', OrderNo = 1
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Sothaydoi';

UPDATE ff
SET CaptionVN = N'Số Hợp Đồng', FormatID = 'sr', DataSource = '/api/API_Gateway_Router?List=API_DanhSachHopDong&Func=View', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 1, FormPosition = '6', OrderNo = 2
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Sohopdong';

UPDATE ff
SET CaptionVN = N'Số Phụ Lục HĐ', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 3
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SoPhuLuc';

UPDATE ff
SET CaptionVN = N'Ngày Lập Phụ Lục', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 4
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'NgayLapPL';

UPDATE ff
SET CaptionVN = N'Ngày Tổ Chức Tiệc', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 5
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'NgayToChuc';

UPDATE ff
SET CaptionVN = N'Loại Hình Tiệc', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 6
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'LoaiTiecID';

UPDATE ff
SET CaptionVN = N'Ca Tổ Chức', FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 7
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'ThoiGianID';

UPDATE ff
SET CaptionVN = N'Quy Mô Bàn (Từ)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 8
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'QuyMoBanTu';

UPDATE ff
SET CaptionVN = N'Quy Mô Bàn (Đến)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 9
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'QuyMoBanDen';

UPDATE ff
SET CaptionVN = N'Đơn Giá Bàn Tiệc', FormatID = 'mn', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 10
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'DonGiaBanTiec';

UPDATE ff
SET CaptionVN = N'Số Khách / Bàn', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 11
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SoKhachTrenBan';

UPDATE ff
SET CaptionVN = N'Bàn Mặn (Chính Thức)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 12
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanManchinhthuc';

UPDATE ff
SET CaptionVN = N'Bàn Mặn (Dự Phòng)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 13
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanManduphong';

UPDATE ff
SET CaptionVN = N'Bàn Chay (Chính Thức)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 14
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanChaychinhthuc';

UPDATE ff
SET CaptionVN = N'Bàn Chay (Dự Phòng)', FormatID = 'n', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 15
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'SobanChayduphong';

UPDATE ff
SET CaptionVN = N'Số Tiền Đợt 2', FormatID = 'mn', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 17
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'ThanhToanDot2SoTien';

UPDATE ff
SET CaptionVN = N'Hình thức thanh toán Đợt 2', FormatID = 'sl', DataSource = N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 18
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'HinhThucThanhToanDot2';

UPDATE ff
SET CaptionVN = N'Hạn Thanh Toán Đợt 2', FormatID = 'dt', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 19
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'HanThanhToanDot2';

UPDATE ff
SET CaptionVN = N'Bên A - Chức Vụ Người Ký', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 0, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 20
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'BenAChucVuDaiDien';

UPDATE ff
SET CaptionVN = N'Trạng Thái Phụ Lục', FormatID = 'sl', DataSource = N'STATIC:DRAFT|Bản nháp,SIGNED|Đã ký (Đang chờ duyệt),APPROVED|Đã duyệt (Sync hợp đồng),CANCELLED|Đã hủy', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '6', OrderNo = 21
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Status';

UPDATE ff
SET CaptionVN = N'Nội dung thỏa thuận', FormatID = 't', ShowInAdd = 1, ShowInEdit = 1, ShowInGrid = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormPosition = '12', OrderNo = 22
FROM SY_FormatFields ff INNER JOIN @Forms f ON ff.FormName = f.FormName WHERE ff.FieldName = 'Ghichu';

-- Đảm bảo định nghĩa các trường Plugin (Json) hoạt động hoàn hảo
UPDATE SY_FormatFields 
SET ShowInAdd = 1, ShowInEdit = 1, FormatID = 't', FormPosition = '6' 
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
GO


-- =========================================================================
-- 8. ĐĂNG KÝ MENU HỆ THỐNG VÀ ĐỒNG BỘ PHÂN QUYỀN
-- =========================================================================
PRINT N'10. Đang đồng bộ Menu hệ thống WA_Menu...';
GO

IF EXISTS (SELECT 1 FROM WA_Menu WHERE FormName = 'frmThayDoiBoSung' OR URLPara = '#/thaydoibosung' OR MenuID = 'frmThayDoiBoSung')
BEGIN
    UPDATE WA_Menu 
    SET VN = N'Thay đổi bổ sung', 
        FormName = 'frmThayDoiBoSung',
        URLPara = '#/thaydoibosung',
        IconClass = 'edit_note',
        isDisable = 0
    WHERE FormName = 'frmThayDoiBoSung' OR URLPara = '#/thaydoibosung' OR MenuID = 'frmThayDoiBoSung';
END
ELSE
BEGIN
    INSERT INTO WA_Menu (MenuID, Parent, VN, FormName, URLPara, IconClass, isDisable) 
    VALUES ('frmThayDoiBoSung', '', N'Thay đổi bổ sung', 'frmThayDoiBoSung', '#/thaydoibosung', 'edit_note', 0);
END
GO

-- Đồng bộ quyền truy cập nhóm người dùng
PRINT N'11. Đang đồng bộ quyền truy cập nhóm người dùng...';
GO
EXEC API_DongBoQuyenTruyCap;
GO


-- =========================================================================
-- 9. ĐĂNG KÝ BẢN ĐỒ FILE MẪU WORD (TEMPLATE MAPPING)
-- =========================================================================
PRINT N'12. Đang cấu hình liên kết Mẫu in Word (de_nghi_thay_doi.docx)...';
GO

DELETE FROM tbmk_LoaitiecAddfile WHERE FormName IN ('frmThayDoiBoSung', 'frmPhuLucHopDong');
GO

INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu) VALUES 
('frmThayDoiBoSung', 'BLT000001', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000002', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000003', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000004', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmThayDoiBoSung', 'BLT000005', N'de_nghi_thay_doi.docx', N'Đề nghị thay đổi bổ sung tiệc'),
('frmPhuLucHopDong', 'BLT000001', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000002', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000003', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000004', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng'),
('frmPhuLucHopDong', 'BLT000005', N'phu_luc_hop_dong.docx', N'Phụ lục Hợp đồng');
GO

PRINT N'=== HOÀN THÀNH CẬP NHẬT TOÀN DIỆN PHÂN HỆ THAY ĐỔI BỔ SUNG (ALL-IN-ONE) ===';
GO
