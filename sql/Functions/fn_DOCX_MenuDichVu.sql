USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- fn_DOCX_* — Build JSON cho docxtemplater từ chi tiết Hợp đồng
-- Nguồn: tbmk_Hopdongthucdonman / chay / thucuong / dichvu
-- Dùng chung cho: BEO, Hợp đồng, Phụ lục, Báo giá, BBNT/Quyết toán
-- =========================================================================

IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachMenu', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_DanhSachMenu;
GO
CREATE FUNCTION dbo.fn_DOCX_DanhSachMenu(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);

    SET @result = (
        SELECT [TenMenu], [DanhSachMon], [GhiChu]
        FROM (
            SELECT
                N'THỰC ĐƠN MẶN'
                    + CASE WHEN ISNULL(h.Giabanman, 0) > 0
                        THEN N' (' + FORMAT(h.Giabanman, 'N0', 'vi-VN') + N' VNĐ/bàn)'
                        ELSE N'' END AS [TenMenu],
                JSON_QUERY((
                    SELECT
                        ROW_NUMBER() OVER (ORDER BY td.STTmon, td.Mahang) AS [STT],
                        ISNULL(hh.Tenhang, td.Mahang) AS [TenMon]
                    FROM tbmk_Hopdongthucdonman td
                    LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                    WHERE td.Sohopdong = @Sohopdong
                    FOR JSON PATH
                )) AS [DanhSachMon],
                ISNULL((
                    SELECT TOP 1 NULLIF(td.Ghichuthucdonman, '')
                    FROM tbmk_Hopdongthucdonman td
                    WHERE td.Sohopdong = @Sohopdong AND NULLIF(td.Ghichuthucdonman, '') IS NOT NULL
                ), N'') AS [GhiChu],
                1 AS [sort_order]
            FROM tbmk_Hopdong h
            WHERE h.Sohopdong = @Sohopdong
              AND EXISTS (SELECT 1 FROM tbmk_Hopdongthucdonman x WHERE x.Sohopdong = @Sohopdong)

            UNION ALL

            SELECT
                N'THỰC ĐƠN CHAY'
                    + CASE WHEN ISNULL(h.Giabanchay, 0) > 0
                        THEN N' (' + FORMAT(h.Giabanchay, 'N0', 'vi-VN') + N' VNĐ/bàn)'
                        ELSE N'' END,
                JSON_QUERY((
                    SELECT
                        ROW_NUMBER() OVER (ORDER BY td.STTmon, td.Mahang) AS [STT],
                        ISNULL(hh.Tenhang, td.Mahang) AS [TenMon]
                    FROM tbmk_Hopdongthucdonchay td
                    LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                    WHERE td.Sohopdong = @Sohopdong
                    FOR JSON PATH
                )),
                ISNULL((
                    SELECT TOP 1 NULLIF(td.Ghichuthucdonchay, '')
                    FROM tbmk_Hopdongthucdonchay td
                    WHERE td.Sohopdong = @Sohopdong AND NULLIF(td.Ghichuthucdonchay, '') IS NOT NULL
                ), N''),
                2
            FROM tbmk_Hopdong h
            WHERE h.Sohopdong = @Sohopdong
              AND EXISTS (SELECT 1 FROM tbmk_Hopdongthucdonchay x WHERE x.Sohopdong = @Sohopdong)
        ) menus
        ORDER BY [sort_order]
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachThucUong', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_DanhSachThucUong;
GO
CREATE FUNCTION dbo.fn_DOCX_DanhSachThucUong(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);

    IF NOT EXISTS (SELECT 1 FROM tbmk_Hopdongthucuong WHERE Sohopdong = @Sohopdong)
        RETURN '[]';

    SET @result = (
        SELECT
            N'THỨC UỐNG' AS [TenThucUong],
            JSON_QUERY((
                SELECT
                    ROW_NUMBER() OVER (ORDER BY tu.STT, tu.Mahang) AS [STT],
                    ISNULL(hh.Tenhang, tu.Mahang) AS [TenMonUong]
                FROM tbmk_Hopdongthucuong tu
                LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
                WHERE tu.Sohopdong = @Sohopdong
                FOR JSON PATH
            )) AS [DanhSachMonUong],
            ISNULL((
                SELECT TOP 1 NULLIF(tu.Ghichuthucuong, '')
                FROM tbmk_Hopdongthucuong tu
                WHERE tu.Sohopdong = @Sohopdong AND NULLIF(tu.Ghichuthucuong, '') IS NOT NULL
            ), N'') AS [GhiChu]
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_MenuTiec', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_MenuTiec;
GO
CREATE FUNCTION dbo.fn_DOCX_MenuTiec(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);

    SET @result = (
        SELECT
            ISNULL(hh.Tenhang, td.Mahang) AS [TenMonAn],
            FORMAT(ISNULL(td.Dongia, 0), 'N0', 'vi-VN') AS [DonGia]
        FROM tbmk_Hopdongthucdonman td
        LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
        WHERE td.Sohopdong = @Sohopdong
        ORDER BY td.STTmon, td.Mahang
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_MenuTongCong', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_MenuTongCong;
GO
CREATE FUNCTION dbo.fn_DOCX_MenuTongCong(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @tong DECIMAL(18, 2);

    SELECT @tong = ISNULL(SUM(ISNULL(td.Dongia, 0)), 0)
    FROM tbmk_Hopdongthucdonman td
    WHERE td.Sohopdong = @Sohopdong;

    IF @tong = 0
    BEGIN
        SELECT @tong = ISNULL(h.Giabanman, 0)
        FROM tbmk_Hopdong h
        WHERE h.Sohopdong = @Sohopdong;
    END

    RETURN FORMAT(ISNULL(@tong, 0), 'N0', 'vi-VN') + N' VNĐ';
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_DichVuTinhPhi', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_DichVuTinhPhi;
GO
CREATE FUNCTION dbo.fn_DOCX_DichVuTinhPhi(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);

    SET @result = (
        SELECT
            ROW_NUMBER() OVER (ORDER BY hd.STT, hd.Mahang) AS [STT],
            ISNULL(hh.Tenhang, hd.Mahang) AS [TenDichVu],
            CAST(FORMAT(ISNULL(hd.Soluong, 0), 'G29') AS NVARCHAR) 
                + CASE WHEN NULLIF(hh.DVTID, '') IS NOT NULL THEN N' ' + hh.DVTID ELSE N'' END AS [SoLuongText],
            FORMAT(ISNULL(hd.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
            FORMAT(ISNULL(hd.Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien],
            ISNULL(hd.Ghichudichvu, N'') AS [GhiChu]
        FROM tbmk_Hopdongdichvu hd
        LEFT JOIN dmHanghoa hh ON hd.Mahang = hh.Mahang
        WHERE hd.Sohopdong = @Sohopdong
        ORDER BY hd.STT, hd.Mahang
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachNgay', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_DanhSachNgay;
GO
CREATE FUNCTION dbo.fn_DOCX_DanhSachNgay(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);
    DECLARE @Ngaytochuc DATETIME;
    DECLARE @Thoigianid VARCHAR(20);
    DECLARE @KhungGio NVARCHAR(100);

    SELECT
        @Ngaytochuc = h.Ngaytochuc,
        @Thoigianid = h.Thoigianid
    FROM tbmk_Hopdong h
    WHERE h.Sohopdong = @Sohopdong;

    SET @KhungGio = ISNULL((
        SELECT TOP 1 tg.Thoigian
        FROM dmThoigian tg
        WHERE tg.Thoigianid = @Thoigianid
    ), ISNULL(@Thoigianid, N'...'));

    SET @result = (
        SELECT
            N'Ngày '
                + RIGHT('0' + CAST(DAY(@Ngaytochuc) AS VARCHAR), 2)
                + '/' + RIGHT('0' + CAST(MONTH(@Ngaytochuc) AS VARCHAR), 2)
                + CASE WHEN YEAR(@Ngaytochuc) > 1900
                    THEN '/' + CAST(YEAR(@Ngaytochuc) AS VARCHAR)
                    ELSE N'' END AS [TenNhomNgay],
            JSON_QUERY((
                SELECT
                    ROW_NUMBER() OVER (ORDER BY hd.STT, hd.Mahang) AS [STT],
                    ISNULL(hh.Tenhang, hd.Mahang) AS [TenDichVu],
                    @KhungGio AS [KhungGio],
                    ISNULL(hh.DVTID, N'') AS [DVT],
                    FORMAT(ISNULL(hd.Soluong, 0), 'G29') AS [SoLuong],
                    FORMAT(ISNULL(hd.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
                    N'' AS [UuDai],
                    FORMAT(ISNULL(hd.Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien]
                FROM tbmk_Hopdongdichvu hd
                LEFT JOIN dmHanghoa hh ON hd.Mahang = hh.Mahang
                WHERE hd.Sohopdong = @Sohopdong
                ORDER BY hd.STT, hd.Mahang
                FOR JSON PATH
            )) AS [DanhSachDV]
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

IF OBJECT_ID(N'dbo.fn_DOCX_DanhSachDichVu', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_DOCX_DanhSachDichVu;
GO
CREATE FUNCTION dbo.fn_DOCX_DanhSachDichVu(@Sohopdong VARCHAR(50))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX);

    SET @result = (
        SELECT
            ROW_NUMBER() OVER (ORDER BY hd.STT, hd.Mahang) AS [STT],
            ISNULL(hh.Tenhang, hd.Mahang) AS [DienGiai],
            N'' AS [ChiTiet],
            ISNULL(hh.DVTID, N'') AS [DVT],
            FORMAT(ISNULL(hd.Soluong, 0), 'G29') AS [SoLuong],
            FORMAT(ISNULL(hd.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
            N'' AS [UuDai],
            FORMAT(ISNULL(hd.Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien],
            1 AS [IsData]
        FROM tbmk_Hopdongdichvu hd
        LEFT JOIN dmHanghoa hh ON hd.Mahang = hh.Mahang
        WHERE hd.Sohopdong = @Sohopdong
        ORDER BY hd.STT, hd.Mahang
        FOR JSON PATH
    );

    RETURN ISNULL(@result, '[]');
END
GO

PRINT N'Đã tạo/cập nhật bộ hàm fn_DOCX_* cho menu & dịch vụ.';
GO
