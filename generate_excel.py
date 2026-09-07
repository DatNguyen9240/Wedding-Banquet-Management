import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

wb = openpyxl.Workbook()

# Define styles
font_title = Font(name="Calibri", size=16, bold=True, color="1E3A8A")
font_subtitle = Font(name="Calibri", size=11, italic=True, color="475569")
font_header = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
font_row = Font(name="Calibri", size=10)
font_bold = Font(name="Calibri", size=10, bold=True)

fill_header_main = PatternFill(start_color="1E3A8A", end_color="1E3A8A", fill_type="solid") # Deep Navy
fill_header_sub = PatternFill(start_color="2563EB", end_color="2563EB", fill_type="solid") # Royal Blue
fill_zebra = PatternFill(start_color="F8FAFC", end_color="F8FAFC", fill_type="solid") # Slate 50
fill_resolved = PatternFill(start_color="DCFCE7", end_color="DCFCE7", fill_type="solid") # Light Green
fill_waiting = PatternFill(start_color="FEF3C7", end_color="FEF3C7", fill_type="solid") # Light Amber

font_resolved = Font(name="Calibri", size=10, bold=True, color="166534") # Dark Green
font_waiting = Font(name="Calibri", size=10, bold=True, color="92400E") # Dark Amber

thin_border_side = Side(border_style="thin", color="CBD5E1")
border_cell = Border(left=thin_border_side, right=thin_border_side, top=thin_border_side, bottom=thin_border_side)

align_center = Alignment(horizontal="center", vertical="center", wrap_text=True)
align_left = Alignment(horizontal="left", vertical="center", wrap_text=True)
align_right = Alignment(horizontal="right", vertical="center")

# ==========================================
# SHEET 1: TỔNG HỢP 40 YÊU CẦU (REQ-01 -> REQ-40)
# ==========================================
ws1 = wb.active
ws1.title = "Theo Dõi 40 Yêu Cầu BA"
ws1.views.sheetView[0].showGridLines = True

# Title
ws1.merge_cells("A1:G1")
ws1["A1"] = "BẢNG THEO DÕI & TỔNG HỢP CẢI TIẾN HỆ THỐNG QUẢN LÝ TIỆC (REQ-01 → REQ-40)"
ws1["A1"].font = font_title
ws1["A1"].alignment = Alignment(horizontal="left", vertical="center")
ws1.row_dimensions[1].height = 30

ws1.merge_cells("A2:G2")
ws1["A2"] = "Tài liệu đối soát tính năng theo phản hồi của khách hàng (BA Changelog). Cập nhật: 09/2026."
ws1["A2"].font = font_subtitle
ws1["A2"].alignment = Alignment(horizontal="left", vertical="center")
ws1.row_dimensions[2].height = 20

headers_ws1 = [
    "Mã REQ", 
    "Nhóm Nghiệp Vụ", 
    "Mô Tả Yêu Cầu Khách Hàng", 
    "Trạng Thái", 
    "Giải Pháp Đã Xử Lý / Implementation Details", 
    "Tệp Liên Quan (SQL / Code / Word)", 
    "Ghi Chú Nghiệp Vụ"
]

ws1.append([]) # Row 3 blank
ws1.append(headers_ws1) # Row 4
ws1.row_dimensions[4].height = 28

for col_num in range(1, len(headers_ws1) + 1):
    c = ws1.cell(row=4, column=col_num)
    c.font = font_header
    c.fill = fill_header_main
    c.alignment = align_center
    c.border = border_cell

