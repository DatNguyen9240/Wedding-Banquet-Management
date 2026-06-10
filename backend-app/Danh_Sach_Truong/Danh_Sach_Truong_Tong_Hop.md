# Danh Sách Trường Tổng Hợp (Hợp Đồng & Tiệc)

Tài liệu này tổng hợp toàn bộ các trường dữ liệu (placeholder `{}`) được trích xuất từ 4 file mẫu hợp đồng bao gồm:
1. **2.1 MAU HDONG - 0406 (TRIỂN LÃM + TIỆC).docx** (98 trường)
2. **2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx** (79 trường)
3. **3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx** (98 trường)
4. **3.2 MAU HDONG - 0406 (HỘI NGHỊ ).docx** (74 trường)

---

## I. Bảng Tổng Hợp So Khớp Giữa Các Mẫu File

Dưới đây là bảng thống kê sự xuất hiện của các trường trong từng loại hợp đồng mẫu:
* **[2.1]**: Triển Lãm + Tiệc
* **[2.2]**: Triển Lãm
* **[3.1]**: Hội Nghị + Tiệc - Teabreak
* **[3.2]**: Hội Nghị

| STT | Tên Trường | Ý Nghĩa / Ghi Chú | [2.1] | [2.2] | [3.1] | [3.2] |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: |
| 1 | `{Sohopdong}` | Số hợp đồng | x | x | x | |
| 2 | `{NgayLapHD}` | Ngày lập hợp đồng | x | x | x | x |
| 3 | `{ThangLapHD}` | Tháng lập hợp đồng | x | x | x | x |
| 4 | `{NamLapHD}` | Năm lập hợp đồng | x | x | x | x |
| 5 | `{NgayToChuc}` | Ngày tổ chức sự kiện (BM02) | x | x | x | |
| 6 | `{BenATenCongTy}` | Tên công ty Bên A | x | x | x | x |
| 7 | `{BenADiaChi}` | Địa chỉ Bên A | x | x | x | x |
| 8 | `{BenASDT}` | Số điện thoại Bên A | x | x | x | x |
| 9 | `{BenAMST}` | Mã số thuế Bên A | x | x | x | x |
| 10 | `{BenANhanVienPhuTrach}` | Nhân viên phụ trách bên A | x | x | x | x |
| 11 | `{BenAChucVu}` | Chức vụ nhân viên phụ trách bên A | x | x | x | x |
| 12 | `{BenASDTNhanVien}` | Số điện thoại nhân viên phụ trách bên A | x | x | x | x |
| 13 | `{BenAEmail}` | Email nhân viên phụ trách bên A | x | x | x | x |
| 14 | `{BenBTenChuTiec}` | Tên chủ tiệc Bên B (BM02) | x | x | x | x |
| 15 | `{BenBTenDaiDien}` | Tên người đại diện Bên B | x | x | x | x |
| 16 | `{BenBChucVu}` | Chức vụ người đại diện Bên B | x | x | x | x |
| 17 | `{BenBDiaChi}` | Địa chỉ Bên B (BM02) | x | x | x | x |
| 18 | `{BenBDienThoai}` | Số điện thoại Bên B (BM02) | x | x | x | x |
| 19 | `{BenBCCCD}` | Số CCCD Bên B | x | x | x | x |
| 20 | `{TenSanhTiec}` | Tên sảnh tiệc chính | x | x | x | x |
| 23 | `{TenSanhTiecPhu}` | Tên sảnh phụ | x | | x | |
| 24 | `{KichThuocSanh}` | Kích thước sảnh chính | x | x | x | x |
| 25 | `{KichThuocSanhPhu}` | Kích thước sảnh phụ | x | | x | |
| 26 | `{TenSanKhau}` | Tên sân khấu chính | x | x | x | x |
| 27 | `{TenSanKhauPhu}` | Tên sân khấu phụ | x | | x | |
| 28 | `{KichThuocSanKhau}` | Kích thước sân khấu chính | x | x | x | x |
| 29 | `{KichThuocSanKhauPhu}` | Kích thước sân khấu phụ | x | | x | |
| 30 | `{SucChuaToiDa}` | Sức chứa tối đa sảnh chính | x | x | x | x |
| 31 | `{SucChuaToiDaPhu}` | Sức chứa tối đa sảnh phụ | x | | x | |
| 32 | `{KhachToiThieu}` | Lượng khách tối thiểu sảnh chính | x | x | x | x |
| 33 | `{SucChuaToiThieuPhu}` | Lượng khách tối thiểu sảnh phụ | x | | x | |
| 34 | `{TiecGioBatDau}` | Giờ bắt đầu tiệc (BM02) | x | x | x | x |
| 35 | `{TiecGioKetThuc}` | Giờ kết thúc tiệc | x | x | x | x |
| 36 | `{SetupBatDau}` | Giờ bắt đầu setup | x | x | x | x |
| 37 | `{SetupKetThuc}` | Giờ kết thúc setup | x | x | x | x |
| 38 | `{SoKhachDiemDanh}` | Số khách dự kiến điểm danh | x | x | x | x |
| 39 | `{SoBanManChinhThuc}` | Số lượng bàn mặn chính thức | x | | x | |
| 40 | `{SoBanManDuPhong}` | Số lượng bàn mặn dự phòng | x | | x | |
| 41 | `{#DichVuTinhPhi}` | Bắt đầu khối dịch vụ tính phí | x | x | x | x |
| 42 | `{TenDichVu}` | Tên dịch vụ tính phí | x | x | x | x |
| 43 | `{STT}` | Số thứ tự trong bảng dịch vụ | x | x | x | x |
| 44 | `{DonGia}` | Đơn giá dịch vụ | x | x | x | x |
| 45 | `{ThanhTien}` | Thành tiền dịch vụ | x | x | x | x |
| 46 | `{GhiChuChiTiet}` | Ghi chú chi tiết dịch vụ | x | x | x | x |
| 47 | `{/DichVuTinhPhi}` | Kết thúc khối dịch vụ tính phí | x | x | x | x |
| 48 | `{#MenuTiec}` | Bắt đầu khối thực đơn tiệc | x | | x | |
| 49 | `{TenMonAn}` | Tên món ăn trong thực đơn | x | | x | |
| 50 | `{/MenuTiec}` | Kết thúc khối thực đơn tiệc | x | | x | |
| 51 | `{MenuTongCong}` | Tổng giá trị thực đơn | x | | x | |
| 52 | `{#DanhSachNgay}` | Bắt đầu khối danh sách ngày sự kiện | x | x | x | x |
| 53 | `{TenNhomNgay}` | Tên nhóm ngày sự kiện | x | x | x | x |
| 54 | `{#DanhSachDV}` | Bắt đầu khối dịch vụ theo ngày | x | x | x | x |
| 55 | `{KhungGio}` | Khung giờ sử dụng dịch vụ | x | x | x | x |
| 56 | `{DVT}` | Đơn vị tính dịch vụ | x | x | x | x |
| 57 | `{SoLuong}` | Số lượng dịch vụ | x | x | x | x |
| 58 | `{UuDai}` | Phần trăm/tiền ưu đãi dịch vụ | x | x | x | x |
| 59 | `{/DanhSachDV}` | Kết thúc khối dịch vụ theo ngày | x | x | x | x |
| 60 | `{/DanhSachNgay}` | Kết thúc khối danh sách ngày | x | x | x | x |
| 61 | `{TongThanhTien}` | Tổng tiền tạm tính trước phí và VAT | x | x | x | x |
| 62 | `{MucPhiPhucVu}` | Mức phí phục vụ (%) | x | x | x | x |
| 63 | `{PhiPhucVu}` | Số tiền phí phục vụ tạm tính | x | x | x | x |
| 64 | `{TongCongChuaVAT}` | Tổng cộng chi phí chưa tính VAT | x | x | x | x |
| 65 | `{VAT8}` | Thuế VAT 8% | x | x | x | x |
| 66 | `{VAT10}` | Thuế VAT 10% | x | x | x | x |
| 67 | `{TongGiaTriTamTinh}` | Tổng giá trị tạm tính (sau VAT) | x | x | x | x |
| 68 | `{TongGiaTriTamTinhBangChu}` | Tổng giá trị tạm tính bằng chữ | x | x | x | x |
| 69 | `{Dot1SoTien}` | Số tiền đặt cọc đợt 1 | x | x | x | |
| 70 | `{Dot1BangChu}` | Số tiền đặt cọc đợt 1 bằng chữ | x | x | x | |
| 71 | `{HDTenCty}` | Tên công ty xuất hoá đơn Bên B | x | x | x | x |
| 72 | `{HDDiaChi}` | Địa chỉ công ty xuất hoá đơn | x | x | x | x |
| 73 | `{HDMaSoThue}` | Mã số thuế công ty xuất hoá đơn | x | x | x | x |
| 74 | `{HDEmail}` | Email nhận hóa đơn điện tử | x | | x | x |
| 75 | `{Email}` | Email liên hệ chung của Bên B | x | x | x | x |
| 76 | `{TongGiaTriQuyetToan}` | Tổng giá trị quyết toán (BBNT) | | | | |
| 77 | `{TongGiaTriQuyetToanBangChu}` | Tổng giá trị quyết toán bằng chữ (BBNT) | | | | |
| 78 | `{SoTienDaDatCoc}` | Số tiền Bên B đã đặt cọc giữ chỗ (BBNT) | | | | |
| 79 | `{NgayThanhToanDatCoc}` | Ngày thanh toán tiền đặt cọc (BBNT) | | | | |
| 80 | `{SoTienConLai}` | Số tiền Bên B còn phải thanh toán (BBNT) | | | | |
| 81 | `{SoTienConLaiBangChu}` | Số tiền còn lại bằng chữ (BBNT) | | | | |
| 82 | `{LoaiHinhSuKien}` | Loại hình sự kiện / Hình thức tiệc (GMPS, BM02) | | | | |
| 83 | `{BanChinhThuc}` | Số bàn chính thức (GMPS) | | | | |
| 84 | `{BanTang}` | Số bàn tặng (GMPS) | | | | |
| 85 | `{BanChay}` | Số bàn chay (GMPS) | | | | |
| 86 | `{BanDuPhong}` | Số bàn dự phòng (GMPS) | | | | |
| 87 | `{BanPhatSinh}` | Số bàn phát sinh (GMPS) | | | | |
| 88 | `{TongSoBan}` | Tổng số bàn thực tế (GMPS, BM02) | | | | |
| 89 | `{#MenuPhatSinh}` | Bắt đầu vòng lặp món phát sinh (GMPS) | | | | |
| 90 | `{MonMan}` | Món mặn phát sinh (GMPS) | | | | |
| 91 | `{MonChay}` | Món chay phát sinh (GMPS) | | | | |
| 92 | `{MonPhatSinh}` | Món phát sinh khác (GMPS) | | | | |
| 93 | `{/MenuPhatSinh}` | Kết thúc vòng lặp món phát sinh (GMPS) | | | | |
| 94 | `{@PhatSinhTrongHoiNghi}` | Các dịch vụ phát sinh trong hội nghị (dạng nhiều dòng, BBGN) | | | | |
| 95 | `{@CacDichVuKhac}` | Các dịch vụ khác trong biên bản giao nhận hội nghị (dạng nhiều dòng, BBGN) | | | | |
| 96 | `{GioBatDauThucTe}` | Giờ bắt đầu thực tế của hội nghị (BBGN) | | | | |
| 97 | `{GioKetThucThucTe}` | Giờ kết thúc thực tế của hội nghị (BBGN) | | | | |
| 98 | `{SoKhachThucTe}` | Số lượng khách tham gia thực tế (BBGN) | | | | |
| 99 | `{SoKhachPhatSinh}` | Số lượng khách phát sinh ngoài (BBGN) | | | | |
| 100 | `{@ThucDonManLuuMau}` | Thực đơn mặn lưu mẫu (dạng nhiều dòng, BBLM) | | | | |
| 101 | `{@ThucDonChayLuuMau}` | Thực đơn chay lưu mẫu (dạng nhiều dòng, BBLM) | | | | |
| 102 | `{GioLayMau}` | Giờ lấy mẫu thức ăn lưu (BBLM) | | | | |
| 103 | `{NgayLayMau}` | Ngày lấy mẫu thức ăn lưu (BBLM) | | | | |
| 104 | `{GioHuyMau}` | Giờ hủy mẫu thức ăn lưu (BBLM) | | | | |
| 105 | `{NgayHuyMau}` | Ngày hủy mẫu thức ăn lưu (BBLM) | | | | |
| 106 | `{#MenuGiaoNhan}` | Bắt đầu vòng lặp thực đơn giao nhận tiệc (BM01) | | | | |
| 107 | `{/MenuGiaoNhan}` | Kết thúc vòng lặp thực đơn giao nhận tiệc (BM01) | | | | |
| 108 | `{#DoUongKiemKe}` | Bắt đầu vòng lặp đồ uống kiểm kê (BM01) | | | | |
| 109 | `{TenNuoc}` | Tên loại nước/đồ uống (BM01) | | | | |
| 110 | `{SLTruocTiec}` | Số lượng đồ uống trước tiệc (BM01) | | | | |
| 111 | `{GhiChu}` | Ghi chú kiểm kê đồ uống (BM01) | | | | |
| 112 | `{/DoUongKiemKe}` | Kết thúc vòng lặp đồ uống kiểm kê (BM01) | | | | |
| 113 | `{#PhatSinhTrongTiec}` | Bắt đầu vòng lặp phát sinh trong tiệc (BM01) | | | | |
| 114 | `{TenPhatSinh}` | Tên mục phát sinh trong tiệc (BM01) | | | | |
| 115 | `{XacNhan}` | Xác nhận phát sinh của khách hàng (BM01) | | | | |
| 116 | `{/PhatSinhTrongTiec}` | Kết thúc vòng lặp phát sinh trong tiệc (BM01) | | | | |
| 117 | `{BanChinhThucDung}` | Số bàn chính thức đã sử dụng (BM01) | | | | |
| 118 | `{BanChayDung}` | Số bàn chay đã sử dụng (BM01) | | | | |
| 119 | `{BanTangDung}` | Số bàn tặng đã sử dụng (BM01) | | | | |
| 120 | `{BanDuPhongDung}` | Số bàn dự phòng đã sử dụng (BM01) | | | | |
| 121 | `{BanPhatSinhDung}` | Số bàn phát sinh đã thêm (BM01) | | | | |
| 122 | `{TongSoBanDung}` | Tổng số bàn đã sử dụng thực tế (BM01) | | | | |
| 123 | `{BiaDung}` | Số bia đã sử dụng (BM01) | | | | |
| 124 | `{BiaTongKet}` | Tổng kết bia (BM01) | | | | |
| 125 | `{BiaTra}` | Số bia trả về kho (BM01) | | | | |
| 126 | `{NuocNgotDung}` | Số nước ngọt đã sử dụng (BM01) | | | | |
| 127 | `{NuocNgotTongKet}` | Tổng kết nước ngọt (BM01) | | | | |
| 128 | `{NuocNgotTra}` | Số nước ngọt trả về kho (BM01) | | | | |
| 129 | `{NuocSuoiDung}` | Số nước suối đã sử dụng (BM01) | | | | |
| 130 | `{NuocSuoiTongKet}` | Tổng kết nước suối (BM01) | | | | |
| 131 | `{NuocSuoiTra}` | Số nước suối trả về kho (BM01) | | | | |
| 132 | `{KhacDung}` | Số mục khác đã sử dụng (BM01) | | | | |
| 133 | `{KhacTongKet}` | Tổng kết mục khác (BM01) | | | | |
| 134 | `{KhacTra}` | Mục khác trả về kho (BM01) | | | | |
| 135 | `{KhanLanhDung}` | Số khăn lạnh đã sử dụng (BM01) | | | | |
| 136 | `{KhanLanhTongKet}` | Tổng kết khăn lạnh (BM01) | | | | |
| 137 | `{KhanLanhTra}` | Số khăn lạnh trả về kho (BM01) | | | | |
| 138 | `{DauPhongDung}` | Số đậu phộng đã sử dụng (BM01) | | | | |
| 139 | `{DauPhongTongKet}` | Tổng kết đậu phộng (BM01) | | | | |
| 140 | `{DauPhongTra}` | Số đậu phộng trả về kho (BM01) | | | | |
| 141 | `{@TenThucAnMangVao}` | Danh sách tên thức ăn mang vào, dạng nhiều dòng (BM02) | | | | |
| 142 | `{@TenThucUongMangVao}` | Danh sách tên thức uống mang vào, dạng nhiều dòng (BM02) | | | | |
| 143 | `{@XuatXuMangVao}` | Danh sách xuất xứ thức ăn/uống mang vào, dạng nhiều dòng (BM02) | | | | |

