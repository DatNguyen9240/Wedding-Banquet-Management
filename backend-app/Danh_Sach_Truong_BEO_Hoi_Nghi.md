# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BEO HỘI NGHỊ (BEO_Hoi_Nghi.docx)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **BEO Hội Nghị** (`BEO_Hoi_Nghi.docx`) để phục vụ việc tự động kết xuất bằng thư viện `docxtemplater`.

---

## 1. Thông tin chung & Nhân viên phụ trách (Header)
*   `{BenA_NhanVienPhuTrach}`: Tên nhân viên kinh doanh chuẩn bị BEO (Ví dụ: `Nhựt Thủy`).
*   `{BenA_SDT_NhanVien}`: Số điện thoại liên hệ của nhân viên (Tel).
*   `{Sohopdong}`: Số hợp đồng dịch vụ liên quan (Ví dụ: `44/CTY-HHKH/2026`).
*   `{NgayHopDong}`: Ngày ký hợp đồng dịch vụ (Định dạng: `dd/MM/yyyy`).
*   `{NgayRaBEO}`: Ngày lập/in phiếu BEO này (Định dạng: `dd/MM/yyyy`).
*   `{TieuDePhieu}`: Tiêu đề phiếu động (Ví dụ: `PHIẾU ĐẶT TIỆC` hoặc `PHIẾU ĐẶT TIỆC THAY ĐỔI LẦN 1`).

---

## 2. Thông tin Khách hàng & Sự kiện
*   `{TenCongTy}`: Tên đơn vị / tên công ty đặt tiệc (Ví dụ: `CÔNG TY TNHH MAKITA VIỆT NAM`).
*   `{NgayToChuc}`: Ngày diễn ra sự kiện (Định dạng: `dd/MM/yyyy`).
*   `{LoaiHinhSuKien}`: Loại hình sự kiện (Ví dụ: `HỘI NGHỊ + TIỆC TỐI`).
*   `{TieuSuKhachHang}`: Ghi chú lịch sử khách hàng (Ví dụ: `Khách hàng thường niên`).
*   `{SanhDat}`: Sảnh hội nghị/sảnh thứ nhất (Ví dụ: `Queen 1`).
*   `{SanhDat2}`: Sảnh tiệc/sảnh thứ hai (Ví dụ: `Queen 5`).
*   `{DichVuKhuyenMai}`: Nội dung ưu đãi/khuyến mãi (lấy từ DB và điền động vào ô DỊCH VỤ ƯU ĐÃI).
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
Sử dụng mảng lặp lồng nhau (nested loop) để hiển thị dòng thời gian sự kiện gom nhóm theo ngày (Setup, Tổ chức, Tháo dỡ):
*   Mảng ngoài: `{#LichTrinh}` ... `{/LichTrinh}`
    *   `{Ngay}`: Tên ngày và loại ngày (Ví dụ: `Setup: 17/05/2026`, `Tổ chức: 18/05/2026`, `Tháo dỡ: 19/05/2026`).
    *   Mảng trong: `{#ChiTietLichTrinh}` ... `{/ChiTietLichTrinh}`
        *   `{BatDau}`: Giờ bắt đầu (Ví dụ: `13h00`).
        *   `{KetThuc}`: Giờ kết thúc (Ví dụ: `17h00`).
        *   `{Sanh}`: Sảnh diễn ra (Ví dụ: `Queen 1`).
        *   `{NoiDung}`: Chi tiết công việc/nội dung (Ví dụ: `SETUP: Không máy lạnh`).

---

## 4. Quy mô Sảnh & Cách thức Setup
Cung cấp chi tiết số lượng khách và cách bố trí cho các sảnh dưới dạng danh sách lặp động (tự động sinh thêm dòng nếu sự kiện đặt nhiều sảnh):
*   Mảng: `{#DanhSachSanh}` ... `{/DanhSachSanh}`
    *   `{SoKhachChinhThuc}`: Số khách/bàn chính thức (Ví dụ: `120 Khách` hoặc `11 Bàn`).
    *   `{SoBanDuPhong}`: Số bàn dự phòng (Ví dụ: `0` hoặc `1`).
    *   `{SanhDat}`: Tên sảnh sử dụng (Ví dụ: `Queen 1` hoặc `Queen 5`).
    *   `{KieuSetup}`: Cách sắp xếp sảnh (Ví dụ: `Bố trí theo layout đính kèm` hoặc `Tiệc bàn tròn`).

