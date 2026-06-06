# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG HỢP ĐỒNG HỘI NGHỊ (3.2 MAU HDONG)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Hợp đồng Hội Nghị** (`3.2 MAU HDONG - 0406 (HỘI NGHỊ ).docx`) để phục vụ việc kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Hợp đồng & Đối tác
*   `{SoHD}`: Số hợp đồng dịch vụ.
*   `{NgayKy}`, `{ThangKy}`, `{NamKy}`: Ngày, tháng, năm ký kết hợp đồng.
*   `{TenCongTy}`: Tên đơn vị / Tên công ty Bên B.
*   `{DaiDienB}`: Người đại diện Bên B ký kết.
*   `{ChucVuB}`: Chức vụ đại diện Bên B.
*   `{DiaChiB}`: Địa chỉ trụ sở Bên B.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{MSTB}`: Mã số thuế Bên B.

---

## 2. Thông tin Hội nghị (Địa điểm & Thời gian)
*   `{SanhHoiNghi}`: Sảnh tổ chức hội nghị (Ví dụ: `Sảnh Lux ABCD`).
*   `{SoKhachHoiNghi}`: Số lượng khách tham dự hội nghị (Ví dụ: `500 khách`).
*   `{NgaySetup}`, `{ThangSetup}`, `{NamSetup}`: Ngày, tháng, năm setup sảnh hội nghị.
*   `{TuGioSetup}`: Giờ bắt đầu setup.
*   `{DenGioSetup}`: Giờ kết thúc setup sảnh.
*   `{NgayHoiNghi}`, `{ThangHoiNghi}`, `{NamHoiNghi}`: Ngày, tháng, năm diễn ra hội nghị chính thức.
*   `{TuGioHoiNghi}`: Giờ bắt đầu hội nghị.
*   `{DenGioHoiNghi}`: Giờ kết thúc hội nghị.
*   `{SetupKieuGhe}`: Kiểu setup bàn ghế hội nghị (Ví dụ: `Dạng lớp học (Classroom)`).
*   `{SucChuaToiDa}`: Sức chứa tối đa của sảnh (Ví dụ: `600`).
*   `{SucChuaToiThieu}`: Sức chứa nhận tối thiểu của sảnh (Ví dụ: `350`).
*   `{SoNgaySetup}`: Số ngày setup thực tế.
*   `{SoNgayThue}`: Số ngày thuê thực tế.

---

## 3. Quy cách sảnh hội nghị
*   `{RongSanhHoiNghi}`: Chiều rộng sảnh.
*   `{DaiSanhHoiNghi}`: Chiều dài sảnh.
*   `{CaoSanhHoiNghi}`: Chiều cao trần sảnh hội nghị.
*   `{KichThuocSanh}`: Thông số kích thước sảnh chung (Ví dụ: `25m x 49m`).
*   `{KichThuocSanKhau}`: Thông số kích thước sân khấu chung (Ví dụ: `3m x 6m`).


---

## 4. Báo giá dịch vụ hội nghị (Dịch vụ tạm tính)
Bảng lặp động chi phí hội nghị:
*   Mảng: `{#DichVuHoiNghi}` ... `{/DichVuHoiNghi}`
    *   `{STT}`: Số thứ tự hạng mục (1, 2, 3...).
    *   `{TenDV}`: Tên hạng mục thuê sảnh, thiết bị, teabreak hội nghị.
    *   `{NoiDung}`: Chi tiết nội dung / thời gian sử dụng.
    *   `{DVT}`: Đơn vị tính (`Ngày`, `Nửa ngày`, `Gói`, `Phần`).
    *   `{SL}`: Số lượng.
    *   `{DonGia}`: Đơn giá.
    *   `{UuDai}`: Trị giá ưu đãi.
    *   `{ThanhTien}`: Thành tiền.

---

## 5. Thanh toán & Hóa đơn GTGT
*   `{TongTienChuaVAT}`: Tổng cộng tiền trước thuế & phí.
*   `{PhiPhucVu}`: Trị giá 5% phí phục vụ.
*   `{VAT8}`: Thuế GTGT 8% (thường áp dụng cho teabreak, nước uống).
*   `{VAT10}`: Thuế GTGT 10% (thuê sảnh và thiết bị kỹ thuật).
*   `{TongGiaTriTamTinh}`: Tổng giá trị hợp đồng tạm tính.
*   `{TongTienBangChu}`: Tổng giá trị tạm tính viết bằng chữ.
*   `{SoTienDatCoc}`: Tiền đặt cọc lần 1 (70% giá trị hợp đồng).
*   `{SoTienDatCocBangChu}`: Số tiền cọc lần 1 viết bằng chữ.
*   `{MST_VAT}`: Mã số thuế xuất hóa đơn của khách hàng.
*   `{DiaChi_VAT}`: Địa chỉ xuất hóa đơn của khách hàng.
*   `{Email_VAT}`: Email nhận hóa đơn điện tử.