---

## II. Danh Sách Phân Loại Theo Nhóm Chức Năng

Để thuận tiện cho việc thiết kế Database/Schema API, các trường có thể được gom nhóm như sau:

### 1. Thông Tin Hợp Đồng & Liên Quan (Contract Metadata)
* `{Sohopdong}`: Số ký hiệu hợp đồng
* `{NgayLapHD}`, `{ThangLapHD}`, `{NamLapHD}`: Thời gian ký kết
* `{NgayToChuc}`: Ngày diễn ra sự kiện chính
* `{LoaiHinhSuKien}`: Loại hình sự kiện / Hình thức tiệc

### 2. Đại Diện Bên A (Công Ty Địa Điểm/Tổ Chức)
* `{BenATenCongTy}`: Tên pháp nhân Bên A
* `{BenADiaChi}`: Trụ sở chính Bên A
* `{BenASDT}`: Số hotline Bên A
* `{BenAMST}`: Mã số thuế Bên A
* `{BenANhanVienPhuTrach}`: Tên nhân viên phụ trách tư vấn/hợp đồng
* `{BenAChucVu}`: Chức vụ của nhân viên phụ trách
* `{BenASDTNhanVien}`: Điện thoại di động của nhân viên
* `{BenAEmail}`: Email công việc của nhân viên

