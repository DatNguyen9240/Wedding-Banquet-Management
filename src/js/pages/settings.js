/**
 * Màn hình Thiết lập Hệ thống (Settings)
 * Bao hàm: Khai báo năm sử dụng, Thông số hệ thống, Sao lưu dữ liệu, Đổi mật khẩu
 */
var SettingsPage = (function () {

  function render($container) {
    var html = `
      <div class="page-title-bar">
        <span>Thiết lập Hệ thống</span>
      </div>
      
      <div class="card" style="animation: slideUp 0.3s ease forwards;">
        <!-- Container cho UITabs -->
        <div id="settings-tabs-container"></div>
      </div>
    `;

    $container.innerHTML = html;

    _mountTabs();
  }

  function _mountTabs() {
    var tabsContainer = document.getElementById('settings-tabs-container');
    if (!tabsContainer) return;

    var tabs = UITabs.create([
      { title: 'Thông tin Công ty', icon: 'business', content: _buildCompanyInfoTab() },
      { title: 'Kỳ Kế Toán', icon: 'calendar_month', content: _buildPeriodTab() },
      { title: 'Bảo mật & Dữ liệu', icon: 'security', content: _buildSecurityTab() }
    ]);

    tabsContainer.appendChild(tabs);

    // Xử lý FileUpload logic sau khi Tab render (có thể DOM chưa kịp mount nhưng vẫn gắn event được)
    setTimeout(_attachFileUploadLogic, 100);
  }

  function _buildCompanyInfoTab() {
    var wrapper = document.createElement('div');
    wrapper.innerHTML = `
      <div style="padding: 24px;">
        <div style="font-size: var(--font-size-lg); font-weight: 600; margin-bottom: 24px;">Thông tin Nhà hàng Quản lý Tiệc Cưới</div>
        
        <div style="display: flex; gap: 40px; flex-wrap: wrap;">
          <!-- Cột Trái: Nhập liệu cơ bản -->
          <div style="flex: 1 1 400px;">
            <div class="form-group mb-4">
              <label>Tên nhà hàng / Công ty</label>
              <input type="text" class="ui-input" value="NHÀ HÀNG TIỆC CƯỚI CÁNH HOA ĐÊM" placeholder="Nhập tên doanh nghiệp...">
            </div>
            
            <div class="form-group mb-4">
              <label>Địa chỉ</label>
              <input type="text" class="ui-input" value="123 Nguyễn Văn Cừ, Phường 4, Quận 5, TP.HCM" placeholder="Địa chỉ cơ sở...">
            </div>

            <div style="display:flex; gap: 24px; margin-bottom: 24px; flex-wrap: wrap;">
              <div class="form-group" style="flex:1">
                <label>Số điện thoại</label>
                <input type="text" class="ui-input" value="0909.123.456" placeholder="Hotline liên hệ...">
              </div>
              <div class="form-group" style="flex:1">
                <label>Quỹ tiền mặt ban đầu</label>
                <input type="text" class="ui-input" value="500,000,000" style="text-align:right" placeholder="...">
              </div>
            </div>
          </div>

          <!-- Cột Phải: Upload & Ghi chú -->
          <div style="flex: 1 1 400px;">
            <div class="form-group mb-4">
              <label>Logo Doanh Nghiệp (Dùng trên Phiếu/Hợp đồng)</label>
              <div id="logo-upload-wrapper"></div>
              <small style="color:var(--color-text-secondary); display:block; margin-top:8px;">Hệ thống sẽ lưu file thành logo.jpg trong thư mục mặc định.</small>
            </div>

            <div style="padding: 16px; background: #F8FAFC; border: 1px dashed var(--color-border-strong); border-radius: 8px;">
              <div style="font-weight: 600; margin-bottom: 8px; font-size: var(--font-size-md); color: var(--color-text);">Ghi chú hệ thống</div>
              <ul style="font-size: var(--font-size-sm); color: var(--color-text-secondary); margin: 0; padding-left: 16px; line-height: 1.6;">
                <li>Thông tin liên hệ này sẽ được in trực tiếp lên các biểu mẫu Hợp đồng & Phiếu thu.</li>
                <li>Logo nên dùng ảnh định dạng PNG nền trong suốt, kích thước tỷ lệ 1:1 tốt nhất là 400x400px.</li>
              </ul>
            </div>
          </div>
        </div>

        <div style="display:flex; gap: 12px; border-top:1px solid var(--color-border); padding-top: 16px; margin-top: 24px;">
          <button class="btn btn-primary" onclick="UIToast.show('Đã lưu thông tin doanh nghiệp.')">Cập Nhật Thông Tin</button>
        </div>
      </div>
    `;

    var uploadNode = UIFileUpload.create({
      accept: 'image/jpeg, image/png',
      onFileSelect: function(file) {
        console.log('Selected logo:', file.name);
      }
    });

    wrapper.querySelector('#logo-upload-wrapper').appendChild(uploadNode);

    return wrapper;
  }

  function _attachFileUploadLogic() {
    // Nếu cần xử lý thêm UI cập nhật ảnh preview,...
  }

  function _buildPeriodTab() {
    var wrapper = document.createElement('div');
    wrapper.innerHTML = `
      <div style="padding: 24px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; flex-wrap:wrap; gap:16px;">
          <div style="font-size: var(--font-size-lg); font-weight: 600; min-width: 200px;">Quản lý Năm Sử Dụng & Kỳ Kế Toán</div>
          <div style="display:flex; gap:12px; flex-wrap:wrap;">
            <button class="btn btn-secondary" onclick="ConfirmModal.show({ title:'Chuyển Kỳ', message:'Chuyển đổi dữ liệu sang kỳ làm việc khác (Kỳ 10/2026)?' })">
              Chuyển tới Kỳ Khác
            </button>
            <button class="btn btn-primary" onclick="UIToast.show('Đã sinh thành công dữ liệu cho Năm 2027.')">
              <span class="material-symbols-outlined" style="font-size:18px; margin-right:6px">add</span>
              Tạo Mới Năm 2027
            </button>
          </div>
        </div>

        <div style="display:flex; gap: 32px; flex-wrap: wrap;" class="settings-period-layout">
          <style>
            @media (max-width: 768px) {
              .settings-period-layout > div:first-child { border-right: none !important; border-bottom: 1px solid var(--color-border); padding-right: 0 !important; padding-bottom: 24px; margin-bottom: 8px; }
            }
            .year-item {
              padding: 10px 16px; background: #fff; border: 1px solid var(--color-border);
              color: var(--color-text); border-radius: 6px; cursor: pointer; transition: all 0.2s;
            }
            .year-item:hover { border-color: var(--color-primary); }
            .year-item.active {
              background: #F8FAFC; border: 1px solid var(--color-primary);
              color: var(--color-primary); font-weight: 600;
            }
          </style>
          <!-- Cột bên trái: Danh sách các năm -->
          <div style="flex: 1 1 250px; max-width: 100%; border-right: 1px solid var(--color-border); padding-right: 16px;">
            <label style="font-weight:600; display:block; margin-bottom:12px;">Năm Làm Việc</label>
            <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:8px">
              <li class="year-item active" onclick="SettingsPage.selectYear(this, '2026')">Năm 2026 (Hiện tại)</li>
              <li class="year-item" onclick="SettingsPage.selectYear(this, '2025')">Năm 2025</li>
              <li class="year-item" onclick="SettingsPage.selectYear(this, '2024')">Năm 2024</li>
            </ul>
          </div>
          
          <!-- Cột bên phải: 12 Kỳ -->
          <div style="flex: 999 1 400px; max-width: 100%;">
            <div style="margin-bottom:16px; display:flex; justify-content:space-between; flex-wrap:wrap; gap:8px; align-items:center;">
              <span style="font-weight:600" id="period-header-year">Tháng / Kỳ trong năm 2026</span>
              <span class="status-badge success" style="white-space:nowrap;">Kỳ hiện hành: T10/2026</span>
            </div>
            <div class="table-wrapper" style="overflow-x: auto; width: 100%; padding-bottom: 8px;">
              <table class="data-table">
                <thead>
                <tr>
                  <th>Kỳ (Tháng)</th>
                  <th>Phân Quý</th>
                  <th>Trạng Thái</th>
                  <th style="text-align:right">Khóa / Mở Kỳ (Toggles)</th>
                </tr>
              </thead>
              <tbody>
                ` + [1, 2, 3, 4, 5, 6, 7, 8, 9].map(i => `
                  <tr>
                    <td>Tháng 0${i}/2026</td>
                    <td>Quý ${Math.ceil(i/3)}</td>
                    <td><span class="status-badge warning">Đã Khóa</span></td>
                    <td style="text-align:right"><label class="ui-checkbox-container" style="display:inline-flex; width:auto; margin:0;"><input type="checkbox" checked><span class="checkmark"></span> Khóa dữ liệu</label></td>
                  </tr>
                `).join('') + `
                <tr style="background: rgba(16,185,129,0.05);">
                  <td style="font-weight:600">Tháng 10/2026</td>
                  <td style="font-weight:600">Quý 4</td>
                  <td style="font-weight:600"><span class="status-badge success">Đang Mở</span></td>
                  <td style="text-align:right"><label class="ui-checkbox-container" style="display:inline-flex; width:auto; margin:0;"><input type="checkbox" onchange="UIToast.show('Đã cập nhật trạng thái khóa kỳ')"><span class="checkmark"></span> Khóa dữ liệu</label></td>
                </tr>
                 <tr>
                  <td>Tháng 11/2026</td>
                  <td>Quý 4</td>
                  <td><span class="status-badge warning">Đã Khóa</span></td>
                  <td style="text-align:right"><label class="ui-checkbox-container" style="display:inline-flex; width:auto; margin:0;"><input type="checkbox" checked><span class="checkmark"></span> Khóa dữ liệu</label></td>
                </tr>
                 <tr>
                  <td>Tháng 12/2026</td>
                  <td>Quý 4</td>
                  <td><span class="status-badge warning">Đã Khóa</span></td>
                  <td style="text-align:right"><label class="ui-checkbox-container" style="display:inline-flex; width:auto; margin:0;"><input type="checkbox" checked><span class="checkmark"></span> Khóa dữ liệu</label></td>
                </tr>
              </tbody>
            </table>
            </div>
          </div>
        </div>
      </div>
    `;
    return wrapper;
  }

  function _buildSecurityTab() {
    var wrapper = document.createElement('div');
    wrapper.innerHTML = `
      <div style="display:flex; gap: 48px; padding: 24px; flex-wrap: wrap;">
        
        <!-- Đổi mật khẩu -->
        <div style="flex: 1 1 400px; max-width: 100%;">
          <div style="font-size: var(--font-size-lg); font-weight: 600; margin-bottom: 24px;">Đổi Mật Khẩu (Admin)</div>
          <div class="form-group mb-3">
            <label>Mật khẩu hiện tại</label>
            <input type="password" class="ui-input" placeholder="***">
          </div>
          <div class="form-group mb-3">
            <label>Mật khẩu mới</label>
            <input type="password" class="ui-input" placeholder="***">
          </div>
          <div class="form-group mb-4">
            <label>Nhập lại mật khẩu mới</label>
            <input type="password" class="ui-input" placeholder="***">
          </div>
          <button class="btn btn-primary" onclick="UIToast.show('Đã cập nhật mật khẩu mới thành công.')">Lưu Thay Đổi</button>
        </div>

        <!-- Sao lưu Dữ liệu -->
        <div style="flex: 1 1 400px; max-width: 100%;" class="settings-backup-layout">
          <style>
            @media (min-width: 769px) {
              .settings-backup-layout { padding-left: 48px; border-left: 1px solid var(--color-border); }
            }
          </style>
          <div style="font-size: var(--font-size-lg); font-weight: 600; margin-bottom: 12px; display: flex; align-items: center; gap:8px;">
            <span class="material-symbols-outlined" style="color:var(--color-primary)">cloud_download</span>
            Sao lưu Dữ liệu Hệ thống
          </div>
          <p style="font-size: 14px; color: var(--color-text-secondary); margin-bottom: 24px; line-height: 1.5;">
            Hệ thống sẽ nén toàn bộ Cơ sở dữ liệu hiện tại thành định dạng .bak hoặc .sql để tải xuống thiết bị của bạn.
            Tên file mặc định: <code style="background:#F1F5F9; padding:2px 6px; border-radius:4px;">PMQLTiec_2026_10_25_14_30.bak</code>
          </p>
          <button class="btn btn-secondary" style="width: 100%; justify-content:center; display:flex; gap:8px;" onclick="Alert.success('Backup thành công!', 'File mãnh đã được tải về máy của bạn.')">
            <span class="material-symbols-outlined">save</span>
            Tải File Sao Lưu Ngay
          </button>
        </div>

      </div>
    `;
    return wrapper;
  }

  return {
    render: render,
    selectYear: function(el, year) {
      if (!el) return;
      var items = el.parentElement.querySelectorAll('.year-item');
      items.forEach(function(item) { item.classList.remove('active'); });
      el.classList.add('active');
      UIToast.show('Đã chuyển sang xem Kỳ Kế Toán Năm ' + year);
      var headerText = document.getElementById('period-header-year');
      if (headerText) headerText.innerText = 'Tháng / Kỳ trong năm ' + year;
    }
  };
})();
