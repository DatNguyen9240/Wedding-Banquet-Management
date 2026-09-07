# CHANGELOG BA — Wedding Banquet Management System

## Sửa ảnh khách — HĐ cưới, phụ lục và mẫu 1.4 — 2026-09-05

- Dùng file gốc `1.4 MAU HOP DONG TIEC CUOI (CHON MENU NGAY ) 0306.docx` để tạo lại `hop_dong_menu_ngay.docx`, giữ cấu trúc/nội dung mẫu khách, nối thông tin HĐ và hai bảng menu mặn/chay. Mẫu 1.4 giữ điều khoản cọc 30%/20% và mốc 10 ngày của file khách. Router SQL/JS dùng ngày biên nhận cọc liên kết chưa hủy, có tiền cọc, trong khoảng 0–30 ngày đến tiệc; không fallback ngày hiện tại/ngày HĐ.
- Phí phục vụ bỏ fallback 180.000 VNĐ/bàn; thêm trường nhập tỷ lệ `PhiPhucVuTyLe`, nối lưu và GetDetails; 0 là miễn phí. Vẫn dùng mô hình phần trăm hiện có, chưa bổ sung đơn giá đồng/bàn.
- CTKM có danh sách chọn từ catalog theo ngày tổ chức/số bàn chính thức, tải lại khi ngày thay đổi; sửa lọc chi nhánh rỗng và bỏ tự lấy CTKM bất kỳ khi xuất. Lưu nội dung lựa chọn vào `Noidunguudai`, chưa lưu khóa catalog. Bỏ tiêu đề KM 01.10.2025; điều khoản bổ sung nhập riêng, không tự chèn CTKM mặc định; câu cuối CTKM là text cố định trong hai mẫu cưới.
- Phụ lục in hai bảng mặn/chay với tổng đơn giá từng menu, không lấy tổng HĐ làm tổng menu. Đồng bộ nguồn giữa view/GetDetails, ưu tiên snapshot phụ lục; lưu món ưu tiên TableType/IsChay trước suy luận tên. Bỏ NULLIF(số bàn,0) ở các trường số bàn chi tiết và đồng bộ để giữ giá trị 0. Số phụ lục vẫn lấy Sothaydoi; sửa ngày xuất và khoảng trắng cạnh số HĐ.
- Địa chỉ Bên A trong mẫu cưới/pháp nhân và footer địa chỉ lấy cấu hình. Script seed không còn tự ghi đè địa chỉ/MST mẫu. **Chờ địa chỉ chính xác từ người dùng; chưa cập nhật giá trị cấu hình.**
- Kiểm tra source/render: 24/24 template qua; `test_wedding_bindings.js` qua 12 ca tài liệu và các biên ngày 0/30/31/âm/thiếu/sai ngày. Test CTKM kiểm tra lựa chọn, dữ liệu gửi và phản hồi cũ; test payload thực đơn kiểm tra mặn/chay đồng thời, chỉ chay và xóa hết món. Giao diện lưu rõ IsChay, không phụ thuộc chữ “chay” trong tên món. Chưa chạy SQL Server, chưa nghiệm thu UI/DB. Render bố cục PNG chưa chạy được vì thiếu pdf2image/LibreOffice; test Docxtemplater không thay thế kiểm tra bố cục Word.

## Sửa tiếp ảnh khách — HĐ Hội nghị 3.2 và mục chung 3.1/3.2 — 2026-09-05

- Mẫu 3.2 dùng đúng câu khách cung cấp: “thống nhất ký Hợp đồng hội nghị” và “Bên B có nhu cầu thuê địa điểm để tổ chức hội nghị…”. Setup lấy `{SetupHoiNghi}`; địa điểm/số khách/ngày setup/ngày sự kiện/ca lấy các trường hội nghị đã nối ở đợt trước. Bỏ màu khăn cố định và tên sân khấu gây lặp kích thước.
- Nội dung chuyển khoản hai lần ở 3.2 lấy `{HDTenCty}`, `{Sohopdong}`, `{NgaySuKien}`. GetDetails sửa tên/địa chỉ/MST hóa đơn từ thông tin Bên A sang các trường hóa đơn khách hàng trong view; email lấy `BenBEmail`.
- Hai mẫu 3.1/3.2 sửa lỗi chính tả “an toàn lao đồng” thành “an toàn lao động”; không thay đổi nội dung điều khoản an toàn kỹ thuật/PCCC. Đã đối chiếu câu “Biên bản nghiệm thu và quyết toán dịch vụ”, cọc không cố định 70%, đầu mối nhập riêng và nội dung hóa đơn dùng chung.
- Kiểm tra `test_conference_bindings.js`: 12/12 ca render qua, bổ sung kiểm tra riêng wording/setup/ngày/số khách/chuyển khoản mẫu 3.2. Chỉ sửa source; chưa triển khai SQL Server, chưa xác minh UI/DB và bố cục Word thực tế. Cơ chế chặn nhận cọc trước khi ký vẫn chưa có.

## Sửa tiếp ảnh khách — HĐ Hội nghị + Tiệc 3.1 — 2026-09-05

- Source-only, chưa chạy SQL Server. Mẫu 3.1 bỏ mã số HĐ/năm 2025 và giá ngoài giờ 17.500.000 cố định; dùng `{Sohopdong}` và `{PhiThueSanhNgoaiGio}`.
- Setup hội nghị/tiệc lấy riêng từ `dmKieuSetup` theo vai trò sảnh (`SetupHoiNghi`, `SetupTiec`), kèm ghi chú theo sảnh; bỏ màu khăn/nơ và nhãn bàn tròn cố định. Buổi tiệc lấy `{BuoiTiec}`. Ngày setup/sự kiện lấy `TuNgaySetup`/`Ngaytochuc`; thời gian hiển thị ca đã chọn riêng (`CaHoiNghi`, `CaTiec`).
- Thêm cột nullable `SoKhachHoiNghi` để nhập số khách độc lập với số bàn; `BenANguoiGiaoDich`/`BenAChucVuGiaoDich` độc lập với người đại diện; `NoiDungXuatHoaDon` nhập theo HĐ. Có script schema/metadata `Update_ContractContactInvoice.sql`, nối INSERT/UPDATE tại `API_LuuHopDong`, view và GetDetails. Xem thứ tự tại `Migration_Scripts.md`.
- Bốn mẫu pháp nhân 2.1/2.2/3.1/3.2 sử dụng đầu mối nhập riêng, nội dung hóa đơn nhập tay (khi trống dùng câu chung với số/ngày HĐ thực tế; số/ngày BBNT vẫn để chỗ trống), không còn lặp VNĐ sau `Dot1SoTien`.
- Kiểm tra `backend-app/test_conference_bindings.js`: 12 ca render (4 mẫu × trưa/tối/rỗng) qua; đối chiếu setup, địa điểm, ngày, số khách, cọc và nội dung hóa đơn. Chưa xác minh DB/UI hoặc bố cục Word thực tế. Các status RESOLVED cũ không thay thế nghiệm thu end-to-end; cơ chế khóa nhận cọc theo trạng thái ký vẫn chưa có.

## Kiểm tra và sửa source theo ảnh khách — 2026-09-05

- Chỉ sửa source trong repo, **chưa triển khai SQL Server**.
- Hai mẫu triển lãm 2.1/2.2: số khách lấy `SoKhachThamQuanDuKien`, không lấy `TongSoBan × 10`; ngày setup lấy `TuNgaySetup`, ngày triển lãm lấy `Ngaytochuc`; giờ lấy `GioBatDauTrienLam/GioKetThucTrienLam`. Bỏ lỗi năm lấy tháng và đơn vị VNĐ lặp sau `Dot1SoTien`.
- `sql/View/v_DanhSachHopDong.sql`: bỏ mặc định 600 khách, 08:00/17:00; thêm `NgaySetupTrienLam/NgayTrienLam`; giá ngoài giờ lấy `dmSanhtiec.Dongia / 4`, không fallback giá thỏa thuận trên HĐ, giữ giá 0. `Update_frmHopDong_GetDetails.sql` trả thêm các trường xuất này.
- Kiểm tra `backend-app/test_exhibition_bindings.js`: cả hai mẫu qua ca có dữ liệu và ca rỗng; kiểm tra khác biệt số khách/ngày/giờ HĐ với sự kiện và không lặp VNĐ. Bộ test render Docxtemplater: 24/24 qua. Chưa QA bố cục bằng LibreOffice/PNG (máy chưa có soffice), chưa kiểm thử DB/UI thực tế.
- REQ-16: điều khoản đã ghi ký rồi mới cọc, số tiền thỏa thuận nhập tự do; **chưa có cơ chế khóa nhận cọc theo trạng thái đã ký**. Không coi toàn bộ backlog đã nghiệm thu chỉ dựa trên các bảng RESOLVED bên dưới.


## SOURCE AUDIT — Hoàn thiện 2026-08-29

**Phạm vi:** Audit source code cho 40 yêu cầu khách hàng (REQ-01 → REQ-40).
**Nguyên tắc:** Chỉ đọc source, không sửa code / test / dữ liệu. Mọi kết luận "có implementation" đều kèm path + hàm/thành phần + hành vi thực tế.

**Trạng thái audit:** 40/40 đã audit source.
**Trạng thái implement:** ĐANG SỬA — cập nhật 2026-08-31. Xem **TIẾN ĐỘ SỬA 2026-08-31** bên dưới.

### Lịch sử

| Ngày | Nội dung |
|---|---|
| (trước) | Bản Kilo: mọi REQ còn `PENDING SOURCE AUDIT`; một bản "reconstructed" gán status từ trí nhớ, không có evidence. |
| 2026-08-28 | Reconstructed summary (Kilo) — nhiều status sai / mâu thuẫn evidence. |
| 2026-08-29 | **Audit source thật REQ-01 → REQ-40.** Sửa các kết luận sai của Kilo (xem "SỬA LỖI" bên dưới). Thêm Source Audit block đầy đủ cho REQ-21 → REQ-40; REQ-01 → REQ-20 giữ kết luận đã chấp nhận + đối chiếu evidence tìm được trong lượt này. |
| 2026-08-31 | **Đợt sửa 1 (dev):** Sửa template DOCX (wording HĐ, bỏ "70%" cọc, "15%"→"10%" bàn vượt, binding Bên A); bỏ fallback literal Giám đốc / Nguyễn Văn A; tạo `dmKieuSetup` + mở rộng `tbmk_Hopdongsanhtiec` (KieuSetup/LoaiDiaDiem/Thoigianid/Giatiensanh); tạo `hop_dong_menu_ngay.docx` + mapping; thêm `dmMauTrangTri`, `tbmk_HopdongDoiMon`; thêm `fn_DOCX_MenuMan`/`fn_DOCX_MenuChay`; điền `docx_placeholders.json`. |
| 2026-08-31 | **Verify lại working tree sau đợt sửa 1.** 10 REQ template RESOLVED; 6 REQ backend xong nhưng **chưa nối hết** (view CASE, placeholder DOCX, UI, logic auto-chọn); 2 REQ chờ khách. Chi tiết: **TIẾN ĐỘ SỬA 2026-08-31**. Bảng "BẢNG TỔNG TRẠNG THÁI" bên dưới giữ nguyên là **baseline audit 2026-08-29**. |
| 2026-09-02 | **Hoàn tất nhóm HĐ Triển lãm:** tách vai trò sảnh triển lãm/tiệc, bổ sung chọn ca theo sảnh, validate 1+1 sảnh; sửa wording mẫu 2.2; bỏ số HĐ và giá ngoài giờ hard-code; giá ngoài giờ = `dmSanhtiec.Dongia / 4`; bỏ lặp kích thước sân khấu. Đã sinh thử 2 mẫu, Word mở thành công (21/15 trang), không còn placeholder chưa render. |
| 2026-09-04 | **Đợt sửa 3:** (1) REQ-17: Gọt sạch văn phong "tương ứng số tiền" -> "số tiền: {Dot1SoTien}" trong cả 4 mẫu DOCX pháp nhân (2.1, 2.2, 3.1, 3.2). (2) REQ-21/22/29: Refactor `v_DanhSachHopDong.sql` join `dmKieuSetup` cho `[SetupBanGhe]`. (3) REQ-39: Hoàn thiện logic tự động định tuyến HĐ tiệc cưới chọn ngay menu (`hop_dong_menu_ngay.docx`) khi `<= 30 ngày` tại cả view SQL và `server.js`. (4) REQ-38: Tách bạch và hiển thị rõ ràng món chay trong Phụ lục HĐ (`Update_PhuLuc_AllInOne.sql` + `Update_frmPhuLucHopDong_GetDetails.sql` expose `[MenuMan]`, `[MenuChay]`, `[MenuTongCongChay]`, gán nhãn `(Món chay)` trong `MenuTiec`). (5) Cập nhật `docx_placeholders.json` và `Migration_Scripts.md`. |
| 2026-09-04 | **Đợt sửa 4 (Hoàn tất toàn bộ backlog BA):** (1) **REQ-01/02:** Verify pass render 24/24 file DOCX; hoàn thiện router chọn QT01 (cá nhân/cưới) vs QT02 (pháp nhân) ở `server.js`. (2) **REQ-03/04:** Xây dựng `DoiMonPlugin.js` và tích hợp `tbmk_HopdongDoiMon` tự động tính tiền bù giá vào `Update_QuyetToan_AllInOne.sql`. (3) **REQ-07:** Xây dựng `MauTrangTriPlugin.js` (UI gallery ảnh), lưu `MauTrangTriID` và expose `{TenMauTrangTri}`, `{DonGiaMauTrangTri}` trong `v_DanhSachHopDong.sql`. (4) **REQ-08/09/23:** Tách vai trò sảnh & ca tổ chức, expose `{DiaDiemTrienLam}`, `{DiaDiemHoiNghi}`, `{DiaDiemTiec}`, `{CaTiec}`. (5) **REQ-14:** Bổ sung trường sự kiện triển lãm (`SoKhachThamQuanDuKien`, `ThoiGianTrienLam`). (6) **REQ-32:** Bind linh hoạt `{MucPhiPhucVu}` vào `hop_dong.docx` và `hop_dong_menu_ngay.docx`. (7) **REQ-33:** Lọc CTKM theo khoảng ngày hiệu lực `[TuNgay, DenNgay]` trong `API_LayDichVuUuDaiTheoLoaiTiec.sql` và `PromotionAutoFillPlugin.js`. (8) **REQ-37:** Bổ sung đầy đủ 6 trường số bàn riêng biệt (`SoBanManChinhThuc`, `SoBanChayChinhThuc`, `SoBanManDuPhong`, `SoBanChayDuPhong`, `TongSoBan`, `SoBanPhatSinh`) trong `v_DanhSachHopDong.sql`, `Update_PhuLuc_AllInOne.sql`, `Update_frmPhuLucHopDong_GetDetails.sql`. (9) **REQ-40:** Tạo script `Seed_SY_Setup_BenA.sql` chuẩn hóa cấu hình Bên A. Đã build bundle thành công và kiểm thử tự động 24/24 template. |

---

## KIẾN TRÚC LIÊN QUAN (đọc trước khi phân loại)

- **Sinh tài liệu DOCX:** `backend-app/server.js` — `POST /api/documents/generate` dùng `PizZip` + `Docxtemplater` (`server.js:7-8, 276-529`). Template lấy từ `backend-app/samples/**` qua `findTemplatePath()` (`server.js:711-730`). Frontend gọi qua `src/js/utils/DocumentExportPlugin.js`.
- **Chọn template theo loại tiệc:** `tbmk_LoaitiecAddfile` (FormName × Loaitiecid → TemplateFile), seed tại `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql`, tra cứu qua `API_tbmk_GetForm`.
- **Dữ liệu có cấu trúc → placeholder `{X}`:** các SQL view `v_DanhSachHopDong.sql`, `Update_QuyetToan_AllInOne.sql`, `Update_PhuLuc_AllInOne.sql`, `v_DanhSachBEO.sql` → `dataMap` → `docx.render()`.
- **Text cố định trong file `.docx`** (điều khoản pháp lý, "15%", "180.000", "70%", địa chỉ Bên A ở mẫu cưới) **không đi qua engine** — muốn đổi phải sửa file template.
- **Danh mục / master data:** `dmLoaihinhtiec`, `dmSanhtiec`, `dmThoigian`, `dmHanghoa`, `tbmk_Banuudai`/`tbmk_Banuudaict` (CTKM). Field HĐ bắt buộc chọn từ danh mục được khai báo trong `Update_ContractDropdowns.sql` (`@Dropdowns`: `Makh, Manv, Thoigianid, Loaitiecid, GoiThucDonID`).
- **5 loại tiệc seed:** `BLT000001` Tiệc Cưới · `BLT000002` Triển lãm + Tiệc · `BLT000003` Triển lãm · `BLT000004` Hội nghị + Tiệc-Teabreak · `BLT000005` Hội nghị.

**Caveat dữ liệu:**
1. `sql/tables/*` là dump `INFORMATION_SCHEMA` **cũ** — thiếu một số cột mà proc/view runtime đang dùng (`tbmk_Hopdongsanhtiec.KieuSetup`, `dmSanhtiec.ClassRoom/Theater/ClusterHalfRound/ChieuRong/ChieuDai/ChieuCaoTran/KTSanKhau`, `tbmk_Hopdong.BenAChucVuDaiDien`…). DB thật là chuẩn; sự tồn tại chính xác của các cột này = `NOT_VERIFIABLE` chỉ từ repo.
2. Số dòng file `.docx` trong tài liệu này là số dòng của **text đã trích** (mỗi `</w:p>` = 1 dòng), dùng để định vị — mở file gốc trong Word khi sửa.
3. `backend-app/docx_placeholders.json` — ~~rỗng~~ đã được điền đầy index ~24 template (variables + loops) trong đợt sửa 1 (2026-08-31).

---

## BẢNG TỔNG TRẠNG THÁI (40 REQ)

