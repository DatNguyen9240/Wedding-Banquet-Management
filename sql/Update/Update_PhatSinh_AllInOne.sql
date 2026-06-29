USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- UPDATE_PHATSINH_ALLINONE.SQL
-- Cập nhật Database cho tính năng PHÁT SINH TRONG TIỆC
-- =========================================================================

PRINT N'=== BẮT ĐẦU TRIỂN KHAI MODULE PHÁT SINH ===';
GO

-- =========================================================================
-- 1. BỔ SUNG CỘT BanPhatSinh VÀO tbmk_Hopdong
-- =========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tbmk_Hopdong') AND name = 'BanPhatSinh')
BEGIN
    ALTER TABLE tbmk_Hopdong ADD BanPhatSinh INT NULL DEFAULT 0;
    PRINT N'  + Đã thêm cột BanPhatSinh vào tbmk_Hopdong';
END
GO

-- =========================================================================
-- 2. TẠO VIEW v_DanhSachPhatSinh
-- =========================================================================
PRINT N'2. Đang tạo/cập nhật View v_DanhSachPhatSinh...';
GO

IF OBJECT_ID('[dbo].[v_DanhSachPhatSinh]', 'V') IS NOT NULL
    DROP VIEW [dbo].[v_DanhSachPhatSinh];
GO

CREATE VIEW [dbo].[v_DanhSachPhatSinh] AS
SELECT 
    hd.Sohopdong AS [Id],
    hd.Sohopdong AS [Sohopdong],
    
    -- Khách hàng & Người phụ trách
    kh.Tenkh AS [BenBTenDaiDien],
    kh.Dienthoai AS [BenBDienThoai],
    N'Khách hàng' AS [BenBChucVu],
    nv.Tennv AS [BenANhanVienPhuTrach],
    
    -- Thông tin tiệc
    hd.Loaitiecid AS [LoaiHinhSuKien],
    RIGHT('0' + CAST(DAY(hd.Ngaytochuc) AS VARCHAR), 2) + '/' + 
    RIGHT('0' + CAST(MONTH(hd.Ngaytochuc) AS VARCHAR), 2) + '/' + 
    CAST(YEAR(hd.Ngaytochuc) AS VARCHAR) AS [NgayToChuc],
    FORMAT(hd.Ngaytochuc, 'HH:mm') AS [TiecGioBatDau],
    ISNULL(FORMAT(hd.NgayTraSanhDV, 'HH:mm'), '') AS [TiecGioKetThuc],
    (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = hd.Sohopdong ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS [TiecSanhTiec],
    
    -- Số lượng bàn
    ISNULL(hd.SobanChaychinhthuc, 0) AS [BanChay],
    ISNULL(hd.SobanManchinhthuc, 0) + ISNULL(hd.SobanChaychinhthuc, 0) AS [SoBanChinhThuc],
    ISNULL(hd.SobanManduphong, 0) + ISNULL(hd.SobanChayduphong, 0) AS [SoBanDuPhong],
    ISNULL(hd.SoBanTang, 0) AS [BanTang],
    ISNULL(hd.BanPhatSinh, 0) AS [BanPhatSinh],
    (ISNULL(hd.SobanManchinhthuc, 0) + ISNULL(hd.SobanChaychinhthuc, 0) + ISNULL(hd.SobanManduphong, 0) + ISNULL(hd.SobanChayduphong, 0) + ISNULL(hd.BanPhatSinh, 0)) AS [TongSoBan],
    
    -- Thực đơn bàn gốc (Món mặn + Món chay) từ hợp đồng để hiển thị đối chiếu
    ISNULL(STUFF((
        SELECT CHAR(10) + hh.Tenhang
        FROM tbmk_Hopdongthucdonman td
        LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
        WHERE td.Sohopdong = hd.Sohopdong
        ORDER BY td.STTmon
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '') AS [MonMan],
        
    ISNULL(STUFF((
        SELECT CHAR(10) + hh.Tenhang
        FROM tbmk_Hopdongthucdonchay td
        LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
        WHERE td.Sohopdong = hd.Sohopdong
        ORDER BY td.STTmon
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '') AS [MonChay],

    ISNULL(STUFF((
        SELECT CHAR(10) + ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), hh.Tenhang) 
               + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END
        FROM tbmk_HopdongPhatSinh ptps
        LEFT JOIN dmHanghoa hh ON ptps.Mahang = hh.Mahang
        WHERE ptps.Sohopdong = hd.Sohopdong
        ORDER BY ptps.DateCreate
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, ''), '') AS [MonPhatSinh],

    -- Mảng Món Phát Sinh (Lấy từ bảng tbmk_HopdongPhatSinh)
    (
        SELECT 
            ROW_NUMBER() OVER(ORDER BY ptps.DateCreate) AS [STT],
            ptps.Mahang AS [Mahang],
            ptps.Mahang AS [MaMon],
            ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), ISNULL(hh.Tenhang, ptps.Mahang)) 
                + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END AS [MonPhatSinh],
            ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), ISNULL(hh.Tenhang, ptps.Mahang)) 
                + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END AS [MonMan], -- Fallback
            ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), ISNULL(hh.Tenhang, ptps.Mahang)) 
                + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END AS [MonChay], -- Fallback
            ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), ISNULL(hh.Tenhang, ptps.Mahang)) 
                + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END AS [TenHang], -- Fallback
            ISNULL(NULLIF(ptps.GhiChuPhatSinh, ''), ISNULL(hh.Tenhang, ptps.Mahang)) 
                + CASE WHEN ISNULL(ptps.Soluong, 0) > 0 THEN N' (SL: ' + CAST(CAST(ptps.Soluong AS FLOAT) AS NVARCHAR(50)) + N')' ELSE N'' END AS [TenMon], -- Fallback
            ptps.GhiChuPhatSinh AS [GhiChuPhatSinh],
            ptps.Soluong AS [SoLuong],
            ptps.Dongia AS [DonGia],
            ptps.Sotien AS [ThanhTien]
        FROM tbmk_HopdongPhatSinh ptps
        LEFT JOIN dmHanghoa hh ON ptps.Mahang = hh.Mahang
        WHERE ptps.Sohopdong = hd.Sohopdong
        FOR JSON PATH
    ) AS [MenuPhatSinh]

