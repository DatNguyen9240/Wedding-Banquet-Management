# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN LƯU MẪU THỨC ĂN KHÁCH HÀNG (BIEN BAN LUU MAU THUC AN KH.doc)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản Lưu Mẫu Thức Ăn** (`BIEN BAN LUU MAU THUC AN KH.doc`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Tiệc & Khách hàng
*   `{NgayTiec}`: Ngày tổ chức tiệc diễn ra (Định dạng: `dd/MM/yyyy`).
*   `{GioTiec}`: Giờ bắt đầu tiệc (Ví dụ: `18h00`).
*   `{SanhTiec}`: Sảnh tiệc tổ chức (Ví dụ: `Sảnh Lux E`).
*   `{LoaiHinhTiec}`: Loại hình tiệc (Ví dụ: `Tiệc cưới`, `Liên hoan`).
*   `{TenKhachHang}`: Tên khách hàng / Tên chủ tiệc (Ví dụ: `Nguyễn Văn A`).
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{DiaChiB}`: Địa chỉ của khách hàng.
*   `{SoBanKhach}`: Số bàn / số khách tham dự (Ví dụ: `30 bàn / 300 khách`).
*   `{GioLayMau}`: Giờ lấy mẫu thực tế.
*   `{NgayLayMau}`: Ngày lấy mẫu thực tế.
*   `{GioHuyMau}`: Giờ hủy mẫu thực tế (sau 24h).
*   `{NgayHuyMau}`: Ngày hủy mẫu thực tế (sau 24h).
*   `{DaiDienA}`: Đại diện nhà hàng (Bên A).
*   `{DaiDienB}`: Đại diện khách hàng (Bên B).


---

## 2. Danh mục các món ăn lưu mẫu
Bảng lặp động hiển thị toàn bộ các món ăn trong thực đơn của tiệc để bếp lưu trữ mẫu thử phòng ngừa ngộ độc thực phẩm:
*   Mảng: `{#MenuLuuMau}` ... `{/MenuLuuMau}`
    *   `{STT}`: Số thứ tự món ăn (1, 2, 3...).
    *   `{TenMon}`: Tên món ăn cần lấy mẫu lưu (Ví dụ: `Lẩu hải sản Queen Plaza`).
    *   `{ThoiGianLuu}`: Giờ thực hiện lấy mẫu (Ví dụ: `18h30`).
    *   `{NguoiBanGiao}`: Tên đại diện bộ phận Bếp bàn giao mẫu.
