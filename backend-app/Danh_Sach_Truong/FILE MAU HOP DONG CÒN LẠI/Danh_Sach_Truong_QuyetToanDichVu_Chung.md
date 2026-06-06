# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN QUYẾT TOÁN DỊCH VỤ CHUNG (4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản nghiệm thu & Quyết toán dịch vụ chung** (`4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Biên bản & Căn cứ Hợp đồng
*   `{SoBBNT}`: Số biên bản nghiệm thu và quyết toán (Ví dụ: `46/CTY-HHKH/2026/NT-QT`).
*   `{SoHD}`: Số hợp đồng gốc ký kết trước đó (Ví dụ: `46/CTY-HHKH/2026`).
*   `{NgayKyHD}`: Ngày ký hợp đồng gốc (Định dạng: `dd/MM/yyyy`).
*   `{TenChuDeSuKien}`: Tên chương trình / Chủ đề sự kiện (Ví dụ: `Hội nghị tổng kết năm 2026`).
*   `{NgayToChuc}`: Ngày tổ chức sự kiện thực tế (Định dạng: `dd/MM/yyyy`).
*   `{NgayQuyetToan}`: Ngày hai bên ký biên bản quyết toán này (Ví dụ: `22/04/2026`).

---

## 2. Thông tin các bên ký kết (Bên A & Bên B)
*   `{BenA_DaiDien}`: Người đại diện Bên A ký quyết toán (Mặc định: `LÊ VĂN PHƯỚC`).
*   `{BenA_ChucVu}`: Chức vụ đại diện Bên A (Mặc định: `Giám Đốc`).
*   `{TenCongTy}`: Tên đơn vị / Tên công ty Bên B (Ví dụ: `CÔNG TY TNHH MAKITA VIỆT NAM`).
*   `{DaiDienB}`: Họ tên người đại diện ký quyết toán phía Bên B.
*   `{ChucVuB}`: Chức vụ của đại diện Bên B (Ví dụ: `Giám Đốc`).
*   `{DiaChiB}`: Địa chỉ trụ sở Bên B.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{MSTB}`: Mã số thuế Bên B.

---

## 3. Bảng Nghiệm thu & Quyết toán Dịch vụ thực tế
Bảng lặp động hiển thị toàn bộ dịch vụ đã sử dụng thực tế:
*   Mảng: `{#QuyetToanDichVu}` ... `{/QuyetToanDichVu}`
    *   `{STT}`: Số thứ tự hạng mục dịch vụ.
    *   `{TenDV}`: Tên nội dung dịch vụ nghiệm thu (Ví dụ: `Phí setup không máy lạnh`, `Tea Break`, `Màn hình Led 18m2`).
    *   `{ThoiGian}`: Thời gian sử dụng thực tế (Ví dụ: `11h00 - 13h00`).
    *   `{Sanh}`: Sảnh tổ chức nghiệm thu (Ví dụ: `LUXURY AB`).
    *   `{DVT}`: Đơn vị tính (`Giờ`, `Sảnh`, `Phần`, `Show`).
    *   `{SL}`: Số lượng thực tế đã tiêu dùng.
    *   `{DonGia}`: Đơn giá thực tế.
    *   `{ThanhTien}`: Thành tiền thực tế (`SL * DonGia`).

---

## 4. Tổng hợp Quyết toán, Đối trừ đặt cọc & Thanh toán
*   `{TongThanhTien}`: Tổng cộng thành tiền thực tế trước thuế & phí dịch vụ (VNĐ).
*   `{PhiPhucVu}`: Trị giá 5% phí phục vụ tính trên Tổng thành tiền.
*   `{VAT8}`: Thuế GTGT 8% cho đồ ăn, thức uống, phí phục vụ & dịch vụ ăn uống.
*   `{VAT10}`: Thuế GTGT 10% cho các chi phí thuê sảnh, LED & dịch vụ kỹ thuật.
*   `{TongQuyetToan}`: Tổng giá trị quyết toán thực tế sau thuế (VNĐ).
*   `{TongQuyetToanBangChu}`: Tổng giá trị quyết toán bằng chữ tiếng Việt.
*   `{SoTienDaDatCoc}`: Số tiền đặt cọc Bên B đã thanh toán trước đó để giữ chỗ (VNĐ).
*   `{NgayThanhToanCoc}`: Ngày Bên B đã chuyển khoản đặt cọc đợt 1 (Định dạng: `dd/MM/yyyy`).
*   `{SoTienConLai}`: Số tiền còn lại Bên B có trách nhiệm thanh toán thêm cho Bên A (`TongQuyetToan - SoTienDaDatCoc`).
*   `{SoTienConLaiBangChu}`: Số tiền còn lại phải thanh toán viết bằng chữ.
