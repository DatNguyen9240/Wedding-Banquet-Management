/**
 * Bootstraps the application layout & interactions
 */
document.addEventListener('DOMContentLoaded', function () {
  // 0. Global Auth Logic
  window.logoutApp = function() {
    // Gọi API đăng xuất (background)
    if (typeof ApiClient !== 'undefined' && window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.AUTH.LOGOUT) {
      ApiClient.post(API_CONFIG.ENDPOINTS.AUTH.LOGOUT).catch(function(){});
    }

    localStorage.removeItem('pmql_user');
    if (typeof ApiClient !== 'undefined' && ApiClient.deleteCookie) {
      ApiClient.deleteCookie('auth_token');
    }

    window.location.href = 'login.html';
  };

  // 0.5 Kiểm tra đăng nhập (Auth Guard)
  var token = typeof ApiClient !== 'undefined' && ApiClient.getCookie ? ApiClient.getCookie('auth_token') : null;
  if (!token) {
    window.location.href = 'login.html';
    return;
  }
  // 1. Khởi tạo trình quản lý phím tắt
  if (typeof KeyboardManager !== 'undefined') {
    KeyboardManager.init();
  }

  // 2. Khởi tạo Router
  if (typeof Router !== 'undefined') {
    Router.init();
  }

  // 3. Khởi tạo Navbar (chỉ render nếu đã đăng nhập)
  var currentUser = localStorage.getItem('pmql_user');
  if (currentUser && typeof Navbar !== 'undefined') {
    Navbar.render('navbar-container');

    // Nếu mode là vertical, chuyển #app-content vào vertical-main
    if (Navbar.getLayout() === 'vertical') {
      var $vertMain = document.getElementById('vertical-main');
      var $content = document.getElementById('app-content');
      if ($vertMain && $content && !$vertMain.contains($content)) {
        $vertMain.appendChild($content);
      }
    }
  }

  // 4. Khởi tạo cấu hình giao diện
  var savedFont = localStorage.getItem('pmql_font_family');
  if (savedFont) {
    document.documentElement.style.setProperty('--font-family', '"' + savedFont + '", sans-serif');
  }

  var savedTheme = localStorage.getItem('pmql_theme') || 'auto';
  if (savedTheme === 'dark' || (savedTheme === 'auto' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
    document.body.classList.add('dark-theme');
  } else {
    document.body.classList.remove('dark-theme');
  }

  // Lắng nghe sự thay đổi giao diện từ hệ thống (khi chuyển qua chế độ tiết kiệm pin hoặc Dark Mode)
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (e) {
    var currentTheme = localStorage.getItem('pmql_theme') || 'auto';
    if (currentTheme === 'auto') {
      if (e.matches) {
        document.body.classList.add('dark-theme');
      } else {
        document.body.classList.remove('dark-theme');
      }
    }
  });

  var savedColor = localStorage.getItem('pmql_color');
  if (savedColor) {
    var COLORS = [
      { id: 'indigo', primary: '#4F46E5', hover: '#4338CA', dark: '#3730A3', light: 'rgba(79, 70, 229, 0.1)' },
      { id: 'emerald', primary: '#10B981', hover: '#059669', dark: '#047857', light: 'rgba(16, 185, 129, 0.1)' },
      { id: 'rose', primary: '#E11D48', hover: '#BE123C', dark: '#9F1239', light: 'rgba(225, 29, 72, 0.1)' },
      { id: 'amber', primary: '#F59E0B', hover: '#D97706', dark: '#B45309', light: 'rgba(245, 158, 11, 0.1)' },
      { id: 'sky', primary: '#0EA5E9', hover: '#0284C7', dark: '#0369A1', light: 'rgba(14, 165, 233, 0.1)' }
    ];
    var colorDef = COLORS.find(function (c) { return c.id === savedColor; });
    if (colorDef) {
      document.documentElement.style.setProperty('--color-primary', colorDef.primary);
      document.documentElement.style.setProperty('--color-primary-hover', colorDef.hover);
      document.documentElement.style.setProperty('--color-primary-dark', colorDef.dark);
      document.documentElement.style.setProperty('--color-primary-light', colorDef.light);
    }
  }

  // 5. Khởi tạo Plugin xuất tài liệu
  if (typeof DocumentExportPlugin !== 'undefined') {
    DocumentExportPlugin.init();
  }

  // 6. Khởi tạo Plugin luồng nghiệp vụ
  if (typeof WorkflowTransferPlugin !== 'undefined') {
    WorkflowTransferPlugin.init();
  }
});
