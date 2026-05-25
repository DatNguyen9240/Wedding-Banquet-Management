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
        -- Cột 2: Tên Khách Hàng (Đóng vai trò là Nhãn - Label hiển thị lên ô text sau khi chọn)
        ISNULL(NULLIF(Tenkh, ''), ISNULL(Tenchure + ' & ' + Tencodau, N'Khách vãng lai')) AS [Tên Khách Hàng],
        -- Cột 3: Số Điện Thoại (Hiển thị thêm trong lưới Dropdown để dễ phân biệt người trùng tên)
        ISNULL(NULLIF(Dienthoai, ''), ISNULL(DTchure, DTcodau)) AS [Số Điện Thoại]
    FROM dmkhachhang
    WHERE 
        (@Keyword IS NULL OR @Keyword = '')
        OR Tenkh LIKE N'%' + @Keyword + '%'
        OR Tenchure LIKE N'%' + @Keyword + '%'
        OR Tencodau LIKE N'%' + @Keyword + '%'
        OR Dienthoai LIKE '%' + @Keyword + '%';
END
GO
