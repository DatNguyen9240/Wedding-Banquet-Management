# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BEO HỘI NGHỊ (BEO_Hoi_Nghi.docx)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **BEO Hội Nghị** (`BEO_Hoi_Nghi.docx`) để phục vụ việc tự động kết xuất bằng thư viện `docxtemplater`.

---

## 1. Thông tin chung & Nhân viên phụ trách (Header)
*   `{BenA_NhanVienPhuTrach}`: Tên nhân viên kinh doanh chuẩn bị BEO (Ví dụ: `Nhựt Thủy`).
*   `{BenA_SDT_NhanVien}`: Số điện thoại liên hệ của nhân viên (Tel).
*   `{Sohopdong}`: Số hợp đồng dịch vụ liên quan (Ví dụ: `44/CTY-HHKH/2026`).
*   `{NgayHopDong}`: Ngày ký hợp đồng dịch vụ (Định dạng: `dd/MM/yyyy`).
*   `{NgayRaBEO}`: Ngày lập/in phiếu BEO này (Định dạng: `dd/MM/yyyy`).

---

## 2. Thông tin Khách hàng & Sự kiện
*   `{TenKhachHang}`: Tên đơn vị đặt tiệc (Ví dụ: `CÔNG TY TNHH MAKITA VIỆT NAM`).
*   `{NgayToChuc}`: Ngày diễn ra sự kiện (Định dạng: `dd/MM/yyyy`).
*   `{LoaiHinhSuKien}`: Loại hình sự kiện (Ví dụ: `HỘI NGHỊ + TIỆC TỐI`).
*   `{TieuSuKhachHang}`: Ghi chú lịch sử khách hàng (Ví dụ: `Khách hàng thường niên`).
*   `{SanhDat}`: Sảnh hội nghị/sảnh thứ nhất (Ví dụ: `Queen 1`).
*   `{SanhDat2}`: Sảnh tiệc/sảnh thứ hai (Ví dụ: `Queen 5`).
*   `{NoiDungBangChao}`: Nội dung chiếu bảng chào (Ví dụ: `HỘI NGHỊ KHÁCH HÀNG 2026`).
*   `{NgaySetup}`: Ngày chuẩn bị/setup sảnh (Ví dụ: `17/05/2026`).
*   `{NgayOut}`: Ngày tháo dỡ/out hàng hóa (Ví dụ: `19/05/2026`).
*   `{NgayOut_Short}`: Ngày out hàng dạng rút gọn (Ví dụ: `19/05`).
*   `{DonViThiCong}`: Đơn vị trang trí/thi công ngoại cảnh.
*   `{NguoiGiaoDich}`: Họ tên người đại diện giao dịch.
*   `{BenB_DiaChi}`: Địa chỉ liên hệ của đơn vị/khách hàng.
*   `{BenB_DienThoai}`: Số điện thoại liên hệ của khách hàng.

---

## 3. Lịch trình sự kiện (Timeline)
Sử dụng mảng lặp để hiển thị dòng thời gian sự kiện:
*   Mảng: `{#LichTrinh}` ... `{/LichTrinh}`
    *   `{BatDau}`: Giờ bắt đầu (Ví dụ: `13h00`).
    *   `{KetThuc}`: Giờ kết thúc (Ví dụ: `17h00`).
    *   `{NoiDung}`: Chi tiết công việc/nội dung (Ví dụ: `HỘI NGHỊ`).

---

## 4. Quy mô Sảnh & Cách thức Setup
Cung cấp chi tiết số lượng khách và cách bố trí cho từng sảnh:
*   **Sảnh 1 (Hội nghị):**
    *   `{SoKhachChinhThuc}`: Số khách chính thức (Ví dụ: `120`).
    *   `{SoBanDuPhong}`: Số bàn dự phòng (Ví dụ: `0`).
    *   `{KieuSetup}`: Cách sắp xếp sảnh (Ví dụ: `Setup lớp học`).
*   **Sảnh 2 (Tiệc tối):**
    *   `{SoKhachChinhThuc2}`: Số bàn/khách chính thức (Ví dụ: `11 Bàn`).
    *   `{SoBanDuPhong2}`: Số bàn dự phòng (Ví dụ: `1`).
    *   `{KieuSetup2}`: Cách sắp xếp sảnh (Ví dụ: `Tiệc bàn tròn`).

---

## 5. Thực đơn (Menu)
*   Mảng: `{#ThucDon}` ... `{/ThucDon}`
    *   `{TenMonAn}`: Tên món ăn (Ví dụ: `Cá Tầm Hấp Sốt Tương Tỏi Ớt`).

---

## 6. Dịch vụ tính phí & Thức uống
*   Mảng: `{#DichVuTinhPhi}` ... `{/DichVuTinhPhi}`
    *   `{TenDichVu}`: Tên dịch vụ tính phí (Ví dụ: `Phí setup không máy lạnh`).
    *   `{ThanhTien}`: Thành tiền của dịch vụ đó.
*   `{SobanTang}`: Số bàn áp dụng phụ thu bàn tăng (Ví dụ: `13`).

---

## 7. Phương thức thanh toán (Đặt cọc)
*   `{Dot1_SoTien}`: Số tiền đặt cọc đợt 1 (Ví dụ: `89.675.555 VNĐ`).
*   `{Dot1_Ngay}`: Hạn/ngày chuyển cọc đợt 1 (Ví dụ: `13/05/2026`).
*   `{DotCuoi_GhiChu}`: Hạn thanh toán đợt cuối (Ví dụ: `Thanh toán sau tiệc 07 ngày`).
