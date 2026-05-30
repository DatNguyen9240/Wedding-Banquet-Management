# Danh sách Công việc Cần làm (TODO) - Dự án Quản lý Tiệc Cưới

Dựa trên tài liệu `REQUIREMENT.md` và tiến độ hiện tại, dưới đây là các hạng mục cốt lõi còn thiếu hoặc chưa hoàn thiện 100% (mới dừng ở mức giao diện mẫu).

## 1. Các Module Nghiệp vụ Lớn (Cần áp dụng DynamicFormEngine & Xử lý Logic)
- [ ] **Hợp đồng tiệc (`#/contract`)**: 
  - Hoàn thiện xử lý 10 Tabs phức tạp (Bàn Tiệc, Sảnh, Thực đơn Mặn/Chay, Ưu đãi, Thức uống, Dịch vụ, Ghi chú, Setup Print, Dời/Hủy).
- [ ] **Quyết toán tiệc (`#/checkout`)**: 
  - Hoàn thiện các Tab: Phát sinh, Giảm giá 3 cách, Tính toán doanh thu thực tế.
  - Xử lý logic **Giải phóng sảnh** (đổi trạng thái sảnh trống) sau khi lưu quyết toán.
- [ ] **Trạng thái Sảnh (`#/hall-status`)**: 
  - Kết nối dữ liệu thực tế từ bảng `SanhTiec` và `HopDongTiec`.
  - Hiển thị đúng logic màu sắc: Xanh (Trống), Vàng (Đã cọc), Đỏ (Đã ký HĐ), Xám (Bảo trì).
- [ ] **Thông tin Thay đổi – Bổ sung & Sắp đặt tiệc**:
  - Tạo form hoặc cơ chế ghi nhận các thay đổi sau khi ký hợp đồng và in phiếu Sắp đặt tiệc cho các bộ phận.

## 2. Liên thông & Tự động hóa Dữ liệu (Workflow)
- [ ] **Luồng dữ liệu tự động điền**: Khách tham quan -> Tự fill data sang Biên nhận cọc chỗ -> Tự fill data sang Hợp đồng.
- [ ] **Quản lý Tiền cọc**: Tính toán hiển thị số tiền còn thiếu để đủ 40% giá trị hợp đồng (cọc lần 2).

## 3. Trải nghiệm Người dùng & Phím tắt (Keyboard Shortcuts)
- [x] Bắt sự kiện phím `Space` để check/uncheck checkbox trong lưới.
- [x] Bắt sự kiện phím `F4` để mở danh sách dropdown/combobox.
- [x] Bắt sự kiện phím `F3` để mở danh sách tra cứu.
- [x] Bắt sự kiện phím `F2` để mở form thêm mới danh mục nhanh.

## 4. Quản trị Hệ thống & Cấu hình
- [x] **Sao lưu dữ liệu**: Xử lý logic tạo file backup tự động với format `[TênDB]_YYYY_MM_DD_HH_mm_ss`.
- [ ] **Khóa/Mở kỳ sử dụng**: Áp dụng logic chặn chặt chẽ (không cho lập phiếu Nhập/Xuất/Hợp đồng nếu kỳ đã bị khóa).
- [ ] **Thiết lập Logo**: Cho phép cập nhật file ảnh `Qplaza\Logo\logo.jpg` vào hệ thống.

## 5. Cảnh báo & Thống kê (Dashboard)
- [x] **Widget Cảnh báo thanh toán**: Hiển thị trên Dashboard danh sách các hợp đồng sắp đến hạn thanh toán (trong vòng 7 ngày) hoặc đã quá hạn (cảnh báo đỏ).
- [ ] **Báo cáo động**: Cập nhật logic để các biểu đồ và báo cáo (Doanh thu, Chi phí, Khảo sát) lấy đúng dữ liệu thật từ Backend thay vì Mock Data.
