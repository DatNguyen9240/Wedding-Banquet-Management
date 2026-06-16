USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =========================================================================
-- 1. CHUẨN HÓA CẤU TRÚC BẢNG (SOFT DELETE COLUMNS CHO TBMK_PHIEUTHU)
-- =========================================================================
PRINT N'Đang chuẩn hóa cấu trúc bảng Quyết toán...';
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Phieuthu]') AND name = 'IsDeleted')
BEGIN
    ALTER TABLE tbmk_Phieuthu ADD IsDeleted BIT DEFAULT 0;
    ALTER TABLE tbmk_Phieuthu ADD DeletedBy VARCHAR(50) NULL;
    ALTER TABLE tbmk_Phieuthu ADD DeletedAt DATETIME NULL;
    PRINT N'Đã thêm cột Soft Delete cho bảng tbmk_Phieuthu';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Phieuthu]') AND name = 'Status')
BEGIN
    ALTER TABLE tbmk_Phieuthu ADD Status VARCHAR(20) DEFAULT 'DRAFT';
    PRINT N'Đã thêm cột Status cho bảng tbmk_Phieuthu';
END
GO

-- =========================================================================
-- 2. CẬP NHẬT STORED PROCEDURE LẤY DANH SÁCH QUYẾT TOÁN (ĐỘNG TỪ BẢNG CHI TIẾT)
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_DanhSachQuyetToan...';
GO

IF OBJECT_ID('API_DanhSachQuyetToan', 'P') IS NOT NULL
    DROP PROCEDURE API_DanhSachQuyetToan;
GO