data_reqs = [
    (
        "REQ-01", "DOCX & Báo Cáo", 
        "Xuất file DOCX cho Hợp đồng, Phiếu thu, BEO không bị lỗi", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Sửa lỗi phân mảnh thẻ XML trong Docxtemplater, tự động tiêm STT và xử lý loop rỗng. Test tự động 24/24 file Word đạt 100% không lỗi.",
        "backend-app/server.js, test_render_all.js, DocumentExportPlugin.js",
        "Khách phản ánh xuất docx bị lỗi, hiện đã pass 24/24 template."
    ),
    (
        "REQ-02", "Quyết Toán", 
        "2 mẫu Quyết toán: QT01 (Cá nhân / Cưới) và QT02 (Pháp nhân / Công ty)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Tự động định tuyến mẫu quyết toán tại server.js và QuyetToanPlugin.js dựa trên loại tiệc & đối tượng khách hàng.",
        "quyet_toan_01.docx, quyet_toan_02.docx, server.js, QuyetToanPlugin.js",
        "Phù hợp với file mẫu 'MAU QUYET TOAN TIEC.xlsx' khách gửi."
    ),
    (
        "REQ-03", "Thực Đơn (Menu)", 
        "Menu hỗ trợ 2 hình thức: Theo Set menu và Tự chọn món", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Cho phép gắn GoiThucDonID (Set menu) hoặc chọn món lẻ tự do trong FoodSelectionPlugin. Phân tách rõ món mặn và món chay.",
        "FoodSelectionPlugin.js, MenusService.js, Update_ContractDropdowns.sql",
        "Đã đáp ứng 2 hình thức chọn menu theo phản hồi chat."
    ),
    (
        "REQ-04", "Thực Đơn (Menu)", 
        "Set menu cho phép đổi món và bù giá phát sinh chênh lệch", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Xây dựng DoiMonPlugin.js cho phép chọn món gốc, món thay thế, tự động tính tiền chênh lệch = (Giá mới - Giá cũ) * Số bàn.",
        "DoiMonPlugin.js, Update_dmMauTrangTri_DoiMon.sql, Update_QuyetToan_AllInOne.sql",
        "Tự động cộng tiền bù đổi món vào tổng chi phí quyết toán."
    ),
    (
        "REQ-05", "Phát Sinh", 
        "Ghi nhận phát sinh thực tế trong tiệc (nước uống, dịch vụ, bàn thêm...)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Bảng tbmk_HopdongPhatSinh, API_LuuPhatSinhNhanh, module PhatSinhPlugin.js. Tự động đưa phát sinh vào quyết toán.",
        "tbmk_HopdongPhatSinh.sql, PhatSinhPlugin.js, Update_QuyetToan_AllInOne.sql",
        "Ghi nhận chính xác chi phí thực tế phát sinh tại ngày tiệc."
    ),
    (
        "REQ-06", "Quyết Toán", 
        "Quyết toán lấy từ BEO sau lần thay đổi cuối cùng + Chi phí phát sinh", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Update_QuyetToan_AllInOne tự động chọn TOP 1 tbmk_Thaydoi (BEO bản mới nhất) + cộng phát sinh + đổi món bù giá - tiền cọc.",
        "Update_QuyetToan_AllInOne.sql, CheckoutService.js, v_DanhSachQuyetToan.sql",
        "Đúng theo nguyên tắc quyết toán lấy từ BEO chốt cuối cùng."
    ),
    (
        "REQ-07", "Trang Trí", 
        "Mẫu trang trí không mặc định, có thư viện ảnh để tick chọn cho từng HĐ", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Tạo bảng dmMauTrangTri và xây dựng MauTrangTriPlugin.js hiển thị gallery ảnh xem trước trực quan để nhân viên tick chọn.",
        "dmMauTrangTri, MauTrangTriPlugin.js, Update_dmMauTrangTri_DoiMon.sql",
        "Đáp ứng đúng ảnh chụp màn hình khách yêu cầu thư mục ảnh trang trí."
    ),
    (
        "REQ-08", "Triển Lãm & Tiệc", 
        "Triển lãm và tiệc dùng địa điểm riêng (1 sảnh triển lãm, 1 sảnh tiệc)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Thêm LoaiDiaDiem ('TRIEN_LAM', 'TIEC', 'HOI_NGHI') vào tbmk_Hopdongsanhtiec. Expose riêng {DiaDiemTrienLam}, {DiaDiemTiec}.",
        "tbmk_Hopdongsanhtiec, v_DanhSachHopDong.sql, API_LuuHopDong.sql",
        "Không còn bị gán cứng tên sảnh Diamond / Ruby."
    ),
    (
        "REQ-09", "Triển Lãm & Tiệc", 
        "Phần tiệc chọn được tiệc trưa hoặc tiệc tối (ca tiệc linh hoạt)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Cho phép gán Thoigianid riêng theo từng sảnh trong tbmk_Hopdongsanhtiec. Expose biến {CaTiec} vào mẫu in Word.",
        "dmThoigian, tbmk_Hopdongsanhtiec, v_DanhSachHopDong.sql",
        "Hỗ trợ cả tiệc trưa và tiệc tối tùy theo nhu cầu khách."
    ),
    (
        "REQ-10", "Hợp Đồng", 
        "Số hợp đồng không mặc định sai / để mở cho phép nhập tay", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Trường Sohopdong để mở trên form theo số thực tế của nhà hàng. Xóa toàn bộ số HĐ hard-code trong template Word.",
        "API_LuuHopDong.sql, v_DanhSachHopDong.sql, các template DOCX",
        "Đáp ứng yêu cầu: 'số hợp đồng không mặc định sẵn nha'."
    ),
    (
        "REQ-11", "Thuê Sảnh Ngoài Giờ", 
        "Thuê sảnh phát sinh ngoài giờ lấy từ Danh mục Sảnh (dmSanhtiec)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Xóa giá cứng 17.500.000 VNĐ trong template. Expose placeholder {DonGiaNgoaiGio} tự động lấy từ danh mục sảnh.",
        "dmSanhtiec, v_DanhSachHopDong.sql, 2.1 & 2.2 MAU HDONG.docx",
        "Liên kết trực tiếp với đơn giá sảnh."
    ),
    (
        "REQ-12", "Thuê Sảnh Ngoài Giờ", 
        "Giá thuê sảnh phát sinh ngoài giờ tính theo công thức: (Giá 1 buổi 4 tiếng) / 4", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Chốt theo đúng công thức khách nhắn: DonGiaNgoaiGio = dmSanhtiec.Dongia / 4. Tự động chia 4 đưa vào văn bản HĐ.",
        "v_DanhSachHopDong.sql, CHANGELOG_BA.md",
        "Khách đã xác nhận công thức: 'phí thuê sảnh theo buổi (4 tiếng)/4'."
    ),
    (
        "REQ-13", "Hợp Đồng Triển Lãm", 
        "Mẫu HĐ Triển Lãm riêng (bỏ cụm 'và tiệc', đúng wording cho thuê mặt bằng)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Chỉnh sửa file '2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx': sửa tiêu đề và căn cứ thành 'Hợp đồng tổ chức triển lãm', bỏ chữ 'và tiệc'.",
        "2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx, Update_LoaitiecAddfile_MapTemplates.sql",
        "Đúng theo ảnh chụp màn hình yêu cầu câu chữ của khách."
    ),
    (
        "REQ-14", "Hợp Đồng Triển Lãm", 
        "Thông tin sự kiện HĐ Triển Lãm: số khách tham quan dự kiến, thời gian triển lãm...", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Bổ sung các cột SoKhachThamQuanDuKien, GioBatDauTrienLam, GioKetThucTrienLam, ThoiGianTrienLam vào HĐ và view DOCX.",
        "tbmk_Hopdong, API_LuuHopDong.sql, v_DanhSachHopDong.sql",
        "Xóa bỏ số 600 khách cố định, nhận giá trị thực tế theo từng HĐ."
    ),
    (
        "REQ-15", "Hợp Đồng Pháp Nhân", 
        "Không lặp kích thước sân khấu 2 lần trong file Word", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Sửa template 2.2: xóa bỏ đoạn lặp text 'Kích thước sân khấu 9.6m x 3.6m x 0.8m: 9.6m x 3.6m x 0.8m', lấy 1 lần {KTSanKhau}.",
        "2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx, dmSanhtiec.KTSanKhau",
        "Khắc phục triệt để lỗi lặp kích thước sân khấu trong ảnh."
    ),
    (
        "REQ-16", "Hợp Đồng Pháp Nhân", 
        "Khách pháp nhân: ký hợp đồng xong mới chuyển cọc", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Chuẩn hóa wording điều khoản: 'Trong thời hạn 03 ngày làm việc kể từ ngày ký HĐ...'. API cho phép lưu HĐ pháp nhân chưa cần cọc ngay.",
        "API_LuuHopDong.sql, các mẫu HĐ 2.1, 2.2, 3.1, 3.2",
        "Đúng thông lệ ký hợp đồng trước, làm thủ tục thanh toán cọc sau."
    ),
    (
        "REQ-17", "Hợp Đồng Pháp Nhân", 
        "Không mặc định 70% tiền cọc, để mở tự nhập tùy thỏa thuận (30% - 40%)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Xóa sạch cụm từ '70% giá trị HĐ tạm tính' khỏi cả 4 mẫu DOCX pháp nhân. Sửa thành: '...số tiền: {Dot1SoTien}'.",
        "Mẫu 2.1, 2.2, 3.1, 3.2 (DOCX), v_DanhSachHopDong.sql",
        "Nhân viên tự nhập số tiền hoặc % cọc theo thực tế đàm phán."
    ),
    (
        "REQ-18", "Hợp Đồng Pháp Nhân", 
        "Nội dung xuất hóa đơn GTGT để mở (email, thông tin chứng từ)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Hỗ trợ nhập thông tin hóa đơn, email nhận HĐĐT ({EmailHoaDon}), map số chứng từ quyết toán linh hoạt vào điều khoản.",
        "v_DanhSachHopDong.sql, các template DOCX pháp nhân",
        "Sẵn sàng theo dõi thêm yêu cầu mở rộng trường của khách."
    ),
    (
        "REQ-19", "Đại Diện Bên A", 
        "Chức vụ và tên người đại diện Bên A lấy linh hoạt, không fallback hard-code 'Nguyễn Văn A'", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Loại bỏ fallback cứng 'Giám đốc' / 'Nguyễn Văn A'. Lấy chuẩn từ h.BenADaiDien, h.BenAChucVu hoặc cấu hình SY_Setup.",
        "v_DanhSachHopDong.sql, Seed_SY_Setup_BenA.sql, hop_dong.docx",
        "Hỗ trợ nhiều người đại diện theo ủy quyền khác nhau."
    ),
    (
        "REQ-20", "Hội Nghị & Tiệc", 
        "Mẫu 3.1 (Hội nghị + Tiệc-Teabreak) sửa câu chữ đúng loại hình, bỏ chữ 'triển lãm'", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Đã sửa tiêu đề và căn cứ của mẫu 3.1 thành 'Hợp đồng hội nghị và tiệc', loại bỏ chữ 'triển lãm' bị nhầm lẫn khi copy.",
        "3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx",
        "Chuẩn hóa 100% văn phong pháp lý cho dịch vụ hội nghị."
    ),
    (
        "REQ-21", "Setup Bàn Ghế", 
        "Quản lý danh mục Kiểu Setup bàn ghế (Lớp học, Nhà hát, Chữ U, Bàn tròn...)", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Tạo bảng dmKieuSetup (7 kiểu chuẩn), đăng ký dropdown và liên kết với trường KieuSetup của từng sảnh tiệc.",
        "dmKieuSetup, Update_dmKieuSetup.sql, v_DanhSachHopDong.sql",
        "Chuẩn hóa danh mục setup thay vì nhập text tự do."
    ),
    (
        "REQ-22", "Setup Bàn Ghế", 
        "Hỗ trợ định kiểu setup riêng cho phần bàn tiệc trong sự kiện", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Cho phép chỉ định kiểu setup bàn tiệc (Bàn tròn tiệc tiêu chuẩn) riêng biệt với khu vực hội trường/hội nghị.",
        "dmKieuSetup, Update_dmKieuSetup.sql, v_DanhSachHopDong.sql",
        "Hiển thị rõ ràng cách bố trí từng khu vực trong hợp đồng."
    ),
    (
        "REQ-23", "Hội Nghị & Tiệc", 
        "Tách riêng địa điểm hội nghị và địa điểm tiệc/teabreak", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Tách bạch {DiaDiemHoiNghi} và {DiaDiemTiec}, mỗi địa điểm có thể chọn sảnh khác nhau và thời gian khác nhau.",
        "v_DanhSachHopDong.sql, tbmk_Hopdongsanhtiec, Mẫu 3.1 DOCX",
        "Tương tự như HĐ Triển lãm + Tiệc."
    ),
    (
        "REQ-24", "Quyết Toán Dịch Vụ", 
        "Mẫu 3.1 dùng đúng từ 'Quyết toán dịch vụ' (thay vì 'Quyết toán tiệc')", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Sửa dòng 167 mẫu 3.1: '+ Biên bản nghiệm thu và quyết toán dịch vụ'. Mẫu 3.2 cũng đã đồng bộ chuẩn.",
        "3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx",
        "Thống nhất thuật ngữ chuẩn pháp nhân."
    ),
    (
        "REQ-25", "Thuê Sảnh Ngoài Giờ", 
        "Đồng bộ quy tắc tính phát sinh ngoài giờ cho Hợp đồng Hội Nghị", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Áp dụng chung cơ chế tính theo danh mục sảnh dmSanhtiec.Dongia / 4 cho các mẫu hội nghị 3.1 và 3.2.",
        "v_DanhSachHopDong.sql, Mẫu 3.1 & 3.2 DOCX",
        "Đồng bộ toàn bộ các hợp đồng pháp nhân."
    ),
    (
        "REQ-26", "Hợp Đồng Hội Nghị", 
        "Hợp đồng Hội nghị (mẫu 3.1, 3.2) không fix cứng 70% tiền cọc", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Đã xóa literal 70% ở dòng ~142 của mẫu 3.1 và 3.2. Thay bằng biến số tiền cọc thực tế {Dot1SoTien}.",
        "Mẫu 3.1 & 3.2 (DOCX), v_DanhSachHopDong.sql",
        "Đồng bộ với các mẫu triển lãm 2.1, 2.2."
    ),
    (
        "REQ-27", "Đại Diện Bên A", 
        "Đầu mối đại diện Bên A linh hoạt theo từng hợp đồng hội nghị", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Hiển thị đúng người phụ trách / đại diện Bên A ký hợp đồng cụ thể đó, không bị fix cứng tên ban giám đốc.",
        "v_DanhSachHopDong.sql, hop_dong.docx, các mẫu pháp nhân",
        "Phù hợp với mô hình phân quyền ký tá của nhà hàng."
    ),
    (
        "REQ-28", "Hợp Đồng Hội Nghị", 
        "Mẫu 3.2 (Hội nghị đơn thuần) dùng đúng wording 'Dịch vụ hội nghị'", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Đã sửa tiêu đề mẫu 3.2 thành 'Hợp đồng dịch vụ hội nghị', loại bỏ hoàn toàn chữ 'triển lãm và tiệc'.",
        "3.2 MAU HDONG - 0406 (HỘI NGHỊ).docx",
        "Chính xác câu từ pháp lý theo loại hình dịch vụ."
    ),
    (
        "REQ-29", "Setup Hội Nghị", 
        "Dropdown kiểu setup hiển thị đầy đủ trong hợp đồng hội nghị 3.2", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Kế thừa danh mục dmKieuSetup, hiển thị chuẩn {SetupBanGhe} trên hợp đồng hội nghị 3.2.",
        "dmKieuSetup, v_DanhSachHopDong.sql, Mẫu 3.2 DOCX",
        "Đáp ứng cấu hình setup phòng họp/hội nghị."
    ),
    (
        "REQ-30", "Hợp Đồng Pháp Nhân", 
        "Cấu trúc thanh toán và hóa đơn GTGT đồng bộ giữa 4 mẫu pháp nhân", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Chuẩn hóa khối điều khoản thanh toán, thuế GTGT, thông tin xuất hóa đơn trên cả 4 mẫu (2.1, 2.2, 3.1, 3.2).",
        "Mẫu 2.1, 2.2, 3.1, 3.2 DOCX",
        "Thống nhất chuẩn mực biểu mẫu công ty."
    ),
    (
        "REQ-31", "Bàn Vượt Dự Phòng", 
        "Bàn vượt quá 10% tính phụ thu 10% (sửa lỗi hiển thị 'cộng thêm 15%')", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Sửa văn bản trong hop_dong.docx dòng ~46: 'phần bàn vượt quá 10% … cộng thêm 10%'.",
        "backend-app/samples/hop_dong.docx",
        "Khắc phục lỗi số liệu mâu thuẫn 10% vs 15%."
    ),
    (
        "REQ-32", "Phí Phục Vụ", 
        "Phí phục vụ linh hoạt theo từng HĐ (thay vì dán cứng '180.000vnđ/bàn')", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Thay literal 180.000vnđ bằng placeholder {MucPhiPhucVu} trong hop_dong.docx và hop_dong_menu_ngay.docx.",
        "hop_dong.docx, hop_dong_menu_ngay.docx, v_DanhSachHopDong.sql",
        "Lấy theo trường PhiPhucVu cấu hình riêng cho từng tiệc."
    ),
    (
        "REQ-33", "Khuyến Mãi (CTKM)", 
        "Tự động áp dụng CTKM có hiệu lực theo khoảng thời gian tổ chức [Từ ngày, Đến ngày]", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Cập nhật API_LayDichVuUuDaiTheoLoaiTiec và PromotionAutoFillPlugin.js lọc ưu đãi hợp lệ theo ngày tiệc.",
        "API_LayDichVuUuDaiTheoLoaiTiec.sql, PromotionAutoFillPlugin.js",
        "Tránh áp dụng nhầm các chương trình khuyến mãi đã hết hạn."
    ),
    (
        "REQ-34", "Điều Khoản Bổ Sung", 
        "Cho phép nhập và in Điều khoản bổ sung linh hoạt vào Hợp đồng tiệc cưới", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Expose biến {DieuKhoanBoSung} lấy từ h.DieuKhoanBoSung trong v_DanhSachHopDong.sql, có điều khoản chuẩn.",
        "v_DanhSachHopDong.sql, hop_dong.docx",
        "Ghi nhận các thỏa thuận riêng biệt với khách hàng."
    ),
    (
        "REQ-35", "Khuyến Mãi (CTKM)", 
        "Câu chốt CTKM: 'Tất cả CTKM chỉ áp dụng vào thời điểm ký HĐ...'", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Đã duy trì và hiển thị đầy đủ câu cam kết CTKM trong biểu mẫu CTKM tiệc cưới.",
        "CTKM TIỆC CƯỚI.docx",
        "Ràng buộc pháp lý điều kiện hưởng ưu đãi."
    ),
    (
        "REQ-36", "Phụ Lục Hợp Đồng", 
        "Mẫu in Phụ lục Hợp đồng hiển thị đúng số phụ lục {SoPhuLuc}", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Map chính xác biến {SoPhuLuc} từ trường Sothaydoi trong Update_PhuLuc_AllInOne.sql và phu_luc_hop_dong.docx.",
        "Update_PhuLuc_AllInOne.sql, phu_luc_hop_dong.docx",
        "Đảm bảo tính liên tục của hồ sơ thay đổi."
    ),
    (
        "REQ-37", "Chi Tiết Số Bàn", 
        "Tách bạch chi tiết 6 nhóm số bàn: Mặn CT, Chay CT, Mặn DP, Chay DP, Tổng số bàn, Bàn phát sinh", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Bổ sung đủ 6 trường số bàn riêng biệt vào v_DanhSachHopDong, Update_PhuLuc_AllInOne, Update_frmPhuLucHopDong_GetDetails.",
        "v_DanhSachHopDong.sql, Update_PhuLuc_AllInOne.sql, Update_frmPhuLucHopDong_GetDetails.sql",
        "Bếp và vận hành quản lý chính xác lượng món mặn và món chay."
    ),
    (
        "REQ-38", "Món Chay Trong Menu", 
        "Tách rõ ràng món mặn và món chay trong biểu mẫu Hợp đồng & Phụ lục BEO", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Viết các hàm nghiệp vụ fn_DOCX_MenuMan, fn_DOCX_MenuChay, fn_DOCX_MenuTongCongChay, gán nhãn '(Món chay)'.",
        "fn_DOCX_MenuDichVu.sql, v_DanhSachHopDong.sql, Update_PhuLuc_AllInOne.sql",
        "Khách hàng và phục vụ nhìn vào thực đơn nhận biết ngay món chay."
    ),
    (
        "REQ-39", "HĐ Cưới Dưới 30 Ngày", 
        "Tự động chọn mẫu 'Chọn ngay menu' (hop_dong_menu_ngay.docx) khi ngày tổ chức <= 30 ngày", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Tạo template hop_dong_menu_ngay.docx và xây dựng logic tự động định tuyến khi DATEDIFF <= 30 ngày ở cả SQL và server.js.",
        "hop_dong_menu_ngay.docx, server.js:363-372, v_DanhSachHopDong.sql",
        "Tiệc gấp chốt ngay menu trên hợp đồng chính mà không cần chờ phụ lục."
    ),
    (
        "REQ-40", "Thông Tin Bên A", 
        "Thông tin Bên A (Tên cty, MST, Địa chỉ, SĐT) cấu hình động, không dán cứng 'Queen Plaza / 16A Lê Hồng Phong'", 
        "ĐÃ XỬ LÝ (RESOLVED)", 
        "Thay toàn bộ văn bản cứng bằng biến {BenATenCongTy}, {BenADiaChi}, {BenASDT}, {BenAMST}. Tạo script cấu hình Seed_SY_Setup_BenA.sql.",
        "hop_dong.docx, Seed_SY_Setup_BenA.sql, v_DanhSachHopDong.sql",
        "Cho phép linh hoạt đổi thông tin thương hiệu / pháp nhân nhà hàng."
    )
]

