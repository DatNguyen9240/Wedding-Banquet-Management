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

-- 2. Cấu hình định tuyến cho Danh sách Đặt cọc trên giao diện chính (frmBiennhancoccho)
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBiennhancoccho', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@TuNgay=N''{TuNgay}'', @DenNgay=N''{DenNgay}'', @Keyword=N''{Keyword}'''
);

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBiennhancoccho', 
    'Save', 
    'API_LuuPhieuCoc', 
    '@DocumentID=N''{DocumentID}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{DiaChi}{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{Ngaytochuc}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{Tongtien}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'''
);

-- 3. Cấu hình định tuyến fallback cho in ấn mẫu Đặt cọc (frmBiennhancocchoancoccho)
-- (Do server.js định nghĩa loại mẫu 'dat_coc' map với list 'frmBiennhancocchoancoccho')
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmBiennhancocchoancoccho', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@Keyword=N''{Keyword}'''
);

-- 4. Cấu hình định tuyến fallback cho in ấn mẫu Phiếu thu (frmPhieuThu)
-- (Do server.js định nghĩa loại mẫu 'phieu_thu' map với list 'frmPhieuThu')
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'frmPhieuThu', 
    'View', 
    'API_DanhSachPhieuCoc', 
    '@Keyword=N''{Keyword}'''
);
