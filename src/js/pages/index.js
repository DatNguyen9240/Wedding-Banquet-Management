/**
 * Bootstraps the application layout & interactions
 */
document.addEventListener('DOMContentLoaded', function () {
  // 1. Khởi tạo trình quản lý phím tắt
  if (typeof KeyboardManager !== 'undefined') {
    KeyboardManager.init();
  }

  // 2. Khởi tạo Router
  if (typeof Router !== 'undefined') {
    Router.init();
  }

  // 3. Khởi tạo UI Giao diện màng bao (App Shell)
  if (typeof Sidebar !== 'undefined') {
    Sidebar.render('sidebar-container');
  }

  if (typeof Header !== 'undefined') {
    Header.render('header-container');
  }

  // Tự động đóng sidebar khi chuyển trang trên Mobile
  window.addEventListener('hashchange', function() {
    if (window.innerWidth <= 1024) {
      closeSidebar();
    }
  });
});
