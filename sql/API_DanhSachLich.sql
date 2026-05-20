USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy dữ liệu Lịch Tiệc theo Tháng
-- Hiển thị: Mới cọc (Chưa HĐ) - Màu xanh | Đã Hợp đồng - Màu Đỏ
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachLich]
    @Thang INT = NULL,
    @Nam INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Lấy dữ liệu CỌC CHỖ (Chưa lên hợp đồng và Chưa hủy)
    SELECT 
        b.DocumentID AS [MaChungTu],
        CONVERT(VARCHAR(10), b.Ngaytochuc, 23) AS [NgayToChuc],
        1 AS [LoaiPhieu], -- 1 = Mới cọc chỗ (Màu xanh)
        ISNULL(b.Tongsoban, 0) AS [SoBan],
        ISNULL(s.Tensanhtiec, N'Chưa chọn sảnh') AS [TenSanh],
        
        -- Dựa theo cấu trúc chuẩn của tbmk_Biennhancocchosanhtiec
        ISNULL(bs.IsSanhchinh, 1) AS [LaSanhChinh],
        
        -- Ghép Tên 2 người
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL 
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách')
        END AS [TenKhachHang]
        
    FROM tbmk_Biennhancoccho b
    LEFT JOIN tbmk_Biennhancocchosanhtiec bs ON b.DocumentID = bs.DocumentID
    LEFT JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid
    LEFT JOIN dmkhachhang k ON b.Makh = k.Makh
    WHERE ISNULL(b.IsHuy, 0) = 0 
      AND ISNULL(b.IsKetthuc, 0) = 0 -- Bắt buộc chưa kết thúc (chưa lên hợp đồng)
      AND (@Thang IS NULL OR MONTH(b.Ngaytochuc) = @Thang)
      AND (@Nam IS NULL OR YEAR(b.Ngaytochuc) = @Nam)

    UNION ALL

    -- 2. Lấy dữ liệu HỢP ĐỒNG (Đã ký hợp đồng và Chưa hủy)
    SELECT 
        h.Sohopdong AS [MaChungTu],
        CONVERT(VARCHAR(10), h.Ngaytochuc, 23) AS [NgayToChuc],
        2 AS [LoaiPhieu], -- 2 = Hợp đồng (Màu đỏ)
        ISNULL(h.TongSoBan, 0) AS [SoBan],
        ISNULL(s.Tensanhtiec, N'Chưa chọn sảnh') AS [TenSanh],
        
        -- Tương tự với bảng Hợp đồng
        ISNULL(hs.IsSanhchinh, 1) AS [LaSanhChinh],
        
        CASE 
            WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL 
                THEN k.Tenchure + ' & ' + k.Tencodau
            ELSE ISNULL(k.Tenkh, N'Khách')
        END AS [TenKhachHang]
        
    FROM tbmk_Hopdong h
    LEFT JOIN tbmk_Hopdongsanhtiec hs ON h.Sohopdong = hs.Sohopdong
    LEFT JOIN dmSanhtiec s ON hs.Sanhtiecid = s.Sanhtiecid
    LEFT JOIN dmkhachhang k ON h.Makh = k.Makh
    WHERE ISNULL(h.IsHuy, 0) = 0 
      AND (@Thang IS NULL OR MONTH(h.Ngaytochuc) = @Thang)
      AND (@Nam IS NULL OR YEAR(h.Ngaytochuc) = @Nam)

    ORDER BY NgayToChuc ASC;
END
GO
