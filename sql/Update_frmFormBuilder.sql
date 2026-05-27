USE [QLTiec]
GO

-- 1. Cập nhật Tiêu đề hiển thị (CaptionVN) cho các trường của Form Builder
UPDATE SY_FormatFields SET CaptionVN = N'Mã Form' WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormName';
UPDATE SY_FormatFields SET CaptionVN = N'Tên Trường (Database)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'FieldName';
UPDATE SY_FormatFields SET CaptionVN = N'Tiêu đề (Hiển thị)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'CaptionVN';
UPDATE SY_FormatFields SET CaptionVN = N'Tiêu đề (Tiếng Anh)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'CaptionEN';
UPDATE SY_FormatFields SET CaptionVN = N'Loại Input' WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID';
UPDATE SY_FormatFields SET CaptionVN = N'Nguồn Dữ Liệu (API/Static)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'DataSource';
UPDATE SY_FormatFields SET CaptionVN = N'Bắt buộc nhập' WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsRequired';
UPDATE SY_FormatFields SET CaptionVN = N'Kích thước hiển thị' WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition';
UPDATE SY_FormatFields SET CaptionVN = N'Hiện khi Thêm' WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInAdd';
UPDATE SY_FormatFields SET CaptionVN = N'Hiện khi Sửa' WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInEdit';
UPDATE SY_FormatFields SET CaptionVN = N'Chỉ đọc khi Thêm' WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsReadOnlyAdd';
UPDATE SY_FormatFields SET CaptionVN = N'Chỉ đọc khi Sửa' WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsReadOnlyEdit';
UPDATE SY_FormatFields SET CaptionVN = N'Quy tắc hiển thị (JS)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'VisibleRule';
UPDATE SY_FormatFields SET CaptionVN = N'Ràng buộc dữ liệu (JS)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'ValidateRule';
UPDATE SY_FormatFields SET CaptionVN = N'Trường phụ thuộc' WHERE FormName = 'frmFormBuilder' AND FieldName = 'DependsOn';
UPDATE SY_FormatFields SET CaptionVN = N'Thứ tự ưu tiên' WHERE FormName = 'frmFormBuilder' AND FieldName = 'OrderNo';

-- 2. Cập nhật FormatID (Loại Input) để giao diện thêm phần sinh động và tiện dụng
-- Các trường Boolean (Tắt/Bật)
UPDATE SY_FormatFields SET FormatID = 'sw' 
WHERE FormName = 'frmFormBuilder' AND FieldName IN ('IsRequired', 'ShowInAdd', 'ShowInEdit', 'IsReadOnlyAdd', 'IsReadOnlyEdit');

-- Khung chọn Loại Input (Select)
UPDATE SY_FormatFields SET FormatID = 'sl', DataSource = N'STATIC:t|Văn bản (Text),n|Số (Number),dt|Ngày (Date),sw|Bật/Tắt (Switch),sl|Danh sách chọn (Select)' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID';

-- Khung chọn Kích thước hiển thị (Select)
UPDATE SY_FormatFields SET FormatID = 'sl', DataSource = N'STATIC:12|Đầy đủ 100% (Full),6|Một nửa 50% (Half),4|1/3 Chiều rộng,3|1/4 Chiều rộng' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition';

-- Cột số thứ tự
UPDATE SY_FormatFields SET FormatID = 'nm' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'OrderNo';

-- 3. Cập nhật FormPosition để dàn layout cho gọn gàng (2 ô 1 hàng)
UPDATE SY_FormatFields SET FormPosition = '6' 
WHERE FormName = 'frmFormBuilder' AND FieldName IN (
    'FormName', 'FieldName', 'CaptionVN', 'CaptionEN', 
    'FormatID', 'FormPosition', 'OrderNo', 'IsRequired'
);

-- Các trường tuỳ chọn logic cho chiếm cả hàng
UPDATE SY_FormatFields SET FormPosition = '12' 
WHERE FormName = 'frmFormBuilder' AND FieldName IN ('DataSource', 'VisibleRule', 'ValidateRule', 'DependsOn');

-- 4. Xóa lỗi Dummy records (Các trường 01, 02 bị đẩy vào do lỗi import nếu có)
DELETE FROM SY_FormatFields WHERE FormName = '' AND FieldName IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15');

GO
