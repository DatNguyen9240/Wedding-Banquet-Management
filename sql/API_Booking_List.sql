USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Booking (Biên nhận cọc chỗ)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_Booking_List]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        b.DocumentID AS [MaChungTu],
        b.SoBN AS [SoPhieu],
        
        -- Thông tin khách hàng chi tiết
        k.Tenchure AS [Tenchure],
        k.Tencodau AS [Tencodau],
        k.DTchure AS [DTchure],
        k.DTcodau AS [DTcodau],
        k.Diachi AS [Diachi],
        k.Nguoigd AS [Nguoigd],
        k.DienThoaiDaiDien AS [DienThoaiDaiDien],
        k.Mail AS [Mail],
        
        -- Thông tin tiệc chi tiết
        b.Thoigianid AS [Thoigianid],
        b.Loaitiecid AS [Loaihinhtiecid],
        b.SobanManchinhthuc AS [SobanManchinhthuc],
        b.SobanChaychinhthuc AS [SobanChaychinhthuc],
        b.Ghichu AS [Ghichu],
        
        -- Ghép Tên 2 người, hoặc xài Tên Khách chung chung nếu không có
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL 
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
        END AS [TenKhachHang],
        
        -- Lấy sdt nếu không có bốc số chú rể / cô dâu
        ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS [DienThoai],
        
        CONVERT(VARCHAR(10), b.Ngaytochuc, 103) AS [NgayToChuc],
        
        ISNULL(b.Tongsoban, 0) AS [SoBan],
        
        -- Lấy Sảnh đặt bằng subquery (chỉ lấy 1 sảnh tượng trưng nếu chọn nhiều)
        -- Chú ý: Ở đây Join với 1 bảng Trung Gian SanhTiec (dựa theo cấu trúc thực tế tbmk_Biennhancocchosanhtiec)
        (
            SELECT TOP 1 s.Tensanhtiec 
            FROM tbmk_Biennhancocchosanhtiec bs 
            INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
            WHERE bs.DocumentID = b.DocumentID
        ) AS [SanhDat],
        
        -- Tiền đã cọc (lấy từ TongTien)
        ISNULL(b.Tongtien, 0) AS [DaCocVND],
        
        -- Danh sách chi tiết sảnh
        (
            SELECT Sanhtiecid, IsSanhchinh 
            FROM tbmk_Biennhancocchosanhtiec 
            WHERE DocumentID = b.DocumentID 
            FOR JSON PATH
        ) AS [JsonSanhTiec],
        
        -- Label trạng thái
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
    WHERE 
        -- Nếu có tìm kiếm thì ưu tiên
        (@Keyword IS NULL OR @Keyword = '' OR b.DocumentID LIKE '%' + @Keyword + '%' OR b.SoBN LIKE '%' + @Keyword + '%' OR k.Dienthoai LIKE '%' + @Keyword + '%' OR k.Tenkh LIKE N'%' + @Keyword + '%' OR k.Tenchure LIKE N'%' + @Keyword + '%' OR k.Tencodau LIKE N'%' + @Keyword + '%')
        
        -- Lọc ngày tổ chức nếu truyền TuNgay / DenNgay (bỏ qua nếu là chuỗi rỗng / 1900-01-01)
        AND (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR b.Ngaytochuc <= @DenNgay)
        
    ORDER BY 
        b.Ngaytochuc DESC, b.DocumentDate DESC;
END
GO
