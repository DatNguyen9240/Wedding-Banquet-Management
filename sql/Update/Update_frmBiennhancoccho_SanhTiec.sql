USE [QLTiec]
GO

-- =====================================================================
-- SQL CẤU HÌNH API DANH SÁCH SẢNH VÀ SELECT DROPDOWN TRÊN FORM ĐẶT CỌC
-- =====================================================================

-- 1. Đăng ký API_DanhSachSanh vào WA_API gateway định tuyến
DELETE FROM WA_API WHERE List = 'API_DanhSachSanh';

INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES (
    'API_DanhSachSanh', 
    'View', 
    'API_DanhSachSanh', 
    '@Keyword=N''{Keyword}'''
);

-- 2. Cấu hình trường JsonSanhTiec trong Form Builder thành dạng dropdown lấy từ API
UPDATE SY_FormatFields 
SET CaptionVN = N'Sảnh đặt',
    FormatID = 'sl',                                                   -- 'sl' = select dropdown
    FormPosition = 'form',                                             -- Hiển thị lên Form
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View', -- Nguồn API
    OrderNo = 22                                                       -- Thứ tự hiển thị trên form
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'JsonSanhTiec';

-- 3. Đăng ký và cấu hình trường Solan (Lần cọc) dưới dạng Static Dropdown trên Form
DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Solan';

INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, DataSource, ValidateRule)
VALUES (
    'frmBiennhancoccho', 
    'Solan', 
    N'Lần cọc', 
    'sl',                                 -- 'sl' = select dropdown
    'form',                               -- Hiện lên Form
    1,                                    -- Bắt buộc chọn
    25,                                   -- Thứ tự sắp xếp
    N'STATIC:1|Cọc lần 1,2|Cọc lần 2',    -- Danh sách tĩnh (có N để hỗ trợ Unicode tiếng Việt)
    NULL
);

-- 4. Cấu hình trường TrangThai (Trạng thái) hiển thị dạng Chỉ đọc (Read-only) trên Form Sửa
UPDATE SY_FormatFields
SET ShowInAdd = 0,
    ShowInEdit = 1,
    IsReadOnlyEdit = 1,
    OrderNo = 26
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TrangThai';

-- 5. Đảm bảo tên trường trong SY_FormatFields đồng bộ về chữ thường 'Diachi' (phù hợp với CSDL gốc và phieu_thu.docx)
UPDATE SY_FormatFields
SET FieldName = 'Diachi'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DiaChi';

-- 6. Ẩn các trường tính toán tự động khỏi Form (chỉ hiển thị trên Grid lưới)
UPDATE SY_FormatFields
SET ShowInAdd = 0,
    ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho'
  AND FieldName IN ('Makh', 'TenKhachHang', 'DienThoai', 'SoBan', 'SanhDat', 'DaCocVND', 'DocumentID', 'MaChungTu');

-- 7. Đảm bảo các trường nhập liệu thực tế được hiển thị trên Form
UPDATE SY_FormatFields
SET ShowInAdd = 1,
    ShowInEdit = 1
WHERE FormName = 'frmBiennhancoccho'
  AND FieldName IN (
    'Tenchure', 'Tencodau', 'DTchure', 'DTcodau', 'Diachi',
    'Nguoigd', 'DienThoaiDaiDien', 'Mail', 'Ngaytochuc', 
    'Thoigianid', 'Loaihinhtiecid', 'SobanManchinhthuc', 
    'SobanManduphong', 'SobanChaychinhthuc', 'SobanChayduphong', 
    'TongtienRaw', 'Ghichu'
  );

-- 8. Cấu hình Số phiếu (SoPhieu) là chỉ đọc khi sửa, không hiện khi thêm (vì tự động sinh)
UPDATE SY_FormatFields
SET ShowInAdd = 0,
    ShowInEdit = 1,
    IsReadOnlyEdit = 1,
    FormPosition = 'grid',
    OrderNo = 1
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SoPhieu';

-- 9. Đăng ký API Ca Tiệc và Loại Hình Tiệc vào WA_API gateway định tuyến
DELETE FROM WA_API WHERE List = 'API_DanhSachCaLam';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachCaLam', 'View', 'API_DanhSachCaLam', NULL);

DELETE FROM WA_API WHERE List = 'API_DanhSachLoaiHinhTiec';
INSERT INTO WA_API (List, Func, [SQL], Para)
VALUES ('API_DanhSachLoaiHinhTiec', 'View', 'API_DanhSachLoaiHinhTiec', NULL);

