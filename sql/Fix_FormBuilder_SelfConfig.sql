-- Script bổ sung cấu hình cho chính Form Builder
-- Điều này giúp Modal của Form Builder hiển thị đầy đủ các ô nhập liệu (FormatID, ShowInAdd, ShowInEdit...) thay vì chỉ có 3 ô cơ bản.

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit, DataSource)
VALUES ('frmFormBuilder', 'FormatID', N'Loại Input (Mã Format)', 'sl', 0, 'grid', 1, 1, N'STATIC:|Chữ (Text),nm|Số (Number),dt|Ngày tháng (Date),sw|Công tắc (Switch),sl|Dropdown (Select)');
ELSE
UPDATE SY_FormatFields SET FormatID = 'sl', CaptionVN = N'Loại Input (Mã Format)', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1, DataSource = N'STATIC:|Chữ (Text),nm|Số (Number),dt|Ngày tháng (Date),sw|Công tắc (Switch),sl|Dropdown (Select)' WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormatID';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsRequired')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
VALUES ('frmFormBuilder', 'IsRequired', N'Bắt buộc nhập?', 'sw', 0, 'grid', 1, 1);
ELSE
UPDATE SY_FormatFields SET FormatID = 'sw', CaptionVN = N'Bắt buộc nhập?', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmFormBuilder' AND FieldName = 'IsRequired';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
VALUES ('frmFormBuilder', 'FormPosition', N'Vị trí hiển thị (grid)', '', 0, 'grid', 1, 1);
ELSE
UPDATE SY_FormatFields SET CaptionVN = N'Vị trí hiển thị (grid)', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmFormBuilder' AND FieldName = 'FormPosition';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInAdd')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
VALUES ('frmFormBuilder', 'ShowInAdd', N'Hiện lúc Thêm?', 'sw', 0, 'grid', 1, 1);
ELSE
UPDATE SY_FormatFields SET FormatID = 'sw', CaptionVN = N'Hiện lúc Thêm?', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInAdd';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInEdit')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
VALUES ('frmFormBuilder', 'ShowInEdit', N'Hiện lúc Sửa?', 'sw', 0, 'grid', 1, 1);
ELSE
UPDATE SY_FormatFields SET FormatID = 'sw', CaptionVN = N'Hiện lúc Sửa?', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInEdit';

IF NOT EXISTS (SELECT 1 FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'DataSource')
INSERT INTO SY_FormatFields (FormName, FieldName, CaptionVN, FormatID, IsRequired, FormPosition, ShowInAdd, ShowInEdit)
VALUES ('frmFormBuilder', 'DataSource', N'Nguồn dữ liệu (API/STATIC)', '', 0, 'grid', 1, 1);
ELSE
UPDATE SY_FormatFields SET CaptionVN = N'Nguồn dữ liệu (API/STATIC)', FormPosition = 'grid', ShowInAdd = 1, ShowInEdit = 1 WHERE FormName = 'frmFormBuilder' AND FieldName = 'DataSource';

-- Xoá bỏ cấu hình của ShowInForm cũ vì đã phân tách thành 2 ô
DELETE FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'ShowInForm';

-- Xoá bỏ cấu hình của CaptionEN cũ để khỏi vướng mắt trên form Thêm 1
DELETE FROM SY_FormatFields WHERE FormName = 'frmFormBuilder' AND FieldName = 'CaptionEN';

PRINT N'Đã cập nhật xong cấu hình cho Form Builder!';
GO