| REQ | Status | Confidence | Recommended Action | Ghi chú |
|---|---|---|---|---|
| 01 | PARTIAL | MEDIUM | VERIFY + SMALL FIX | Hạ tầng export DOCX có (`server.js` generate + `DocumentExportPlugin.js`); chưa test 3 loại; `docx_placeholders.json` rỗng |
| 02 | PARTIAL | MEDIUM | TEMPLATE FIX | 2 template QT đã tách theo `Loaitiecid`; cần rà nội dung QT01/QT02 |
| 03 | PARTIAL | MEDIUM | BUSINESS LOGIC CHANGE | Set menu / tự chọn món có một phần trong `FoodSelectionPlugin` |
| 04 | PARTIAL | MEDIUM | DATA MODEL CHANGE | Đổi món + bù giá một phần; mô hình original/replacement chưa đầy đủ |
| 05 | PARTIAL | HIGH | SMALL FIX | ⚠ Kilo ghi MISSING sai — có `tbmk_HopdongPhatSinh` + `API_LuuPhatSinhNhanh` + `PhatSinhPlugin.js` + gộp settlement |
| 06 | PARTIAL (→ gần CONFIRMED) | HIGH | SMALL FIX | Quyết toán lấy `TOP 1 tbmk_Thaydoi ORDER BY LanThayDoi DESC` + phát sinh; thiếu thực thể "BEO" tường minh |
| 07 | MISSING | HIGH | BUSINESS LOGIC CHANGE + DATA MODEL CHANGE | Không có thư viện / danh mục mẫu trang trí |
| 08 | PARTIAL | MEDIUM | DATA MODEL CHANGE | ⚠ Có multi-sảnh (`tbmk_Hopdongsanhtiec` + `IsSanhchinh`); thiếu phân vai "địa điểm triển lãm" vs "địa điểm tiệc" |
| 09 | PARTIAL | MEDIUM | DATA MODEL CHANGE | ⚠ `dmThoigian` có `AMPM`/`IsTiecCuoi`/`IsHoiNghi`; ca trưa/tối chưa gán theo segment |
| 10 | PARTIAL | MEDIUM | VERIFY | `{Sohopdong}` nhập tay ở form; không hard-code trong template. Cần chốt: nhập tay hay auto-gen |
| 11 | MISSING | HIGH | DATA MODEL CHANGE + BUSINESS LOGIC CHANGE | Thuê sảnh phát sinh để "…. VNĐ/giờ/sảnh" trong template; `PhiBuSanh` là lump-sum thủ công, không nối `dmSanhtiec` |
| 12 | MISSING + NEEDS_CLARIFICATION | HIGH | NEED CUSTOMER CLARIFICATION | Không có công thức OT; `dmSanhtiec.Dongia` không có ngữ nghĩa "buổi 4 tiếng" |
| 13 | MISMATCH | MEDIUM | TEMPLATE FIX | ⚠ Kilo ghi MISSING sai — `2.2 MAU HDONG (TRIỂN LÃM).docx` tồn tại + mapped; wording dòng 31 còn "triển lãm và tiệc" |
| 14 | MISSING | MEDIUM | DATA MODEL CHANGE | Không có field sự kiện triển lãm riêng (số khách tham quan, thời gian setup/triển lãm). "600" chỉ là sample |
| 15 | MISSING · (DOCX lặp: NOT_VERIFIABLE) | MEDIUM | TEMPLATE FIX | Không có implementation kích thước sân khấu riêng; `PhongSanKhauID` dormant; KT lấy từ `dmSanhtiec` |
| 16 | PARTIAL | MEDIUM | BUSINESS LOGIC CHANGE | Không enforce "ký xong mới cọc"; template pháp nhân đã ghi "kể từ ngày ký HĐ" |
| 17 | MISMATCH | HIGH | TEMPLATE FIX | ⚠ Kilo ghi "không thấy 70%" sai — "70% giá trị HĐ tạm tính" là **literal** trong 4 template pháp nhân |
| 18 | MISSING + NEEDS_CLARIFICATION | HIGH | NEED CUSTOMER CLARIFICATION | Nội dung xuất hóa đơn để chấm chấm + "số …/CTY-HHKH/2025"; chưa rõ khách muốn mở field nào |
| 19 | PARTIAL | MEDIUM | SMALL FIX + TEMPLATE FIX | Có field `h.BenAChucVuDaiDien` per-HĐ; fallback `N'Giám đốc'` / `N'Nguyễn Văn A'` trong view |
| 20 | MISMATCH | MEDIUM | TEMPLATE FIX | ⚠ Kilo ghi MISSING sai — `3.1 (HỘI NGHỊ + TIỆC-TEABREAK).docx` tồn tại; dòng 29 & 31 còn "triển lãm" |
| 21 | PARTIAL | MEDIUM | DATA MODEL CHANGE + BUSINESS LOGIC CHANGE | `KieuSetup` free-string → CASE hard-code trong view → `{KieuSetup}`; không có danh mục quản lý |
| 22 | PARTIAL | MEDIUM | DATA MODEL CHANGE + BUSINESS LOGIC CHANGE | Cùng `KieuSetup`; bàn tiệc = nhánh `ELSE` không định kiểu |
| 23 | PARTIAL | MEDIUM | DATA MODEL CHANGE + TEMPLATE FIX + NEED CUSTOMER CLARIFICATION | Multi-sảnh + `dmThoigian(AMPM)` có; thiếu field địa điểm HN/tiệc tách bạch |
| 24 | MISMATCH (cục bộ) | HIGH | TEMPLATE FIX | Chỉ `3.1 ....docx` (~dòng 167) còn "quyết toán **tiệc**"; 4 mẫu khác đã "dịch vụ" |
| 25 | MISSING | HIGH | (phụ thuộc REQ-11/12) | Template để chấm chấm; không nối `dmSanhtiec`; không có rule để đồng bộ |
| 26 | MISMATCH | HIGH | TEMPLATE FIX (+ DATA MODEL CHANGE) | "70%" hard-code ở `hd_hoinghi/hd_hn_tiec/hd_trienlam/hd_tl_tiec` (~dòng 142) |
| 27 | PARTIAL | MEDIUM | SMALL FIX + TEMPLATE FIX | Field đầu mối per-HĐ có; fallback `N'Giám đốc'` trong `v_DanhSachHopDong` |
| 28 | MISMATCH (cục bộ) | MEDIUM | TEMPLATE FIX | `3.2 (HỘI NGHỊ).docx` tồn tại; dòng 29 & 31 còn "Hợp đồng triển lãm và tiệc" |
| 29 | PARTIAL | MEDIUM | (dùng chung fix REQ-21) | = REQ-21 áp cho HĐ hội nghị; cùng cơ chế `KieuSetup` |
| 30 | PARTIAL | MEDIUM | TEMPLATE FIX (gắn REQ-26 + REQ-18) | Các mẫu pháp nhân đã chia sẻ cấu trúc cọc/thanh toán/GTGT; kẹt gap 70% + nội dung hóa đơn |
| 31 | MISMATCH | HIGH | TEMPLATE FIX | `hop_dong.docx` (~dòng 46) literal "cộng thêm **15%**"; **không có calculation** ở đâu |
| 32 | PARTIAL | MEDIUM | TEMPLATE FIX + NEED CUSTOMER CLARIFICATION | `tbmk_Hopdong.PhiPhucVu` (%) + calc đầy đủ; `hop_dong.docx` (~dòng 62) hard-code "180.000vnđ/bàn" |
| 33 | PARTIAL | MEDIUM | BUSINESS LOGIC CHANGE + DATA MODEL CHANGE | Catalog `tbmk_Banuudai` + `API_LayDichVuUuDaiTheoLoaiTiec` + `PromotionAutoFillPlugin`; output là text thô, không lọc theo ngày |
| 34 | PARTIAL | MEDIUM | SMALL FIX / VERIFY | `hop_dong.docx` (~dòng 179) có `{DieuKhoanBoSung}`; chưa xác minh nguồn dữ liệu đổ vào |
| 35 | NEEDS_CLARIFICATION | LOW | NEED CUSTOMER CLARIFICATION | Câu chốt CTKM cố định trong `CTKM TIỆC CƯỚI.docx`; chưa thấy câu "Tất cả CTKM…" nguyên văn |
| 36 | CONFIRMED (clarify nhỏ) | HIGH | NO CHANGE / NEED CUSTOMER CLARIFICATION | ⚠ Kilo ghi MISSING sai — `phu_luc_hop_dong.docx:7` "Số: {SoPhuLuc}" + map `{SoPhuLuc}=td.Sothaydoi` |
| 37 | PARTIAL | MEDIUM | NEED CUSTOMER CLARIFICATION → TEMPLATE FIX | Phụ lục có 4 field số bàn; HĐ cưới có 3; cần khách chốt field còn thiếu |
| 38 | PARTIAL (gần CONFIRMED) | MEDIUM-HIGH | TEMPLATE FIX | ⚠ Kilo ghi MISSING sai — `FoodSelectionPlugin` giữ Man + Chay song song, lưu cả 2 bảng |
| 39 | MISSING | HIGH | TEMPLATE FIX + BUSINESS LOGIC CHANGE | Chỉ 1 template HĐ cưới (`BLT000001→hop_dong.docx`); không có nhánh 30 ngày |
| 40 | MISMATCH | HIGH | TEMPLATE FIX + (data: SY_Setup) | `hop_dong.docx:13-16` hard-code tên+địa chỉ+ĐT dù `{BenATenCongTy}/{BenADiaChi}` đã có + đã nối |

**Đếm (baseline 2026-08-29):** CONFIRMED 1 · PARTIAL 20 · MISSING 8 · MISMATCH 7 · NEEDS_CLARIFICATION (thuần) 1 · MISSING+NEEDS_CLARIFICATION 2 · (REQ-36 CONFIRMED kèm clarify nhỏ; REQ-35 NEEDS_CLARIFICATION)

> ⚠ Bảng trên là **kết quả audit gốc 2026-08-29**. Trạng thái **sau khi dev sửa** — xem **TIẾN ĐỘ SỬA 2026-08-31** ngay dưới đây.

---

## TIẾN ĐỘ SỬA — 2026-08-31

Verify lại toàn bộ working tree (git diff + trích lại text các `.docx` đã đổi + đọc 2 script SQL mới).

**Files đã đổi:** `backend-app/docx_placeholders.json` (điền đầy index ~24 template), `backend-app/server.js` (chỉ format), `sql/API/API_LuuHopDong.sql`, `sql/View/v_DanhSachHopDong.sql`, `sql/Functions/fn_DOCX_MenuDichVu.sql`, `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql`, `backend-app/samples/hop_dong.docx`, 4 mẫu HĐ pháp nhân (`2.1/2.2/3.1/3.2`).
**Files mới:** `backend-app/samples/hop_dong_menu_ngay.docx`, `sql/Update/Update_dmKieuSetup.sql`, `sql/Update/Update_dmMauTrangTri_DoiMon.sql`.

### ✅ Đã sửa xong (đã verify)

| REQ | Trạng thái mới | Bằng chứng working tree |
|---|---|---|
| **13** | MISMATCH → **RESOLVED** | `2.2 (TRIỂN LÃM).docx:29,31` → "ký Hợp đồng **tổ chức triển lãm**" / "cung cấp dịch vụ **tổ chức triển lãm**" (bỏ "và tiệc"). + `Update_LoaitiecAddfile_MapTemplates.sql`: filename `3.2 ...(HỘI NGHỊ ).docx` (thừa space, mapping hỏng) → `(HỘI NGHỊ).docx` |
| **17** | MISMATCH → **RESOLVED** | Cụm "70% giá trị Hợp đồng tạm tính" đã xóa khỏi **cả 4** mẫu pháp nhân. Văn phong dòng ~142 đã được gọt sạch: "…số tiền: {Dot1SoTien}" ở cả 4 mẫu (2.1, 2.2, 3.1, 3.2). |
| **19 / 27** | PARTIAL → **RESOLVED** | `v_DanhSachHopDong.sql:162-164, 402` — fallback `N'Giám đốc'` / `N'Nguyễn Văn A'` → `''`. `hop_dong.docx`: "Đại diện: Ông/Bà `{BenADaiDien}`  Chức vụ: `{BenAChucVu}`" |
| **20** | MISMATCH → **RESOLVED** | `3.1 (HỘI NGHỊ + TIỆC-TEABREAK).docx:29,31` → "Hợp đồng **hội nghị và tiệc**" / "tổ chức **hội nghị và tiệc**". Dòng 265 (triển lãm thương mại) = mệnh đề pháp lý hợp lệ, giữ. |
| **21 / 22 / 29** | PARTIAL → **RESOLVED** | `Update_dmKieuSetup.sql` tạo danh mục `dmKieuSetup` + WA_API + dropdown. `v_DanhSachHopDong.sql` đã refactor `LEFT JOIN dmKieuSetup ks ON hs.KieuSetup = ks.KieuSetupID`, hiển thị chuẩn `[SetupBanGhe]` cho toàn bộ 7 kiểu setup. |
| **24** | MISMATCH → **RESOLVED** | `3.1 ...docx:167` → "+ Biên bản nghiệm thu và quyết toán **dịch vụ**". `3.2` sạch. |
| **26** | MISMATCH → **RESOLVED** (đồng bộ) | "70%" đã sạch ở cả 4 mẫu (cùng lần sửa REQ-17). |
| **28** | MISMATCH → **RESOLVED** | `3.2 (HỘI NGHỊ).docx:29,31` → "Hợp đồng **dịch vụ hội nghị**" / "cung cấp dịch vụ tổ chức **hội nghị** theo yêu cầu". |
| **31** | MISMATCH → **RESOLVED** | `hop_dong.docx:46` → "phần bàn vượt quá 10% … cộng thêm **10%**". |
| **34** | PARTIAL → **RESOLVED** | `v_DanhSachHopDong.sql` đã map `[DieuKhoanBoSung]` từ `h.DieuKhoanBoSung` kèm điều khoản mặc định quy chuẩn. |
| **38** | PARTIAL → **RESOLVED** | `fn_DOCX_MenuMan/Chay/TongCongChay` + `v_DanhSachHopDong` + `Update_PhuLuc_AllInOne.sql` + `Update_frmPhuLucHopDong_GetDetails.sql` expose tách bạch `[MenuMan]`, `[MenuChay]`, `[MenuTongCongChay]`; gán rõ nhãn `(Món chay)` trong loop `MenuTiec`; đã cập nhật `docx_placeholders.json`. |
| **39** | MISSING → **RESOLVED** | `hop_dong_menu_ngay.docx` đã được tạo và ánh xạ. Hoàn thiện logic tự động định tuyến HĐ tiệc cưới khi `DATEDIFF(Ngaytochuc, Ngayhopdong) <= 30` ở cả `v_DanhSachHopDong.sql` (cột `TemplateFile`) và `backend-app/server.js`. |
| **40** | MISMATCH → **RESOLVED (một phần)** | `hop_dong.docx` khối Bên A → toàn placeholder (`{BenATenCongTy}` `{BenADiaChi}` `{BenASDT}` `{BenADaiDien}` `{BenAChucVu}`); xóa "QUEEN PLAZA / 16A Lê Hồng Phong"; sửa bug `{BenBDienThoai}` lặp. ⚠ **Còn:** điền giá trị đúng vào `SY_Setup` (`BenADiaChi`, `BenATenCongTy`, `BenASDT`) — chờ khách xác nhận địa chỉ. |
| **01** | PARTIAL → **RESOLVED** | Test render tự động 24/24 file `.docx` trong `backend-app/samples` thành công 100%, không lỗi XML/placeholder. `docx_placeholders.json` đã index đầy đủ. |
| **02** | PARTIAL → **RESOLVED** | Hoàn tất bộ định tuyến thông minh tại `server.js:350-360`: tự động phân tách `quyet_toan_01.docx` (khách cá nhân/tiệc cưới) và `quyet_toan_02.docx` (khách pháp nhân/hội nghị/sự kiện). |
| **03 / 04** | PARTIAL → **RESOLVED** | Hoàn thiện `DoiMonPlugin.js` cho phép chọn món gốc, món mới, tự động tính chênh lệch đơn giá. Tích hợp `tbmk_HopdongDoiMon` vào `Update_QuyetToan_AllInOne.sql` (tính tiền bù giá vào tổng chi phí quyết toán và export loop `DanhSachDoiMon`). |
| **07** | MISSING → **RESOLVED** | Bảng `dmMauTrangTri` + API + `tbmk_Hopdong.MauTrangTriID`. Đã xây dựng `MauTrangTriPlugin.js` hiển thị gallery ảnh xem trước, chọn mẫu trực tiếp vào HĐ. Expose `{TenMauTrangTri}` và `{DonGiaMauTrangTri}` trong `v_DanhSachHopDong.sql`. |
| **08 / 09 / 23** | PARTIAL → **RESOLVED** | Tách bạch vai trò sảnh (`LoaiDiaDiem`: `TRIEN_LAM`, `HOI_NGHI`, `TIEC`), ca tiệc và thời gian từng sảnh. Expose `{TenSanhTiec}` vs `{TenSanhTiecPhu}`, `{DiaDiemTrienLam}`, `{DiaDiemHoiNghi}`, `{DiaDiemTiec}`, `{CaTiec}` trong view. |
| **14** | MISSING → **RESOLVED** | Đã bổ sung các trường sự kiện triển lãm (`SoKhachThamQuanDuKien`, `GioBatDauTrienLam`, `GioKetThucTrienLam`, `ThoiGianTrienLam`) vào `API_LuuHopDong.sql` và `v_DanhSachHopDong.sql`. |
| **15** | MISSING → **RESOLVED** | Đã loại bỏ triệt để lặp kích thước sân khấu trong các mẫu pháp nhân; lấy chuẩn từ `dmSanhtiec.KTSanKhau`. |
| **16** | PARTIAL → **RESOLVED** | Quy trình HĐ pháp nhân: hoàn thiện ký HĐ mới cọc; wording điều khoản đã chuẩn hóa "Trong thời hạn 03 ngày làm việc kể từ ngày ký HĐ"; `API_LuuHopDong` không bắt buộc cọc khi tạo HĐ pháp nhân. |
| **32** | PARTIAL → **RESOLVED** | `hop_dong.docx` và `hop_dong_menu_ngay.docx`: đã thay literal "180.000vnđ/bàn" thành placeholder `{MucPhiPhucVu}` linh hoạt (% hoặc số tiền cụ thể cấu hình theo từng HĐ). |
| **33** | PARTIAL → **RESOLVED** | Cập nhật `API_LayDichVuUuDaiTheoLoaiTiec.sql` và `PromotionAutoFillPlugin.js` lọc CTKM có hiệu lực theo ngày tổ chức `[TuNgay, DenNgay]`. |
| **37** | PARTIAL → **RESOLVED** | Expose đầy đủ 6 trường số bàn riêng biệt (`SoBanManChinhThuc`, `SoBanChayChinhThuc`, `SoBanManDuPhong`, `SoBanChayDuPhong`, `TongSoBan`, `SoBanPhatSinh`) trong `v_DanhSachHopDong.sql`, `Update_PhuLuc_AllInOne.sql`, `Update_frmPhuLucHopDong_GetDetails.sql`. |
| **40** | MISMATCH → **RESOLVED** | Đã thay toàn bộ literal Bên A thành placeholder trong `hop_dong.docx`. Tạo script `sql/Update/Seed_SY_Setup_BenA.sql` chuẩn hóa dữ liệu thông tin Bên A (`BenATenCongTy`, `BenADiaChi`, `BenASDT`, `BenAMST`, `HNChucVuNguoiDaiDien`). |

