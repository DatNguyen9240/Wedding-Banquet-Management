# CẤU HÌNH HỆ THỐNG THAY ĐỔI - BỔ SUNG HỢP ĐỒNG (THAY ĐỔI BEO)

Dưới đây là cấu hình hiện tại của hệ thống No-Code liên quan đến chức năng thay đổi, bổ sung thông tin hợp đồng trước khi diễn ra tiệc cưới/hội nghị.

---

## 1. Cấu hình định tuyến API Gateway (WA_API)
Bảng `WA_API` định nghĩa các hàm xử lý dữ liệu qua API Gateway:

| List / Form | Func | Stored Procedure (SQL) | Parameters (Para) |
| :--- | :--- | :--- | :--- |
| `frmThayDoiBoSung` | `View` | `API_TruyVanDong` | `@List=N'frmThayDoiBoSung', @Keyword=N'{Keyword}', @SortColumn=N'{SortColumn}', @SortDir=N'{SortDir}', @Data=N'{JsonData}'` |
| `frmThayDoiBoSung` | `Save` | `API_LuuTruongGiaoDien` | `@FormName=N'frmThayDoiBoSung', @FieldName=N'{FieldName}', @CaptionVN=N'{CaptionVN}', ...` |
| `frmThayDoiBoSung` | `Delete` | `API_XoaDong` | `@List=N'{List}', @Ids=N'{Ids}', @UserName=N'{User}'` |
| `tbmk_Thaydoi` | `Add` | `API_LuuDong` | `@List=N'tbmk_Thaydoi', @Data=N'{JsonData}'` |
| `tbmk_Thaydoi` | `View` | `API_tbmk_Thaydoi_View` | `@Keyword=N'{Keyword}', @Sothaydoi=N'{Sothaydoi}'` |
| `API_tbmk_Thaydoi_View` | `Execute` | `API_tbmk_Thaydoi_View` | `@Keyword=N'{Keyword}', @Sothaydoi=N'{Sothaydoi}'` |

---

## 2. Danh sách các Form liên quan (SY_FrmLstTbl)
Thông tin các form thay đổi bổ sung được đăng ký trong hệ thống:

*   **`frmThayDoiBoSung`** (Loại: `LISTEDIT2`):
    *   Tên hiển thị: **Phiếu Thay Đổi - Bổ sung**
    *   Bảng liên kết chính: `tbmk_Hopdong`
    *   Khóa chính: `Sohopdong`
*   **`tbmk_Thaydoi`** (Loại: `LISTEDIT2`):
    *   Tên hiển thị: **Danh mục thay đổi**
    *   Bảng liên kết chính: `tbmk_Thaydoi`
    *   Khóa chính: `Sothaydoi`
*   **Các Form chỉnh sửa trực quan (EDIT)**:
    *   `QueenThayDoiHopDongDatTiecFrm`: Thay đổi - Bổ sung hợp đồng tiệc (Queen)
    *   `QueenThayDoiHopDongHoiNghiFrm`: Thay đổi - Bổ sung hợp đồng hội nghị (Queen)
    *   `tbmkBiennhancocchoThaydoiFrm`: Biên nhận cọc chỗ thay đổi
    *   `ThayDoiHopDongDatTiecFrm`: Thay đổi - Bổ sung hợp đồng tiệc
    *   `ThayDoiHopDongDatTiecViewFrm`: Xem thay đổi - Bổ sung hợp đồng tiệc
    *   `ThayDoiHopDongHoiNghiFrm`: Thay đổi - Bổ sung hợp đồng hội nghị
    *   `ThayDoiHopDongHoiNghiViewFrm`: Xem thay đổi - Bổ sung hợp đồng hội nghị

---

## 3. Bản chất nghiệp vụ dữ liệu
1.  **`frmThayDoiBoSung`** đứng ở vai trò quản lý danh sách các hợp đồng cần thay đổi. Vì liên kết trực tiếp với `tbmk_Hopdong` qua khóa `Sohopdong`, trang này hiển thị danh sách các Hợp đồng đang hoạt động.
2.  Khi phát sinh thay đổi chi tiết, dữ liệu thay đổi sẽ được tạo mới và đẩy vào bảng **`tbmk_Thaydoi`** (lưu số phiếu thay đổi `Sothaydoi`, ngày thay đổi, lần thay đổi `LanThayDoi`,...) và chi tiết các dòng dịch vụ sửa đổi nằm ở bảng **`tbmk_Thaydoichitiet`**.
3.  Khi in BEO hoặc in Quyết toán tiệc, ta sẽ truy vấn `tbmk_Thaydoi` có `LanThayDoi` lớn nhất của `Sohopdong` tương ứng để lấy ra dữ liệu thực đơn/dịch vụ mới nhất.