-- 10. Cấu hình Ca Tiệc (Thoigianid), Loại Hình Tiệc (Loaihinhtiecid) thành Select Dropdown và Ngày tổ chức (_Ngaytochuc) thành DatePicker
UPDATE SY_FormatFields
SET FormatID = 'dt'
WHERE FormName = 'frmBiennhancoccho' AND FieldName = '_Ngaytochuc';

UPDATE SY_FormatFields
SET FormatID = 'sl',
    FormPosition = 'form',
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View',
    OrderNo = 20
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Thoigianid';

UPDATE SY_FormatFields
SET FormatID = 'sl',
    FormPosition = 'form',
    DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View',
    OrderNo = 2
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaihinhtiecid';

-- 11. Cập nhật ánh xạ tham số (Parameter Mapping) trong cổng API WA_API
-- Khắc phục lỗi lệch tên trường giữa Frontend (Loaihinhtiecid, _Ngaytochuc, TongtienRaw) và Database
UPDATE WA_API
SET Para = '@DocumentID=N''{DocumentID}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{_Ngaytochuc}'', @Loaitiecid=N''{Loaihinhtiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{TongtienRaw}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'''
WHERE List = 'frmBiennhancoccho' AND Func = 'Save';

-- 12. Cấu hình hiển thị động (VisibleRule)
-- Ẩn Tên chú rể, Cô dâu, SĐT chú rể, Cô dâu khi loại hình tiệc KHÔNG PHẢI là Tiệc cưới
-- Chỉ cho phép hiển thị khi chọn đúng ID Tiệc cưới thực tế (blt000001 hoặc t01)
UPDATE SY_FormatFields
SET VisibleRule = 'Loaihinhtiecid=blt000001|t01'
WHERE FormName = 'frmBiennhancoccho' 
  AND FieldName IN ('Tenchure', 'Tencodau', 'DTchure', 'DTcodau');

-- 13. Cấu hình chia cột giao diện (Mỗi dòng 2 cột - FormPosition = '6')
-- Giúp giao diện gọn gàng, cân đối hơn thay vì mỗi dòng 1 ô kéo dài
UPDATE SY_FormatFields
SET FormPosition = '6'
WHERE FormName = 'frmBiennhancoccho'
  AND FieldName IN (
    'Tenchure', 'Tencodau',           -- Cặp 1: Chú rể - Cô dâu
    'DTchure', 'DTcodau',             -- Cặp 2: SĐT Chú rể - SĐT Cô dâu
    'Nguoigd', 'DienThoaiDaiDien',     -- Cặp 3: Người giao dịch - SĐT đại diện
    'Diachi', 'Mail',                 -- Cặp 4: Địa chỉ - Email
    'SobanManchinhthuc', 'SobanManduphong',  -- Cặp 5: Bàn mặn chính thức - dự phòng
    'SobanChaychinhthuc', 'SobanChayduphong',-- Cặp 6: Bàn chay chính thức - dự phòng
    '_Ngaytochuc', 'Thoigianid',      -- Cặp 7: Ngày tổ chức - Ca tiệc
    'Loaihinhtiecid', 'JsonSanhTiec', -- Cặp 8: Loại hình tiệc - Sảnh đặt
    'TongtienRaw', 'Solan'            -- Cặp 9: Số tiền cọc - Lần cọc
  );
GO

-- 14. Cấu hình hành động Xóa (Delete) trong cổng API WA_API cho frmBiennhancoccho
-- Khắc phục lỗi lệch tham số giữa Frontend (truyền object chứa id/MaChungTu trong JsonData) và Procedure (@DocumentIDs)
IF NOT EXISTS (SELECT 1 FROM WA_API WHERE List = 'frmBiennhancoccho' AND Func = 'Delete')
BEGIN
    INSERT INTO WA_API (List, Func, [SQL], Para)
    VALUES ('frmBiennhancoccho', 'Delete', 'API_XoaPhieuCoc', '@DocumentIDs=N''{id}''');
END
ELSE
BEGIN
    UPDATE WA_API
    SET [SQL] = 'API_XoaPhieuCoc',
        Para = '@DocumentIDs=N''{id}'''
    WHERE List = 'frmBiennhancoccho' AND Func = 'Delete';
END
GO
