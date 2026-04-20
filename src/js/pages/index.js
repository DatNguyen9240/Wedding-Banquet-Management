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

  // 3. Xử lý UI Sidebar Responsive
  var $sidebar = document.getElementById('app-sidebar');
  var $btnHamburger = document.getElementById('btn-hamburger');
  var $btnCloseSidebar = document.getElementById('btn-close-sidebar');
  var $sidebarOverlay = document.getElementById('sidebar-overlay');

  function openSidebar() {
    if ($sidebar) $sidebar.classList.add('open');
    if ($sidebarOverlay) $sidebarOverlay.classList.add('active');
  }

  function closeSidebar() {
    if ($sidebar) $sidebar.classList.remove('open');
    if ($sidebarOverlay) $sidebarOverlay.classList.remove('active');
  }

  if ($btnHamburger) {
    $btnHamburger.addEventListener('click', openSidebar);
  }

  if ($btnCloseSidebar) {
    $btnCloseSidebar.addEventListener('click', closeSidebar);
  }
  
  if ($sidebarOverlay) {
    $sidebarOverlay.addEventListener('click', closeSidebar);
  }

  // Tự động đóng sidebar khi chuyển trang trên Mobile
  window.addEventListener('hashchange', function() {
    if (window.innerWidth <= 1024) {
      closeSidebar();
    }
  });
});
