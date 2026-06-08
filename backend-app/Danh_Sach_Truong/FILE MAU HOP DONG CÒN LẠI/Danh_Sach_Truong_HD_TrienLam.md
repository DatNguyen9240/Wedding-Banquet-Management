# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG HỢP ĐỒNG TRIỂN LÃM (2.2 MAU HDONG)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Hợp đồng Triển Lãm** (`2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx`) để phục vụ việc kết xuất bằng `docxtemplater`.

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

## 2. Thông tin Triển lãm (Địa điểm & Thời gian)
*   `{SanhTrienLam}`: Sảnh tổ chức triển lãm (Ví dụ: `Sảnh Lux ABCD`).
*   `{KhachTrienLam}`: Số lượng khách tham quan dự kiến (Ví dụ: `500 khách`).
*   `{NgaySetup}`, `{ThangSetup}`, `{NamSetup}`: Ngày, tháng, năm setup, thi công triển lãm.
*   `{TuGioSetup}`: Giờ bắt đầu setup.
*   `{DenGioSetup}`: Giờ kết thúc setup sảnh.
*   `{NgayTrienLam}`, `{ThangTrienLam}`, `{NamTrienLam}`: Ngày, tháng, năm diễn ra triển lãm chính thức.
*   `{TuGioTrienLam}`: Giờ mở cửa sự kiện triển lãm.
*   `{DenGioTrienLam}`: Giờ kết thúc triển lãm.
*   `{ThoiGianThaoDo}`: Thời gian tháo dỡ, di dời thiết bị, hàng hóa triển lãm (Ví dụ: `22h00 ngày 18/05/2026`).
*   `{SoNgaySetup}`: Số ngày setup thực tế (Ví dụ: `1`).
*   `{SoNgayThue}`: Số ngày thuê thực tế (Ví dụ: `1`).


---

## 3. Quy cách sảnh triển lãm
*   `{RongSanhTrienLam}`: Chiều rộng sảnh.
*   `{DaiSanhTrienLam}`: Chiều dài sảnh.
*   `{CaoSanhTrienLam}`: Chiều cao trần sảnh triển lãm.
*   `{RongSanKhauTrienLam}`: Chiều rộng sân khấu.
*   `{DaiSanKhauTrienLam}`: Chiều dài sân khấu.

---

## 4. Báo giá dịch vụ triển lãm (Dịch vụ tạm tính)
Bảng lặp động chi phí triển lãm:
*   Mảng: `{#DichVuTrienLam}` ... `{/DichVuTrienLam}`
    *   `{STT}`: Số thứ tự hạng mục (1, 2, 3...).
    *   `{TenDV}`: Tên hạng mục thuê sảnh, thiết bị triển lãm.
    *   `{NoiDung}`: Chi tiết nội dung / thời gian sử dụng.
    *   `{DVT}`: Đơn vị tính (`Ngày`, `Gói`, `Cái`).
    *   `{SL}`: Số lượng.
    *   `{DonGia}`: Đơn giá.
    *   `{UuDai}`: Trị giá ưu đãi.
    *   `{ThanhTien}`: Thành tiền.

---

## 5. Thanh toán & Hóa đơn GTGT
*   `{TongTienChuaVAT}`: Tổng cộng tiền trước thuế & phí.
*   `{PhiPhucVu}`: Trị giá 5% phí phục vụ.
*   `{VAT8}`: Thuế GTGT 8% (nếu có dịch vụ nước giải khát kèm theo).
*   `{VAT10}`: Thuế GTGT 10% (cho phí thuê sảnh và thiết bị).
*   `{TongGiaTriTamTinh}`: Tổng giá trị hợp đồng tạm tính.
*   `{TongTienBangChu}`: Tổng giá trị tạm tính viết bằng chữ.
*   `{SoTienDatCoc}`: Tiền đặt cọc lần 1 (70% giá trị hợp đồng).
*   `{SoTienDatCocBangChu}`: Số tiền cọc lần 1 viết bằng chữ.
*   `{MST_VAT}`: Mã số thuế xuất hóa đơn của khách hàng.
*   `{DiaChi_VAT}`: Địa chỉ xuất hóa đơn của khách hàng.
*   `{Email_VAT}`: Email nhận hóa đơn điện tử.
