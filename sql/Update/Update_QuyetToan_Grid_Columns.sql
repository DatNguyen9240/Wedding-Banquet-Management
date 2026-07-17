USE [QLTiec]
GO

PRINT N'=== BẮT ĐẦU CẬP NHẬT CẤU HÌNH CỘT LƯỚI CHO FRMQUYETTOAN ===';
GO

-- Xóa cấu hình cũ của các trường hiển thị để tránh trùng lặp
DELETE FROM SY_FmtFldTbl 
WHERE FormName = 'frmQuyetToan' 
  AND FieldName IN ('DocumentID', 'DocumentDate', 'Tenkh', 'Nguoinop', 'Tongtiencoc', 'TongtienHoaDon', 'Thanhtoan', 'Conlai');
GO

-- Chèn cấu hình các trường cột cho Grid và Form Quyết Toán
INSERT INTO SY_FmtFldTbl (FormName, FieldName, CaptionVN, FormatID, FormPosition, IsRequired, OrderNo, ShowInAdd, ShowInEdit, IsReadOnlyAdd, IsReadOnlyEdit, ShowInFilter)
VALUES 
('frmQuyetToan', 'DocumentID', N'Số Phiếu QT', 't', '6', 0, 5, 0, 1, 1, 1, 1),
('frmQuyetToan', 'DocumentDate', N'Ngày Quyết Toán', 'dt', '6', 0, 8, 1, 1, 0, 0, 1),
('frmQuyetToan', 'Tenkh', N'Khách Hàng', 't', '6', 0, 15, 0, 0, 1, 1, 1),
('frmQuyetToan', 'Nguoinop', N'Người Nộp Tiền', 't', '6', 0, 20, 1, 1, 0, 0, 1),
('frmQuyetToan', 'Tongtiencoc', N'Tổng Tiền Cọc', 'mn', '6', 0, 25, 1, 1, 1, 1, 0),
('frmQuyetToan', 'TongtienHoaDon', N'Tổng Hóa Đơn', 'mn', '6', 0, 30, 1, 1, 1, 1, 0),
('frmQuyetToan', 'Thanhtoan', N'Khách Thanh Toán', 'mn', '6', 0, 35, 1, 1, 0, 0, 0),
('frmQuyetToan', 'Conlai', N'Còn Lại', 'mn', '6', 0, 40, 1, 1, 1, 1, 0);
GO

PRINT N'=== HOÀN TẤT CẬP NHẬT CẤU HÌNH CỘT LƯỚI CHO FRMQUYETTOAN ===';
GO
