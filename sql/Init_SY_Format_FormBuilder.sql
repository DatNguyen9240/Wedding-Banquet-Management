-- ==========================================================
-- BOOTSTRAP: KHỞI TẠO CẤU HÌNH GIAO DIỆN CHO CHÍNH TRANG "FORM BUILDER"
-- ==========================================================

-- (Không dùng DELETE vì ta chỉ cập nhật chứ không xóa)

-- Cập nhật FormName và Tiêu đề (CaptionVN) cho từng trường để hiển thị đẹp trên Web
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Tên Form', IsRequired = 1 WHERE FieldName = 'FormName';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Tên Cột (Database)', IsRequired = 1 WHERE FieldName = 'FieldName';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Tiêu đề (Tiếng Việt)', IsRequired = 1 WHERE FieldName = 'CaptionVN';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Quy tắc Giao diện (sw, dt, sl)', IsRequired = 0 WHERE FieldName = 'FormatID';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'API Nguồn (cho Select)', IsRequired = 0 WHERE FieldName = 'CaptionEN';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Bắt buộc nhập', IsRequired = 0 WHERE FieldName = 'IsRequired';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Vị trí', IsRequired = 0 WHERE FieldName = 'FormPosition';
UPDATE SY_FormatFields SET FormName = 'frmFormBuilder', CaptionVN = N'Hiển thị', IsRequired = 0 WHERE FieldName = 'ShowInForm';
GO

-- ==========================================================
-- TEST: Chạy thử xem cấu hình lấy lên đúng chưa
-- ==========================================================
-- Bôi đen 1 dòng EXEC dưới đây và ấn F5 để test:
-- EXEC [dbo].[API_LayCacTruongGiaoDien] @FormName = 'frmFormBuilder';
