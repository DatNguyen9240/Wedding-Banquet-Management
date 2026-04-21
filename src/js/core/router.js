/**
 * Router — Quản lý Hash Routing kiểu SPA
 */
var Router = (function () {
  var $content = document.getElementById('app-content');
  var $pageTitle = document.getElementById('page-title');

  // Cấu hình các Route mô phỏng
  var routes = {
    '/dashboard':      { title: 'Tổng quan', module: 'QuanTriHeThong' },
    '/users':          { title: 'Danh sách người dùng', module: 'QuanTriHeThong' },
    '/permissions':    { title: 'Phân quyền Cán bộ', module: 'QuanTriHeThong' },
    '/settings':       { title: 'Thiết lập chung', module: 'QuanTriHeThong' },
    // Quản lý tiệc
    '/customers':      { title: 'Hồ sơ Khách hàng', module: 'HopDong' },
    '/calendar':       { title: 'Lịch tiệc trong tháng', module: 'HopDong' },
    '/hall-status':    { title: 'Trạng thái Sảnh Tiệc', module: 'HopDong' },
    '/visitor':        { title: 'Khách tham quan', module: 'HopDong' },
    '/booking':        { title: 'Biên nhận cọc chỗ', module: 'HopDong' },
    '/contract':       { title: 'Hợp đồng tiệc', module: 'HopDong' },
    '/checkout':       { title: 'Quyết toán', module: 'QuyetToan' },
    // Nhân sự
    '/staff':          { title: 'Nhân viên Phục vụ Tiệc', module: 'NhanSu' },
    // Danh mục
    '/categories':     { title: 'Quản lý Danh mục', module: 'DanhMuc' },
    // Báo cáo
    '/report-revenue': { title: 'Báo cáo Doanh thu Tiệc', module: 'BaoCao' },
    '/report-cost':    { title: 'Báo cáo Chi phí Tiệc', module: 'BaoCao' },
    '/report-other':   { title: 'Báo cáo Quản lý Khác', module: 'BaoCao' },
    '/components-demo':{ title: 'Bản test Component', module: 'QuanTriHeThong' }
  };

  function init() {
    window.addEventListener('hashchange', _handleRoute);
    // Nếu mới vào chưa có hash thì đẩy về dashboard
    if (!window.location.hash) {
      window.location.hash = '#/dashboard';
    } else {
      _handleRoute();
    }
  }

  function _handleRoute() {
    var hash = window.location.hash.replace('#', '') || '/dashboard';
    var route = routes[hash];

    // Cập nhật nav active (UI Menu)
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(function(el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) {
        el.classList.add('active');
      }
    });

    if (!route) {
      if ($pageTitle) $pageTitle.innerText = 'Trang không tồn tại';
      $content.innerHTML = '<div class="card"><div class="card-body">Không tìm thấy trang yêu cầu (404)</div></div>';
      return;
    }

    // Kiểm tra quyền View cơ bản
    if (!Permission.canView(route.module)) {
      if ($pageTitle) $pageTitle.innerText = 'Từ chối truy cập';
      $content.innerHTML = '<div class="card"><div class="card-body" style="color:var(--color-danger)">Bạn không có quyền xem trang này!</div></div>';
      return;
    }

    if ($pageTitle) {
      $pageTitle.innerText = route.title;
    }
    
    // Nếu là trang Tổng quan (Dashboard) thì hiển thị giao diện mẫu cực đẹp
    if (hash === '/dashboard') {
      $content.innerHTML = `
        <!-- 4 Thẻ Phân Tích Thống Kê -->
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon" style="color: var(--color-primary); background: rgba(60, 80, 224, 0.1);">
              <span class="material-symbols-outlined">payments</span>
            </div>
            <div class="stat-info">
              <h3>₫3.540M</h3>
              <p>Tổng doanh thu tháng này</p>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon" style="color: var(--color-success); background: rgba(16, 185, 129, 0.1);">
              <span class="material-symbols-outlined">contract</span>
            </div>
            <div class="stat-info">
              <h3>120</h3>
              <p>Hợp đồng đã ký</p>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon" style="color: var(--color-warning); background: rgba(245, 158, 11, 0.1);">
              <span class="material-symbols-outlined">event_seat</span>
            </div>
            <div class="stat-info">
              <h3>45</h3>
              <p>Khách đang đặt cọc</p>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon" style="color: var(--color-danger); background: rgba(239, 68, 68, 0.1);">
              <span class="material-symbols-outlined">trending_up</span>
            </div>
            <div class="stat-info">
              <h3>+14.5%</h3>
              <p>Tăng trưởng so với trước</p>
            </div>
          </div>
        </div>

        <!-- Bảng Dữ Liệu Mẫu -->
        <div class="card">
          <div class="card-header">
            <span>Tiệc Cưới Sắp Diễn Ra</span>
            <span class="material-symbols-outlined" style="cursor: pointer; color: var(--color-text-secondary);">more_vert</span>
          </div>
          <div class="card-body" style="padding: 0;">
            <div class="table-wrapper">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Khách hàng</th>
                    <th>Ngày tổ chức</th>
                    <th>Sảnh tiệc</th>
                    <th>Số bàn</th>
                    <th>Trạng thái</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>
                      <div style="font-weight: 500; color: var(--color-text);">Nguyễn Văn A - Lê Thị B</div>
                      <div style="font-size: 13px; color: var(--color-text-secondary);">0909 123 456</div>
                    </td>
                    <td>25/11/2026<br><span style="font-size: 12px; color: #8A99AF;">Nhằm 15/10 ÂL</span></td>
                    <td>Diamond Hall</td>
                    <td>45 mặn, 2 chay</td>
                    <td><span class="status-badge success">Đã ký HĐ</span></td>
                  </tr>
                  <tr>
                    <td>
                      <div style="font-weight: 500; color: var(--color-text);">Trần Hữu C - Đinh Bích D</div>
                      <div style="font-size: 13px; color: var(--color-text-secondary);">0988 765 432</div>
                    </td>
                    <td>30/11/2026<br><span style="font-size: 12px; color: #8A99AF;">Nhằm 20/10 ÂL</span></td>
                    <td>Ruby Hall</td>
                    <td>30 mặn</td>
                    <td><span class="status-badge warning">Mới cọc lần 1</span></td>
                  </tr>
                  <tr>
                    <td>
                      <div style="font-weight: 500; color: var(--color-text);">Hoàng Hữu E - Ngô F</div>
                      <div style="font-size: 13px; color: var(--color-text-secondary);">0912 345 678</div>
                    </td>
                    <td>01/12/2026<br><span style="font-size: 12px; color: #8A99AF;">Nhằm 21/10 ÂL</span></td>
                    <td>Sapphire Hall</td>
                    <td>60 mặn</td>
                    <td><span class="status-badge success">Đã ký HĐ</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      `;
    } else if (hash === '/visitor') {
      // Delegate toàn bộ UI Khách tham quan cho VisitorPage module
      if(window.VisitorPage) {
        window.VisitorPage.render($content);
      } else {
        $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module VisitorPage.</div></div>';
      }
    } else if (hash === '/components-demo') {
      if(window.ComponentsDemoPage) window.ComponentsDemoPage.render($content);
      else $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module ComponentsDemoPage.</div></div>';
    } else if (hash === '/users') {
      if(window.UsersPage) window.UsersPage.render($content);
      else $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module UsersPage.</div></div>';
    } else if (hash === '/permissions') {
      if(window.PermissionsPage) window.PermissionsPage.render($content);
      else $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module PermissionsPage.</div></div>';
    } else if (hash === '/settings') {
      if(window.SettingsPage) window.SettingsPage.render($content);
      else $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module SettingsPage.</div></div>';
    } else if (hash === '/categories') {
      if(window.CategoriesPage) window.CategoriesPage.render($content);
      else $content.innerHTML = '<div class="card"><div class="card-body">Lỗi: Không tìm thấy module CategoriesPage.</div></div>';
    } else {
      // Các trang khác tạm thời hiện raw html
      $content.innerHTML = '<div class="card"><div class="card-header">' + route.title + '</div><div class="card-body">Giao diện nội dung của trang <b>' + route.title + '</b> sẽ load ở đây...</div></div>';
    }
  }

  return { init: init };
})();
