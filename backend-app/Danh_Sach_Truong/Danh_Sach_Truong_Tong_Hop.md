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
| 56 | `{SoBanChinhThuc}` | Số lượng bàn chính thức | x | | x | |
| 57 | `{SoBanDuPhong}` | Số lượng bàn dự phòng | x | | x | |
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
| 78 | `{TongTienDichVu}` | Tổng tiền dịch vụ tạm tính (trước phí) | x | x | x | x |
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
| 92 | `{BenBEmail}` | Email liên hệ chung của Bên B | x | x | x | x |
| 76 | `{TongGiaTriQuyetToan}` | Tổng giá trị quyết toán (BBNT) | | | | |
| 77 | `{TongGiaTriQuyetToanBangChu}` | Tổng giá trị quyết toán bằng chữ (BBNT) | | | | |
| 78 | `{SoTienDaDatCoc}` | Số tiền Bên B đã đặt cọc giữ chỗ (BBNT) | | | | |
| 79 | `{NgayThanhToanDatCoc}` | Ngày thanh toán tiền đặt cọc (BBNT) | | | | |
| 80 | `{SoTienConLai}` | Số tiền Bên B còn phải thanh toán (BBNT) | | | | |
| 81 | `{SoTienConLaiBangChu}` | Số tiền còn lại bằng chữ (BBNT) | | | | |
| 82 | `{LoaiHinhSuKien}` | Loại hình sự kiện / Hình thức tiệc (GMPS, BM02) | | | | |
| 100 | `{SoBanChinhThuc}` | Số bàn chính thức (GMPS) | | | | |
| 101 | `{BanTang}` | Số bàn tặng (GMPS) | | | | |
| 102 | `{BanChay}` | Số bàn chay (GMPS) | | | | |
| 103 | `{SoBanDuPhong}` | Số bàn dự phòng (GMPS) | | | | |
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
| 144 | `{SoPhuLuc}` | Số hiệu phụ lục hợp đồng (PL) | | | | |
| 145 | `{NgayLapPL}` | Ngày lập phụ lục (PL) | | | | |
| 146 | `{ThangLapPL}` | Tháng lập phụ lục (PL) | | | | |
| 147 | `{NamLapPL}` | Năm lập phụ lục (PL) | | | | |
| 148 | `{NgayToChucAmLich}` | Ngày tổ chức tính theo Âm Lịch (PL) | | | | |
| 149 | `{ThangToChucAmLich}` | Tháng tổ chức Âm Lịch (PL) | | | | |
| 150 | `{NamToChucAmLich}` | Năm tổ chức Âm Lịch (PL) | | | | |
| 151 | `{ThangToChuc}` | Tháng tổ chức Dương Lịch (PL) | | | | |
| 152 | `{NamToChuc}` | Năm tổ chức Dương Lịch (PL) | | | | |
| 153 | `{QuyMoBanTu}` | Quy mô sảnh từ X bàn (PL) | | | | |
| 154 | `{QuyMoBanDen}` | Quy mô sảnh đến Y bàn (PL) | | | | |
| 155 | `{TenDotThanhToan}` | Tên đợt thanh toán (Ví dụ: Đợt 2, Đợt 3) (PL) | | | | |
| 156 | `{ThanhToanDot2SoTien}` | Số tiền cần thanh toán cho đợt tiếp theo (PL) | | | | |
| 157 | `{HinhThucThanhToanDot2}` | Hình thức thanh toán đợt tiếp theo (PL) | | | | |
| 158 | `{HanThanhToanDot2}` | Thời hạn thanh toán (PL) | | | | |
| 159 | `{@DichVuTinhPhiPhuLuc}` | Dịch vụ tính phí phát sinh, nhiều dòng (PL) | | | | |
| 160 | `{@ThoaThuanPhuLucKhac}` | Dịch vụ ưu đãi và thoả thuận khác, nhiều dòng (PL) | | | | |
| 161 | `{BenAChucVuDaiDien}` | Chức vụ người đại diện ký hợp đồng Bên A (PL) | | | | |
| 162 | `{DonGiaBanTiec}` | Đơn giá hiển thị trên tiêu đề bảng thực đơn (PL) | | | | |
| 163 | `{SoKhachTrenBan}` | Số lượng khách trên mỗi bàn (PL) | | | | |
| 163b | `{NoiDungPhuLuc}` | Nội dung thỏa thuận (PL) | | | | |
| 164 | `{#DanhSachChiPhi}` | Bắt đầu vòng lặp bảng tổng chi phí thay thế Excel (PL) | | | | |
| 165 | `{NoiDung}` | Nội dung chi phí trong bảng (PL) | | | | |
| 166 | `{/DanhSachChiPhi}` | Kết thúc vòng lặp bảng tổng chi phí (PL) | | | | |
| 167 | `{NgayQuyetToan}` | Ngày lập biên bản quyết toán (QT) | | | | |
| 168 | `{ThangQuyetToan}` | Tháng lập biên bản quyết toán (QT) | | | | |
| 169 | `{NamQuyetToan}` | Năm lập biên bản quyết toán (QT) | | | | |
| 170 | `{#ChiTietQuyetToan}` | Bắt đầu vòng lặp bảng chi tiết quyết toán (QT) | | | | |
| 171 | `{/ChiTietQuyetToan}` | Kết thúc vòng lặp bảng chi tiết quyết toán (QT) | | | | |
| 172 | `{Cong1}` | Tổng cộng nhóm chi phí 1 (Ví dụ: Tiền tiệc) (QT) | | | | |
| 173 | `{Cong2}` | Tổng cộng nhóm chi phí 2 (Ví dụ: Thức uống/Dịch vụ) (QT) | | | | |
| 174 | `{TongCong12}` | Tổng cộng cả 2 nhóm trước phí phục vụ (QT) | | | | |
| 175 | `{NgayLapPT}` | Ngày lập phiếu thu (PT) | | | | |
| 176 | `{ThangLapPT}` | Tháng lập phiếu thu (PT) | | | | |
| 177 | `{NamLapPT}` | Năm lập phiếu thu (PT) | | | | |
| 178 | `{SoPhieu}` | Số phiếu thu (PT) | | | | |
| 179 | `{TaiKhoanNo}` | Tài khoản kế toán nợ (PT) | | | | |
| 180 | `{TaiKhoanCo}` | Tài khoản kế toán có (PT) | | | | |
| 181 | `{Lydo}` | Lý do thu tiền (PT) | | | | |
| 182 | `{SoTienThu}` | Số tiền thực thu (PT) | | | | |
| 183 | `{SoTienThuBangChu}` | Số tiền thực thu bằng chữ (PT) | | | | |
| 184 | `{HinhThuc}` | Hình thức thanh toán (Tiền mặt/Chuyển khoản) (PT) | | | | |
| 185 | `{Kemtheo}` | Chứng từ gốc kèm theo (PT) | | | | |

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
* `{BenADaiDien}`: Đại diện của Bên A (Người ký hợp đồng)

