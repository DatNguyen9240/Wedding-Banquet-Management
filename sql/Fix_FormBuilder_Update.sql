-- Cập nhật bắt buộc các trường bị lỗi duplicate
UPDATE SY_FormatFields 
SET FormName = 'frmFormBuilder' 
WHERE FieldName IN ('FormatID', 'CaptionEN');

PRINT N'Đã cưỡng chế cập nhật thành công!';
GO
