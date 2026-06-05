# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BEO TIỆC CƯỚI (BEO_Tiec_Cuoi.docx)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **BEO Tiệc Cưới** (`BEO_Tiec_Cuoi.docx`) để phục vụ việc tự động kết xuất bằng thư viện `docxtemplater`.

---

## 1. Thông tin chung & Nhân viên phụ trách (Header)
*   `{BenA_NhanVienPhuTrach}`: Tên nhân viên kinh doanh chuẩn bị BEO (Ví dụ: `Mộng Tuyền`).
*   `{BenA_SDT_NhanVien}`: Số điện thoại liên hệ của nhân viên (Tel).
*   `{Sohopdong}`: Số hợp đồng dịch vụ tiệc cưới (Ví dụ: `01/11-HHKH2025`).
*   `{NgayHopDong}`: Ngày ký hợp đồng gốc (Định dạng: `dd/MM/yyyy`).
*   `{NgayRaBEO}`: Ngày lập/in phiếu BEO này (Định dạng: `dd/MM/yyyy`).

---

## 2. Thông tin Chủ tiệc (Cô dâu & Chú rể)
*   `{Tenchure}`: Họ tên Chú Rể (Ví dụ: `NGUYỄN PHƯƠNG DUY`).
*   `{Tencodau}`: Họ tên Cô Dâu (Ví dụ: `NGUYỄN HỒ THU PHƯỢNG`).
*   `{NgayToChuc}`: Ngày diễn ra tiệc cưới (Định dạng: `dd.MM.yyyy` hoặc `dd/MM/yyyy`).
*   `{BenB_DiaChi}`: Địa chỉ của gia đình Cô Dâu / Chú Rể (Ví dụ: `21/08/11 Lê Công Phép, P. An Lạc, TPHCM`).
*   `{Sdtchure}`: Số điện thoại Chú Rể (Ví dụ: `0937 260 013`).
*   `{Sdtcodau}`: Số điện thoại Cô Dâu (Ví dụ: `0398 401 671`).
*   `{DoiTuongKhach}`: Nguồn/Đối tượng khách hàng (Ví dụ: `Fanpage`).

---

## 3. Thời gian & Địa điểm (Vị trí)
*   `{SanhDat}`: Sảnh tổ chức tiệc (Ví dụ: `QUEEN 02+03`).

---

## 4. Quy mô & Cách thức setup
*   `{SobanManchinhthuc}`: Số lượng bàn tiệc mặn chính thức (Ví dụ: `36`).
*   `{SobanManduphong}`: Số lượng bàn dự phòng chuẩn bị sẵn (Ví dụ: `02`).
*   `{SetupNoGhe}`: Tone màu trang trí, áo ghế, nơ (Ví dụ: `Ghế trắng - Nơ hồng`).

---

## 5. Thực đơn tiệc cưới
*   `{AnNheTruocTiec}`: Thông tin suất ăn nhẹ trước giờ tiệc cho gia đình (Ví dụ: `Súp + cơm cho 10 người`).
*   `{BanhManDauGio}`: Loại bánh mặn phục vụ lúc đón khách (Ví dụ: `Bánh Danish Ham Cheese đầu giờ: 36 bàn`).
*   Mảng: `{#ThucDon}` ... `{/ThucDon}`
    *   `{STT}`: Số thứ tự món ăn.
    *   `{TenMonAn}`: Tên món ăn (Ví dụ: `Gỏi ngó sen tôm thịt Chả ốc lá lốt`).

---

## 6. Dịch vụ tính phí & Thức uống
*   Mảng: `{#DichVuTinhPhi}` ... `{/DichVuTinhPhi}`
    *   `{TenDichVu}`: Tên dịch vụ tính phí (Ví dụ: `Thực đơn`, `Phí phục vụ`).
    *   `{ThanhTien}`: Giá trị hoặc thành tiền của dịch vụ đó.
*   `{SobanTang}`: Số lượng bàn bắt đầu áp dụng phụ thu bàn tăng (Ví dụ: `40`).

---

## 7. Phương thức thanh toán (Đặt cọc)
*   `{Dot1_SoTien}`: Số tiền đặt cọc đợt 1 (Ví dụ: `10.000.000`).
*   `{Dot1_HinhThuc}`: Hình thức cọc đợt 1 (Ví dụ: `CK` hoặc `TM`).
*   `{Dot2_SoTien}`: Số tiền đặt cọc đợt 2 (Ví dụ: `100.000.000`).
*   `{Dot2_HinhThuc}`: Hình thức cọc đợt 2 (Ví dụ: `CK` hoặc `TM`).
*   `{DotCuoi_GhiChu}`: Hạn thanh toán đợt cuối (Ví dụ: `Thanh toán cuối tiệc`).

---

## 8. Biểu ngữ sân khấu (Backdrop)
*   `{TenLe}`: Tên nghi lễ cưới (Ví dụ: `LỄ THÀNH HÔN`, `LỄ VU QUY`).
*   `{BieuNguCR}`: Tên Chú Rể trên biểu ngữ.
*   `{BieuNguCD}`: Tên Cô Dâu trên biểu ngữ.
*   `{NgayBieuNgu}`: Ngày in trên biểu ngữ (Ví dụ: `06.06.2026`).
