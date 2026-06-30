CREATE OR ALTER PROCEDURE [dbo].[API_DanhSachKhachHang]
    @Keyword NVARCHAR(100) = NULL,
    
    -- Khai báo hứng các biến từ giao diện gửi xuống (Tên biến phải khớp với FieldName trong DB)
    @Makh NVARCHAR(50) = NULL,
    @Tenkh NVARCHAR(100) = NULL,
    @DTcodau NVARCHAR(20) = NULL,
    @DienthoaiChung NVARCHAR(20) = NULL,
    @CCCD NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Makh,
        Tenchure,
        DTchure,
        Tencodau,
        DTcodau,
        Tenkh,
        Dienthoai,
        ISNULL(NULLIF(Dienthoai, ''), ISNULL(DTchure, DTcodau)) AS DienthoaiChung,
        Dienthoai AS DienThoaiDaiDien,
        Nguoigd,
        Mail,
        Diachi,
        CMNDDaiDien AS CCCD,
        (SELECT COUNT(1) FROM tbmk_Khachthamquan WHERE Makh = dmkhachhang.Makh) AS SoLanThamQuan,
        (SELECT COUNT(1) FROM tbmk_Hopdong WHERE Makh = dmkhachhang.Makh) AS SoHopDong
    FROM dmkhachhang
    WHERE ISNULL(IsDeleted, 0) = 0
        -- 1. Lọc theo các trường Dynamic Filter (nếu Frontend có truyền xuống)
        AND (@Makh IS NULL OR @Makh = '' OR Makh = @Makh)
        AND (@Tenkh IS NULL OR @Tenkh = '' OR Tenkh LIKE N'%' + @Tenkh + '%')
        AND (@DTcodau IS NULL OR @DTcodau = '' OR DTcodau LIKE '%' + @DTcodau + '%')
        AND (@DienthoaiChung IS NULL OR @DienthoaiChung = '' OR ISNULL(NULLIF(Dienthoai, ''), ISNULL(DTchure, DTcodau)) LIKE '%' + @DienthoaiChung + '%')
        AND (@CCCD IS NULL OR @CCCD = '' OR CMNDDaiDien LIKE '%' + @CCCD + '%')
        
        -- 2. Lọc Keyword (Tìm kiếm chung toàn cục cũ)
        AND (@Keyword IS NULL OR @Keyword = ''
             OR Tenkh LIKE N'%' + @Keyword + '%'
             OR Tenchure LIKE N'%' + @Keyword + '%'
             OR Tencodau LIKE N'%' + @Keyword + '%'
             OR Dienthoai LIKE '%' + @Keyword + '%'
             OR CMNDDaiDien LIKE '%' + @Keyword + '%');
END
GO

/* =============================================
   TEST SCRIPTS (Bôi đen khối EXEC để chạy thử)
================================================

-- 1. Test không truyền gì (Lấy tất cả)
EXEC [dbo].[API_DanhSachKhachHang];

-- 2. Test truyền Parameter tĩnh (VD: Tìm theo Tên khách hàng)
EXEC [dbo].[API_DanhSachKhachHang] 
    @Tenkh = N'Nguyễn';

-- 3. Test truyền nhiều Parameter cùng lúc
EXEC [dbo].[API_DanhSachKhachHang] 
    @Tenkh = N'Nguyễn',
    @DTcodau = '098';
*/