---

## 5. Thực đơn (Menu)
*   Mảng: `{#DanhSachMenu}` ... `{/DanhSachMenu}` (Dành cho tiệc có một hoặc nhiều thực đơn song song/dọc)
    *   `{TenMenu}`: Tên nhóm thực đơn (Ví dụ: `10 bàn` hoặc `01 bàn của Sếp`).
    *   `{GhiChuMenu}`: Lưu ý riêng cho thực đơn đó (Ví dụ: `==> Lưu ý: Bàn của Sếp các món không cay`).
    *   Mảng con món ăn: `{#DanhSachMon}` ... `{/DanhSachMon}`
        *   `{STT}`: Số thứ tự món (1, 2, 3...).
        *   `{TenMon}`: Tên món ăn (Ví dụ: `Cá Tầm Hấp Hongkong`).
*   *Lưu ý:* Hệ thống hỗ trợ tự động convert từ dữ liệu cũ `{ThucDon}` (dạng text chuỗi phẳng) sang mảng `DanhSachMenu` để đảm bảo tương thích ngược 100%.

---

## 6. Dịch vụ tính phí & Thức uống
*   Mảng: `{#DichVuTinhPhi}` ... `{/DichVuTinhPhi}`
    *   `{TenDichVu}`: Tên dịch vụ tính phí (Ví dụ: `Phí setup không máy lạnh`).
    *   `{ThanhTien}`: Thành tiền của dịch vụ đó.
*   `{SobanTang}`: Số bàn áp dụng phụ thu bàn tăng (Ví dụ: `13`).
*   Mảng thức uống: `{#DanhSachThucUong}` ... `{/DanhSachThucUong}`
    *   `{TenThucUong}`: Tiêu đề nhóm thức uống (Ví dụ: `QUEEN 5: TIỆC BÀN TRÒN`).
    *   `{GhiChuThucUong}`: Ghi chú cho phần thức uống.
    *   Mảng con món uống: `{#DanhSachMonUong}` ... `{/DanhSachMonUong}`
        *   `{STT}`: Số thứ tự thức uống.
        *   `{TenMonUong}`: Tên loại đồ uống (Ví dụ: `Bia Tiger lon bạc`).
*   *Lưu ý:* Hệ thống hỗ trợ tự động convert từ dữ liệu đồ uống cũ `{ThucUong}` (dạng text chuỗi phẳng) sang mảng `DanhSachThucUong` để đảm bảo tương thích ngược 100%.

---

## 7. Phương thức thanh toán (Đặt cọc)
*   `{Dot1_SoTien}`: Số tiền đặt cọc đợt 1 (Ví dụ: `89.675.555 VNĐ`).
*   `{Dot1_Ngay}`: Hạn/ngày chuyển cọc đợt 1 (Ví dụ: `13/05/2026`).
*   `{DotCuoi_GhiChu}`: Hạn thanh toán đợt cuối (Ví dụ: `Thanh toán sau tiệc 07 ngày`).

---

## 8. Ghi chú Phòng ban (Bảo vệ, Kỹ thuật, Biểu ngữ)
*   `{NoteBaoVe}`: Ghi chú cho bộ phận Bảo Vệ (Mặc định: `Danh sách vào + ra hàng hóa (BÁO SAU)`).
*   `{NoteKyThuat}`: Ghi chú cho bộ phận Kỹ Thuật (Mặc định: `Căng banner cổng chính: 8.5m*1.2m\nCăng Background sân khấu: 6m*3.5m (SảnhDat2)`).
*   `{NoteBieuNgu}`: Ghi chú biểu ngữ sân khấu (Mặc định: `Phối hợp với khách`).
*   `{NoteLobby}`: Ghi chú khu vực Lobby / Bàn lễ tân (Mặc định: `Bàn Lễ Tân đón khách [SanhDat] và [SanhDat2]`, tự động ẩn chữ "và" nếu chỉ có 1 sảnh).
