# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN GIAO NHẬN TIỆC (BM - 01 BIEN BAN GIAO NHAN TIEC ok)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản Giao Nhận Tiệc** (`BM - 01 BIEN BAN GIAO NHAN TIEC ok.docx`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Tiệc & Khách hàng
*   `{NgayTiec}`: Ngày tổ chức tiệc (Định dạng: `dd/MM/yyyy`).
*   `{GioTiec}`: Thời gian bắt đầu tiệc (Ví dụ: `18h00`).
*   `{SanhTiec}`: Sảnh tiệc (Ví dụ: `Sảnh Lux E`).
*   `{LoaiHinhTiec}`: Loại hình sự kiện (Ví dụ: `Tiệc cưới`, `Thôi nôi`).
*   `{TenKhachHang}`: Tên khách hàng đặt tiệc.
*   `{DaiDienTiec}`: Đại diện khách hàng tại sảnh running.
*   `{DienThoaiKhach}`: Số điện thoại liên lạc.

---

## 2. Số lượng bàn tiệc bàn giao
*   `{BanChinhThuc}`: Số bàn chính thức.
*   `{BanTang}`: Số bàn được tặng khuyến mãi.
*   `{BanChay}`: Số bàn chay.
*   `{BanDuPhong}`: Số bàn dự phòng.
*   `{TongSoBan}`: Tổng số bàn thực tế bàn giao cho khách.

---

## 3. Thực đơn bàn giao sảnh (Đa cột song song)
Bảng lặp động hiển thị thực đơn song song 3 cột (Mặn, Chay, Phát sinh):
*   Mảng: `{#MenuGiaoNhan}` ... `{/MenuGiaoNhan}`
    *   `{STT}`: Số thứ tự dòng (1, 2, 3...).
    *   `{MonMan}`: Món mặn tương ứng (Cột 2).
    *   `{MonChay}`: Món chay tương ứng (Cột 3).
    *   `{MonPhatSinh}`: Món phát sinh tương ứng (Cột 4).

---

## 4. Kiểm kê đồ uống trước tiệc (Check-in)
*   Mảng: `{#DoUongKiemKe}` ... `{/DoUongKiemKe}`
    *   `{STT}`: Số thứ tự.
    *   `{TenNuoc}`: Tên loại đồ uống (Ví dụ: `Tiger bạc lon`, `Coca-cola lon`, `Nước suối Aquafina`).
    *   `{SLTruocTiec}`: Số lượng thùng/chai bàn giao trước giờ tiệc.
    *   `{GhiChu}`: Ghi chú bàn giao.

---

## 5. Tổng kết tiêu dùng & Trả kho sau tiệc (Check-out)
Bảng này chứa các hàng cố định trong mẫu biểu. Có thể điền trực tiếp bằng các trường riêng lẻ cho từng ô:
*   **Bàn tiệc:**
    *   `{BanChinhThuc_Dung}`, `{BanChay_Dung}`, `{BanTang_Dung}`, `{BanDuPhong_Dung}`, `{BanPhatSinh_Dung}`: Số bàn sử dụng thực tế của từng loại.
    *   `{TongSoBan_Dung}`: Tổng số bàn tiệc đã sử dụng.
*   **Đồ uống & Dịch vụ khác (Bia, Nước ngọt, Nước suối, Phát sinh khác, Khăn lạnh, Đậu phộng):**
    *   Số lượng sử dụng: `{Bia_Dung}`, `{NuocNgot_Dung}`, `{NuocSuoi_Dung}`, `{Khac_Dung}`, `{KhanLanh_Dung}`, `{DauPhong_Dung}`
    *   Số lượng trả kho: `{Bia_Tra}`, `{NuocNgot_Tra}`, `{NuocSuoi_Tra}`, `{Khac_Tra}`, `{KhanLanh_Tra}`, `{DauPhong_Tra}`
    *   Tổng kết (thanh toán): `{Bia_TongKet}`, `{NuocNgot_TongKet}`, `{NuocSuoi_TongKet}`, `{Khac_TongKet}`, `{KhanLanh_TongKet}`, `{DauPhong_TongKet}`

