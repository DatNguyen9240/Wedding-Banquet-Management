/* --- mockData.js --- */
/**
 * Mock Data
 * Dữ liệu mẫu dùng chung cho toàn bộ hệ thống trong lúc chờ tích hợp API thật
 */
var MockData = {
  // Dữ liệu Nhóm Quyền & Người dùng 
  groups: [
    { id: 'G01', name: 'Admin', icon: 'shield_person', selected: true },
    { id: 'G02', name: 'Quản lý', icon: 'manage_accounts', selected: false },
    { id: 'G03', name: 'Nhân viên lễ tân', icon: 'support_agent', selected: false },
    { id: 'G04', name: 'Kế toán', icon: 'account_balance', selected: false },
    { id: 'G05', name: 'Bếp trưởng', icon: 'restaurant_menu', selected: false }
  ],
  groupDataSimple: [
    ['G01', 'Admin'],
    ['G02', 'Quản lý'],
    ['G03', 'Nhân viên lễ tân'],
    ['G04', 'Kế toán'],
    ['G05', 'Bếp trưởng']
  ],
  usersData: [
    { id: 'NV0000', name: 'Trương Nguyễn Administrator', username: 'admin', group: 'Admin', disabled: false },
    { id: 'NV0001', name: 'Trương Du Kỳ', username: 'duky123', group: 'Quản lý', disabled: false },
    { id: 'NV0002', name: 'Triệu Quách Minh', username: 'minh.trieu', group: 'Nhân viên lễ tân', disabled: true },
    { id: 'NV0003', name: 'Châu Chỉ Nhược', username: 'nhuoc.cc', group: 'Kế toán', disabled: false }
  ],

  // Dữ liệu Phân quyền
  permissionModules: [
    'Hệ thống (Tài khoản & Phân quyền)',
    'Danh mục Hàng hóa',
    'Danh mục Khách hàng',
    'Phiếu Khách Tham Quan',
    'Biên nhận Cọc chỗ',
    'Hợp đồng Tiệc',
    'Thông tin Bổ sung Tiệc',
    'Quyết toán Tiệc',
    'Báo cáo Doanh thu',
    'Báo cáo Kho'
  ],

  // Dữ liệu Demo (Hàng hóa, Nhân sự)
  demoEmployees: [
    ['NV0000', 'Administrator', '0909123456'],
    ['NV0001', 'Trương Du Kỳ', '123456789'],
    ['NV0002', 'Triệu Minh', '23654789']
  ],
  demoItems: [
    ['CO-FAN-CAM-1-300', 'Coca++Fanta-Cam-chai-300', 'K24', 24, 150, 0, '3,600'],
    ['PE-7UP-ZZZ-1-285', 'Pepsi++7up-chai-285', 'K24', 24, '1,000', 5, '24,005'],
    ['SG-BIA-EXP-1-355', 'Sài gòn++Export-chai-355', 'K20', 20, '2,935', 10, '58,710'],
    ['SG-BIA-LAG-1-450', 'Sài gòn++Lager beer-chai', 'K20', 20, 300, 0, '6,000'],
    ['A4', 'Giấy A4', 'KG', 1, '', '', ''],
    ['A55', 'Giấy A55', 'KG', 1, '', '', '']
  ],

  // Dữ liệu Demo Báo cáo Doanh thu (12 tháng)
  demoRevenue: [
    { month: 'Tháng 1', revenue: 125000000, count: 5 },
    { month: 'Tháng 2', revenue: 85000000, count: 3 },
    { month: 'Tháng 3', revenue: 210000000, count: 8 },
    { month: 'Tháng 4', revenue: 150000000, count: 6 },
    { month: 'Tháng 5', revenue: 320000000, count: 12 },
    { month: 'Tháng 6', revenue: 280000000, count: 10 },
    { month: 'Tháng 7', revenue: 190000000, count: 7 },
    { month: 'Tháng 8', revenue: 160000000, count: 5 },
    { month: 'Tháng 9', revenue: 410000000, count: 15 },
    { month: 'Tháng 10', revenue: 550000000, count: 20 },
    { month: 'Tháng 11', revenue: 620000000, count: 22 },
    { month: 'Tháng 12', revenue: 750000000, count: 28 }
  ],

  // Dữ liệu Demo Chi phí
  demoCost: [
    { id: 'HD001', customer: 'Nguyễn Văn A', date: '25/11/2026', foodCost: 50000000, serviceCost: 10000000, staffCost: 5000000, totalCost: 65000000 },
    { id: 'HD002', customer: 'Trần Thị B', date: '28/11/2026', foodCost: 30000000, serviceCost: 5000000, staffCost: 3000000, totalCost: 38000000 },
    { id: 'HD003', customer: 'Lê C', date: '02/12/2026', foodCost: 80000000, serviceCost: 15000000, staffCost: 8000000, totalCost: 103000000 }
  ],

  // Dữ liệu Demo Khảo sát - Yếu tố đặt tiệc
  demoSurveyFactors: [
    { label: 'Không gian sảnh', value: 35 },
    { label: 'Thực đơn ngon', value: 25 },
    { label: 'Giá cả hợp lý', value: 20 },
    { label: 'Khuyến mãi tốt', value: 15 },
    { label: 'Phục vụ', value: 5 }
  ],

  // Dữ liệu Demo Khảo sát - Kênh thông tin
  demoSurveyChannels: [
    { label: 'Facebook', value: 45 },
    { label: 'Người quen giới thiệu', value: 30 },
    { label: 'Tiktok', value: 15 },
    { label: 'Website', value: 10 }
  ],

  // Dữ liệu Demo Khách Hàng (Hồ sơ)
  khachHang: [
    { id: 1, MaKH: 'KH2026-001', TenKhach: 'Nguyễn Văn A - Lê Thị B', DienThoai: '0909123456', Email: 'a.b@gmail.com', DiaChi: 'Quận 1, TP.HCM', SoLanThamQuan: 2, SoHopDong: 1 },
    { id: 2, MaKH: 'KH2026-002', TenKhach: 'Trần Hữu C - Đinh Bích D', DienThoai: '0988765432', Email: 'c.d@gmail.com', DiaChi: 'Quận 3, TP.HCM', SoLanThamQuan: 1, SoHopDong: 1 },
    { id: 3, MaKH: 'KH2026-003', TenKhach: 'Hoàng Hữu E - Ngô F', DienThoai: '0912345678', Email: 'e.f@gmail.com', DiaChi: 'Quận 7, TP.HCM', SoLanThamQuan: 3, SoHopDong: 2 },
    { id: 4, MaKH: 'KH2026-004', TenKhach: 'Lý Mạc Sầu', DienThoai: '0944555666', Email: 'sau.lm@gmail.com', DiaChi: 'Bình Thạnh, TP.HCM', SoLanThamQuan: 1, SoHopDong: 1 },
    { id: 5, MaKH: 'KH2026-005', TenKhach: 'Lệnh Hồ Xung - Nhậm Doanh Doanh', DienThoai: '0933444555', Email: 'xung.doanh@gmail.com', DiaChi: 'Tân Bình, TP.HCM', SoLanThamQuan: 4, SoHopDong: 1 }
  ],

  // Dữ liệu Demo Sảnh Tiệc
  sanhTiec: [
    { id: 'S01', name: 'Diamond Hall', status: 'TRONG', capacity: 60 },
    { id: 'S02', name: 'Ruby Hall', status: 'DA_COC', capacity: 40, customer: 'Trần Hữu C', session: 'Trưa' },
    { id: 'S03', name: 'Sapphire Hall', status: 'DA_KY', capacity: 50, customer: 'Hoàng Hữu E', session: 'Tối' },
    { id: 'S04', name: 'Emerald Hall', status: 'TRONG', capacity: 35 },
    { id: 'S05', name: 'Gold Hall', status: 'BAO_TRI', capacity: 45 },
    { id: 'S06', name: 'Silver Hall', status: 'DA_KY', capacity: 30, customer: 'Lý Mạc Sầu', session: 'Trưa' }
  ],

  // Dữ liệu Demo Nhân sự phục vụ
  nhanVienPhucVu: [
    { id: 1, MaNV: 'PV001', HoTen: 'Nguyễn Văn Tèo', GioiTinh: 'Nam', DienThoai: '0901234567', LoaiHopDong: 'Thời vụ', MucLuong: 200000, DanhGia: '8.5' },
    { id: 2, MaNV: 'PV002', HoTen: 'Trần Thị Nở', GioiTinh: 'Nữ', DienThoai: '0912345678', LoaiHopDong: 'Bán thời gian', MucLuong: 4000000, DanhGia: '9.0' },
    { id: 3, MaNV: 'PV003', HoTen: 'Lê Chí Phèo', GioiTinh: 'Nam', DienThoai: '0923456789', LoaiHopDong: 'Fulltime', MucLuong: 6000000, DanhGia: '7.5' },
    { id: 4, MaNV: 'PV004', HoTen: 'Thị Kính', GioiTinh: 'Nữ', DienThoai: '0988888888', LoaiHopDong: 'Thời vụ', MucLuong: 250000, DanhGia: '9.5' },
    { id: 5, MaNV: 'PV005', HoTen: 'Lý Thông', GioiTinh: 'Nam', DienThoai: '0977665544', LoaiHopDong: 'Fulltime', MucLuong: 6500000, DanhGia: '6.0' }
  ]
};


/* --- permission.js --- */
/**
 * Permission Utility
 * Quản lý phân quyền hiển thị UI
 */
var Permission = (function () {
  function _get(module) {
    var perms = JSON.parse(localStorage.getItem('app_permissions') || '{}');
    // Mặc định cho phép tất cả ở môi trường phát triển ban đầu
    if (Object.keys(perms).length === 0) {
      return { xem: true, them: true, sua: true, xoa: true };
    }
    return perms[module] || { xem: false, them: false, sua: false, xoa: false };
  }

  return {
    canView:   function (module) { return _get(module).xem; },
    canAdd:    function (module) { return _get(module).them; },
    canEdit:   function (module) { return _get(module).sua; },
    canDelete: function (module) { return _get(module).xoa; }
  };
})();


/* --- KeyboardManager.js --- */
/**
 * KeyboardManager — Quản lý phím tắt tập trung
 * Hỗ trợ các phím chuyên dụng: F2, F3, F4, Space, Enter, Esc
 */
