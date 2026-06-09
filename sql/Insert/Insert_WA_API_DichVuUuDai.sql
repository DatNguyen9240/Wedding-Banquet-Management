-- =========================================================================
-- Đăng ký API Lấy dịch vụ ưu đãi theo loại tiệc & số lượng bàn vào API Gateway
-- =========================================================================

-- Xóa cấu hình cũ nếu có
DELETE FROM WA_API WHERE list = 'DichVuUuDai' AND func = 'View';

-- Thêm cấu hình mới
INSERT INTO WA_API (list, func, [SQL], Para)
VALUES (
    'DichVuUuDai', 
    'View', 
    'API_LayDichVuUuDaiTheoLoaiTiec', 
    '@Loaitiecid=''{Loaitiecid}'', @Soluongban={Soluongban}, @Nhahangid=''{BranchID}'''
);
GO