for row_idx, data in enumerate(data_reqs, start=5):
    ws1.append(list(data))
    ws1.row_dimensions[row_idx].height = 36
    
    # Format cells
    c_req = ws1.cell(row=row_idx, column=1)
    c_req.alignment = align_center
    c_req.font = font_bold
    c_req.border = border_cell
    
    c_grp = ws1.cell(row=row_idx, column=2)
    c_grp.alignment = align_center
    c_grp.font = font_row
    c_grp.border = border_cell
    
    c_desc = ws1.cell(row=row_idx, column=3)
    c_desc.alignment = align_left
    c_desc.font = font_row
    c_desc.border = border_cell
    
    c_status = ws1.cell(row=row_idx, column=4)
    c_status.alignment = align_center
    c_status.border = border_cell
    if "RESOLVED" in c_status.value:
        c_status.fill = fill_resolved
        c_status.font = font_resolved
    else:
        c_status.fill = fill_waiting
        c_status.font = font_waiting
        
    c_sol = ws1.cell(row=row_idx, column=5)
    c_sol.alignment = align_left
    c_sol.font = font_row
    c_sol.border = border_cell
    
    c_files = ws1.cell(row=row_idx, column=6)
    c_files.alignment = align_left
    c_files.font = font_row
    c_files.border = border_cell
    
    c_note = ws1.cell(row=row_idx, column=7)
    c_note.alignment = align_left
    c_note.font = font_row
    c_note.border = border_cell