### 3. Khách Hàng Bên B (Đối Tác / Người Đặt Tiệc)
* `{BenBTenChuTiec}`: Tên chủ tiệc (tên cô dâu/chú rể hoặc đơn vị thuê sảnh)
* `{BenBTenDaiDien}`: Tên cá nhân ký tên đại diện trên hợp đồng
* `{BenBChucVu}`: Chức vụ của người đại diện (nếu là doanh nghiệp)
* `{BenBDiaChi}`: Địa chỉ thường trú hoặc trụ sở Bên B
* `{BenBDienThoai}`: Số điện thoại liên lạc chính
* `{BenBCCCD}`: Số căn cước công dân
* `{Email}`: Địa chỉ email liên hệ

### 4. Thiết Lập Sảnh Tiệc & Thiết Bị (Venue Setup & Specifications)
* `{TenSanhTiec}`: Sảnh chính sử dụng
* `{TenSanhTiecPhu}`: Sảnh phụ / sảnh mở rộng
* `{KichThuocSanhPhu}`: Kích thước chiều dài x rộng sảnh
* `{TenSanKhau}` / `{TenSanKhauPhu}`: Tên khu vực sân khấu
* `{KichThuocSanKhau}` / `{KichThuocSanKhauPhu}`: Kích thước khu vực sân khấu
* `{SucChuaToiDa}` / `{SucChuaToiDaPhu}`: Giới hạn sức chứa tối đa
* `{KhachToiThieu}` / `{SucChuaToiThieuPhu}`: Số lượng khách tối thiểu cam kết
* `{TiecGioBatDau}` / `{TiecGioKetThuc}`: Khung giờ sự kiện diễn ra
* `{SetupBatDau}` / `{SetupKetThuc}`: Khung giờ bàn giao sảnh để setup
* `{SoKhachDiemDanh}`: Số lượng khách check-in thực tế
* Các trường thực tế sau sự kiện / hội nghị (BBGN):
  * `{GioBatDauThucTe}` / `{GioKetThucThucTe}`: Giờ bắt đầu và giờ kết thúc thực tế
  * `{SoKhachThucTe}`: Số lượng khách thực tế tham dự
  * `{SoKhachPhatSinh}`: Số lượng khách phát sinh ngoài

