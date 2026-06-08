-- =========================================================
-- 1. THÊM CỘT [KieuSetup] VÀO BẢNG tbmk_Hopdongsanhtiec (Nếu chưa có)
-- =========================================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_Hopdongsanhtiec]') AND name = 'KieuSetup')
BEGIN
    ALTER TABLE [dbo].[tbmk_Hopdongsanhtiec] ADD [KieuSetup] VARCHAR(50) NULL;
END
GO

-- =========================================================
-- 2. ĐỔI CỘT CHỌN SẢNH [JsonSanhTiec] TRÊN MÀN HÌNH frmHopDong THÀNH BẢNG (GRID)
-- =========================================================
-- Mở rộng độ dài cột DataSource để chứa được chuỗi JSON cấu hình Grid dài
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[SY_FormatFields]') AND name = 'DataSource')
BEGIN
    ALTER TABLE [dbo].[SY_FormatFields] ALTER COLUMN [DataSource] NVARCHAR(MAX) NULL;
END
GO

UPDATE SY_FormatFields 
SET 
    FormatID = 'js', 
    DataSource = N'[{"key":"Sanhtiecid","label":"Sảnh Tiệc","type":"select","dataSource":"/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View","width":"150px"},{"key":"IsSanhchinh","label":"Sảnh Chính?","type":"checkbox","width":"80px"},{"key":"KieuSetup","label":"Kiểu Setup","type":"select","options":[{"id":"Banquet","name":"Bàn Tròn"},{"id":"ClassRoom","name":"Lớp Học"},{"id":"Theater","name":"Nhà Hát"},{"id":"Cluster","name":"Bàn Xoay"}],"width":"150px"},{"key":"Ghichuct","label":"Màu sắc","type":"text","width":"auto"}]', 
    FormPosition = '12', -- Di chuyển xuống vùng Bottom cùng với Lịch trình BEO
    OrderNo = 26 -- Đặt thứ tự ngay trên Lịch trình BEO
WHERE FormName = 'frmHopDong' AND FieldName = 'JsonSanhTiec';
GO