### 3. Khách Hàng Bên B (Đối Tác / Người Đặt Tiệc)
* `{BenBTenDaiDien}`: Tên cá nhân ký tên đại diện trên hợp đồng
* `{BenBChucVu}`: Chức vụ của người đại diện (nếu là doanh nghiệp)
* `{BenBDiaChi}`: Địa chỉ thường trú hoặc trụ sở Bên B
* `{BenBDienThoai}`: Số điện thoại liên lạc chính
* `{BenBCCCD}`: Số căn cước công dân
* `{BenBEmail}`: Địa chỉ email liên hệ

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

---

### 12. Các Trường Dành Riêng Cho Phụ Lục (PL) / Phiếu Đề Nghị Thay Đổi
* `{SoPhuLuc}`: Số hiệu của phụ lục hợp đồng
* `{NgayLapPL}`, `{ThangLapPL}`, `{NamLapPL}`: Ngày/tháng/năm lập phụ lục
* `{NgayToChucAmLich}`, `{ThangToChucAmLich}`, `{NamToChucAmLich}`: Thời gian tổ chức tính theo Âm Lịch
* `{ThangToChuc}`, `{NamToChuc}`: Tháng và năm tổ chức Dương Lịch (tách riêng)
* `{QuyMoBanTu}`, `{QuyMoBanDen}`: Quy mô sảnh (Số lượng bàn từ ... đến ...)
* `{TenDotThanhToan}`: Tên đợt thanh toán (Ví dụ: đợt 2, đợt 3...)
* `{ThanhToanDot2SoTien}`: Số tiền cần thanh toán cho đợt tiếp theo trong phụ lục
* `{HinhThucThanhToanDot2}`: Hình thức thanh toán (Tiền mặt/Chuyển khoản)
* `{HanThanhToanDot2}`: Hạn thanh toán đợt này
* `{@DichVuTinhPhiPhuLuc}`: Khối dữ liệu dạng nhiều dòng (multiline) ghi chú các dịch vụ tính phí riêng lẻ
* `{@ThoaThuanPhuLucKhac}`: Khối dữ liệu dạng nhiều dòng (multiline) lưu tất cả các thỏa thuận/dịch vụ tặng kèm/khuyến mãi khác
* `{BenAChucVuDaiDien}`: Chức vụ của đại diện bên A (bổ sung đi kèm `{BenADaiDien}`)
* `{DonGiaBanTiec}`, `{SoKhachTrenBan}`: Các trường phục vụ ghi chú lên header của bảng thực đơn/báo giá
* `{NoiDungPhuLuc}`: Nội dung thỏa thuận / ghi chú chung của phụ lục
* `{#DanhSachChiPhi}` ... `{/DanhSachChiPhi}`: Vòng lặp bảng tổng hợp tất cả các chi phí (dùng khi khách chèn Excel table vào Word)
  * `{NoiDung}`, `{DVT}`: Các cột nội dung và đơn vị tính của bảng tổng hợp chi phí

