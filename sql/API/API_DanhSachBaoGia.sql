USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('API_DanhSachBaoGia', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachBaoGia;
GO

CREATE PROCEDURE [dbo].[API_DanhSachBaoGia]
    @Keyword    NVARCHAR(250) = NULL,
    @Sohopdong  VARCHAR(50)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Keyword = '' SET @Keyword = NULL;
    IF @Sohopdong = '' SET @Sohopdong = NULL;

    SELECT
        h.Sohopdong AS [Id],
        h.Sohopdong,
        h.Sobiennhan,
        h.Makh,

        CASE
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [KhachHang],
        CASE
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [TenKhachHang],

        h.Ngaytochuc AS [NgayToChuc],
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS [NgayToChucFormat],
        ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
        CASE
            WHEN h.IsHuy = 1 THEN N'Đã Hủy'
            WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
            ELSE N'Đang xử lý'
        END AS [TrangThai],

        STUFF((
            SELECT N', ' + s.Tensanhtiec
            FROM tbmk_Hopdongsanhtiec hs
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
            FOR XML PATH(''), TYPE
        ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS [SanhDat],

        ISNULL((SELECT TOP 1 lt.Tenloaitiec FROM dmLoaihinhtiec lt WHERE lt.Loaitiecid = h.Loaitiecid), N'') AS [LoaiHinhSuKien],

        -- ===== Placeholder báo giá (Section 16) =====
        CONVERT(VARCHAR(10), ISNULL(h.Ngayhopdong, GETDATE()), 103) AS [NgayBaoGia],
        RIGHT('0' + CAST(DAY(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR), 2) AS [NgayBaoGiaDay],
        RIGHT('0' + CAST(MONTH(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR), 2) AS [ThangBaoGia],
        CAST(YEAR(ISNULL(h.Ngayhopdong, GETDATE())) AS VARCHAR) AS [NamBaoGia],

        FORMAT(ISNULL(h.Tongtienhopdong, 0), 'N0', 'vi-VN') AS [TongCongTamTinh],
        [dbo].[fn_DocTienBangChu](ISNULL(h.Tongtienhopdong, 0)) AS [TongCongTamTinhBangChu],
        ISNULL(NULLIF(h.Ghichu, ''), N'') AS [LuuYChung],

        -- Bên A
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenATenCongTy') AS [BenATenCongTy],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenADiaChi') AS [BenADiaChi],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenASDT') AS [BenASDT],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail') AS [BenAEmail],
        (SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID = 'BenAEmail') AS [BenAEmailNhanVien],
        (SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv) AS [BenANhanVienPhuTrach],
        (SELECT TOP 1 nv.DIENTHOAI FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR nv.Manv = h.Manv) AS [BenASDTNhanVien],

        -- Bên B
        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [BenBDienThoai],
        ISNULL(k.Diachi, N'...') AS [BenBDiaChi],
        ISNULL(NULLIF(h.TenCtyHoaDon, ''), ISNULL(k.Tenkh, N'')) AS [HDTenCty],

        -- Ghi chú theo sảnh (multiline {@GhiChuSanh1..3})
        ISNULL((
            SELECT TOP 1 NULLIF(hs.Ghichuct, '')
            FROM tbmk_Hopdongsanhtiec hs
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
        ), N'') AS [GhiChuSanh1],
        ISNULL((
            SELECT Ghichuct FROM (
                SELECT hs.Ghichuct, ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS rn
                FROM tbmk_Hopdongsanhtiec hs
                WHERE hs.Sohopdong = h.Sohopdong
            ) x WHERE x.rn = 2
        ), N'') AS [GhiChuSanh2],
        ISNULL((
            SELECT Ghichuct FROM (
                SELECT hs.Ghichuct, ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS rn
                FROM tbmk_Hopdongsanhtiec hs
                WHERE hs.Sohopdong = h.Sohopdong
            ) x WHERE x.rn = 3
        ), N'') AS [GhiChuSanh3],

        -- {#DanhSachDichVu}
        dbo.fn_DOCX_DanhSachDichVu(h.Sohopdong) AS [DanhSachDichVu],

        -- {#DanhSachKhuVuc} — khu vực / sảnh tiệc
        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid) AS [STT],
                s.Tensanhtiec AS [TenKhuVuc],
                s.Tensanhtiec AS [TenSanh],
                ISNULL(CAST(s.SLBanMin AS NVARCHAR), N'0') AS [SoBanMin],
                ISNULL(CAST(s.SLBanMax AS NVARCHAR), N'0') AS [SoBanMax],
                ISNULL(CAST(s.SLBanMin * 10 AS NVARCHAR), N'0') AS [SucchuaMin],
                ISNULL(CAST(s.SLBanMax * 10 AS NVARCHAR), N'0') AS [SucchuaMax],
                ISNULL(hs.Ghichuct, N'') AS [GhiChu]
            FROM tbmk_Hopdongsanhtiec hs
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
            WHERE hs.Sohopdong = h.Sohopdong
            ORDER BY hs.IsSanhchinh DESC, hs.Sanhtiecid
            FOR JSON PATH
        ) AS [DanhSachKhuVuc],

        -- {#DanhSachThamKhao} — menu + thức uống + DV tham khảo
        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY src.sort_order, src.TenHang) AS [STT],
                src.TenHang AS [DienGiai],
                N'' AS [ChiTiet],
                N'' AS [DVT],
                N'' AS [SoLuong],
                FORMAT(ISNULL(src.Dongia, 0), 'N0', 'vi-VN') AS [DonGia],
                N'' AS [UuDai],
                FORMAT(ISNULL(src.Dongia, 0), 'N0', 'vi-VN') AS [ThanhTien],
                1 AS [IsData]
            FROM (
                SELECT ISNULL(hh.Tenhang, td.Mahang) AS TenHang, td.Dongia, 1 AS sort_order
                FROM tbmk_Hopdongthucdonman td
                LEFT JOIN dmHanghoa hh ON td.Mahang = hh.Mahang
                WHERE td.Sohopdong = h.Sohopdong
                UNION ALL
                SELECT ISNULL(hh.Tenhang, tu.Mahang), tu.Dongia, 2
                FROM tbmk_Hopdongthucuong tu
                LEFT JOIN dmHanghoa hh ON tu.Mahang = hh.Mahang
                WHERE tu.Sohopdong = h.Sohopdong
                UNION ALL
                SELECT ISNULL(hh.Tenhang, dv.Mahang), dv.Dongia, 3
                FROM tbmk_Hopdongdichvu dv
                LEFT JOIN dmHanghoa hh ON dv.Mahang = hh.Mahang
                WHERE dv.Sohopdong = h.Sohopdong
            ) src
            FOR JSON PATH
        ) AS [DanhSachThamKhao],

        CAST(NULL AS VARCHAR(100)) AS [BoTri]
        -- , CAST(NULL AS INT) AS [IsHeader]

    FROM tbmk_Hopdong h
    LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
    WHERE ISNULL(h.IsDeleted, 0) = 0
      AND (@Sohopdong IS NULL OR h.Sohopdong = @Sohopdong)
      AND (@Keyword IS NULL OR
           h.Sohopdong LIKE '%' + @Keyword + '%' OR
           k.Tenkh LIKE N'%' + @Keyword + '%' OR
           k.Tenchure LIKE N'%' + @Keyword + '%' OR
           k.Tencodau LIKE N'%' + @Keyword + '%')
    ORDER BY h.Ngaytochuc DESC, h.Sohopdong DESC;
END
GO
