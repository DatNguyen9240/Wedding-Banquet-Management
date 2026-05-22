# Danh sách Công việc Cần làm (TODO) - Dự án Quản lý Tiệc Cưới

Sau khi hoàn thành bộ khung giao diện (UI) cho tất cả các màn hình, dự án hiện đang ở giai đoạn **Tích hợp & Hoàn thiện Nghiệp vụ**. Dưới đây là danh sách chi tiết các công việc chưa làm và cần thực hiện tiếp theo:

## 1. Tích hợp Dữ liệu thật (API Integration) thay cho MockData
Các màn hình hiện tại đang sử dụng dữ liệu giả (MockData). Cần kết nối giao diện với các file trong thư mục `src/js/services/`.

- [ ] **Màn hình Khách hàng (`#/customers`):** Gọi API để load danh sách khách hàng thực, tìm kiếm và phân trang.
- [ ] **Màn hình Lịch tiệc (`#/calendar`):** Lấy dữ liệu tiệc theo tháng thực tế để hiển thị lên lịch (màu xanh/đỏ).
- [ ] **Màn hình Trạng thái Sảnh (`#/hall-status`):** Gọi API lấy tình trạng sảnh trong ngày để tô màu chuẩn (Trống, Cọc, Hợp đồng, Bảo trì).
- [ ] **Màn hình Báo cáo (`#/report-revenue`, `#/report-cost`...):** Gọi API lấy doanh thu/chi phí thực tế, vẽ biểu đồ và xuất Excel.
- [ ] **Các trang giao dịch (Khách tham quan, Cọc, Hợp đồng, Quyết toán):** Đảm bảo tính năng Thêm/Sửa/Xóa lưu thẳng xuống Database qua các hàm trong API.

## 2. Hoàn thiện Luồng Quy trình (Business Logic Flow)
Phần mềm yêu cầu luồng dữ liệu liên thông chặt chẽ giữa các bước giao dịch.

- [ ] **Liên thông dữ liệu Khách Tham Quan ➔ Biên nhận Cọc 1:** Tự động điền tên, SĐT, thông tin cơ bản khi khách cũ quay lại cọc.
- [ ] **Liên thông dữ liệu Cọc ➔ Hợp đồng:** Kế thừa Ngày tổ chức, Sảnh, Số bàn, Tổng tiền cọc chuyển sang làm Hợp đồng.
- [ ] **Quyết toán Tiệc ➔ Giải phóng Sảnh:** Logic cập nhật trạng thái sảnh từ Đỏ (Đã ký) sang Xanh (Trống) sau khi lưu Quyết toán.
- [ ] **Validation Dữ liệu:** 
  - Ràng buộc: Số hợp đồng không được có dấu.
  - Ràng buộc: Khi đặt sảnh, bắt buộc phải chọn 1 Sảnh chính.
  - Cảnh báo: Chọn Kỳ/Năm sử dụng phải chuẩn xác trước khi cho lưu dữ liệu.

## 3. Cập nhật & Triển khai Database (SQL Server)
Các tệp thủ tục SQL mới đã được viết/đổi tên nhưng cần chắc chắn đã được thực thi vào DB.

- [ ] Chạy các script `.sql` trong thư mục `sql/` (như `API_LuuHopDong.sql`, `API_DongBoQuyenTruyCap.sql`, `API_DanhSach...`) vào database.
- [ ] Kiểm tra bảng `SanhTiec` và `HopDongTiec` để hỗ trợ tính năng màn hình Trạng thái sảnh (Hall-Status).
- [ ] Đảm bảo cơ sở dữ liệu có sẵn bảng danh mục hệ thống (Ngày tháng, Năm âm lịch, Khu vực...).

## 4. Áp dụng Phân Quyền Người dùng (RBAC)
Đã có màn hình phân quyền, nhưng chưa áp dụng logic khóa UI trên toàn hệ thống.

- [ ] Viết logic (hoặc middleware) kiểm tra quyền của User đang đăng nhập (Xem, Thêm, Sửa, Xóa).
- [ ] Tại mỗi form (như Lập Hợp Đồng, Quản lý Khách hàng): Ẩn/hiện hoặc vô hiệu hóa (`disabled`) các nút `[Thêm]`, `[Sửa]`, `[Xóa]` dựa theo quyền.
- [ ] Nếu User cố truy cập URL trang không có quyền, chuyển hướng ra báo lỗi "Từ chối truy cập".

## 5. Tính năng Bổ sung Cần xử lý
- [ ] Cảnh báo thời hạn thanh toán (Quá hạn hoặc sắp tới hạn) trên màn hình Dashboard.
- [ ] Tích hợp tính năng Sao lưu dữ liệu trực tiếp từ phần mềm (`Hệ thống > Sao lưu dữ liệu`).
