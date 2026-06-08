-- =========================================================
-- 1. THÊM CÁC CỘT MỚI VÀO BẢNG SẢNH TIỆC (NẾU CHƯA CÓ)
-- =========================================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[dmSanhtiec]') AND name = 'ChieuCaoTran')
BEGIN
    ALTER TABLE [dbo].[dmSanhtiec] ADD 
        [ChieuCaoTran] [float] NULL,         -- Chiều cao trần (m)
        [ChieuRong] [float] NULL,            -- Chiều rộng (m)
        [ChieuDai] [float] NULL,             -- Chiều dài (m)
        [DienTich] [float] NULL,             -- M2
        [KTSanKhau] [nvarchar](255) NULL,    -- Kích thước sân khấu
        [ClassRoom] [int] NULL,              -- Sức chứa kiểu lớp học
        [Theater] [int] NULL,                -- Sức chứa kiểu nhà hát
        [ClusterHalfRound] [int] NULL,       -- Kiểu bàn tròn xoay về 1 phía
        [PhongMan] [nvarchar](100) NULL;     -- Phông màn (Trắng/Đen)
END
GO