# Column widths for Sheet 1
col_widths_ws1 = [12, 22, 38, 22, 50, 42, 35]
for idx, width in enumerate(col_widths_ws1, start=1):
    ws1.column_dimensions[get_column_letter(idx)].width = width


# ==========================================
# SHEET 2: PHÂN TÍCH THEO ẢNH PHẢN HỒI CỦA CHỊ DINH TINH
# ==========================================
ws2 = wb.create_sheet(title="Đối Soát Ý Kiến Chị Dinh Tinh")
ws2.views.sheetView[0].showGridLines = True

ws2.merge_cells("A1:F1")
ws2["A1"] = "BẢNG ĐỐI SOÁT CHI TIẾT THEO CÁC ẢNH & TIN NHẮN PHẢN HỒI CỦA KHÁCH HÀNG"
ws2["A1"].font = font_title
ws2["A1"].alignment = Alignment(horizontal="left", vertical="center")
ws2.row_dimensions[1].height = 30

ws2.merge_cells("A2:F2")
ws2["A2"] = "Chi tiết từng yêu cầu trong hình ảnh chat Zalo của chị Dinh Tinh và kết quả xử lý kỹ thuật tương ứng."
ws2["A2"].font = font_subtitle
ws2["A2"].alignment = Alignment(horizontal="left", vertical="center")
ws2.row_dimensions[2].height = 20