### 5. Dịch Vụ Ẩm Thực (Catering Details)
* `{SoBanManChinhThuc}`: Bàn tiệc mặn chính thức (Hợp đồng)
* `{SoBanManDuPhong}`: Bàn tiệc mặn dự phòng để phát sinh (Hợp đồng)
* `{MenuTongCong}`: Tổng giá trị gói thực đơn
* Vòng lặp thực đơn hợp đồng:
  * `{#MenuTiec}` ... `{/MenuTiec}`
  * `{TenMonAn}`: Tên các món trong set menu
* Các trường liên quan đến bàn tiệc (GMPS):
  * `{BanChinhThuc}`: Số lượng bàn chính thức thực tế
  * `{BanTang}`: Số lượng bàn tặng
  * `{BanChay}`: Số lượng bàn chay
  * `{BanDuPhong}`: Số lượng bàn dự phòng
  * `{BanPhatSinh}`: Số lượng bàn phát sinh
  * `{TongSoBan}`: Tổng số bàn thực tế (Chính thức + Tặng + Chay + Dự phòng + Phát sinh)
* Vòng lặp món ăn phát sinh (GMPS):
  * `{#MenuPhatSinh}` ... `{/MenuPhatSinh}`
  * `{STT}`: Số thứ tự món phát sinh
  * `{MonMan}`: Tên món mặn phát sinh
  * `{MonChay}`: Tên món chay phát sinh
  * `{MonPhatSinh}`: Tên món phát sinh khác
