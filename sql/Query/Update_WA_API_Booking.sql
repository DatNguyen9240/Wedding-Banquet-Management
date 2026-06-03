-- =====================================================================
-- SQL CẤU HÌNH WA_API CHO ĐẶT CỌC (BOOKING)
-- Đảm bảo Database gánh hết luồng xử lý định tuyến mà không cần sửa server.
-- =====================================================================

-- 1. Xóa cấu hình cũ (nếu có) để tránh trùng lặp
DELETE FROM WA_API 
WHERE (List = 'frmBiennhancoccho' AND Func IN ('View', 'Save'))
   OR (List = 'frmBiennhancocchoancoccho' AND Func = 'View')
   OR (List = 'frmPhieuThu' AND Func = 'View');

-- Cập nhật tên trường Diachi để đồng bộ đúng chữ hoa chữ thường (phải là Diachi viết thường chữ c)
UPDATE SY_FormatFields 
SET FieldName = 'Diachi' 
WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DiaChi';

-- 2. Cấu hình định tuyến cho Danh sách Đặt cọc (frmBiennhancoccho), các mẫu in, và dropdown lists
DELETE FROM WA_API WHERE List IN ('API_DanhSachCaLam', 'API_DanhSachSanh', 'API_DanhSachLoaiHinhTiec') OR (List = 'frmBiennhancoccho' AND Func IN ('View', 'Save')) OR (List = 'frmBiennhancocchoancoccho' AND Func = 'View') OR (List = 'frmPhieuThu' AND Func = 'View');

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
    '@DocumentID=N''{DocumentID}'', @Tenchure=N''{Tenchure}'', @Tencodau=N''{Tencodau}'', @DTchure=N''{DTchure}'', @DTcodau=N''{DTcodau}'', @Diachi=N''{Diachi}'', @Nguoigd=N''{Nguoigd}'', @DienThoaiDaiDien=N''{DienThoaiDaiDien}'', @Mail=N''{Mail}'', @Ngaytochuc=N''{NgayToChuc}'', @Loaitiecid=N''{Loaitiecid}'', @Thoigianid=N''{Thoigianid}'', @SobanManchinhthuc=N''{SobanManchinhthuc}'', @SobanManduphong=N''{SobanManduphong}'', @SobanChaychinhthuc=N''{SobanChaychinhthuc}'', @SobanChayduphong=N''{SobanChayduphong}'', @Tongtien=N''{DaCocVND}'', @Solan=N''{Solan}'', @Ghichu=N''{Ghichu}'', @JsonSanhTiec=N''{JsonSanhTiec}'', @TaiKhoanNo=N''{TaiKhoanNo}'', @TaiKhoanCo=N''{TaiKhoanCo}'', @Kemtheo=N''{Kemtheo}'', @Lydo=N''{Lydo}'', @HinhThuc=N''{HinhThuc}'''
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
),
(
    'API_DanhSachCaLam',
    'View',
    'API_DanhSachCaLam',
    NULL
),
(
    'API_DanhSachSanh',
    'View',
    'API_DanhSachSanh',
    '@Keyword=N''{Keyword}'''
),
(
    'API_DanhSachLoaiHinhTiec',
    'View',
    'API_DanhSachLoaiHinhTiec',
    NULL
);

-- Dọn dẹp trường Sotiencoccho dư thừa khỏi cấu hình Đặt cọc
DELETE FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Sotiencoccho';
GO

-- Ẩn các trường tính toán hoặc không cần nhập trên Form nhập liệu (Chỉ hiện ở Grid)
UPDATE SY_FormatFields
SET ShowInAdd = 0, ShowInEdit = 0
WHERE FormName = 'frmBiennhancoccho' AND FieldName IN ('TenKhachHang', 'DienThoai', 'SoBan', 'SanhDat');

-- Cập nhật vị trí hiển thị (FormPosition: 12/6/4/3) và thứ tự sắp xếp (OrderNo)
-- Nhóm 1: Thông tin liên hệ
UPDATE SY_FormatFields SET CaptionVN = N'Người giao dịch', FormPosition = '6', OrderNo = 1, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nguoigd';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT đại diện', FormPosition = '6', OrderNo = 2, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DienThoaiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể', FormPosition = '6', OrderNo = 3, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu', FormPosition = '6', OrderNo = 4, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT chú rể', FormPosition = '6', OrderNo = 5, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTchure';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT cô dâu', FormPosition = '6', OrderNo = 6, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTcodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ', FormPosition = '6', OrderNo = 7, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Email', FormPosition = '6', OrderNo = 8, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0 WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Mail';

