USE [QLTiec]
GO

-- 1. Tạo bảng trung gian tbmk_LoaitiecAddfile (Bảng cấu hình Mẫu In Động)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tbmk_LoaitiecAddfile]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[tbmk_LoaitiecAddfile] (
        [ID] INT IDENTITY(1,1) PRIMARY KEY,
        [FormName] VARCHAR(50) NOT NULL,        -- VD: 'frmHopDong', 'frmQuyetToan', 'frmBiennhancoccho'
        [Loaitiecid] VARCHAR(20) NOT NULL,      -- VD: 'BLT000001'
        [TemplateFile] NVARCHAR(255) NOT NULL,  -- Đã đổi thành NVARCHAR để hỗ trợ tiếng Việt có dấu
        [GhiChu] NVARCHAR(255) NULL             -- Ghi chú cho dễ quản lý
    )
END
ELSE
BEGIN
    -- Fix lỗi thiếu NVARCHAR nếu bảng đã lỡ tạo trước đó
    ALTER TABLE [dbo].[tbmk_LoaitiecAddfile] ALTER COLUMN [TemplateFile] NVARCHAR(255) NOT NULL;
END
GO

-- Xóa dữ liệu cũ của frmHopDong để insert lại cho chuẩn
DELETE FROM tbmk_LoaitiecAddfile WHERE FormName = 'frmHopDong';

-- 2. Insert dữ liệu Mapping cho trang Hợp Đồng (Nhớ thêm chữ N đằng trước để giữ dấu tiếng Việt)
INSERT INTO tbmk_LoaitiecAddfile (FormName, Loaitiecid, TemplateFile, GhiChu)
VALUES 
('frmHopDong', 'BLT000001', N'hop_dong', N'Mẫu in hợp đồng Tiệc Cưới'),
('frmHopDong', 'BLT000002', N'2.1 MAU HDONG - 0406 (TRIỂN LÃM + TIỆC)', N'Mẫu in hợp đồng Triển lãm + Tiệc'),
('frmHopDong', 'BLT000003', N'2.2 MAU HDONG - 0406 (TRIỂN LÃM)', N'Mẫu in hợp đồng Triển lãm'),
('frmHopDong', 'BLT000004', N'3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK)', N'Mẫu in hợp đồng Hội nghị + Break Tea'),
('frmHopDong', 'BLT000005', N'3.2 MAU HDONG - 0406 (HỘI NGHỊ )', N'Mẫu in hợp đồng Hội nghị');
GO
