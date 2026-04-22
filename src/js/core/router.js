/**
 * Router — Hash-based SPA routing cho Quản lý Tiệc Cưới
 * ─────────────────────────────────────────────────────
 * Kiến trúc: Mảng ROUTES cấu hình → Dynamic script loading → pageFn.render()
 * Template do Page Module tự fetch (Router cung cấp cache layer)
 * Tham khảo: Medstand Router v9
 */
var Router = (function () {

  // ── Route definitions ──────────────────────────────────────────────────
  var ROUTES = [
    { path: '/dashboard',       template: 'src/pages/dashboard/dashboard.html',             script: null,                                                module: 'QuanTriHeThong', title: 'Tổng quan',               pageFn: null },
    { path: '/visitor',         template: 'src/pages/visitor/visitor.html',                 script: 'src/pages/visitor/visitor.js',                     module: 'HopDong',        title: 'Khách tham quan',         pageFn: 'VisitorPage' },
    { path: '/booking',         template: 'src/pages/booking/booking.html',                 script: 'src/pages/booking/booking.js',                     module: 'HopDong',        title: 'Biên nhận cọc chỗ',       pageFn: 'BookingPage' },
    { path: '/contract',        template: 'src/pages/contract/contract.html',               script: 'src/pages/contract/contract.js',                   module: 'HopDong',        title: 'Hợp đồng tiệc',          pageFn: 'ContractPage' },
    { path: '/checkout',        template: 'src/pages/checkout/checkout.html',               script: 'src/pages/checkout/checkout.js',                   module: 'QuyetToan',      title: 'Quyết toán',              pageFn: 'CheckoutPage' },
    { path: '/calendar',        template: 'src/pages/calendar/calendar.html',               script: 'src/pages/calendar/calendar.js',                   module: 'HopDong',        title: 'Lịch tiệc trong tháng',   pageFn: 'CalendarPage' },
    { path: '/customers',       template: null,                                              script: null,                                                module: 'HopDong',        title: 'Hồ sơ Khách hàng',        pageFn: null },
    { path: '/hall-status',     template: null,                                              script: null,                                                module: 'HopDong',        title: 'Trạng thái Sảnh Tiệc',    pageFn: null },
    { path: '/users',           template: 'src/pages/users/users.html',                     script: 'src/pages/users/users.js',                         module: 'QuanTriHeThong', title: 'Danh sách người dùng',    pageFn: 'UsersPage' },
    { path: '/permissions',     template: 'src/pages/permissions/permissions.html',         script: 'src/pages/permissions/permissions.js',             module: 'QuanTriHeThong', title: 'Phân quyền Cán bộ',       pageFn: 'PermissionsPage' },
    { path: '/settings',        template: 'src/pages/settings/settings.html',               script: 'src/pages/settings/settings.js',                   module: 'QuanTriHeThong', title: 'Thiết lập chung',         pageFn: 'SettingsPage' },
    { path: '/appearance',      template: 'src/pages/appearance/appearance.html',           script: 'src/pages/appearance/appearance.js',               module: 'QuanTriHeThong', title: 'Cài đặt Giao diện',       pageFn: 'AppearancePage' },
    { path: '/categories',      template: 'src/pages/categories/categories.html',           script: 'src/pages/categories/categories.js',               module: 'DanhMuc',        title: 'Quản lý Danh mục',        pageFn: 'CategoriesPage' },
    { path: '/staff',           template: null,                                              script: null,                                                module: 'NhanSu',         title: 'Nhân viên Phục vụ Tiệc',  pageFn: null },
    { path: '/report-revenue',  template: 'src/pages/report-revenue/report-revenue.html',   script: 'src/pages/report-revenue/report-revenue.js',       module: 'BaoCao',         title: 'Báo cáo Doanh thu Tiệc',  pageFn: 'ReportRevenuePage' },
    { path: '/report-cost',     template: 'src/pages/report-cost/report-cost.html',         script: 'src/pages/report-cost/report-cost.js',             module: 'BaoCao',         title: 'Báo cáo Chi phí Tiệc',    pageFn: 'ReportCostPage' },
    { path: '/report-other',    template: 'src/pages/report-other/report-other.html',       script: 'src/pages/report-other/report-other.js',           module: 'BaoCao',         title: 'Báo cáo Quản lý Khác',    pageFn: 'ReportOtherPage' },
    { path: '/components-demo', template: 'src/pages/components-demo/components-demo.html', script: 'src/pages/components-demo/components-demo.js',     module: 'QuanTriHeThong', title: 'Bản test Component',       pageFn: 'ComponentsDemoPage' }
  ];

  // ── State ──────────────────────────────────────────────────────────────
  var _currentRoute = null;
  var _loadedScripts = {};
  var _templateCache = {};
  var _appVersion = '1.0';
  var _isNavigating = false;    // Guard chống double-navigate

  // ── Template cache (dùng chung cho cả Router lẫn Page modules) ─────────
  function fetchTemplate(url) {
    if (_templateCache[url]) return Promise.resolve(_templateCache[url]);
    return fetch(url + '?v=' + _appVersion)
      .then(function (res) {
        if (!res.ok) throw new Error('Template not found: ' + url);
        return res.text();
      })
      .then(function (html) {
        _templateCache[url] = html;
        return html;
      });
  }

  // ── Preload templates phổ biến (tải trước nền) ─────────────────────────
  function _preloadTemplates() {
    var priority = ['/dashboard', '/visitor', '/booking'];
    priority.forEach(function (p) {
      var r = _findRoute(p);
      if (r && r.template) fetchTemplate(r.template).catch(function () { });
    });
  }

  // ── Dynamic Script Loading ─────────────────────────────────────────────
  function _loadScript(src) {
    return new Promise(function (resolve, reject) {
      if (_loadedScripts[src]) { resolve(); return; }
      var el = document.createElement('script');
      el.src = src + '?v=' + _appVersion;
      el.onload = function () { _loadedScripts[src] = true; resolve(); };
      el.onerror = function () { reject(new Error('Script load failed: ' + src)); };
      document.body.appendChild(el);
    });
  }

  // ── Route matching (dùng Map nội bộ cho O(1) lookup) ───────────────────
  var _routeMap = {};
  ROUTES.forEach(function (r) { _routeMap[r.path] = r; });

  function _findRoute(path) {
    return _routeMap[path] || null;
  }

  // ── Page Transition ────────────────────────────────────────────────────
  function _fadeOut($el) {
    return new Promise(function (resolve) {
      $el.style.opacity = '0';
      $el.style.transition = 'opacity 120ms ease';
      setTimeout(resolve, 120);
    });
  }

  function _fadeIn($el) {
    $el.style.opacity = '1';
    $el.style.transition = 'opacity 180ms ease';
  }

  // ── Trang lỗi ──────────────────────────────────────────────────────────
  function _render404($el, path) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:50vh;text-align:center;padding:48px 24px;">' +
        '<span class="material-symbols-outlined" style="font-size:72px;color:var(--color-border-strong);margin-bottom:16px;">search_off</span>' +
        '<h2 style="font-size:2rem;font-weight:700;margin:0 0 8px;">404</h2>' +
        '<p style="color:var(--color-text-secondary);margin:0 0 24px;">Trang <code style="background:#F1F5F9;padding:2px 8px;border-radius:4px;">' + path + '</code> không tồn tại</p>' +
        '<a href="#/dashboard" class="btn btn-primary" style="text-decoration:none;">Về trang chủ</a>' +
      '</div>';
  }

  function _renderAccessDenied($el) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:40vh;text-align:center;padding:48px;">' +
        '<span class="material-symbols-outlined" style="font-size:64px;color:var(--color-danger);opacity:0.4;margin-bottom:16px;">lock</span>' +
        '<p style="color:var(--color-danger);font-weight:600;">Bạn không có quyền xem trang này</p>' +
      '</div>';
  }

  function _renderPlaceholder($el, title) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:40vh;text-align:center;padding:48px;">' +
        '<span class="material-symbols-outlined" style="font-size:64px;color:var(--color-border-strong);opacity:0.4;margin-bottom:16px;">construction</span>' +
        '<h3 style="margin:0 0 8px;font-weight:600;">' + title + '</h3>' +
        '<p style="color:var(--color-text-secondary);margin:0;">Trang này đang được phát triển...</p>' +
      '</div>';
  }

  function _renderError($el, message) {
    $el.innerHTML =
      '<div class="card"><div class="card-body" style="color:var(--color-danger);">' +
        '<span class="material-symbols-outlined" style="vertical-align:middle;margin-right:8px;">error</span>' + message +
      '</div></div>';
  }

  // ── Cập nhật navigation UI ─────────────────────────────────────────────
  function _updateNavActive(hash) {
    // Sidebar nav
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
    // Navbar (nếu đang dùng layout ngang)
    document.querySelectorAll('.main-nav .nav-link, .sub-menu-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
  }

  // ── Main Route Handler ─────────────────────────────────────────────────
  function _handleRoute() {
    if (_isNavigating) return;   // Chống double-trigger
    _isNavigating = true;

    var $content = document.getElementById('app-content');
    var $pageTitle = document.getElementById('page-title');
    var hash = window.location.hash.replace('#', '') || '/dashboard';
    var route = _findRoute(hash);

    // Scroll to top
    window.scrollTo({ top: 0, behavior: 'instant' });

    // Cập nhật nav UI
    _updateNavActive(hash);

    // 404
    if (!route) {
      if ($pageTitle) $pageTitle.innerText = '404 — Không tìm thấy';
      document.title = '404 | Quản lý Tiệc Cưới';
      _render404($content, hash);
      _isNavigating = false;
      return;
    }

    // Kiểm tra quyền
    if (!Permission.canView(route.module)) {
      if ($pageTitle) $pageTitle.innerText = 'Từ chối truy cập';
      _renderAccessDenied($content);
      _isNavigating = false;
      return;
    }

    // Cập nhật title
    if ($pageTitle) $pageTitle.innerText = route.title;
    document.title = route.title + ' | Quản lý Tiệc Cưới';
    document.body.setAttribute('data-page', hash.replace('/', ''));

    // ── Trường hợp 1: Có script → load script → pageFn.render() ──
    // (Page module tự fetch template bên trong render nếu cần)
    if (route.script && route.pageFn) {
      _fadeOut($content)
        .then(function () { return _loadScript(route.script); })
        .then(function () {
          var mod = window[route.pageFn];
          if (mod && typeof mod.render === 'function') {
            mod.render($content);
          } else {
            _renderError($content, 'Không tìm thấy module: ' + route.pageFn);
          }
          _fadeIn($content);
          _currentRoute = route;
          _isNavigating = false;
        })
        .catch(function (err) {
          console.error('[Router]', err);
          _renderError($content, 'Lỗi tải module: ' + err.message);
          _fadeIn($content);
          _isNavigating = false;
        });
      return;
    }

    // ── Trường hợp 2: Chỉ có template (dashboard, trang tĩnh) ──
    if (route.template) {
      _fadeOut($content)
        .then(function () { return fetchTemplate(route.template); })
        .then(function (html) {
          $content.innerHTML = html;
          _fadeIn($content);
          _currentRoute = route;
          _isNavigating = false;
        })
        .catch(function (err) {
          console.error('[Router]', err);
          _renderError($content, 'Lỗi tải template: ' + err.message);
          _fadeIn($content);
          _isNavigating = false;
        });
      return;
    }

    // ── Trường hợp 3: Trang chưa code ──
    _renderPlaceholder($content, route.title);
    _isNavigating = false;
  }

  // ── Init ───────────────────────────────────────────────────────────────
  function init() {
    window.addEventListener('hashchange', _handleRoute);

    if (!window.location.hash) {
      window.location.hash = '#/dashboard';
    } else {
      _handleRoute();
    }

    // Preload templates phổ biến sau 500ms
    setTimeout(_preloadTemplates, 500);
  }

  // ── Public API ─────────────────────────────────────────────────────────
  return {
    init: init,
    ROUTES: ROUTES,
    fetchTemplate: fetchTemplate   // Cho page modules dùng chung cache layer
  };
})();
