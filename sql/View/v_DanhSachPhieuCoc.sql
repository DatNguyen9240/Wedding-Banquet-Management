USE [QLTiec]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- VIEW: Danh sách Biên nhận đặt cọc
-- Chức năng: Nối (JOIN) bảng tbmk_Biennhancoccho với bảng Khách hàng
-- Mục đích: Làm Data Source (TableName) cho màn hình Form Động frmBiennhancoccho
-- =============================================
IF EXISTS(SELECT * FROM sys.views WHERE name = 'v_DanhSachPhieuCoc' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW [dbo].[v_DanhSachPhieuCoc];
END
GO
CREATE VIEW [dbo].[v_DanhSachPhieuCoc] AS
SELECT 
    b.DocumentID,
    b.DocumentID AS MaChungTu,
    b.Makh AS Makh,
    b.SoBN AS SoPhieu,
    b.Thoigianid,
    b.Loaitiecid,
    b.Nhamngay,
    b.SobanManchinhthuc,
    b.SobanChaychinhthuc,
    b.SobanManduphong,
    b.SobanChayduphong,
    b.Ghichu,
    
    -- Lôi thông tin khách hàng từ bảng khác đắp vào đây
    k.Tenchure,
    k.Tencodau,
    k.DTchure,
    k.DTcodau,
    k.Diachi,
    k.Nguoigd,
    k.DienThoaiDaiDien,
    k.Mail,
    
    -- Cột tính toán Tên khách & Điện thoại
    CASE 
        WHEN k.Tenchure IS NOT NULL AND k.Tencodau IS NOT NULL THEN k.Tenchure + ' & ' + k.Tencodau
        ELSE ISNULL(k.Tenkh, N'Khách vãng lai')
    END AS TenKhachHang,
    
    ISNULL(k.Dienthoai, ISNULL(k.DTchure, k.DTcodau)) AS DienThoai,
    
    b.Ngaytochuc AS [NgayToChuc],
    ISNULL(b.Tongsoban, 0) AS SoBan,
    (
        SELECT TOP 1 s.Tensanhtiec 
        FROM tbmk_Biennhancocchosanhtiec bs 
        INNER JOIN dmSanhtiec s ON bs.Sanhtiecid = s.Sanhtiecid 
        WHERE bs.DocumentID = b.DocumentID
    ) AS SanhDat,
    ISNULL(
        CASE 
            WHEN ISNULL(b.Solan, 1) = 2 THEN (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentID = b.DocumentIDcu)
            ELSE b.Tongtien 
        END, 0
    ) AS DaCocVND,
    ISNULL(
        CASE 
            WHEN ISNULL(b.Solan, 1) = 2 THEN b.Tongtien
            ELSE (SELECT TOP 1 Tongtien FROM tbmk_Biennhancoccho WHERE DocumentIDcu = b.DocumentID AND Solan = 2)
        END, 0
    ) AS Sotiencochopdong,
    
    -- Cột Lần cọc để Form Sửa tự động điền (fill) vào dropdown
    b.Solan AS [Solan],
    
    -- Các cột mới cho việc in phiếu và nhập liệu
    b.TaiKhoanNo,
    b.TaiKhoanCo,
    b.Kemtheo,
    b.Lydo,
    b.HinhThuc,
    
    -- Thay đổi cột JsonSanhTiec thành Scalar ID (lấy sảnh đầu tiên/sảnh chính)
    -- Điều này giúp DynamicFormEngine.js khi mở form Sửa tự động mapping value trùng khớp với Mã sảnh của Dropdown
    (
        SELECT TOP 1 Sanhtiecid 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        ORDER BY IsSanhchinh DESC
    ) AS JsonSanhTiec,
    
    -- Cột JSON đầy đủ dự phòng nếu cần dùng sau này
    (
        SELECT Sanhtiecid, IsSanhchinh 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        FOR JSON PATH
    ) AS [_JsonSanhTiec],
    
    CASE
        WHEN b.IsHuy = 1 THEN N'Đã Hủy'
        WHEN b.IsKetthuc = 1 THEN N'Đã lên Hợp đồng'
        WHEN b.Solan = 2 THEN N'Đã cọc lần 2'
        ELSE N'Đã cọc lần 1'
    END AS TrangThai

FROM tbmk_Biennhancoccho b
LEFT JOIN dmkhachhang k ON b.Makh = k.Makh
WHERE ISNULL(b.IsDeleted, 0) = 0;
GO

-- Dạy cho Form Đặt Cọc biết: Hãy chọc vào cái View v_DanhSachPhieuCoc thay vì bảng gốc và dùng khóa chính DocumentID
UPDATE SY_FrmLstTbl 
SET TableName = 'v_DanhSachPhieuCoc', PrimaryKey = 'DocumentID'
WHERE FormID = 'frmBiennhancoccho';
GO

-- Đồng bộ hóa các trường giao diện
EXEC API_DongBoTruongGiaoDien @FormName = 'frmBiennhancoccho', @ObjectName = 'v_DanhSachPhieuCoc';
GO

-- Cấu hình ẩn trường Makh khỏi Add/Edit nhưng vẫn sinh input ẩn
UPDATE SY_FormatFields
SET ShowInForm = 0, ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Makh';
GO