---

### 13. Biên Bản Quyết Toán (QT)
*(Lưu ý: Đa số các trường dùng lại của Hợp đồng như `{Sohopdong}`)*
* `{NgayQuyetToan}`, `{ThangQuyetToan}`, `{NamQuyetToan}`: Ngày tháng năm ký biên bản quyết toán
* Thông tin chung Quyết toán: `{KhachHang}`, `{LoaiHinhSK}`, `{NVKD}`, `{SoLuongKhach}`, `{SanhTiec}`, `{NgayToChuc}`, `{ThoiGian}`
* `{#DanhSachDichVu}` ... `{/DanhSachDichVu}`: Vòng lặp bảng chi tiết các dịch vụ chính (Tiệc, Nước, Dịch vụ cưới...)
* `{#DichVuPhatSinh}` ... `{/DichVuPhatSinh}`: Vòng lặp bảng chi tiết các dịch vụ phát sinh (Bù sảnh, bù bàn tăng...)
  * Các trường bên trong vòng lặp: `{STT}`, `{DienGiai}`, `{DVT}`, `{SoLuong}`, `{DonGia}`, `{ThanhTien}`
* Bảng Tổng kết & Thanh toán:
  * `{Cong1}`: Tổng cộng nhóm chi phí 1 (Dịch vụ chính)
  * `{Cong2}`: Tổng cộng nhóm chi phí 2 (Phát sinh)
  * `{TongCong12}`: Tổng cộng của (`{Cong1}` + `{Cong2}`)
  * `{PhiPhucVu}`: Tiền phí phục vụ (5%)
  * `{TongCongChuaVAT}`: Tổng cộng trước thuế
  * `{VAT8}`, `{VAT10}`: Thuế VAT 8% và 10%
  * `{TongTien}`: Tổng tiền cuối cùng (Đã gồm VAT)
  * `{TruCoc}`: Số tiền đã cọc
  * `{ThanhToanConLai}`: Số tiền cần thanh toán còn lại

