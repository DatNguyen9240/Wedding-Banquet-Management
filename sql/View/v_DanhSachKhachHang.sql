USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- VIEW: Danh sách Khách Hàng (Customer)
-- Mục đích: Cung cấp đầy đủ dữ liệu (kể cả các cột tính toán như SoHopDong, SoLanThamQuan) 
-- cho màn hình Form Động frmCustomer
-- =============================================
CREATE OR ALTER VIEW [dbo].[v_DanhSachKhachHang] AS
SELECT 
    Makh,
    Makh AS [Id], -- Alias để Frontend dễ nhận diện khóa chính nếu cần
    Tenchure,
    DTchure,
    Tencodau,
    DTcodau,
    Tenkh,
    ISNULL(NULLIF(Dienthoai, ''), ISNULL(DTchure, DTcodau)) AS DienthoaiChung,
    Mail,
    Diachi,
    (SELECT COUNT(1) FROM tbmk_Khachthamquan WHERE Makh = dmkhachhang.Makh) AS SoLanThamQuan,
    (SELECT COUNT(1) FROM tbmk_Hopdong WHERE Makh = dmkhachhang.Makh) AS SoHopDong
FROM dmkhachhang
WHERE ISNULL(IsDeleted, 0) = 0;
GO



-- 2. Đồng bộ lại cấu hình các cột giao diện từ View
EXEC API_DongBoTruongGiaoDien @FormName = 'frmCustomer', @ObjectName = 'v_DanhSachKhachHang';
GO
