CREATE OR ALTER PROCEDURE [dbo].[API_TimKiemKhachHang]
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Makh,
        Tenkh,
        Tencodau,
        Tenchure,
        DTcodau,
        DTchure,
        Dienthoai,
        Mail,
        Diachi,
        DateCreate,
        UserCreate
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%';
END
GO

/* =============================================
   TEST SCRIPTS (Bôi đen dòng EXEC để chạy thử)
================================================
-- 1. Test mặc định (Chỉ test việc SP lấy data, API Framework sẽ lo việc phân trang và sort)
EXEC [dbo].[API_TimKiemKhachHang] 
    @Keyword = N'';
*/