---

### 14. Phiếu Thu (PT)
*(Lưu ý: Các trường dùng chung với hợp đồng gốc gồm `{BenATenCongTy}`, `{BenADiaChi}`, `{BenBTenDaiDien}`, `{BenBDiaChi}`, `{Sohopdong}`)*
* `{NgayLapPT}`, `{ThangLapPT}`, `{NamLapPT}`: Ngày/tháng/năm lập phiếu thu (tách biệt với ngày lập hợp đồng)
* `{SoPhieu}`: Số hiệu của phiếu thu (VD: PT-001)
* `{TaiKhoanNo}`, `{TaiKhoanCo}`: Số tài khoản kế toán ghi nợ/có
* `{Lydo}`: Lý do nộp tiền (Ví dụ: Đặt cọc lần 1)
* `{SoTienThu}`: Số tiền khách nộp thực tế trong đợt này
* `{SoTienThuBangChu}`: Số tiền viết bằng chữ
* `{HinhThuc}`: Hình thức nộp tiền (Tiền mặt / Chuyển khoản)
* `{Kemtheo}`: Số lượng/thông tin chứng từ gốc đính kèm

---

### 15. Các Trường Bổ Sung Dành Riêng Cho BEO Hội Nghị
*(Lưu ý: Các trường cơ bản dùng chung với hợp đồng gốc như {HDTenCty}, {BenANhanVienPhuTrach}, {BenASDTNhanVien}, {BenBDiaChi}, {BenBDienThoai}, {BenBDaiDien}, {Sohopdong}, {NgayToChuc}, {GioBatDau}, {GioKetThuc})*
* {NgayRaBEO}: Ngày xuất BEO Hội Nghị
* {TieuDePhieu}: Tiêu đề phiếu BEO
* {SoKhachChinhThuc}: Số lượng khách hội nghị chính thức
* {KieuSetup}: Kiểu setup bàn ghế hội nghị
* {#ChiTietLichTrinh} ... {/ChiTietLichTrinh}: Vòng lặp bảng chi tiết lịch trình hội nghị
* {#LichTrinhThanhToan} ... {/LichTrinhThanhToan}: Vòng lặp bảng lịch trình thanh toán
* {@ThongTinSetup}: Block thông tin setup chi tiết
* {@NoteBaoVe}: Ghi chú cho bộ phận Bảo Vệ
* {@NoteBieuNgu}: Ghi chú biểu ngữ / backdrop
* {@NoteKyThuat}: Ghi chú cho bộ phận Kỹ Thuật
* {@NoteLobby}: Ghi chú khu vực Lobby

---

### 16. Báo Giá Dịch Vụ
*(Lưu ý: Các trường cơ bản dùng chung với hợp đồng gốc như {HDTenCty}, {BenBDienThoai}, {BenADiaChi}, {BenATenCongTy}, {BenANhanVienPhuTrach}, {BenASDTNhanVien}, {BenAEmailNhanVien})*
* {NgayBaoGia}: Ngày lập báo giá
* {#DanhSachDichVu} ... {/DanhSachDichVu}: Vòng lặp danh sách các dịch vụ trong báo giá
* {#DanhSachKhuVuc} ... {/DanhSachKhuVuc}: Vòng lặp danh sách khu vực sảnh tiệc
* {#DanhSachThamKhao} ... {/DanhSachThamKhao}: Vòng lặp danh sách menu/dịch vụ tham khảo
* {@GhiChuSanh1}, {@GhiChuSanh2}, {@GhiChuSanh3}: Các khối ghi chú tương ứng cho từng sảnh
* {@LuuYChung}: Ghi chú lưu ý chung của báo giá
* {TongCongTamTinh}: Tổng tiền các hạng mục
* {TongTienMuc}: Tổng tiền cho từng mục con