-- =====================================================================
-- SQL CẤU HÌNH WA_API CHO ĐẶT CỌC (BOOKING)
-- Đảm bảo Database gánh hết luồng xử lý định tuyến mà không cần sửa server.
-- =====================================================================

-- 1. Xóa cấu hình cũ (nếu có) để tránh trùng lặp
DELETE FROM WA_API 
WHERE (List = 'frmBiennhancoccho' AND Func IN ('View', 'Save'))
   OR (List = 'frmBiennhancocchoancoccho' AND Func = 'View')
   OR (List = 'frmPhieuThu' AND Func = 'View');

-- Cập nhật tên trường Diachi sang DiaChi để chuẩn hóa chữ hoa chữ thường
UPDATE SY_FormatFields 
SET FieldName = 'DiaChi' 
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Diachi';

-- 2. Cấu hình định tuyến cho Danh sách Đặt cọc (frmBiennhancoccho) và các mẫu in (frmBiennhancocchoancoccho, frmPhieuThu)
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES 
(
    'frmBiennhancoccho', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@TuNgay=N''{TuNgay}'', @DenNgay=N''{DenNgay}'', @Keyword=N''{Keyword}'''
),
(
    'frmBiennhancoccho', 
    'Save', 
    'API_LuuPhieuCoc', 
    '@DocumentID=N''{DocumentID}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{DiaChi}{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{Ngaytochuc}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{Tongtien}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'''
),
(
    'frmBiennhancocchoancoccho', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@Keyword=N''{Keyword}'''
),
(
    'frmPhieuThu', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@Keyword=N''{Keyword}'''
);