var KeyboardManager = (function () {

  function init() {
    document.addEventListener('keydown', function (e) {
      var target = document.activeElement;
      if (!target || target.tagName === 'BODY') return;

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
        case ' ': // Space bar
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

    // Support trigger by right-clicking checkboxes
    document.addEventListener('contextmenu', function (e) {
      if (e.target && e.target.type === 'checkbox') {
        e.preventDefault();
        e.target.checked = !e.target.checked;
        e.target.dispatchEvent(new Event('change', { bubbles: true }));
      }
    });
  }

  // Bubble custom event lên DOM để component tự lắng nghe
  function _dispatch(el, eventName) {
    el.dispatchEvent(new CustomEvent(eventName, { bubbles: true, cancelable: true }));
  }

  return { init: init };
})();


/* --- FormatUtils.js --- */
/**
 * Format Utility
 * Các hàm tiện ích dùng chung (Tiền tệ, Thời gian, Số)
 */
var FormatUtils = (function () {

  /**
   * Định dạng tiền tệ VNĐ (VD: 1500000 -> 1.500.000 VNĐ)
   */
  function currency(amount) {
    if (amount === null || amount === undefined || isNaN(amount)) return '0 VNĐ';
    return Number(amount).toLocaleString('vi-VN') + ' VNĐ';
  }

  /**
   * Định dạng số có dấy tách thập phân (VD: 1500 -> 1.500)
   */
  function number(value) {
    if (value === null || value === undefined || isNaN(value)) return '0';
    return Number(value).toLocaleString('vi-VN');
  }

  /**
   * Định dạng ngày tháng VN (VD: YYYY-MM-DD -> DD/MM/YYYY)
   */
  function date(dateString) {
    if (!dateString) return '';
    var d = new Date(dateString);
    if (isNaN(d.getTime())) return dateString;
    var day = ('0' + d.getDate()).slice(-2);
    var month = ('0' + (d.getMonth() + 1)).slice(-2);
    return day + '/' + month + '/' + d.getFullYear();
  }

  return {
    currency: currency,
    number: number,
    date: date
  };
})();


/* --- PrintUtils.js --- */
/**
 * Print Utility
 * Phục vụ nghiệp vụ IN phiếu và IN lưới từ ứng dụng CSR (Client Side Render)
 */
var PrintUtils = (function () {

  /**
   * Mở cửa sổ in một vùng giao diện (DOM Node)
   * @param {Node} element - DOM Node cần in
   * @param {string} title - Tiêu đề trang in
   */
  function printElement(element, title) {
    var win = window.open('', '', 'height=700,width=900');
    if (!win) {
      Alert.error('Lỗi', 'Trình duyệt bị chặn mở cửa sổ (Popup blocked). Vui lòng cho phép!');
      return;
    }

    win.document.write('<html><head><title>' + (title || 'In tài liệu') + '</title>');
    
    // Nạp toàn bộ style hiện tại vào bản in
    var styles = document.querySelectorAll('link[rel="stylesheet"], style');
    styles.forEach(function(s) {
      win.document.write(s.outerHTML);
    });

    win.document.write('<style> @media print { body { padding: 20px; background: var(--color-surface); } .btn-tool { display: none; } } </style>');
    win.document.write('</head><body >');
    win.document.write(element.outerHTML);
    win.document.write('</body></html>');

    win.document.close();
    win.focus();

    setTimeout(function() {
      win.print();
      win.close();
    }, 500); // Đợi CSS load
  }

  return {
    printElement: printElement
  };
})();


/* --- UIUtils.js --- */
/**
 * Shared UI Utilities for Components
 */
var UIControls = window.UIControls || {};

UIControls.utils = (function() {
  /**
   * Tính toán vụ trí Dropdown thông minh (Tránh tràn màn hình)
   */
  function computeDropdownPosition(inputElement, dropdownElement) {
    var rect = inputElement.getBoundingClientRect();

    // Navbar: giới hạn top khi mở lên trên
    var navbarBottom = 0;
    var navbar = document.querySelector('.app-navbar');
    if (navbar) navbarBottom = navbar.getBoundingClientRect().bottom;

    // position:fixed — tọa độ viewport, không bị ảnh hưởng bởi overflow:hidden
    dropdownElement.style.position   = 'fixed';
    dropdownElement.style.zIndex     = '10001';
    dropdownElement.style.transition = 'opacity 0.15s ease, visibility 0.15s ease';
    dropdownElement.style.minWidth   = rect.width + 'px';

    var isActive = dropdownElement.classList.contains('active');
    if (!isActive) {
      dropdownElement.style.maxHeight  = '300px';
      dropdownElement.style.visibility = 'hidden';
      dropdownElement.classList.add('active');
    }

    var dropWidth  = dropdownElement.offsetWidth;
    var dropHeight = dropdownElement.offsetHeight;

    // --- Tính toán Left ---
    var leftPos = rect.left;
    if (leftPos + dropWidth > window.innerWidth - 10) {
      // Nếu tràn phải -> Căn lề phải với input
      leftPos = rect.right - dropWidth;
    }
    // Đảm bảo không tràn trái
    leftPos = Math.max(10, leftPos);
    dropdownElement.style.left = leftPos + 'px';

    // --- Tính toán Top ---
    var spaceBelow = window.innerHeight - rect.bottom;
    var spaceAbove = rect.top - navbarBottom;

    if (spaceBelow < dropHeight && spaceAbove > spaceBelow) {
      if (spaceAbove < dropHeight) {
        dropdownElement.style.maxHeight = (spaceAbove - 4) + 'px';
        dropHeight = dropdownElement.offsetHeight;
      }
      var topPos = Math.max(rect.top - dropHeight, navbarBottom + 4);
      dropdownElement.style.top = topPos + 'px';
    } else {
      if (spaceBelow < dropHeight) {
        dropdownElement.style.maxHeight = (spaceBelow - 4) + 'px';
      }
      dropdownElement.style.top = rect.bottom + 'px';
    }

    if (!isActive) {
      dropdownElement.classList.remove('active');
      dropdownElement.style.visibility = '';
    }
  }

  /**
   * Tìm tất cả scrollable ancestors từ một element
   */
  function getScrollableAncestors(el) {
    var ancestors = [];
    var node = el.parentElement;
    while (node && node !== document.documentElement) {
      var style = window.getComputedStyle(node);
      var ov = style.overflow + style.overflowY + style.overflowX;
      if (/auto|scroll/.test(ov)) {
        ancestors.push(node);
      }
      node = node.parentElement;
    }
    ancestors.push(window);
    return ancestors;
  }




  /**
   * Sinh HTML cho Dropdown Table List
   */
  function createDropdownTableHTML(headers, data, colHighlightIndex) {
    var theadHTML = headers.map(h => `<th>${h}</th>`).join('');
    var tbodyHTML = data.map(function(row, rIdx) {
      var cells = row.map(function(cell, cIdx) {
        var cls = (cIdx === colHighlightIndex) ? 'highlight-col' : '';
        return `<td class="${cls}">${cell}</td>`;
      }).join('');
      return `<tr data-index="${rIdx}">${cells}</tr>`;
    }).join('');

    return `
      <table class="dropdown-table">
        <thead><tr>${theadHTML}</tr></thead>
        <tbody>${tbodyHTML}</tbody>
      </table>
    `;
  }

  return {
    computeDropdownPosition: computeDropdownPosition,
    getScrollableAncestors: getScrollableAncestors,
    createDropdownTableHTML: createDropdownTableHTML,
    /**
     * Setup single row selection for a table
     */
    setupTableSelection: function(tableBody, onSelect) {
      if (!tableBody) return;
      tableBody.addEventListener('click', function(e) {
        var tr = e.target.closest('tr');
        if (!tr) return;
        
        var isAlreadyActive = tr.classList.contains('active');
        
        // Remove active from all rows
        Array.from(tableBody.querySelectorAll('tr')).forEach(r => r.classList.remove('active'));
        
        // If it wasn't active, make it active
        if (!isAlreadyActive) {
          tr.classList.add('active');
          if (typeof onSelect === 'function') onSelect(tr);
        } else {
          // If it was already active, we just removed it above, so we pass null to onSelect
          if (typeof onSelect === 'function') onSelect(null);
        }
      });
    }
  };
})();


/* --- Navbar.js --- */
/**
 * Navbar Component
 * Thanh điều hướng ngang trên cùng — thay thế sidebar dọc.
 * Có dropdown xổ xuống cho từng nhóm menu.
 * Hỗ trợ chuyển đổi layout ngang ↔ dọc (sidebar mode).
 */
var Navbar = (function () {

  /* ─────────────────────────────────────────
     Layout Mode (lưu vào localStorage)
  ───────────────────────────────────────── */
  var LAYOUT_KEY = 'pmql_layout_mode';
  var LAYOUT_HORIZONTAL = 'horizontal';
  var LAYOUT_VERTICAL   = 'vertical';

  function getLayout() {
    return localStorage.getItem(LAYOUT_KEY) || LAYOUT_HORIZONTAL;
  }

  function setLayout(mode) {
    localStorage.setItem(LAYOUT_KEY, mode);
  }

  /* Áp dụng layout lên <body> */
  function applyLayout(mode) {
    document.body.setAttribute('data-layout', mode);

    var $app = document.getElementById('app');
    if (!$app) return;

    if (mode === LAYOUT_VERTICAL) {
      $app.classList.add('layout-vertical');
      $app.classList.remove('layout-horizontal');
    } else {
      $app.classList.add('layout-horizontal');
      $app.classList.remove('layout-vertical');
    }
  }

  /* ─────────────────────────────────────────
     Cấu hình menu — groups + single links
  ───────────────────────────────────────── */
  var NAV_CONFIG = [
    // Single link: Tổng quan
    {
      type: 'link',
      href: '#/dashboard',
      icon: 'dashboard',
      label: 'Tổng quan'
    },

    // Dropdown: Quản lý tiệc
    {
      type: 'group',
      icon: 'celebration',
      label: 'Quản lý tiệc',
      items: [
        { href: '#/customers',   icon: 'manage_accounts', label: 'Hồ sơ khách hàng' },
        { href: '#/calendar',    icon: 'calendar_month',  label: 'Lịch tiệc' },
        { href: '#/hall-status', icon: 'meeting_room',    label: 'Trạng thái sảnh' },
        { href: '#/visitor',     icon: 'hail',            label: 'Khách tham quan' },
        { href: '#/booking',     icon: 'edit_document',   label: 'Biên nhận cọc' },
        { href: '#/contract',    icon: 'contract',        label: 'Hợp đồng tiệc' },
        { href: '#/checkout',    icon: 'receipt_long',    label: 'Quyết toán' }
      ]
    },

    // Dropdown: Hệ thống
    {
      type: 'group',
      icon: 'admin_panel_settings',
      label: 'Hệ thống',
      items: [
        { href: '#/users',       icon: 'group',                 label: 'Người dùng' },
        { href: '#/permissions', icon: 'admin_panel_settings',  label: 'Phân quyền' },
        { href: '#/menus',       icon: 'list_alt',              label: 'Danh mục Menu' },
        { href: '#/settings',    icon: 'settings_applications', label: 'Thiết lập chung' }
      ]
    },

    // Single link: Nhân sự
    {
      type: 'link',
      href: '#/staff',
      icon: 'badge',
      label: 'Nhân sự'
    },

    // Single link: Danh mục
    {
      type: 'link',
      href: '#/categories',
      icon: 'category',
      label: 'Danh mục'
    },

    // Dropdown: Báo cáo
    {
      type: 'group',
      icon: 'bar_chart',
      label: 'Báo cáo',
      items: [
        { href: '#/report-revenue', icon: 'bar_chart',    label: 'Doanh thu tiệc' },
        { href: '#/report-cost',    icon: 'price_change', label: 'Chi phí tiệc' },
        { href: '#/report-other',   icon: 'assessment',   label: 'Báo cáo khác' }
      ]
    },

    // Single: Components demo
    {
      type: 'link',
      href: '#/components-demo',
      icon: 'integration_instructions',
      label: 'UI Demo'
    }
  ];

  /* ─────────────────────────────────────────
     Build HTML helpers
  ───────────────────────────────────────── */
  function _buildMenuHTML() {
    return NAV_CONFIG.map(function (item) {
      if (item.type === 'link') {
        return `
          <a href="${item.href}" class="nav-link" data-href="${item.href}">
            <span class="material-symbols-outlined nav-icon">${item.icon}</span>
            ${item.label}
          </a>`;
      }

      var dropdownItems = item.items.map(function (di) {
        return `
          <a href="${di.href}" class="dropdown-item" data-href="${di.href}">
            <span class="material-symbols-outlined drop-icon">${di.icon}</span>
            ${di.label}
          </a>`;
      }).join('');

      return `
        <div class="nav-group" data-group>
          <button class="nav-group-btn">
            <span class="material-symbols-outlined nav-icon">${item.icon}</span>
            ${item.label}
            <span class="material-symbols-outlined chevron">expand_more</span>
          </button>
          <div class="nav-dropdown">
            ${dropdownItems}
          </div>
        </div>`;
    }).join('');
  }

  /* Sidebar nav items (for vertical mode) */
  function _buildSidebarNavHTML() {
    var html = '';
    NAV_CONFIG.forEach(function (item) {
      if (item.type === 'link') {
        html += `
          <a href="${item.href}" class="nav-item" data-href="${item.href}">
            <span class="material-symbols-outlined icon">${item.icon}</span>
            ${item.label}
          </a>`;
        return;
      }
      html += `<div class="nav-group-title">${item.label}</div>`;
      item.items.forEach(function (di) {
        html += `
          <a href="${di.href}" class="nav-item" data-href="${di.href}">
            <span class="material-symbols-outlined icon">${di.icon}</span>
            ${di.label}
          </a>`;
      });
    });
    return html;
  }

  /* Mobile drawer nav */
  function _buildMobileNavHTML() {
    var html = '';
    NAV_CONFIG.forEach(function (item) {
      if (item.type === 'link') {
        html += `
          <a href="${item.href}" class="mobile-nav-item" data-href="${item.href}">
            <span class="material-symbols-outlined">${item.icon}</span>
            ${item.label}
          </a>`;
        return;
      }
      html += `<div class="mobile-nav-divider"></div>
               <div class="mobile-nav-section-label">${item.label}</div>`;
      item.items.forEach(function (di) {
        html += `
          <a href="${di.href}" class="mobile-nav-item" data-href="${di.href}">
            <span class="material-symbols-outlined">${di.icon}</span>
            ${di.label}
          </a>`;
      });
    });
    return html;
  }

  /* ── Layout switcher buttons HTML ── */
  function _buildLayoutSwitcherHTML(currentLayout) {
    var isH = currentLayout === LAYOUT_HORIZONTAL;
    var isV = !isH;
    return `
      <div class="layout-switcher-row">
        <div class="layout-switcher-label">
          <span class="material-symbols-outlined" style="font-size:15px;opacity:.6">tune</span>
          Giao diện
        </div>
        <div class="layout-toggle-group">
          <button class="layout-toggle-btn ${isH ? 'active' : ''}" 
                  id="btn-layout-horizontal" 
                  title="Thanh ngang (Navbar)">
            <span class="material-symbols-outlined">view_agenda</span>
          </button>
          <button class="layout-toggle-btn ${isV ? 'active' : ''}" 
                  id="btn-layout-vertical" 
                  title="Thanh dọc (Sidebar)">
            <span class="material-symbols-outlined">view_sidebar</span>
          </button>
        </div>
      </div>`;
  }

  /* ─────────────────────────────────────────
     Render — Horizontal (Navbar) mode
  ───────────────────────────────────────── */
  function _renderHorizontal(container) {
    var layout = getLayout();
    var html = `
      <!-- ═══ TOP NAVBAR ═══ -->
      <nav class="app-navbar" id="app-navbar">

        <!-- Hamburger (mobile only) -->
        <button class="navbar-hamburger" id="navbar-hamburger">
          <span class="material-symbols-outlined">menu</span>
        </button>

        <!-- Brand / Logo -->
        <div class="navbar-brand" onclick="window.location.hash='#/'">
          <span class="material-symbols-outlined brand-icon">diamond</span>
          <span class="brand-text">PMQL Tiệc Cưới</span>
        </div>

        <!-- Desktop Menu -->
        <ul class="navbar-menu" id="navbar-menu">
          ${_buildMenuHTML()}
        </ul>

        <!-- Right Actions -->
        <div class="navbar-right">
          <div class="navbar-icon-btn" onclick="var isDark = document.body.classList.toggle('dark-theme'); localStorage.setItem('pmql_theme', isDark ? 'dark' : 'light'); this.querySelector('span').innerText = isDark ? 'light_mode' : 'dark_mode';" title="Chuyển giao diện">
            <span class="material-symbols-outlined" id="header-theme-icon-horizontal">dark_mode</span>
          </div>
          <div class="navbar-icon-btn" id="navbar-btn-notif" title="Thông báo">
            <span class="material-symbols-outlined">notifications</span>
            <span class="badge-dot"></span>
          </div>
          <div class="navbar-user" id="navbar-user">
            <div class="user-avatar-nav">
              <img src="https://ui-avatars.com/api/?name=Admin&background=3C50E0&color=fff" alt="User">
            </div>
            <div class="user-info-nav">
              <div class="user-name-nav">Admin</div>
              <div class="user-role-nav">Quản trị hệ thống</div>
            </div>
            <span class="material-symbols-outlined expand-icon">expand_more</span>

            <!-- User dropdown -->
            <div class="user-dropdown" id="user-dropdown">
              <div class="user-dropdown-header">
                <div class="user-dropdown-name">Admin</div>
                <div class="user-dropdown-role">Quản trị hệ thống</div>
              </div>

              <div class="user-dropdown-item">
                <span class="material-symbols-outlined">person</span>
                Hồ sơ cá nhân
              </div>
              <div class="user-dropdown-item" onclick="Alert.info('Thông báo', 'Bạn không có thông báo mới')">
                <span class="material-symbols-outlined">notifications</span>
                Thông báo
              </div>
              <a href="#/appearance" class="user-dropdown-item" style="text-decoration: none;">
                <span class="material-symbols-outlined">palette</span>
                Cài đặt Giao diện
              </a>

              <div class="dropdown-divider"></div>

              <div class="user-dropdown-item danger" onclick="ConfirmModal.show({ title: 'Đăng xuất', message: 'Bạn muốn đăng xuất khỏi hệ thống?', onConfirm: window.logoutApp })">
                <span class="material-symbols-outlined">logout</span>
                Đăng xuất
              </div>
            </div>
          </div>
        </div>
      </nav>

      <!-- ═══ MOBILE DRAWER ═══ -->
      <div class="mobile-drawer-overlay" id="mobile-drawer-overlay"></div>
      <div class="mobile-drawer" id="mobile-drawer">
        <div class="mobile-drawer-header">
          <div class="mobile-drawer-brand">
            <span class="material-symbols-outlined brand-icon" style="margin-right:12px;font-size:28px;color:var(--color-primary)">diamond</span>
            Quản lý tiệc cưới
          </div>
          <button class="mobile-drawer-close" id="mobile-drawer-close">
            <span class="material-symbols-outlined">arrow_back</span>
          </button>
        </div>
        <nav class="mobile-drawer-nav" id="mobile-drawer-nav">
          ${_buildMobileNavHTML()}
        </nav>
      </div>
    `;
    container.innerHTML = html;
    _attachHorizontalEvents();
  }

  /* ─────────────────────────────────────────
     Render — Vertical (Sidebar) mode
  ───────────────────────────────────────── */
  function _renderVertical(container) {
    var layout = getLayout();
    var html = `
      <!-- ════ VERTICAL LAYOUT: Sidebar + Header ════ -->
      <div class="vertical-layout-shell" id="vertical-layout-shell">

        <!-- Sidebar -->
        <aside class="app-sidebar" id="app-sidebar">
          <div class="sidebar-header">
            <div style="display:flex;align-items:center;font-size:18px;font-weight:700;">
              <span class="material-symbols-outlined"
                style="margin-right:12px;font-size:28px;color:var(--color-primary)">diamond</span>
              Quản lý tiệc cưới
            </div>
            <button class="btn-close-sidebar" id="btn-close-sidebar">
              <span class="material-symbols-outlined">arrow_back</span>
            </button>
          </div>
          <nav class="sidebar-nav" id="sidebar-nav">
            ${_buildSidebarNavHTML()}
          </nav>
        </aside>

        <!-- Sidebar overlay (mobile) -->
        <div class="sidebar-overlay" id="sidebar-overlay"></div>

        <!-- Main area (header + content) -->
        <div class="vertical-main" id="vertical-main">

          <!-- Vertical Header -->
          <header class="app-header" id="app-header">
            <div class="header-left">
              <button class="btn-hamburger" id="btn-hamburger">
                <span class="material-symbols-outlined">menu</span>
              </button>
              <div class="search-box">
                <span class="material-symbols-outlined">search</span>
                <input type="text" placeholder="Type to search...">
              </div>
            </div>

            <div class="header-right">
              <div class="navbar-icon-btn" onclick="var isDark = document.body.classList.toggle('dark-theme'); localStorage.setItem('pmql_theme', isDark ? 'dark' : 'light'); this.querySelector('span').innerText = isDark ? 'light_mode' : 'dark_mode';" title="Chuyển giao diện">
                <span class="material-symbols-outlined" id="header-theme-icon-vertical">dark_mode</span>
              </div>
              <div class="navbar-icon-btn" onclick="Alert.info('Thông báo', 'Bạn không có thông báo mới')">
                <span class="material-symbols-outlined">notifications</span>
                <span class="badge-dot"></span>
              </div>
              <div class="navbar-user" id="vertical-user-profile">
                <div class="user-avatar-nav">
                  <img src="https://ui-avatars.com/api/?name=Admin&background=3C50E0&color=fff" alt="User">
                </div>
                <div class="user-info-nav">
                  <div class="user-name-nav">Admin</div>
                  <div class="user-role-nav">Quản trị hệ thống</div>
                </div>
                <span class="material-symbols-outlined expand-icon">expand_more</span>

                <!-- Vertical user dropdown -->
                <div class="user-dropdown" id="vertical-user-dropdown">
                  <div class="user-dropdown-header">
                    <div class="user-dropdown-name">Admin</div>
                    <div class="user-dropdown-role">Quản trị hệ thống</div>
                  </div>
                  <div class="user-dropdown-item">
                    <span class="material-symbols-outlined">person</span>
                    Hồ sơ cá nhân
                  </div>
                  <a href="#/appearance" class="user-dropdown-item" style="text-decoration: none;">
                    <span class="material-symbols-outlined">palette</span>
                    Cài đặt Giao diện
                  </a>

                  <div class="dropdown-divider"></div>

                  <div class="user-dropdown-item danger" onclick="ConfirmModal.show({ title: 'Đăng xuất', message: 'Bạn muốn đăng xuất?', onConfirm: window.logoutApp })">
                    <span class="material-symbols-outlined">logout</span>
                    Đăng xuất
                  </div>
                </div>
              </div>
            </div>
          </header>

        </div><!-- /vertical-main -->
      </div><!-- /vertical-layout-shell -->
    `;
    container.innerHTML = html;
    _attachVerticalEvents();
  }

  /* ─────────────────────────────────────────
     Main render — dispatch by layout mode
  ───────────────────────────────────────── */
  function render(containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;

    var mode = getLayout();
    applyLayout(mode);
    _adjustAppLayout(mode);

    if (mode === LAYOUT_VERTICAL) {
      _renderVertical(container);
    } else {
      _renderHorizontal(container);
    }
  }

  /* Adjust #app and #app-content structure per mode */
  function _adjustAppLayout(mode) {
    var $app = document.getElementById('app');
    var $content = document.getElementById('app-content');
    if (!$app) return;

    // Reset any inline styles that might interfere
    $app.style.flexDirection = '';
  }

  /* ─────────────────────────────────────────
     Move #app-content into vertical-main
     (only for vertical mode)
  ───────────────────────────────────────── */
  function _moveContentToVerticalMain() {
    var $vertMain = document.getElementById('vertical-main');
    var $content  = document.getElementById('app-content');
    if ($vertMain && $content && !$vertMain.contains($content)) {
      $vertMain.appendChild($content);
    }
  }

  /* Move #app-content back to #app (horizontal mode) */
  function _moveContentToApp() {
    var $app     = document.getElementById('app');
    var $content = document.getElementById('app-content');
    if ($app && $content && $content.parentNode !== $app) {
      $app.appendChild($content);
    }
  }

  /* ─────────────────────────────────────────
     Events — Horizontal mode
  ───────────────────────────────────────── */
  function _attachHorizontalEvents() {
    var groups = document.querySelectorAll('.nav-group[data-group]');
    groups.forEach(function (group) {
      var btn = group.querySelector('.nav-group-btn');
      if (btn) {
        btn.addEventListener('click', function (e) {
          e.stopPropagation();
          var isOpen = group.classList.contains('open');
          groups.forEach(function (g) { g.classList.remove('open'); });
          _closeUserDropdown();
          if (!isOpen) group.classList.add('open');
        });
      }
    });

    var $user = document.getElementById('navbar-user');
    if ($user) {
      $user.addEventListener('click', function (e) {
        e.stopPropagation();
        var isOpen = $user.classList.contains('open');
        groups.forEach(function (g) { g.classList.remove('open'); });
        if (isOpen) {
          _closeUserDropdown();
        } else {
          $user.classList.add('open');
        }
      });
    }

    var $notif = document.getElementById('navbar-btn-notif');
    if ($notif) {
      $notif.addEventListener('click', function () {
        Alert.info('Thông báo', 'Bạn không có thông báo mới');
      });
    }

    document.addEventListener('click', function () {
      groups.forEach(function (g) { g.classList.remove('open'); });
      _closeUserDropdown();
    });

    // Mobile drawer
    var $hamburger  = document.getElementById('navbar-hamburger');
    var $overlay    = document.getElementById('mobile-drawer-overlay');
    var $drawer     = document.getElementById('mobile-drawer');
    var $drawerClose = document.getElementById('mobile-drawer-close');

    function openDrawer()  { if ($drawer) $drawer.classList.add('open'); if ($overlay) $overlay.classList.add('active'); }
    function closeDrawer() { if ($drawer) $drawer.classList.remove('open'); if ($overlay) $overlay.classList.remove('active'); }

    if ($hamburger)   $hamburger.addEventListener('click', openDrawer);
    if ($drawerClose) $drawerClose.addEventListener('click', closeDrawer);
    if ($overlay)     $overlay.addEventListener('click', closeDrawer);

    document.querySelectorAll('.mobile-nav-item').forEach(function (item) {
      item.addEventListener('click', function () { setTimeout(closeDrawer, 150); });
    });

    _highlightActive();
    window.addEventListener('hashchange', _highlightActive);
  }

  /* ─────────────────────────────────────────
     Events — Vertical mode
  ───────────────────────────────────────── */
  function _attachVerticalEvents() {
    // Move content into vertical-main
    _moveContentToVerticalMain();

    // Sidebar toggle
    var $sidebar  = document.getElementById('app-sidebar');
    var $overlay  = document.getElementById('sidebar-overlay');
    var $btnOpen  = document.getElementById('btn-hamburger');
    var $btnClose = document.getElementById('btn-close-sidebar');

    function openSidebar()  { if ($sidebar) $sidebar.classList.add('open'); if ($overlay) $overlay.classList.add('active'); }
    function closeSidebar() { if ($sidebar) $sidebar.classList.remove('open'); if ($overlay) $overlay.classList.remove('active'); }

    if ($btnOpen)  $btnOpen.addEventListener('click', openSidebar);
    if ($btnClose) $btnClose.addEventListener('click', closeSidebar);
    if ($overlay)  $overlay.addEventListener('click', closeSidebar);

    // User dropdown in vertical header
    var $uProf = document.getElementById('vertical-user-profile');
    var $uDrop = document.getElementById('vertical-user-dropdown');
    if ($uProf && $uDrop) {
      $uProf.addEventListener('click', function (e) {
        e.stopPropagation();
        var isOpen = $uProf.classList.contains('open');
        $uProf.classList.toggle('open', !isOpen);
        
        // Also toggle 'open' on dropdown if needed by other CSS
        $uDrop.classList.toggle('open', !isOpen);

        var expandIcon = $uProf.querySelector('.expand-icon');
        if (expandIcon) {
          expandIcon.textContent = isOpen ? 'expand_more' : 'expand_less';
        }
      });
    }

    document.addEventListener('click', function () {
      if ($uDrop) $uDrop.classList.remove('open');
      if ($uProf) $uProf.classList.remove('open');
    });

    _highlightActive();
    window.addEventListener('hashchange', _highlightActive);
  }

  /* ─────────────────────────────────────────
     Helpers
  ───────────────────────────────────────── */
  function _closeUserDropdown() {
    var $user = document.getElementById('navbar-user');
    if ($user) $user.classList.remove('open');
  }

  function _highlightActive() {
    var hash = window.location.hash || '#/dashboard';

    // Horizontal: nav-links & dropdown items
    document.querySelectorAll('.navbar-menu .nav-link').forEach(function (el) {
      el.classList.toggle('active', el.getAttribute('data-href') === hash);
    });
    document.querySelectorAll('.navbar-menu .dropdown-item').forEach(function (el) {
      el.classList.toggle('active', el.getAttribute('data-href') === hash);
    });
    document.querySelectorAll('.mobile-nav-item').forEach(function (el) {
      el.classList.toggle('active', el.getAttribute('data-href') === hash);
    });

    // Vertical: sidebar items
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(function (el) {
      el.classList.toggle('active', el.getAttribute('data-href') === hash);
    });
  }

  return {
    render: render,
    getLayout: getLayout,
    setLayout: setLayout,
    applyLayout: applyLayout,
    moveContentToApp: _moveContentToApp,
    moveContentToVerticalMain: _moveContentToVerticalMain
  };
})();


/* --- Checkbox.js --- */
/**
 * Custom Checkbox Component
 */
var UIControls = window.UIControls || {};

UIControls.createCheckbox = function(options) {
  var wrapper = document.createElement('label');
  wrapper.className = 'modern-checkbox-wrapper';

  var input = document.createElement('input');
  input.type = 'checkbox';
  input.className = 'modern-checkbox';
  if (options.checked) input.checked = true;

  input.addEventListener('change', function(e) {
    if (typeof options.onChange === 'function') {
      options.onChange(e.target.checked);
    }
  });

  var span = document.createElement('span');
  span.innerText = options.label || '';

  wrapper.appendChild(input);
  wrapper.appendChild(span);

  return wrapper;
};


/* --- DataComboBox.js --- */
/**
 * Data ComboBox Component
 */
var UIControls = window.UIControls || {};

UIControls.createDataComboBox = function(options) {
  var container = document.createElement('div');
  container.className = 'combo-box-container';

  // Input
  var input = document.createElement('input');
  input.type = 'text';
  input.className = 'ui-input';
  input.placeholder = options.placeholder || '';
  if (options.id) input.id = options.id;

  // Actions block – chỉ giữ nút mũi tên
  var actions = document.createElement('div');
  actions.className = 'combo-box-actions';

  var btnArrow = document.createElement('button');
  btnArrow.className = 'combo-action-btn';
  btnArrow.innerHTML = '<span class="material-symbols-outlined">arrow_drop_down</span>';
  btnArrow.title = 'Mở danh sách (F4)';
  btnArrow.type = 'button';

  actions.appendChild(btnArrow);

  // ── Dropdown Panel ──────────────────────────────────────────────
  var dropdown = document.createElement('div');
  dropdown.className = 'data-dropdown-menu';

  // Search bar bên trong dropdown
  var searchWrapper = document.createElement('div');
  searchWrapper.className = 'dd-search-wrapper';

  var searchIcon = document.createElement('span');
  searchIcon.className = 'material-symbols-outlined dd-search-icon';
  searchIcon.textContent = 'search';

  var searchInput = document.createElement('input');
  searchInput.type = 'text';
  searchInput.className = 'dd-search-input';
  searchInput.placeholder = 'Tìm kiếm...';

  searchWrapper.appendChild(searchIcon);
  searchWrapper.appendChild(searchInput);

  // Table wrapper (scrollable)
  var tableWrapper = document.createElement('div');
  tableWrapper.className = 'dd-table-wrapper';

  // Footer "+ Thêm mới"
  var footer = document.createElement('div');
  footer.className = 'dd-footer';

  var btnAddNew = document.createElement('button');
  btnAddNew.type = 'button';
  btnAddNew.className = 'dd-footer-add-btn';
  btnAddNew.innerHTML = '<span class="material-symbols-outlined">add</span> Thêm mới';

  btnAddNew.addEventListener('click', function(e) {
    e.stopPropagation();
    hideDropdown();
    if (typeof options.onF2 === 'function') options.onF2();
  });

  footer.appendChild(btnAddNew);

  dropdown.appendChild(searchWrapper);
  dropdown.appendChild(tableWrapper);
  dropdown.appendChild(footer);

  // ── Data & Render ───────────────────────────────────────────────
  var fullData = options.data || [];

  function renderTable(displayData) {
    if (UIControls.utils) {
      tableWrapper.innerHTML = UIControls.utils.createDropdownTableHTML(
        options.headers || [], displayData, options.colHighlightIndex || 0
      );
      var rows = tableWrapper.querySelectorAll('tbody tr');
      rows.forEach(function(row) {
        row.addEventListener('click', function() {
          var dataRow = displayData[row.getAttribute('data-index')];
          input.value = dataRow[options.colFilterIndex || 0];
          hideDropdown();
          if (typeof options.onSelect === 'function') {
            options.onSelect(dataRow);
          }
        });
      });
    }
  }

  // ── Scroll listeners trên đúng container đang scroll ───────────
  var _scrollTargets = [];
  var _scrollHandler = null;

  function attachScrollListeners() {
    if (_scrollHandler) return;
    _scrollHandler = function() {
      if (UIControls.utils) {
        UIControls.utils.computeDropdownPosition(container, dropdown);
      }
    };
    // Tìm tất cả scrollable ancestors của combo-box-container
    _scrollTargets = UIControls.utils
      ? UIControls.utils.getScrollableAncestors(container)
      : [window];
    _scrollTargets.forEach(function(target) {
      target.addEventListener('scroll', _scrollHandler, { passive: true, capture: false });
    });
    window.addEventListener('resize', _scrollHandler, { passive: true });
  }

  function detachScrollListeners() {
    if (!_scrollHandler) return;
    _scrollTargets.forEach(function(target) {
      target.removeEventListener('scroll', _scrollHandler, { capture: false });
    });
    window.removeEventListener('resize', _scrollHandler);
    _scrollHandler = null;
    _scrollTargets = [];
  }

  function showDropdown() {
    if (dropdown.parentNode !== document.body) {
      document.body.appendChild(dropdown);
    }
    renderTable(fullData);
    searchInput.value = '';
    if (UIControls.utils) {
      UIControls.utils.computeDropdownPosition(container, dropdown);
    }
    dropdown.classList.add('active');
    attachScrollListeners();
    setTimeout(function() { searchInput.focus(); }, 50);
  }

  function hideDropdown() {
    detachScrollListeners();
    dropdown.classList.remove('active');
    if (dropdown.parentNode) dropdown.parentNode.removeChild(dropdown);
  }



  // ── Search bên trong dropdown ───────────────────────────────────
  searchInput.addEventListener('input', function() {
    var val = searchInput.value.toLowerCase();
    if (!val) {
      renderTable(fullData);
      return;
    }
    var filtered = fullData.filter(function(row) {
      var cellContent = (row[options.colFilterIndex || 0] || '').toString().toLowerCase();
      return cellContent.includes(val);
    });
    renderTable(filtered);
  });

  // Ngăn click trong dropdown đóng nó
  searchInput.addEventListener('click', function(e) { e.stopPropagation(); });

  // ── Events ──────────────────────────────────────────────────────
  btnArrow.addEventListener('click', function(e) {
    e.preventDefault();
    dropdown.classList.contains('active') ? hideDropdown() : showDropdown();
  });

  // Gõ vào input chính vẫn mở & filter
  input.addEventListener('input', function(e) {
    var val = e.target.value.toLowerCase();
    if (!dropdown.classList.contains('active')) {
      showDropdown();
    }
    var filtered = fullData.filter(function(row) {
      var cellContent = (row[options.colFilterIndex || 0] || '').toString().toLowerCase();
      return cellContent.includes(val);
    });
    renderTable(filtered);
  });

  document.addEventListener('click', function(e) {
    if (!container.contains(e.target) && !dropdown.contains(e.target)) {
      hideDropdown();
    }
  });

  input.addEventListener('kb:open', function() {
    dropdown.classList.contains('active') ? hideDropdown() : showDropdown();
  });
  input.addEventListener('kb:lookup', function() { if (options.onF3) options.onF3(); });
  input.addEventListener('kb:new',    function() { if (options.onF2) options.onF2(); });
  input.addEventListener('kb:close',  function() { hideDropdown(); });

  container.appendChild(input);
  container.appendChild(actions);

  return container;
};


/* --- GridDropdown.js --- */
/**
 * Grid Dropdown Component
 */
var UIControls = window.UIControls || {};

UIControls.createGridDropdown = function(options) {
  var wrapper = document.createElement('div');
  wrapper.className = 'grid-cell-dropdown-wrapper';

  var input = document.createElement('input');
  input.type = 'text';
  input.className = 'grid-cell-input';
  input.placeholder = options.placeholder || '';
  if(options.value) input.value = options.value;

  var dropdown = document.createElement('div');
  dropdown.className = 'data-dropdown-menu';
  dropdown.style.left = '-1px';
  dropdown.style.width = 'max-content';
  dropdown.style.minWidth = '300px';

  var fullData = options.data || [];

  function renderTable(displayData) {
    if (UIControls.utils) {
      dropdown.innerHTML = UIControls.utils.createDropdownTableHTML(options.headers || [], displayData, options.colHighlightIndex || 0);
      var rows = dropdown.querySelectorAll('tbody tr');
      rows.forEach(row => {
        row.addEventListener('click', function(e) {
          e.stopPropagation();
          var dataRow = displayData[row.getAttribute('data-index')];
          input.value = dataRow[options.colFilterIndex || 0];
          hideDropdown();
          if(typeof options.onSelect === 'function') {
            options.onSelect(dataRow);
          }
        });
      });
    }
  }

  function showDropdown() {
    if (dropdown.parentNode !== document.body) {
      document.body.appendChild(dropdown);
    }
    renderTable(fullData);
    if (UIControls.utils) {
      UIControls.utils.computeDropdownPosition(input, dropdown);
    }
    dropdown.classList.add('active');
  }
  
  function hideDropdown() {
    dropdown.classList.remove('active');
    if (dropdown.parentNode) dropdown.parentNode.removeChild(dropdown);
  }

  input.addEventListener('focus', showDropdown);
  
  input.addEventListener('input', function(e) {
    var val = e.target.value.toLowerCase();
    dropdown.classList.add('active');
    if(!val) return renderTable(fullData);
    var filtered = fullData.filter(function(row) {
      return (row[options.colFilterIndex || 0] || '').toString().toLowerCase().includes(val);
    });
    renderTable(filtered);
  });

  document.addEventListener('click', function(e) {
    if(!wrapper.contains(e.target) && !dropdown.contains(e.target)) hideDropdown();
  });

  window.addEventListener('scroll', function(e) {
      if (dropdown.classList.contains('active') && !dropdown.contains(e.target)) {
          hideDropdown();
      }
  }, true);

  wrapper.appendChild(input);
  return wrapper;
};


/* --- LoadingSpinner.js --- */
/**
 * Loading Spinner Component
 * Hiện vòng xoay tải trang toàn màn hình
 */
var LoadingSpinner = (function () {
  var overlay = null;
  var textElement = null;

  function init() {
    if (document.getElementById('loading-spinner-overlay')) return;

    overlay = document.createElement('div');
    overlay.id = 'loading-spinner-overlay';
    overlay.className = 'loading-overlay';

    var spinner = document.createElement('div');
    spinner.className = 'spinner';

    textElement = document.createElement('div');
    textElement.className = 'loading-text';
    textElement.innerText = 'Đang tải dữ liệu...';

    overlay.appendChild(spinner);
    overlay.appendChild(textElement);
    document.body.appendChild(overlay);
  }

  function show(message) {
    if (!overlay) init();
    if (message) textElement.innerText = message;
    else textElement.innerText = 'Đang tải dữ liệu...';
    overlay.classList.add('active');
  }

  function hide() {
    if (overlay) {
      overlay.classList.remove('active');
    }
  }

  return {
    show: show,
    hide: hide
  };
})();


/* --- Alert.js --- */
/**
 * Alert (Toast) Component
 * Hiển thị thông báo trượt góc phải màn hình
 */
var Alert = (function () {
  var container = null;

  function init() {
    if (!document.getElementById('toast-container')) {
      container = document.createElement('div');
      container.id = 'toast-container';
      document.body.appendChild(container);
    } else {
      container = document.getElementById('toast-container');
    }
  }

  /**
   * Hiển thị thông báo
   * @param {string} type - 'success', 'danger', 'warning', 'info'
   * @param {string} title - Tiêu đề
   * @param {string} message - Nội dung
   * @param {number} duration - Thời gian hiển thị (ms)
   */
  function show(type, title, message, duration) {
    if (!container) init();
    duration = duration || 3000;

    var toast = document.createElement('div');
    toast.className = 'toast ' + type;

    var iconMap = {
      'success': 'check_circle',
      'danger': 'error',
      'warning': 'warning',
      'info': 'info'
    };

    var html = `
      <div class="toast-icon">
        <span class="material-symbols-outlined">${iconMap[type] || 'info'}</span>
      </div>
      <div class="toast-content">
        <div class="toast-title">${title}</div>
        <div class="toast-message">${message}</div>
      </div>
      <button class="toast-close">
        <span class="material-symbols-outlined" style="font-size:18px;">close</span>
      </button>
    `;

    toast.innerHTML = html;
    container.appendChild(toast);

    toast.querySelector('.toast-close').addEventListener('click', function() {
      removeToast(toast);
    });

    // Trigger animation
    setTimeout(function() {
      toast.classList.add('show');
    }, 10);

    // Auto remove
    setTimeout(function() {
      removeToast(toast);
    }, duration);
  }

  function removeToast(toast) {
    toast.classList.remove('show');
    setTimeout(function() {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    }, 400); // Wait for transition
  }

  return {
    success: function(title, message, duration) { show('success', title, message, duration); },
    error: function(title, message, duration) { show('danger', title, message, duration); },
    warning: function(title, message, duration) { show('warning', title, message, duration); },
    info: function(title, message, duration) { show('info', title, message, duration); }
  };
})();


/* --- ConfirmModal.js --- */
/**
 * Confirm Modal Component
 * Hộp thoại hỏi ý kiến (Xóa/Lưu dữ liệu)
 */
var ConfirmModal = (function () {
  var modalOverlay = null;

  function init() {
    if (document.getElementById('confirm-modal-overlay')) return;

    modalOverlay = document.createElement('div');
    modalOverlay.id = 'confirm-modal-overlay';
    modalOverlay.className = 'modal-overlay';
    modalOverlay.style.display = 'none';

    var html = `
      <div class="modal-content" style="width: 400px;">
        <div class="modal-header">
          <h3 id="confirm-modal-title">Xác nhận</h3>
          <button class="btn-close-modal" id="confirm-modal-btn-close">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        <div class="card-body">
          <p id="confirm-modal-message" style="margin-bottom: 24px; color: var(--color-text-secondary);"></p>
          <div style="display: flex; justify-content: flex-end; gap: 12px;">
            <button class="btn btn-secondary" id="confirm-modal-btn-cancel">Hủy bỏ</button>
            <button class="btn btn-primary" id="confirm-modal-btn-confirm">Đồng ý</button>
          </div>
        </div>
      </div>
    `;

    modalOverlay.innerHTML = html;
    document.body.appendChild(modalOverlay);
  }

  /**
   * Mở hộp thoại xác nhận
   * @param {Object} options - { title, message, confirmText, confirmClass, onConfirm }
   */
  function show(options) {
    if (!modalOverlay) init();

    document.getElementById('confirm-modal-title').innerText = options.title || 'Xác nhận';
    document.getElementById('confirm-modal-message').innerText = options.message || 'Bạn có chắc chắn muốn thực hiện hành động này?';
    
    var btnConfirm = document.getElementById('confirm-modal-btn-confirm');
    btnConfirm.innerText = options.confirmText || 'Đồng ý';
    btnConfirm.className = 'btn ' + (options.confirmClass || 'btn-primary');

    var btnCancel = document.getElementById('confirm-modal-btn-cancel');
    var btnClose = document.getElementById('confirm-modal-btn-close');

    // Remove old listeners using clone node trick
    var newBtnConfirm = btnConfirm.cloneNode(true);
    btnConfirm.parentNode.replaceChild(newBtnConfirm, btnConfirm);

    var newBtnCancel = btnCancel.cloneNode(true);
    btnCancel.parentNode.replaceChild(newBtnCancel, btnCancel);

    var newBtnClose = btnClose.cloneNode(true);
    btnClose.parentNode.replaceChild(newBtnClose, btnClose);

    // Add new listeners
    newBtnConfirm.addEventListener('click', function() {
      hide();
      if (typeof options.onConfirm === 'function') options.onConfirm();
    });

    newBtnCancel.addEventListener('click', hide);
    newBtnClose.addEventListener('click', hide);

    modalOverlay.style.display = 'flex';
  }

  function hide() {
    if (modalOverlay) {
      modalOverlay.style.display = 'none';
    }
  }

  return {
    show: show,
    hide: hide
  };
})();


/* --- Modal.js --- */
/**
 * Generic Modal Builder
 * Mở các Pop-up Window Nhập liệu / Báo cáo không cần code cứng HTML
 */
var UIModal = (function () {
  
  /**
   * Mở một form Modal bất kỳ
   * @param {Object} config - { id, title, width, content (Node/String), footer (Node), onClose }
   */
  function show(config) {
    var overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.style.display = 'flex';
    if (config.id) overlay.id = config.id;

    var contentWidth = config.width || '600px';

    var html = `
      <div class="modal-content" style="width: ${contentWidth}; animation: fadeIn 0.2s ease;">
        <div class="modal-header">
          <h3>${config.title || 'Tiêu đề'}</h3>
          <button class="btn-close-modal">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        <div class="card-body ui-modal-body"></div>
        <div class="modal-footer" style="padding: 16px 24px; border-top: 1px solid var(--color-border); display: flex; justify-content: flex-end; gap: 12px; background: var(--color-background); border-radius: 0 0 var(--radius-lg) var(--radius-lg);"></div>
      </div>
    `;
    overlay.innerHTML = html;

    var bodyWrapper = overlay.querySelector('.ui-modal-body');
    if (typeof config.content === 'string') {
      bodyWrapper.innerHTML = config.content;
    } else if (config.content instanceof Node) {
      bodyWrapper.appendChild(config.content);
    }

    var footerWrapper = overlay.querySelector('.modal-footer');
    if (config.footer instanceof Node) {
      footerWrapper.appendChild(config.footer);
    } else {
      footerWrapper.style.display = 'none';
    }

    document.getElementById('modal-container').appendChild(overlay);

    function close() {
      overlay.remove();
      if (typeof config.onClose === 'function') config.onClose();
    }

    overlay.querySelector('.btn-close-modal').addEventListener('click', close);
    // Optional: close on click outside
    /* overlay.addEventListener('click', function(e) {
      if (e.target === overlay) close();
    }); */

    return {
      close: close,
      node: overlay
    };
  }

  return {
    show: show
  };
})();


/* --- Pagination.js --- */
/**
 * Pagination Component
 * Trình phân trang cho DataGrid
 */
var Pagination = (function () {
  /**
   * Tạo component phân trang
   * @param {Object} options - { totalItems, itemsPerPage, currentPage, onPageChange }
   * @returns {HTMLElement} wrapper
   */
  function create(options) {
    var wrapper = document.createElement('div');
    wrapper.className = 'pagination-wrapper';

    var totalPages = Math.ceil(options.totalItems / (options.itemsPerPage || 10));
    var currentPage = options.currentPage || 1;

    var startItem = (currentPage - 1) * options.itemsPerPage + 1;
    var endItem = Math.min(currentPage * options.itemsPerPage, options.totalItems);
    if (options.totalItems === 0) { startItem = 0; endItem = 0; }

    var info = document.createElement('div');
    info.className = 'pagination-info';
    info.innerText = `Hiển thị ${startItem}-${endItem} trong số ${options.totalItems} bản ghi`;

    var controls = document.createElement('div');
    controls.className = 'pagination-controls';

    // Prev Button
    var btnPrev = document.createElement('button');
    btnPrev.className = 'page-btn';
    btnPrev.innerHTML = '<span class="material-symbols-outlined">chevron_left</span>';
    btnPrev.disabled = currentPage === 1;
    btnPrev.onclick = function() {
      if (typeof options.onPageChange === 'function') options.onPageChange(currentPage - 1);
    };
    controls.appendChild(btnPrev);

    // Page numbers logic (simplified for Max 5 pages shown)
    var startP = Math.max(1, currentPage - 2);
    var endP = Math.min(totalPages, startP + 4);
    if (endP - startP < 4) startP = Math.max(1, endP - 4);

    for (let i = startP; i <= endP; i++) {
      let pBtn = document.createElement('button');
      pBtn.className = 'page-btn' + (i === currentPage ? ' active' : '');
      pBtn.innerText = i;
      pBtn.onclick = function() {
        if (typeof options.onPageChange === 'function' && i !== currentPage) options.onPageChange(i);
      };
      controls.appendChild(pBtn);
    }

    // Next Button
    var btnNext = document.createElement('button');
    btnNext.className = 'page-btn';
    btnNext.innerHTML = '<span class="material-symbols-outlined">chevron_right</span>';
    btnNext.disabled = currentPage === totalPages || totalPages === 0;
    btnNext.onclick = function() {
      if (typeof options.onPageChange === 'function') options.onPageChange(currentPage + 1);
    };
    controls.appendChild(btnNext);

    wrapper.appendChild(info);
    wrapper.appendChild(controls);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- FilterComponent.js --- */
/**
 * Filter Component
 * Thanh công cụ lọc dữ liệu
 */
var FilterComponent = (function () {
  /**
   * Tạo component bộ lọc
   * @param {Array} filters - Cấu hình các trường (vd: { id, label, type, placeholder })
   * @param {function} onSearch - Hàm callback khi bấm "Lọc"
   * @returns {HTMLElement} wrapper
   */
  function create(filters, onSearch) {
    var wrapper = document.createElement('div');
    wrapper.className = 'filter-wrapper';

    var inputs = {};

    filters.forEach(function(f) {
      var item = document.createElement('div');
      item.className = 'filter-item';

      if (f.label) {
        var lbl = document.createElement('label');
        lbl.innerText = f.label;
        item.appendChild(lbl);
      }

      var input = document.createElement('input');
      input.type = f.type || 'text';
      input.className = 'ui-input';
      if (f.placeholder) input.placeholder = f.placeholder;
      input.id = f.id;

      inputs[f.id] = input;
      item.appendChild(input);
      wrapper.appendChild(item);
    });

    var actions = document.createElement('div');
    actions.className = 'filter-actions';

    var btnSearch = document.createElement('button');
    btnSearch.className = 'btn btn-primary';
    btnSearch.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">search</span> Lọc dữ liệu';
    btnSearch.onclick = function() {
      if (typeof onSearch === 'function') {
        var values = {};
        for(var key in inputs) {
          values[key] = inputs[key].value;
        }
        onSearch(values);
      }
    };

    var btnReset = document.createElement('button');
    btnReset.className = 'btn btn-secondary';
    btnReset.innerText = 'Xóa bộ lọc';
    btnReset.onclick = function() {
      for(var key in inputs) {
        inputs[key].value = '';
      }
      if (typeof onSearch === 'function') onSearch({});
    };

    actions.appendChild(btnSearch);
    actions.appendChild(btnReset);
    wrapper.appendChild(actions);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Input.js --- */
/**
 * Input Component
 * Sinh ra các ô nhập liệu (Text, Number, Date...) kèm Label bằng DOM Node chuẩn.
 * An toàn XSS, tiện lợi khi build Form hoàn toàn bằng JavaScript.
 */
var UIInput = (function () {

  /**
   * Sinh cấu trúc Label + DOM Input
   */
  function _createBaseWrapper(config, inputType) {
    var wrapper = document.createElement('div');
    wrapper.className = 'form-group ' + (config.className || '');

    if (config.label) {
      var lbl = document.createElement('label');
      lbl.innerText = config.label;
      if (config.required) {
        var req = document.createElement('span');
        req.innerText = ' *';
        req.style.color = 'var(--color-danger)';
        lbl.appendChild(req);
      }
      wrapper.appendChild(lbl);
    }

    var input = document.createElement('input');
    input.type = inputType;
    input.className = 'ui-input';
    if (config.id) input.id = config.id;
    if (config.name) input.name = config.name;
    if (config.placeholder) input.placeholder = config.placeholder;
    if (config.value !== undefined) input.value = config.value;
    if (config.disabled) input.disabled = true;
    if (config.readonly) input.readOnly = true;

    wrapper.appendChild(input);

    return { wrapper: wrapper, input: input };
  }

  /**
   * Ô nhập Text thông thường
   */
  function createText(config) {
    return _createBaseWrapper(config, 'text').wrapper;
  }

  /**
   * Ô nhập Số
   */
  function createNumber(config) {
    var obj = _createBaseWrapper(config, 'number');
    if (config.min !== undefined) obj.input.min = config.min;
    if (config.max !== undefined) obj.input.max = config.max;
    if (config.step !== undefined) obj.input.step = config.step;
    return obj.wrapper;
  }

  /**
   * Ô chọn Ngày
   */
  function createDate(config) {
    return _createBaseWrapper(config, 'date').wrapper;
  }

  return {
    createText: createText,
    createNumber: createNumber,
    createDate: createDate
  };
})();


/* --- Button.js --- */
/**
 * Button Component
 * Sinh Nút bấm (Button) bằng DOM manipulation.
 */
var UIButton = (function () {

  /**
   * Tạo Nút bấm mới
   * @param {Object} config - { id, text, icon, type, className, onClick, disabled, tooltip }
   */
  function create(config) {
    var btn = document.createElement('button');
    
    // Base class
    var typeClass = config.type ? 'btn-' + config.type : 'btn-primary';
    if (config.type === 'tool') typeClass = 'btn-tool'; // Special case for toolbar
    
    btn.className = 'btn ' + typeClass + (config.className ? ' ' + config.className : '');
    
    if (config.id) btn.id = config.id;
    if (config.disabled) btn.disabled = true;
    if (config.tooltip) btn.title = config.tooltip;

    // Build nội dung
    var innerHTML = '';
    if (config.icon) {
      innerHTML += '<span class="material-symbols-outlined">' + config.icon + '</span>';
    }
    if (config.text) {
      innerHTML += '<span>' + config.text + '</span>';
    }
    btn.innerHTML = innerHTML;

    // Gắn sự kiện
    if (typeof config.onClick === 'function') {
      btn.addEventListener('click', function(e) {
        if (!btn.disabled) {
          config.onClick(e);
        }
      });
    }

    return btn;
  }

  /**
   * Tạo Bar chứa danh sách các nút
   * @param {Array} buttonsConfig - Mảng config của các nút
   */
  function createBar(buttonsConfig) {
    var bar = document.createElement('div');
    bar.className = 'button-bar';

    buttonsConfig.forEach(function(cfg) {
      if (cfg === '|') {
        var div = document.createElement('div');
        div.className = 'divider';
        bar.appendChild(div);
      } else {
        bar.appendChild(create(cfg));
      }
    });

    return bar;
  }

  return {
    create: create,
    createBar: createBar
  };
})();


/* --- Icon.js --- */
/**
 * Icon Component
 * Quản lý và render Icon (Hỗ trợ cả Material Symbols và Icon font riêng biệt)
 */
var UIIcon = (function () {
  
  /**
   * Sinh ra mã HTML của Icon
   * @param {string} iconName - Tên icon (VD: 'home', 'bar_chart', 'icon-grid')
   * @param {string} style - (Tùy chọn) Style inline bổ sung (VD: 'font-size: 18px;')
   * @param {string} className - (Tùy chọn) Class name bổ sung (VD: 'nav-icon')
   */
  function renderHtml(iconName, style, className) {
    if (!iconName) return '';
    var styleAttr = style ? ' style="' + style + '"' : '';
    var extraClass = className ? ' ' + className : '';
    
    // Nếu có chứa "icon-" hoặc dấu cách, hoặc dấu gạch ngang -> Dùng thẻ <i> cho Icon font
    if (iconName.indexOf('icon-') >= 0 || iconName.indexOf(' ') >= 0 || iconName.indexOf('-') > 0) {
      return '<i class="' + iconName + extraClass + '"' + styleAttr + '></i>';
    } else {
      // Mặc định: Google Material Symbols Outlined
      return '<span class="material-symbols-outlined' + extraClass + '"' + styleAttr + '>' + iconName + '</span>';
    }
  }

  /**
   * Tạo DOM Element của Icon
   * @param {string} iconName 
   * @param {string} className 
   */
  function create(iconName, className) {
    if (!iconName) return null;
    var el;
    if (iconName.indexOf('icon-') >= 0 || iconName.indexOf(' ') >= 0 || iconName.indexOf('-') > 0) {
      el = document.createElement('i');
      el.className = iconName + (className ? ' ' + className : '');
    } else {
      el = document.createElement('span');
      el.className = 'material-symbols-outlined' + (className ? ' ' + className : '');
      el.innerText = iconName;
    }
    return el;
  }

  return {
    renderHtml: renderHtml,
    create: create
  };
})();


/* --- ActionToolbar.js --- */
/**
 * Action Toolbar Component
 * Thanh công cụ chuẩn 6 nút: Thêm, Sửa, Xóa, Lọc, In, Đóng theo REQUIREMENT.md
 */
var UIActionToolbar = (function () {

  /**
   * Sinh thanh Toolbar nghiệp vụ
   * @param {Object} actions - { onAdd, onEdit, onDelete, onFilter, onPrint, onClose }
   */
  function create(actions) {
    actions = actions || {};
    
    return UIButton.createBar([
      { text: 'Thêm', icon: 'add', type: 'tool', onClick: actions.onAdd },
      { text: 'Sửa', icon: 'edit', type: 'tool', onClick: actions.onEdit },
      { text: 'Xóa', icon: 'delete', type: 'tool', onClick: actions.onDelete },
      { text: 'Lọc', icon: 'filter_alt', type: 'tool', onClick: actions.onFilter },
      { text: 'In', icon: 'print', type: 'tool', onClick: actions.onPrint },
      { text: 'Đóng', icon: 'close', type: 'tool', onClick: actions.onClose }
    ]);
  }

  return {
    create: create
  };
})();


/* --- Card.js --- */
/**
 * Card Component
 * Sinh khối bao bọc Card chuẩn xác bằng JS.
 */
var UICard = (function () {

  /**
   * Tạo Card
   * @param {Object} config - { title, rightElement (DOM), bodyContent (DOM/HTML), className }
   */
  function create(config) {
    var card = document.createElement('div');
    card.className = 'card ' + (config.className || '');

    // Header
    if (config.title || config.rightElement) {
      var header = document.createElement('div');
      header.className = 'card-header';
      
      var titleSpan = document.createElement('span');
      titleSpan.innerText = config.title || '';
      header.appendChild(titleSpan);

      if (config.rightElement) {
        header.appendChild(config.rightElement);
      }
      card.appendChild(header);
    }

    // Body
    var body = document.createElement('div');
    body.className = 'card-body';
    
    if (config.bodyContent) {
      if (typeof config.bodyContent === 'string') {
        body.innerHTML = config.bodyContent;
      } else {
        body.appendChild(config.bodyContent);
      }
    }

    card.appendChild(body);

    return card;
  }

  return {
    create: create
  };
})();


/* --- Table.js --- */
/**
 * Table Component
 * Sinh ra DataGrid Table với JS.
 */
var UITable = (function () {

  /**
   * Tạo Datagrid Table
   * @param {Object} config - { headers (Array), data (Array), columns (Array of mappings), className }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'table-wrapper ' + (config.className || '');

    var table = document.createElement('table');
    table.className = 'data-table';

    // Thead
    if (config.headers && config.headers.length > 0) {
      var thead = document.createElement('thead');
      var trHead = document.createElement('tr');
      
      config.headers.forEach(function(h) {
        var th = document.createElement('th');
        th.innerText = h.label || h;
        if (h.width) th.style.width = h.width;
        if (h.align) th.style.textAlign = h.align;
        trHead.appendChild(th);
      });
      thead.appendChild(trHead);
      table.appendChild(thead);
    }

    // Tbody
    var tbody = document.createElement('tbody');
    
    if (config.data && config.data.length > 0) {
      config.data.forEach(function(row) {
        var tr = document.createElement('tr');
        
        // Render either via columns map or direct array
        if (config.columns) {
          config.columns.forEach(function(col) {
            var td = document.createElement('td');
            if (col.align) td.style.textAlign = col.align;
            
            var val = row[col.field];
            if (col.render) {
              var rendered = col.render(val, row);
              if (typeof rendered === 'string') td.innerHTML = rendered;
              else if (rendered instanceof Node) td.appendChild(rendered);
            } else {
              td.innerText = val !== undefined ? val : '';
            }
            tr.appendChild(td);
          });
        } else {
          // Fallback pass raw array
          row.forEach(function(cellStr) {
            var td = document.createElement('td');
            if (typeof cellStr === 'string' && cellStr.indexOf('<') > -1) {
              td.innerHTML = cellStr;
            } else {
              td.innerText = cellStr;
            }
            tr.appendChild(td);
          });
        }

        tbody.appendChild(tr);
      });
    } else {
       var trEmpty = document.createElement('tr');
       var tdEmpty = document.createElement('td');
       tdEmpty.colSpan = config.headers ? config.headers.length : 1;
       tdEmpty.style.textAlign = 'center';
       tdEmpty.style.padding = '32px';
       tdEmpty.style.color = 'var(--color-text-secondary)';
       tdEmpty.innerText = 'Không có dữ liệu';
       trEmpty.appendChild(tdEmpty);
       tbody.appendChild(trEmpty);
    }

    table.appendChild(tbody);
    wrapper.appendChild(table);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Tabs.js --- */
/**
 * Tabs Component
 * Quản lý chuyển đổi các Tab (Ví dụ: Tab Bàn tiệc, Tab Khác...)
 */
var UITabs = (function () {

  /**
   * Tạo bộ Tabs
   * @param {Array} tabsConfig - [{ id, title, content (DOM) }]
   */
  function create(tabsConfig) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-tabs';

    var header = document.createElement('div');
    header.className = 'ui-tabs-header';

    var body = document.createElement('div');
    body.className = 'ui-tabs-body';

    tabsConfig.forEach(function(tab, index) {
      // Header Button
      var btn = document.createElement('button');
      btn.className = 'ui-tab-btn' + (index === 0 ? ' active' : '');
      btn.innerText = tab.title;
      btn.dataset.target = tab.id;
      header.appendChild(btn);

      // Panel Body
      var panel = document.createElement('div');
      panel.className = 'ui-tab-panel' + (index === 0 ? ' active' : '');
      panel.id = 'panel-' + tab.id;
      
      if (typeof tab.content === 'string') {
        panel.innerHTML = tab.content;
      } else if (tab.content instanceof Node) {
        panel.appendChild(tab.content);
      }
      
      body.appendChild(panel);

      // Event listener
      btn.addEventListener('click', function() {
        // Gỡ active toàn bộ
        var allBtns = header.querySelectorAll('.ui-tab-btn');
        var allPanels = body.querySelectorAll('.ui-tab-panel');
        
        allBtns.forEach(b => b.classList.remove('active'));
        allPanels.forEach(p => p.classList.remove('active'));

        // Set active cho nút được bấm
        btn.classList.add('active');
        panel.classList.add('active');
      });
    });

    wrapper.appendChild(header);
    wrapper.appendChild(body);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- NestedTabs.js --- */
/**
 * UINestedTabs — Tab phân cấp 2 cấp (Cha → Con) + Kéo thả sắp xếp
 * ──────────────────────────────────────────────────────────────────
 * Nhận vào một mảng flat từ DB (giống WA_Menu):
 *   [{ id, parent, label, [icon], [formName] }]
 *
 * Quy tắc xác định cha/con:
 *   - parent === '' hoặc null/undefined → Tab CHA (root)
 *   - parent !== ''                     → Tab CON (thuộc parent đó)
 *
 * API:
 *   UINestedTabs.create(records, options?) → DOM Element
 *   UINestedTabs.createFromDB(dbRows, options?) → DOM Element
 *
 * Options:
 *   onTabChange(parentId, childId)            - callback khi đổi tab
 *   onReorder(type, orderedIds, parentId?)    - callback khi kéo thả xong
 *                                               type = 'parent' | 'child'
 *   renderContent(item)                       - trả về Node | string cho panel
 *   defaultParentId                           - tab cha active ban đầu
 *   defaultChildId                            - tab con active ban đầu
 *   draggable                                 - true (mặc định) để bật kéo thả
 */
var UINestedTabs = (function () {

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: create
  // ════════════════════════════════════════════════════════════
  function create(records, options) {
    options = options || {};
    var isDraggable = options.draggable !== false; // bật mặc định

    // ── 1. Phân loại cha / con ──────────────────────────────────
    var parents = records.filter(function (r) {
      return !r.parent || r.parent.trim() === '';
    });

    var childrenMap = {}; // { parentId: [child, ...] }
    records.forEach(function (r) {
      if (r.parent && r.parent.trim() !== '') {
        if (!childrenMap[r.parent]) childrenMap[r.parent] = [];
        childrenMap[r.parent].push(r);
      }
    });

    if (parents.length === 0) {
      var empty = document.createElement('div');
      empty.className = 'ui-nested-tabs-empty';
      empty.textContent = 'Không có dữ liệu Tab';
      return empty;
    }

    // ── Phân nhánh: Vertical vs Horizontal ──────────────────
    if (options.vertical) {
      return _createVertical(parents, childrenMap, options);
    }

    // ── 2. Active mặc định ──────────────────────────────────────
    var defaultParentId = options.defaultParentId || parents[0].id;
    var activeParent    = parents.find(function (p) { return p.id === defaultParentId; }) || parents[0];

    // ── 3. Wrapper ───────────────────────────────────────────────
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-nested-tabs';

    // ── 4. Parent Tab Bar ────────────────────────────────────────
    var parentBar = document.createElement('div');
    parentBar.className = 'ui-nested-tabs__parent-bar';

    // ── 5. Child Area ────────────────────────────────────────────
    var childArea = document.createElement('div');
    childArea.className = 'ui-nested-tabs__child-area';

    // ── 6. Render mỗi parent ────────────────────────────────────
    parents.forEach(function (parentItem) {
      var isParentActive = (parentItem.id === activeParent.id);
      var children       = childrenMap[parentItem.id] || [];

      // ─ Parent button ─
      var pBtn = _buildParentBtn(parentItem, isParentActive, children.length, isDraggable);
      parentBar.appendChild(pBtn);

      // ─ Child section ─
      var childSection = document.createElement('div');
      childSection.className = 'ui-nested-tabs__section' + (isParentActive ? ' active' : '');
      childSection.dataset.sectionId = parentItem.id;

      if (children.length > 0) {
        var defaultChildId  = isParentActive ? (options.defaultChildId || children[0].id) : children[0].id;

        var childBar        = document.createElement('div');
        childBar.className  = 'ui-nested-tabs__child-bar';

        var panelArea       = document.createElement('div');
        panelArea.className = 'ui-nested-tabs__panel-area';

        children.forEach(function (childItem) {
          var isChildActive = (childItem.id === defaultChildId);

          // Child btn
          var cBtn = _buildChildBtn(childItem, parentItem, isChildActive, isDraggable);
          childBar.appendChild(cBtn);

          // Panel
          var panel = _buildPanel(childItem, parentItem, isChildActive, options);
          panelArea.appendChild(panel);

          // Click: activate child tab
          cBtn.addEventListener('click', function () {
            _activateChildTab(childBar, panelArea, cBtn, panel);
            if (typeof options.onTabChange === 'function') {
              options.onTabChange(parentItem.id, childItem.id);
            }
          });
        });

        // Drag-and-drop cho child bar
        if (isDraggable) {
          _attachDragToBar(childBar, panelArea, 'child', parentItem.id, options);
        }

        childSection.appendChild(childBar);
        childSection.appendChild(panelArea);

      } else {
        // Không có con → panel trực tiếp
        var soloPanel = _buildPanel(parentItem, null, true, options);
        childSection.appendChild(soloPanel);
      }

      childArea.appendChild(childSection);

      // Click: activate parent tab
      pBtn.addEventListener('click', function () {
        _activateParentTab(parentBar, childArea, pBtn, childSection);
        if (typeof options.onTabChange === 'function') {
          var activeChild = childSection.querySelector('.ui-nested-tab-child-btn.active');
          options.onTabChange(parentItem.id, activeChild ? activeChild.dataset.childId : null);
        }
      });
    });

    // Drag-and-drop cho parent bar
    if (isDraggable) {
      _attachDragToBar(parentBar, null, 'parent', null, options);
    }

    wrapper.appendChild(parentBar);
    wrapper.appendChild(childArea);
    return wrapper;
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC: createFromDB
  // ════════════════════════════════════════════════════════════
  function createFromDB(dbRows, options) {
    var records = (dbRows || []).map(function (row) {
      return {
        id:       row.MenuID   || row.id       || row.menuId,
        parent:   row.Parent   || row.parent   || row.parentId || '',
        label:    row.VN       || row.label    || row.name || row.Label || '(Không tên)',
        labelEN:  row.EN       || row.en       || '',
        icon:     row.IconClass || row.icon    || '',
        formName: row.FormName  || row.formName || ''
      };
    });
    return create(records, options);
  }

  // ════════════════════════════════════════════════════════════
  //  PRIVATE: builders
  // ════════════════════════════════════════════════════════════

  function _buildParentBtn(item, isActive, childCount, isDraggable) {
    var btn = document.createElement('button');
    btn.className = 'ui-nested-tab-parent-btn' + (isActive ? ' active' : '');
    btn.dataset.parentId = item.id;

    // Drag handle icon (chỉ hiện khi hover nhờ CSS)
    if (isDraggable) {
      var handle = UIIcon.create('drag_indicator', 'ui-nested-drag-handle');
      btn.appendChild(handle);
      btn.draggable = true;
      btn.dataset.dragType = 'parent';
    }

    if (item.icon) {
      var iconEl = UIIcon.create(item.icon);
      if (iconEl) { iconEl.style.fontSize = '18px'; btn.appendChild(iconEl); }
    }

    var labelSpan = document.createElement('span');
    labelSpan.textContent = item.label || item.id;
    btn.appendChild(labelSpan);

    if (childCount > 0) {
      var badge = document.createElement('span');
      badge.className = 'ui-nested-tab-badge';
      badge.textContent = childCount;
      btn.appendChild(badge);
    }

    return btn;
  }

  function _buildChildBtn(childItem, parentItem, isActive, isDraggable) {
    var btn = document.createElement('button');
    btn.className = 'ui-nested-tab-child-btn' + (isActive ? ' active' : '');
    btn.dataset.childId  = childItem.id;
    btn.dataset.parentId = parentItem.id;

    if (isDraggable) {
      var handle = UIIcon.create('drag_indicator', 'ui-nested-drag-handle ui-nested-drag-handle--child');
      btn.appendChild(handle);

      btn.draggable = true;
      btn.dataset.dragType = 'child';
    }

    var labelSpan = document.createElement('span');
    labelSpan.textContent = childItem.label || childItem.id;
    btn.appendChild(labelSpan);

    return btn;
  }

  function _buildPanel(item, parentItem, isActive, options) {
    var panel = document.createElement('div');
    panel.className = 'ui-nested-tab-panel' + (isActive ? ' active' : '');
    panel.id = 'nested-panel-' + item.id;

    if (typeof options.renderContent === 'function') {
      var content = options.renderContent(item);
      if (typeof content === 'string') {
        panel.innerHTML = content;
      } else if (content instanceof Node) {
        panel.appendChild(content);
      }
    } else {
      panel.innerHTML = _defaultPanelHTML(item, parentItem);
    }

    return panel;
  }

  // ════════════════════════════════════════════════════════════
  //  PRIVATE: activate helpers
  // ════════════════════════════════════════════════════════════

  function _activateParentTab(parentBar, childArea, activeBtn, activeSection) {
    parentBar.querySelectorAll('.ui-nested-tab-parent-btn').forEach(function (b) {
      b.classList.remove('active');
    });
    childArea.querySelectorAll('.ui-nested-tabs__section').forEach(function (s) {
      s.classList.remove('active');
    });
    activeBtn.classList.add('active');
    activeSection.classList.add('active');
  }

  function _activateChildTab(childBar, panelArea, activeBtn, activePanel) {
    childBar.querySelectorAll('.ui-nested-tab-child-btn').forEach(function (b) {
      b.classList.remove('active');
    });
    panelArea.querySelectorAll('.ui-nested-tab-panel').forEach(function (p) {
      p.classList.remove('active');
    });
    activeBtn.classList.add('active');
    activePanel.classList.add('active');
  }

  // ════════════════════════════════════════════════════════════
  //  PRIVATE: Drag-and-drop
  // ════════════════════════════════════════════════════════════

  /**
   * Gắn drag-and-drop vào một tab bar (parent hoặc child)
   * @param {Element} bar          - thanh tab chứa các btn có thể kéo
   * @param {Element|null} panelArea - vùng panel tương ứng (dùng để sync thứ tự panel)
   * @param {string}  type         - 'parent' | 'child'
   * @param {string|null} parentId - id của tab cha (chỉ dùng khi type='child')
   * @param {Object}  options      - options của component
   */
  function _attachDragToBar(bar, panelArea, type, parentId, options) {
    var dragging    = null;  // phần tử đang kéo
    var placeholder = null;  // dải chỉ vị trí thả

    // Selector của các btn trong bar
    var btnSelector = (type === 'parent')
      ? '.ui-nested-tab-parent-btn'
      : '.ui-nested-tab-child-btn';

    // ── dragstart ──
    bar.addEventListener('dragstart', function (e) {
      var btn = e.target.closest(btnSelector);
      if (!btn) return;

      dragging = btn;
      dragging.classList.add('ui-nested-dragging');

      // Tạo ghost image sạch
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', btn.dataset.parentId || btn.dataset.childId || '');

      // Tạo placeholder
      placeholder = document.createElement('div');
      placeholder.className = 'ui-nested-drop-placeholder';
      if (type === 'child') placeholder.classList.add('ui-nested-drop-placeholder--child');
    });

    // ── dragover ──
    bar.addEventListener('dragover', function (e) {
      if (!dragging) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';

      var target = e.target.closest(btnSelector);
      if (!target || target === dragging) {
        return;
      }

      // Xác định thả vào trước hay sau
      var rect   = target.getBoundingClientRect();
      var offset = (type === 'parent')
        ? e.clientX - rect.left    // ngang
        : e.clientX - rect.left;   // ngang (child bar cũng ngang)
      var half = (type === 'parent') ? rect.width / 2 : rect.width / 2;

      // Xóa placeholder cũ nếu có
      if (placeholder.parentNode) placeholder.parentNode.removeChild(placeholder);

      if (offset < half) {
        bar.insertBefore(placeholder, target);
      } else {
        var next = target.nextSibling;
        if (next) bar.insertBefore(placeholder, next);
        else bar.appendChild(placeholder);
      }
    });

    // ── dragleave ──
    bar.addEventListener('dragleave', function (e) {
      // Chỉ xóa placeholder khi ra ngoài bar
      if (!bar.contains(e.relatedTarget) && placeholder && placeholder.parentNode) {
        placeholder.parentNode.removeChild(placeholder);
      }
    });

    // ── drop ──
    bar.addEventListener('drop', function (e) {
      e.preventDefault();
      if (!dragging || !placeholder || !placeholder.parentNode) return;

      // Đặt btn vào vị trí placeholder
      bar.insertBefore(dragging, placeholder);
      placeholder.parentNode.removeChild(placeholder);

      // Sync thứ tự panel nếu là child bar
      if (panelArea) {
        _syncPanelOrder(bar, panelArea, btnSelector);
      }

      // Gọi onReorder callback
      if (typeof options.onReorder === 'function') {
        var orderedIds = Array.from(bar.querySelectorAll(btnSelector)).map(function (b) {
          return type === 'parent' ? b.dataset.parentId : b.dataset.childId;
        });
        options.onReorder(type, orderedIds, parentId);
      }

      _cleanup();
    });

    // ── dragend ──
    bar.addEventListener('dragend', function () {
      _cleanup();
    });

    // ─ cleanup local state ─
    function _cleanup() {
      if (dragging) {
        dragging.classList.remove('ui-nested-dragging');
        dragging = null;
      }
      if (placeholder && placeholder.parentNode) {
        placeholder.parentNode.removeChild(placeholder);
      }
      placeholder = null;
    }
  }

  /**
   * Sau khi kéo thả child btn, sắp xếp lại các panel theo thứ tự btn mới
   */
  function _syncPanelOrder(childBar, panelArea, btnSelector) {
    var btns = Array.from(childBar.querySelectorAll(btnSelector));
    btns.forEach(function (btn) {
      var childId = btn.dataset.childId;
      var panel   = panelArea.querySelector('#nested-panel-' + childId);
      if (panel) panelArea.appendChild(panel); // appendChild tự move về cuối → đúng thứ tự
    });
  }

  // ════════════════════════════════════════════════════════════
  //  PRIVATE: default panel content
  // ════════════════════════════════════════════════════════════

  function _defaultPanelHTML(item, parentItem) {
    return [
      '<div class="ui-nested-tab-default-content">',
        UIIcon.renderHtml(item.icon || 'folder_open', 'font-size:40px;opacity:0.2;display:block;margin-bottom:12px'),
        '<div style="font-weight:600;font-size:15px;margin-bottom:6px">', item.label || item.id, '</div>',
        parentItem
          ? '<div style="font-size:12px;opacity:0.5">Thuộc nhóm: ' + parentItem.label + ' (' + parentItem.id + ')</div>'
          : '',
        item.formName
          ? '<code style="font-size:11px;opacity:0.5;display:block;margin-top:8px">' + item.formName + '</code>'
          : '',
      '</div>'
    ].join('');
  }

  // ════════════════════════════════════════════════════════════
  //  PRIVATE: Vertical layout
  // ════════════════════════════════════════════════════════════

  function _createVertical(parents, childrenMap, options) {
    var isDraggable = options.draggable !== false;

    var defaultParentId = options.defaultParentId || parents[0].id;
    var activeParent    = parents.find(function (p) { return p.id === defaultParentId; }) || parents[0];
    var defaultChildId  = options.defaultChildId  || null;

    var initChildren = childrenMap[activeParent.id] || [];
    var activeChildId = defaultChildId || (initChildren.length > 0 ? initChildren[0].id : null);

    var allContentPanels = [];
    var allSidebarBtns = [];

    var wrapper = document.createElement('div');
    wrapper.className = 'ui-nested-tabs ui-nested-tabs--vertical';

    var sidebar = document.createElement('div');
    sidebar.className = 'ui-nested-tabs__sidebar';

    var contentArea = document.createElement('div');
    contentArea.className = 'ui-nested-tabs__vertical-content';

    function _buildSidebarNode(node, level, isNodeActive, shouldOpen) {
      var children = childrenMap[node.id] || [];
      var isRoot = level === 0;

      var parentGroup = document.createElement('div');
      parentGroup.className = 'ui-nested-tabs__sidebar-parent level-' + level;
      if (isDraggable) {
        parentGroup.draggable = true;
        parentGroup.dataset.dragParentId = node.id;
      }

      var pBtn = document.createElement('button');
      pBtn.className = (isRoot ? 'ui-nested-tab-parent-btn--v' : 'ui-nested-tab-child-btn--v') + (isNodeActive ? ' active' : '');
      pBtn.dataset.nodeId = node.id;
      pBtn.dataset.parentId = node.parent || '';
      if (!isRoot) {
          pBtn.dataset.childId = node.id; 
      }
      
      if (level > 0) {
        pBtn.style.paddingLeft = (16 + level * 20) + 'px';
      }

      if (isDraggable) {
        var handle = UIIcon.create('drag_indicator', 'ui-nested-drag-handle' + (isRoot ? '' : ' ui-nested-drag-handle--child'));
        pBtn.appendChild(handle);
        if (!isRoot) {
            pBtn.draggable = true;
            pBtn.dataset.dragType = 'child';
        }
      }

      var iconWrap = document.createElement('div');
      iconWrap.style.cssText = 'width: 20px; display: flex; justify-content: center; align-items: center; flex-shrink: 0;';
      if (!isRoot) iconWrap.style.marginRight = '8px';

      var actualIcon = node.icon;
      if (!actualIcon || actualIcon.indexOf('icon-') === 0) actualIcon = (isRoot ? 'folder_open' : 'horizontal_rule');

      var iconEl = UIIcon.create(actualIcon);
      if (iconEl) {
        iconEl.style.fontSize = isRoot ? '18px' : '16px';
        if (!node.icon || node.icon.indexOf('icon-') === 0) {
          iconEl.style.opacity = '0.3';
        }
        iconWrap.appendChild(iconEl);
      }
      pBtn.appendChild(iconWrap);

      var lbl = document.createElement('span');
      lbl.style.cssText = 'flex:1;overflow:hidden;text-overflow:ellipsis;';
      lbl.textContent = node.label || node.id;
      pBtn.appendChild(lbl);

      if (children.length > 0) {
        var badge = document.createElement('span');
        badge.className = 'ui-nested-tab-badge';
        badge.style.cssText = 'min-width:18px;height:18px;font-size:10px; margin-right: 4px;';
        badge.textContent = children.length;
        pBtn.appendChild(badge);

        var chevron = UIIcon.create('expand_more', 'ui-nested-parent-chevron');
        pBtn.appendChild(chevron);
      }

      parentGroup.appendChild(pBtn);
      allSidebarBtns.push(pBtn);

      var childList = null;
      if (children.length > 0) {
        childList = document.createElement('div');
        childList.className = 'ui-nested-tabs__child-list' + (shouldOpen ? ' open' : '');

        children.forEach(function (childItem) {
           var childIsActive = isNodeActive && (childItem.id === activeChildId);
           var childShouldOpen = childIsActive;
           var cRes = _buildSidebarNode(childItem, level + 1, childIsActive, childShouldOpen);
           childList.appendChild(cRes.group);
        });

        parentGroup.appendChild(childList);

        if (isDraggable) {
          _attachVerticalDrag(childList, contentArea, node.id, options);
        }
      }

      var parentPanel = document.createElement('div');
      parentPanel.className = 'ui-nested-tab-panel--v' + (isNodeActive && (!activeChildId || activeChildId === '') ? ' active' : '');
      parentPanel.id = 'nested-panel-' + node.id;
      if (typeof options.renderContent === 'function') {
        var sc = options.renderContent(node);
        if (typeof sc === 'string') { parentPanel.innerHTML = sc; }
        else if (sc instanceof Node) { parentPanel.appendChild(sc); }
      } else { parentPanel.innerHTML = _defaultPanelHTML(node, null); }
      contentArea.appendChild(parentPanel);
      allContentPanels.push(parentPanel);

      pBtn.addEventListener('click', function (e) {
        e.stopPropagation();

        var isPanelActive = parentPanel.classList.contains('active');

        allSidebarBtns.forEach(function(b) { b.classList.remove('active'); });
        allContentPanels.forEach(function(p) { p.classList.remove('active'); });

        pBtn.classList.add('active');

        if (!isPanelActive) {
          parentPanel.classList.add('active');
          if (childList) childList.classList.add('open');
          
          var curr = parentGroup.parentElement;
          while(curr && curr.classList.contains('ui-nested-tabs__child-list')) {
            curr.classList.add('open');
            curr = curr.parentElement.parentElement;
          }

          if (typeof options.onTabChange === 'function') {
            options.onTabChange(node.id, null);
          }
        } else {
          parentPanel.classList.add('active');
          if (childList) {
            childList.classList.toggle('open');
          }
        }
      });

      return { group: parentGroup };
    }

    parents.forEach(function (parentItem) {
      var isParentActive = (parentItem.id === activeParent.id);
      var res = _buildSidebarNode(parentItem, 0, isParentActive, isParentActive);
      sidebar.appendChild(res.group);
    });

    if (isDraggable) {
      // NOTE: attach to sidebar directly
      _attachVerticalDragParent(sidebar, options);
    }

    var resizer = document.createElement('div');
    resizer.className = 'ui-nested-resizer';
    sidebar.appendChild(resizer);
    _initSidebarResizer(resizer, sidebar);

    wrapper.appendChild(sidebar);
    wrapper.appendChild(contentArea);
    return wrapper;
  }

  /**
   * Khởi tạo tính năng kéo giãn sidebar
   */
  function _initSidebarResizer(resizer, sidebar) {
    var isResizing = false;

    resizer.addEventListener('mousedown', function (e) {
      isResizing = true;
      resizer.classList.add('is-resizing');
      document.body.style.cursor = 'col-resize';
      document.body.style.userSelect = 'none';
      
      var onMouseMove = function (e) {
        if (!isResizing) return;
        
        // Tính toán độ rộng mới dựa trên vị trí chuột
        var containerRect = sidebar.parentElement.getBoundingClientRect();
        var newWidth = e.clientX - containerRect.left;
        
        // Giới hạn width từ 180px đến 600px
        if (newWidth < 180) newWidth = 180;
        if (newWidth > 600) newWidth = 600;
        
        sidebar.style.width = newWidth + 'px';
      };

      var onMouseUp = function () {
        isResizing = false;
        resizer.classList.remove('is-resizing');
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
        window.removeEventListener('mousemove', onMouseMove);
        window.removeEventListener('mouseup', onMouseUp);
      };

      window.addEventListener('mousemove', onMouseMove);
      window.addEventListener('mouseup', onMouseUp);
    });
  }

  // ── Drag dọc cho child list ──────────────────────────────
  function _attachVerticalDrag(childList, contentArea, parentId, options) {
    var dragging    = null;
    var placeholder = null;

    childList.addEventListener('dragstart', function (e) {
      var grp = e.target.closest('.ui-nested-tabs__sidebar-parent');
      if (!grp || grp.parentElement !== childList) return;
      dragging = grp;
      dragging.classList.add('ui-nested-dragging');
      e.dataTransfer.effectAllowed = 'move';
      placeholder = document.createElement('div');
      placeholder.className = 'ui-nested-drop-placeholder--v';
      e.stopPropagation();
    });

    childList.addEventListener('dragover', function (e) {
      if (!dragging) return;
      e.preventDefault();
      var target = e.target.closest('.ui-nested-tabs__sidebar-parent');
      if (!target || target === dragging || target.parentElement !== childList) return;
      if (placeholder.parentNode) placeholder.parentNode.removeChild(placeholder);
      var rect   = target.getBoundingClientRect();
      var isUpper = (e.clientY - rect.top) < rect.height / 2;
      if (isUpper) childList.insertBefore(placeholder, target);
      else { var nx = target.nextSibling; if (nx) childList.insertBefore(placeholder, nx); else childList.appendChild(placeholder); }
    });

    childList.addEventListener('dragleave', function (e) {
      if (!childList.contains(e.relatedTarget) && placeholder && placeholder.parentNode) {
        placeholder.parentNode.removeChild(placeholder);
      }
    });

    childList.addEventListener('drop', function (e) {
      e.preventDefault();
      e.stopPropagation();
      if (!dragging || !placeholder || !placeholder.parentNode) return;
      childList.insertBefore(dragging, placeholder);
      placeholder.parentNode.removeChild(placeholder);
      
      // Sync panel order for UI (if needed, but panels are all flat in contentArea)
      // Array.from(childList.children).forEach(...) is possible, but contentArea order doesn't break CSS rendering.
      
      if (typeof options.onReorder === 'function') {
        var ids = Array.from(childList.querySelectorAll(':scope > .ui-nested-tabs__sidebar-parent > .ui-nested-tab-child-btn--v')).map(function (b) { return b.dataset.childId || b.dataset.nodeId; });
        options.onReorder('child', ids, parentId);
      }
      _vCleanup();
    });

    childList.addEventListener('dragend', function(e) { e.stopPropagation(); _vCleanup(); });

    function _vCleanup() {
      if (dragging) { dragging.classList.remove('ui-nested-dragging'); dragging = null; }
      if (placeholder && placeholder.parentNode) placeholder.parentNode.removeChild(placeholder);
      placeholder = null;
    }
  }

  // ── Drag dọc cho parent groups ───────────────────────────
  function _attachVerticalDragParent(sidebar, options) {
    var dragging    = null;
    var placeholder = null;

    sidebar.addEventListener('dragstart', function (e) {
      var grp = e.target.closest('.ui-nested-tabs__sidebar-parent');
      if (!grp || grp.parentElement !== sidebar) return;
      dragging = grp;
      dragging.classList.add('ui-nested-dragging');
      e.dataTransfer.effectAllowed = 'move';
      placeholder = document.createElement('div');
      placeholder.className = 'ui-nested-drop-placeholder--v';
      placeholder.style.margin = '2px 0';
      e.stopPropagation();
    });

    sidebar.addEventListener('dragover', function (e) {
      if (!dragging) return;
      e.preventDefault();
      var target = e.target.closest('.ui-nested-tabs__sidebar-parent');
      if (!target || target === dragging || target.parentElement !== sidebar) return;
      if (placeholder.parentNode) placeholder.parentNode.removeChild(placeholder);
      var rect   = target.getBoundingClientRect();
      var isUpper = (e.clientY - rect.top) < rect.height / 2;
      if (isUpper) sidebar.insertBefore(placeholder, target);
      else { var nx = target.nextSibling; if (nx) sidebar.insertBefore(placeholder, nx); else sidebar.appendChild(placeholder); }
    });

    sidebar.addEventListener('dragleave', function (e) {
      if (!sidebar.contains(e.relatedTarget) && placeholder && placeholder.parentNode) {
        placeholder.parentNode.removeChild(placeholder);
      }
    });

    sidebar.addEventListener('drop', function (e) {
      e.preventDefault();
      e.stopPropagation();
      if (!dragging || !placeholder || !placeholder.parentNode) return;
      sidebar.insertBefore(dragging, placeholder);
      placeholder.parentNode.removeChild(placeholder);
      if (typeof options.onReorder === 'function') {
        var ids = Array.from(sidebar.querySelectorAll(':scope > .ui-nested-tabs__sidebar-parent > .ui-nested-tab-parent-btn--v')).map(function (b) {
          return b.dataset.parentId || b.dataset.nodeId;
        });
        options.onReorder('parent', ids, null);
      }
      _vpCleanup();
    });

    sidebar.addEventListener('dragend', function(e) { e.stopPropagation(); _vpCleanup(); });

    function _vpCleanup() {
      if (dragging) { dragging.classList.remove('ui-nested-dragging'); dragging = null; }
      if (placeholder && placeholder.parentNode) placeholder.parentNode.removeChild(placeholder);
      placeholder = null;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  EXPORTS
  // ════════════════════════════════════════════════════════════
  return {
    create:       create,
    createFromDB: createFromDB
  };

})();


/* --- TotalBar.js --- */
/**
 * Total Bar Component
 * Thanh tổng cộng ở cuối bảng / trang (Ví dụ: Tổng chi phí, Tổng doanh thu)
 */
var UITotalBar = (function () {

  /**
   * Sinh thanh TotalBar
   * @param {Object} config - { label, valueStr, className }
   */
  function create(config) {
    var bar = document.createElement('div');
    bar.className = 'total-bar ' + (config.className || '');
    
    var label = document.createElement('div');
    label.className = 'total-bar-label';
    label.innerText = config.label || 'Tổng cộng';

    var val = document.createElement('div');
    val.className = 'total-bar-value';
    val.innerText = config.valueStr || '0';

    bar.appendChild(label);
    bar.appendChild(val);

    return bar;
  }

  return {
    create: create
  };
})();


/* --- Badge.js --- */
/**
 * Badge Component
 * Sinh ra các nhãn trạng thái (Ví dụ: Đã Thanh Toán, Còn trống, Hủy)
 */
var UIBadge = (function () {

  /**
   * Sinh Badge
   * @param {string} text - Nội dung hiển thị
   * @param {string} type - success | danger | warning | primary
   */
  function create(text, type) {
    var badge = document.createElement('span');
    badge.className = 'status-badge ' + (type || 'primary');
    badge.innerText = text;
    return badge;
  }

  return {
    create: create
  };
})();


/* --- Chart.js --- */
/**
 * Chart.js Wrapper Component 
 * Cần nạp Chart.js CDN trong index.html
 */
var UIChart = (function () {

  /**
   * Sinh một khối thẻ chứa Chart
   * @param {Object} config - { title, type, data, options }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'chart-wrapper';

    if (config.title) {
      var header = document.createElement('div');
      header.className = 'chart-header';
      header.innerHTML = '<div class="chart-title">' + config.title + '</div>';
      wrapper.appendChild(header);
    }

    var chartContainer = document.createElement('div');
    chartContainer.className = 'chart-container';
    
    var canvas = document.createElement('canvas');
    chartContainer.appendChild(canvas);
    wrapper.appendChild(chartContainer);

    // Kích hoạt chart mượt sau khi insert vào DOM
    setTimeout(function() {
      if (typeof Chart !== 'undefined') {
        new Chart(canvas, {
          type: config.type || 'bar',
          data: config.data || {},
          options: Object.assign({
            responsive: true,
            maintainAspectRatio: false
          }, config.options || {})
        });
      }
    }, 100);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Stepper.js --- */
/**
 * Stepper Component
 * Sinh thanh điều hướng tiến trình nhiều bước (VD: Step 1 -> Step 2 -> Step 3)
 */
var UIStepper = (function () {

  /**
   * Tạo Thanh Trình Tự
   * @param {Array} steps - [{ label: 'Chọn Sảnh' }, { label: 'Chọn Món' }]
   * @param {number} currentStepIndex - Bắt đầu từ 0
   */
  function create(steps, currentStepIndex) {
    currentStepIndex = currentStepIndex || 0;
    
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-stepper';

    steps.forEach(function(step, index) {
      var stepDiv = document.createElement('div');
      stepDiv.className = 'ui-step';
      
      if (index < currentStepIndex) {
        stepDiv.classList.add('completed');
      } else if (index === currentStepIndex) {
        stepDiv.classList.add('active');
      }

      var circle = document.createElement('div');
      circle.className = 'ui-step-circle';
      if (index < currentStepIndex) {
        circle.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">check</span>';
      } else {
        circle.innerText = (index + 1);
      }

      var label = document.createElement('div');
      label.className = 'ui-step-label';
      label.innerText = step.label;

      stepDiv.appendChild(circle);
      stepDiv.appendChild(label);
      wrapper.appendChild(stepDiv);
    });

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Timeline.js --- */
/**
 * Timeline Component
 * Sinh ra Danh sách Lịch sử thao tác (VD: Cọc lần 1 -> Đổi cọc -> Cọc lần 2 -> Ký Hợp Đồng)
 */
var UITimeline = (function () {

  /**
   * Tạo Timeline
   * @param {Array} events - [{ title, time, desc, type: 'success'|'primary'|'' }]
   */
  function create(events) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-timeline';

    events.forEach(function(ev) {
      var item = document.createElement('div');
      item.className = 'timeline-item ' + (ev.type || '');

      var marker = document.createElement('div');
      marker.className = 'timeline-marker';

      var content = document.createElement('div');
      content.className = 'timeline-content';

      var title = document.createElement('div');
      title.className = 'timeline-title';
      title.innerText = ev.title;

      var time = document.createElement('div');
      time.className = 'timeline-time';
      time.innerText = ev.time || '';

      content.appendChild(title);
      content.appendChild(time);

      if (ev.desc) {
        var desc = document.createElement('div');
        desc.className = 'timeline-desc';
        desc.innerText = ev.desc;
        content.appendChild(desc);
      }

      item.appendChild(marker);
      item.appendChild(content);
      wrapper.appendChild(item);
    });

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- EmptyState.js --- */
/**
 * EmptyState Component
 * Trạng thái trống (VD: Chưa có khách hàng, chưa có hợp đồng)
 */
var UIEmptyState = (function () {

  /**
   * Tạo màn hình rỗng
   * @param {Object} config - { icon, title, desc, action (DOM Node) }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-empty-state';

    var iconSpan = document.createElement('span');
    iconSpan.className = 'material-symbols-outlined ui-empty-icon';
    iconSpan.innerText = config.icon || 'inbox';
    wrapper.appendChild(iconSpan);

    var titleDiv = document.createElement('div');
    titleDiv.className = 'ui-empty-title';
    titleDiv.innerText = config.title || 'Không có dữ liệu';
    wrapper.appendChild(titleDiv);

    if (config.desc) {
      var descDiv = document.createElement('div');
      descDiv.className = 'ui-empty-desc';
      descDiv.innerText = config.desc;
      wrapper.appendChild(descDiv);
    }

    if (config.action instanceof Node) {
      wrapper.appendChild(config.action);
    }

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- FileUpload.js --- */
/**
 * File Upload Component
 * Cung cấp vùng Drag & Drop để upload Ảnh Món Ăn, Logo...
 */
var UIFileUpload = (function () {

  /**
   * Sinh vùng Dropzone
   * @param {Object} config - { id, text, hint, accept, onChange }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-file-upload';

    var input = document.createElement('input');
    input.type = 'file';
    if (config.id) input.id = config.id;
    if (config.accept) input.accept = config.accept;

    var icon = document.createElement('span');
    icon.className = 'material-symbols-outlined ui-upload-icon';
    icon.innerText = 'cloud_upload';

    var text = document.createElement('div');
    text.className = 'ui-upload-text';
    text.innerText = config.text || 'Kéo thả file hoặc Click để tải lên';

    var hint = document.createElement('div');
    hint.className = 'ui-upload-hint';
    hint.innerText = config.hint || 'Hỗ trợ: JPG, PNG... Tối đa 5MB';

    wrapper.appendChild(input);
    wrapper.appendChild(icon);
    wrapper.appendChild(text);
    wrapper.appendChild(hint);

    // Xử lý sự kiện Drag & Drop css ảo diệu
    wrapper.addEventListener('dragover', function(e) {
      wrapper.classList.add('dragover');
    });

    wrapper.addEventListener('dragleave', function(e) {
      wrapper.classList.remove('dragover');
    });

    wrapper.addEventListener('drop', function(e) {
      wrapper.classList.remove('dragover');
    });

    if (typeof config.onChange === 'function') {
      input.addEventListener('change', function(e) {
        if (e.target.files && e.target.files.length > 0) {
          config.onChange(e.target.files[0]);
        }
      });
    }

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- ContextMenu.js --- */
/**
 * Context Menu Component
 * Bắt sự kiện Click Chuột Phải -> Hiện Menu thả xuống tùy chỉnh (Ví dụ: Tick/Bỏ Tick dòng, Đổi trạng thái)
 */
var UIContextMenu = (function () {
  
  var currentMenu = null;

  /**
   * Khởi tạo Menu 
   * @param {Event} e - Sự kiện chuột phải (Dùng để lấy toạ độ X, Y)
   * @param {Array} items - [{ label, icon, onClick }, '|' ]
   */
  function show(e, items) {
    e.preventDefault();
    hide();

    var menu = document.createElement('div');
    menu.className = 'ui-context-menu';
    
    // Position
    menu.style.top = e.pageY + 'px';
    menu.style.left = e.pageX + 'px';

    items.forEach(function(item) {
      if (item === '|') {
        var div = document.createElement('div');
        div.className = 'context-menu-divider';
        menu.appendChild(div);
      } else {
        var btn = document.createElement('div');
        btn.className = 'context-menu-item';
        
        var iconHtml = item.icon ? '<span class="material-symbols-outlined">' + item.icon + '</span>' : '';
        btn.innerHTML = iconHtml + '<span>' + item.label + '</span>';
        
        btn.onclick = function() {
          hide();
          if (typeof item.onClick === 'function') item.onClick();
        };

        menu.appendChild(btn);
      }
    });

    document.body.appendChild(menu);
    currentMenu = menu;

    // Nghe sự kiện click ngoài -> Đóng menu
    document.addEventListener('click', hideOnOutsideClick);
  }

  function hide() {
    if (currentMenu) {
      currentMenu.remove();
      currentMenu = null;
    }
  }

  function hideOnOutsideClick(e) {
    if (currentMenu && !currentMenu.contains(e.target)) {
      hide();
      document.removeEventListener('click', hideOnOutsideClick);
    }
  }

  return {
    show: show,
    hide: hide
  };
})();


/* --- Accordion.js --- */
/**
 * Accordion Component (Mở rộng / Thu gọn)
 * Áp dụng cho các Form quá dài cần gom nhóm lại
 */
var UIAccordion = (function () {

  /**
   * Tạo khối thu gọn Accordion
   * @param {Object} config - { title, content (Node/String), isOpen }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-accordion';
    if (config.isOpen) wrapper.classList.add('open');

    var header = document.createElement('div');
    header.className = 'ui-accordion-header';

    var titleSpan = document.createElement('span');
    titleSpan.innerText = config.title;

    var iconSpan = document.createElement('span');
    iconSpan.className = 'material-symbols-outlined ui-accordion-icon';
    iconSpan.innerText = 'keyboard_arrow_down';

    header.appendChild(titleSpan);
    header.appendChild(iconSpan);

    var body = document.createElement('div');
    body.className = 'ui-accordion-body';

    if (typeof config.content === 'string') {
      body.innerHTML = config.content;
    } else if (config.content instanceof Node) {
      body.appendChild(config.content);
    }

    wrapper.appendChild(header);
    wrapper.appendChild(body);

    header.addEventListener('click', function() {
      wrapper.classList.toggle('open');
    });

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- TreeView.js --- */
/**
 * TreeView Component
 * Hiển thị dạng hình cây thư mục (Dùng cho Phân Quyền, Danh mục nhóm)
 */
var UITreeView = (function () {

  /**
   * Đệ quy build node
   */
  function buildNodes(nodes) {
    var ul = document.createElement('ul');

    nodes.forEach(function(node) {
      var li = document.createElement('li');
      
      var nodeWrapper = document.createElement('div');
      nodeWrapper.className = 'ui-tree-node';

      var toggle = document.createElement('span');
      toggle.className = 'material-symbols-outlined ui-tree-toggle';
      if (node.children && node.children.length > 0) {
        toggle.innerText = 'chevron_right';
      } else {
        toggle.classList.add('empty');
      }

      var icon = document.createElement('span');
      icon.className = 'material-symbols-outlined ui-tree-icon';
      icon.innerText = node.icon || (node.children ? 'folder' : 'draft');

      var text = document.createElement('span');
      text.innerText = node.label;

      nodeWrapper.appendChild(toggle);
      nodeWrapper.appendChild(icon);
      nodeWrapper.appendChild(text);
      li.appendChild(nodeWrapper);

      if (node.children && node.children.length > 0) {
        var childUl = buildNodes(node.children);
        li.appendChild(childUl);

        // Click to toggle
        nodeWrapper.addEventListener('click', function() {
          childUl.classList.toggle('open');
          toggle.innerText = childUl.classList.contains('open') ? 'expand_more' : 'chevron_right';
          icon.innerText = childUl.classList.contains('open') ? 'folder_open' : 'folder';
        });
      }

      ul.appendChild(li);
    });

    return ul;
  }

  /**
   * Tạo Tree
   * @param {Array} data - Data dạng Node: [{ label, icon, children: [...] }]
   */
  function create(data) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-tree';
    
    var rootUl = buildNodes(data);
    rootUl.style.display = 'block'; // Root luôn mở
    rootUl.style.paddingLeft = '0'; // Xoá padding thừa của root
    wrapper.appendChild(rootUl);

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Calendar.js --- */
/**
 * Calendar Component
 * Sinh Lịch Tiệc cơ bản bằng JS. Không dùng thư viện nặng.
 */
var UICalendar = (function () {

  /**
   * Khởi tạo Lịch
   * @param {Object} config - { year, month, events (danh sách chấm đỏ/xanh) }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-calendar-wrapper';

    // Header
    var header = document.createElement('div');
    header.className = 'calendar-header';
    var title = document.createElement('div');
    title.className = 'calendar-month';
    title.innerText = 'Tháng ' + (config.month + 1) + ' / ' + config.year;
    
    var controls = UIButton.createBar([
      { icon: 'chevron_left', tooltip: 'Tháng trước' },
      { text: 'Hôm nay' },
      { icon: 'chevron_right', tooltip: 'Tháng sau' }
    ]);

    header.appendChild(title);
    header.appendChild(controls);
    wrapper.appendChild(header);

    // Days Header
    var grid = document.createElement('div');
    grid.className = 'calendar-grid';

    ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].forEach(function(d) {
      var dDiv = document.createElement('div');
      dDiv.className = 'calendar-day-header';
      dDiv.innerText = d;
      grid.appendChild(dDiv);
    });

    // Date calculations
    var firstDay = new Date(config.year, config.month, 1).getDay();
    var daysInMonth = new Date(config.year, config.month + 1, 0).getDate();
    var today = new Date();

    // 빈 ô trước ngày 1
    for (let i = 0; i < firstDay; i++) {
      var empty = document.createElement('div');
      grid.appendChild(empty);
    }

    // Các ngày
    for (let i = 1; i <= daysInMonth; i++) {
      var dayCell = document.createElement('div');
      dayCell.className = 'calendar-day';
      if (today.getFullYear() === config.year && today.getMonth() === config.month && today.getDate() === i) {
        dayCell.classList.add('today');
      }

      var dayNum = document.createElement('div');
      dayNum.className = 'calendar-day-number';
      dayNum.innerText = i;
      dayCell.appendChild(dayNum);

      // Thêm events giả lập
      var evtDiv = document.createElement('div');
      evtDiv.className = 'calendar-events';
      if (config.events && config.events[i]) {
        config.events[i].forEach(function(evType) {
           var dot = document.createElement('div');
           dot.className = 'calendar-dot ' + evType;
           evtDiv.appendChild(dot);
        });
      }
      dayCell.appendChild(evtDiv);

      grid.appendChild(dayCell);
    }

    wrapper.appendChild(grid);
    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Slider.js --- */
/**
 * Slider Component
 * Thanh kéo trượt chọn giá trị (Ví dụ: Khoảng giá, Phần trăm giảm giá)
 */
var UISlider = (function () {

  /**
   * Sinh thanh Slider
   * @param {Object} config - { min, max, value, step, onChange, formatValue }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'ui-slider-container';

    var slider = document.createElement('input');
    slider.type = 'range';
    slider.className = 'ui-slider';
    slider.min = config.min || 0;
    slider.max = config.max || 100;
    slider.step = config.step || 1;
    slider.value = config.value || 0;

    var valDisplay = document.createElement('div');
    valDisplay.className = 'ui-slider-value';
    
    function updateDisplay(val) {
      if (typeof config.formatValue === 'function') {
        valDisplay.innerText = config.formatValue(val);
      } else {
        valDisplay.innerText = val;
      }
    }
    updateDisplay(slider.value);

    wrapper.appendChild(slider);
    wrapper.appendChild(valDisplay);

    slider.addEventListener('input', function(e) {
      updateDisplay(e.target.value);
    });

    if (typeof config.onChange === 'function') {
      slider.addEventListener('change', function(e) {
        config.onChange(e.target.value);
      });
    }

    return wrapper;
  }

  return {
    create: create
  };
})();


/* --- Toast.js --- */
/**
 * Toast Component
 * Khác với Alert (Gây gián đoạn), Toast hiện lên lặng lẽ ở góc và tự biến mất sau 3s
 */
var UIToast = (function () {

  // Auto-init container
  var container = null;
  document.addEventListener('DOMContentLoaded', function() {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  });

  /**
   * Gọi thông báo
   * @param {string} msg - Nội dung thông báo
   * @param {string} type - 'success', 'error', 'warning', 'info'
   */
  function show(msg, type) {
    if (!container) return; // Fallback

    var toast = document.createElement('div');
    toast.className = 'ui-toast ' + (type || 'success');

    var iconMap = {
      'success': 'check_circle',
      'error': 'error',
      'warning': 'warning',
      'info': 'info'
    };

    var icon = document.createElement('span');
    icon.className = 'material-symbols-outlined ui-toast-icon';
    icon.innerText = iconMap[type || 'success'] || 'info';

    var txt = document.createElement('div');
    txt.className = 'ui-toast-content';
    txt.innerText = msg;

    toast.appendChild(icon);
    toast.appendChild(txt);
    container.appendChild(toast);

    // Trigger animate in
    requestAnimationFrame(function() {
      toast.classList.add('show');
    });

    // Tự động tắt sau 3 giây
    setTimeout(function() {
      toast.classList.remove('show');
      // Đợi animation chạy xong rồi xóa node
      setTimeout(function() {
        if (toast.parentNode) toast.remove();
      }, 300);
    }, 3000);
  }

  return {
    show: show
  };
})();


/* --- Popover.js --- */
/**
 * Popover Component
 * Một khung form nổi lên nhỏ gọn nằm cạnh Nút được bấm (Ví dụ: Form nhập nhanh số lượng)
 */
var UIPopover = (function () {
  
  var currentPopover = null;

  /**
   * Mở popover ngay dưới 1 trigger element
   * @param {Node} triggerNode - DOM Node vừa được click (hoặc hover)
   * @param {Object} config - { title, content (Node) }
   */
  function show(triggerNode, config) {
    hide(); // Đóng popover cũ nếu có

    var popover = document.createElement('div');
    popover.className = 'ui-popover';

    if (config.title) {
      var header = document.createElement('div');
      header.className = 'ui-popover-header';
      header.innerText = config.title;
      popover.appendChild(header);
    }

    var body = document.createElement('div');
    body.className = 'ui-popover-body';
    if (config.content instanceof Node) {
      body.appendChild(config.content);
    } else if (typeof config.content === 'string') {
      body.innerHTML = config.content;
    }
    popover.appendChild(body);

    document.body.appendChild(popover);

    // Tính toán position
    var rect = triggerNode.getBoundingClientRect();
    popover.style.top = (rect.bottom + window.scrollY + 8) + 'px';
    // Căn giữa theo trigger
    var pWidth = popover.offsetWidth || 250;
    var left = rect.left + window.scrollX + (rect.width / 2) - (pWidth / 2);
    // Tránh tràn viền
    if (left < 10) left = 10;
    if (left + pWidth > window.innerWidth - 10) left = window.innerWidth - pWidth - 10;
    
    popover.style.left = left + 'px';

    // Show animation
    requestAnimationFrame(function() {
      popover.classList.add('show');
    });

    currentPopover = popover;

    // Click outside to hide
    setTimeout(function() { // Delay xíu để không bắt nhầm sự kiện click hiện tại
      document.addEventListener('click', hideOnOutsideClick);
    }, 10);
  }

  function hide() {
    if (currentPopover) {
      currentPopover.remove();
      currentPopover = null;
    }
  }

  function hideOnOutsideClick(e) {
    if (currentPopover && !currentPopover.contains(e.target)) {
      hide();
      document.removeEventListener('click', hideOnOutsideClick);
    }
  }

  return {
    show: show,
    hide: hide
  };
})();


/* --- Header.js --- */
/**
 * Header Component
 * Cấu trúc thanh Header trên cùng
 */
var Header = (function () {
  
  function render(containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;

    var html = `
      <header class="app-header">
        <div class="header-left">
          <!-- Nút Hamburger Mở Sidebar (Chỉ hiện trên Mobile) -->
          <button class="btn-hamburger" id="btn-hamburger">
            <span class="material-symbols-outlined">menu</span>
          </button>

          <!-- Thanh tìm kiếm kiểu Tailadmin -->
          <div class="search-box">
            <span class="material-symbols-outlined">search</span>
            <input type="text" placeholder="Type to search...">
          </div>
        </div>

        <div class="header-right">
          <!-- Các nút Notification / Chat -->
          <div class="icon-btn" onclick="Alert.info('Thông báo', 'Bạn không có thông báo mới')">
            <span class="material-symbols-outlined" style="font-size:20px;">notifications</span>
            <span class="badge"></span>
          </div>


          <!-- Thông tin User -->
          <div class="user-profile">
            <div class="user-text">
              <div class="user-name">Admin</div>
              <div class="user-role">Quản trị hệ thống</div>
            </div>
            <div class="user-avatar">
              <img src="https://ui-avatars.com/api/?name=Admin&background=3C50E0&color=fff" alt="User">
            </div>
            <span class="material-symbols-outlined" style="color:var(--color-text-secondary)">expand_more</span>
          </div>
        </div>
      </header>
    `;

    container.innerHTML = html;

    _attachEvents();
  }

  function _attachEvents() {
    var $btnHamburger = document.getElementById('btn-hamburger');
    var $sidebar = document.getElementById('app-sidebar');
    var $sidebarOverlay = document.getElementById('sidebar-overlay');

    if ($btnHamburger) {
      $btnHamburger.addEventListener('click', function() {
        if ($sidebar) $sidebar.classList.add('open');
        if ($sidebarOverlay) $sidebarOverlay.classList.add('active');
      });
    }
  }

  return {
    render: render
  };
})();


/* --- Sidebar.js --- */
/**
 * Sidebar Component
 * Cấu trúc thanh điều hướng bên trái
 */
var Sidebar = (function () {
  
  function render(containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;

    var html = `
      <aside class="app-sidebar" id="app-sidebar">
        <div class="sidebar-header">
          <div style="display:flex; align-items:center;">
            <span class="material-symbols-outlined"
              style="margin-right:12px; font-size:32px; color:var(--color-primary)">diamond</span>
            Quản lí tiệc cưới
          </div>
          <!-- Nút đóng Sidebar trên Mobile -->
          <button class="btn-close-sidebar" id="btn-close-sidebar">
            <span class="material-symbols-outlined">arrow_back</span>
          </button>
        </div>

        <nav class="sidebar-nav" id="sidebar-nav">
          <!-- Nhóm Hệ thống -->
          <div class="nav-group-title">Hệ Thống</div>
          <a href="#/dashboard" class="nav-item">
            <span class="material-symbols-outlined icon">dashboard</span>
            Tổng quan
          </a>
          <a href="#/users" class="nav-item">
            <span class="material-symbols-outlined icon">group</span>
            Người dùng
          </a>
          <a href="#/permissions" class="nav-item">
            <span class="material-symbols-outlined icon">admin_panel_settings</span>
            Phân quyền
          </a>
          <a href="#/settings" class="nav-item">
            <span class="material-symbols-outlined icon">settings_applications</span>
            Thiết lập chung
          </a>

          <!-- Nhóm Quản lý tiệc -->
          <div class="nav-group-title">Quản lý tiệc</div>
          <a href="#/customers" class="nav-item">
            <span class="material-symbols-outlined icon">manage_accounts</span>
            Hồ sơ khách hàng
          </a>
          <a href="#/calendar" class="nav-item">
            <span class="material-symbols-outlined icon">calendar_month</span>
            Lịch tiệc
          </a>
          <a href="#/hall-status" class="nav-item">
            <span class="material-symbols-outlined icon">meeting_room</span>
            Trạng thái sảnh
          </a>
          <a href="#/visitor" class="nav-item">
            <span class="material-symbols-outlined icon">hail</span>
            Khách tham quan
          </a>
          <a href="#/booking" class="nav-item">
            <span class="material-symbols-outlined icon">edit_document</span>
            Biên nhận cọc
          </a>
          <a href="#/contract" class="nav-item">
            <span class="material-symbols-outlined icon">contract</span>
            Hợp đồng tiệc
          </a>
          <a href="#/checkout" class="nav-item">
            <span class="material-symbols-outlined icon">receipt_long</span>
            Quyết toán
          </a>

          <!-- Nhóm Nhân sự -->
          <div class="nav-group-title">Nhân sự</div>
          <a href="#/staff" class="nav-item">
            <span class="material-symbols-outlined icon">badge</span>
            Nhân viên phục vụ
          </a>

          <!-- Nhóm Danh mục -->
          <div class="nav-group-title">Danh mục</div>
          <a href="#/categories" class="nav-item">
            <span class="material-symbols-outlined icon">category</span>
            Quản lý Danh mục
          </a>

          <!-- Nhóm Báo cáo -->
          <div class="nav-group-title">Báo cáo</div>
          <a href="#/report-revenue" class="nav-item">
            <span class="material-symbols-outlined icon">bar_chart</span>
            Doanh thu tiệc
          </a>
          <a href="#/report-cost" class="nav-item">
            <span class="material-symbols-outlined icon">price_change</span>
            Chi phí tiệc
          </a>
          <a href="#/report-other" class="nav-item">
            <span class="material-symbols-outlined icon">assessment</span>
            Báo cáo khác
          </a>

          <!-- System UI Components -->
          <div class="nav-group-title">UI Components</div>
          <a href="#/components-demo" class="nav-item">
            <span class="material-symbols-outlined icon">integration_instructions</span>
            Bản test Component
          </a>
        </nav>
      </aside>

      <!-- Overlay mờ khi mở Sidebar trên Mobile -->
      <div class="sidebar-overlay" id="sidebar-overlay"></div>
    `;

    container.innerHTML = html;

    _attachEvents();
  }

  function _attachEvents() {
    var $sidebar = document.getElementById('app-sidebar');
    var $btnCloseSidebar = document.getElementById('btn-close-sidebar');
    var $sidebarOverlay = document.getElementById('sidebar-overlay');

    function closeSidebar() {
      if ($sidebar) $sidebar.classList.remove('open');
      if ($sidebarOverlay) $sidebarOverlay.classList.remove('active');
    }

    if ($btnCloseSidebar) {
      $btnCloseSidebar.addEventListener('click', closeSidebar);
    }
    
    if ($sidebarOverlay) {
      $sidebarOverlay.addEventListener('click', closeSidebar);
    }

    // Auto highlight active nav item based on hash
    _highlightActiveNav();
    window.addEventListener('hashchange', _highlightActiveNav);
  }

  function _highlightActiveNav() {
    var currentHash = window.location.hash || '#/dashboard';
    var navItems = document.querySelectorAll('.sidebar-nav .nav-item');
    
    navItems.forEach(function(item) {
      item.classList.remove('active');
      if (item.getAttribute('href') === currentHash) {
        item.classList.add('active');
      }
    });
  }

  return {
    render: render
  };
})();


/* --- SearchDropdown.js --- */
/**
 * Search Dropdown Component
 * Autocomplete / Custom search results list with input and search button
 */
var UIControls = window.UIControls || {};

UIControls.createSearchDropdown = function (options) {
  var wrapper = document.createElement('div');
  wrapper.className = 'ui-search-dropdown-wrapper d-flex gap-2 align-items-center';
  wrapper.style.position = 'relative';
  wrapper.style.zIndex = '100'; // To avoid overlap issues in cards
  if (options.width) wrapper.style.width = options.width;

  var input = document.createElement('input');
  input.type = 'text';
  input.className = 'ui-input flex-grow-1';
  input.placeholder = options.placeholder || 'Tìm kiếm...';
  input.style.height = '32px';
  input.style.fontSize = '13px';

  var btn = document.createElement('button');
  btn.className = 'btn btn-outline-primary d-flex align-items-center gap-1';
  btn.style.height = '32px';
  btn.style.padding = '0 12px';
  btn.style.fontSize = '13px';
  btn.innerHTML = '<span class="material-symbols-outlined" style="font-size: 16px;">search</span>' + (options.btnText || 'Tìm');

  var dropdown = document.createElement('div');
  dropdown.className = 'ui-search-dropdown-menu';
  
  wrapper.appendChild(input);
  wrapper.appendChild(btn);
  wrapper.appendChild(dropdown);

  function showDropdown() {
    dropdown.classList.add('show');
  }

  function hideDropdown() {
    dropdown.classList.remove('show');
  }

  function renderResults(results) {
    dropdown.innerHTML = '';
    if (!results || results.length === 0) {
      dropdown.innerHTML = '<div class="p-3 text-center text-secondary">Không tìm thấy kết quả!</div>';
    } else {
      results.forEach(function (item) {
        var div = document.createElement('a');
        div.className = 'ui-search-dropdown-item border-bottom';
        div.style.cursor = 'pointer';
        div.innerHTML = options.renderItem ? options.renderItem(item) : item.toString();
        div.addEventListener('click', function () {
          hideDropdown();
          if (typeof options.onSelect === 'function') {
            options.onSelect(item);
          }
        });
        dropdown.appendChild(div);
      });
    }
    showDropdown();
  }

  btn.addEventListener('click', function (e) {
    e.preventDefault();
    var keyword = input.value.trim();
    if (!keyword && options.requireKeyword) {
      if (window.UIToast) UIToast.show('Vui lòng nhập từ khóa', 'warning');
      return;
    }
    dropdown.innerHTML = '<div class="p-3 text-center text-secondary">Đang tìm kiếm...</div>';
    showDropdown();
    
    if (typeof options.onSearch === 'function') {
      options.onSearch(keyword, renderResults, hideDropdown);
    }
  });

  input.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      btn.click();
    }
  });

  document.addEventListener('click', function (e) {
    if (!wrapper.contains(e.target)) hideDropdown();
  });

  return wrapper;
};


/* --- SidePanel.js --- */
/**
 * SidePanel Component (Right Drawer)
 * Automatically handles overlays, sliding animations, and shadow-safe hiding.
 */
var UISidePanel = (function () {
  function SidePanel(selectorOrElement) {
    this.panel = typeof selectorOrElement === 'string' 
      ? document.querySelector(selectorOrElement) 
      : selectorOrElement;
      
    if (!this.panel) return;

    this.panel.classList.add('ui-side-panel');
    
    // Ensure initial state is off-screen and display:none
    this.panel.style.display = 'none';
    this.panel.style.right = '-1000px';

    // Automatically find or create an overlay
    this.overlay = document.querySelector('.ui-side-panel-overlay');
    if (!this.overlay) {
      this.overlay = document.createElement('div');
      this.overlay.className = 'ui-side-panel-overlay';
      document.body.appendChild(this.overlay);
    }

    var self = this;
    
    // Bind close buttons
    var closeBtns = this.panel.querySelectorAll('[data-dismiss="side-panel"]');
    closeBtns.forEach(function(btn) {
      btn.addEventListener('click', function(e) {
        e.preventDefault();
        self.hide();
      });
    });

    this.overlay.addEventListener('click', function() {
      self.hide();
    });
  }

  SidePanel.prototype.show = function() {
    var self = this;
    this.panel.style.display = 'flex';
    this.overlay.classList.add('show');
    // Tiny delay to allow display:flex to register before animation
    setTimeout(function() {
      self.panel.classList.add('show');
    }, 10);
  };

  SidePanel.prototype.hide = function() {
    var self = this;
    this.overlay.classList.remove('show');
    this.panel.classList.remove('show');
    // Wait for transition to finish before display:none
    setTimeout(function() {
      if (!self.panel.classList.contains('show')) {
        self.panel.style.display = 'none';
        self.panel.style.right = '-1000px';
      }
    }, 300);
  };

  return SidePanel;
})();


