# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG PHIẾU THU CỌC
Dựa trên việc đọc kỹ nội dung file `phieu_thu.docx`, dưới đây là danh sách chi tiết các trường thông tin động cần được điền bằng `docxtemplater` khi in phiếu thu cọc (Cọc giữ chỗ/sảnh hoặc Cọc thực hiện HĐ).

Các biến dưới đây được thiết lập khớp với cấu trúc cơ sở dữ liệu `tbPhieuthu` và thông tin khách hàng liên quan.

## 1. Thông tin đơn vị lập phiếu (Bên A)
1. `{TenNhaHang}`: Tên công ty/nhà hàng (Ví dụ: `CÔNG TY TNHH GIẢI TRÍ HOÀNG HẢI`).
2. `{DiaChiNhaHang}`: Địa chỉ của nhà hàng (Ví dụ: `16A Lê Hồng Phong (nối dài), P. Hòa Hưng, TP.HCM`).

## 2. Thông tin chung của Phiếu Thu
3. `{SoPhieu}`: Mã số phiếu thu (Cột `SPthu` hoặc `DocumentID`).
4. `{NgayThu}` / `{ThangThu}` / `{NamThu}`: Ngày, tháng, năm lập phiếu thu tiền (Tách từ cột `Ngaythu`).
5. `{TaiKhoanNo}`: Tài khoản Nợ trong kế toán (Mặc định trống hoặc điền động).
6. `{TaiKhoanCo}`: Tài khoản Có trong kế toán (Mặc định trống hoặc điền động).

## 3. Thông tin Khách hàng & Thanh toán
7. `{Sohopdong}`: Mã số hợp đồng đặt tiệc liên kết (Cột `Sohopdong`).
8. `{Nguoinop}`: Họ và tên người nộp tiền (Cột `Nguoinop`).
9. `{DiaChi}`: Địa chỉ liên hệ của người nộp (Cột `Diachi` từ bảng khách hàng).
10. `{Lydo}`: Lý do nộp tiền (Cột `Lydo` - Ví dụ: `Cọc giữ chỗ sảnh cưới lần 1` hoặc `Cọc thực hiện HĐ lần 2`).
11. `{Tongtien}`: Số tiền đóng bằng số (Cột `Tongtien` - Định dạng đẹp, ví dụ: `10.000.000 VNĐ`).
12. `{HinhThuc}`: Hình thức nộp tiền (Tiền mặt / Chuyển khoản, dựa trên cột `IsTienmat`).
13. `{SoTienBangChu}`: Số tiền bằng chữ tương ứng của `{Tongtien}`.
14. `{Kemtheo}`: Số lượng chứng từ gốc kèm theo (Cột `Kemtheo`).

---
**Hướng dẫn thực hiện tiếp theo:**
Hãy mở file `phieu_thu.docx` bằng **OnlyOffice** hoặc **Microsoft Word**, tìm các vùng có dấu chấm lửng `...` hoặc thông tin tĩnh và thay thế bằng các biến `{...}` tương ứng trên để hệ thống tự động binding dữ liệu khi in phiếu.