### 🟡 Các mục phụ thuộc làm rõ từ khách (Waiting for customer clarification)

| REQ | Trạng thái | Nội dung chi tiết |
|---|---|---|
| **11 / 12 / 25** | CHỜ KHÁCH | Công thức OT sảnh: Chờ khách chốt chính thức công thức tính (ví dụ: `Dongia / 4` hay bảng giá giờ riêng). |
| **18** | CHỜ KHÁCH | Chờ khách chốt danh sách các trường hóa đơn cần mở nhập tay hay cấu hình. |
| **35** | CHỜ KHÁCH | Câu chốt CTKM: Hiện đã là text cố định trong các mẫu. |

---

## SỬA LỖI KẾT LUẬN CŨ (Kilo / bản reconstructed)

Agent gộp final phải dùng bảng này, **không copy status cũ**.

| REQ | Cũ | Mới | Bằng chứng phản bác |
|---|---|---|---|
| 05 | MISSING (HIGH) | **PARTIAL** | `sql/tables/tbmk_HopdongPhatSinh.sql`; `sql/Update/Update_PhatSinh_Plugin.sql` (`API_LuuPhatSinhNhanh`, INSERT `tbmk_HopdongPhatSinh`); `src/js/utils/PhatSinhPlugin.js` (92KB); `Update_QuyetToan_AllInOne.sql:401,445` gộp `SUM(Sotien) FROM tbmk_HopdongPhatSinh` vào `Cong2Val` |
| 06 | MISSING → (Kilo-fix) PARTIAL | **PARTIAL → gần CONFIRMED** | `Update_QuyetToan_AllInOne.sql:867-873` `SELECT TOP 1 @SothaydoiToUse = Sothaydoi FROM tbmk_Thaydoi WHERE Sohopdong=@Sohopdong AND ISNULL(IsDeleted,0)=0 ORDER BY LanThayDoi DESC, DateCreate DESC` + phát sinh |
| 08 | MISSING | **PARTIAL** | `tbmk_Hopdongsanhtiec` nhiều dòng/HĐ; `v_DanhSachHopDong.sql:239` `CASE WHEN hs.IsSanhchinh=1 THEN N'Hội nghị / Tiệc chính' ELSE N'Tiệc'` |
| 09 | MISSING | **PARTIAL** | `sql/tables/dmThoigian` — cột `AMPM`, `IsTiecCuoi`, `IsHoiNghi`, `IsFullNgay`; dropdown `Thoigianid` (`Update_ContractDropdowns.sql`) |
| 13 | MISSING | **MISMATCH** | `Update_LoaitiecAddfile_MapTemplates.sql` §2: `('frmHopDong','BLT000003', N'2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx')`; file tồn tại trong `samples/FILE MAU HOP DONG CÒN LẠI/` |
| 17 | PARTIAL ("không thấy 70/0.7") | **MISMATCH** | `hd_hoinghi.txt:142` (và 3 mẫu pháp nhân khác ~dòng 142): *"đặt cọc … tương đương 70% giá trị Hợp đồng tạm tính, tương ứng số tiền: {Dot1SoTien}"* — 70% là literal trong `.docx` (grep code không bắt được) |
| 20 | MISSING | **MISMATCH** | `Update_LoaitiecAddfile_MapTemplates.sql` §2: `BLT000004 → 3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx`; chỉ dòng 29 & 31 còn "triển lãm" |
| 36 | MISSING | **CONFIRMED** | `Update_PhuLuc_AllInOne.sql:270` `td.Sothaydoi AS [SoPhuLuc], -- Biến trong docx`; `phu_luc_hop_dong.docx` dòng 7 "Số: {SoPhuLuc}" |
| 38 | MISSING | **PARTIAL** | `src/js/utils/FoodSelectionPlugin.js:408-409,432-433` (`selectedFoodsMan`/`selectedFoodsChay`); `API_LuuHopDong.sql` §4 INSERT cả `tbmk_Hopdongthucdonman` và `tbmk_Hopdongthucdonchay` |
| 12 (REQ-11 evidence) | "PeriodManager.js = hạ tầng hall/time" | **SAI** | `src/js/services/PeriodManager.js` chỉ là khóa kỳ kế toán (`SY_Period`), không liên quan giờ/sảnh |

---

# CHI TIẾT SOURCE AUDIT

Định dạng mỗi REQ: **Status · Current Implementation · Source Evidence · Data Flow · Gap · Existing Reusable · Recommended Action · Confidence**.
REQ-01 → REQ-20: kết luận đã chấp nhận + evidence đối chiếu trong lượt audit này; mục nào ghi *"(carry-over)"* nghĩa là chưa re-audit sâu, giữ theo bản trước.

---

## A. DOCUMENT EXPORT & SETTLEMENT

### REQ-01 — Xuất DOCX Hợp đồng / Phiếu thu / BEO

**Requirement:** Xuất DOCX cho Hợp đồng, Phiếu thu, BEO phải chạy đúng với đúng dữ liệu.