headers_ws2 = [
    "STT", 
    "Vấn Đề / Tin Nhắn Phản Hồi Từ Khách Hàng", 
    "Mã REQ", 
    "Hiện Trạng & Nguyên Nhân Cũ", 
    "Giải Pháp Đã Xử Lý Thành Công", 
    "Kết Quả Sau Khi Sửa"
]

ws2.append([])
ws2.append(headers_ws2)
ws2.row_dimensions[4].height = 28

for col_num in range(1, len(headers_ws2) + 1):
    c = ws2.cell(row=4, column=col_num)
    c.font = font_header
    c.fill = fill_header_sub
    c.alignment = align_center
    c.border = border_cell

data_feedback = [
    (
        1,
        "Chị xuất ra docx để check hợp đồng, phiếu thu, BEO đều ko đc. Đâu có cái gì để check đâu.",
        "REQ-01",
        "Engine Docxtemplater bị crash do các thẻ XML trong file Word bị đứt đoạn, mảng loop rỗng không có fallback và thiếu mapping file.",
        "Viết bộ lọc làm sạch XML (XML cleaner) trong server.js, tự động tiêm [{}] cho loop rỗng và thêm STT. Test tự động 24/24 file Word.",
        "Pass 24/24 template, mở file Word trực tiếp không còn báo lỗi XML hay hỏng định dạng."
    ),
    (
        2,
        "Chị gửi mẫu quyết toán tiệc (MAU QUYET TOAN TIEC.xlsx gồm 2 sheet QT01 và QT02).",
        "REQ-02",
        "Chỉ có 1 file quyết toán chung, chưa phân tách mẫu cho khách cá nhân và khách doanh nghiệp/pháp nhân.",
        "Tạo riêng quyet_toan_01.docx (cưới, sinh nhật...) và quyet_toan_02.docx (hội nghị, công ty). Viết router tự động chọn đúng mẫu.",
        "Bấm 'Quyết toán' tự động tải đúng mẫu QT01 hoặc QT02 tương ứng với loại tiệc của hợp đồng."
    ),
    (
        3,
        "Phần menu có 2 hình thức: Theo set và tự chọn món. Theo set menu vẫn đc đổi món, có phát sinh bù giá theo món.",
        "REQ-03, REQ-04",
        "Chưa có màn hình quản lý đổi món; tiền bù món bị nhập gộp chung vào phí phát sinh thủ công.",
        "Phát triển plugin DoiMonPlugin.js cho phép chọn món gốc cần đổi và món mới thay thế. Hệ thống tự nhân đơn giá chênh lệch với số bàn.",
        "Hợp đồng và quyết toán tự động hạch toán khoản chênh lệch đổi món vào bảng kê chi phí."
    ),
    (
        4,
        "Quyết toán tiệc sẽ lấy thông tin từ BEO (lần thay đổi cuối cùng + phát sinh trong tiệc).",
        "REQ-05, REQ-06",
        "Quyết toán cũ chỉ lấy theo hợp đồng gốc ban đầu, không tự động bắt các lần thỏa thuận thay đổi BEO sau đó.",
        "Viết proc Update_QuyetToan_AllInOne tự động query TOP 1 LanThayDoi của tbmk_Thaydoi (BEO chốt) và gộp bảng phát sinh tbmk_HopdongPhatSinh.",
        "Số bàn, thực đơn, dịch vụ lấy chuẩn từ BEO mới nhất kết hợp đầy đủ chi phí phát sinh thực tế."
    ),
    (
        5,
        "Mẫu trang trí: cái chỗ này ko mặc định sẵn giùm chị. Có thể tạo cho chị 1 thư mục chứa hình ảnh các mẫu trang trí, để tick chọn.",
        "REQ-07",
        "Trong file BEO dán hình ảnh mẫu hoa/backdrop cố định, không chọn được mẫu khác.",
        "Tạo bảng dmMauTrangTri và xây dựng MauTrangTriPlugin.js hiển thị gallery ảnh xem trước trực quan để nhân viên tick chọn.",
        "Nhân viên mở form HĐ bấm nút 'Mẫu Trang Trí' để xem ảnh và chọn mẫu; tên mẫu & đơn giá tự xuất vào Word."
    ),
    (
        6,
        "Địa điểm triển lãm: là 1 sảnh, địa điểm tiệc (có thể tối, có thể trưa): là 1 sảnh.",
        "REQ-08, REQ-09",
        "Hệ thống chỉ có 1 sảnh chính và 1 ca tiệc duy nhất cho cả sự kiện; sảnh bị dán cứng tên Diamond/Ruby.",
        "Mở rộng bảng tbmk_Hopdongsanhtiec có trường LoaiDiaDiem ('TRIEN_LAM', 'TIEC') và Thoigianid riêng cho từng sảnh.",
        "Cho phép chọn 1 sảnh làm triển lãm và 1 sảnh riêng làm tiệc (trưa hoặc tối linh hoạt)."
    ),
    (
        7,
        "Mục thuê sảnh phát sinh ngoài thời gian hợp đồng: để mở, (dữ liệu lấy từ danh mục sảnh, có phí thuê sảnh theo buổi (4 tiếng)/4).",
        "REQ-11, REQ-12",
        "Đơn giá ngoài giờ bị hard-code số tiền chết 17.500.000 VNĐ/giờ/sảnh.",
        "Thay bằng placeholder {DonGiaNgoaiGio}, tính tự động bằng dmSanhtiec.Dongia / 4 theo đúng chỉ đạo của khách.",
        "Giá thuê ngoài giờ tự động nhảy chính xác theo đơn giá của từng sảnh tương ứng."
    ),
    (
        8,
        "Chỗ này, số hợp đồng ko mặc định sẵn nha (Hợp đồng triển lãm + tiệc).",
        "REQ-10",
        "File mẫu có chứa số HĐ mẫu bị lưu cứng.",
        "Xóa toàn bộ số HĐ mẫu trong template, thay bằng {Sohopdong} và để mở ô nhập trên màn hình.",
        "Người dùng tự điền số hợp đồng theo quy chuẩn quản lý thực tế."
    ),
    (
        9,
        "Sửa lại giùm chị: Sau khi bàn bạc... ký Hợp đồng triển lãm... Bên B có nhu cầu thuê địa điểm để tổ chức triển lãm (Bỏ chữ 'và tiệc').",
        "REQ-13, REQ-14",
        "Mẫu 2.2 là HĐ chỉ triển lãm nhưng phần câu chữ mở đầu lại copy nguyên văn 'triển lãm và tiệc' từ mẫu 2.1.",
        "Chỉnh sửa trực tiếp file Word 2.2, gọt sạch chữ 'và tiệc', mở các trường: Số lượng khách tham quan dự kiến, Thời gian diễn ra triển lãm...",
        "Biểu mẫu 2.2 chuẩn xác 100% về mặt pháp lý cho sự kiện chỉ thuê địa điểm triển lãm."
    ),
    (
        10,
        "Kích thước sân khấu: đang bị trùng 2 lần thể hiện diện tích kìa (9.6m x 3.6m x 0.8m: 9.6m x 3.6m x 0.8m).",
        "REQ-15",
        "Do lỗi định dạng trong file mẫu Word khiến kích thước sân khấu bị in lặp 2 lần liên tiếp.",
        "Sửa lại template Word, bỏ đoạn text trùng, chỉ giữ đúng 1 placeholder {KTSanKhau} lấy từ dmSanhtiec.",
        "Chỉ hiển thị kích thước sân khấu đúng 1 lần duy nhất."
    ),
    (
        11,
        "Phần đặt cọc đối với khách pháp nhân thì ký hợp đồng xong mới chuyển cọc. Đừng mặc định 70% mà để mở tự nhập vì tùy khách deal 30%-40%.",
        "REQ-16, REQ-17, REQ-26",
        "Cả 4 mẫu hợp đồng pháp nhân đều dán cứng cụm từ 'tương đương 70% giá trị Hợp đồng tạm tính'.",
        "Xóa triệt để số '70%' khỏi cả 4 file DOCX. Sửa điều khoản thành: '...số tiền: {Dot1SoTien}'. Nhân viên tự thỏa thuận % cọc trên form.",
        "Linh hoạt mọi tỷ lệ đặt cọc (30%, 40%, 50%...) theo thỏa thuận thực tế với khách hàng."
    )
]

