USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- API: Lấy danh sách Nhân viên chuyên dụng cho Combo Box (Dropdown)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[API_ComboNhanVien]
    @Keyword NVARCHAR(100) = '',
    @BranchID VARCHAR(50) = ''   -- Thêm tham số BranchID để phân quyền theo chi nhánh
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 20
        NHANVIENID,               -- Cột 1: Tự động bắn vào ô Mã nhân viên (NHANVIENID)
        Tennv AS TENNHANVIEN,     -- Cột 2: Lấy Tennv đổi tên thành TENNHANVIEN để khớp với giao diện
        DIENTHOAI,                
        
        -- Các cột ẩn để Auto-fill
        ISNULL(Tenbophan, Bophanid) AS Bophanid,    -- Ép tên bộ phận vào ô Bophanid để hiện chữ
        DIACHI,             
        ISDANGHI,           
        NGAYSINH,           
        NGAYVAOLAM          
    FROM dmNhanvienView 
    WHERE (Tennv LIKE N'%' + @Keyword + '%' OR NHANVIENID LIKE '%' + @Keyword + '%')
      AND (@BranchID = '' OR Bophanid = @BranchID) -- Lọc theo chi nhánh (nếu có truyền)
END
GO
