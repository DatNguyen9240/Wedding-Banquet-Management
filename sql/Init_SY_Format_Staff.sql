-- ==========================================================
-- BƯỚC 0: KIỂM TRA CỘT THẬT TRONG DATABASE
-- Bôi đen đoạn dưới đây và F5 để xem bảng Nhân Viên tên thật là gì, có những cột nào
-- ==========================================================
-- SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME LIKE '%nhanvien%' OR TABLE_NAME LIKE '%staff%'
-- ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ==========================================================
-- SCRIPT KHỞI TẠO CẤU HÌNH GIAO DIỆN CHO TRANG NHÂN VIÊN
-- Lưu ý: Hãy sửa lại chữ 'MaNV', 'TenNV'... ở dưới cho khớp với COLUMN_NAME ở bảng trên!
-- ==========================================================

-- 1. Bảng SY_FormatFields có UNIQUE INDEX trên FieldName, nên ta không INSERT mà chỉ UPDATE
UPDATE SY_FormatFields 
SET FormName = 'frmStaff'
WHERE FieldName IN (
    'NHANVIENID', 'TENNHANVIEN', 'IsGioitinh', 
    'DIENTHOAI', 'NGAYSINH', 'DIACHI', 
    'NGAYVAOLAM', 'ISDANGHI', 'Bophanid'
);

GO
-- ==========================================================
-- TEST: Chạy thử xem cấu hình lấy lên đúng chưa
-- EXEC [dbo].[API_LayCacTruongGiaoDien] @FormName = 'frmStaff';
-- ==========================================================
