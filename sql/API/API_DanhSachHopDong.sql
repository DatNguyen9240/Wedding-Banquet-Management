USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Màn hình Hợp đồng (Contract)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[API_DanhSachHopDong]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[API_DanhSachHopDong]
GO
CREATE PROCEDURE [dbo].[API_DanhSachHopDong]
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL,
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        v.*
    FROM 
        [dbo].[v_DanhSachHopDong] v
    WHERE 
        -- Bộ lọc theo Khoảng ngày (Dựa theo NgayToChuc)
        (@TuNgay IS NULL OR CAST(@TuNgay AS DATE) <= '1900-01-01' OR v.NgayToChuc >= @TuNgay)
        AND (@DenNgay IS NULL OR CAST(@DenNgay AS DATE) <= '1900-01-01' OR v.NgayToChuc <= @DenNgay)
        
        -- Bộ lọc Keyword tìm kiếm tương đối
        AND (
            @Keyword IS NULL OR @Keyword = ''
            OR v.Sohopdong LIKE '%' + @Keyword + '%'
            OR v.Sobiennhan LIKE '%' + @Keyword + '%'
            OR v.TenKhachHang LIKE N'%' + @Keyword + '%'
            OR v.Tenchure LIKE N'%' + @Keyword + '%'
            OR v.Tencodau LIKE N'%' + @Keyword + '%'
            OR v.DienThoai LIKE '%' + @Keyword + '%'
            OR v.BenBCCCD LIKE '%' + @Keyword + '%'
        )
    ORDER BY 
        v.Sohopdong DESC;
        
END
GO
