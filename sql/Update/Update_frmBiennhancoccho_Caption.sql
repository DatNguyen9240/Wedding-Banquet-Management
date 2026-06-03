USE [QLTiec]
GO

-- Cập nhật tiêu đề tiếng Việt có dấu cho form Biên nhận cọc chỗ (frmBiennhancoccho)
UPDATE SY_FormatFields SET CaptionVN = N'Tên chú rể' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tenchure';
UPDATE SY_FormatFields SET CaptionVN = N'Tên cô dâu' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Tencodau';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT chú rể' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTchure';
UPDATE SY_FormatFields SET CaptionVN = N'SĐT cô dâu' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DTcodau';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Diachi';
UPDATE SY_FormatFields SET CaptionVN = N'Người giao dịch' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Nguoigd';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại đại diện' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'DienThoaiDaiDien';
UPDATE SY_FormatFields SET CaptionVN = N'Email' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Mail';
UPDATE SY_FormatFields SET CaptionVN = N'Mã ca tiệc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Thoigianid';
UPDATE SY_FormatFields SET CaptionVN = N'Mã loại tiệc' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'Loaitiecid';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn chính thức' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManchinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn mặn dự phòng' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanManduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay chính thức' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChaychinhthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Bàn chay dự phòng' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'SobanChayduphong';
UPDATE SY_FormatFields SET CaptionVN = N'Dữ liệu sảnh' WHERE FormName = 'frmBiennhancoccho' AND FieldName = 'JsonSanhTiec';

GO