* Các trường liên quan đến lưu mẫu thức ăn (BBLM):
  * `{@ThucDonManLuuMau}`: Chi tiết thực đơn mặn lưu mẫu (dạng nhiều dòng, cần đưa vào convertFields)
  * `{@ThucDonChayLuuMau}`: Chi tiết thực đơn chay lưu mẫu (dạng nhiều dòng, cần đưa vào convertFields)
  * `{GioLayMau}` / `{NgayLayMau}`: Giờ và ngày lấy mẫu thức ăn lưu
  * `{GioHuyMau}` / `{NgayHuyMau}`: Giờ và ngày hủy mẫu thức ăn lưu

### 6. Lịch Trình Chi Tiết Dịch Vụ Theo Ngày (Agenda & Rental Timeline)
* Vòng lặp ngày: `{#DanhSachNgay}` ... `{/DanhSachNgay}`
  * `{TenNhomNgay}`: Phân nhóm ngày (Ví dụ: Ngày setup, ngày sự kiện chính)
  * Vòng lặp dịch vụ chi tiết: `{#DanhSachDV}` ... `{/DanhSachDV}`
    * `{KhungGio}`: Thời gian áp dụng
    * `{TenDichVu}`: Tên dịch vụ/mục thuê
    * `{DVT}`: Đơn vị tính (Lượt, giờ, ngày, bộ,...)
    * `{SoLuong}`: Số lượng đặt mua/thuê
    * `{DonGia}`: Đơn giá chưa thuế
    * `{UuDai}`: Giảm giá/khuyến mại áp dụng
    * `{ThanhTien}`: Thành tiền sau ưu đãi của mục dịch vụ đó