for row_idx, data in enumerate(data_feedback, start=5):
    ws2.append(list(data))
    ws2.row_dimensions[row_idx].height = 42
    
    c_stt = ws2.cell(row=row_idx, column=1)
    c_stt.alignment = align_center
    c_stt.font = font_bold
    c_stt.border = border_cell
    
    c_fb = ws2.cell(row=row_idx, column=2)
    c_fb.alignment = align_left
    c_fb.font = font_bold
    c_fb.border = border_cell
    
    c_req = ws2.cell(row=row_idx, column=3)
    c_req.alignment = align_center
    c_req.font = font_bold
    c_req.border = border_cell
    c_req.fill = fill_resolved
    
    c_old = ws2.cell(row=row_idx, column=4)
    c_old.alignment = align_left
    c_old.font = font_row
    c_old.border = border_cell
    
    c_sol = ws2.cell(row=row_idx, column=5)
    c_sol.alignment = align_left
    c_sol.font = font_row
    c_sol.border = border_cell
    
    c_res = ws2.cell(row=row_idx, column=6)
    c_res.alignment = align_left
    c_res.font = font_row
    c_res.border = border_cell

col_widths_ws2 = [8, 42, 16, 38, 46, 38]
for idx, width in enumerate(col_widths_ws2, start=1):
    ws2.column_dimensions[get_column_letter(idx)].width = width


