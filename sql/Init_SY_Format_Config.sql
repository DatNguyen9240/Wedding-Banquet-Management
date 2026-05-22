-- ==============================================================================
-- KỊCH BẢN CẤU HÌNH GIAO DIỆN BẰNG CÁC CỘT MỚI THÊM
-- (Chạy script này để cấu hình 3 cột bác vừa ALTER thành công)
-- ==============================================================================

-- 1. Cập nhật các cột hiển thị trên Form
UPDATE SY_FormatFields SET IsRequired = 1, FormPosition = 'grid', ShowInForm = 1 WHERE FieldName IN ('Tenchure', 'DTchure');
UPDATE SY_FormatFields SET IsRequired = 0, FormPosition = 'grid', ShowInForm = 1 WHERE FieldName IN ('Tencodau', 'DTcodau');
UPDATE SY_FormatFields SET IsRequired = 0, FormPosition = 'body', ShowInForm = 1 WHERE FieldName IN ('Mail', 'Diachi');

-- 2. Ẩn các cột thừa khỏi Form (Chỉ hiện ở bảng danh sách)
UPDATE SY_FormatFields SET ShowInForm = 0 WHERE FieldName IN ('Makh', 'Tenkh', 'SoLanThamQuan', 'SoHopDong', 'DienthoaiChung');

-- 3. Cập nhật chính xác FormName cho ĐÚNG các cột của Khách hàng
UPDATE SY_FormatFields SET FormName = NULL;
UPDATE SY_FormatFields 
SET FormName = 'frmCustomer' 
WHERE FieldName IN (
    'Tenchure', 'DTchure', 'Tencodau', 'DTcodau', 
    'Mail', 'Diachi', 'Makh', 'Tenkh', 
    'SoLanThamQuan', 'SoHopDong', 'DienthoaiChung'
);
GO