CREATE PROCEDURE [dbo].[API_DanhSachQuyetToan]
    @Keyword NVARCHAR(100) = NULL,
    @DocumentID VARCHAR(50) = NULL,
    @Sohopdong VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        -- Cột gốc cho Grid và tính tương thích của hệ thống
        pt.DocumentID,
        pt.DocumentDate,
        pt.Sohopdong,
        hd.Tentiec,
        kh.Tenkh,
        pt.Nguoinop,
        pt.Manv,
        pt.TongtienHoaDon,
        pt.Tongtiencoc,
        pt.Thanhtoan,
        pt.Conlai,
        pt.IsKetthuc,
        pt.IsHoaDon,
        pt.IsXacNhanKeToan,
        pt.Ghichu,

        -- Cột dùng cho in ấn (placeholders)
        kh.Tenkh AS [KhachHang],
        ISNULL((SELECT TOP 1 Tenloaitiec FROM dmLoaihinhtiec WHERE Loaitiecid = hd.Loaitiecid), N'TIỆC CƯỚI') AS [LoaiHinhSK],
        ISNULL((SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.Manv = pt.Manv), pt.Manv) AS [NVKD],
        
        CAST(ISNULL(hd.TongSoBan, 0) AS VARCHAR) + N' BÀN (' + CAST(ISNULL(hd.TongSoBan * 10, 0) AS VARCHAR) + N' KHÁCH)' AS [SoLuongKhach],
        (SELECT TOP 1 s.Tensanhtiec FROM tbmk_Hopdongsanhtiec hs INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid WHERE hs.Sohopdong = pt.Sohopdong) AS [SanhTiec],
        CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) AS [NgayToChuc],
        ISNULL(hd.GioDienRaSuKien, N'Chưa xác định') AS [ThoiGian],

        RIGHT('0' + CAST(DAY(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [NgayQuyetToan],
        RIGHT('0' + CAST(MONTH(ISNULL(pt.DocumentDate, GETDATE())) AS VARCHAR), 2) AS [ThangQuyetToan],
        YEAR(ISNULL(pt.DocumentDate, GETDATE())) AS [NamQuyetToan],

        -- Bảng tổng hợp & tính toán chi tiết
        CASE WHEN c1.Cong1Val = 0 THEN N'-' ELSE FORMAT(c1.Cong1Val, 'N0', 'vi-VN') END AS [Cong1],
        CASE WHEN c2.Cong2Val = 0 THEN N'-' ELSE FORMAT(c2.Cong2Val, 'N0', 'vi-VN') END AS [Cong2],
        CASE WHEN (c1.Cong1Val + c2.Cong2Val) = 0 THEN N'-' ELSE FORMAT((c1.Cong1Val + c2.Cong2Val), 'N0', 'vi-VN') END AS [TongCong12],
        CASE WHEN ISNULL(pt.PhiPhucVu, 0) = 0 THEN N'-' ELSE FORMAT(pt.PhiPhucVu, 'N0', 'vi-VN') END AS [PhiPhucVu],
        CASE WHEN (c1.Cong1Val + c2.Cong2Val + ISNULL(pt.PhiPhucVu, 0)) = 0 THEN N'-' ELSE FORMAT((c1.Cong1Val + c2.Cong2Val + ISNULL(pt.PhiPhucVu, 0)), 'N0', 'vi-VN') END AS [TongCongChuaVAT],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 8 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT8],
        CASE WHEN (CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END) = 0 THEN N'-' ELSE FORMAT(CASE WHEN pt.PTThueVAT = 10 THEN ISNULL(pt.TienThueVAT, 0) ELSE 0 END, 'N0', 'vi-VN') END AS [VAT10],
        -- Alias khớp placeholder Word template (Danh_Sach_Truong_Tong_Hop.md - Section 13)
        CASE WHEN ISNULL(pt.TongtienHoaDon, 0) = 0 THEN N'-' ELSE FORMAT(pt.TongtienHoaDon, 'N0', 'vi-VN') END AS [TongTien],
        CASE WHEN ISNULL(pt.TongtienHoaDon, 0) = 0 THEN N'-' ELSE FORMAT(pt.TongtienHoaDon, 'N0', 'vi-VN') END AS [TongGiaTriQuyetToan],
        [dbo].[fn_DocTienBangChu](ISNULL(pt.TongtienHoaDon, 0)) AS [TongGiaTriQuyetToanBangChu],
        CASE WHEN ISNULL(pt.Tongtiencoc, 0) = 0 THEN N'-' ELSE FORMAT(pt.Tongtiencoc, 'N0', 'vi-VN') END AS [TruCoc],
        CASE WHEN ISNULL(pt.Tongtiencoc, 0) = 0 THEN N'-' ELSE FORMAT(pt.Tongtiencoc, 'N0', 'vi-VN') END AS [SoTienDaDatCoc],
        CONVERT(VARCHAR(10), hd.Ngayhopdong, 103) AS [NgayThanhToanDatCoc], -- Ngày khách đặt cọc ban đầu (từ HĐ)
        CASE WHEN ISNULL(pt.Conlai, 0) = 0 THEN N'-' ELSE FORMAT(pt.Conlai, 'N0', 'vi-VN') END AS [ThanhToanConLai],
        CASE WHEN ISNULL(pt.Conlai, 0) = 0 THEN N'-' ELSE FORMAT(pt.Conlai, 'N0', 'vi-VN') END AS [SoTienConLai],
        [dbo].[fn_DocTienBangChu](ISNULL(pt.Conlai, 0)) AS [SoTienConLaiBangChu],

        -- DỮ LIỆU MẢNG JSON CHO BÀN TIỆC & DỊCH VỤ CHI TIẾT
        (
            SELECT 
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[DienGiai], N'') AS [DienGiai],
                ISNULL(t.[DVT], N'') AS [DVT],
                ISNULL(CAST(t.[SoLuong] AS NVARCHAR(50)), N'') AS [SoLuong],
                ISNULL(t.[DonGia], N'') AS [DonGia],
                ISNULL(t.[ThanhTien], N'-') AS [ThanhTien]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order, [DienGiai]) AS RowNum,
                    [DienGiai], [DVT], [SoLuong], [DonGia], [ThanhTien]
                FROM (
                    -- A. NẾU ĐÃ CÓ CHI TIẾT LƯU TRONG BẢNG CON
                    SELECT 
                        TenHang AS [DienGiai], 
                        DvtID AS [DVT], 
                        ISNULL(Soluong, 0) AS [SoLuong], 
                        FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(ThanhTien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(ThanhTien, 0) AS val, 
                        1 AS sort_order
                    FROM tbmk_Phieuthubantiec
                    WHERE SPthu = pt.SPthu
                    
                    UNION ALL
                    
                    SELECT 
                        (SELECT TOP 1 Tenhang FROM dmHanghoa WHERE Mahang = tu.Mahang) AS [DienGiai], 
                        N'Két/Lon' AS [DVT], 
                        ISNULL(Soluong, 0) AS [SoLuong], 
                        FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(Sotien, 0) AS val, 
                        2 AS sort_order
                    FROM tbmk_Phieuthuthucuong tu
                    WHERE SPthu = pt.SPthu
                    
                    UNION ALL
                    
                    SELECT 
                        (SELECT TOP 1 Tenhang FROM dmHanghoa WHERE Mahang = dv.Mahang) AS [DienGiai], 
                        N'Lần' AS [DVT], 
                        ISNULL(Soluong, 0) AS [SoLuong], 
                        FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(Sotien, 0) AS val, 
                        3 AS sort_order
                    FROM tbmk_PhieuthuDichvu dv
                    WHERE SPthu = pt.SPthu

                    UNION ALL

                    -- B. NẾU CHƯA CÓ CHI TIẾT TRONG BẢNG CON (DỰ PHÒNG TỪ HỢP ĐỒNG GỐC)
                    SELECT N'Bàn tiệc mặn' AS [DienGiai], N'Bàn' AS [DVT], ISNULL(hd.SobanManchinhthuc, 0) AS [SoLuong], FORMAT(ISNULL(hd.Giabanman, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienbanman, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienbanman, 0) AS val, 1 AS sort_order
                    WHERE ISNULL(hd.Tongtienbanman, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Bàn tiệc chay' AS [DienGiai], N'Bàn' AS [DVT], ISNULL(hd.SobanChaychinhthuc, 0) AS [SoLuong], FORMAT(ISNULL(hd.Giabanchay, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienbanchay, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienbanchay, 0) AS val, 2 AS sort_order
                    WHERE ISNULL(hd.SobanChaychinhthuc, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Thức uống' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtienthucuong, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtienthucuong, 0) AS val, 3 AS sort_order
                    WHERE ISNULL(hd.Tongtienthucuong, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthuthucuong WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Dịch vụ cưới & Trang trí' AS [DienGiai], N'Gói' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(hd.Tongtiendichvu, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(hd.Tongtiendichvu, 0) AS val, 4 AS sort_order
                    WHERE ISNULL(hd.Tongtiendichvu, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_PhieuthuDichvu WHERE SPthu = pt.SPthu)
                ) sub
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DanhSachDichVu],

        -- {#DanhSachNgay}{#DanhSachDV} — timeline từ HĐ gốc (BBNT / báo giá)
        dbo.fn_DOCX_DanhSachNgay(pt.Sohopdong)   AS [DanhSachNgay],
        dbo.fn_DOCX_DichVuTinhPhi(pt.Sohopdong)  AS [DichVuTinhPhi],

        -- DỮ LIỆU MẢNG JSON CHO DỊCH VỤ PHÁT SINH
        (
            SELECT 
                COALESCE(t.RowNum, n.n) AS [STT],
                ISNULL(t.[DienGiai], N'') AS [DienGiai],
                ISNULL(t.[DVT], N'') AS [DVT],
                ISNULL(CAST(t.[SoLuong] AS NVARCHAR(50)), N'') AS [SoLuong],
                ISNULL(t.[DonGia], N'') AS [DonGia],
                ISNULL(t.[ThanhTien], N'-') AS [ThanhTien]
            FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) n
            FULL OUTER JOIN (
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY sort_order) AS RowNum,
                    [DienGiai], [DVT], [SoLuong], [DonGia], [ThanhTien]
                FROM (
                    -- A. LẤY CHI TIẾT TỪ BẢNG PHÁT SINH NẾU CÓ DỮ LIỆU
                    SELECT 
                        ISNULL(GhiChuPhatSinh, N'Phát sinh thực tế') AS [DienGiai], 
                        N'Lần' AS [DVT], 
                        ISNULL(Soluong, 1) AS [SoLuong], 
                        FORMAT(ISNULL(Dongia, 0), 'N0', 'vi-VN') AS [DonGia], 
                        FORMAT(ISNULL(Sotien, 0), 'N0', 'vi-VN') AS [ThanhTien], 
                        ISNULL(Sotien, 0) AS val, 
                        1 AS sort_order
                    FROM tbmk_Phieuthuphatsinh
                    WHERE SPthu = pt.SPthu

                    UNION ALL

                    -- B. NẾU CHƯA CÓ CHI TIẾT, DỰ PHÒNG TỪ BẢNG MẸ
                    SELECT N'Chi phí phát sinh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.Sotienphatsinh, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.Sotienphatsinh, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.Sotienphatsinh, 0) AS val, 1 AS sort_order
                    WHERE ISNULL(pt.Sotienphatsinh, 0) > 0 AND NOT EXISTS (SELECT 1 FROM tbmk_Phieuthuphatsinh WHERE SPthu = pt.SPthu)
                    
                    UNION ALL
                    
                    SELECT N'Phí bù sảnh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuSanh, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuSanh, 0) AS val, 2 AS sort_order
                    WHERE ISNULL(pt.PhiBuSanh, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù bàn tăng' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuBanTang, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuBanTang, 0) AS val, 3 AS sort_order
                    WHERE ISNULL(pt.PhiBuBanTang, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù trang trí sảnh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuTTS, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuTTS, 0) AS val, 4 AS sort_order
                    WHERE ISNULL(pt.PhiBuTTS, 0) > 0
                    
                    UNION ALL
                    
                    SELECT N'Phí bù nghi thức lễ' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [DonGia], FORMAT(ISNULL(pt.PhiBuNTL, 0), 'N0', 'vi-VN') AS [ThanhTien], ISNULL(pt.PhiBuNTL, 0) AS val, 5 AS sort_order
                    WHERE ISNULL(pt.PhiBuNTL, 0) > 0
                ) sub
                WHERE val > 0
            ) t ON n.n = t.RowNum
            ORDER BY [STT]
            FOR JSON PATH
        ) AS [DichVuPhatSinh]

    FROM tbmk_Phieuthu pt
    LEFT JOIN tbmk_Hopdong hd ON pt.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    CROSS APPLY (
        SELECT COALESCE(
            NULLIF(
                ISNULL((SELECT SUM(ThanhTien) FROM tbmk_Phieuthubantiec WHERE SPthu = pt.SPthu), 0) +
                ISNULL((SELECT SUM(Sotien - Sotiengiamgia) FROM tbmk_Phieuthuthucuong WHERE SPthu = pt.SPthu), 0) +
                ISNULL((SELECT SUM(Sotien - Sotiengiamgia) FROM tbmk_PhieuthuDichvu WHERE SPthu = pt.SPthu), 0),
                0
            ),
            (ISNULL(hd.Tongtienbanman, 0) + ISNULL(hd.Tongtienbanchay, 0) + ISNULL(hd.Tongtienthucuong, 0) + ISNULL(hd.Tongtiendichvu, 0))
        ) AS Cong1Val
    ) c1
    CROSS APPLY (
        SELECT (ISNULL(pt.Sotienphatsinh, 0) + ISNULL(pt.PhiBuSanh, 0) + ISNULL(pt.PhiBuBanTang, 0) + ISNULL(pt.PhiBuTTS, 0) + ISNULL(pt.PhiBuNTL, 0)) AS Cong2Val
    ) c2
    WHERE 
        ISNULL(pt.IsDeleted, 0) = 0
        AND (@DocumentID IS NULL OR @DocumentID = '' OR pt.DocumentID = @DocumentID)
        AND (@Sohopdong IS NULL OR @Sohopdong = '' OR pt.Sohopdong = @Sohopdong)
        AND (@Keyword IS NULL OR @Keyword = ''
             OR pt.DocumentID LIKE '%' + @Keyword + '%'
             OR pt.Sohopdong LIKE '%' + @Keyword + '%'
             OR pt.Nguoinop LIKE N'%' + @Keyword + '%'
             OR kh.Tenkh LIKE N'%' + @Keyword + '%')
    ORDER BY pt.DocumentDate DESC;
END
GO

-- =========================================================================
-- 3. CẬP NHẬT STORED PROCEDURE LƯU QUYẾT TOÁN (ĐÃ TỐI ƯU HÓA LƯU JSON CHI TIẾT)
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_LuuQuyenToan...';
GO

IF OBJECT_ID('API_LuuQuyenToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LuuQuyenToan;
GO

CREATE PROCEDURE [dbo].[API_LuuQuyenToan]
    @DocumentID VARCHAR(50) = NULL,
    @DocumentDate DATETIME = NULL,
    @Sohopdong VARCHAR(50) = NULL,
    @Nguoinop NVARCHAR(100) = NULL,
    @Tongtiencoc DECIMAL(18,2) = 0,
    @TongtienHoaDon DECIMAL(18,2) = 0,
    @Thanhtoan DECIMAL(18,2) = 0,
    @Conlai DECIMAL(18,2) = 0,
    @IsKetthuc BIT = 0,
    @Ghichu NVARCHAR(500) = NULL,
    @User VARCHAR(50) = NULL,
    @BanPhatSinh INT = 0,

    -- Extra fields for settlement totals
    @Sotienphatsinh DECIMAL(18,2) = 0,
    @PhiBuSanh DECIMAL(18,2) = 0,
    @PhiBuBantang DECIMAL(18,2) = 0,
    @PhiBuTTS DECIMAL(18,2) = 0,
    @PhiBuNTL DECIMAL(18,2) = 0,
    @PhiPhucVu DECIMAL(18,2) = 0,
    @PTThueVAT DECIMAL(18,2) = 0,
    @TienThueVAT DECIMAL(18,2) = 0,

    -- Các tham số JSON chi tiết gửi từ Frontend
    @JsonBanTiec NVARCHAR(MAX) = NULL,  -- Danh sách chi tiết món ăn/bàn tiệc
    @JsonThucUong NVARCHAR(MAX) = NULL, -- Danh sách chi tiết đồ uống tiêu dùng thực tế
    @JsonDichVu NVARCHAR(MAX) = NULL,   -- Danh sách chi tiết dịch vụ đi kèm
    @JsonPhatSinh NVARCHAR(MAX) = NULL  -- Danh sách chi tiết các phát sinh khác
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SPthu VARCHAR(20);
    DECLARE @Now DATETIME = GETDATE();

    -- Chuẩn hóa các tham số JSON chi tiết
    IF @JsonBanTiec IS NOT NULL AND LTRIM(RTRIM(@JsonBanTiec)) = '' SET @JsonBanTiec = NULL;
    IF @JsonBanTiec IS NOT NULL AND LEFT(LTRIM(@JsonBanTiec), 1) <> '[' SET @JsonBanTiec = '[' + @JsonBanTiec + ']';

    IF @JsonThucUong IS NOT NULL AND LTRIM(RTRIM(@JsonThucUong)) = '' SET @JsonThucUong = NULL;
    IF @JsonThucUong IS NOT NULL AND LEFT(LTRIM(@JsonThucUong), 1) <> '[' SET @JsonThucUong = '[' + @JsonThucUong + ']';

    IF @JsonDichVu IS NOT NULL AND LTRIM(RTRIM(@JsonDichVu)) = '' SET @JsonDichVu = NULL;
    IF @JsonDichVu IS NOT NULL AND LEFT(LTRIM(@JsonDichVu), 1) <> '[' SET @JsonDichVu = '[' + @JsonDichVu + ']';

    IF @JsonPhatSinh IS NOT NULL AND LTRIM(RTRIM(@JsonPhatSinh)) = '' SET @JsonPhatSinh = NULL;
    IF @JsonPhatSinh IS NOT NULL AND LEFT(LTRIM(@JsonPhatSinh), 1) <> '[' SET @JsonPhatSinh = '[' + @JsonPhatSinh + ']';

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Lưu hoặc cập nhật bảng mẹ (tbmk_Phieuthu)
        IF @DocumentID IS NULL OR @DocumentID = ''
        BEGIN
            SET @DocumentID = 'QT' + FORMAT(@Now, 'yyMMddHHmmss');
            SET @SPthu = @DocumentID;
            
            INSERT INTO tbmk_Phieuthu (
                DocumentID, DocumentDate, SPthu, Ngaythu, Sohopdong, Nguoinop, Manv, 
                Tongtiencoc, TongtienHoaDon, Thanhtoan, Conlai, IsKetthuc, Ghichu, 
                Sotienphatsinh, PhiBuSanh, PhiBuBantang, PhiBuTTS, PhiBuNTL, PhiPhucVu, PTThueVAT, TienThueVAT,
                UserCreate, DateCreate
            )
            VALUES (
                @DocumentID, ISNULL(@DocumentDate, @Now), @SPthu, ISNULL(@DocumentDate, @Now), @Sohopdong, @Nguoinop, @User,
                @Tongtiencoc, @TongtienHoaDon, @Thanhtoan, @Conlai, @IsKetthuc, @Ghichu,
                @Sotienphatsinh, @PhiBuSanh, @PhiBuBantang, @PhiBuTTS, @PhiBuNTL, @PhiPhucVu, @PTThueVAT, @TienThueVAT,
                @User, @Now
            );
        END
        ELSE
        BEGIN
            SET @SPthu = @DocumentID;
            
            UPDATE tbmk_Phieuthu
            SET DocumentDate = ISNULL(@DocumentDate, DocumentDate),
                Ngaythu = ISNULL(@DocumentDate, Ngaythu),
                Sohopdong = ISNULL(@Sohopdong, Sohopdong),
                Nguoinop = ISNULL(@Nguoinop, Nguoinop),
                Tongtiencoc = ISNULL(@Tongtiencoc, Tongtiencoc),
                TongtienHoaDon = ISNULL(@TongtienHoaDon, TongtienHoaDon),
                Thanhtoan = ISNULL(@Thanhtoan, Thanhtoan),
                Conlai = ISNULL(@Conlai, Conlai),
                IsKetthuc = ISNULL(@IsKetthuc, IsKetthuc),
                Ghichu = ISNULL(@Ghichu, Ghichu),
                Sotienphatsinh = ISNULL(@Sotienphatsinh, Sotienphatsinh),
                PhiBuSanh = ISNULL(@PhiBuSanh, PhiBuSanh),
                PhiBuBantang = ISNULL(@PhiBuBantang, PhiBuBantang),
                PhiBuTTS = ISNULL(@PhiBuTTS, PhiBuTTS),
                PhiBuNTL = ISNULL(@PhiBuNTL, PhiBuNTL),
                PhiPhucVu = ISNULL(@PhiPhucVu, PhiPhucVu),
                PTThueVAT = ISNULL(@PTThueVAT, PTThueVAT),
                TienThueVAT = ISNULL(@TienThueVAT, TienThueVAT),
                UserUpdate = @User,
                DateUpdate = @Now
            WHERE DocumentID = @DocumentID;
        END

        -- 2. Lưu chi tiết món ăn/bàn tiệc (tbmk_Phieuthubantiec)
        IF @JsonBanTiec IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthubantiec WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthubantiec (
                UserAutoid, DocumentID, SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, ThanhTien, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @DocumentID, @SPthu, Mahang, TenHang, DvtID, Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), (Soluong * Dongia - ISNULL(Sotiengiamgia, 0)), @User, @Now
            FROM OPENJSON(@JsonBanTiec)
            WITH (
                Mahang VARCHAR(30),
                TenHang NVARCHAR(460),
                DvtID NVARCHAR(100),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 3. Lưu chi tiết thức uống (tbmk_Phieuthuthucuong)
        IF @JsonThucUong IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuthucuong WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuthucuong (
                UserAutoid, SPthu, Mahang, IsKhuyenmai, Soluong, Dongia, Sotien, 
                Giamgia, Sotiengiamgia, Soluongle, Dongiale, Ghichuthucuong, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, ISNULL(IsKhuyenmai, 0), Soluong, Dongia, (Soluong * Dongia),
                ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), ISNULL(Soluongle, 0), ISNULL(Dongiale, 0), Ghichuthucuong, @User, @Now
            FROM OPENJSON(@JsonThucUong)
            WITH (
                Mahang VARCHAR(30),
                IsKhuyenmai BIT,
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2),
                Soluongle DECIMAL(18,2),
                Dongiale DECIMAL(18,2),
                Ghichuthucuong NVARCHAR(500)
            );
        END

        -- 4. Lưu chi tiết dịch vụ (tbmk_PhieuthuDichvu)
        IF @JsonDichVu IS NOT NULL
        BEGIN
            DELETE FROM tbmk_PhieuthuDichvu WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_PhieuthuDichvu (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, Giamgia, Sotiengiamgia, UserCreate, DateCreate
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), ISNULL(Giamgia, 0), ISNULL(Sotiengiamgia, 0), @User, @Now
            FROM OPENJSON(@JsonDichVu)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                Giamgia DECIMAL(18,2),
                Sotiengiamgia DECIMAL(18,2)
            );
        END

        -- 5. Lưu chi tiết phát sinh (tbmk_Phieuthuphatsinh)
        IF @JsonPhatSinh IS NOT NULL
        BEGIN
            DELETE FROM tbmk_Phieuthuphatsinh WHERE SPthu = @SPthu;
            
            INSERT INTO tbmk_Phieuthuphatsinh (
                UserAutoid, SPthu, Mahang, Soluong, Dongia, Sotien, UserCreate, DateCreate, GhiChuPhatSinh
            )
            SELECT 
                NEWID(), @SPthu, Mahang, Soluong, Dongia, (Soluong * Dongia), @User, @Now, GhiChuPhatSinh
            FROM OPENJSON(@JsonPhatSinh)
            WITH (
                Mahang VARCHAR(30),
                Soluong DECIMAL(18,2),
                Dongia DECIMAL(18,2),
                GhiChuPhatSinh NVARCHAR(500)
            );
        END

        IF @IsKetthuc = 1 AND @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET IsKetthuc = 1, Conlai = @Conlai, BanPhatSinh = @BanPhatSinh
            WHERE Sohopdong = @Sohopdong;
        END
        ELSE IF @Sohopdong IS NOT NULL
        BEGIN
            UPDATE tbmk_Hopdong 
            SET BanPhatSinh = @BanPhatSinh
            WHERE Sohopdong = @Sohopdong;
        END

        COMMIT TRANSACTION;

        -- Trả về dòng vừa lưu để Frontend đồng bộ lại giao diện
        SELECT * FROM tbmk_Phieuthu WHERE DocumentID = @DocumentID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- =========================================================================
-- 4. TẠO CÁC STORED PROCEDURE CHI TIẾT & THAY ĐỔI
-- =========================================================================
PRINT N'Đang cập nhật Stored Procedure API_LayChiTietQuyetToan...';
GO

IF OBJECT_ID('API_LayChiTietQuyetToan', 'P') IS NOT NULL
    DROP PROCEDURE API_LayChiTietQuyetToan;
GO

CREATE PROCEDURE [dbo].[API_LayChiTietQuyetToan]
    @Sohopdong VARCHAR(50) = NULL,
    @Sothaydoi VARCHAR(50) = NULL,
    @DocumentID VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GoiThucDonID VARCHAR(50) = NULL;
    DECLARE @SothaydoiToUse VARCHAR(50) = @Sothaydoi;
    DECLARE @SoBanChinhThuc DECIMAL(18,2) = 0;
    DECLARE @Giabanman DECIMAL(18,2) = 0;
    DECLARE @Giabanchay DECIMAL(18,2) = 0;
    DECLARE @Tongtienbanman DECIMAL(18,2) = 0;
    DECLARE @Tongtienbanchay DECIMAL(18,2) = 0;
    DECLARE @Tongtienthucuong DECIMAL(18,2) = 0;
    DECLARE @Tongtiendichvu DECIMAL(18,2) = 0;

    -- 1. TRƯỜNG HỢP 1: ĐÃ CÓ PHIẾU QUYẾT TOÁN (Xem lại hoặc sửa)
    IF @DocumentID IS NOT NULL AND @DocumentID <> '' AND EXISTS (SELECT 1 FROM tbmk_Phieuthu WHERE DocumentID = @DocumentID)
    BEGIN
        SELECT 
            (
                SELECT 
                    ptb.Mahang,
                    ptb.TenHang,
                    ptb.DvtID,
                    ptb.Soluong,
                    ptb.Dongia,
                    ptb.Sotien,
                    ptb.Giamgia,
                    ptb.Sotiengiamgia,
                    ptb.ThanhTien
                FROM tbmk_Phieuthubantiec ptb
                WHERE ptb.SPthu = @DocumentID
                FOR JSON PATH
            ) AS [JsonBanTiec],

            (
                SELECT 
                    ptu.Mahang,
                    h.Tenhang AS [TenHang],
                    h.DVTID AS [DvtID],
                    ptu.IsKhuyenmai,
                    ptu.Soluong,
                    ptu.Dongia,
                    ptu.Sotien,
                    ptu.Giamgia,
                    ptu.Sotiengiamgia,
                    ptu.Soluongle,
                    ptu.Dongiale,
                    ptu.Ghichuthucuong
                FROM tbmk_Phieuthuthucuong ptu
                LEFT JOIN dmHangHoa h ON ptu.Mahang = h.Mahang
                WHERE ptu.SPthu = @DocumentID
                FOR JSON PATH
            ) AS [JsonThucUong],

            (
                SELECT 
                    ptd.Mahang,
                    h.Tenhang AS [TenHang],
                    h.DVTID AS [DvtID],
                    ptd.Soluong,
                    ptd.Dongia,
                    ptd.Sotien,
                    ptd.Giamgia,
                    ptd.Sotiengiamgia,
                    (ptd.Sotien - ptd.Sotiengiamgia) AS [ThanhTien]
                FROM tbmk_PhieuthuDichvu ptd
                LEFT JOIN dmHangHoa h ON ptd.Mahang = h.Mahang
                WHERE ptd.SPthu = @DocumentID
                FOR JSON PATH
            ) AS [JsonDichVu],

            (
                SELECT 
                    ptp.Mahang,
                    h.Tenhang AS [TenHang],
                    h.DVTID AS [DvtID],
                    ptp.Soluong,
                    ptp.Dongia,
                    ptp.Sotien,
                    ptp.GhiChuPhatSinh
                FROM tbmk_Phieuthuphatsinh ptp
                LEFT JOIN dmHangHoa h ON ptp.Mahang = h.Mahang
                WHERE ptp.SPthu = @DocumentID
                FOR JSON PATH
            ) AS [JsonPhatSinh];
            
        RETURN;
    END

    -- 2. TRƯỜNG HỢP 2: TẠO MỚI QUYẾT TOÁN (Chưa có DocumentID hoặc chưa lưu)
    IF (@SothaydoiToUse IS NULL OR @SothaydoiToUse = '') AND @Sohopdong IS NOT NULL
    BEGIN
        SELECT TOP 1 @SothaydoiToUse = Sothaydoi 
        FROM tbmk_Thaydoi 
        WHERE Sohopdong = @Sohopdong AND ISNULL(IsDeleted, 0) = 0 AND Status = 'SIGNED'
        ORDER BY LanThayDoi DESC, DateCreate DESC;
    END

    IF @SothaydoiToUse IS NOT NULL AND @SothaydoiToUse <> ''
    BEGIN
        SELECT 
            @GoiThucDonID = GoiThucDonIDTD,
            @SoBanChinhThuc = ISNULL(TongSoBanTD, TongSoBan),
            @Giabanman = ISNULL(GiabanManTD, Giabanman),
            @Giabanchay = ISNULL(GiabanChayTD, Giabanchay),
            @Tongtienbanman = ISNULL(TongtienBanmanTD, Tongtienbanman),
            @Tongtienbanchay = ISNULL(TongtienBanchayTD, Tongtienbanchay),
            @Tongtienthucuong = ISNULL(Tongtienthucuong, 0),
            @Tongtiendichvu = ISNULL(TongtienDichvuTD, Tongtiendichvu)
        FROM tbmk_Thaydoi
        WHERE Sothaydoi = @SothaydoiToUse;
    END
    ELSE IF @Sohopdong IS NOT NULL
    BEGIN
        SELECT 
            @GoiThucDonID = GoiThucDonID,
            @SoBanChinhThuc = ISNULL(TongSoBan, 0),
            @Giabanman = ISNULL(Giabanman, 0),
            @Giabanchay = ISNULL(Giabanchay, 0),
            @Tongtienbanman = ISNULL(Tongtienbanman, 0),
            @Tongtienbanchay = ISNULL(Tongtienbanchay, 0),
            @Tongtienthucuong = ISNULL(Tongtienthucuong, 0),
            @Tongtiendichvu = ISNULL(Tongtiendichvu, 0)
        FROM tbmk_Hopdong
        WHERE Sohopdong = @Sohopdong;
    END

    SELECT 
        CAST('[]' AS NVARCHAR(MAX)) AS [JsonBanTiec],

        (
            SELECT 
                h.Mahang,
                h.Tenhang AS [TenHang],
                h.DVTID AS [DvtID],
                0 AS [IsKhuyenmai],
                0 AS [Soluong],
                ISNULL((SELECT TOP 1 dg.Dongia FROM dmHanghoadg dg WHERE dg.Mahang = h.Mahang ORDER BY dg.Ngay DESC), 0) AS [Dongia],
                0 AS [Sotien],
                0 AS [Giamgia],
                0 AS [Sotiengiamgia],
                0 AS [Soluongle],
                0 AS [Dongiale],
                N'' AS [Ghichuthucuong]
            FROM dmHangHoa h
            WHERE h.Nhomhangid = 'THUCUONG' 
              AND ISNULL(h.IsNgungSuDung, 0) = 0
            FOR JSON PATH
        ) AS [JsonThucUong],

        CAST('[]' AS NVARCHAR(MAX)) AS [JsonDichVu],

        CAST('[]' AS NVARCHAR(MAX)) AS [JsonPhatSinh];
END;
GO

PRINT N'Đang cập nhật Stored Procedure API_Thaydoi...';
GO

IF OBJECT_ID('API_tbmk_Thaydoi_View', 'P') IS NOT NULL
    DROP PROCEDURE API_tbmk_Thaydoi_View;
GO

IF OBJECT_ID('API_Thaydoi', 'P') IS NOT NULL
    DROP PROCEDURE API_Thaydoi;
GO

CREATE PROCEDURE [dbo].[API_Thaydoi]
    @Keyword NVARCHAR(250),
    @Sothaydoi NVARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    IF @Sothaydoi = '' SET @Sothaydoi = NULL;

    SELECT 
        td.Sothaydoi,
        td.Ngaythaydoi,
        td.Sohopdong,
        td.LanThayDoi,
        td.Ghichu,
        td.Status,
        td.JsonBanTiec,
        td.JsonThucUong,
        td.JsonDichVu,
        td.JsonPhatSinh,
        
        -- Các trường văn bản phụ lục
        ISNULL(td.DichVuTinhPhiPhuLucTD, td.DichVuTinhPhiPhuLuc) AS [DichVuTinhPhiPhuLuc],
        ISNULL(td.ThoaThuanPhuLucKhacTD, td.ThoaThuanPhuLucKhac) AS [ThoaThuanPhuLucKhac],
        ISNULL(td.DanhSachChiPhiTD, td.DanhSachChiPhi) AS [DanhSachChiPhi],
        ISNULL(td.BenAChucVuDaiDienTD, td.BenAChucVuDaiDien) AS [BenAChucVuDaiDien],

        kh.Tenkh AS [KhachHang],
        kh.Tenkh AS [BenBDaiDien],
        ISNULL(nv.Tennv, td.Manv) AS [NVKD],
        CONVERT(VARCHAR(10), hd.Ngayhopdong, 103) AS [NgayHopDong],
        hd.Tentiec AS [TenTiec],
        CONVERT(VARCHAR(10), ISNULL(td.NgayToChucTD, hd.Ngaytochuc), 103) AS [NgayToChuc],
        
        ISNULL(
            (SELECT TOP 1 s.Tensanhtiec 
             FROM tbmk_Hopdongsanhtiec hs 
             INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
             WHERE hs.Sohopdong = td.Sohopdong), 
            N'Chưa xác định'
        ) AS [SanhTiec],
        ISNULL(
            (SELECT TOP 1 s.Tensanhtiec 
             FROM tbmk_Hopdongsanhtiec hs 
             INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
             WHERE hs.Sohopdong = td.Sohopdong), 
            N'Chưa xác định'
        ) AS [Sanh],

        ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc) AS [SoBanChinhThuc],
        ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [SoBanTang],
        ISNULL(ISNULL(td.SoBanTang, hd.SoBanTang), 0) AS [BanTang],
        ISNULL(td.SobanManduphong, hd.SobanManduphong) AS [SoBanDuPhong],

        CASE 
            WHEN ISNULL(td.PhiBuSanhTD, 0) > 0 THEN FORMAT(td.PhiBuSanhTD, 'N0', 'vi-VN') 
            WHEN ISNULL(td.PhiBuSanh, 0) > 0 THEN FORMAT(td.PhiBuSanh, 'N0', 'vi-VN')
            ELSE N'0' 
        END AS [PhiBuSanh],

        RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayThayDoi],
        RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangThayDoi],
        YEAR(td.Ngaythaydoi) AS [NamThayDoi],
        RIGHT('0' + CAST(DAY(td.Ngaythaydoi) AS VARCHAR), 2) AS [NgayLapPL],
        RIGHT('0' + CAST(MONTH(td.Ngaythaydoi) AS VARCHAR), 2) AS [ThangLapPL],
        YEAR(td.Ngaythaydoi) AS [NamLapPL],

        CAST(ISNULL(td.SobanManchinhthuc, hd.SobanManchinhthuc) AS VARCHAR) + N' bàn chính thức và ' + 
        CAST(ISNULL(td.SobanManduphong, hd.SobanManduphong) AS VARCHAR) + N' bàn dự phòng' AS [MoTaTongSoBanSauThayDoi],

        (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY sort_order) AS [STT],
                [NoiDung]
            FROM (
                SELECT N'Thay đổi ngày tổ chức từ ' + CONVERT(VARCHAR(10), hd.Ngaytochuc, 103) + N' sang ngày ' + CONVERT(VARCHAR(10), td.NgayToChucTD, 103) AS [NoiDung], 1 AS sort_order
                WHERE td.NgayToChucTD IS NOT NULL AND td.NgayToChucTD <> hd.Ngaytochuc

                UNION ALL
                SELECT N'Tăng ' + CAST(td.SoBanManChinhThucTang AS NVARCHAR) + N' bàn chính thức' AS [NoiDung], 2 AS sort_order
                WHERE ISNULL(td.SoBanManChinhThucTang, 0) > 0

                UNION ALL
                SELECT N'Giảm ' + CAST(td.SoBanManChinhThucGiam AS NVARCHAR) + N' bàn chính thức' AS [NoiDung], 3 AS sort_order
                WHERE ISNULL(td.SoBanManChinhThucGiam, 0) > 0

                UNION ALL
                SELECT N'Tăng ' + CAST(td.SobanManduphongTang AS NVARCHAR) + N' bàn dự phòng' AS [NoiDung], 4 AS sort_order
                WHERE ISNULL(td.SobanManduphongTang, 0) > 0

                UNION ALL
                SELECT N'Giảm ' + CAST(td.SobanManduphongGiam AS NVARCHAR) + N' bàn dự phòng' AS [NoiDung], 5 AS sort_order
                WHERE ISNULL(td.SobanManduphongGiam, 0) > 0

                UNION ALL
                SELECT N'Thay đổi đơn giá bàn mặn thành: ' + FORMAT(td.GiabanManTD, 'N0', 'vi-VN') + N' VND/bàn' AS [NoiDung], 6 AS sort_order
                WHERE td.GiabanManTD IS NOT NULL AND td.GiabanManTD <> hd.Giabanman

                UNION ALL
                SELECT N'Phụ thu phí sảnh: ' + FORMAT(td.PhiBuSanhTD, 'N0', 'vi-VN') + N' VND' AS [NoiDung], 7 AS sort_order
                WHERE ISNULL(td.PhiBuSanhTD, 0) > 0
            ) sub
            FOR JSON PATH
        ) AS [ChiTietThayDoi]

    FROM tbmk_Thaydoi td
    INNER JOIN tbmk_Hopdong hd ON td.Sohopdong = hd.Sohopdong
    LEFT JOIN dmkhachhang kh ON hd.Makh = kh.Makh
    LEFT JOIN dmNhanvienView nv ON td.Manv = nv.Manv
    WHERE (td.Sohopdong = @Keyword OR td.Sothaydoi = @Keyword)
      AND (@Sothaydoi IS NULL OR td.Sothaydoi = @Sothaydoi)
      AND ISNULL(td.IsDeleted, 0) = 0
    ORDER BY td.Sothaydoi DESC; 
END;
GO

-- =========================================================================
-- 5. ĐỒNG BỘ ĐỊNH TUYẾN GATEWAY (WA_API)
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình định tuyến WA_API cho frmQuyetToan và tbmk_Thaydoi...';
GO

-- Quyết toán (View, Save, GetDetails, Delete)
DELETE FROM WA_API 
WHERE (List = 'frmQuyetToan' AND Func IN ('View', 'Save', 'GetDetails', 'Delete'));
GO

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
(
    'frmQuyetToan', 
    'View', 
    'API_DanhSachQuyetToan', 
    '@Keyword=N''{Keyword}'', @DocumentID=N''{DocumentID}'', @Sohopdong=N''{Sohopdong}'''
),
(
    'frmQuyetToan', 
    'Save', 
    'API_LuuQuyenToan', 
    '@DocumentID=N''{DocumentID}'', @DocumentDate=N''{DocumentDate}'', @Sohopdong=N''{Sohopdong}'', @Nguoinop=N''{Nguoinop}'', @Tongtiencoc={Tongtiencoc}, @TongtienHoaDon={TongtienHoaDon}, @Thanhtoan={Thanhtoan}, @Conlai={Conlai}, @IsKetthuc={IsKetthuc}, @Ghichu=N''{Ghichu}'', @User=N''{UserName}'', @Sotienphatsinh={Sotienphatsinh}, @PhiBuSanh={PhiBuSanh}, @PhiBuBantang={PhiBuBantang}, @PhiBuTTS={PhiBuTTS}, @PhiBuNTL={PhiBuNTL}, @PhiPhucVu={PhiPhucVu}, @PTThueVAT={PTThueVAT}, @TienThueVAT={TienThueVAT}, @JsonBanTiec=N''{JsonBanTiec}'', @JsonThucUong=N''{JsonThucUong}'', @JsonDichVu=N''{JsonDichVu}'', @JsonPhatSinh=N''{JsonPhatSinh}'''
),
(
    'frmQuyetToan', 
    'GetDetails', 
    'API_LayChiTietQuyetToan', 
    '@Sohopdong=N''{Sohopdong}'', @Sothaydoi=N''{Sothaydoi}'', @DocumentID=N''{DocumentID}'''
),
(
    'frmQuyetToan', 
    'Delete', 
    'API_XoaPhieuThu', 
    '@Ids=N''{Keyword}'', @UserName=N''{User}'''
);
GO

-- Phiếu thay đổi (Cập nhật View trỏ sang API_Thaydoi)
UPDATE WA_API
SET [SQL] = 'API_Thaydoi',
    [Para] = '@Keyword=N''{Keyword}'', @Sothaydoi=N''{Sothaydoi}'''
WHERE list = 'tbmk_Thaydoi' AND func = 'View';
GO

-- =========================================================================
-- 6. ĐỒNG BỘ CẤU HÌNH TRƯỜNG DỮ LIỆU (SY_FORMATFIELDS)
-- =========================================================================
PRINT N'Đang đồng bộ cấu hình trường dữ liệu cho frmQuyetToan...';
GO

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonBanTiec')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonBanTiec', N'Chi tiết bàn tiệc (JSON)', 't', '12', 0, 90, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonThucUong')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonThucUong', N'Chi tiết thức uống (JSON)', 't', '12', 0, 91, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonDichVu')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonDichVu', N'Chi tiết dịch vụ (JSON)', 't', '12', 0, 92, 0, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmQuyetToan' AND FieldName = 'JsonPhatSinh')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmQuyetToan', 'JsonPhatSinh', N'Chi tiết phát sinh (JSON)', 't', '12', 0, 93, 0, 0, 1, 1);
GO

PRINT N'>> ĐÃ CẬP NHẬT TOÀN BỘ CHỨC NĂNG QUYẾT TOÁN VÀ THAY ĐỔI CHI TIẾT THÀNH CÔNG!';
GO


