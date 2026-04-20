# ARCHITECTURE.md — PMQLTiec (Phần mềm Quản lý Tiệc Cưới)
## Web App + PWA — Cấu trúc Module hóa theo chuẩn Medstand

---

## 1. Tổng quan Kiến trúc

Ứng dụng là một **SPA (Single Page Application)** dạng **Hash-based routing** (`#/path`) — không dùng framework nặng, chạy thuần HTML + Vanilla JS + CSS. Mô hình lấy cảm hứng từ chuẩn của dự án `Medstand` (đã hoạt động thực tế).

- **Routing**: `src/js/core/router.js` — lắng nghe `hashchange`, load template HTML vào `#app-content`, load CSS và JS động theo route
- **Components**: Các UI Component được viết dạng ES5 Prototype (dùng chung giữa các trang)
- **Templates**: Các file HTML nhỏ (`src/templates/...`) — được fetch và inject vào shell `index.html`
- **Services**: Các file giao tiếp Backend API (`Http.get`, `Http.post`) qua `src/js/services/http.js`
- **PWA**: `sw.js` (Service Worker) + `manifest.json` — hỗ trợ cache offline, cài đặt như app
- **Responsive**: Mobile-first (< 768px) kết hợp Desktop layout (> 768px) qua CSS Media Query

---

## 2. Cấu trúc Thư mục

