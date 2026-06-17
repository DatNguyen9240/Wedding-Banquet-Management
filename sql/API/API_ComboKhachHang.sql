USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Khách hàng chuyên dụng cho Combo Box (Dropdown)
-- Trả về đúng 3 cột: Mã (Value) - Tên (Label hiển thị) - Số Điện Thoại (Bổ sung)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_ComboKhachHang]
    @Keyword NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Makh,
        -- Cột 2 & 3: Sẽ được hiển thị trên Lưới thả xuống (Do frontend chỉ render max 3 cột đầu)
        ISNULL(NULLIF(Tenkh, ''), ISNULL(Tenchure + ' & ' + Tencodau, N'Khách vãng lai')) AS [TenKhachHang],
        ISNULL(NULLIF(Dienthoai, ''), ISNULL(DTchure, DTcodau)) AS [Dienthoai],
        
        -- Cột 4 trở đi: Bị ẨN khỏi Lưới, nhưng Frontend sẽ TỰ ĐỘNG BẮT LẤY để Auto-fill vào các ô nhập liệu trùng tên
        Tenchure,
        Tencodau,
        DTchure,
        DTcodau,
        Diachi,
        Nguoigd,
        Mail,
        DienThoaiDaiDien
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%';
END
GO
