# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG HỢP ĐỒNG TRIỂN LÃM & TIỆC (2.1 MAU HDONG)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Hợp đồng Triển Lãm & Tiệc** (`2.1 MAU HDONG - 0406 (TRIỂN LÃM + TIỆC).docx`) để phục vụ việc kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Hợp đồng (Header)
*   `{SoHD}`: Số hợp đồng dịch vụ (Ví dụ: `45/CTY-HHKH/2026`).
*   `{NgayKy}`: Ngày ký hợp đồng (Ví dụ: `06`).
*   `{ThangKy}`: Tháng ký hợp đồng (Ví dụ: `06`).
*   `{NamKy}`: Năm ký hợp đồng (Ví dụ: `2026`).

---

## 2. Thông tin Bên A (Nhà hàng) & Bên B (Khách hàng)
*   `{TenCongTy}`: Tên đơn vị / Tên công ty Bên B (Ví dụ: `CÔNG TY TNHH MAKITA VIỆT NAM`).
*   `{DaiDienB}`: Họ tên người đại diện ký hợp đồng phía Bên B (Ví dụ: `Nguyễn Văn A`).
*   `{ChucVuB}`: Chức vụ của người đại diện Bên B (Ví dụ: `Giám Đốc`).
*   `{DiaChiB}`: Địa chỉ trụ sở Bên B.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{MSTB}`: Mã số thuế Bên B.

---

## 3. Địa điểm & Thời gian sự kiện (Triển lãm & Tiệc)
*   `{SanhTrienLam}`: Sảnh tổ chức triển lãm (Ví dụ: `Sảnh Lux ABCD`).
*   `{KhachTrienLam}`: Số lượng khách tham quan dự kiến (Ví dụ: `500 khách`).
*   `{NgaySetup}`: Ngày setup, thi công triển lãm (Ví dụ: `17/05/2026`).
*   `{TuGioSetup}`: Giờ bắt đầu setup (Ví dụ: `08h00`).
*   `{DenGioSetup}`: Giờ kết thúc setup (Ví dụ: `18h00`).
*   `{NgayTrienLam}`: Ngày diễn ra triển lãm (Ví dụ: `18/05/2026`).
*   `{TuGioTrienLam}`: Giờ mở cửa triển lãm (Ví dụ: `08h00`).
*   `{DenGioTrienLam}`: Giờ đóng cửa triển lãm (Ví dụ: `17h00`).
*   `{SanhTiec}`: Sảnh tổ chức tiệc tối (Ví dụ: `Sảnh Lux E`).
*   `{SoBanChinhThuc}`: Số lượng bàn tiệc chính thức (Ví dụ: `28`).
*   `{SoBanDuPhong}`: Số lượng bàn tiệc dự phòng (Ví dụ: `02`).
*   `{NgayTiec}`: Ngày tổ chức tiệc tối (Ví dụ: `18/05/2026`).
*   `{TuGioTiec}`: Giờ bắt đầu tiệc (Ví dụ: `18h00`).
*   `{DenGioTiec}`: Giờ kết thúc tiệc (Ví dụ: `22h00`).

---

## 4. Cấu trúc Sảnh & Thiết lập
*   `{RongSanhTrienLam}`: Chiều rộng sảnh triển lãm (Ví dụ: `25m`).
*   `{DaiSanhTrienLam}`: Chiều dài sảnh triển lãm (Ví dụ: `49m`).
*   `{CaoSanhTrienLam}`: Chiều cao trần sảnh triển lãm (Ví dụ: `5m`).
*   `{RongSanKhauTrienLam}`: Chiều rộng sân khấu triển lãm.
*   `{DaiSanKhauTrienLam}`: Chiều dài sân khấu triển lãm.
*   `{RongSanhTiec}`: Chiều rộng sảnh tiệc tối (Ví dụ: `25m`).
*   `{DaiSanhTiec}`: Chiều dài sảnh tiệc tối (Ví dụ: `25m`).
*   `{CaoSanhTiec}`: Chiều cao trần sảnh tiệc tối (Ví dụ: `7.8m`).

---

## 5. Bảng báo giá chi tiết (Dịch vụ tạm tính)
Bảng lặp động hiển thị chi phí dự kiến cho triển lãm và tiệc tối:
*   Mảng: `{#DichVuBaoGia}` ... `{/DichVuBaoGia}`
    *   `{STT}`: Số thứ tự (1, 2, 3...).
    *   `{TenDV}`: Tên hạng mục dịch vụ (Ví dụ: `Phí thuê sảnh hội nghị Lux ABCD`).
    *   `{NoiDung}`: Chi tiết thời gian/nội dung (Ví dụ: `08h00 - 17h00 nửa ngày`).
    *   `{DVT}`: Đơn vị tính (Ví dụ: `Ngày`, `Nửa ngày`, `Gói`, `Bàn`).
    *   `{SL}`: Số lượng thực tế.
    *   `{DonGia}`: Đơn giá (đã định dạng VNĐ).
    *   `{UuDai}`: Trị giá ưu đãi/khuyến mãi giảm giá.
    *   `{ThanhTien}`: Thành tiền sau khi cấn trừ ưu đãi.

---

## 6. Thực đơn tiệc tối (Menu)
Danh sách món ăn mặn/chay phục vụ tiệc tối:
*   Mảng: `{#MenuTiec}` ... `{/MenuTiec}`
    *   `{STT}`: Số thứ tự món ăn (1, 2, 3...).
    *   `{TenMon}`: Tên món ăn (Ví dụ: `Bò sốt tiêu đen kèm bánh mì`).

---

## 7. Thanh toán & Xuất hóa đơn GTGT
*   `{TongTienChuaVAT}`: Tổng tiền trước thuế & phí phục vụ (VNĐ).
*   `{PhiPhucVu}`: Trị giá 5% phí phục vụ (VNĐ).
*   `{VAT8}`: Thuế GTGT 8% (thức ăn, nước uống).
*   `{VAT10}`: Thuế GTGT 10% (các chi phí dịch vụ khác).
*   `{TongGiaTriTamTinh}`: Tổng giá trị hợp đồng tạm tính sau thuế (VNĐ).
*   `{TongTienBangChu}`: Số tiền bằng chữ tiếng Việt (Ví dụ: `Một trăm bốn mươi bảy triệu đồng./.`).
*   `{SoTienDatCoc}`: Số tiền đặt cọc đợt 1 (tương đương 70% giá trị hợp đồng).
*   `{SoTienDatCocBangChu}`: Tiền đặt cọc đợt 1 bằng chữ.
*   `{MST_VAT}`: Mã số thuế xuất hóa đơn của khách hàng.
*   `{DiaChi_VAT}`: Địa chỉ xuất hóa đơn của khách hàng.
*   `{Email_VAT}`: Email nhận hóa đơn điện tử.