```
Wedding-Banquet-Management/
│
├── index.html                         # Shell: chứa #sidebar-container, #app-header, #app-content, #nav-container
├── login.html                         # Trang Login standalone (ngoài SPA)
├── sw.js                              # Service Worker: Cache-first (static), Network-first (API)
├── manifest.json                      # PWA Manifest (tên App, icon, màu theme)
├── env.js                             # Biến môi trường: BASE_URL, API_URL
├── images/                            # Icons, logo nhà hàng, ảnh minh hoạ
│
└── src/
    ├── css/
    │   ├── design-tokens.css          # ⭐ Biến CSS toàn cục: màu, font, spacing, shadow, radius
    │   ├── global.css                 # Reset, body, .btn, .form-control, scrollbar, route-spinner
    │   │
    │   ├── layouts/
    │   │   └── desktop.css            # Sidebar + Content layout khi màn hình > 768px
    │   │
    │   ├── components/                # Styles cho từng Component dùng chung
    │   │   ├── header.css             # App header, logo, avatar
    │   │   ├── nav-bar.css            # Bottom navigation (Mobile)
    │   │   ├── card.css               # Card container (thông tin, stat)
    │   │   ├── data-table.css         # Bảng dữ liệu (.data-table)
    │   │   ├── forms.css              # Nhóm Form chung (.form-grid, .form-field)
    │   │   ├── input.css              # Input field, date picker, select trigger
    │   │   ├── filter.css             # Filter bottom-sheet modal + overlay
    │   │   ├── form-select.css        # FormSelect picker component
    │   │   ├── tabs.css               # Tab navigation (Hợp đồng có 9 tabs)
    │   │   ├── confirm-modal.css      # Modal xác nhận Xóa/Lưu
    │   │   ├── pagination.css         # Phân trang bảng dữ liệu
    │   │   ├── loading-spinner.css    # Spinner khi chuyển trang
    │   │   ├── skeleton.css           # Skeleton loading placeholder
    │   │   ├── fab.css                # Floating Action Button (Thêm mới)
    │   │   ├── segment.css            # Segment control (chuyển tab kiểu pill)
    │   │   ├── list.css               # Danh sách dạng card list
    │   │   ├── total-bar.css          # Thanh tổng tiền cố định dưới màn hình
    │   │   └── chart.css              # Biểu đồ báo cáo
    │   │
    │   └── pages/                     # CSS riêng cho từng trang (chỉ load khi vào trang đó)
    │       ├── auth.css               # Login, Register
    │       ├── home.css               # Dashboard - Lịch tiệc tháng
    │       ├── visitor.css            # Khách tham quan
    │       ├── booking.css            # Biên nhận cọc chỗ (lần 1, 2)
    │       ├── contract.css           # Hợp đồng tiệc (form nhiều tabs)
    │       ├── checkout.css           # Quyết toán tiệc
    │       ├── calendar.css           # Lịch tiệc (màu Xanh/Đỏ, ký hiệu X)
    │       ├── categories.css         # Danh mục hàng hoá, khu vực, nhóm hàng
    │       ├── system.css             # Hệ thống: user, phân quyền, cấu hình
    │       └── reports.css            # Báo cáo thống kê, doanh thu
    │
    ├── js/
    │   ├── core/
    │   │   └── router.js              # ⭐ SPA Router: hash routing, template fetch, dynamic CSS/JS load
    │   │                              #    Hỗ trợ: auth guard, route spinner, fade transition, 404 page
    │   │                              #    Mobile: ẩn nav/header khi keyboard mở (focusin/focusout)
    │   │
    │   ├── components/                # UI Components Prototype-based (dùng lại nhiều trang)
    │   │   ├── Alert.js               # Toast thông báo (success, error, warning)
    │   │   ├── ConfirmModal.js        # Dialog xác nhận (Xóa, Hủy hợp đồng)
    │   │   ├── FilterComponent.js     # ⭐ Bộ lọc bottom-sheet: ngày từ-đến + các field select
    │   │   │                          #    Tự lưu state vào localStorage theo từng trang
    │   │   ├── FormSelect.js          # ⭐ Form nhập liệu nâng cao: addInput + addList (modal picker)
    │   │   │                          #    Method: setValue, setListValue, getValues, reset, setLocked
    │   │   ├── Input.js               # Helper render HTML: renderField, renderDate, renderSelect, renderSearch
    │   │   ├── NavBar.js              # Bottom Nav (Mobile) + Sidebar (Desktop)
    │   │   ├── Pagination.js          # Component phân trang (prev/next/page numbers)
    │   │   ├── SearchBar.js           # Thanh tìm kiếm nhanh
    │   │   ├── TotalBar.js            # Thanh tổng tiền sticky dưới màn hình
    │   │   ├── LoadingSpinner.js      # Spinner inline
    │   │   ├── Chart.js               # Wrapper biểu đồ Chart.js
    │   │   ├── AuthThemeToggle.js     # Toggle Dark/Light mode (trang auth)
    │   │   ├── PasswordToggle.js      # Hiện/ẩn mật khẩu
    │   │   │
    │   │   │   ── [MỚI CẦN TẠO CHO PMQLTiec] ──
    │   │   ├── DataGrid.js            # Bảng dữ liệu click chọn dòng (highlight xanh)
    │   │   │                          #    Hỗ trợ: click dòng → lưu selected row, double-click → edit
    │   │   ├── ButtonBar.js           # Thanh nút: [Thêm][Sửa][Xóa][Lọc][In][Đóng]
    │   │   │                          #    Nhận callbacks: onAdd, onEdit, onDelete, onFilter, onPrint, onClose
    │   │   ├── TabPanel.js            # Component quản lý nhiều Tab (Hợp đồng có 9 tabs)
    │   │   └── LunarCalendar.js       # Chuyển đổi Dương lịch ↔ Âm lịch (hỗ trợ tên năm Can Chi)
    │   │
    │   ├── services/
    │   │   ├── http.js                # ⭐ HTTP wrapper: get/post/put/delete + token auth + cache + retry
    │   │   ├── auth.service.js        # Login, logout, token refresh, kiểm tra auth
    │   │   ├── banquet.service.js     # API Hợp đồng, Cọc chỗ, Quyết toán, Khách tham quan
    │   │   ├── categories.service.js  # API Danh mục hàng hoá, khu vực, nhóm hàng
    │   │   ├── reports.service.js     # API Báo cáo thống kê, doanh thu, khảo sát
    │   │   └── system.service.js      # API Người dùng, phân quyền, cấu hình hệ thống
    │   │
    │   ├── utils/
    │   │   ├── format.js              # Format tiền VNĐ, ngày tháng, removeAccents (tìm kiếm không dấu)
    │   │   ├── debounce.js            # Debounce function (dùng cho search input)
    │   │   ├── theme.js               # Quản lý Dark/Light mode (localStorage + data-theme attribute)
    │   │   └── lunar.js               # Thư viện tính Âm lịch thuần JS (chuyển đổi, tên năm Can Chi)
    │   │
    │   ├── config/
    │   │   ├── routes.js              # Khai báo tất cả ROUTES: { path, template, scripts, css, auth, nav, title }
    │   │   └── filter-fields.js       # Cấu hình trường lọc tái sử dụng theo trang
    │   │
    │   ├── schemas/
    │   │   └── contract.schema.js     # Khai báo cấu trúc form Hợp đồng (các tab, fields, validation rules)
    │   │
    │   └── pages/                     # Logic nghiệp vụ riêng từng trang (load theo route)
    │       ├── index.js               # Boot: khởi tạo Router.init() và global listeners
    │       ├── home.js                # Dashboard: thống kê nhanh, lịch tiệc tháng
    │       ├── system/
    │       │   ├── users.js           # Danh sách người dùng (CRUD + DataGrid)
    │       │   ├── permissions.js     # Phân quyền theo nhóm/user
    │       │   └── settings.js        # Thiết lập thông số hệ thống (3 tabs: Công ty, Kỳ, Khác)
    │       ├── categories/
    │       │   ├── items.js           # Hàng hoá (CRUD, giá bán theo ngày, định lượng)
    │       │   ├── customers.js       # Đối tượng khách hàng
    │       │   ├── regions.js         # Khu vực
    │       │   └── calendar-setup.js  # Tạo ngày Âm/Dương lịch
    │       └── banquet/
    │           ├── visitor.js         # Khách tham quan
    │           ├── booking1.js        # Biên nhận cọc chỗ lần 1
    │           ├── booking1-change.js # Thay đổi biên nhận cọc lần 1
    │           ├── booking2.js        # Biên nhận cọc chỗ lần 2
    │           ├── booking2-change.js # Thay đổi biên nhận cọc lần 2
    │           ├── contract.js        # Hợp đồng tiệc (9 tabs: Bàn, Sảnh, Thực đơn, Ưu đãi...)
    │           ├── contract-deposit.js# Cọc hợp đồng lần 2
    │           ├── contract-change.js # Thay đổi - Bổ sung hợp đồng
    │           ├── arrangement.js     # Thông tin sắp đặt tiệc
    │           ├── checkout.js        # Quyết toán tiệc (tabs: Bàn, Thức uống, Phát sinh, Giảm giá)
    │           ├── calendar.js        # Lịch tiệc tháng (Xanh: cọc, Đỏ: hợp đồng, X: sảnh phụ)
    │           └── survey.js          # Khảo sát thông tin khách hàng sau tiệc
    │
    └── templates/                     # HTML partial — inject vào #app-content qua Router
        ├── home.html
        ├── system/
        │   ├── users.html
        │   ├── permissions.html
        │   └── settings.html
        ├── categories/
        │   ├── items.html
        │   ├── customers.html
        │   ├── regions.html
        │   └── calendar-setup.html
        └── banquet/
            ├── visitor.html
            ├── booking1.html
            ├── booking1-change.html
            ├── booking2.html
            ├── booking2-change.html
            ├── contract.html           # Form phức tạp nhất: 9 tabs
            ├── contract-deposit.html
            ├── contract-change.html
            ├── arrangement.html
            ├── checkout.html           # 4 tabs: Bàn, Thức uống, Phát sinh, Giảm giá
            ├── calendar.html           # Lịch tháng dạng CSS Grid
            └── survey.html
```

