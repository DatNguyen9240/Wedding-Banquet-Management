USE [QLTiec];
GO

PRINT N'Đang cập nhật View v_DanhSachPhieuCoc với định dạng cột NgayToChuc chuẩn...';
GO
IF EXISTS(SELECT * FROM sys.views WHERE name = 'v_DanhSachPhieuCoc' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP VIEW [dbo].[v_DanhSachPhieuCoc];
END
GO
CREATE VIEW [dbo].[v_DanhSachPhieuCoc] AS
SELECT 
    b.DocumentID,
    b.DocumentID AS MaChungTu,
    b.SoBN AS SoPhieu,
    b.Thoigianid,
    b.Loaitiecid,
    b.Nhamngay,
    b.SobanManchinhthuc,
    b.SobanChaychinhthuc,
    b.SobanManduphong,
    b.SobanChayduphong,
    b.Ghichu,
    
    k.Tenchure,
    k.Tencodau,
    k.DTchure,
    k.DTcodau,
    k.Diachi,
    k.Nguoigd,
    k.DienThoaiDaiDien,
    k.Mail,
    
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
    ISNULL(b.Tongtien, 0) AS DaCocVND,
    
    b.Solan AS [Solan],
    b.TaiKhoanNo,
    b.TaiKhoanCo,
    b.Kemtheo,
    b.Lydo,
    b.HinhThuc,
    
    (
        SELECT TOP 1 Sanhtiecid 
        FROM tbmk_Biennhancocchosanhtiec 
        WHERE DocumentID = b.DocumentID 
        ORDER BY IsSanhchinh DESC
    ) AS JsonSanhTiec,
    
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
LEFT JOIN dmkhachhang k ON b.Makh = k.Makh;
GO

PRINT N'Đang đồng bộ và phục hồi các trường từ View...';
GO
EXEC API_DongBoTruongGiaoDien @FormName = 'frmHopDong', @ObjectName = 'v_DanhSachHopDong';
EXEC API_DongBoTruongGiaoDien @FormName = 'frmBiennhancoccho', @ObjectName = 'v_DanhSachPhieuCoc';
GO

PRINT N'Đang đồng bộ hóa tên trường Ngày tổ chức về duy nhất NgayToChuc...';
GO

-- Đồng bộ hóa tên trường "Ngày tổ chức" về duy nhất "NgayToChuc" (chữ hoa chữ T) cho frmHopDong
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS)
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc' COLLATE Latin1_General_CS_AS)
        DELETE FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS;
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS;
END
GO
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS)
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc' COLLATE Latin1_General_CS_AS)
        DELETE FROM SY_FormatFields WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS;
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmHopDong' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS;
END
GO

-- Đồng bộ hóa tên trường "Ngày tổ chức" về duy nhất "NgayToChuc" (chữ hoa chữ T) cho frmBiennhancoccho
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS)
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc' COLLATE Latin1_General_CS_AS)
        DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS;
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ngaytochuc' COLLATE Latin1_General_CS_AS;
END
GO
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS)
BEGIN
    IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc' COLLATE Latin1_General_CS_AS)
        DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS;
    ELSE
        UPDATE SY_FormatFields SET FieldName = 'NgayToChuc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc' COLLATE Latin1_General_CS_AS;
END
GO

-- Đảm bảo hiển thị trường NgayToChuc trên Form cho cả 2 biểu mẫu
UPDATE SY_FormatFields 
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, FormPosition = '6'
WHERE FormName IN ('frmHopDong', 'frmBiennhancoccho') AND FieldName = 'NgayToChuc';
GO

PRINT N'Đang cập nhật định dạng trường trong SY_FormatFields...';

-- 1. Cập nhật các trường ngày sang định dạng 'dt' (date picker) và nhãn tiếng Việt
-- Phân hệ Hợp đồng (frmHopDong)
UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày tổ chức'
WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';

UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày lập HĐ'
WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';

-- Phân hệ Biên nhận cọc (frmBiennhancoccho)
UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày tổ chức'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';

UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày lập cọc'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DocumentDate';

-- Phân hệ Quyết toán (frmQuyetToan)
UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày lập quyết toán'
WHERE FormName = 'frmQuyetToan' AND FieldName = 'DocumentDate';

UPDATE SY_FormatFields 
SET FormatID = 'dt', CaptionVN = N'Ngày thu'
WHERE FormName = 'frmQuyetToan' AND FieldName = 'Ngaythu';

-- 2. Đổi định dạng Nhằm ngày âm lịch (Nhamngay) sang 't' (Văn bản thường) và đặt Read-Only (không cho sửa tay)
UPDATE SY_FormatFields 
SET FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';

UPDATE SY_FormatFields 
SET FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';

-- 3. Cập nhật Quy tắc Trigger (ValidateRule) để tự động gọi API tính lịch âm khi chọn Ngày tổ chức
-- Hợp đồng (frmHopDong)
UPDATE SY_FormatFields
SET ValidateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';

-- Biên nhận cọc (frmBiennhancoccho)
UPDATE SY_FormatFields
SET ValidateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';

-- 4. Ẩn/Hiện và khóa (Read-Only) các trường mã tự sinh bởi database
-- Biên nhận cọc (frmBiennhancoccho)
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SoPhieu';

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName IN ('DocumentID', 'MaChungTu', 'Makh', '_JsonSanhTiec');

-- Hợp đồng (frmHopDong)
UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sohopdong';

UPDATE SY_FormatFields 
SET IsReadOnlyAdd = 1, IsReadOnlyEdit = 1
WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';

