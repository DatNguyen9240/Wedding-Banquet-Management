USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- VIEW: Danh sách Khách Tham Quan (Visitor)
-- Mục đích: Làm Data Source (TableName) cho màn hình Form Động frmKhachThamQuan
-- =============================================
CREATE OR ALTER VIEW [dbo].[v_DanhSachKhachThamQuan] AS
SELECT 
    v.DocumentID,
    v.DocumentID AS [MaPhieu],
    v.Tenkh AS [TenKhachHang],
    v.Dienthoai AS [DienThoai],
    
    v.Ngaytochuc AS [NgayToChucGoc],
    CONVERT(VARCHAR(10), v.Ngaytochuc, 103) AS [NgayDuKien],
    v.Nhamngay AS [NgayAmLich],
    
    v.Tenloaitiec AS [GoiTiec],
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Khachthamquansanhtiec bs 
        INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
        WHERE bs.DocumentID = v.DocumentID
    ) AS [SanhTiec],
    
    CASE
        WHEN v.IsHuy = 1 THEN N'Đã Hủy'
        WHEN v.IsKetthuc = 1 THEN N'Đã Đặt Cọc'
        ELSE N'Đang Tư Vấn'
    END AS [TrangThai]
    
FROM SelectKhachThamQuanView v;
GO

-- Cập nhật Form Khách Tham Quan chọc vào View này
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachKhachThamQuan' 
WHERE FormID = 'frmKhachThamQuan';
GO