---

## 3. Quy tắc Code (Coding Standards)

### 3.1 Router — Định nghĩa Route
Mỗi route được khai báo trong `config/routes.js` theo format:
```js
{ 
  path: 'contract',                           // URL hash: #/contract
  template: 'src/templates/banquet/contract.html',
  scripts: ['src/js/pages/banquet/contract.js'],
  css: ['src/css/components/tabs.css', 'src/css/pages/contract.css'],
  auth: true,
  nav: 'banquet',
  title: 'Hợp đồng tiệc'
}
```

### 3.2 CSS — Thứ tự Load
```html
<!-- Trong index.html, load tĩnh -->
<link rel="stylesheet" href="src/css/design-tokens.css"> <!-- 1. Biến -->
<link rel="stylesheet" href="src/css/global.css">        <!-- 2. Reset + Utility -->
<link rel="stylesheet" href="src/css/layouts/desktop.css"> <!-- 3. Layout -->
<!-- Components CSS load tĩnh theo nhóm -->
<!-- Page CSS load động theo Route qua Router._loadCSS() -->
```

### 3.3 Component Pattern (Prototype-based)
```js
// Khởi tạo DataGrid
var grid = new DataGrid({
  container: '#data-container',
  columns: [
    { key: 'MaHD', label: 'Mã HĐ', width: '100px' },
    { key: 'TenKhach', label: 'Tên khách hàng' },
    { key: 'NgayToChuc', label: 'Ngày tổ chức', type: 'date' },
    { key: 'TongTien', label: 'Tổng tiền', type: 'currency' }
  ],
  onRowClick: function(row) { selectedRow = row; },
  onRowDblClick: function(row) { openEditForm(row); }
});
grid.load(dataArray);
```

```js
// ButtonBar với callbacks
var btnBar = new ButtonBar({
  container: '#btn-container',
  onAdd:    function() { openAddForm(); },
  onEdit:   function() { if (!selectedRow) return Alert.warn('Chọn dòng cần sửa'); openEditForm(selectedRow); },
  onDelete: function() { if (!selectedRow) return; ConfirmModal.show('Xóa?', function() { deleteRecord(selectedRow.id); }); },
  onFilter: function() { filterComponent.open(); },
  onPrint:  function() { window.print(); },
  onClose:  function() { Router.navigate('home'); }
});
```

### 3.4 FormSelect — Nhập liệu Form
```js
// Tạo form nhập liệu cho Biên nhận cọc chỗ
var fs = new FormSelect({ container: '#form-fields' });
fs.addInput({ id: 'NgayLap', label: 'Ngày lập', type: 'date', value: today })
  .addList({ id: 'MaKhach', label: 'Khách hàng', required: true,
    loadFn: function(done) { CustomerService.getAll().then(done); },
    full: true })
  .addInput({ id: 'NgayToChuc', label: 'Ngày tổ chức (DL)', type: 'date', required: true })
  .addInput({ id: 'NgayAmLich', label: 'Ngày âm lịch', locked: true })
  .addInput({ id: 'SoBanMan', label: 'Số bàn mặn', type: 'number' });

// Khi chọn Ngày tổ chức → tự động fill Ngày âm lịch
fs.onListChange('NgayToChuc', function(val) {
  var lunar = LunarCalendar.toLunar(val);
  fs.setValue('NgayAmLich', lunar.display);
});
```

### 3.5 FilterComponent — Lọc dữ liệu
```js
// Ví dụ: Lọc báo cáo doanh thu
var filter = new FilterComponent({
  container: '#filter-container',
  storageKey: 'revenue_filter',         // Tên key trong localStorage
  fields: [
    { key: 'SanhTiec', label: 'Sảnh tiệc', options: [] },
    { key: 'NhanVienSales', label: 'Nhân viên Sales', options: [] }
  ],
  onApply: function(result) {
    loadRevenueData(result.dateFrom, result.dateTo, result.filters);
  }
});
// Load options async sau
SanhService.getAll().then(function(list) {
  filter.setFieldOptions('SanhTiec', list.map(function(s) {
    return { value: s.ID, label: s.TenSanh };
  }));
});
```

---

## 4. Design Tokens — Bảng màu & Biến CSS

