# DANH SÁCH CÁC TRƯỜNG DỮ LIỆU CẦN ĐIỀN TRONG BIÊN BẢN GIAO NHẬN TIỆC HỘI NGHỊ (BIEN BAN GIAO NHAN TIEC HOI NGHI.docx)

Tài liệu này chi tiết các vị trí cần điền dữ liệu động (Placeholders) trong mẫu **Biên bản Giao Nhận Tiệc Hội Nghị** (`BIEN BAN GIAO NHAN TIEC HOI NGHI.docx`) để phục vụ kết xuất bằng `docxtemplater`.

---

## 1. Thông tin Hội nghị & Sự kiện
*   `{NgayHoiNghi}`: Ngày tổ chức hội nghị (Định dạng: `dd/MM/yyyy`).
*   `{GioHoiNghi}`: Thời gian diễn ra hội nghị (Ví dụ: `08h00 - 17h00`).
*   `{SanhDat}`: Sảnh hội nghị diễn ra (Ví dụ: `Sảnh Lux ABCD`).
*   `{LoaiSuKien}`: Loại hình sự kiện (Ví dụ: `Hội nghị đại biểu`, `Hội thảo khoa học`).
*   `{SoKhachDat}`: Số lượng khách đặt trước theo hợp đồng.
*   `{SoKhachDuPhong}`: Số lượng khách dự phòng.

---

## 2. Thông tin Đối tác & Đại diện
*   `{DonViToChuc}`: Đơn vị / Tên công ty đứng ra tổ chức hội nghị.
*   `{DaiDienB}`: Họ tên người đại diện chủ tiệc.
*   `{DienThoaiB}`: Số điện thoại liên hệ Bên B.
*   `{DaiDienA}`: Đại diện sảnh tiệc phía nhà hàng (Bên A).
*   `{ChucDanhDaiDienA}`: Chức danh của đại diện nhà hàng.

---

## 3. Checklist dịch vụ đặt trước (Setup Checklist)
Hệ thống sử dụng các thẻ Checkmark (đánh dấu x) hoặc dữ liệu Text tùy vào yêu cầu của khách hàng:
*   `{Check_PhongSanKhau}`: Trạng thái phông sân khấu.
*   `{Check_AnhSang}`: Trạng thái hệ thống ánh sáng.
*   `{Check_Micro}`: Số lượng/trạng thái micro không dây.
*   `{Check_MayChieu}`: Số lượng/trạng thái máy chiếu/LED.
*   `{Check_AmThanh}`: Trạng thái hệ thống âm thanh.
*   `{Check_BucPhatBieu}`: Trạng thái bục phát biểu.
*   `{Check_HoaTuoi}`: Setup hoa tươi (bàn đón khách, bục phát biểu).
*   `{Check_VanPhongPham}`: Folder, giấy viết, bút bi cho khách.
*   `{Check_BangHuongDan}`: Bảng chỉ dẫn khu vực lobby.
*   `{Check_BanLeTan}`: Setup bàn lễ tân đón khách.
*   `{Check_NuocSuoi}`: Nước suối setup trên bàn hội nghị.
*   `{Check_TeaBreak}`: Thời gian và thực đơn Tea break.
*   `{Check_DichVuKhac}`: Các hạng mục thiết bị phụ trợ khác.

---

## 4. Dịch vụ phát sinh và Tổng kết sự kiện
*   `{PhatSinhTrongHoiNghi}`: Ghi nhận các hạng mục phát sinh thêm (Ví dụ: thuê thêm micro, kéo dài thời gian sử dụng sảnh).
*   `{GioBatDauThucTe}`: Thời gian bắt đầu thực tế của hội nghị.
*   `{GioKetThucThucTe}`: Thời gian kết thúc thực tế.
*   `{SoKhachThucTe}`: Số lượng khách tham gia thực tế sau khi kiểm đếm.
*   `{SoKhachPhatSinh}`: Số lượng khách vượt trội so với đặt trước.
