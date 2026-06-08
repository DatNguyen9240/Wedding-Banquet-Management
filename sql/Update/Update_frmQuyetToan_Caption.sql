USE [QLTiec]
GO

-- Cập nhật tiêu đề tiếng Việt có dấu cho form Quyết toán (frmQuyetToan)
UPDATE SY_FormatFields SET CaptionVN = N'Mã quyết toán' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DocumentID';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày quyết toán' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DocumentDate';
UPDATE SY_FormatFields SET CaptionVN = N'Mã phiếu thu' WHERE FormName = 'frmQuyetToan' AND FieldName = 'SPthu';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày thu' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Ngaythu';
UPDATE SY_FormatFields SET CaptionVN = N'Số biên nhận' WHERE FormName = 'frmQuyetToan' AND FieldName = 'SoBienNhan';
UPDATE SY_FormatFields SET CaptionVN = N'Số hợp đồng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sohopdong';
UPDATE SY_FormatFields SET CaptionVN = N'Người nộp' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Nguoinop';
UPDATE SY_FormatFields SET CaptionVN = N'Mã nhân viên' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Manv';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền cọc' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Tongtiencoc';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền giảm giá' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sotiengiamgia';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền phát sinh' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sotienphatsinh';
UPDATE SY_FormatFields SET CaptionVN = N'Thanh toán' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Thanhtoan';
UPDATE SY_FormatFields SET CaptionVN = N'Ghi chú' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Ghichu';
UPDATE SY_FormatFields SET CaptionVN = N'Người tạo' WHERE FormName = 'frmQuyetToan' AND FieldName = 'UserCreate';
UPDATE SY_FormatFields SET CaptionVN = N'Người cập nhật' WHERE FormName = 'frmQuyetToan' AND FieldName = 'UserUpdate';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày tạo' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DateCreate';
UPDATE SY_FormatFields SET CaptionVN = N'Ngày cập nhật' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DateUpdate';
UPDATE SY_FormatFields SET CaptionVN = N'Mã nhà hàng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Nhahangid';
UPDATE SY_FormatFields SET CaptionVN = N'Đã kết thúc' WHERE FormName = 'frmQuyetToan' AND FieldName = 'IsKetthuc';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền dịch vụ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'SotienDichVu';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền thức uống' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sotienthucuong';
UPDATE SY_FormatFields SET CaptionVN = N'Còn lại' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Conlai';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền hóa đơn' WHERE FormName = 'frmQuyetToan' AND FieldName = 'TongtienHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Tongtien';
UPDATE SY_FormatFields SET CaptionVN = N'Giảm giá tổng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Giamgiatong';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền giảm giá tổng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Sotiengiamgiatong';
UPDATE SY_FormatFields SET CaptionVN = N'Số tiền bàn tiệc' WHERE FormName = 'frmQuyetToan' AND FieldName = 'SoTienBanTiec';
UPDATE SY_FormatFields SET CaptionVN = N'Phải thanh toán' WHERE FormName = 'frmQuyetToan' AND FieldName = 'Phaithanhtoan';
UPDATE SY_FormatFields SET CaptionVN = N'Phí bù sảnh' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PhiBuSanh';
UPDATE SY_FormatFields SET CaptionVN = N'Phí bù bàn tăng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PhiBuBantang';
UPDATE SY_FormatFields SET CaptionVN = N'Phí bù trang trí sảnh' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PhiBuTTS';
UPDATE SY_FormatFields SET CaptionVN = N'Phí bù nghi thức lễ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PhiBuNTL';
UPDATE SY_FormatFields SET CaptionVN = N'Số bàn tính phí phục vụ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'SoBanTinhPhiPhucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Phí phục vụ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PhiPhucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Tổng tiền phí phục vụ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'TongTienPhiPhucVu';
UPDATE SY_FormatFields SET CaptionVN = N'Xuất hóa đơn' WHERE FormName = 'frmQuyetToan' AND FieldName = 'IsHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Tiền thuế VAT' WHERE FormName = 'frmQuyetToan' AND FieldName = 'TienThueVAT';
UPDATE SY_FormatFields SET CaptionVN = N'Phần trăm thuế VAT' WHERE FormName = 'frmQuyetToan' AND FieldName = 'PTThueVAT';
UPDATE SY_FormatFields SET CaptionVN = N'Tên công ty xuất HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'TenCtyHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Địa chỉ công ty HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DiaChiCtyHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Mã số thuế HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'MaSoThueHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Người liên hệ HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'NguoiLienHeHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Điện thoại HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'DienThoaiHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Nội dung HĐ' WHERE FormName = 'frmQuyetToan' AND FieldName = 'NoiDungHoaDon';
UPDATE SY_FormatFields SET CaptionVN = N'Kế toán xác nhận' WHERE FormName = 'frmQuyetToan' AND FieldName = 'IsXacNhanKeToan';
UPDATE SY_FormatFields SET CaptionVN = N'Phương thức thanh toán' WHERE FormName = 'frmQuyetToan' AND FieldName = 'ThanhToanID';
UPDATE SY_FormatFields SET CaptionVN = N'Ngân hàng' WHERE FormName = 'frmQuyetToan' AND FieldName = 'NganHang';

GO
