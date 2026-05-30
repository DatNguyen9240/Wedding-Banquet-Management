# Danh sách Công việc Cần làm (TODO) - Dự án Quản lý Tiệc Cưới

Sau khi hoàn thiện hầu hết các tính năng theo REQUIREMENT, đây là những công việc THỰC SỰ CÒN THIẾU và cần làm tiếp theo:

## 1. Thông tin Thay đổi – Bổ sung & Sắp đặt tiệc (Mục IV.9 & IV.10)
- **Tình trạng:** CHƯA LÀM.
- **Mô tả:** Tài liệu yêu cầu có form riêng để ghi nhận những "Thay đổi - Bổ sung" sau khi hợp đồng đã ký (thay vì sửa trực tiếp vào hợp đồng gốc). Đồng thời cần phiếu "Sắp đặt tiệc" để in ra cho nhà bếp/lễ tân.
- **Hành động:** 
  - Hoặc là tạo thêm một Dynamic Form `frmThayDoiBoSung` và `frmSapDatTiec`.
  - Hoặc là thống nhất chỉ cần Edit trực tiếp trên `frmHopDong` để tiết kiệm thời gian (cần chốt lại với khách hàng).

## 2. Ghép API thật (Tích hợp Dữ liệu)
- **Tình trạng:** ĐANG DÙNG MOCK DATA (Dữ liệu giả).
- **Hành động:** Cần nối các form giao diện vào các API viết trong SQL (`API_LuuHopDong`, `API_LuuKhachHang`...) qua tầng backend.

## 3. Liên thông dữ liệu các bước
- **Tình trạng:** Giao diện đã có nhưng chưa truyền dữ liệu qua lại.
- **Hành động:** Viết logic JS để: Khách tham quan -> Tự fill data sang Biên nhận cọc -> Tự fill data sang Hợp đồng -> Quyết toán xong thì đổi trạng thái sảnh.

*(Ghi chú: Các tính năng Tạo Ngày Tháng, Khóa Kỳ Kế Toán, Sao lưu dữ liệu đã được code xong và tích hợp rất khéo léo vào trong `categories.js` và `settings.js`, vượt mức mong đợi ban đầu!)*