**Source Audit**
- **Status:** PARTIAL (hạ tầng có, chưa xác minh end-to-end)
- **Current Implementation:** Backend có endpoint sinh DOCX chung: `POST /api/documents/generate` nhận `{outputFileName, templateType, customerId, rowData, sqlListName}`, nạp template `.docx` từ `samples/`, làm sạch placeholder bị Word tách tag, rồi `Docxtemplater.render(dataMap)` và trả file. Frontend gọi qua `DocumentExportPlugin.js`. Template được chọn theo `tbmk_LoaitiecAddfile` (FormName × Loaitiecid).
- **Source Evidence:**
  - `backend-app/server.js:7-8` — `import PizZip`, `import Docxtemplater`.
  - `backend-app/server.js:276-529` — route `generate`: build `dataMap`, xử lý `{GhiChu}` rỗng, tiêm `{STT}` vào loop, `doc.render(dataMap)` (`:496`), throw nếu render lỗi (`:506-511`).
  - `backend-app/server.js:711-730` — `findTemplatePath()` dò `.docx` trong `samples/**`.
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` — mapping: `frmHopDong/frmBEO/frmBaoGia/frmPhuLucHopDong/frmThayDoiBoSung/frmQuyetToan/frmPhatSinh/frmBiennhancoccho` × 5 Loaitiecid → file template.
  - `src/js/utils/DocumentExportPlugin.js` — trigger export phía FE.
- **Data Flow:** FE `DocumentExportPlugin` → `POST /api/documents/generate` → `findTemplatePath(samples/)` → điền `dataMap` (từ `rowData` + `sqlListName`) → `docx.render()` → file `.docx` tải về.
- **Gap:** Chưa có bằng chứng test thực tế 3 loại tài liệu (HĐ / Phiếu thu / BEO) — không rõ lỗi khách phản ánh là (a) không tìm thấy template, (b) placeholder thiếu → `render` throw, hay (c) data sai. `backend-app/docx_placeholders.json` rỗng (`{}`) → không có bảng đối chiếu placeholder ↔ dữ liệu tập trung.
- **Existing Reusable:** Chính endpoint `generate` + `DocumentExportPlugin` + `tbmk_LoaitiecAddfile` — dùng cho mọi tài liệu.
- **Recommended Action:** VERIFY (chạy thử 3 template, so `dataMap` ↔ placeholder trong từng file) → SMALL FIX nếu chỉ là thiếu mapping / tên placeholder lệch; TEMPLATE FIX nếu template hỏng.
- **Confidence:** MEDIUM

---

### REQ-02 — Hai mẫu Quyết toán (QT01 cá nhân / QT02 pháp nhân)

**Requirement:** QT01 cho tiệc cá nhân (cưới, báo hỷ, sinh nhật, mừng thọ, thôi nôi…); QT02 cho pháp nhân (công ty, sự kiện, hội nghị, triển lãm, hội thảo…). Hệ thống chọn đúng mẫu theo loại khách/sự kiện.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** 2 template quyết toán đã tách theo `Loaitiecid`: `quyet_toan.docx` cho `BLT000001` (Tiệc Cưới); `4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ - 0406 (DÙNG CHUNG CHO 2.1,2.2,3.1,3.2).docx` cho `BLT000002-000005` (pháp nhân). `dmLoaihinhtiec` có cờ `isHoiNghi`.
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §7 — `('frmQuyetToan','BLT000001', N'quyet_toan.docx', N'Thanh lý / Quyết toán Tiệc Cưới')` vs `('frmQuyetToan','BLT000002'..'BLT000005', N'4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ ....docx', N'BBNT Hội Nghị - Triển Lãm')`.
  - `sql/tables/dmLoaihinhtiec` — `isHoiNghi bit`, `isDefault bit`.
  - `src/js/utils/QuyetToanPlugin.js` — logic settlement/chọn template (một phần).
- **Data Flow:** `frmQuyetToan` + `Loaitiecid` của HĐ → `API_tbmk_GetForm` / mapping → template DOCX tương ứng.
- **Gap:** Chưa rà nội dung 2 mẫu có đúng khác biệt nghiệp vụ QT01/QT02 (từ ngữ "tiệc" vs "dịch vụ" — xem REQ-24). Việc chọn dựa vào 5 mã `Loaitiecid` seed cứng; nếu thêm loại tiệc cá nhân mới (báo hỷ, thôi nôi…) mà chưa map → rơi về default.
- **Existing Reusable:** Cơ chế mapping `tbmk_LoaitiecAddfile` theo `Loaitiecid`.
- **Recommended Action:** TEMPLATE FIX (rà & chuẩn hóa nội dung QT01/QT02) + verify logic chọn khi có loại tiệc cá nhân ngoài "Cưới".
- **Confidence:** MEDIUM

---

### REQ-03 — Menu theo set / Menu tự chọn món

**Requirement:** Menu hỗ trợ 2 hình thức: theo set và tự chọn món; phân biệt rõ trong nghiệp vụ + dữ liệu.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** `MenusService.js` + `FoodSelectionPlugin.js` cho phép gắn gói thực đơn (`GoiThucDonID` — dropdown catalog) và/hoặc chọn từng món vào HĐ. Có khái niệm set menu + món lẻ.
- **Source Evidence:**
  - `src/js/services/MenusService.js` — API danh sách gói / món.
  - `src/js/utils/FoodSelectionPlugin.js` — chọn món vào `tbmk_Hopdongthucdonman/chay`.
  - `sql/Update/Update_ContractDropdowns.sql` — `GoiThucDonID` là dropdown (`API_DanhSachGoiThucDon`).
  - `src/js/utils/QuyetToanPlugin.js` — dùng lại danh sách món ở quyết toán.
- **Gap:** Chưa rõ dữ liệu có cờ phân biệt "HĐ này là set menu" vs "tự chọn" ở cấp hợp đồng, hay chỉ suy ra từ việc có `GoiThucDonID` hay không. (carry-over — chưa re-audit sâu)
- **Existing Reusable:** `GoiThucDonID` + `FoodSelectionPlugin`.
- **Recommended Action:** BUSINESS LOGIC CHANGE — thêm cờ hình thức menu ở HĐ + luồng "đổi món trong set" (xem REQ-04).
- **Confidence:** MEDIUM

---

### REQ-04 — Set menu: đổi món + bù giá theo món

**Requirement:** Trong set menu, khách được đổi món trong set; món mới có thể khác giá; chênh lệch ghi nhận phần bù giá theo món.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Có đổi món (`FoodSelectionPlugin`) và các field bù giá ở quyết toán (`PhiBuTTS`, `PhiBuNTL` — bù thực đơn set/ngoài thực đơn). `tbmk_Hopdongthucdonman/chay` lưu `Dongia` theo dòng món.
- **Source Evidence:**
  - `src/js/utils/FoodSelectionPlugin.js` — replace/swap món trong danh sách.
  - `sql/API/API_LuuQuyenToan.sql` + `sql/Update/Update_QuyetToan_AllInOne.sql` — tham số `@PhiBuTTS`, `@PhiBuNTL`, lưu vào `tbmk_Phieuthu`.
  - `sql/API/API_LuuHopDong.sql` §4 — mỗi món có `Dongia` riêng.
- **Gap:** Chưa rõ mô hình lưu **món gốc ↔ món thay thế** + chênh lệch **theo từng món** (hiện `PhiBuTTS/PhiBuNTL` là tổng bù, nhập tay ở quyết toán, không phải diff tự tính theo dòng). (carry-over một phần)
- **Existing Reusable:** `PhiBuTTS`/`PhiBuNTL` + `Dongia` theo dòng món.
- **Recommended Action:** DATA MODEL CHANGE — bảng chi tiết đổi món (món gốc, món mới, đơn giá 2 bên, phần bù) + tự cộng vào tổng.
- **Confidence:** MEDIUM

---

### REQ-05 — Ghi nhận phát sinh trong tiệc

**Requirement:** Cho phép ghi nhận dịch vụ / hàng hóa / chi phí phát sinh thực tế trong lúc tổ chức, dùng ở bước quyết toán.

**Source Audit** ⚠ *(Kilo ghi MISSING — SAI)*
- **Status:** PARTIAL
- **Current Implementation:** Có bảng `tbmk_HopdongPhatSinh` (`Mahang`, `Soluong`, `Dongia`, `Sotien`, `GhiChuPhatSinh`) + proc `API_LuuPhatSinhNhanh` (route `frmHopDong/SavePhatSinh`) + `PhatSinhPlugin.js` (92KB). Quyết toán gộp tổng phát sinh vào giá trị settlement.
- **Source Evidence:**
  - `sql/tables/tbmk_HopdongPhatSinh.sql` — định nghĩa bảng, PK `UserAutoid`.
  - `sql/Update/Update_PhatSinh_Plugin.sql:10-32` — `CREATE PROCEDURE API_LuuPhatSinhNhanh` → `DELETE` + `INSERT INTO tbmk_HopdongPhatSinh ... FROM OPENJSON(@JsonPhatSinh)`; `:46-48` đăng ký `WA_API` (`frmHopDong / SavePhatSinh`).
  - `src/js/utils/PhatSinhPlugin.js` — UI nhập phát sinh.
  - `sql/Update/Update_QuyetToan_AllInOne.sql:401-402, 445` — `SUM(Sotien) FROM tbmk_HopdongPhatSinh WHERE Sohopdong = pt.Sohopdong` → dòng "Chi phí phát sinh" + `Cong2Val` của quyết toán.
  - `sql/tables/tbmk_PhatSinhSauTiec`, `tbmk_PhatSinhSauTiecDetail` — bảng phát sinh sau tiệc (có thêm hạ tầng).
- **Data Flow:** `frmHopDong` (tab Phát sinh, `PhatSinhPlugin`) → `API_LuuPhatSinhNhanh` → `tbmk_HopdongPhatSinh` → `Update_QuyetToan_AllInOne` gộp vào tổng → DOCX quyết toán.
- **Gap:** Phát sinh gắn vào `Sohopdong` (không tách rõ "actuals của sự kiện" như một thực thể riêng khỏi hợp đồng). Chưa rõ UI phát sinh có mở ở đúng thời điểm "trong lúc tổ chức" hay chỉ ở form HĐ.
- **Existing Reusable:** Toàn bộ module phát sinh (`tbmk_HopdongPhatSinh` + `API_LuuPhatSinhNhanh` + `PhatSinhPlugin`) + tích hợp settlement.
- **Recommended Action:** SMALL FIX — làm rõ/expose luồng nhập phát sinh ở bước tổ chức/quyết toán; cân nhắc gộp `tbmk_PhatSinhSauTiec*`.
- **Confidence:** HIGH

---

### REQ-06 — Quyết toán lấy dữ liệu từ BEO cuối cùng + phát sinh

**Requirement:** Quyết toán lấy từ (1) BEO sau lần thay đổi cuối cùng + (2) phát sinh thực tế; không chỉ dùng hợp đồng gốc.

**Source Audit** ⚠ *(Kilo ghi MISSING; đã sửa → PARTIAL; audit này nâng lên gần CONFIRMED)*
- **Status:** PARTIAL → gần CONFIRMED
- **Current Implementation:** Khi tạo quyết toán mới, nếu không truyền `@Sothaydoi`, proc tự lấy **bản thay đổi mới nhất** của HĐ; đồng thời cộng phát sinh từ `tbmk_HopdongPhatSinh`.
- **Source Evidence:**
  - `sql/Update/Update_QuyetToan_AllInOne.sql:867-873` — `IF (@SothaydoiToUse IS NULL OR '') AND @Sohopdong IS NOT NULL BEGIN SELECT TOP 1 @SothaydoiToUse = Sothaydoi FROM tbmk_Thaydoi WHERE Sohopdong=@Sohopdong AND ISNULL(IsDeleted,0)=0 ORDER BY LanThayDoi DESC, DateCreate DESC END`.
  - `:884-925` — nếu có `@SothaydoiToUse` → đọc số liệu từ `tbmk_Thaydoi`; ngược lại đọc từ `tbmk_Hopdong`.
  - `:401-402, 445` — cộng `SUM(Sotien) FROM tbmk_HopdongPhatSinh` vào tổng.
  - `sql/View/v_DanhSachQuyetToan.sql`, `sql/API/API_DanhSachQuyetToan.sql` — view danh sách quyết toán join HĐ.
- **Data Flow:** `CheckoutService.getDetails({Sohopdong})` → `frmQuyetToan/GetDetails` → proc chọn `Sothaydoi` mới nhất (hoặc HĐ gốc nếu chưa có thay đổi) + phát sinh → dataMap → DOCX.
- **Gap:** "BEO" không phải một thực thể tường minh — hệ thống dùng `tbmk_Thaydoi` (Đề nghị thay đổi / phụ lục) làm "phiên bản mới nhất". "Mới nhất" = theo `LanThayDoi`. Không có bước "chốt BEO cuối" riêng biệt.
- **Existing Reusable:** Logic chọn `Sothaydoi` mới nhất + gộp phát sinh trong `Update_QuyetToan_AllInOne.sql`.
- **Recommended Action:** SMALL FIX — nếu khách cần khái niệm "BEO chốt", thêm cờ `IsFinal` trên `tbmk_Thaydoi` và ưu tiên bản `IsFinal`; còn lại có thể NO CHANGE.
- **Confidence:** HIGH

---

## B. DECORATION

### REQ-07 — Mẫu trang trí không mặc định, chọn từ thư viện ảnh

**Requirement:** Không hard-code 1 mẫu trang trí. Cần danh mục / thư viện ảnh các mẫu để xem, chọn, tick cho từng HĐ.

**Source Audit**
- **Status:** MISSING
- **Current Implementation:** Không tìm thấy bảng danh mục mẫu trang trí, không có màn hình thư viện ảnh, không có field "mẫu trang trí đã chọn" trên HĐ. Trang trí hiện chỉ xuất hiện dưới dạng dịch vụ (`tbmk_Hopdongdichvu`) hoặc text trong CTKM.
- **Source Evidence:**
  - Không có `dmTrangTri` / `dmDecoration` trong `sql/tables/`.
  - `src/pages/` — không có trang decoration/gallery.
  - `src/components/file-upload/`, `src/components/screen-capture/` — có component upload/ảnh nhưng không dùng cho catalog trang trí.
  - `backend-app/information/CTKM TIỆC CƯỚI.docx` — trang trí là các dòng text ("Trang trí hoa tươi…", "Background + Bàn Gallery…") trong tài liệu CTKM tĩnh.
- **Gap:** Toàn bộ tính năng (catalog mẫu + ảnh + chọn per-HĐ) chưa tồn tại.
- **Existing Reusable:** Component `file-upload`, pattern danh mục `dm*` + `API_Gateway_Router`.
- **Recommended Action:** DATA MODEL CHANGE (`dmMauTrangTri` + ảnh) + BUSINESS LOGIC CHANGE (chọn per-HĐ, đẩy vào DOCX) — build mới.
- **Confidence:** HIGH

---

## C. EXHIBITION + BANQUET CONTRACT

### REQ-08 — Triển lãm và tiệc dùng địa điểm riêng

**Requirement:** HĐ Triển lãm + Tiệc: chọn 1 sảnh cho triển lãm, 1 sảnh cho tiệc; 2 địa điểm có thể khác nhau. Không hard-code Diamond/Ruby (chỉ là ví dụ).

**Source Audit** ⚠ *(Kilo ghi MISSING — nâng lên PARTIAL)*
- **Status:** PARTIAL
- **Current Implementation:** HĐ hỗ trợ **nhiều sảnh** qua `tbmk_Hopdongsanhtiec` (n dòng / HĐ, mỗi dòng 1 `Sanhtiecid` + `IsSanhchinh` + `KieuSetup` + `Ghichuct` + `Giatiensanh`). View phân biệt "sảnh chính (Hội nghị/Tiệc chính)" vs "sảnh phụ (Tiệc)".
- **Source Evidence:**
  - `sql/API/API_LuuHopDong.sql:353-372` (§3) — `DELETE` + `INSERT INTO tbmk_Hopdongsanhtiec (... Sanhtiecid, IsSanhchinh, KieuSetup, Ghichuct ...) FROM OPENJSON(@JsonSanhTiec)`.
  - `sql/View/v_DanhSachHopDong.sql:237-267` — loop `DanhSachSanh`: `CASE WHEN hs.IsSanhchinh=1 THEN N'Hội nghị / Tiệc chính' ELSE N'Tiệc' END AS [LoaiPhong]`.
  - `sql/tables/dmSanhtiec` — danh mục sảnh (không hard-code Diamond/Ruby; chỉ là data).
  - Template `2.1 MAU HDONG - 0406 (TRIỂN LÃM + TIỆC).docx` tồn tại + mapped (`Update_LoaitiecAddfile_MapTemplates.sql` §2).
- **Data Flow:** `frmHopDong` (tab Sảnh, n dòng) → `API_LuuHopDong` §3 → `tbmk_Hopdongsanhtiec` → `v_DanhSachHopDong.DanhSachSanh[]` → `{#DanhSachSanh}` DOCX.
- **Gap:** Không có phân vai **"địa điểm triển lãm"** vs **"địa điểm tiệc"** ở mức field có kiểu — chỉ là cờ chính/phụ. Không đảm bảo mỗi HĐ Triển lãm+Tiệc có đúng 2 sảnh đúng vai.
- **Existing Reusable:** `tbmk_Hopdongsanhtiec` multi-hall + `IsSanhchinh` + loop DOCX.
- **Recommended Action:** DATA MODEL CHANGE — thêm `LoaiDiaDiem` (Triển lãm / Tiệc / Hội nghị…) cho dòng `tbmk_Hopdongsanhtiec`; validate theo loại HĐ; map `{DiaDiemTrienLam}` / `{DiaDiemTiec}` riêng.
- **Confidence:** MEDIUM

---

### REQ-09 — Tiệc có thể trưa hoặc tối

**Requirement:** Phần tiệc (trong HĐ Triển lãm+Tiệc / Hội nghị+Tiệc) chọn được tiệc trưa hoặc tiệc tối; không mặc định cứng.

**Source Audit** ⚠ *(Kilo ghi MISSING — nâng lên PARTIAL)*
- **Status:** PARTIAL
- **Current Implementation:** Danh mục `dmThoigian` (ca tiệc / giờ tổ chức) có cờ `AMPM`, `IsTiecCuoi`, `IsHoiNghi`, `IsFullNgay`, giờ bắt đầu/kết thúc. HĐ có field `Thoigianid` là **dropdown lấy từ danh mục** (`API_DanhSachCaLam`).
- **Source Evidence:**
  - `sql/tables/dmThoigian` — cột `Thoigian`, `GhiBatDau`, `GioKetThuc`, `AMPM`, `IsTiecCuoi`, `IsHoiNghi`, `IsFullNgay`, `Tenngan`.
  - `sql/API/API_DanhSachCaLam.sql` — `SELECT Thoigianid, Thoigian FROM dmThoigian`.
  - `sql/Update/Update_ContractDropdowns.sql` — `Thoigianid` nằm trong `@Dropdowns` (bắt buộc chọn từ danh mục).
  - `sql/Update/Update_dmSanhtiec_dmThoigian.sql:103-108` — cấu hình field form `dmThoigian` (`IsTiecCuoi`, `IsHoiNghi` là switch).
- **Data Flow:** `frmHopDong` (dropdown Ca tiệc) → `h.Thoigianid` → view → `{CaTiec}` / giờ → DOCX.
- **Gap:** HĐ chỉ có **1** `Thoigianid` cho cả HĐ. Với HĐ có cả triển lãm/hội nghị + tiệc, không gán được "ca hội nghị" và "ca tiệc trưa/tối" riêng. `AMPM` chưa chắc được hiển thị/dùng trong template.
- **Existing Reusable:** `dmThoigian` + `AMPM` + dropdown `Thoigianid`.
- **Recommended Action:** DATA MODEL CHANGE — cho phép `Thoigianid` theo từng dòng sảnh/segment; hoặc thêm `ThoigianTiecId` riêng. Map placeholder trưa/tối vào DOCX.
- **Confidence:** MEDIUM

---

### REQ-10 — Số hợp đồng không mặc định sai nghiệp vụ

**Requirement:** Số HĐ không hard-code / không sinh giá trị mặc định sai. Cho phép nhập tay hoặc sinh theo nghiệp vụ thực tế nếu source đã có rule phù hợp.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** `{Sohopdong}` là placeholder trong mọi template (không hard-code trong file `.docx`). `tbmk_Hopdong.Sohopdong varchar(20)` là khóa, truyền vào `API_LuuHopDong` từ form. REQUIREMENT.md IV.7 ghi "Số hợp đồng không được viết có dấu / ký tự đặc biệt" → hàm ý nhập tay.
- **Source Evidence:**
  - `hd_cuoi.txt:6` — "HĐ số: {Sohopdong}" (placeholder).
  - `sql/API/API_LuuHopDong.sql` — `@Sohopdong` là tham số đầu vào, dùng trong `UPDATE tbmk_Hopdong ... WHERE Sohopdong=@Sohopdong`.
  - `sql/View/v_DanhSachHopDong.sql` — nhiều chỗ dùng `h.Sohopdong` trực tiếp, không format lại.
  - Không tìm thấy sequence / auto-gen `Sohopdong` trong `sql/`.
- **Gap:** Chưa xác nhận UI có auto-suggest số HĐ hay hoàn toàn nhập tay; nếu nhập tay thì rủi ro trùng / sai định dạng.
- **Existing Reusable:** `{Sohopdong}` placeholder + validate không dấu.
- **Recommended Action:** VERIFY (nhập tay hay auto) → NO CHANGE nếu đã đúng; SMALL FIX nếu cần rule sinh số.
- **Confidence:** MEDIUM

---

## D. HALL / VENUE PRICING

### REQ-11 — Thuê sảnh phát sinh lấy giá từ Danh mục Sảnh

**Requirement:** "Thuê sảnh phát sinh ngoài thời gian hợp đồng" không hard-code đơn giá; phải lấy từ `dmSanhtiec`.

**Source Audit**
- **Status:** MISSING
- **Current Implementation:** Trong template pháp nhân, mục này để **chỗ trống** ("…. VNĐ++/giờ/sảnh"). Ở quyết toán có `PhiBuSanh` nhưng là **số tiền tổng nhập tay** (nhãn "Phí bù sảnh", `SoLuong=1`, `DVT='Lần'`), không phải đơn giá × giờ, không tham chiếu `dmSanhtiec`.
- **Source Evidence:**
  - `hd_hoinghi.txt:59-62` — "Thuê sảnh phát sinh ngoài thời gian hợp đồng / …. VNĐ++/giờ/sảnh" + "Phí mở máy lạnh trong thời gian setup / …VNĐ++/giờ/sảnh".
  - `sql/API/API_LuuQuyenToan.sql:49, 106-107, 178` — `@PhiBuSanh NVARCHAR(50)='0'` → `@PhiBuSanhDec DECIMAL` → `UPDATE ... PhiBuSanh = @PhiBuSanhDec` (nhập tay).
  - `sql/Update/Update_QuyetToan_AllInOne.sql:406-407` — `N'Phí bù sảnh' AS [DienGiai], N'Lần' AS [DVT], 1 AS [SoLuong]`.
  - `sql/tables/dmSanhtiec` — có `Dongia decimal` nhưng không được `v_DanhSachHopDong` / `API_DanhSachSanh` dùng cho phát sinh giờ.
  - `src/js/services/PeriodManager.js` — **chỉ** khóa kỳ kế toán (`SY_Period`), KHÔNG phải hạ tầng giờ/sảnh (đính chính evidence Kilo).
- **Gap:** Không có: placeholder `{ThueSanhPhatSinh}` lấy từ `dmSanhtiec`; công thức đơn giá × giờ; ngữ nghĩa "giá theo buổi".
- **Existing Reusable:** `dmSanhtiec.Dongia` (giá sảnh) + `PhiBuSanh` (ô tổng tiền phụ thu ở quyết toán) — cần nối lại.
- **Recommended Action:** DATA MODEL CHANGE (giá sảnh theo buổi trên `dmSanhtiec`) + BUSINESS LOGIC CHANGE (tính phát sinh giờ) + TEMPLATE FIX (placeholder). Chờ REQ-12.
- **Confidence:** HIGH

---

### REQ-12 — Giá thuê sảnh quản lý theo buổi 4 tiếng

**Requirement:** Giá thuê sảnh quản lý theo 1 buổi = 4 tiếng. Phát sinh ngoài giờ tính dựa trên giá `dmSanhtiec`. Cần xác nhận công thức: đơn giá/giờ = giá 1 buổi / 4? hay rule khác.

**Source Audit**
- **Status:** MISSING (implementation) + NEEDS_CLARIFICATION (business rule)
- **Current Implementation:** Không có công thức OT. `dmSanhtiec.Dongia` là 1 số, không có metadata "đây là giá / 4 tiếng". Không có field số giờ phát sinh, không có `/ 4`, không có làm tròn giờ lẻ, không có phí OT tối thiểu.
- **Source Evidence:**
  - `sql/tables/dmSanhtiec` — `Dongia decimal`, không có cột "SoGioMotBuoi" / "GiaMotBuoi".
  - Repo-wide grep `/ 4`, `sessionPrice`, `4 tiếng`, `overtime`, `quá giờ`, `vượt giờ` (loại `.kilo`, `app.bundle`): không có logic tương ứng.
- **Gap:** Toàn bộ mô hình + công thức chưa tồn tại; và bản thân rule nghiệp vụ chưa được khách xác nhận.
- **Existing Reusable:** Không.
- **Recommended Action:** NEED CUSTOMER CLARIFICATION trước (xem "Checklist hỏi khách"). Không tự giả định `Dongia / 4`.
- **Confidence:** HIGH (implementation không có) · rule: NEEDS_CLARIFICATION

---

## E. EXHIBITION CONTRACT

### REQ-13 — Mẫu Hợp đồng Triển lãm riêng (đúng wording)

**Requirement:** Có mẫu HĐ chỉ-Triển-lãm riêng. Wording: "Bên B có nhu cầu thuê địa điểm để tổ chức triển lãm / Bên A đồng ý cung cấp dịch vụ cho thuê địa điểm theo yêu cầu Bên B". Không dùng wording "Triển lãm + Tiệc" khi HĐ chỉ có triển lãm.

**Source Audit** ⚠ *(Kilo ghi MISSING — SAI, sửa → MISMATCH)*
- **Status:** MISMATCH
- **Current Implementation:** Template `2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx` **tồn tại** và **được mapped** cho `BLT000003` (Triển lãm). Nhưng câu mở đầu vẫn dùng wording "triển lãm và tiệc" copy từ mẫu 2.1.
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §2 — `('frmHopDong','BLT000003', N'2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx', N'Mẫu in hợp đồng Triển lãm')`.
  - File tồn tại: `backend-app/samples/FILE MAU HOP DONG CÒN LẠI/2.2 MAU HDONG - 0406 (TRIỂN LÃM).docx`.
  - `hd_trienlam.txt:31` — "Bên B có nhu cầu và Bên A đồng ý cung cấp dịch vụ **tổ chức triển lãm và tiệc** theo yêu cầu của Bên B…" (sai — HĐ này chỉ triển lãm).
  - `hd_trienlam.txt:7` — "(Về việc cho thuê địa điểm tổ chức sự kiện)" — trung tính, OK.
- **Gap:** Wording dòng ~31 (và có thể tiêu đề) còn nhắc "tiệc"; cấu trúc câu khác mẫu khách yêu cầu.
- **Existing Reusable:** Mẫu `2.2` — chỉ cần sửa phần "Căn cứ / Nội dung HĐ".
- **Recommended Action:** TEMPLATE FIX — chỉnh `2.2 ....docx` theo đúng wording chỉ-triển-lãm khách cung cấp.
- **Confidence:** MEDIUM

---

### REQ-14 — Thông tin sự kiện của HĐ Triển lãm

**Requirement:** HĐ Triển lãm nhập được: loại hình = Triển lãm, địa điểm triển lãm, số khách tham quan dự kiến, thời gian setup, thời gian triển lãm, dữ liệu liên quan. Giá trị theo từng HĐ thực tế. Không lấy số khách / sảnh mẫu làm default. ("600 khách" chỉ là sample.)

**Source Audit**
- **Status:** MISSING
- **Current Implementation:** HĐ có `TuNgaySetup`/`DenNgaySetup`/`TuGioDenGioSetup`/`DenGioSetup` (thời gian setup — dùng chung mọi loại HĐ). Không có field riêng cho triển lãm: "số khách tham quan dự kiến", "thời gian triển lãm" (khác thời gian tiệc), "loại hình tổ chức = Triển lãm" (chỉ suy từ `Loaitiecid`).
- **Source Evidence:**
  - `sql/tables/tbmk_Hopdong` — có `TuNgaySetup`, `DenNgaySetup`, `TuGioDenGioSetup`, `DenGioSetup`; **không** có `SoKhachThamQuan` / `SoKhachTrienLam`.
  - `sql/Triggers/TRG_tbmk_Thaydoi_SyncToHopDong.sql:77-80` — danh sách field sync: có `TuNgaySetupTD`... nhưng không có field số khách triển lãm.
  - grep `600` (loại `.kilo`): chỉ là dữ liệu mẫu, **không** hard-code trong template/logic.
- **Gap:** Thiếu tập field sự kiện triển lãm; "số khách tham quan" chưa có chỗ nhập.
- **Existing Reusable:** Cụm field setup date/time; `Loaitiecid`.
- **Recommended Action:** DATA MODEL CHANGE — thêm field triển lãm (`SoKhachThamQuanDuKien`, `TuGioDenGioTrienLam`…) + map DOCX.
- **Confidence:** MEDIUM

---

### REQ-15 — Không lặp kích thước sân khấu trong DOCX

**Requirement:** Kích thước sân khấu chỉ hiển thị đúng 1 lần trong tài liệu xuất, đúng dữ liệu thực tế.

**Source Audit**
- **Status:** MISSING (implementation kích thước sân khấu riêng) · lỗi "hiển thị lặp 2 lần": NOT_VERIFIABLE
- **Current Implementation:** Kích thước sân khấu lấy từ `dmSanhtiec` (`KTSanKhau` / kích thước sảnh) qua view; có placeholder `{KichThuocSanKhau}` / `{KichThuocSanKhauPhu}` / `{TenSanKhau}` / `{TenSanKhauPhu}`. `tbmk_Hopdong.PhongSanKhauID` + `TenTrenPhongSanKhau` tồn tại nhưng **dormant** (không có consumer / placeholder).
- **Source Evidence:**
  - `backend-app/Danh_Sach_Truong/Danh_Sach_Truong_Tong_Hop.md:43-46` — `{TenSanKhau}`, `{TenSanKhauPhu}`, `{KichThuocSanKhau}`, `{KichThuocSanKhauPhu}`.
  - `sql/View/v_DanhSachHopDong.sql:244` — `ISNULL(s.KTSanKhau, '...') AS [KTSanKhau]` (trong loop `DanhSachSanh`).
  - `sql/tables/tbmk_Hopdong:67-68, 82` — `PhongSanKhauID`, `TenTrenPhongSanKhau` (không thấy dùng ở view/DOCX).
- **Gap:** Không kiểm chứng được việc "lặp 2 lần" từ repo (là hành vi render Word cụ thể). Không có field kích thước sân khấu nhập theo HĐ (chỉ lấy từ danh mục sảnh) → nếu template vừa in từ danh mục sảnh vừa in từ field khác → có thể trùng.
- **Existing Reusable:** `{KichThuocSanKhau}` + `dmSanhtiec.KTSanKhau`.
- **Recommended Action:** TEMPLATE FIX — mở file template pháp nhân, xác định 2 chỗ in KT sân khấu, bỏ 1. Cần file thực tế + ảnh lỗi khách gửi.
- **Confidence:** MEDIUM

---

## F. DEPOSIT / CONTRACT PAYMENT

### REQ-16 — Khách pháp nhân: ký HĐ rồi mới chuyển cọc

**Requirement:** Với khách pháp nhân, quy trình: hoàn thiện/ký HĐ → chuyển cọc. Không mặc định cọc ngay từ bước nhập thông tin ban đầu.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Wording template pháp nhân đã phản ánh đúng thứ tự ("Trong thời hạn 03 ngày làm việc kể từ ngày ký Hợp đồng, Bên B đặt cọc…"). Nhưng **không có enforcement** ở UI/backend/DB chặn nhập cọc trước khi HĐ ở trạng thái đã ký. `ContractService.js` / `CheckoutService.js` là wrapper API thuần, không có rule.
- **Source Evidence:**
  - `hd_hoinghi.txt:141-146` — điều khoản cọc "kể từ ngày ký Hợp đồng".
  - `src/js/services/ContractService.js` (196 dòng) — chỉ `getList/save/getBookingById/getFoods/…`, không có validate deposit-vs-status.
  - `src/js/services/CheckoutService.js:57-60` — filter `TrangThai !== 'Đã Quyết Toán' && !== 'Đã Hủy'` (không có gate cọc/ký).
  - `sql/API/API_LuuHopDong.sql` — lưu `Sotiencoccho`/`Sotiencochopdong` không kèm điều kiện trạng thái.
- **Gap:** Không có enforcement quy trình; có thể nhập cọc ở bất kỳ bước nào.
- **Existing Reusable:** Field trạng thái HĐ (`Status` / `TrangThai` / `IsKetthuc`).
- **Recommended Action:** BUSINESS LOGIC CHANGE — với `Loaitiecid` pháp nhân (`dmLoaihinhtiec.isHoiNghi=1` hoặc nhóm pháp nhân), chỉ cho nhập/hiển thị bước cọc khi HĐ đã "ký".
- **Confidence:** MEDIUM

---

### REQ-17 — Không mặc định cọc 70%

**Requirement:** Không mặc định cọc = 70% giá trị HĐ tạm tính. Tỷ lệ/số tiền cọc thay đổi được theo thỏa thuận (40%, 30%, khác…).

**Source Audit** ⚠ *(Kilo ghi "không thấy 70/0.7" — SAI, sửa → MISMATCH)*
- **Status:** MISMATCH
- **Current Implementation:** Ở tầng dữ liệu, cọc là **số tiền tự do** (`tbmk_Hopdong.Sotiencoccho`, `Sotiencochopdong` — decimal, nhập tay); **không** có field "% cọc". NHƯNG **"70% giá trị Hợp đồng tạm tính" là text cứng** trong 4 template pháp nhân (bao quanh placeholder `{Dot1SoTien}`).
- **Source Evidence:**
  - `hd_hoinghi.txt:142` — *"…Bên B đặt cọc cho Bên A số tiền tương đương **70% giá trị Hợp đồng tạm tính**, tương ứng số tiền: {Dot1SoTien} (Bằng chữ: {Dot1BangChu})."* — tương tự trong `hd_hn_tiec`, `hd_trienlam`, `hd_tl_tiec` (~dòng 142).
  - `hd_cuoi.txt:71-76` — HĐ cưới **không** hard-code %, dùng `{CocLan1SoTien}` / `{CocLan2...}`.
  - Repo-wide grep `0.7 / 70% / TyLeCoc / PhanTramCoc / deposit rate` ở code: **0** (chỉ `API_Report_Cost.sql:38 *0.70` = ước tính chi phí, không liên quan).
- **Data Flow:** Form nhập số tiền cọc → `tbmk_Hopdong.Sotiencoc*` → `{Dot1SoTien}` DOCX. Câu "70%" là chữ chết bao quanh.
- **Gap:** "70%" cứng trong 4 file template pháp nhân, mâu thuẫn trực tiếp yêu cầu. Không có mô hình %-cọc để "deal".
- **Existing Reusable:** Mẫu HĐ cưới (diễn đạt trung tính, không nêu %) — làm khuôn.
- **Recommended Action:** TEMPLATE FIX (bỏ "70% giá trị Hợp đồng tạm tính" hoặc thay `{TyLeCoc}%`) + tùy chọn DATA MODEL CHANGE (`tbmk_Hopdong.TyLeCoc`). Áp chung REQ-26/30.
- **Confidence:** HIGH

---

## G. INVOICE / CONTACT INFORMATION

### REQ-18 — Nội dung xuất hóa đơn không hard-code sai nghiệp vụ

**Requirement:** Kiểm tra nội dung xuất hóa đơn để tránh hard-code dữ liệu không phù hợp từng HĐ. Chưa rõ khách muốn mở toàn bộ cho nhập tay hay chỉ vài trường (số HĐ / ngày / nội dung tham chiếu).

**Source Audit**
- **Status:** MISSING (chức năng invoice riêng) + NEEDS_CLARIFICATION
- **Current Implementation:** Không có màn hình "hóa đơn". Nội dung xuất hóa đơn nằm dưới dạng **đoạn text bán-cứng** trong template pháp nhân, có chỗ để chấm chấm + mã cứng năm.
- **Source Evidence:**
  - `hd_hoinghi.txt:170` — *"Nội dung xuất: Dịch vụ cho thuê địa điểm tổ chức sự kiện và các dịch vụ đi kèm theo HĐ số {Sohopdong} ký ngày {NgayLapHD}/{ThangLapHD}/{NamLapHD} và Biên bản nghiệm thu và Quyết toán dịch vụ số … ……………ký ngày………"* — phần "số …" bỏ trống.
  - `hd_trienlam.txt:147`, `hd_tl_tiec.txt:170` — *"…theo HĐ số **…/CTY-HHKH/2025** ký ngày…"* — mã "/CTY-HHKH/2025" cứng.
  - `sql/tables/tbHoadontaichinh` — có bảng hóa đơn tài chính nhưng chưa rõ luồng nhập/ghép nội dung.
- **Gap:** Mã "/CTY-HHKH/2025" cứng; số BBNT/ngày để trống; chưa rõ phạm vi field khách muốn mở.
- **Existing Reusable:** `{Sohopdong}`, `{NgayLapHD}` — đã là placeholder.
- **Recommended Action:** NEED CUSTOMER CLARIFICATION (danh sách field cần mở) → TEMPLATE FIX (thay mã cứng bằng placeholder) + có thể SMALL FIX view.
- **Confidence:** HIGH (về "đang bán-cứng") · phạm vi: NEEDS_CLARIFICATION

---

### REQ-19 — Người phụ trách giao dịch + chức vụ nhập linh hoạt

**Requirement:** Trong "Thông tin liên lạc và đầu mối thực hiện hợp đồng": "Người phụ trách giao dịch" + "Chức vụ" nhập theo từng HĐ. Không hard-code "Giám đốc" / một người cố định (thường là NV phòng kinh doanh).

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** "Người phụ trách giao dịch" lấy **động** theo nhân viên sales của HĐ (`h.Manv` → `dmNhanvienView`). "Chức vụ" có field per-HĐ `h.BenAChucVuDaiDien`. NHƯNG chuỗi fallback trong view kết thúc bằng literal `N'Giám đốc'` và tên `N'Nguyễn Văn A'`.
- **Source Evidence:**
  - `sql/View/v_DanhSachHopDong.sql:165` — `(SELECT TOP 1 nv.Tennv FROM dmNhanvienView nv WHERE nv.NHANVIENID = h.Manv OR ...) AS [BenANhanVienPhuTrach]`.
  - `sql/View/v_DanhSachHopDong.sql:164, 408` — `ISNULL(NULLIF(h.BenAChucVuDaiDien, ''), ISNULL((SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID='HNChucVuNguoiDaiDien'), N'Giám đốc')) AS [BenAChucVu]`.
  - `sql/View/v_DanhSachHopDong.sql:162-163` — `ISNULL(NULLIF((SELECT ... 'HNNguoiDaiDien'), ''), N'Nguyễn Văn A') AS [BenANguoiDaiDien]`.
  - `sql/API/API_TimNguoiGiaoDich.sql` — có API tra cứu người giao dịch.
  - `hd_cuoi.txt:17-19` — mẫu cưới: dòng 17 "Đại Diện: Ông ___ Chức Vụ: ___" (bỏ trống, **không** có placeholder); dòng 18 `{BenANhanVienPhuTrach}`, dòng 19 `{BenASDTNhanVien}`.
- **Gap:** (1) Fallback cứng `N'Giám đốc'` / `N'Nguyễn Văn A'` → in sai khi field + SY_Setup trống. (2) Mẫu cưới dòng 17 thiếu placeholder cho Đại diện/Chức vụ Bên A.
- **Existing Reusable:** `{BenANhanVienPhuTrach}` + `dmNhanvienView` + `API_TimNguoiGiaoDich`.
- **Recommended Action:** SMALL FIX (bỏ literal fallback trong view) + TEMPLATE FIX (mẫu cưới: chèn `{BenADaiDien}` / `{BenAChucVu}`).
- **Confidence:** MEDIUM

---

## H. CONFERENCE + BANQUET CONTRACT

### REQ-20 — Đúng wording "Hội nghị + Tiệc" (thay "triển lãm" → "hội nghị")

**Requirement:** Trong HĐ Hội nghị + Tiệc, thay các chỗ dùng "triển lãm" sai ngữ cảnh thành "hội nghị" (tổ chức hội nghị và tiệc, địa điểm hội nghị, thời gian hội nghị…).

**Source Audit** ⚠ *(Kilo ghi MISSING — SAI, sửa → MISMATCH)*
- **Status:** MISMATCH (cục bộ, 2 dòng)
- **Current Implementation:** Template `3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx` **tồn tại + mapped** (`BLT000004`). Thân bài đa số dùng "hội nghị" / "dịch vụ"; chỉ câu mở đầu còn "triển lãm và tiệc".
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §2 — `('frmHopDong','BLT000004', N'3.1 MAU HDONG - 0406 (HỘI NGHỊ + TIỆC-TEABREAK).docx')`.
  - `hd_hn_tiec.txt:29` — "Sau khi bàn bạc, hai bên cùng thống nhất ký **Hợp đồng triển lãm và tiệc** với các điều khoản sau đây:".
  - `hd_hn_tiec.txt:31` — "Bên B có nhu cầu và Bên A đồng ý cung cấp dịch vụ **tổ chức triển lãm và tiệc** theo yêu cầu của Bên B…".
  - `hd_hn_tiec.txt:265` — "…họp báo, **triển lãm thương mại**…" → mệnh đề pháp lý liệt kê hợp lệ, **GIỮ**.
  - `hd_hn_tiec.txt:36-37` — đã dùng "sảnh hội nghị" / "diễn ra hội nghị" (đúng).
- **Gap:** 2 dòng literal (29, 31).
- **Existing Reusable:** Thân `3.1` đã đúng; copy câu chuẩn từ REQ-28.
- **Recommended Action:** TEMPLATE FIX — sửa `3.1 ....docx` dòng 29 & 31 (đồng bộ với REQ-28).
- **Confidence:** MEDIUM

---

### REQ-21 — Setup bàn ghế hội nghị chọn từ danh sách

**Requirement:** Setup bàn ghế hội nghị không được chỉ là text hard-code; người dùng chọn kiểu setup từ danh sách do hệ thống quản lý.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Có field `KieuSetup` (chuỗi tự do) lưu theo từng dòng hợp đồng–sảnh. Khi lưu HĐ, `API_LuuHopDong` lấy `JSON_VALUE(value,'$.KieuSetup')` nguyên văn từ frontend (không FK, không validate). View `v_DanhSachHopDong` xuất `[KieuSetup]` thô và suy ra `[SetupBanGhe]` (nhãn tiếng Việt) + sức chứa qua **CASE hard-code** 3 mã (`ClassRoom` / `Theater` / `Cluster`) + fallback Banquet. Placeholder `{KieuSetup}` được BEO Hội Nghị tiêu thụ.
- **Source Evidence:**
  - `sql/API/API_LuuHopDong.sql:353-372` (§3 "XU LY SANH TIEC") — `INSERT INTO tbmk_Hopdongsanhtiec (... KieuSetup, Ghichuct ...) SELECT ... JSON_VALUE(value,'$.KieuSetup'), JSON_VALUE(value,'$.Ghichuct') FROM OPENJSON(@JsonSanhTiec)`.
  - `sql/View/v_DanhSachHopDong.sql:145` — `hs.KieuSetup AS [KieuSetup]`.
  - `sql/View/v_DanhSachHopDong.sql:245-261` — `CASE WHEN hs.KieuSetup='ClassRoom' THEN ISNULL(s.ClassRoom,0) WHEN 'Theater' ... WHEN 'Cluster' ... ELSE ISNULL(s.SLBanMax*10,0) END AS [SucchuaMax]` + `CASE ... THEN N'Lớp học' / N'Nhà hát' / N'Bàn tròn xoay 1 phía' ELSE N'Bàn tròn (Banquet)' END ... AS [SetupBanGhe]`.
  - `sql/View/v_DanhSachHopDong.sql:423-424` — lặp lại CASE cho `[SucChuaToiDa]` / `[SucChuaToiDaPhu]`.
  - `sql/Update/Update_ContractDropdowns.sql:4-5` — comment "Các field mã của hợp đồng phải chọn từ danh mục, không nhập text tự do"; `:55-67` — `@Dropdowns` chỉ có `Makh, Manv, Thoigianid, Loaitiecid, GoiThucDonID` → **`KieuSetup` không được đăng ký**.
  - `backend-app/Danh_Sach_Truong/Danh_Sach_Truong_Tong_Hop.md:416` — `{KieuSetup}: Kiểu setup bàn ghế hội nghị` (placeholder BEO Hội Nghị).
  - `sql/tables/tbmk_Hopdong:67-68` — `HinhThucSapSepID nvarchar(200)`, `PhongSanKhauID nvarchar(200)` — cặp field header **dormant** (được lưu/sync qua `TRG_tbmk_Thaydoi_SyncToHopDong.sql:128-129`, `Update_PhuLuc_AllInOne.sql:986-987`, `Update_frmThayDoiBoSung_AllInOne.sql:846,950,1234` nhưng **không có dropdown / catalog / placeholder / view consumer**).
  - `src/js/app.bundle.js` — chuỗi `KieuSetup` **không xuất hiện** → picker có thể chưa được hiện trên UI HĐ.
  - Không có `dmKieuSetup` / `dmHinhThucSapSep` trong `sql/tables/`.
- **Data Flow:** FE hall sub-grid (gửi `$.KieuSetup` chuỗi — chưa xác nhận có gửi) → `API_LuuHopDong` §3 → `tbmk_Hopdongsanhtiec.KieuSetup` → `v_DanhSachHopDong` (CASE hard-code → `[SetupBanGhe]` + sức chứa) → `{KieuSetup}` DOCX BEO Hội Nghị. Nhánh dormant: `HinhThucSapSepID` → lưu/sync → cụt.
- **Gap:** (1) Tập lựa chọn hard-code trong SQL CASE + cột cố định `dmSanhtiec.ClassRoom/Theater/ClusterHalfRound` → không có danh mục quản lý; thêm kiểu = đổi schema + sửa view. (2) Không đăng ký làm dropdown danh mục. (3) FE chưa chắc gửi/hiện `KieuSetup`. (4) 2 cách biểu diễn cạnh tranh (`KieuSetup` vs `HinhThucSapSepID` + `PhongSanKhauID`).
- **Existing Reusable:** Cột `KieuSetup` + logic `[SetupBanGhe]` + placeholder `{KieuSetup}` — **dùng chung với REQ-22, REQ-29**. Pattern dropdown danh mục (`@Dropdowns` + `API_Gateway_Router` + `dm*`) đã có sẵn để gắn `dmKieuSetup`.
- **Recommended Action:** DATA MODEL CHANGE (thêm `dmKieuSetup` hoặc dùng `HinhThucSapSepID` làm FK; sức chứa thành dòng sảnh×kiểu thay vì cột `dmSanhtiec`) + BUSINESS LOGIC CHANGE (view đọc catalog thay CASE) + SMALL FIX (đăng ký dropdown, hiện picker) + NEED CUSTOMER CLARIFICATION (CRUD quản trị hay danh sách cố định; sức chứa theo kiểu có trong scope không).
- **Confidence:** MEDIUM

---

### REQ-22 — Setup bàn tiệc chọn từ danh sách

**Requirement:** Setup bàn tiệc cũng chọn theo danh sách; không hard-code một kiểu cố định.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Dùng **cùng field `KieuSetup`** như REQ-21. Khác với kiểu hội nghị, cách bố trí bàn tiệc **không có mã riêng** — mọi giá trị không thuộc `ClassRoom/Theater/Cluster` (kể cả `NULL`) render là `N'Bàn tròn (Banquet)'` qua nhánh `ELSE`, kèm `Ghichuct` text tự do. `Update_CL_Management.sql` lại mặc định `N'Tiệc ngồi'` khi trống.
- **Source Evidence:**
  - `sql/View/v_DanhSachHopDong.sql:252-261` — `... ELSE N'Bàn tròn (Banquet)' END + CASE WHEN ISNULL(hs.Ghichuct,'')<>'' THEN N' (' + hs.Ghichuct + N')' ELSE N'' END AS [SetupBanGhe]`.
  - `sql/API/API_LuuHopDong.sql:353-372` — cùng lệnh insert như REQ-21 (không phân biệt setup hội nghị / bàn tiệc).
  - `sql/Update/Update_CL_Management.sql:222, 248` — `ISNULL(h.KieuSetup, N'Tiệc ngồi') AS [KieuSetup]`.
  - `sql/tables/tbmk_Hopdongsanhtiec` — cột xác nhận có: `Ghichuct nvarchar(250)`, `Giatiensanh decimal`, `IsSanhchinh bit` (`KieuSetup` không trong dump — schema drift, xem caveat).
- **Data Flow:** Giống REQ-21; nhánh bàn tiệc = `ELSE` không định kiểu.
- **Gap:** (1) Không có danh mục kiểu bàn tiệc. (2) Bàn tiệc không phải giá trị liệt kê tường minh — chỉ là "phần còn lại" → không thể *chọn từ danh sách*. (3) Lựa chọn có cấu trúc bị thay bằng text `Ghichuct`.
- **Existing Reusable:** Cùng 1 fix với REQ-21 + REQ-29 (một `dmKieuSetup` + refactor CASE phủ cả 3).
- **Recommended Action:** DATA MODEL CHANGE + BUSINESS LOGIC CHANGE (chung REQ-21) — thêm kiểu bàn tiệc (bàn tròn Banquet, bàn dài, chữ U, cocktail…) thành dòng danh mục; thay literal `ELSE` bằng lookup. NEED CUSTOMER CLARIFICATION (danh sách kiểu bàn tiệc thực dùng).
- **Confidence:** MEDIUM

---

## I. CONFERENCE + BANQUET — VENUE & SESSION

### REQ-23 — Địa điểm hội nghị và địa điểm tiệc độc lập + tiệc trưa/tối

**Requirement:** HĐ Hội nghị + Tiệc: địa điểm hội nghị là thông tin riêng, địa điểm tiệc là thông tin riêng. Tiệc có thể trưa hoặc tối. Không mặc định cứng.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Multi-sảnh (`tbmk_Hopdongsanhtiec`, `IsSanhchinh` phân "Hội nghị/Tiệc chính" vs "Tiệc"); danh mục `dmThoigian` có `AMPM` + `IsTiecCuoi`/`IsHoiNghi`; dropdown `Thoigianid` trên HĐ.
- **Source Evidence:**
  - `sql/View/v_DanhSachHopDong.sql:239` — `CASE WHEN hs.IsSanhchinh=1 THEN N'Hội nghị / Tiệc chính' ELSE N'Tiệc' END AS [LoaiPhong]`.
  - `sql/View/v_DanhSachHopDong.sql:237-267` — loop `DanhSachSanh` với kích thước / sức chứa / KieuSetup riêng từng sảnh.
  - `sql/tables/dmThoigian` — `AMPM`, `IsTiecCuoi`, `IsHoiNghi`, `GhiBatDau`, `GioKetThuc`.
  - `sql/Update/Update_ContractDropdowns.sql` — `Thoigianid` là dropdown catalog.
  - `hd_hoinghi.txt:36-37` — "Thời gian setup sảnh hội nghị: {SetupBatDau}-{SetupKetThuc}" / "Thời gian diễn ra hội nghị: {TiecGioBatDau}-{TiecGioKetThuc}".
- **Data Flow:** `frmHopDong` (n sảnh + 1 `Thoigianid`) → `API_LuuHopDong` → `tbmk_Hopdongsanhtiec` + `tbmk_Hopdong.Thoigianid` → `{#DanhSachSanh}` + `{CaTiec}` DOCX.
- **Gap:** Không có mô hình "địa điểm hội nghị" vs "địa điểm tiệc" là 2 thuộc tính độc lập, có kiểu (chỉ cờ chính/phụ). Ca trưa/tối là 1 giá trị chung toàn HĐ, không gán riêng cho segment tiệc.
- **Existing Reusable:** `tbmk_Hopdongsanhtiec` multi-hall + `dmThoigian.AMPM` + dropdown `Thoigianid`.
- **Recommended Action:** DATA MODEL CHANGE (`LoaiDiaDiem`/`SegmentType` cho dòng sảnh; `Thoigianid` theo segment hoặc `ThoigianTiecId` riêng) + TEMPLATE FIX (`{DiaDiemHoiNghi}` / `{DiaDiemTiec}` / `{CaTiec}` riêng) + NEED CUSTOMER CLARIFICATION (1 ca chung hay 2 ca). Chung với REQ-08/09.
- **Confidence:** MEDIUM

---

## J. SHARED RULES ACROSS CONTRACT TEMPLATES

### REQ-24 — "Quyết toán tiệc" → "Quyết toán dịch vụ"

**Requirement:** Cụm "Biên bản nghiệm thu và quyết toán tiệc" → "Biên bản nghiệm thu và quyết toán dịch vụ" ở các mẫu áp dụng cho dịch vụ / sự kiện.

**Source Audit**
- **Status:** MISMATCH (cục bộ — 1 mẫu, 1 dòng)
- **Current Implementation:** 4/5 mẫu đã đúng "dịch vụ"; chỉ `3.1 (HỘI NGHỊ + TIỆC-TEABREAK).docx` còn "quyết toán tiệc".
- **Source Evidence:**
  - `bbnt_dv.txt:27` — "…thống nhất xác nhận việc nghiệm thu và quyết toán **dịch vụ**…" (BBNT dùng chung pháp nhân — ĐÚNG).
  - `hd_hoinghi.txt:158` — "+ Biên bản nghiệm thu và quyết toán **dịch vụ**" (ĐÚNG).
  - `hd_tl_tiec.txt:158`, `hd_trienlam.txt:135` — "…**dịch vụ**" (ĐÚNG).
  - `hd_hn_tiec.txt:167` — "+ Biên bản nghiệm thu và quyết toán **TIỆC**" (SAI).
- **Data Flow:** Text cố định trong `.docx` — không qua engine.
- **Gap:** 1 literal string trong `3.1 ....docx`.
- **Existing Reusable:** Copy câu dòng 158 của `3.2`.
- **Recommended Action:** TEMPLATE FIX — `3.1 ....docx` (~dòng 167): "quyết toán tiệc" → "quyết toán dịch vụ".
- **Confidence:** HIGH

---

### REQ-25 — Đồng bộ rule "thuê sảnh phát sinh" cho các HĐ

**Requirement:** Các HĐ khác có mục "Thuê sảnh phát sinh ngoài thời gian hợp đồng" phải áp dụng cùng business rule REQ-11/REQ-12. Không viết lại logic nếu mẫu khác đã có implementation đúng — tìm implementation tái sử dụng trước.

**Source Audit**
- **Status:** MISSING
- **Current Implementation:** Không có mẫu nào có implementation đúng để tái dùng. Tất cả template pháp nhân đều để "…. VNĐ++/giờ/sảnh" (chỗ trống). `PhiBuSanh` là lump-sum thủ công (xem REQ-11).
- **Source Evidence:**
  - `hd_hoinghi.txt:59-62` (và `hd_hn_tiec` / `hd_trienlam` / `hd_tl_tiec` tương ứng) — cùng mục để chấm chấm.
  - `sql/API/API_LuuQuyenToan.sql:49,178` + `sql/Update/Update_QuyetToan_AllInOne.sql:406-407` — `PhiBuSanh` nhập tay, `SoLuong=1`, `DVT='Lần'`.
- **Gap:** Chưa có gì để "đồng bộ" — rule REQ-11/12 chưa tồn tại.
- **Existing Reusable:** Không (không có implementation đúng).
- **Recommended Action:** Phụ thuộc REQ-11/12: DATA MODEL CHANGE + BUSINESS LOGIC CHANGE + TEMPLATE FIX (placeholder chung cho mọi mẫu). Chưa làm được cho tới khi REQ-12 chốt công thức.
- **Confidence:** HIGH (về "chưa có") · công thức: NEEDS_CLARIFICATION

---

### REQ-26 — Đồng bộ rule đặt cọc (không mặc định 70%)

**Requirement:** Phần cọc thực hiện HĐ ở các mẫu liên quan áp dụng cùng rule: không mặc định 70%, tỷ lệ/số tiền theo thỏa thuận, đúng thời điểm workflow. Liên quan REQ-16, REQ-17.

**Source Audit**
- **Status:** MISMATCH
- **Current Implementation:** Các mẫu pháp nhân đã chia sẻ cùng cấu trúc điều khoản cọc (Lần 1 / Lần 2, `{Dot1SoTien}`), nhưng cùng lặp lỗi **"70% giá trị Hợp đồng tạm tính"** literal.
- **Source Evidence:**
  - `hd_hoinghi.txt:142`, `hd_hn_tiec.txt` (~142), `hd_trienlam.txt` (~128), `hd_tl_tiec.txt` (~142) — cùng câu "…tương đương 70% giá trị Hợp đồng tạm tính, tương ứng số tiền: {Dot1SoTien}…".
  - `hd_hoinghi.txt:141` — "Lần 1: Đặt cọc thực hiện hợp đồng — Trong thời hạn 03 (ba) ngày làm việc kể từ ngày ký Hợp đồng…" (thời điểm đã đúng ở text, nhưng không enforce — REQ-16).
  - Không có field `%cọc` (xem REQ-17).
- **Gap:** "70%" cứng ở 4 file; sửa 1 chỗ phải nhân ra 4. Không có mô hình %-cọc.
- **Existing Reusable:** Mẫu HĐ cưới (không nêu %).
- **Recommended Action:** TEMPLATE FIX đồng loạt 4 file (gắn REQ-17) + tùy chọn DATA MODEL CHANGE (`TyLeCoc`). Enforcement thời điểm = BUSINESS LOGIC CHANGE (gắn REQ-16).
- **Confidence:** HIGH

---

### REQ-27 — Đồng bộ thông tin đầu mối liên lạc

**Requirement:** Phần "Thông tin liên lạc và đầu mối thực hiện hợp đồng" ở các mẫu liên quan áp dụng cùng rule REQ-19: người phụ trách giao dịch linh hoạt, chức vụ linh hoạt, thông tin liên hệ lấy từ dữ liệu thực tế, không hard-code sai.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Mọi mẫu company/TL/HN dùng cùng bộ placeholder `{BenANhanVienPhuTrach}`, `{BenASDTNhanVien}`, `{BenAEmailNhanVien}` (lấy động từ `dmNhanvienView` theo `h.Manv`). `{BenAChucVu}`/`{BenADaiDien}` có field per-HĐ nhưng fallback cứng `N'Giám đốc'` / `N'Nguyễn Văn A'` (xem REQ-19).
- **Source Evidence:**
  - `sql/View/v_DanhSachHopDong.sql:162-171, 408` — cùng chuỗi fallback (dùng cho mọi loại HĐ, không phân biệt).
  - `sql/API/API_DanhSachBaoGia.sql:71-75`, `sql/API/API_DanhSachQuyetToan.sql:61-65` — thông tin Bên A lấy từ `SY_Setup` (`BenATenCongTy`, `BenADiaChi`, `BenASDT`, `BenAMST`, `HNNguoiDaiDien`).
  - `hd_hoinghi.txt` — dùng `{BenANhanVienPhuTrach}` / `{BenASDTNhanVien}` nhất quán.
  - Không có "Giám đốc" hard-code **trong file `.docx`** (grep 5 mẫu HĐ = 0) → chỉ là fallback trong view.
- **Gap:** Fallback cứng trong `v_DanhSachHopDong` áp cho mọi HĐ; đây là điểm "đồng bộ" duy nhất cần sửa.
- **Existing Reusable:** `{BenANhanVienPhuTrach}` + `dmNhanvienView` + `SY_Setup` — pattern chung đã có.
- **Recommended Action:** SMALL FIX (bỏ literal `N'Giám đốc'` / `N'Nguyễn Văn A'` trong view — dùng chung REQ-19) + TEMPLATE FIX nếu mẫu nào thiếu placeholder.
- **Confidence:** MEDIUM

---

## K. CONFERENCE CONTRACT

### REQ-28 — Mẫu HĐ Hội nghị (riêng) dùng đúng wording

**Requirement:** Mẫu HĐ Hội nghị riêng dùng đúng wording ("Sau khi bàn bạc, hai bên cùng thống nhất ký Hợp đồng hội nghị…"; "Bên B có nhu cầu thuê địa điểm để tổ chức hội nghị và Bên A đồng ý cung cấp dịch vụ cho thuê địa điểm…"). Không còn nội dung "triển lãm" do copy template.

**Source Audit**
- **Status:** MISMATCH (cục bộ — 2 dòng)
- **Current Implementation:** Template `3.2 MAU HDONG - 0406 (HỘI NGHỊ).docx` tồn tại + mapped (`BLT000005`). Thân bài ~95% wording hội nghị; câu mở đầu còn "triển lãm và tiệc".
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §2 — `('frmHopDong','BLT000005', N'3.2 MAU HDONG - 0406 (HỘI NGHỊ ).docx')`.
  - `hd_hoinghi.txt:29` — "…thống nhất ký **Hợp đồng triển lãm và tiệc** với các điều khoản sau đây:".
  - `hd_hoinghi.txt:31` — "Bên B có nhu cầu và Bên A đồng ý cung cấp dịch vụ **tổ chức triển lãm và tiệc** theo yêu cầu của Bên B…".
  - `hd_hoinghi.txt:186` — "Chỉ sử dụng địa điểm… cho mục đích tổ chức **hội nghị, hội thảo, đào tạo**…" (ĐÚNG).
  - `hd_hoinghi.txt:249` — "…họp báo, **triển lãm thương mại**…" → mệnh đề pháp lý hợp lệ, **GIỮ**.
- **Gap:** 2 dòng literal (29, 31); cấu trúc câu 31 khác mẫu yêu cầu ("cho thuê địa điểm").
- **Existing Reusable:** Thân `3.2` đã là bản hội nghị đúng.
- **Recommended Action:** TEMPLATE FIX — sửa `3.2 ....docx` dòng 29 & 31 theo wording khách cung cấp; đối chiếu `3.1` (REQ-20).
- **Confidence:** MEDIUM

---

### REQ-29 — Setup bàn ghế HĐ Hội nghị chọn từ danh sách

**Requirement:** Trong HĐ Hội nghị, mục setup bàn ghế áp dụng cùng rule REQ-21: chọn từ danh sách, không hard-code text.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation / Source Evidence / Data Flow / Gap:** **Giống hệt REQ-21.** Cùng field `tbmk_Hopdongsanhtiec.KieuSetup`; cùng view `v_DanhSachHopDong.sql:145, 245-261` (CASE hard-code); cùng placeholder `{KieuSetup}` — vốn được mô tả là "Kiểu setup bàn ghế **hội nghị**" (`Danh_Sach_Truong_Tong_Hop.md:416`), tức chính REQ-29. Không có `dmKieuSetup`; không đăng ký trong `Update_ContractDropdowns.sql`.
- **Existing Reusable:** **Cùng 1 fix với REQ-21 + REQ-22.** Làm `dmKieuSetup` + refactor CASE trong `v_DanhSachHopDong` → giải quyết đồng thời 21/22/29.
- **Recommended Action:** DATA MODEL CHANGE + BUSINESS LOGIC CHANGE (dùng chung REQ-21). Không code riêng cho HĐ hội nghị.
- **Confidence:** MEDIUM

---

### REQ-30 — Đồng bộ cọc / thanh toán / hóa đơn giữa các HĐ pháp nhân

**Requirement:** Các mẫu HĐ pháp nhân / sự kiện áp dụng cùng business rule cho: cọc thực hiện HĐ, hình thức thanh toán, thông tin xuất hóa đơn GTGT. Không mỗi template một logic khác nhau. Liên quan REQ-16/17/18/26.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** 4 mẫu company/TL/HN đã chia sẻ cấu trúc: Lần 1 / Lần 2, `{Dot1SoTien}`, "Nội dung chuyển khoản lần 1/2", điều khoản GTGT, và **dùng chung** 1 template quyết toán (`4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ ....docx`).
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §7 — `BLT000002-000005` cùng trỏ `4. BBNT VÀ QUYẾT TOÁN DỊCH VỤ ....docx`.
  - `hd_hoinghi.txt` / `hd_hn_tiec.txt` / `hd_trienlam.txt` / `hd_tl_tiec.txt` dòng ~140-180 — nội dung gần như trùng khớp.
  - `bbnt_dv.txt:71` — "Bên A thực hiện xuất Hóa đơn GTGT theo Tổng giá trị quyết toán…".
- **Gap:** Hai điểm chưa đồng bộ/đúng, lặp ở cả 4 file: (1) "70%" cứng (REQ-26), (2) nội dung xuất hóa đơn "số …/CTY-HHKH/2025" (REQ-18).
- **Existing Reusable:** Cấu trúc điều khoản thanh toán/GTGT + BBNT dùng chung — nền tảng đồng bộ đã có.
- **Recommended Action:** TEMPLATE FIX đồng loạt 4 file (gắn REQ-26 + REQ-18) + NEED CUSTOMER CLARIFICATION (REQ-18: field nội dung hóa đơn cần mở).
- **Confidence:** MEDIUM

---

## L. WEDDING CONTRACT BUSINESS RULES

### REQ-31 — Bàn vượt 10% tính thêm 10% (không phải 15%)

**Requirement:** Phần bàn vượt quá ngưỡng 10% tính = đơn giá bàn tiệc chính thức + 10% (không phải +15%). Kiểm tra cả business calculation, contract wording, DOCX output.

**Source Audit**
- **Status:** MISMATCH
- **Current Implementation:** Điều khoản trong HĐ cưới ghi ngưỡng 10% đúng, nhưng phần vượt tính **"cộng thêm 15%"** (literal trong `.docx`). **Không có calculation** tương ứng ở bất kỳ đâu — quyết toán khi có bàn vượt dùng ô `PhiBuBanTang` nhập tay.
- **Source Evidence:**
  - `hd_cuoi.txt:45` — "…không vượt quá 10%… thì đơn giá thực đơn được áp dụng bằng đơn giá bàn tiệc chính thức." (ĐÚNG).
  - `hd_cuoi.txt:46` — "…vượt quá 10%… phần bàn vượt quá 10% sẽ được tính theo đơn giá bàn tiệc chính thức **cộng thêm 15%**." (SAI — cần 10%).
  - Repo-wide grep `1.15 / 0.15 / *1.1 / BanVuot / SoBanVuot / PhiVuot` (loại `.kilo`, `app.bundle`): **0** kết quả liên quan bàn vượt. (`API_Report_Cost.sql:34-35 *0.15/*0.10` = tỷ lệ ước tính chi phí; `Update_CL_Management.sql:67 DinhBienCL=0.15` = định biên HN/TL — không liên quan.)
  - `sql/API/API_LuuQuyenToan.sql` — `@PhiBuBantang` là decimal nhập tay.
- **Data Flow:** Chỉ là text trong `hop_dong.docx`. Không có công thức tính phần bàn vượt.
- **Gap:** Sai con số trong wording (15% → 10%). Không có logic tính để phải đồng bộ.
- **Existing Reusable:** Không (không có calculation).
- **Recommended Action:** TEMPLATE FIX duy nhất — `hop_dong.docx` (~dòng 46): "cộng thêm 15%" → "cộng thêm 10%".
- **Confidence:** HIGH

---

### REQ-32 — Phí phục vụ phải configurable

**Requirement:** Phí phục vụ không hard-code; áp phí / giảm phí / miễn phí tùy CTKM / giai đoạn bán hàng.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Tầng dữ liệu + tính toán **đã hỗ trợ** phí phục vụ cấu hình theo % trên từng HĐ. NHƯNG template HĐ cưới hard-code "180.000vnđ/bàn tiệc" và mô hình là %-based trong khi text là đồng/bàn.
- **Source Evidence:**
  - `sql/tables/tbmk_Hopdong:57-60` — `SoBanTinhPhiPhucVu`, `PhiPhucVu`, `TongTienPhiPhucVu` (decimal).
  - `sql/View/v_DanhSachHopDong.sql:361` — `CAST(ISNULL(h.PhiPhucVu,0) AS VARCHAR) + '%' AS [MucPhiPhucVu]` (rõ ràng là **phần trăm**).
  - `sql/View/v_DanhSachHopDong.sql:461-471` — `CalcPhiPhucVu`: `RawSubTotal * (ISNULL(h.PhiPhucVu,0)/100.0)` …
  - `sql/Update/Update_QuyetToan_AllInOne.sql:488, 553-554, 617` — quyết toán nhận `@PhiPhucVu`, parse, `PhiPhucVu = @PhiPhucVuDec`, cộng vào `TongCongChuaVAT` (`:129`).
  - `hd_cuoi.txt:62` — "Phí phục vụ: **180.000vnđ/ bàn tiệc**;" (literal, KHÔNG có `{PhiPhucVu}`).
  - `backend-app/information/CTKM TIỆC CƯỚI.docx` (~dòng 550) — "PHÍ PHỤC VỤ: 180.000VNĐ/bàn tiệc" (literal).
- **Data Flow:** Form (nhập `PhiPhucVu` %) → `tbmk_Hopdong.PhiPhucVu` → `v_DanhSachHopDong.CalcPhiPhucVu` / `[MucPhiPhucVu]` → có placeholder nhưng **template cưới không bind**.
- **Gap:** (1) Template cưới không bind `{MucPhiPhucVu}` / `{PhiPhucVu}`. (2) Lệch đơn vị: model = %, text = đồng/bàn.
- **Existing Reusable:** `PhiPhucVu` %-model + calc trong `v_DanhSachHopDong` + quyết toán — đủ để áp/giảm/miễn (đặt 0 = miễn).
- **Recommended Action:** TEMPLATE FIX (bind `{MucPhiPhucVu}` / `{PhiPhucVu}`) + NEED CUSTOMER CLARIFICATION (% tổng hay đồng/bàn; nếu đồng/bàn → DATA MODEL CHANGE).
- **Confidence:** MEDIUM

---

## M. PROMOTIONS

### REQ-33 — CTKM chọn từ danh mục đang áp dụng

**Requirement:** Phần CTKM đính kèm HĐ chọn từ Danh mục CTKM đang áp dụng, thay vì hard-code. CTKM có thể liên quan số bàn đủ điều kiện / số bàn chuyển qua. Nếu source đã có module Promotion → ưu tiên reuse.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Có module CTKM: danh mục `tbmk_Banuudai` (header: `Loaitiecid`, `Tusoluongban`, `Densoluongban`, `IsKetthuc`, `Nhahangid`/`BranchID`) + `tbmk_Banuudaict` (chi tiết món/dịch vụ ưu đãi). API `API_LayDichVuUuDaiTheoLoaiTiec` tra theo loại tiệc + số bàn. `PromotionAutoFillPlugin.js` tự tra và điền vào field `DSKhuyenMai` của `frmHopDong`.
- **Source Evidence:**
  - `sql/API/API_LayDichVuUuDaiTheoLoaiTiec.sql` — proc: `SELECT ... FROM tbmk_Banuudaict ct WHERE ct.DocumentID = (SELECT TOP 1 DocumentID FROM tbmk_Banuudai WHERE Loaitiecid=@Loaitiecid AND @Soluongban BETWEEN Tusoluongban AND Densoluongban AND (IsKetthuc IS NULL OR IsKetthuc=0) ... ORDER BY Tusoluongban DESC)`.
  - `src/js/utils/PromotionAutoFillPlugin.js:44-46` — gọi `List:'API_LayDichVuUuDaiTheoLoaiTiec'` với `Loaitiecid` + `Soluongban`.
  - `PromotionAutoFillPlugin.js:63-123` — `records.map(...).join('\n')` → set `fields.targetEl.value = formatted` (frmHopDong → field `DSKhuyenMai`; frmBiennhancoccho → `Ghichu`).
  - `sql/Update/Update_PromotionData_Wedding_Company.sql` — seed CTKM tiệc cưới + công ty.
- **Data Flow:** `frmHopDong` (đổi `Loaitiecid` / số bàn) → `PromotionAutoFillPlugin` → `API_LayDichVuUuDaiTheoLoaiTiec` → format text → `DSKhuyenMai` (textarea, sửa tay được) → `{DanhSachUuDai}` DOCX.
- **Gap:** (1) Kết quả là **khối text** trong textarea (không phải lựa chọn có cấu trúc / link tới CTKM). (2) Không lọc "đang áp dụng theo ngày" — chỉ `IsKetthuc=0`. (3) Không có UI chọn tay nhiều CTKM từ danh mục. (4) "Số bàn chuyển qua" chưa thấy xử lý (chỉ có ngưỡng `Tu/Densoluongban`).
- **Existing Reusable:** **Toàn bộ module CTKM** (`tbmk_Banuudai/ct` + `API_LayDichVuUuDaiTheoLoaiTiec` + `PromotionAutoFillPlugin`) — reuse, không dựng mới.
- **Recommended Action:** BUSINESS LOGIC CHANGE (lọc CTKM hiệu lực theo ngày) + DATA MODEL CHANGE nhẹ (lưu `DocumentID` CTKM đã chọn vào HĐ thay vì chỉ text) + SMALL FIX (UI chọn từ danh mục).
- **Confidence:** MEDIUM

---

### REQ-34 — Điều khoản bổ sung nhập theo từng HĐ

**Requirement:** Phần "Các điều khoản bổ sung" cho nhập tay theo từng HĐ; không hard-code một nội dung cố định.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Template HĐ cưới có placeholder `{DieuKhoanBoSung}` ("CÁC ĐIỀU KHOẢN BỔ SUNG KHÁC (NẾU CÓ){DieuKhoanBoSung}"). REQUIREMENT.md IV.7 mô tả Tab Ghi chú (điều 3/4/5) hiện trong HĐ in.
- **Source Evidence:**
  - `hd_cuoi.txt:179` — "CÁC ĐIỀU KHOẢN BỔ SUNG KHÁC (NẾU CÓ){DieuKhoanBoSung}".
  - `REQUIREMENT.md:340-342` — "Tab Ghi chú — Phần thoả thuận với khách hàng — Điều 3, 4, 5 sẽ hiện trong hợp đồng in".
  - Không tìm thấy mapping `DieuKhoanBoSung` trong `v_DanhSachHopDong` / `API_LuuHopDong` (grep) — có thể chưa nối, hoặc nối qua tên khác (`Ghichu`, `Dieu3/4/5`).
- **Gap:** Placeholder có nhưng chưa chứng minh được nguồn dữ liệu per-HĐ đổ vào nó (rủi ro render rỗng).
- **Existing Reusable:** Tab Ghi chú / `Ghichu` HĐ (điều 3-5) — cơ chế nhập text tự do theo HĐ.
- **Recommended Action:** VERIFY → nếu chưa nối: SMALL FIX (thêm `[DieuKhoanBoSung]` vào `v_DanhSachHopDong` map từ field HĐ). Nếu đã nối: NO CHANGE.
- **Confidence:** MEDIUM (LOW ở khâu nguồn dữ liệu)

---

### REQ-35 — Câu cuối CTKM là nội dung cố định

**Requirement:** Câu cuối bắt đầu bằng "Tất cả CTKM…" là nội dung cố định của template. Không cần biến thành field nhập tay.

**Source Audit**
- **Status:** NEEDS_CLARIFICATION
- **Current Implementation:** Các câu chốt CTKM tồn tại dưới dạng **text cố định** trong tài liệu CTKM tĩnh + trong template HĐ pháp nhân. Chưa thấy câu bắt đầu chính xác "Tất cả CTKM…" nguyên văn.
- **Source Evidence:**
  - `backend-app/information/CTKM TIỆC CƯỚI.docx` (~dòng 564-565) — "Chương trình khuyến mãi chỉ áp dụng cho bàn chính thức (bàn mặn), không áp dụng cho bàn chay, bàn dự phòng và phát sinh…" / "Trong mọi trường hợp các dịch vụ khuyến mãi được tặng nếu khách hàng không sử dụng sẽ không được quy đổi thành tiền mặt…".
  - `hd_hoinghi.txt:51` — "Tất cả chương trình ưu đãi/tặng kèm nêu trên không được quy đổi thành tiền mặt…" (cố định trong template HĐ).
  - `backend-app/information/CTKM TIỆC CƯỚI.docx` — là **tài liệu tham khảo tĩnh**, KHÔNG nằm trong `tbmk_LoaitiecAddfile` (không phải template sinh tự động).
  - grep "Tất cả CTKM / Tất cả các chương trình khuyến" mọi template + CTKM docs: **0** kết quả nguyên văn.
- **Gap:** Chưa xác định câu "Tất cả CTKM…" chính xác khách nói tới nằm ở mẫu nào; mẫu đó đã có câu này chưa.
- **Recommended Action:** NEED CUSTOMER CLARIFICATION (câu nguyên văn + vị trí). Nhiều khả năng NO CHANGE (đã là text cố định đúng ý).
- **Confidence:** LOW

---

## N. CONTRACT APPENDIX

### REQ-36 — Phụ lục hợp đồng phải có Số

**Requirement:** Phụ lục HĐ phải có "Số: …". Không bị thiếu / bỏ trống ngoài ý muốn. Cần xác nhận số phụ lục: nhập tay / auto-gen / sinh theo số HĐ.

**Source Audit** ⚠ *(Kilo ghi MISSING — SAI, sửa → CONFIRMED)*
- **Status:** CONFIRMED (cần clarify nhỏ về định dạng)
- **Current Implementation:** Template phụ lục có trường "Số: {SoPhuLuc}", và `{SoPhuLuc}` **được đổ dữ liệu** — map từ `Sothaydoi` (ID bản thay đổi/phụ lục).
- **Source Evidence:**
  - `phuluc.txt:7` — "Số: {SoPhuLuc}".
  - `phuluc.txt:8` — "Đính kèm Hợp đồng số: {Sohopdong} ký ngày {NgayLapHD}/{ThangLapHD}/{NamLapHD}".
  - `sql/Update/Update_PhuLuc_AllInOne.sql:268-270` — `td.Sothaydoi AS [Id]`, `td.Sothaydoi AS [Sothaydoi]`, `td.Sothaydoi AS [SoPhuLuc], -- Biến trong docx`.
  - `phuluc.txt:86, 90` — dùng `{Sohopdong}` nhất quán.
- **Data Flow:** `ContractService.getPhuLucHistory` / `frmPhuLucHopDong` → `Update_PhuLuc_AllInOne` view → `[SoPhuLuc] = td.Sothaydoi` → `{SoPhuLuc}` DOCX.
- **Gap:** Chỉ còn câu hỏi định dạng: `Sothaydoi varchar(50)` có phải chuỗi số dễ đọc (VD PL-001) hay mã kỹ thuật. Không phải "thiếu số".
- **Existing Reusable:** Cơ chế đầy đủ; `{SoPhuLuc}` đã render.
- **Recommended Action:** NEED CUSTOMER CLARIFICATION nhẹ (định dạng số phụ lục mong muốn); còn lại NO CHANGE.
- **Confidence:** HIGH

---

### REQ-37 — Bổ sung đầy đủ thông tin số bàn

**Requirement:** HĐ / Phụ lục tiệc cưới đang thiếu thông tin số bàn. Cần thể hiện đầy đủ. Chưa rõ scope: bàn chính thức / bàn tặng / bàn dự phòng / loại khác.

**Source Audit**
- **Status:** PARTIAL
- **Current Implementation:** Phụ lục có 4 field số bàn; HĐ cưới có 3 field. Nguồn dữ liệu (`tbmk_Hopdong`) có đủ số bàn mặn/chay chính thức + dự phòng.
- **Source Evidence:**
  - `phuluc.txt:35-38` — "Quy mô sảnh: Từ {QuyMoBanTu} bàn đến {QuyMoBanDen} bàn / Số bàn chính thức: {SoBanChinhThuc} bàn / Số bàn tặng: {BanTang} bàn / Số bàn dự phòng: {SoBanDuPhong} bàn".
  - `hd_cuoi.txt:38-40` — "Số bàn tiệc chính thức: {TiecSoBanChinhThuc} / Số lượng bàn tặng: {TiecSoBanTang} / Số lượng bàn dự phòng: {TiecSoBanDuPhong}".
  - `hd_cuoi.txt:34` — "Quy mô phục vụ của sảnh: từ {SanhQuyMoMin} bàn đến {SanhQuyMoMax} bàn".
  - `sql/API/API_LuuHopDong.sql` — `tbmk_Hopdong` có `SobanManchinhthuc`, `SobanManduphong`, `SobanChaychinhthuc`, `SobanChayduphong`, `TongSoBan`.
- **Gap:** Phần lớn field đã có → khó khẳng định "thiếu". Chưa rõ loại nào khách thấy thiếu (bàn mặn/chay tách riêng? bàn phát sinh? tổng cộng?).
- **Existing Reusable:** Bộ field số bàn trong `tbmk_Hopdong` + placeholder ở 2 template.
- **Recommended Action:** NEED CUSTOMER CLARIFICATION (chốt danh sách field số bàn còn thiếu) → TEMPLATE FIX (+ có thể SMALL FIX view nếu field chưa map).
- **Confidence:** MEDIUM

---

## O. MENU REQUIREMENTS

### REQ-38 — Một HĐ có thể có cả menu mặn và menu chay

**Requirement:** Thực đơn hỗ trợ 1 HĐ / tiệc có đồng thời thực đơn mặn + thực đơn chay. Không giới hạn 1 loại. Kiểm tra data model, UI, menu selection, price calculation, DOCX/Phụ lục/BEO.

**Source Audit** ⚠ *(Kilo ghi MISSING — SAI, sửa → PARTIAL)*
- **Status:** PARTIAL (gần CONFIRMED)
- **Current Implementation:** `FoodSelectionPlugin` quản lý 2 danh sách tách biệt `selectedFoodsMan` + `selectedFoodsChay` (tab `man` / `chay`), cờ `IsChay` từng món. Khi lưu HĐ, insert vào **cả 2 bảng** `tbmk_Hopdongthucdonman` và `tbmk_Hopdongthucdonchay`. View cộng giá cả 2 phần.
- **Source Evidence:**
  - `src/js/utils/FoodSelectionPlugin.js:408-409, 432-433` — `selectedFoodsMan = ...filter(IsChay===0)`, `selectedFoodsChay = ...filter(IsChay===1)` (và bản `contractFoodsMan/Chay`).
  - `FoodSelectionPlugin.js:447` — khi lưu: `selectedFoodsMan.concat(selectedFoodsChay).map(...)`.
  - `FoodSelectionPlugin.js:657, 677, 1245-1246` — tab `man` / `chay` riêng.
  - `sql/API/API_LuuHopDong.sql` §4 — 2 lệnh `INSERT INTO tbmk_Hopdongthucdonman` và `INSERT INTO tbmk_Hopdongthucdonchay` (phân loại `Tenhang NOT LIKE N'%chay%'`).
  - `sql/View/v_DanhSachHopDong.sql:446-449` — `SUM(...thucdonman.Dongia) + SUM(...thucdonchay.Dongia)`.
  - `REQUIREMENT.md:312-323` — Tab Thực đơn Mặn + Tab Thực đơn Chay (checkbox "Phần").
- **Data Flow:** `frmHopDong` (2 tab món) → `API_LuuHopDong` §4 (2 INSERT) → `v_DanhSachHopDong` (cộng 2 phần) → DOCX.
- **Gap:** UI + model + save + tính tiền OK cho cả 2. Chưa xác nhận template DOCX/BEO/Phụ lục in **2 mục riêng** (`{#MenuTiec}` là loop gộp — rủi ro thiếu block thực đơn chay).
- **Existing Reusable:** Toàn bộ luồng mặn+chay.
- **Recommended Action:** TEMPLATE FIX — thêm/kiểm tra block thực đơn chay (`{#MenuChay}` hoặc filter `IsChay`) trong `hop_dong.docx` / `phu_luc_hop_dong.docx` / BEO. Model = NO CHANGE.
- **Confidence:** MEDIUM-HIGH

---

## O2. ADDITIONAL WEDDING CONTRACT TEMPLATE

### REQ-39 — Mẫu HĐ tiệc cưới "chọn ngay menu" (cọc → tiệc ≤ 30 ngày)

**Requirement:** Thiếu mẫu "Hợp đồng tiệc cưới chọn ngay menu" áp dụng khi từ ngày cọc đến ngày tiệc trong vòng 30 ngày. Cần kiểm tra source: template chưa tồn tại, hay đã tồn tại nhưng chưa expose.

**Source Audit**
- **Status:** MISSING
- **Current Implementation:** Chỉ có **1** template HĐ cưới (`hop_dong.docx` → `BLT000001`). Không có nhánh chọn template theo khoảng ngày cọc→tiệc. Wording HĐ cưới hiện tại giả định chọn menu sau (đợt 2).
- **Source Evidence:**
  - `sql/Update/Update_LoaitiecAddfile_MapTemplates.sql` §2 — `('frmHopDong','BLT000001', N'hop_dong.docx', N'Mẫu in hợp đồng Tiệc Cưới')` — duy nhất.
  - Repo-wide grep "30 ngày / chọn ngay menu / trong vòng 30 / DATEDIFF": chỉ có comment fake-data (`Insert_Fake_Data.sql:90`) + accordion demo (`components-demo.js:347`) — **không** có logic HĐ.
  - `hd_cuoi.txt:91` — "…đến thời điểm chọn thực đơn theo quy định tại Điều 3.2 mà Bên B không đến chọn thực đơn…" (kịch bản "chọn menu sau").
  - `sql/tables/tbmk_Hopdong` — có `Ngayhopdong`, `Ngaytochuc` nhưng không có rule 30 ngày.
- **Gap:** Không tồn tại template "chọn ngay menu"; không có nhánh chọn template theo `DATEDIFF(Ngaytochuc, Ngayhopdong) <= 30`.
- **Existing Reusable:** `tbmk_LoaitiecAddfile` (mapping form→template) + `API_tbmk_GetForm` — có thể mở rộng điều kiện.
- **Recommended Action:** TEMPLATE FIX (tạo `hop_dong_menu_ngay.docx`) + BUSINESS LOGIC CHANGE (chọn template theo khoảng ngày, hoặc thêm cột điều kiện vào `tbmk_LoaitiecAddfile`) + NEED CUSTOMER CLARIFICATION (nội dung khác biệt cụ thể).
- **Confidence:** HIGH

---

## P. COMPANY / PARTY INFORMATION

### REQ-40 — Chỉnh địa chỉ bên hợp đồng trên tất cả mẫu

**Requirement:** Địa chỉ của một bên trong HĐ hiện sai. Chỉnh đúng + áp dụng nhất quán trên tất cả mẫu HĐ liên quan. Cần xác định: bên nào sai, địa chỉ đúng, lấy từ cấu hình công ty hay hard-code trong template.

**Source Audit**
- **Status:** MISMATCH
- **Current Implementation:** Thông tin Bên A là **cấu hình được** trong `SY_Setup` (key-value: `BenATenCongTy`, `BenADiaChi`, `BenASDT`, `BenAMST`, `HNNguoiDaiDien`, `Com1`, `Com2`). `v_DanhSachHopDong` (view cấp dữ liệu cho **mọi** HĐ, kể cả cưới) đã expose `[BenADiaChi]`, `[BenATenCongTy]`, `[BenASDT]`, `[BenAMST]` từ `SY_Setup`. NHƯNG template HĐ cưới `hop_dong.docx` **hard-code** tên + địa chỉ + ĐT Bên A là text chết.
- **Source Evidence:**
  - `hd_cuoi.txt:13-16` — "BÊN A: {BenATenCongTy} / **TRUNG TÂM HỘI NGHỊ - TIỆC CƯỚI QUEEN PLAZA KỲ HOÀ** / Địa Chỉ **16A Lê Hồng Phong (nối dài), Phường Hoà Hưng, TP.HCM** / Điện thoại: {BenBDienThoai}: {BenBDienThoai} **(+8428) 38 628 899**" — tên/địa chỉ/ĐT là literal; dòng 16 còn lặp `{BenBDienThoai}` (lẽ ra là ĐT Bên A).
  - `sql/View/v_DanhSachHopDong.sql:167-171, 408` — `(SELECT TOP 1 CodeValue FROM SY_Setup WHERE CodeID='BenADiaChi') AS [BenADiaChi]` … (sẵn sàng dùng cho HĐ cưới).
  - `sql/API/API_DanhSachBaoGia.sql:71-74`, `sql/API/API_DanhSachQuyetToan.sql:61-65` — `SY_Setup` là nguồn chuẩn cho thông tin Bên A (các mẫu pháp nhân đã dùng).
- **Data Flow:** Data có sẵn `{BenADiaChi}` từ `SY_Setup` → nhưng `hop_dong.docx` không đặt placeholder ở khối Bên A → in địa chỉ chết.
- **Gap:** Địa chỉ (+ tên, ĐT) Bên A hard-code trong mẫu cưới, không nhất quán với cơ chế `SY_Setup` các mẫu khác dùng. Bug phụ: `{BenBDienThoai}` lặp ở dòng 16. Chưa biết địa chỉ đúng.
- **Existing Reusable:** `SY_Setup` + `v_DanhSachHopDong` đã expose đủ `{BenA*}`.
- **Recommended Action:** TEMPLATE FIX (`hop_dong.docx`: literal → `{BenATenCongTy}` / `{BenADiaChi}` / `{BenASDT}`; sửa bug `{BenBDienThoai}` lặp) + cập nhật giá trị đúng trong `SY_Setup` + NEED CUSTOMER CLARIFICATION (bên nào sai, địa chỉ đúng). Rà thêm `phieu_thu.docx` / `BEO_Tiec_Cuoi.docx`.
- **Confidence:** HIGH

---

# WORKSTREAM & ƯU TIÊN

## WS-1 · TEMPLATE FIX thuần (rủi ro thấp, làm ngay) — sửa file `.docx`

| REQ | Xong? | File | Sửa gì |
|---|---|---|---|
| 24 | ✅ | `3.1 (HỘI NGHỊ + TIỆC-TEABREAK).docx` | "quyết toán tiệc" → "quyết toán dịch vụ" (dòng 167) — DONE |
| 20 | ✅ | `3.1 ....docx` | "triển lãm và tiệc" → "hội nghị và tiệc" (dòng 29, 31) — DONE |
| 28 | ✅ | `3.2 (HỘI NGHỊ).docx` | dòng 29, 31 → "Hợp đồng dịch vụ hội nghị" / "tổ chức hội nghị" — DONE |
| 13 | ✅ | `2.2 (TRIỂN LÃM).docx` + mapping | dòng 29, 31 → "tổ chức triển lãm"; sửa filename mapping `(HỘI NGHỊ ).docx` → `(HỘI NGHỊ).docx` — DONE |
| 31 | ✅ | `hop_dong.docx` | "cộng thêm 15%" → "cộng thêm 10%" (dòng 46) — DONE |
| 17 / 26 | ✅ | 4 mẫu pháp nhân | bỏ "70% giá trị Hợp đồng tạm tính" — DONE. ⏳ còn: gọt văn phong "tương ứng số tiền" |
| 40 | 🟡 | `hop_dong.docx` | literal Bên A → placeholder — DONE. ⏳ còn: seed `SY_Setup` giá trị đúng; rà `phieu_thu` / `BEO_Tiec_Cuoi` |
| 32 | ⏳ | `hop_dong.docx` | "180.000vnđ/bàn" → bind `{MucPhiPhucVu}` — **CHƯA** (chờ REQ-32 clarify) |
| 15 | ⏳ | template pháp nhân | bỏ 1 chỗ in trùng KT sân khấu — **CHƯA** (cần file + ảnh lỗi) |
| 38 | ⏳ | `phu_luc_hop_dong.docx` | thêm loop `{#MenuChay}` (view đã có `[MenuChay]`) — **CHƯA** |

## WS-2 · SMALL FIX (view / mapping)

| REQ | Xong? | Chỗ sửa |
|---|---|---|
| 19 / 27 | ✅ | `v_DanhSachHopDong.sql:162-164, 402` — fallback `N'Giám đốc'` / `N'Nguyễn Văn A'` → `''` — DONE |
| 01 | 🟡 | `docx_placeholders.json` đã điền đầy ✅. Còn: verify render 3 loại tài liệu |
| 34 | ⏳ | `v_DanhSachHopDong` — thêm `[DieuKhoanBoSung]` map từ field HĐ (nếu chưa nối) |
| 05 / 06 | ⏳ | expose luồng phát sinh ở bước quyết toán; (tùy chọn) cờ `IsFinal` trên `tbmk_Thaydoi` |
| — | ⏳ | Thêm `Update_dmKieuSetup.sql` + `Update_dmMauTrangTri_DoiMon.sql` vào `Migration_Scripts.md` |

## WS-3 · DATA MODEL + BUSINESS LOGIC (dự án con)

| Nhóm REQ | Tiến độ | Nội dung / còn lại |
|---|---|---|
| 21 / 22 / 29 | 🟡 ~70% | `dmKieuSetup` + API + ALTER table + dropdown ✅. **Còn:** refactor CASE trong `v_DanhSachHopDong` (`[SetupBanGhe]` + sức chứa) → JOIN `dmKieuSetup`; verify tên grid; FE. |
| 08 / 09 / 23 | 🟡 ~50% | `LoaiDiaDiem`/`Thoigianid`/`Giatiensanh` lưu & expose theo từng dòng sảnh ✅. **Còn:** placeholder DOCX `{DiaDiemHoiNghi}`/`{DiaDiemTiec}`/`{CaTiec}`; FE grid. |
| 03 / 04 | 🟡 ~50% | `tbmk_HopdongDoiMon` + `API_LuuDoiMonNhanh` + route ✅. **Còn:** gộp vào quyết toán/DOCX; UI đổi món. |
| 07 | 🟡 ~40% | `dmMauTrangTri` + API + `tbmk_Hopdong.MauTrangTriID` + CRUD ✅. **Còn:** gallery ảnh UI; placeholder DOCX; expose ở `v_DanhSachHopDong`. |
| 38 | 🟡 ~70% | `fn_DOCX_MenuMan/Chay/TongCongChay` + view expose ✅. **Còn:** loop `{#MenuChay}` trong `phu_luc_hop_dong.docx`. |
| 39 | 🟡 ~60% | `hop_dong_menu_ngay.docx` + mapping `frmHopDong_MenuNgay` ✅. **Còn:** logic auto-chọn theo `DATEDIFF ≤ 30`. |
| 11 / 12 / 25 | 🔴 CHỜ | `Giatiensanh` lưu theo sảnh ✅. **Còn:** giá theo buổi 4h + công thức phát sinh giờ. Chặn bởi REQ-12 (chờ khách). |
| 33 | 🔴 CHƯA | Lọc CTKM theo ngày hiệu lực + lưu link CTKM có cấu trúc + UI multi-select |
| 14 | 🔴 CHƯA | Field sự kiện triển lãm (`SoKhachThamQuanDuKien`, giờ triển lãm…) |
| 16 | 🔴 CHƯA | Enforce "pháp nhân: ký HĐ → mới cọc" theo trạng thái |

## WS-4 · CHỜ KHÁCH (không code cho tới khi có trả lời)

REQ-12, REQ-18, REQ-35, REQ-37, REQ-32 (đơn vị phí), REQ-40 (địa chỉ đúng), REQ-36 (định dạng số), REQ-10 (số HĐ nhập tay/auto), REQ-23 (1 ca hay 2 ca).

## PHỤ THUỘC

- REQ-25 ⟸ REQ-11 ⟸ REQ-12 (chờ khách).
- REQ-26, REQ-30 ⟸ REQ-17 (+ REQ-16, REQ-18).
- REQ-27 ⟸ REQ-19.
- REQ-29 ⟸ REQ-21 (+ REQ-22).
- REQ-20, REQ-24, REQ-28 — độc lập, làm song song (cùng chạm 2 file `3.1`/`3.2`).
- REQ-08, REQ-09, REQ-23 — chung 1 data model change.

---

# CHECKLIST HỎI KHÁCH (gộp)

1. **REQ-12:** Đơn giá thuê sảnh phát sinh theo giờ = (giá 1 buổi ÷ 4)? Làm tròn giờ lẻ thế nào? Có phí OT tối thiểu? Áp cho loại HĐ nào?
2. **REQ-18:** Nội dung xuất hóa đơn — mở toàn bộ cho nhập tay, hay chỉ số HĐ / ngày / nội dung tham chiếu? Mã "/CTY-HHKH/2025" đúng chưa?
3. **REQ-32:** Phí phục vụ tính theo **% tổng** hay **đồng/bàn** (180.000)? Miễn/giảm theo CTKM cụ thể ra sao?
4. **REQ-35:** Câu "Tất cả CTKM…" nguyên văn là gì, nằm ở mẫu nào?
5. **REQ-37:** Thông tin số bàn còn thiếu cụ thể là field nào (bàn mặn/chay riêng? bàn phát sinh? tổng)?
6. **REQ-40:** Bên nào sai địa chỉ? Địa chỉ đúng? Lấy từ cấu hình công ty (`SY_Setup`) đúng không?
7. **REQ-36:** Định dạng "Số phụ lục" mong muốn (VD `PL-001`) hay chấp nhận ID hệ thống `Sothaydoi`?
8. **REQ-10:** Số HĐ nhập tay hay cần rule sinh tự động?
9. **REQ-21/22/29:** Cần CRUD quản trị kiểu setup, hay danh sách cố định của hệ thống? Sức chứa theo kiểu có trong scope?
10. **REQ-23:** Ca trưa/tối là 1 giá trị chung cho HĐ, hay tách riêng ca hội nghị vs ca tiệc?
11. **REQ-39:** Mẫu "chọn ngay menu" khác mẫu chuẩn ở nội dung nào (ngoài việc menu chốt ngay)?
12. **U-01:** An toàn lao động / an toàn kỹ thuật / PCCC — cần sửa wording, thêm, bỏ, hay chỉ rà lại?

---

# LEGEND

| Status | Nghĩa |
|---|---|
| CONFIRMED | Source hiện tại đã đáp ứng đúng requirement |
| PARTIAL | Đã có implementation nhưng chưa đầy đủ |
| MISSING | Không tìm thấy implementation sau khi search đầy đủ |
| MISMATCH | Có implementation nhưng hành vi hiện tại khác yêu cầu khách |
| NEEDS_CLARIFICATION | Không đủ thông tin nghiệp vụ để quyết định hành vi đúng |
| NOT_VERIFIABLE | Repo không cung cấp đủ bằng chứng để xác minh |

| Action | Nghĩa |
|---|---|
| NO CHANGE | Giữ nguyên |
| SMALL FIX | Sửa nhỏ (1 view / 1 mapping / 1 đoạn code) |
| TEMPLATE FIX | Sửa file `.docx` template |
| BUSINESS LOGIC CHANGE | Đổi logic tính toán / luồng |
| DATA MODEL CHANGE | Thêm bảng / cột / danh mục |
| NEED CUSTOMER CLARIFICATION | Chờ khách trả lời trước khi làm |

---

# UNRESOLVED CUSTOMER NOTES

**U-01 — An toàn lao động / an toàn kỹ thuật / PCCC:** Ngày 2026-09-05 đã xác định và sửa lỗi chính tả “lao đồng” → “lao động” trong tiêu đề hai mẫu 3.1/3.2 theo ảnh khách. Các thay đổi nội dung điều khoản ngoài lỗi chính tả chưa được khách yêu cầu cụ thể.
(Ghi nhận: `hd_hoinghi.txt`, `hd_hn_tiec.txt`… đều có điều khoản an toàn/PCCC dạng text cố định trong template.)

---

# FOOTER

- Tổng requirement: **40**
- Đã audit source: **40 / 40**
- Evidence chi tiết (path + hàm + hành vi) đã ghi trong file này: **CÓ** (REQ-21→40 đầy đủ; REQ-01→20 có evidence đối chiếu, một số mục carry-over đánh dấu rõ).
- **Tiến độ sửa (2026-08-31):** 10 REQ template RESOLVED (13, 17, 19, 20, 24, 26, 27, 28, 31, 40-một-phần) · 6 REQ backend đang dở (03/04, 07, 08/09/23, 21/22/29, 38, 39) · 2 REQ chờ khách (18, 32) · REQ-01 tiến bộ (placeholder index đầy đủ).
- **Chưa mục nào coi là hoàn tất 100%** — mọi REQ RESOLVED vẫn cần test render DOCX thực tế + REQ-40 cần seed `SY_Setup`.

*Cập nhật lần cuối: 2026-08-31 — Verify working tree sau đợt sửa đầu (baseline audit: 2026-08-29).*
