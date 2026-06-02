# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG PHIẾU THU CỌC
Dựa trên việc đọc kỹ nội dung file `phieu_thu.docx`, dưới đây là danh sách chi tiết các trường thông tin động cần được điền bằng `docxtemplater` khi in phiếu thu cọc (Cọc giữ chỗ/sảnh hoặc Cọc thực hiện HĐ).

Các biến dưới đây được thiết lập khớp với cấu trúc cơ sở dữ liệu `tbPhieuthu` và thông tin khách hàng liên quan.

## 1. Thông tin đơn vị lập phiếu (Bên A)
1. `{Tên nhà hàng}`: Tên công ty/nhà hàng (Ví dụ: `CÔNG TY TNHH GIẢI TRÍ HOÀNG HẢI`).
2. `{Địa chỉ nhà hàng}`: Địa chỉ của nhà hàng (Ví dụ: `16A Lê Hồng Phong (nối dài), P. Hòa Hưng, TP.HCM`).

## 2. Thông tin chung của Phiếu Thu
3. `{Số phiếu}`: Mã số phiếu thu (Cột `SoBN` hoặc `DocumentID`).
4. `{Ngày}` / `{Tháng}` / `{Năm}`: Ngày, tháng, năm lập phiếu thu tiền (Tách từ cột `Ngaythu`).
5. `{Tài khoản nợ}`: Tài khoản Nợ trong kế toán.
6. `{Tài khoản có}`: Tài khoản Có trong kế toán.

## 3. Thông tin Khách hàng & Thanh toán
7. `{Số hợp đồng}`: Mã số hợp đồng đặt tiệc liên kết (Cột `Sohopdong`).
8. `{Người nộp}`: Họ và tên người nộp tiền.
9. `{Địa chỉ}`: Địa chỉ liên hệ của người nộp.
10. `{Lý do}`: Lý do nộp tiền.
11. `{Tổng tiền}`: Số tiền đóng bằng số (Định dạng đẹp, ví dụ: `10.000.000`).
12. `{Hình thức}`: Hình thức nộp tiền (Tiền mặt / Chuyển khoản).
13. `{Số tiền bằng chữ}`: Số tiền bằng chữ tương ứng của `{Tổng tiền}`.
14. `{Kèm theo}`: Số lượng chứng từ gốc kèm theo.

---
**Hướng dẫn thực hiện tiếp theo:**
Hãy mở file `phieu_thu.docx` bằng **OnlyOffice** hoặc **Microsoft Word**, tìm các vùng có dấu chấm lửng `...` hoặc thông tin tĩnh và thay thế bằng các biến `{...}` tương ứng trên để hệ thống tự động binding dữ liệu khi in phiếu.