Tất cả màu sắc, font, spacing, animation đều khai báo trong `design-tokens.css` theo chuẩn Medstand. Hỗ trợ **Dark Mode** tự động qua `[data-theme="dark"]`.

| Token | Light | Dark |
|---|---|---|
| `--color-primary` | `#3c50e0` | `#3c50e0` |
| `--color-background` | `#f1f5f9` | `#1a222c` |
| `--color-surface` | `#ffffff` | `#1c2536` |
| `--color-text` | `#1c2434` | `#dee4ee` |
| `--color-success` | `#10b981` | `#10b981` |
| `--color-danger` | `#ef4444` | `#ef4444` |
| `--color-warning` | `#f59e0b` | `#f59e0b` |
| **Lịch xanh** (Cọc chỗ) | `--color-booking: #22c55e` | — |
| **Lịch đỏ** (Hợp đồng) | `--color-contract: #ef4444` | — |

> **Ghi chú:** Cần bổ sung thêm 2 token `--color-booking` và `--color-contract` vào `design-tokens.css` dành cho hiển thị Lịch tiệc.

---

## 5. Luồng Dữ liệu Tiệc Cưới (Data Pipeline)

```
Khách Tham Quan (visitor)
    ↓  [transferData(visitorId, 'booking1')]
Biên Nhận Cọc Lần 1 (booking1)
    ↓  ← Thay đổi BN Cọc Lần 1 (booking1-change) [optional]
    ↓  ← Biên Nhận Cọc Lần 2 (booking2) [optional]
    ↓  ← Thay đổi BN Cọc Lần 2 (booking2-change) [optional]
    ↓  [transferData(bookingId, 'contract')]
Hợp Đồng Tiệc (contract) — 9 Tabs
    ↓  ← Cọc HĐ Lần 2 (contract-deposit) [optional]
    ↓  ← Thay đổi - Bổ sung (contract-change) [optional]
    ↓  ← Thông tin sắp đặt (arrangement)
    ↓  [transferData(contractId, 'checkout')]
Quyết Toán Tiệc (checkout) — 4 Tabs
    ↓
KẾT THÚC → Sảnh trống, sẵn sàng nhận tiệc mới
```

Hàm `transferData(sourceId, destType)` trong `banquet/utils.js`:
- Fetch dữ liệu nguồn từ API
- Map fields tương ứng (tên, ngày tổ chức, số bàn, tiền cọc...)
- Pre-fill vào form đích, allow user chỉnh sửa trước khi save

---

## 6. PWA — Chiến lược Cache (sw.js)

| Loại Request | Chiến lược | Ghi chú |
|---|---|---|
| HTML/CSS/JS/Images | Cache-first | Tải nhanh, offline OK |
| API calls (`/api/*`) | Network-first → fallback cache | Ưu tiên data mới |
| Font Google | Cache-first (1 năm) | Tốc độ load text |

**Offline UX:** Khi mất mạng, hiển thị banner cảnh báo. Các form nhập liệu vẫn dùng được với dữ liệu đã cache. Khi có mạng trở lại, tự động sync queue các request chưa gửi.

---

## 7. Responsive Breakpoints

```css
/* Mobile first (default) — < 768px */
/* Tablet — 768px */
@media (min-width: 768px) { ... }
/* Desktop — 1024px */
@media (min-width: 1024px) { ... }
/* Wide Desktop — 1280px */
@media (min-width: 1280px) { ... }
```

| Element | Mobile | Desktop |
|---|---|---|
| Navigation | Bottom Nav Bar (fixed) | Left Sidebar (collapsible) |
| DataGrid | List Cards | Full Table |
| Contract Tabs | Swipe / Accordion | Tab Bar ngang |
| Form Fields | 1 cột | 2-3 cột (grid) |
| ButtonBar | FAB (+) / Bottom sheet | Toolbar ngang |

---

## 8. Naming Convention (Quy tắc Đặt tên)

Áp dụng nhất quán toàn dự án, tránh tình trạng mỗi người đặt tên theo ý khác nhau.

### 8.1 File & Thư mục
| Loại | Quy tắc | Ví dụ |
|---|---|---|
| Template HTML | `kebab-case.html` | `booking1-change.html` |
| Page JS | `kebab-case.js` | `contract-deposit.js` |
| Component JS | `PascalCase.js` | `DataGrid.js`, `ButtonBar.js` |
| Service JS | `kebab-case.service.js` | `banquet.service.js` |
| CSS Component | `kebab-case.css` | `data-table.css`, `tabs.css` |
| CSS Page | `kebab-case.css` trùng tên page | `contract.css` ↔ `contract.js` |
| Schema JS | `kebab-case.schema.js` | `contract.schema.js` |
| Thư mục | `kebab-case/` | `banquet/`, `categories/` |

### 8.2 Biến & Hàm trong JS
| Loại | Quy tắc | Ví dụ |
|---|---|---|
| Biến cục bộ | `camelCase` | `selectedRow`, `currentPage` |
| Hàm | `camelCase`, động từ đầu | `loadData()`, `openEditForm()` |
| Hằng số | `UPPER_SNAKE_CASE` | `MAX_TABLE_COUNT`, `API_BASE_URL` |
| Constructor/Component | `PascalCase` | `new DataGrid()`, `new FormSelect()` |
| Private (quy ước) | Tiền tố `_` | `_currentRoute`, `_loadedScripts` |
| ID HTML (tương tác JS) | `kebab-case` | `#app-content`, `#btn-container` |