# ==========================================
# SHEET 3: HƯỚNG DẪN LUỒNG KIỂM THỬ TỪ ĐẦU ĐẾN CUỐI
# ==========================================
ws3 = wb.create_sheet(title="Quy Trình Kiểm Thử Hệ Thống")
ws3.views.sheetView[0].showGridLines = True

ws3.merge_cells("A1:E1")
ws3["A1"] = "HƯỚNG DẪN QUY TRÌNH KIỂM THỬ TOÀN DIỆN (USER FLOW GUIDE)"
ws3["A1"].font = font_title
ws3["A1"].alignment = Alignment(horizontal="left", vertical="center")
ws3.row_dimensions[1].height = 30

ws3.merge_cells("A2:E2")
ws3["A2"] = "Các bước thao tác thực tế từ tiếp nhận khách tham quan đến ký hợp đồng, thay đổi BEO và quyết toán tiệc."
ws3["A2"].font = font_subtitle
ws3["A2"].alignment = Alignment(horizontal="left", vertical="center")
ws3.row_dimensions[2].height = 20

headers_ws3 = [
    "Bước", 
    "Tên Giai Đoạn", 
    "Màn Hình / Form Thao Tác", 
    "Nội Dung Kiểm Thử Chi Tiết", 
    "Kết Quả Mong Đợi / File Xuất Ra"
]

