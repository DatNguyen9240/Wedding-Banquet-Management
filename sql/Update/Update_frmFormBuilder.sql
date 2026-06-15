USE [QLTiec]
GO

-- 0. Khởi tạo/Bổ sung đầy đủ các trường cấu hình cho FormBuilder nếu chưa có
IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormName')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'FormName', N'Mã Form', 'Form Name', 't', 1, '6', 1, 1, 0, 1, 1);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FieldName')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'FieldName', N'Tên Trường (Database)', 'Field Name', 't', 1, '6', 1, 1, 0, 1, 2);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'CaptionVN')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'CaptionVN', N'Tiêu đề (Hiển thị)', 'Caption VN', 't', 1, '6', 1, 1, 0, 0, 3);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'CaptionEN')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'CaptionEN', N'Tiêu đề (Tiếng Anh)', 'Caption EN', 't', 0, '6', 1, 1, 0, 0, 4);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo, DataSource)
    VALUES ('frmFormBuilder', 'FormatID', N'Loại Input', 'Format ID', 'sl', 1, '6', 1, 1, 0, 0, 5, N'STATIC:t|Văn bản (Text),n|Số (Number),dt|Ngày (Date),sw|Bật/Tắt (Switch),sl|Danh sách chọn (Select)');

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo, DataSource)
    VALUES ('frmFormBuilder', 'FormPosition', N'Kích thước hiển thị', 'Form Position', 'sl', 1, '6', 1, 1, 0, 0, 6, N'STATIC:12|Đầy đủ 100% (Full),6|Một nửa 50% (Half),4|1/3 Chiều rộng,3|1/4 Chiều rộng,hidden|Chỉ hiện trên Form (100%)');

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'OrderNo')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'OrderNo', N'Thứ tự ưu tiên', 'Order No', 'nm', 1, '6', 1, 1, 0, 0, 7);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsRequired')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'IsRequired', N'Bắt buộc nhập', 'Is Required', 'sw', 0, '6', 1, 1, 0, 0, 8);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInFilter')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'ShowInFilter', N'Hiển thị bộ lọc', 'Show in Filter', 'sw', 0, '6', 1, 1, 0, 0, 9);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInAdd')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'ShowInAdd', N'Hiện khi Thêm', 'Show In Add', 'sw', 0, '6', 1, 1, 0, 0, 10);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInEdit')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'ShowInEdit', N'Hiện khi Sửa', 'Show In Edit', 'sw', 0, '6', 1, 1, 0, 0, 11);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsReadOnlyAdd')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'IsReadOnlyAdd', N'Chỉ đọc khi Thêm', 'Is ReadOnly Add', 'sw', 0, '6', 1, 1, 0, 0, 12);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsReadOnlyEdit')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'IsReadOnlyEdit', N'Chỉ đọc khi Sửa', 'Is ReadOnly Edit', 'sw', 0, '6', 1, 1, 0, 0, 13);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'DataSource')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'DataSource', N'Nguồn Dữ Liệu (API/Static)', 'Data Source', 't', 0, '12', 1, 1, 0, 0, 14);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'VisibleRule')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'VisibleRule', N'Quy tắc hiển thị (JS)', 'Visible Rule', 't', 0, '12', 1, 1, 0, 0, 15);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ValidateRule')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'ValidateRule', N'Ràng buộc dữ liệu (JS)', 'Validate Rule', 't', 0, '12', 1, 1, 0, 0, 16);

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'DependsOn')
    INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, CaptionEN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, IsReadOnlyEdit, IsReadOnlyAdd, OrderNo)
    VALUES ('frmFormBuilder', 'DependsOn', N'Trường phụ thuộc', 'Depends On', 't', 0, '12', 1, 1, 0, 0, 17);

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
WHERE FormName = 'frmFormBuilder' AND FieldName IN ('IsRequired', 'ShowInAdd', 'ShowInEdit', 'IsReadOnlyAdd', 'IsReadOnlyEdit', 'ShowInFilter');

-- Khung chọn Loại Input (Select)
UPDATE SY_FormatFields SET FormatID = 'sl', DataSource = N'STATIC:t|Văn bản (Text),n|Số (Number),dt|Ngày (Date),sw|Bật/Tắt (Switch),sl|Danh sách chọn (Select)' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID';

-- Khung chọn Kích thước hiển thị (Select)
UPDATE SY_FormatFields SET FormatID = 'sl', DataSource = N'STATIC:12|Đầy đủ 100% (Full),6|Một nửa 50% (Half),4|1/3 Chiều rộng,3|1/4 Chiều rộng,hidden|Chỉ hiện trên Form (100%)' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition';

-- Cột số thứ tự
UPDATE SY_FormatFields SET FormatID = 'nm' 
WHERE FormName = 'frmFormBuilder' AND FieldName = 'OrderNo';

-- 3. Cập nhật FormPosition để dàn layout cho gọn gàng (2 ô 1 hàng)
UPDATE SY_FormatFields SET FormPosition = '6' 
WHERE FormName = 'frmFormBuilder' AND FieldName IN (
    'FormName', 'FieldName', 'CaptionVN', 'CaptionEN', 
    'FormatID', 'FormPosition', 'OrderNo', 'IsRequired',
    'ShowInFilter'
);

-- Các trường tuỳ chọn logic cho chiếm cả hàng
UPDATE SY_FormatFields SET FormPosition = '12' 
WHERE FormName = 'frmFormBuilder' AND FieldName IN ('DataSource', 'VisibleRule', 'ValidateRule', 'DependsOn');

-- 4. Xóa lỗi Dummy records
DELETE FROM SY_FormatFields WHERE FormName = '' AND FieldName IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15');

-- 5. AUTO-HEAL CHO CHÍNH FORM BUILDER (Trường hợp lưu bị mất ô trên giao diện do C# set null = 0)
UPDATE SY_FormatFields 
SET ShowInAdd = 1, ShowInEdit = 1 
WHERE FormName = 'frmFormBuilder' AND FieldName IN (
    'FormName', 'FieldName', 'CaptionVN', 'CaptionEN', 
    'FormatID', 'FormPosition', 'OrderNo', 'IsRequired',
    'ShowInFilter', 'DataSource', 'VisibleRule', 'ValidateRule', 'DependsOn',
    'ShowInAdd', 'ShowInEdit', 'IsReadOnlyAdd', 'IsReadOnlyEdit'
);

-- 6. MIGRATION: Chuyển đổi toàn bộ vị trí 'grid' cũ sang '6' để đồng bộ với cơ chế kiểm tra số động trong JS
UPDATE SY_FormatFields 
SET FormPosition = '6' 
WHERE FormPosition = 'grid';

GO