### 8.3 CSS Class
| Loại | Quy tắc | Ví dụ |
|---|---|---|
| Component wrapper | `component-name` | `.data-grid`, `.button-bar` |
| Element con | `component__element` | `.data-grid__row`, `.tab-panel__header` |
| Trạng thái | `is-` hoặc `has-` | `.is-selected`, `.has-value`, `.is-loading` |
| Status nghiệp vụ | `status-` | `.status-booking`, `.status-contract` |
| Layout utility | Dùng token, không dùng số magic | `gap: var(--spacing-md)` ✅ `gap: 16px` ❌ |

### 8.4 API Field & DB Column
- Dùng **PascalCase** cho tất cả field trả về từ Backend (theo chuẩn C#/SQL): `MaHD`, `TenKhach`, `NgayToChuc`
- Biến JS giữ nguyên tên field để dễ map: `var maHD = row.MaHD;`

---

## 9. Component → Trang Sử dụng (Dependency Map)

Bảng này giúp biết ngay: **sửa component X sẽ ảnh hưởng trang nào**, tránh regression bug.

| Component | Trang sử dụng |
|---|---|
| `DataGrid.js` | users, items, customers, regions, visitor, booking1, booking2, contract-list, checkout, reports |
| `ButtonBar.js` | **Tất cả trang** có CRUD (từ users → checkout) |
| `FilterComponent.js` | visitor, booking1, booking2, contract-list, checkout, reports, revenue |
| `FormSelect.js` | booking1, booking1-change, booking2, booking2-change, contract, contract-change, checkout, arrangement |
| `TabPanel.js` | contract (9 tabs), checkout (4 tabs), settings (3 tabs) |
| `LunarCalendar.js` | booking1, contract, calendar (lịch tiệc) |
| `TotalBar.js` | contract, checkout |
| `ConfirmModal.js` | Mọi trang có nút Xóa hoặc Hủy hợp đồng |
| `Alert.js` | **Tất cả trang** (thông báo success/error sau mỗi action) |
| `Pagination.js` | visitor, booking1, booking2, reports, revenue |
| `Chart.js` | home (dashboard), reports |

> [!WARNING]
> Trước khi sửa `DataGrid.js`, `ButtonBar.js` hoặc `Alert.js` — phải test lại **toàn bộ trang** vì chúng được dùng ở mọi nơi.

---

## 10. Error Handling Strategy (Chiến lược xử lý Lỗi)

Mọi lỗi phải được xử lý theo **một chuẩn duy nhất** — không để lỗi âm thầm, không `console.log` trần.

### 10.1 Lỗi API (Network / Server)
```js
// ✅ ĐÚNG — chuẩn toàn dự án
BanquetService.getContracts(filters)
  .then(function(data) {
    grid.load(data);
  })
  .catch(function(err) {
    // Lỗi 401: tự động redirect login (http.js xử lý)
    // Lỗi 403: hiện thông báo không có quyền
    // Lỗi 4xx/5xx: hiện toast lỗi
    Alert.error(err.message || 'Không thể tải dữ liệu. Vui lòng thử lại.');
  });

// ❌ SAI — không để lỗi âm thầm
BanquetService.getContracts(filters).then(function(data) { grid.load(data); });
```

### 10.2 Lỗi Validation Form (trước khi submit)
```js
// Validate tập trung trước khi gọi API
function validateBookingForm(values) {
  if (!values.MaKhach)       return 'Vui lòng chọn khách hàng';
  if (!values.NgayToChuc)    return 'Vui lòng nhập ngày tổ chức';
  if (values.SoBanMan < 1)   return 'Số bàn mặn phải ≥ 1';
  return null; // null = hợp lệ
}

var err = validateBookingForm(fs.getValues());
if (err) return Alert.warn(err);
// Tiếp tục gọi API...
```

### 10.3 Lỗi Xóa / Hủy hợp đồng (Destructive action)
```js
// Luôn dùng ConfirmModal trước khi thực hiện
ConfirmModal.show({
  title: 'Xác nhận xóa',
  message: 'Bạn có chắc muốn xóa hợp đồng ' + row.MaHD + '?',
  confirmText: 'Xóa',
  danger: true,
  onConfirm: function() {
    BanquetService.deleteContract(row.ID)
      .then(function() { Alert.success('Đã xóa hợp đồng'); grid.removeRow(row.ID); })
      .catch(function(err) { Alert.error(err.message); });
  }
});
```

### 10.4 HTTP Status Codes — Xử lý tập trung trong `http.js`
| Status | Xử lý |
|---|---|
| `401 Unauthorized` | Xóa token + redirect `login.html` |
| `403 Forbidden` | `Alert.error('Bạn không có quyền thực hiện')` |
| `404 Not Found` | `Alert.error('Không tìm thấy dữ liệu')` |
| `422 Validation` | Lấy message từ response body, hiện `Alert.warn()` |
| `500 Server Error` | `Alert.error('Lỗi máy chủ, vui lòng liên hệ kỹ thuật')` |
| Network timeout | `Alert.error('Mất kết nối, kiểm tra đường truyền')` |

---

## 11. Validation Rules — Form Nghiệp vụ Quan trọng

### 11.1 Biên nhận Cọc chỗ Lần 1
| Field | Rule |
|---|---|
| Khách hàng | Bắt buộc chọn |
| Ngày lập | Bắt buộc, ≤ hôm nay |
| Ngày tổ chức | Bắt buộc, ≥ hôm nay + 7 ngày |
| Sảnh chính | Phải đánh dấu ít nhất 1 sảnh là "sảnh chính" |
| Sảnh | Không được trùng với tiệc đã đặt cùng ngày |
| Số bàn mặn | ≥ 1 nếu có đặt bàn mặn |
| Tiền cọc | ≥ 0, ≤ tổng giá trị dự kiến |

### 11.2 Hợp đồng Tiệc
| Field | Rule |
|---|---|
| Số hợp đồng | Bắt buộc, không dấu, không ký tự đặc biệt, không trùng |
| Ngày tổ chức | Phải khớp hoặc sau ngày cọc chỗ |
| Sảnh chính | Bắt buộc đánh dấu 1 sảnh là chính |
| Giá bàn mặn/chay | > 0 |
| Tab Thực đơn | Nếu không phải combo, đơn giá từng món phải > 0 |
| Tổng cọc HĐ | Cảnh báo nếu < 40% tổng giá trị (không block) |

### 11.3 Quyết toán Tiệc
| Field | Rule |
|---|---|
| Hợp đồng | Bắt buộc chọn, phải ở trạng thái "Đã ký" |
| Số bàn thực tế | ≥ số bàn trong hợp đồng (cảnh báo nếu khác) |
| Thức uống | Số lượng ≥ 0 |
| Giảm giá | ≤ tổng giá trị quyết toán |
| Lưu QT | Sau khi lưu → hợp đồng đổi trạng thái "Đã quyết toán", sảnh được giải phóng |

---

## 12. Changelog (Lịch sử Thay đổi)

> Mỗi khi thêm tính năng mới, thay đổi kiến trúc hoặc component quan trọng, **cập nhật bảng này**.

| Ngày | Người thực hiện | Thay đổi |
|---|---|---|
| 2026-04-20 | Init | Khởi tạo ARCHITECTURE.md theo chuẩn Medstand |
| — | — | — |

**Quy tắc Changelog:**
- Format ngày: `YYYY-MM-DD`
- Mô tả ngắn gọn, đủ để hiểu đã thay đổi gì
- Khi xóa/đổi tên component → ghi rõ để các trang liên quan biết cần cập nhật

---

## 13. Keyboard Shortcut System (F2, F3, F4, Space)

Phần mềm này mang phong cách **Windows Desktop App** — người dùng quen thao tác bàn phím nhanh. Đây là tính năng **đặc trưng bắt buộc** theo `required.md`.

### 13.1 Bảng Phím tắt Toàn cục

| Phím | Ngữ cảnh | Hành động |
|---|---|---|
| `F2` | Combo box / Dropdown đang focus | Mở form thêm mới danh mục |
| `F3` | Combo box / Dropdown đang focus | Mở form danh sách tra cứu / chọn |
| `F4` | Combo box đang focus | Mở dropdown list (tương đương click mũi tên) |
| `Space` | Checkbox đang focus | Toggle checked / unchecked |
| `Enter` | Nút đang focus, Input cuối form | Submit / Lưu form |
| `Esc` | Modal/Form phụ đang mở | Đóng form phụ |

### 13.2 Kiến trúc Implementation — `KeyboardManager`

Tạo file `src/js/core/KeyboardManager.js` — quản lý tập trung, tránh mỗi trang tự bind riêng.

```js
/**
 * KeyboardManager — Quản lý phím tắt tập trung
 * Bind 1 lần duy nhất lên document, dispatch xuống element đang focus
 */
var KeyboardManager = (function () {

  function init() {
    document.addEventListener('keydown', function (e) {
      var target = document.activeElement;
      if (!target) return;

      switch (e.key) {
        case 'F2':
          e.preventDefault();
          _dispatch(target, 'kb:new');       // Thêm mới danh mục
          break;
        case 'F3':
          e.preventDefault();
          _dispatch(target, 'kb:lookup');    // Mở danh sách tra cứu
          break;
        case 'F4':
          e.preventDefault();
          _dispatch(target, 'kb:open');      // Mở dropdown
          break;
        case ' ':
          if (target.type === 'checkbox') {
            e.preventDefault();
            target.checked = !target.checked;
            target.dispatchEvent(new Event('change', { bubbles: true }));
          }
          break;
        case 'Escape':
          _dispatch(target, 'kb:close');
          break;
      }
    });
  }

  // Bubble custom event lên DOM để component tự lắng nghe
  function _dispatch(el, eventName) {
    el.dispatchEvent(new CustomEvent(eventName, { bubbles: true, cancelable: true }));
  }

  return { init: init };
})();
```

### 13.3 Cách Component lắng nghe phím tắt

Mỗi component (`UIComboBox`, `UIDropdown`) tự đăng ký lắng nghe custom event trên phần tử của nó:

```js
// Trong UIComboBox constructor
this.$input.addEventListener('kb:open', function () {
  self._openDropdown();          // F4 → mở dropdown
});
this.$input.addEventListener('kb:lookup', function () {
  self._openLookupModal();       // F3 → mở form tra cứu
});
this.$input.addEventListener('kb:new', function () {
  self._openAddNewForm();        // F2 → mở form thêm mới
});
```

### 13.4 Khởi tạo tại Boot

```js
// src/js/pages/index.js — chạy 1 lần khi app khởi động
KeyboardManager.init();
Router.init();
```

> [!NOTE]
> `KeyboardManager` chỉ bind **1 lần** lên `document`. Không bind `keydown` trực tiếp trong từng page script để tránh memory leak và xung đột phím khi chuyển trang.

---

## 14. Permission-based UI (Phân quyền Giao diện)

Hệ thống có 4 quyền theo `required.md`: **Xem, Thêm, Sửa, Xóa**. Frontend phải **phản ánh đúng quyền** — ẩn nút, vô hiệu hóa action, không chỉ dựa vào Backend chặn API.

### 14.1 Cấu trúc Permission Object

```js
// Lưu vào localStorage sau khi login thành công
// window.APP_PERMISSIONS — đọc toàn cục
{
  "QuanTriHeThong": { "xem": true,  "them": true,  "sua": true,  "xoa": true  },
  "DanhMuc":        { "xem": true,  "them": true,  "sua": true,  "xoa": false },
  "HopDong":        { "xem": true,  "them": true,  "sua": true,  "xoa": false },
  "QuyetToan":      { "xem": true,  "them": false, "sua": false, "xoa": false },
  "BaoCao":         { "xem": true,  "them": false, "sua": false, "xoa": false }
}
```

### 14.2 Permission Helper — `src/js/utils/permission.js`

```js
var Permission = (function () {
  function _get(module) {
    var perms = JSON.parse(localStorage.getItem('app_permissions') || '{}');
    return perms[module] || { xem: false, them: false, sua: false, xoa: false };
  }

  return {
    canView:   function (module) { return _get(module).xem; },
    canAdd:    function (module) { return _get(module).them; },
    canEdit:   function (module) { return _get(module).sua; },
    canDelete: function (module) { return _get(module).xoa; }
  };
})();
```

### 14.3 Áp dụng trong ButtonBar

`ButtonBar.js` nhận thêm `module` để tự động ẩn nút theo quyền:

```js
var btnBar = new ButtonBar({
  container: '#btn-container',
  module: 'HopDong',           // ← Tên module để kiểm tra quyền
  onAdd:    function () { ... },
  onEdit:   function () { ... },
  onDelete: function () { ... },
  onFilter: function () { ... },
  onPrint:  function () { ... },
  onClose:  function () { ... }
});

// Trong ButtonBar constructor — tự ẩn nút dựa trên quyền
ButtonBar.prototype._applyPermissions = function () {
  if (!Permission.canAdd(this.module))    this.$el.find('.btn-add').hide();
  if (!Permission.canEdit(this.module))   this.$el.find('.btn-edit').hide();
  if (!Permission.canDelete(this.module)) this.$el.find('.btn-delete').hide();
};
```

### 14.4 Bảo vệ Action (Double-check trước khi gọi API)

```js
// Dù nút đã bị ẩn, vẫn kiểm tra lại trong handler để an toàn tuyệt đối
function onDeleteClick() {
  if (!Permission.canDelete('HopDong')) {
    return Alert.error('Bạn không có quyền xóa');
  }
  // Tiếp tục xóa...
}
```

### 14.5 Bảo vệ Route (Auth Guard trong Router)

```js
// Cấu hình route có thêm trường permission
{ 
  path: 'checkout',
  module: 'QuyetToan',
  requireView: true,        // ← Phải có quyền Xem mới vào được trang
  // ...
}

// Trong router._handleRoute()
if (route.requireView && !Permission.canView(route.module)) {
  _render403();             // Hiện trang "Không có quyền truy cập"
  return;
}
```

> [!IMPORTANT]
> Kiểm tra quyền **2 lớp**: (1) ẩn nút trên UI, (2) kiểm tra lại trong handler trước khi gọi API. Không bao giờ chỉ dựa vào 1 lớp.

---

## 15. Print Strategy (Chiến lược In ấn)

Phần mềm cần in nhiều loại tài liệu nghiệp vụ. Theo `required.md`:
- **Danh mục** → In tất cả dữ liệu trong lưới (DataGrid)
- **Phiếu / Hợp đồng** → In phiếu theo mẫu định sẵn

### 15.1 Hai loại In

| Loại | Khi nào | Cách thực hiện |
|---|---|---|
| **In Danh mục** (in lưới) | Trang danh mục: hàng hoá, khách hàng, khu vực... | CSS `@media print` ẩn UI, chỉ in bảng |
| **In Phiếu** (in template) | Hợp đồng, Biên nhận cọc, Quyết toán | Render HTML template riêng → `window.print()` |

### 15.2 In Danh mục — CSS Print

```css
/* src/css/components/data-table.css */
@media print {
  /* Ẩn toàn bộ UI */
  .app-header, .app-sidebar, .app-nav,
  .button-bar, .filter-container, .pagination { display: none !important; }

  /* Chỉ in bảng */
  .app-content { margin: 0; padding: 0; max-width: 100%; }
  .data-grid    { font-size: 11pt; border-collapse: collapse; width: 100%; }
  .data-grid th,
  .data-grid td { border: 1px solid #000; padding: 4px 8px; }

  /* Không phân trang khi in */
  .data-grid tbody tr { page-break-inside: avoid; }
}
```

```js
// ButtonBar.onPrint cho trang Danh mục
onPrint: function () {
  window.print();   // CSS print đã lo ẩn UI
}
```

### 15.3 In Phiếu — Print Template

Mỗi loại phiếu có 1 file HTML template riêng trong `src/templates/print/`:

```
src/templates/print/
├── print-contract.html       # In Hợp đồng tiệc
├── print-booking.html        # In Biên nhận cọc chỗ
├── print-checkout.html       # In Quyết toán tiệc
├── print-arrangement.html    # In Thông tin sắp đặt tiệc
└── print-invoice.html        # In phiếu thu
```

### 15.4 PrintManager — `src/js/utils/PrintManager.js`

```js
var PrintManager = (function () {

  /**
   * In phiếu theo template
   * @param {string} templatePath  - Đường dẫn file HTML template
   * @param {object} data          - Dữ liệu điền vào template
   * @param {object} options       - { title, paperSize: 'A4'|'A5', landscape: false }
   */
  function print(templatePath, data, options) {
    options = options || {};

    fetch(templatePath)
      .then(function (res) { return res.text(); })
      .then(function (html) {
        // Thay thế placeholder {{TenKhach}}, {{NgayToChuc}}... bằng data thực
        var filled = _fillTemplate(html, data);

        // Mở cửa sổ in riêng
        var win = window.open('', '_blank',
          'width=900,height=700,scrollbars=yes');

        win.document.write(
          '<!DOCTYPE html><html><head>' +
          '<meta charset="UTF-8">' +
          '<title>' + (options.title || 'In phiếu') + '</title>' +
          '<style>' + _getPrintCSS(options) + '</style>' +
          '</head><body onload="window.print();window.close()">' +
          filled +
          '</body></html>'
        );
        win.document.close();
      })
      .catch(function () {
        Alert.error('Không thể tải mẫu in. Vui lòng thử lại.');
      });
  }

  // Điền dữ liệu vào template: thay {{KEY}} bằng data[KEY]
  function _fillTemplate(html, data) {
    return html.replace(/\{\{(\w+)\}\}/g, function (_, key) {
      return data[key] !== undefined ? data[key] : '';
    });
  }

  // CSS cơ bản cho trang in
  function _getPrintCSS(options) {
    var size = (options.paperSize || 'A4') +
               (options.landscape ? ' landscape' : '');
    return '@page { size: ' + size + '; margin: 15mm; }' +
           'body { font-family: Arial, sans-serif; font-size: 11pt; color: #000; }' +
           'table { width: 100%; border-collapse: collapse; }' +
           'th, td { border: 1px solid #000; padding: 4px 8px; }';
  }

  return { print: print };
})();
```

### 15.5 Cách dùng trong Page Script

```js
// In Hợp đồng tiệc
onPrint: function () {
  if (!selectedRow) return Alert.warn('Chọn hợp đồng cần in');

  BanquetService.getContractDetail(selectedRow.ID)
    .then(function (data) {
      PrintManager.print(
        'src/templates/print/print-contract.html',
        {
          SoHopDong:   data.SoHD,
          TenKhach:    data.TenKhach,
          NgayToChuc:  Format.date(data.NgayToChuc),
          NgayAmLich:  data.NgayAmLich,
          TenSanh:     data.TenSanh,
          SoBanMan:    data.SoBanMan,
          SoBanChay:   data.SoBanChay,
          TongTien:    Format.currency(data.TongTien),
          TienCoc:     Format.currency(data.TienCoc),
          ConLai:      Format.currency(data.TongTien - data.TienCoc)
          // ...thêm các field khác
        },
        { title: 'Hợp đồng tiệc - ' + data.SoHD, paperSize: 'A4' }
      );
    });
}
```

### 15.6 Mẫu Print Template HTML

```html
<!-- src/templates/print/print-contract.html -->
<div class="contract-header">
  <h2>HỢP ĐỒNG TIỆC CƯỚI</h2>
  <p>Số HĐ: <strong>{{SoHopDong}}</strong></p>
</div>
<table class="contract-info">
  <tr><td>Khách hàng:</td>  <td><strong>{{TenKhach}}</strong></td></tr>
  <tr><td>Ngày tổ chức:</td><td>{{NgayToChuc}} — {{NgayAmLich}}</td></tr>
  <tr><td>Sảnh tiệc:</td>   <td>{{TenSanh}}</td></tr>
  <tr><td>Số bàn mặn:</td>  <td>{{SoBanMan}}</td></tr>
  <tr><td>Số bàn chay:</td> <td>{{SoBanChay}}</td></tr>
</table>
<!-- ...thực đơn, ưu đãi, điều khoản... -->
<div class="contract-footer">
  <div class="sign-col">Đại diện nhà hàng<br><br><br>________________</div>
  <div class="sign-col">Khách hàng<br><br><br>________________</div>
</div>
```

> [!TIP]
> Template HTML in phiếu **không load CSS của app** — chỉ dùng CSS inline/embedded riêng. Điều này đảm bảo bản in không bị ảnh hưởng khi thay đổi giao diện app.
