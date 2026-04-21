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
          <a href="#/menu-items" class="nav-item">
            <span class="material-symbols-outlined icon">restaurant_menu</span>
            Hàng hóa / Món ăn
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
