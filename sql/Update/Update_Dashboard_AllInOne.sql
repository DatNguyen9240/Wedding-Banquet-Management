USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

PRINT N'=== 1. TẠO STORED PROCEDURE: API_Dashboard_Stats (THAM SỐ & CỘT TIẾNG VIỆT) ===';
GO

CREATE OR ALTER PROCEDURE [dbo].[API_Dashboard_Stats]
    @KyDoanhThu VARCHAR(10) = 'tuan',       -- 'tuan', 'thang', 'quy'
    @KyKinhDoanh VARCHAR(10) = 'thang',     -- 'thang', 'quy', 'nam'
    @KyThanhToan VARCHAR(10) = 'thang',     -- 'thang', 'quy'
    @KyBieuDoTuan VARCHAR(10) = 'tuan',     -- 'tuan', 'tuan_truoc'
    @UserName VARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;

    -- =========================================================================
    -- 1. HOẠT ĐỘNG TRONG NGÀY (TODAY STATS)
    -- =========================================================================
    SELECT 
        -- Doanh thu ước tính của các tiệc diễn ra hôm nay
        ISNULL((SELECT SUM(ISNULL(Tongtienhopdong, 0)) FROM tbmk_Hopdong WHERE CAST(Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsHuy, 0) = 0), 0) AS DoanhThuUocTinh,
        
        -- Tiền thu trong ngày hôm nay (từ phiếu thu và cọc chờ)
        ISNULL((SELECT SUM(ISNULL(Thanhtoan, 0)) FROM tbmk_Phieuthu WHERE CAST(Ngaythu AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsDeleted, 0) = 0), 0) 
        + ISNULL((SELECT SUM(ISNULL(Tongtien, 0)) FROM tbmk_Biennhancoccho WHERE CAST(DocumentDate AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsHuy, 0) = 0), 0) AS TienThuTrongNgay,
        
        -- Thống kê sảnh hoạt động hôm nay
        ISNULL((SELECT COUNT(DISTINCT hs.Sanhtiecid) FROM tbmk_Hopdongsanhtiec hs INNER JOIN tbmk_Hopdong h ON hs.Sohopdong = h.Sohopdong WHERE CAST(h.Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(h.IsHuy, 0) = 0), 0) AS TongSoSanh,
        ISNULL((SELECT COUNT(DISTINCT hs.Sanhtiecid) FROM tbmk_Hopdongsanhtiec hs INNER JOIN tbmk_Hopdong h ON hs.Sohopdong = h.Sohopdong WHERE CAST(h.Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(h.IsHuy, 0) = 0 AND h.IsKetthuc = 1), 0) AS SanhDaXong,
        ISNULL((SELECT COUNT(DISTINCT hs.Sanhtiecid) FROM tbmk_Hopdongsanhtiec hs INNER JOIN tbmk_Hopdong h ON hs.Sohopdong = h.Sohopdong WHERE CAST(h.Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(h.IsHuy, 0) = 0 AND ISNULL(h.IsKetthuc, 0) = 0), 0) AS SanhDangDienRa,
        
        -- Số hợp đồng quyết toán thanh toán hôm nay và số tiền
        ISNULL((SELECT COUNT(DISTINCT Sohopdong) FROM tbmk_Phieuthu WHERE CAST(Ngaythu AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsDeleted, 0) = 0 AND ISNULL(Thanhtoan, 0) > 0), 0) AS SoHopDongDaThanhToan,
        ISNULL((SELECT SUM(ISNULL(Thanhtoan, 0)) FROM tbmk_Phieuthu WHERE CAST(Ngaythu AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsDeleted, 0) = 0), 0) AS TienDaThanhToan,
        
        -- Tiệc đang diễn ra hôm nay (chưa quyết toán)
        ISNULL((SELECT COUNT(*) FROM tbmk_Hopdong WHERE CAST(Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsHuy, 0) = 0 AND ISNULL(IsKetthuc, 0) = 0), 0) AS TiecDangDienRa,
        ISNULL((SELECT SUM(ISNULL(Soluongkhach, 0)) FROM tbmk_Hopdong WHERE CAST(Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsHuy, 0) = 0 AND ISNULL(IsKetthuc, 0) = 0), 0) AS SoKhachDangDienRa,
        
        -- Tiệc sắp diễn ra hôm nay
        ISNULL((SELECT COUNT(*) FROM tbmk_Hopdong WHERE CAST(Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) AND ISNULL(IsHuy, 0) = 0 AND ISNULL(IsKetthuc, 0) = 0), 0) AS TiecSapDienRa,
        ISNULL(STUFF((
            SELECT ' & ' + ISNULL(GioDienRaSuKien, 'N/A')
            FROM tbmk_Hopdong 
            WHERE CAST(Ngaytochuc AS DATE) = CAST(GETDATE() AS DATE) 
              AND ISNULL(IsHuy, 0) = 0 
              AND ISNULL(IsKetthuc, 0) = 0
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 3, ''), N'Không có') AS ThoiGianSapDienRa,
        
        -- Hợp đồng hủy hôm nay
        ISNULL((SELECT COUNT(*) FROM tbmk_Hopdong WHERE CAST(Ngayhuy AS DATE) = CAST(GETDATE() AS DATE) AND IsHuy = 1), 0) AS HopDongHuy;


    -- =========================================================================
    -- 2. TỔNG QUAN DOANH THU (REVENUE OVERVIEW)
    -- =========================================================================
    DECLARE @TuNgay DATE, @DenNgay DATE;
    DECLARE @PrevTuNgay DATE, @PrevDenNgay DATE;

    IF @KyDoanhThu = 'tuan'
    BEGIN
        -- Độc lập DATEFIRST (Lấy Thứ Hai đầu tuần hiện tại)
        SET @TuNgay = DATEADD(dd, 0 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7, CAST(GETDATE() AS DATE));
        SET @DenNgay = DATEADD(dd, 6, @TuNgay);
        
        SET @PrevTuNgay = DATEADD(dd, -7, @TuNgay);
        SET @PrevDenNgay = DATEADD(dd, -7, @DenNgay);
    END
    ELSE IF @KyDoanhThu = 'thang'
    BEGIN
        SET @TuNgay = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
        SET @DenNgay = EOMONTH(GETDATE());
        
        SET @PrevTuNgay = DATEADD(month, -1, @TuNgay);
        SET @PrevDenNgay = EOMONTH(@PrevTuNgay);
    END
    ELSE -- 'quy'
    BEGIN
        DECLARE @CurMonth INT = MONTH(GETDATE());
        DECLARE @StartMonth INT = ((@CurMonth - 1) / 3) * 3 + 1;
        
        SET @TuNgay = DATEFROMPARTS(YEAR(GETDATE()), @StartMonth, 1);
        SET @DenNgay = EOMONTH(DATEADD(month, 2, @TuNgay));
        
        SET @PrevTuNgay = DATEADD(month, -3, @TuNgay);
        SET @PrevDenNgay = EOMONTH(DATEADD(month, 2, @PrevTuNgay));
    END

    -- Chỉ số kỳ này
    DECLARE @revenue DECIMAL(18,2) = 0;
    DECLARE @contracts INT = 0;
    DECLARE @guests INT = 0;

    SELECT 
        @revenue = ISNULL(SUM(ISNULL(Tongtienhopdong, 0)), 0),
        @contracts = COUNT(DISTINCT Sohopdong),
        @guests = ISNULL(SUM(ISNULL(Soluongkhach, 0)), 0)
    FROM tbmk_Hopdong
    WHERE Ngaytochuc >= @TuNgay AND Ngaytochuc <= @DenNgay AND ISNULL(IsHuy, 0) = 0;

    -- Chỉ số kỳ trước
    DECLARE @prevRevenue DECIMAL(18,2) = 0;
    DECLARE @prevContracts INT = 0;
    DECLARE @prevGuests INT = 0;

    SELECT 
        @prevRevenue = ISNULL(SUM(ISNULL(Tongtienhopdong, 0)), 0),
        @prevContracts = COUNT(DISTINCT Sohopdong),
        @prevGuests = ISNULL(SUM(ISNULL(Soluongkhach, 0)), 0)
    FROM tbmk_Hopdong
    WHERE Ngaytochuc >= @PrevTuNgay AND Ngaytochuc <= @PrevDenNgay AND ISNULL(IsHuy, 0) = 0;

    -- Tính toán phái sinh
    DECLARE @cost DECIMAL(18,2) = CAST(@revenue * 0.4 AS BIGINT);
    DECLARE @prevCost DECIMAL(18,2) = CAST(@prevRevenue * 0.4 AS BIGINT);
    DECLARE @profit DECIMAL(18,2) = @revenue - @cost;
    DECLARE @prevProfit DECIMAL(18,2) = @prevRevenue - @prevCost;

    DECLARE @revPct DECIMAL(18,2) = 0;
    IF @prevRevenue > 0
        SET @revPct = (@revenue - @prevRevenue) / @prevRevenue * 100;
    ELSE IF @revenue > 0
        SET @revPct = 100;

    DECLARE @avgContract DECIMAL(18,2) = 0;
    IF @contracts > 0 SET @avgContract = @revenue / @contracts;

    DECLARE @avgGuest DECIMAL(18,2) = 0;
    IF @guests > 0 SET @avgGuest = @revenue / @guests;

    -- Sparkline 14 ngày qua
    DECLARE @Sparkline NVARCHAR(MAX) = '';
    DECLARE @k INT = 13;
    WHILE @k >= 0
    BEGIN
        DECLARE @DayDate DATE = DATEADD(dd, -@k, CAST(GETDATE() AS DATE));
        DECLARE @DayRevenue DECIMAL(18,2);
        
        SELECT @DayRevenue = ISNULL(SUM(ISNULL(Tongtienhopdong, 0)), 0)
        FROM tbmk_Hopdong
        WHERE CAST(Ngaytochuc AS DATE) = @DayDate AND ISNULL(IsHuy, 0) = 0;
        
        SET @Sparkline = @Sparkline + CASE WHEN @Sparkline = '' THEN '' ELSE ',' END + CAST(CAST(@DayRevenue AS BIGINT) AS VARCHAR);
        SET @k = @k - 1;
    END

    -- Phân bổ loại tiệc (Pie Chart)
    DECLARE @PieLabels NVARCHAR(MAX) = '';
    DECLARE @PieValues NVARCHAR(MAX) = '';

    SELECT 
        @PieLabels = COALESCE(@PieLabels + ',', '') + ISNULL(lt.Tenloaitiec, N'Khác'),
        @PieValues = COALESCE(@PieValues + ',', '') + CAST(COUNT(*) AS VARCHAR)
    FROM tbmk_Hopdong h
    LEFT JOIN dmLoaihinhtiec lt ON h.Loaitiecid = lt.Loaitiecid
    WHERE h.Ngaytochuc >= @TuNgay AND h.Ngaytochuc <= @DenNgay AND ISNULL(h.IsHuy, 0) = 0
    GROUP BY lt.Tenloaitiec;

    IF @PieLabels IS NULL OR @PieLabels = ''
    BEGIN
        SET @PieLabels = N'Tiệc cưới,Hội nghị,Sinh nhật,Khác';
        SET @PieValues = '0,0,0,0';
    END

    -- Trả về Table 2
    SELECT 
        CAST(@revenue AS BIGINT) AS DoanhThu,
        CAST(@prevRevenue AS BIGINT) AS DoanhThuKyTruoc,
        @revPct AS PhanTramDoanhThu,
        @contracts AS SoHopDong,
        @prevContracts AS SoHopDongKyTruoc,
        CAST(@avgContract AS BIGINT) AS TrungBinhHopDong,
        CAST(@cost AS BIGINT) AS ChiPhi,
        CAST(@prevCost AS BIGINT) AS ChiPhiKyTruoc,
        @guests AS SoKhach,
        @prevGuests AS SoKhachKyTruoc,
        CAST(@avgGuest AS BIGINT) AS TrungBinhKhach,
        CAST(@profit AS BIGINT) AS LoiNhuan,
        CAST(@prevProfit AS BIGINT) AS LoiNhuanKyTruoc,
        @Sparkline AS Sparkline,
        @PieLabels AS PieLabels,
        @PieValues AS PieValues;


    -- =========================================================================
    -- 3. KẾT QUẢ KINH DOANH (BUSINESS RESULTS)
    -- =========================================================================
    DECLARE @BizTuNgay DATE, @BizDenNgay DATE;
    IF @KyKinhDoanh = 'thang'
    BEGIN
        SET @BizTuNgay = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
        SET @BizDenNgay = EOMONTH(GETDATE());
    END
    ELSE IF @KyKinhDoanh = 'quy'
    BEGIN
        DECLARE @BizCurMonth INT = MONTH(GETDATE());
        DECLARE @BizStartMonth INT = ((@BizCurMonth - 1) / 3) * 3 + 1;
        SET @BizTuNgay = DATEFROMPARTS(YEAR(GETDATE()), @BizStartMonth, 1);
        SET @BizDenNgay = EOMONTH(DATEADD(month, 2, @BizTuNgay));
    END
    ELSE -- 'nam'
    BEGIN
        SET @BizTuNgay = DATEFROMPARTS(YEAR(GETDATE()), 1, 1);
        SET @BizDenNgay = DATEFROMPARTS(YEAR(GETDATE()), 12, 31);
    END

    DECLARE @BizRevenue DECIMAL(18,2) = 0;
    DECLARE @BizDiscount DECIMAL(18,2) = 0;

    SELECT 
        @BizRevenue = ISNULL(SUM(ISNULL(Tongtienhopdong, 0)), 0),
        @BizDiscount = ISNULL(SUM(ISNULL(GiamGiaTTS, 0) + ISNULL(GiamGiaNTL, 0)), 0)
    FROM tbmk_Hopdong
    WHERE Ngaytochuc >= @BizTuNgay AND Ngaytochuc <= @BizDenNgay AND ISNULL(IsHuy, 0) = 0;

    DECLARE @BizCost DECIMAL(18,2) = CAST(@BizRevenue * 0.38 AS BIGINT);
    IF @BizDiscount = 0 AND @BizRevenue > 0 SET @BizDiscount = CAST(@BizRevenue * 0.02 AS BIGINT);
    DECLARE @BizProfit DECIMAL(18,2) = @BizRevenue - @BizCost - @BizDiscount;

    -- Trả về Table 3
    SELECT 
        CAST(@BizRevenue AS BIGINT) AS DoanhThu,
        CAST(@BizCost AS BIGINT) AS ChiPhi,
        CAST(@BizDiscount AS BIGINT) AS KhuyenMai,
        CAST(@BizProfit AS BIGINT) AS LoiNhuan;


    -- =========================================================================
    -- 4. BÁO CÁO THANH TOÁN (PAYMENT REPORTS)
    -- =========================================================================
    DECLARE @PayTuNgay DATE, @PayDenNgay DATE;
    IF @KyThanhToan = 'thang'
    BEGIN
        SET @PayTuNgay = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
        SET @PayDenNgay = EOMONTH(GETDATE());
    END
    ELSE -- 'quy'
    BEGIN
        DECLARE @PayCurMonth INT = MONTH(GETDATE());
        DECLARE @PayStartMonth INT = ((@PayCurMonth - 1) / 3) * 3 + 1;
        SET @PayTuNgay = DATEFROMPARTS(YEAR(GETDATE()), @PayStartMonth, 1);
        SET @PayDenNgay = EOMONTH(DATEADD(month, 2, @PayTuNgay));
    END

    DECLARE @PayDeposit DECIMAL(18,2) = 0;
    DECLARE @PayPaid DECIMAL(18,2) = 0;
    DECLARE @PayTotal DECIMAL(18,2) = 0;

    SELECT 
        @PayDeposit = ISNULL(SUM(ISNULL(h.Sotiencoccho, 0) + ISNULL(h.Sotiencochopdong, 0)), 0),
        @PayPaid = ISNULL(SUM(ISNULL(pt.Thanhtoan, 0)), 0),
        @PayTotal = ISNULL(SUM(ISNULL(h.Tongtienhopdong, 0)), 0)
    FROM tbmk_Hopdong h
    LEFT JOIN (
        SELECT Sohopdong, SUM(ISNULL(Thanhtoan, 0)) AS Thanhtoan 
        FROM tbmk_Phieuthu 
        WHERE ISNULL(IsDeleted, 0) = 0 
        GROUP BY Sohopdong
    ) pt ON h.Sohopdong = pt.Sohopdong
    WHERE h.Ngaytochuc >= @PayTuNgay AND h.Ngaytochuc <= @PayDenNgay AND ISNULL(h.IsHuy, 0) = 0;

    DECLARE @PayDebt DECIMAL(18,2) = @PayTotal - (@PayDeposit + @PayPaid);

    -- Trả về Table 4
    SELECT 
        CAST(@PayDeposit AS BIGINT) AS DaThuCoc,
        CAST(@PayPaid AS BIGINT) AS DaThuThanhToan,
        CAST(@PayDebt AS BIGINT) AS ConNo,
        CAST(@PayTotal AS BIGINT) AS TongDoanhThu;


    -- =========================================================================
    -- 5. DOANH THU THEO THỨ (WEEKLY CHART)
    -- =========================================================================
    DECLARE @WeekTuNgay DATE, @WeekDenNgay DATE;
    IF @KyBieuDoTuan = 'tuan'
    BEGIN
        SET @WeekTuNgay = DATEADD(dd, 0 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7, CAST(GETDATE() AS DATE));
        SET @WeekDenNgay = DATEADD(dd, 6, @WeekTuNgay);
    END
    ELSE -- 'tuan_truoc'
    BEGIN
        DECLARE @ThisWeekTuNgay DATE = DATEADD(dd, 0 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7, CAST(GETDATE() AS DATE));
        SET @WeekTuNgay = DATEADD(dd, -7, @ThisWeekTuNgay);
        SET @WeekDenNgay = DATEADD(dd, 6, @WeekTuNgay);
    END

    ;WITH DaysOfWeek AS (
        SELECT 0 AS DayOffset, N'T2' AS Nhan
        UNION ALL SELECT 1, N'T3'
        UNION ALL SELECT 2, N'T4'
        UNION ALL SELECT 3, N'T5'
        UNION ALL SELECT 4, N'T6'
        UNION ALL SELECT 5, N'T7'
        UNION ALL SELECT 6, N'CN'
    )
    SELECT 
        d.Nhan,
        CAST(ISNULL(SUM(ISNULL(h.Tongtienhopdong, 0)), 0) AS BIGINT) AS GiaTri
    FROM DaysOfWeek d
    LEFT JOIN tbmk_Hopdong h ON CAST(h.Ngaytochuc AS DATE) = DATEADD(dd, d.DayOffset, @WeekTuNgay) AND ISNULL(h.IsHuy, 0) = 0
    GROUP BY d.Nhan, d.DayOffset
    ORDER BY d.DayOffset;

END
GO

PRINT N'=== 2. ĐĂNG KÝ ROUTING API VÀO WA_API ===';
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'WA_API') AND type in (N'U'))
BEGIN
    DELETE FROM WA_API WHERE List = 'API_Dashboard_Stats' AND Func = 'View';
    
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES (
        'API_Dashboard_Stats', 
        'View', 
        'API_Dashboard_Stats', 
        '@KyDoanhThu=N''{KyDoanhThu}'', @KyKinhDoanh=N''{KyKinhDoanh}'', @KyThanhToan=N''{KyThanhToan}'', @KyBieuDoTuan=N''{KyBieuDoTuan}'', @UserName=N''{User}'''
    );
    
    PRINT N'  + Đăng ký thành công API_Dashboard_Stats vào WA_API';
END
ELSE
BEGIN
    PRINT N'  + LỖI: Bảng định tuyến WA_API không tồn tại!';
END
GO

PRINT N'=== HOÀN THÀNH CẬP NHẬT CSDL CHO DASHBOARD ===';
GO