### 7. Dịch Vụ Tính Phí Ngoài (Additional Charge Services)
* Vòng lặp dịch vụ ngoài: `{#DichVuTinhPhi}` ... `{/DichVuTinhPhi}`
  * `{STT}`: Số thứ tự dịch vụ phát sinh
  * `{TenDichVu}`: Tên dịch vụ
  * `{DonGia}`: Đơn giá
  * `{ThanhTien}`: Thành tiền
  * `{GhiChuChiTiet}`: Ghi chú đính kèm
* Các trường dịch vụ phát sinh khác (BBGN):
  * `{@PhatSinhTrongHoiNghi}`: Chi tiết dịch vụ phát sinh trong hội nghị (dạng nhiều dòng, cần đưa vào convertFields)
  * `{@CacDichVuKhac}`: Chi tiết các dịch vụ khác (dạng nhiều dòng, cần đưa vào convertFields)

### 8. Tổng Hợp Tài Chính & Thuế (Financial Summaries)
* `{TongThanhTien}`: Tổng tiền trước thuế & phí phục vụ
* `{MucPhiPhucVu}`: % Phí phục vụ (ví dụ: 5%, 10%)
* `{PhiPhucVu}`: Tiền phí phục vụ
* `{TongCongChuaVAT}`: Tổng cộng (Đã bao gồm phí phục vụ nhưng chưa VAT)
* `{VAT8}` / `{VAT10}`: Số tiền thuế VAT 8% hoặc 10%
* `{TongGiaTriTamTinh}`: Tổng giá trị thanh toán cuối cùng
* `{TongGiaTriTamTinhBangChu}`: Số tiền viết bằng chữ tiếng Việt
* `{Dot1SoTien}` / `{Dot1BangChu}`: Chi phí đặt cọc đợt 1 cần thu trước
* `{TongGiaTriQuyetToan}` / `{TongGiaTriQuyetToanBangChu}`: Tổng giá trị quyết toán thực tế & Bằng chữ (BBNT)
* `{SoTienDaDatCoc}` / `{NgayThanhToanDatCoc}`: Số tiền Bên B đã đặt cọc giữ chỗ & Ngày thanh toán (BBNT)
* `{SoTienConLai}` / `{SoTienConLaiBangChu}`: Số tiền Bên B còn phải thanh toán & Bằng chữ (BBNT)