-- Nhóm 2: Thông tin tiệc và sảnh
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tổ chức', FormPosition = '6', OrderNo = 9, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'dt', validateRule = 'trigger:/api/API_Gateway_Router?List=API_TinhLichAm&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'NgayToChuc';
UPDATE SY_FormatFields SET CaptionVN = N'Nhằm ngày (Âm lịch)', FormPosition = '6', OrderNo = 10, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 1, IsReadOnlyEdit = 1, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nhamngay';
UPDATE SY_FormatFields SET CaptionVN = N'Ca tiệc', FormPosition = '6', OrderNo = 11, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachCaLam&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Loại tiệc', FormPosition = '6', OrderNo = 12, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachLoaiHinhTiec&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Sảnh đặt', FormPosition = '6', OrderNo = 13, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sl', DataSource = '/api/API_Gateway_Router?List=API_DanhSachSanh&Func=View' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'JsonSanhTiec';

-- Đảm bảo trường DaCocVND (Số tiền cọc) được hiển thị và cho phép nhập dạng số
IF EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DaCocVND')
BEGIN
    UPDATE SY_FormatFields 
    SET CaptionVN = N'Số tiền cọc',
        FormatID = 'n',
        ShowInAdd = 1,
        ShowInEdit = 1,
        IsReadOnlyAdd = 0,
        IsReadOnlyEdit = 0,
        FormPosition = '6',
        OrderNo = 14
    WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DaCocVND';
END
ELSE
BEGIN
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit)
    VALUES ('frmBiennhancoccho', 'DaCocVND', N'Số tiền cọc', 'n', '6', 1, 14, 1, 1, 0, 0);
END

-- Nhóm 3: Số bàn (mỗi ô chiếm 1/4 dòng = df-col-3 để nằm gọn trên 1 hàng ngang)
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn mặn chính', FormPosition = '3', OrderNo = 15, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng', FormPosition = '3', OrderNo = 16, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn chay chính', FormPosition = '3', OrderNo = 17, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng', FormPosition = '3', OrderNo = 18, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'n' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChayduphong';

-- Nhóm 4: Hạch toán và thanh toán (Mỗi ô chiếm 1/3 dòng = df-col-4 nằm gọn trên 1 hàng ngang)
UPDATE SY_FormatFields SET CaptionVN = N'Hình thức thanh toán', FormPosition = '4', OrderNo = 19, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sl', DataSource = N'STATIC:Tiền mặt|Tiền mặt,Chuyển khoản|Chuyển khoản,Tiền mặt / Chuyển khoản|Tiền mặt / Chuyển khoản' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'HinhThuc';
UPDATE SY_FormatFields SET CaptionVN = N'Tài khoản Nợ', FormPosition = '4', OrderNo = 20, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TaiKhoanNo';
UPDATE SY_FormatFields SET CaptionVN = N'Tài khoản Có', FormPosition = '4', OrderNo = 21, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'TaiKhoanCo';

-- Nhóm 5: Ghi chú, lý do và hồ sơ kèm theo
UPDATE SY_FormatFields SET CaptionVN = N'Lý do nộp tiền', FormPosition = '6', OrderNo = 22, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Lydo';
UPDATE SY_FormatFields SET CaptionVN = N'Kèm theo chứng từ', FormPosition = '6', OrderNo = 23, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Kemtheo';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú', FormPosition = '12', OrderNo = 24, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 't' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Ghichu';

-- Cập nhật lần cọc thành dạng dropdown cho phép chọn (hiển thị ở cả Thêm mới và Sửa)
UPDATE SY_FormatFields SET CaptionVN = N'Lần cọc', FormPosition = '6', OrderNo = 25, ShowInAdd = 1, ShowInEdit = 1, IsReadOnlyAdd = 0, IsReadOnlyEdit = 0, FormatID = 'sl', DataSource = N'STATIC:1|Cọc lần 1,2|Cọc lần 2' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Solan';

-- Cấu hình hiển thị động (VisibleRule) cho các trường Chú rể / Cô dâu
-- Chỉ hiển thị khi chọn loại tiệc là Tiệc cưới (blt000001 hoặc t01)
UPDATE SY_FormatFields
SET VisibleRule = 'Loaitiecid=blt000001|t01'
WHERE FormName = 'frmBiennhancoccho' 
  AND FieldName IN ('Tenchure', 'Tencodau', 'DTchure', 'DTcodau');
