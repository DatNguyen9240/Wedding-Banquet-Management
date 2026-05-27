USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Hợp đồng (Contract)
-- =============================================
CREATE PROCEDURE [dbo].[API_DanhSachHopDong]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        h.Sohopdong,
        h.Sobiennhan,
        
        -- Ghép Tên 2 người, hoặc xài Tên Khách chung chung nếu không có
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL AND k.Tenchure <> '' AND k.Tencodau <> ''
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [TenKhachHang],
        
        -- Lấy sdt nếu không có bốc số chú rể / cô dâu
        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
        
        CONVERT(VARCHAR(10), h.Ngaytochuc, 103) AS [NgayToChuc],
        
        ISNULL(h.TongSoBan, 0) AS [SoBan],
        
        -- Lấy Sảnh đặt bằng subquery (chỉ lấy 1 sảnh tượng trưng nếu chọn nhiều)
        (
            SELECT TOP 1 s.Tensanhtiec 
            FROM tbmk_Hopdongsanhtiec hs 
            INNER JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid 
            WHERE hs.Sohopdong = h.Sohopdong
        ) AS [SanhDat],
        
        ISNULL(h.Tongtienhopdong, 0) AS [TongTien],
        
        -- Label trạng thái
        CASE
            WHEN h.IsHuy = 1 THEN N'Đã Hủy'
            WHEN h.IsKetthuc = 1 THEN N'Đã Quyết Toán'
            ELSE N'Đã Ký'
        END AS [TrangThai]
        
    FROM 
        tbmk_Hopdong h
    LEFT JOIN 
        dmkhachhang k ON h.Makh = k.Makh
    WHERE 
        -- Bộ lọc theo Khoảng ngày (Dựa theo NgayToChuc)
        (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR h.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR h.Ngaytochuc <= @DenNgay)
        
        -- Bộ lọc Keyword tìm kiếm tương đối
        AND (
            @Keyword IS NULL OR @Keyword = ''
            OR h.Sohopdong LIKE '%' + @Keyword + '%'
            OR h.Sobiennhan LIKE '%' + @Keyword + '%'
            OR k.Tenkh LIKE N'%' + @Keyword + '%'
            OR k.Tenchure LIKE N'%' + @Keyword + '%'
            OR k.Tencodau LIKE N'%' + @Keyword + '%'
            OR k.Dienthoai LIKE '%' + @Keyword + '%'
        )
    ORDER BY 
        h.Ngaytochuc ASC;
        
END
GO
