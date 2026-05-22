USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Mô tả: API Tìm kiếm nhanh thông tin Khách hàng cũ
-- Cập nhật: Thêm tính năng Server-Side Sorting và Pagination
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_TimKiemKhachHang]
    @Keyword NVARCHAR(100) = NULL,
    @SortColumn VARCHAR(50) = 'DateCreate',
    @SortDirection VARCHAR(4) = 'DESC',
    @Page INT = 1,
    @Limit INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính tổng số bản ghi
    DECLARE @TotalRecords INT;
    SELECT @TotalRecords = COUNT(1)
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%';

    -- Truy vấn phân trang
    SELECT 
        Makh,
        Tenkh,
        Tenchure,
        Tencodau,
        Dienthoai,
        Diachi,
        Mail,
        @TotalRecords AS TotalRecords -- Trả về cùng để proxy map thành _recordtotal
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%'
    ORDER BY 
        CASE WHEN @SortDirection = 'ASC' AND @SortColumn = 'MaKH' THEN Makh END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'MaKH' THEN Makh END DESC,
        
        CASE WHEN @SortDirection = 'ASC' AND @SortColumn = 'TenKhach' THEN Tenkh END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'TenKhach' THEN Tenkh END DESC,
        
        CASE WHEN @SortDirection = 'ASC' AND @SortColumn = 'SoLanThamQuan' THEN Makh END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'SoLanThamQuan' THEN Makh END DESC,

        CASE WHEN @SortDirection = 'ASC' AND @SortColumn = 'SoHopDong' THEN Makh END ASC,
        CASE WHEN @SortDirection = 'DESC' AND @SortColumn = 'SoHopDong' THEN Makh END DESC,

        -- Fallback default
        CASE WHEN @SortColumn NOT IN ('MaKH', 'TenKhach', 'SoLanThamQuan', 'SoHopDong') THEN DateCreate END DESC

    OFFSET (@Page - 1) * @Limit ROWS
    FETCH NEXT @Limit ROWS ONLY;
END
GO
