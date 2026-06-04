# DANH SÁCH TRƯỜNG PHIẾU ĐỀ NGHỊ THAY ĐỔI - BỔ SUNG THÔNG TIN TIỆC

Tài liệu này xác định các vị trí cần điền dữ liệu động (Placeholders) trong mẫu `de_nghi_thay_doi.docx` để xuất file thông qua thư viện `docxtemplater`. Các trường được ánh xạ trực tiếp từ bảng `tbmk_Thaydoi`, `tbmk_Hopdong` và `dmkhachhang`.

---

## 1. Bản dịch nội dung tài liệu và vị trí điền trường (Placeholders)

Dưới đây là phần nội dung gốc trong văn bản được thay thế bằng các Placeholder tương ứng:

```text
                               ĐỀ NGHỊ THAY ĐỔI LẦN {LanThayDoi} - BỔ SUNG THÔNG TIN TIỆC
                               
Khách hàng đề nghị: {KhachHang}                         Bên tiếp nhận: {NVKD}
Liên quan đến Hợp đồng số: {Sohopdong}                  ký ngày: {NgayHopDong}
Tổ chức tiệc: {TenTiec}                                 Ngày: {NgayToChuc}; Sảnh: {SanhTiec}
Số bàn: {SoBanChinhThuc} bàn chính thức, {SoBanTang} bàn tặng và {SoBanDuPhong} bàn dự phòng

[BẢNG CHI TIẾT THAY ĐỔI]
STT   Nội dung thay đổi
{#ChiTietThayDoi}
{STT} {NoiDung}
{/ChiTietThayDoi}

Tổng cộng: {MoTaTongSoBanSauThayDoi}
Phụ thu phí sảnh: {PhiBuSanh} VND

                                                        Ngày {NgayThayDoi} tháng {ThangThayDoi} năm {NamThayDoi}
          KHÁCH HÀNG                       QLKD                            BÊN TIẾP NHẬN
```

---

## 2. Chi tiết ánh xạ các trường (100% Khớp Cơ sở dữ liệu)

| Placeholder trong Word | Kiểu dữ liệu | Bảng & Cột dữ liệu gốc | Mô tả / Công thức hiển thị |
| :--- | :--- | :--- | :--- |
| `{LanThayDoi}` | Số (INT) | `tbmk_Thaydoi.LanThayDoi` | Lần thay đổi thứ mấy của hợp đồng này. |
| `{KhachHang}` | Chuỗi | `dmkhachhang.Tenkh` | Tên khách hàng (nối từ `Makh` qua `tbmk_Hopdong`). |
| `{NVKD}` | Chuỗi | `dmNhanvien.Tennv` | Tên nhân viên tiếp nhận phiếu (nối từ `Manv` trong `tbmk_Thaydoi`). |
| `{Sohopdong}` | Chuỗi | `tbmk_Thaydoi.Sohopdong` | Số hợp đồng tiệc gốc. |
| `{NgayHopDong}` | Ngày | `tbmk_Hopdong.Ngayhopdong` | Ngày ký hợp đồng gốc (Định dạng: `dd/MM/yyyy`). |
| `{TenTiec}` | Chuỗi | `tbmk_Hopdong.Tentiec` | Tên chủ tiệc (Ví dụ: "Chú rể Nguyễn Văn A & Cô dâu Trần Thị B"). |
| `{NgayToChuc}` | Ngày | `tbmk_Thaydoi.Ngaytochuc` | Ngày diễn ra tiệc cưới thực tế (Định dạng: `dd/MM/yyyy`). |
| `{SanhTiec}` | Chuỗi | `dmSanhtiec.Tensanhtiec` | Tên sảnh tiệc (Lấy từ `tbmk_Hopdongsanhtiec` join với `dmSanhtiec`). |
| `{SoBanChinhThuc}` | Số | `tbmk_Thaydoi.SobanManchinhthuc` | Số bàn chính thức sau thay đổi. |
| `{SoBanTang}` | Số | `tbmk_Thaydoi.SoBanTang` | Số bàn tặng sau thay đổi. |
| `{SoBanDuPhong}` | Số | `tbmk_Thaydoi.SobanManduphong` | Số bàn dự phòng sau thay đổi. |
| `{MoTaTongSoBanSauThayDoi}`| Chuỗi | Tự động sinh từ SQL | Ví dụ: `"37 bàn chính thức và 02 bàn dự phòng"` |
| `{PhiBuSanh}` | Số | `tbmk_Thaydoi.PhiBuSanh` | Tiền phụ thu phí sảnh (Định dạng: `N0` vi-VN). |
| `{NgayThayDoi}` | Số | `tbmk_Thaydoi.Ngaythaydoi` | Ngày ký phiếu (Định dạng: `dd`). |
| `{ThangThayDoi}` | Số | `tbmk_Thaydoi.Ngaythaydoi` | Tháng ký phiếu (Định dạng: `MM`). |
| `{NamThayDoi}` | Số | `tbmk_Thaydoi.Ngaythaydoi` | Năm ký phiếu (Định dạng: `yyyy`). |

### Đối với bảng vòng lặp chi tiết `{#ChiTietThayDoi}`:
Bảng này sẽ liệt kê chi tiết các nội dung thay đổi. Chúng ta có thể sinh dữ liệu động bằng cách so sánh các trường trước và sau thay đổi (ví dụ: So sánh `SobanManchinhthuc` trước/sau để sinh dòng "Tăng/Giảm X bàn chính thức").

*   `{STT}`: Số thứ tự dòng.
*   `{NoiDung}`: Nội dung thay đổi (Ví dụ: "Tăng 01 bàn chính thức", "Thay đổi sảnh từ Queen 1 sang Queen 2", "Bổ sung gói dịch vụ trang trí sân khấu").