### 9. Yêu Cầu Xuất Hóa Đơn VAT (Billing Info)
* `{HDTenCty}`: Tên doanh nghiệp/tổ chức xuất hóa đơn
* `{HDDiaChi}`: Địa chỉ đăng ký kinh doanh
* `{HDMaSoThue}`: Mã số thuế
* `{HDEmail}`: Email nhận hóa đơn điện tử

### 10. Tổng Kết Sau Tiệc – Kiểm Kê Đồ Dùng (Post-Party Reconciliation - BM01)
* Vòng lặp thực đơn giao nhận: `{#MenuGiaoNhan}` ... `{/MenuGiaoNhan}`
  * `{STT}`: Số thứ tự
  * `{MonMan}`: Tên món mặn
  * `{MonChay}`: Tên món chay
  * `{MonPhatSinh}`: Tên món phát sinh
* Vòng lặp kiểm kê đồ uống: `{#DoUongKiemKe}` ... `{/DoUongKiemKe}`
  * `{STT}`: Số thứ tự
  * `{TenNuoc}`: Tên loại nước/đồ uống
  * `{SLTruocTiec}`: Số lượng trước tiệc
  * `{GhiChu}`: Ghi chú
* Vòng lặp phát sinh trong tiệc: `{#PhatSinhTrongTiec}` ... `{/PhatSinhTrongTiec}`
  * `{STT}`: Số thứ tự
  * `{TenPhatSinh}`: Tên mục phát sinh
  * `{SoLuong}`: Số lượng phát sinh
  * `{XacNhan}`: Xác nhận của khách hàng
* Bảng tổng kết các mục sử dụng sau tiệc (cột Dung = đã dùng, TongKet = tổng theo BEO, Tra = trả kho):
  * **Bàn:** `{BanChinhThucDung}`, `{BanChayDung}`, `{BanTangDung}`, `{BanDuPhongDung}`, `{BanPhatSinhDung}`, `{TongSoBanDung}`
  * **Bia:** `{BiaDung}`, `{BiaTongKet}`, `{BiaTra}`
  * **Nước ngọt:** `{NuocNgotDung}`, `{NuocNgotTongKet}`, `{NuocNgotTra}`
  * **Nước suối:** `{NuocSuoiDung}`, `{NuocSuoiTongKet}`, `{NuocSuoiTra}`
  * **Phát sinh khác:** `{KhacDung}`, `{KhacTongKet}`, `{KhacTra}`
  * **Khăn lạnh:** `{KhanLanhDung}`, `{KhanLanhTongKet}`, `{KhanLanhTra}`
  * **Đậu phộng:** `{DauPhongDung}`, `{DauPhongTongKet}`, `{DauPhongTra}`

### 11. Biên Bản Khách Mang Thức Ăn Vào (BM02)

Tái sử dụng trường header đã có:
* `{NgayToChuc}`, `{TiecGioBatDau}`, `{LoaiHinhSuKien}`, `{TongSoBan}`
* `{TenSanhTiec}`
* `{BenBTenChuTiec}`, `{BenBDienThoai}`, `{BenBDiaChi}`

Bảng **CHỦNG LOẠI THỨC ĂN MANG VÀO** (3 cột, dùng `convertFields`):
* `{@TenThucAnMangVao}`: Cột **TÊN THỨC ĂN** (ví dụ: `1. Bánh kem\n2. Trái cây`)
* `{@TenThucUongMangVao}`: Cột **TÊN THỨC UỐNG** (ví dụ: `1. Rượu vang\n2. Nước suối`)
* `{@XuatXuMangVao}`: Cột **XUẤT XỨ** (ví dụ: `1. Tiệm bánh ABC\n2. Siêu thị XYZ`)
