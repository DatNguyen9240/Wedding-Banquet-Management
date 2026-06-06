# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN MANG THỨC ĂN VÀO SẢNH (BM - 02 BIEN BAN MANG THU AN VAO.doc)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản Mang Thức Ăn Vào Sảnh** (`BM - 02 BIEN BAN MANG THU AN VAO.doc`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Tiệc & Khách hàng
*   `{TenKhachHang}`: Tên khách hàng / Tên chủ tiệc.
*   `{NgayTiec}`: Ngày diễn ra tiệc (Định dạng: `dd/MM/yyyy`).
*   `{GioTiec}`: Giờ diễn ra tiệc (Ví dụ: `18h00`).
*   `{LoaiHinhTiec}`: Loại hình tiệc (Ví dụ: `Tiệc cưới`, `Liên hoan`).
*   `{SoBanKhach}`: Số bàn / số khách tham dự (Ví dụ: `30 bàn / 300 khách`).
*   `{SanhTiec}`: Địa điểm / Sảnh tiệc (Ví dụ: `Sảnh Lux E`).
*   `{DaiDienB}`: Người đại diện Bên B (khách hàng) chịu trách nhiệm.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{DiaChiB}`: Địa chỉ của khách hàng.
*   `{DaiDienA}`: Đại diện nhà hàng (Bên A).


---

## 2. Danh mục thực phẩm mang vào
Bảng lặp động chi tiết các món ăn, đồ uống do khách tự đem từ bên ngoài vào:
*   Mảng: `{#ThucPhamMangVao}` ... `{/ThucPhamMangVao}`
    *   `{STT}`: Số thứ tự (1, 2, 3...).
    *   `{TenThucPham}`: Tên loại đồ ăn / thức uống (Ví dụ: `Bánh sinh nhật 2 tầng`, `Rượu Chivas 18`).
    *   `{SoLuong}`: Số lượng mang vào.
    *   `{DVT}`: Đơn vị tính (`Cái`, `Chai`, `Kg`).
    *   `{PhiPhucVu}`: Phí phục vụ thu thêm nếu có (VNĐ).
    *   `{CamKet}`: Ghi chú cam kết đảm bảo vệ sinh an toàn thực phẩm.
