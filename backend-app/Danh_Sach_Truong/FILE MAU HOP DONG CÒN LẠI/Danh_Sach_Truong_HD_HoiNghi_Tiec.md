# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG HỢP ĐỒNG HỘI NGHỊ & TIỆC (3.1 MAU HDONG)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Hợp đồng Hội Nghị & Tiệc** (`3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx`) để phục vụ việc kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Hợp đồng (Header)
*   `{SoHD}`: Số hợp đồng dịch vụ (Ví dụ: `46/CTY-HHKH/2026`).
*   `{NgayKy}`: Ngày ký hợp đồng.
*   `{ThangKy}`: Tháng ký hợp đồng.
*   `{NamKy}`: Năm ký hợp đồng.

---

## 2. Thông tin Bên A (Nhà hàng) & Bên B (Khách hàng)
*   `{TenCongTy}`: Tên đơn vị / Tên công ty Bên B (Ví dụ: `CÔNG TY TNHH MAKITA VIỆT NAM`).
*   `{DaiDienB}`: Họ tên người đại diện ký hợp đồng phía Bên B.
*   `{ChucVuB}`: Chức vụ của người đại diện Bên B (Ví dụ: `Giám Đốc`).
*   `{DiaChiB}`: Địa chỉ trụ sở Bên B.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{MSTB}`: Mã số thuế Bên B.

---

## 3. Địa điểm & Thời gian sự kiện (Hội nghị & Tiệc tối)
*   `{SanhHoiNghi}`: Sảnh tổ chức hội nghị (Ví dụ: `Sảnh Lux ABCD`).
*   `{SoKhachHoiNghi}`: Số lượng khách tham dự hội nghị (Ví dụ: `500 khách`).
*   `{NgaySetup}`: Ngày setup sảnh hội nghị.
*   `{TuGioSetup}`: Giờ bắt đầu setup sảnh.
*   `{DenGioSetup}`: Giờ kết thúc setup sảnh.
*   `{NgayHoiNghi}`: Ngày diễn ra hội nghị.
*   `{TuGioHoiNghi}`: Giờ bắt đầu hội nghị.
*   `{DenGioHoiNghi}`: Giờ kết thúc hội nghị.
*   `{SetupKieuGhe}`: Kiểu setup bàn ghế hội nghị (Ví dụ: `Dạng lớp học (Classroom)` hoặc `Dạng rạp hát (Theater)`).
*   `{MauKhanTraiBan}`: Màu khăn trải bàn và nơ ghế sảnh hội nghị.
*   `{SanhTiec}`: Sảnh tổ chức tiệc tối (Ví dụ: `Sảnh Lux E`).
*   `{SoBanChinhThuc}`: Số lượng bàn tiệc chính thức.
*   `{SoBanDuPhong}`: Số lượng bàn tiệc dự phòng.
*   `{NgayTiec}`: Ngày tổ chức tiệc tối.
*   `{TuGioTiec}`: Giờ bắt đầu tiệc.
*   `{DenGioTiec}`: Giờ kết thúc tiệc.

---

## 4. Cấu trúc kích thước sảnh
*   `{RongSanhHoiNghi}`: Chiều rộng sảnh hội nghị.
*   `{DaiSanhHoiNghi}`: Chiều dài sảnh hội nghị.
*   `{CaoSanhHoiNghi}`: Chiều cao trần sảnh hội nghị.
*   `{RongSanhTiec}`: Chiều rộng sảnh tiệc tối.
*   `{DaiSanhTiec}`: Chiều dài sảnh tiệc tối.

---

## 5. Bảng báo giá dịch vụ (Dịch vụ tạm tính)
Bảng lặp động hiển thị toàn bộ chi phí hội nghị, LED, teabreak, thực đơn tiệc tối và các dịch vụ đi kèm:
*   Mảng: `{#DichVuMICE}` ... `{/DichVuMICE}`
    *   `{STT}`: Số thứ tự hạng mục.
    *   `{TenDV}`: Tên hạng mục dịch vụ.
    *   `{NoiDung}`: Thời gian / chi tiết (Ví dụ: `08h00 - 17h00 nửa ngày`).
    *   `{DVT}`: Đơn vị tính (`Ngày`, `Giờ`, `Gói`, `Bàn`, `Cái`).
    *   `{SL}`: Số lượng sử dụng.
    *   `{DonGia}`: Đơn giá.
    *   `{UuDai}`: Giá trị ưu đãi.
    *   `{ThanhTien}`: Thành tiền.

---

## 6. Thực đơn tiệc trà (Tea break Menu)
*   Mảng: `{#MenuTeabreak}` ... `{/MenuTeabreak}`
    *   `{STT}`: Số thứ tự món ngọt/nước.
    *   `{TenMonTeabreak}`: Tên món bánh/trái cây/nước uống phục vụ giữa giờ.

---

## 7. Thực đơn tiệc tối (Menu tiệc chính)
*   Mảng: `{#MenuTiec}` ... `{/MenuTiec}`
    *   `{STT}`: Số thứ tự món ăn.
    *   `{TenMon}`: Tên món ăn chính thức.

---

## 8. Thanh toán & Xuất hóa đơn GTGT
*   `{TongTienChuaVAT}`: Tổng giá trị dịch vụ trước thuế.
*   `{PhiPhucVu}`: Trị giá 5% phí phục vụ.
*   `{VAT8}`: Thuế GTGT 8% cho thực phẩm & đồ uống.
*   `{VAT10}`: Thuế GTGT 10% cho trang thiết bị & dịch vụ khác.
*   `{TongGiaTriTamTinh}`: Tổng giá trị tạm tính của hợp đồng.
*   `{TongTienBangChu}`: Số tiền bằng chữ tiếng Việt.
*   `{SoTienDatCoc}`: Số tiền đặt cọc lần 1 (70% giá trị tạm tính).
*   `{SoTienDatCocBangChu}`: Tiền cọc lần 1 bằng chữ.
*   `{MST_VAT}`: Mã số thuế xuất hóa đơn của khách hàng.
*   `{DiaChi_VAT}`: Địa chỉ xuất hóa đơn của khách hàng.
*   `{Email_VAT}`: Email nhận hóa đơn điện tử.