UPDATE SY_FormatFields 
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmHopDong' AND FieldName IN ('Makh', '_JsonSanhTiec');

-- 5. Cấu hình kề nhau và chia cột (FormPosition = '6') cho Ngày tổ chức & Nhằm ngày
-- Hợp đồng (frmHopDong)
UPDATE SY_FormatFields 
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, CaptionVN = N'Nhằm ngày'
WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';

UPDATE SY_FormatFields SET OrderNo = 2, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Sobiennhan';
UPDATE SY_FormatFields SET OrderNo = 3, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Ngayhopdong';
UPDATE SY_FormatFields SET OrderNo = 4, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 5, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 6, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'DienThoai';
UPDATE SY_FormatFields SET OrderNo = 7, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 8, FormPosition = 'form' WHERE FormName = 'frmHopDong' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 9, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 10, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 11, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 12, FormPosition = '6' WHERE FormName = 'frmHopDong' AND FieldName = 'Thoigianid';

-- Biên nhận cọc (frmBiennhancoccho)
UPDATE SY_FormatFields 
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1, FormatID = 't', IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, CaptionVN = N'Nhằm ngày'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';

UPDATE SY_FormatFields SET OrderNo = 4, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET OrderNo = 5, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET OrderNo = 6, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTchure';
UPDATE SY_FormatFields SET OrderNo = 7, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTcodau';
UPDATE SY_FormatFields SET OrderNo = 8, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nguoigd';
UPDATE SY_FormatFields SET OrderNo = 9, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DienThoaiDaiDien';
UPDATE SY_FormatFields SET OrderNo = 10, FormPosition = 'form' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET OrderNo = 11, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET OrderNo = 12, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET OrderNo = 13, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET OrderNo = 14, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET OrderNo = 15, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET OrderNo = 16, FormPosition = '6', ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'JsonSanhTiec';
UPDATE SY_FormatFields SET OrderNo = 17, FormPosition = '6' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TongTienRaw';

-- Đảm bảo trường Sảnh đặt (JsonSanhTiec) hiển thị trên cả 2 phân hệ Hợp đồng & Đặt cọc
UPDATE SY_FormatFields 
SET ShowInForm = 1, ShowInAdd = 1, ShowInEdit = 1
WHERE FormName IN ('frmHopDong', 'frmBiennhancoccho') AND FieldName = 'JsonSanhTiec';

-- 6. Đồng bộ hóa lịch âm Nhằm ngày cho các bản ghi đã lưu sẵn trong CSDL
PRINT N'Đang đồng bộ hóa dữ liệu Nhằm ngày lịch âm cho các bản ghi cũ...';
UPDATE tbmk_Hopdong
SET Nhamngay = dbo.fn_SolarToLunar(Ngaytochuc)
WHERE Ngaytochuc IS NOT NULL;

UPDATE tbmk_Biennhancoccho
SET Nhamngay = dbo.fn_SolarToLunar(Ngaytochuc)
WHERE Ngaytochuc IS NOT NULL;

PRINT N'Cập nhật định dạng ngày, quy tắc trigger, các trường mã, căn lề giao diện và đồng bộ dữ liệu cũ thành công!';
GO

IF OBJECT_ID('dbo.API_TinhLichAm', 'P') IS NOT NULL
    DROP PROCEDURE dbo.API_TinhLichAm;
GO

CREATE PROCEDURE [dbo].[API_TinhLichAm]
    @JsonData NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NgayToChuc NVARCHAR(50) = NULL;
    
    -- Trích xuất ngày tổ chức từ JSON (hỗ trợ cả NgayToChuc và ngaytochuc)
    IF @JsonData IS NOT NULL AND ISJSON(@JsonData) = 1
    BEGIN
        SELECT @NgayToChuc = COALESCE(
            JSON_VALUE(@JsonData, '$.NgayToChuc'),
            JSON_VALUE(@JsonData, '$.Ngaytochuc'),
            JSON_VALUE(@JsonData, '$.ngaytochuc')
        );
    END
    
    DECLARE @LunarDate NVARCHAR(50) = '';
    DECLARE @ParsedDate DATE = NULL;
    
    IF @NgayToChuc IS NOT NULL AND @NgayToChuc <> ''
    BEGIN
        -- 1. Nếu định dạng có dấu gạch chéo (/), thử parse theo kiểu dd/MM/yyyy (Style 103) trước
        IF @NgayToChuc LIKE '%/%/%'
        BEGIN
            SET @ParsedDate = TRY_CONVERT(DATE, @NgayToChuc, 103);
        END
        
        -- 2. Nếu thất bại hoặc không phải dạng /, thử cast trực tiếp (ISO YYYY-MM-DD)
        IF @ParsedDate IS NULL
        BEGIN
            SET @ParsedDate = TRY_CAST(@NgayToChuc AS DATE);
        END
        
        -- 3. Thử kiểu yyyy/MM/dd (Style 111)
        IF @ParsedDate IS NULL
        BEGIN
            SET @ParsedDate = TRY_CONVERT(DATE, @NgayToChuc, 111);
        END
    END
    
    IF @ParsedDate IS NOT NULL
    BEGIN
        SET @LunarDate = dbo.fn_SolarToLunar(@ParsedDate);
    END
    
    -- Trả về trường Nhamngay tương ứng với ô nhập trên form
    SELECT @LunarDate AS [Nhamngay];
END;
GO

PRINT N'Cập nhật Stored Procedure API_TinhLichAm thành công!';
GO