FROM 
    dbo.tbmk_Hopdong hd
LEFT JOIN dbo.dmkhachhang kh ON hd.Makh = kh.Makh
LEFT JOIN dbo.dmNhanvienView nv ON nv.NHANVIENID = hd.Manv OR nv.Manv = hd.Manv;
GO

-- =========================================================================
-- 3. TẠO STORED PROCEDURE API_DanhSachPhatSinh
-- =========================================================================
PRINT N'3. Đang tạo SP API_DanhSachPhatSinh...';
GO

IF OBJECT_ID('dbo.API_DanhSachPhatSinh', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_DanhSachPhatSinh;
GO

CREATE PROCEDURE [dbo].[API_DanhSachPhatSinh]
    @Keyword NVARCHAR(MAX) = N'',
    @Limit INT = 50,
    @Page INT = 1,
    @Where NVARCHAR(MAX) = N'',
    @OrderBy NVARCHAR(MAX) = N'NgayToChuc DESC'
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @Limit <= 0 SET @Limit = 50;
    IF @Page <= 0 SET @Page = 1;
    DECLARE @Offset INT = (@Page - 1) * @Limit;

    DECLARE @SQL NVARCHAR(MAX) = N'';
    
    DECLARE @BaseQuery NVARCHAR(MAX) = N'
        FROM [dbo].[v_DanhSachPhatSinh]
        WHERE 1=1
    ';

    IF LEN(ISNULL(@Keyword, '')) > 0
    BEGIN
        SET @BaseQuery = @BaseQuery + N' AND (
            Sohopdong LIKE N''%'' + @Kw + N''%'' OR 
            BenBTenDaiDien LIKE N''%'' + @Kw + N''%'' OR
            BenBDienThoai LIKE N''%'' + @Kw + N''%''
        )';
    END
    
    IF LEN(ISNULL(@Where, '')) > 0
    BEGIN
        SET @BaseQuery = @BaseQuery + N' AND (' + @Where + N')';
    END

    SET @SQL = N'
        SELECT *
        ' + @BaseQuery + N'
        ORDER BY ' + @OrderBy + N'
        OFFSET @Off ROWS FETCH NEXT @Lim ROWS ONLY;
    ';

    EXEC sp_executesql 
        @SQL, 
        N'@Kw NVARCHAR(MAX), @Off INT, @Lim INT', 
        @Kw = @Keyword, @Off = @Offset, @Lim = @Limit;
END;
GO

-- =========================================================================
-- 4. ĐĂNG KÝ VÀO WA_API
-- =========================================================================
PRINT N'4. Đang đăng ký API_DanhSachPhatSinh vào WA_API...';
GO

DELETE FROM WA_API WHERE List = 'API_DanhSachPhatSinh';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES
('API_DanhSachPhatSinh', 'View', 'API_DanhSachPhatSinh', '@Keyword=N''{Keyword}'', @Limit=N''{Limit}'', @Page=N''{Page}'', @Where=N''{Where}'', @OrderBy=N''{OrderBy}''');
GO

PRINT N'=== HOÀN TẤT TRIỂN KHAI MODULE PHÁT SINH ===';
GO