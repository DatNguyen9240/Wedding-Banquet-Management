# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG PHIẾU QUYẾT TOÁN
Dựa trên việc đọc kỹ nội dung file `quyet_toan.docx`, dưới đây là danh sách chi tiết các trường thông tin động cần được điền bằng `docxtemplater` khi in phiếu quyết toán tiệc cưới/hội nghị.

Các biến dưới đây được thiết lập khớp với cấu trúc cơ sở dữ liệu và kết quả trả về của Stored Procedure `API_DanhSachQuyetToan`.

---

## 1. Thông tin chung của Hợp đồng & Khách hàng
1. `{Sohopdong}`: Số hợp đồng tiệc (Ví dụ: `HD2026-001`).
2. `{KhachHang}`: Tên khách hàng đặt tiệc (Cột `Tenkh` liên kết).
3. `{LoaiHinhSK}`: Loại hình sự kiện (Ví dụ: `TIỆC CƯỚI`, `HỘI NGHỊ`).
4. `{SoLuongKhach}`: Số lượng khách mời và số bàn (Ví dụ: `50 BÀN (500 KHÁCH)`).
5. `{SanhTiec}`: Tên sảnh tổ chức tiệc (Ví dụ: `Gold 1`, `Queen 2`).
6. `{NgayToChuc}`: Ngày tổ chức tiệc cưới/hội nghị (Định dạng: `dd/MM/yyyy`).
7. `{ThoiGian}`: Ca/Giờ diễn ra sự kiện (Ví dụ: `Ca trưa`, `18:00`).
8. `{NVKD}`: Tên nhân viên kinh doanh quản lý hợp đồng.

## 2. Thông tin chung của Phiếu Quyết Toán
9. `{DocumentID}`: Số phiếu quyết toán tiệc (Cột `DocumentID` trong bảng `tbmk_Phieuthu`).
10. `{NgayQuyetToan}` / `{ThangQuyetToan}` / `{NamQuyetToan}`: Ngày, tháng, năm lập hóa đơn quyết toán.

## 3. Các chỉ số Tài chính & Thanh toán
11. `{Cong1}`: Tổng chi phí hợp đồng gốc trước phát sinh (Ví dụ: `150.000.000`).
12. `{Cong2}`: Tổng các khoản chi phí phát sinh thực tế tại tiệc (Ví dụ: `12.500.000`).
13. `{TongCong12}`: Cộng tiền chi phí (Mục 1 + Mục 2) trước thuế và phục vụ phí.
14. `{PhiPhucVu}`: Phí phục vụ tiệc phát sinh (nếu có).
15. `{TongCongChuaVAT}`: Tổng cộng tiền trước thuế VAT.
16. `{VAT 8}`: Số tiền thuế VAT 8% (nếu chọn xuất hóa đơn VAT 8%).
17. `{VAT 10}`: Số tiền thuế VAT 10% (nếu chọn xuất hóa đơn VAT 10%).
18. `{TongTien}`: Tổng tiền thanh toán cuối cùng của hóa đơn quyết toán.
19. `{TruCoc}`: Tổng số tiền khách hàng đã đặt cọc trước đó (Sẽ tự động trừ đi).
20. `{ThanhToanConLai}`: Số tiền còn lại khách hàng phải thanh toán thêm cho nhà hàng (Hoặc số tiền nhà hàng hoàn trả nếu cọc dư).

---

## 4. Bảng lặp chi tiết - Danh sách Dịch vụ/Thực đơn chính (`#DanhSachDichVu` ... `/DanhSachDichVu`)
Vùng này chứa danh sách các món ăn chính, nước uống và các gói dịch vụ cơ bản ban đầu của tiệc cưới.
* `{STT}`: Số thứ tự dòng.
* `{DienGiai}`: Tên món ăn / Đồ uống / Dịch vụ tổ chức.
* `{DVT}`: Đơn vị tính (Bàn, Két, Lon, Lần...).
* `{SoLuong}`: Số lượng thực dùng.
* `{DonGia}`: Đơn giá.
* `{ThanhTien}`: Thành tiền của dòng.

## 5. Bảng lặp chi tiết - Danh sách Phát sinh tại Tiệc (`#DichVuPhatSinh` ... `/DichVuPhatSinh`)
Vùng này hiển thị các chi phí phát sinh ngoài hợp đồng ban đầu (Ví dụ: bàn tăng, uống bia thêm, bù sảnh, dịch vụ khói lạnh phát sinh...).
* `{STT}`: Số thứ tự dòng.
* `{DienGiai}`: Tên chi phí phát sinh / phí bù sảnh / phí trang trí.
* `{DVT}`: Đơn vị tính.
* `{SoLuong}`: Số lượng.
* `{DonGia}`: Đơn giá.
* `{ThanhTien}`: Thành tiền phát sinh.

---
**Hướng dẫn thực hiện tiếp theo:**
Hãy mở file `quyet_toan.docx` bằng **OnlyOffice** hoặc **Microsoft Word**, tìm các vị trí tương ứng để đặt các biến `{...}` phía trên (đặc biệt lưu ý viết đúng tên biến và khoảng trắng đối với `{VAT 8}` và `{VAT 10}`).
