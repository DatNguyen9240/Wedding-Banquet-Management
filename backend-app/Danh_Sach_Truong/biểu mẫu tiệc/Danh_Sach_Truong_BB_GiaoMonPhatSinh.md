# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN GIAO MÓN PHÁT SINH (BIEN BAN GIAO MON PHAT SINH.docx)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản Giao Món Phát Sinh** (`BIEN BAN GIAO MON PHAT SINH.docx`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Tiệc & Sự kiện
*   `{NgayTiec}`: Ngày diễn ra tiệc (Định dạng: `dd/MM/yyyy`).
*   `{GioTiec}`: Thời gian bắt đầu tiệc (Ví dụ: `18h00`).
*   `{SanhTiec}`: Sảnh tiệc diễn ra sự kiện (Ví dụ: `Sảnh Lux E`).
*   `{LoaiHinhTiec}`: Loại hình tiệc (Ví dụ: `Tiệc cưới`, `Hội nghị`, `Liên hoan`).

---

## 2. Thông tin Khách hàng đại diện
*   `{TenKhachHang}`: Tên chủ tiệc / Tên khách hàng (Ví dụ: `Nguyễn Văn A`).
*   `{DaiDienTiec}`: Họ tên người đại diện ký bàn giao sảnh (Ví dụ: `Nguyễn Văn B`).
*   `{DienThoaiKhach}`: Số điện thoại liên hệ của khách hàng.

---

## 3. Tổng hợp Số lượng Bàn tiệc
Các trường số lượng bàn tiệc mặn/chay thực tế và phát sinh thêm trong tiệc:
*   `{BanChinhThuc}`: Số lượng bàn tiệc chính thức (Ví dụ: `28 bàn`).
*   `{BanTang}`: Số lượng bàn tặng kèm (Ví dụ: `01 bàn`).
*   `{BanChay}`: Số lượng bàn chay đặt trước (Ví dụ: `01 bàn`).
*   `{BanDuPhong}`: Số lượng bàn dự phòng chuẩn bị sẵn (Ví dụ: `02 bàn`).
*   `{BanPhatSinh}`: Số lượng bàn tiệc phát sinh thêm trong tiệc (Ví dụ: `01 bàn`).
*   `{TongSoBan}`: Tổng số lượng bàn thực tế phục vụ (`BanChinhThuc + BanTang + BanChay + BanPhatSinh`).

---

## 4. Thực đơn bàn phát sinh (Đa cột)
Bảng lặp động hiển thị thực đơn song song 3 cột (Mặn, Chay, Phát sinh):
*   Mảng: `{#MenuPhatSinh}` ... `{/MenuPhatSinh}`
    *   `{STT}`: Số thứ tự dòng (1, 2, 3...).
    *   `{MonMan}`: Món mặn tương ứng (Cột 2).
    *   `{MonChay}`: Món chay tương ứng (Cột 3).
    *   `{MonPhatSinh}`: Món phát sinh tương ứng (Cột 4).