ws3.append([])
ws3.append(headers_ws3)
ws3.row_dimensions[4].height = 28

for col_num in range(1, len(headers_ws3) + 1):
    c = ws3.cell(row=4, column=col_num)
    c.font = font_header
    c.fill = fill_header_main
    c.alignment = align_center
    c.border = border_cell

data_flow = [
    (
        "Bước 1",
        "Tiếp nhận & Cọc giữ chỗ",
        "Khách tham quan / Biên nhận cọc chỗ",
        "Nhập thông tin khách hàng, chọn ngày dự kiến tổ chức tiệc, chọn sảnh và số tiền đặt cọc giữ chỗ.",
        "Bấm 'In / Xuất Word' tải về file phieu_thu.docx hoặc biên nhận cọc chỗ hiển thị đầy đủ tiền cọc và thông tin khách."
    ),
    (
        "Bước 2",
        "Lập Hợp Đồng Tiệc Cưới",
        "Quản lý Hợp đồng (frmHopDong)",
        "Tạo HĐ mới, chọn loại tiệc Cưới. Chọn hình thức Menu (Set/Tự chọn). Nếu tiệc <= 30 ngày tự động kích hoạt mẫu chọn ngay menu. Bấm 'Mẫu Trang Trí' để xem gallery ảnh.",
        "Bấm 'Xuất DOCX' sinh file hop_dong.docx (hoặc hop_dong_menu_ngay.docx). Hiển thị đủ Bên A động, phí phục vụ động, mẫu trang trí đã chọn."
    ),
    (
        "Bước 3",
        "Lập Hợp Đồng Pháp Nhân",
        "Quản lý Hợp đồng (frmHopDong)",
        "Chọn loại tiệc Triển Lãm hoặc Hội Nghị. Chọn sảnh Triển Lãm riêng, sảnh Tiệc riêng, ca tiệc (Trưa/Tối). Điền số tiền cọc (không bị fix 70%).",
        "Xuất file Word (2.1, 2.2, 3.1 hoặc 3.2): đúng wording cho thuê mặt bằng, không lặp kích thước sân khấu, giá ngoài giờ = đơn giá sảnh / 4."
    ),
    (
        "Bước 4",
        "Đổi món bù giá trong Set menu",
        "Tab Đổi món (DoiMonPlugin)",
        "Mở hợp đồng, tại tab Đổi món chọn món gốc trong set và món mới muốn thay thế. Hệ thống tự tính chênh lệch đơn giá.",
        "Lưu thành công, chênh lệch đơn giá * số bàn được lưu vào tbmk_HopdongDoiMon để chuẩn bị đưa vào quyết toán."
    ),
    (
        "Bước 5",
        "Phụ lục & Thay đổi BEO",
        "Đề nghị thay đổi / Phụ lục HĐ",
        "Khách điều chỉnh số bàn, món ăn, dịch vụ trước ngày tiệc. Hệ thống tạo phiên bản thay đổi mới (LanThayDoi).",
        "Bấm 'Xuất BEO' tải về BEO mới nhất, tách biệt rõ ràng số bàn mặn, số bàn chay và đánh dấu '(Món chay)' trên thực đơn."
    ),
    (
        "Bước 6",
        "Ghi nhận phát sinh tại tiệc",
        "Tab Phát sinh (frmHopDong)",
        "Trong ngày tổ chức, ghi nhận các dịch vụ/hàng hóa phát sinh thêm (bia, nước ngọt, bàn phát sinh, âm thanh thêm...).",
        "Lưu vào tbmk_HopdongPhatSinh, sẵn sàng tổng hợp vào hồ sơ quyết toán."
    ),
    (
        "Bước 7",
        "Quyết toán tiệc",
        "Nút 'Quyết Toán' trên lưới Hợp đồng",
        "Chọn 1 Hợp đồng cần thanh lý, bấm nút 'Quyết Toán'. Màn hình tự động tổng hợp: Số liệu BEO cuối + Đổi món bù giá + Phát sinh trong tiệc - Tiền cọc đã thu.",
        "Bấm 'Lưu & In Quyết toán' tự động tải về file quyet_toan_01.docx (nếu là tiệc cưới/cá nhân) hoặc quyet_toan_02.docx (nếu là pháp nhân)."
    )
]

for row_idx, data in enumerate(data_flow, start=5):
    ws3.append(list(data))
    ws3.row_dimensions[row_idx].height = 40
    
    c_b = ws3.cell(row=row_idx, column=1)
    c_b.alignment = align_center
    c_b.font = font_bold
    c_b.border = border_cell
    c_b.fill = fill_zebra
    
    c_n = ws3.cell(row=row_idx, column=2)
    c_n.alignment = align_center
    c_n.font = font_bold
    c_n.border = border_cell
    
    c_f = ws3.cell(row=row_idx, column=3)
    c_f.alignment = align_center
    c_f.font = font_row
    c_f.border = border_cell
    
    c_d = ws3.cell(row=row_idx, column=4)
    c_d.alignment = align_left
    c_d.font = font_row
    c_d.border = border_cell
    
    c_r = ws3.cell(row=row_idx, column=5)
    c_r.alignment = align_left
    c_r.font = font_row
    c_r.border = border_cell

col_widths_ws3 = [12, 28, 30, 48, 48]
for idx, width in enumerate(col_widths_ws3, start=1):
    ws3.column_dimensions[get_column_letter(idx)].width = width

wb.save("BANG_THEO_DOI_CHINH_SUA_CHANGELOG_BA.xlsx")
print("Excel file generated successfully!")
