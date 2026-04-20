/**
 * Module Giao diện Khách Tham Quan (Visitor Page)
 * Đảm nhiệm hiển thị Bảng danh sách và Form Nhập liệu Khách Tham Quan
 */
var VisitorPage = (function () {
  
  function render($container) {
    var html = `
      <!-- Tiêu đề & Công cụ -->
      <div class="page-title-bar" style="display: flex; justify-content: space-between; align-items: center;">
        <span>Quản Lý Khách Tham Quan</span>
        <button class="btn btn-primary" id="btn-add-visitor" style="display: flex; align-items: center; gap: 6px; padding: 10px 16px; border: none; border-radius: var(--radius-md); background: var(--color-primary); color: white; cursor: pointer; font-weight: 600;">
          <span class="material-symbols-outlined" style="font-size: 20px;">add</span>
          Thêm Khách Mới
        </button>
      </div>

      <!-- Bảng Danh sách Khách Tham Quan -->
      <div class="card mb-4" style="animation: slideUp 0.3s ease forwards;">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
          <div class="search-box" style="display: flex; border: 1px solid var(--color-border); padding: 8px 12px; border-radius: var(--radius-md);">
            <span class="material-symbols-outlined" style="color: var(--color-text-secondary); margin-right: 8px;">search</span>
            <input type="text" placeholder="Tìm tên khách hoặc SĐT..." style="border: none; outline: none; background: transparent; width: 200px;">
          </div>
          <div style="display: flex; gap: 8px;">
            <button class="icon-btn tooltip"><span class="material-symbols-outlined">filter_list</span></button>
          </div>
        </div>
        <div class="card-body" style="padding: 0;">
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Mã Phiếu</th>
                  <th>Khách Hàng</th>
                  <th>Ngày Dự Kiến</th>
                  <th>Gói & Sảnh</th>
                  <th>Trạng Thái</th>
                  <th style="text-align: right;">Thao Tác</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td style="font-weight: 600;">TQ10426/002</td>
                  <td>
                    <div style="font-weight: 500; color: var(--color-text);">Trần Văn Khoa - Lê Nhã Kỳ</div>
                    <div style="font-size: 13px; color: var(--color-text-secondary);">0982.42.33.88</div>
                  </td>
                  <td>
                    20/11/2026
                    <div style="font-size: 12px; color: var(--color-text-secondary);">Nhằm 10/10 ÂL</div>
                  </td>
                  <td>
                    <div style="font-weight: 500;">Gói Lộc Phát</div>
                    <div style="font-size: 13px; color: var(--color-text-secondary);">Diamond Hall</div>
                  </td>
                  <td><span class="status-badge warning">Đang Tư Vấn</span></td>
                  <td style="text-align: right;">
                    <button class="icon-btn btn-edit-visitor" style="display: inline-flex;"><span class="material-symbols-outlined">edit</span></button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Khung Trượt Form Thêm / Sửa (Slide-over Panel) -->
      <div id="visitor-form-overlay" class="sidebar-overlay"></div>
      <div id="visitor-form-panel" style="position: fixed; top: 0; right: -800px; width: 100%; max-width: 800px; height: 100vh; background: var(--color-surface); box-shadow: -10px 0 30px rgba(0,0,0,0.1); transition: right 0.3s ease; z-index: 10000; display: flex; flex-direction: column;">
        
        <!-- Panel Header -->
        <div style="padding: 24px; border-bottom: 1px solid var(--color-border); display: flex; justify-content: space-between; align-items: center; background: var(--color-background);">
          <h2 style="margin: 0; font-size: 20px;">Phiếu Khách Tham Quan</h2>
          <button id="btn-close-form" class="icon-btn" style="background: transparent; border: none;"><span class="material-symbols-outlined">close</span></button>
        </div>

        <!-- Panel Body (Scrollable) -->
        <div style="flex: 1; overflow-y: auto; padding: 24px;">
          
          <!-- Thẻ 1: Thông tin khách -->
          <div class="card" style="margin-bottom: 24px; box-shadow: none;">
            <div class="card-header" style="padding: 16px; background: #F8FAFC; font-size: 14px; color: var(--color-text-secondary);">1. Thông Tin Khách Hàng Gốc</div>
            <div class="card-body" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px;">
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px; color: var(--color-text-secondary);">Mã Chứng Từ</label>
                <input type="text" value="TQ10427/AUTO" readonly style="width: 100%; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); background: #f1f5f9; color: #64748b; font-weight: 600;">
              </div>
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Số Điện Thoại <span style="color: var(--color-danger);">*</span></label>
                <div style="display: flex; gap: 8px;">
                  <input type="text" placeholder="Gõ để tìm KH cũ..." style="flex: 1; padding: 10px; border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); outline: none;">
                  <button class="btn" style="padding: 0 12px; border: 1px solid var(--color-border); background: var(--color-background); border-radius: var(--radius-md); cursor: pointer;"><span class="material-symbols-outlined">search</span></button>
                </div>
              </div>
              <div class="form-group" style="grid-column: span 2;">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Họ tên Cô Dâu - Chú Rể <span style="color: var(--color-danger);">*</span></label>
                <input type="text" placeholder="VD: Nguyễn Văn A - Lê Thị B" style="width: 100%; padding: 10px; border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); outline: none; font-weight: 500;">
              </div>
              <div class="form-group" style="grid-column: span 2;">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Địa chỉ liên hệ</label>
                <input type="text" placeholder="Phường, Quận..." style="width: 100%; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none;">
              </div>
            </div>
          </div>

          <!-- Thẻ 2: Thông tin Tiệc & Nhu cầu -->
          <div class="card" style="margin-bottom: 24px; box-shadow: none;">
            <div class="card-header" style="padding: 16px; background: #F8FAFC; font-size: 14px; color: var(--color-text-secondary);">2. Nhu Cầu & Tiệc Dự Kiến</div>
            <div class="card-body" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px;">
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Ngày tổ chức</label>
                <input type="date" style="width: 100%; padding: 10px; border: 1px solid var(--color-border-strong); border-radius: var(--radius-md); outline: none;">
              </div>
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Loại tiệc & Khung giờ</label>
                <div style="display: flex; gap: 8px;">
                  <select style="flex: 1; min-width: 0; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none; background: white;">
                    <option>Tiệc Cưới</option>
                    <option>Sinh Nhật</option>
                    <option>Hội Nghị</option>
                  </select>
                  <select style="flex: 1; min-width: 0; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none; background: white;">
                    <option>Trưa (11h-14h)</option>
                    <option selected>Tối (17h-22h)</option>
                  </select>
                </div>
              </div>
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Số Bàn</label>
                <div style="display: flex; gap: 8px; align-items: center;">
                  <input type="number" id="inp-ban-man" placeholder="Mặn" title="Số bàn mặn" min="0" style="flex: 1; min-width: 0; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none;">
                  <span style="color: var(--color-text-secondary);">+</span>
                  <input type="number" id="inp-ban-chay" placeholder="Chay" title="Số bàn chay" min="0" style="flex: 1; min-width: 0; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none;">
                  <span style="color: var(--color-text-secondary);">=</span>
                  <input type="number" id="inp-tong-ban" placeholder="Tổng" readonly style="flex: 1; min-width: 0; padding: 10px; border: 1px solid transparent; background: #e0e7ff; color: var(--color-primary); font-weight: 700; border-radius: var(--radius-md); outline: none;">
                </div>
              </div>
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Trạng thái Tư Vấn</label>
                <select style="width: 100%; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none; background: white;">
                  <option>0 - Đang Tư Vấn</option>
                  <option>1 - Khách Hủy / Rớt Khách</option>
                  <option>2 - Chuyển sang Đặt Cọc</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Thẻ 3: Chọn Sảnh & Ghi chú -->
          <div class="card" style="box-shadow: none;">
            <div class="card-header" style="padding: 16px; background: #F8FAFC; font-size: 14px; color: var(--color-text-secondary);">3. Sảnh Quan Tâm & Ghi Chú</div>
            <div class="card-body">
              <div class="form-group" style="margin-bottom: 16px;">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Khách quan tâm Sảnh nào? (Chọn nhiều)</label>
                <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                  <label style="background: var(--color-background); border: 1px solid var(--color-border-strong); padding: 8px 12px; border-radius: 20px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px;">
                    <input type="checkbox"> Diamond Hall
                  </label>
                  <label style="background: var(--color-background); border: 1px solid var(--color-border-strong); padding: 8px 12px; border-radius: 20px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px;">
                    <input type="checkbox"> Ruby Hall
                  </label>
                  <label style="background: var(--color-background); border: 1px solid var(--color-border-strong); padding: 8px 12px; border-radius: 20px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px;">
                    <input type="checkbox"> Queen Plaza
                  </label>
                </div>
              </div>
              <div class="form-group">
                <label style="display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px;">Nội dung Ghi chú Trao đổi</label>
                <textarea rows="3" placeholder="Nhập tóm tắt trao đổi với khách, hứa hẹn giảm giá..." style="width: 100%; padding: 10px; border: 1px solid var(--color-border); border-radius: var(--radius-md); outline: none; resize: vertical; font-family: var(--font-family);"></textarea>
              </div>
            </div>
          </div>
        </div>

        <!-- Panel Footer (Actions) -->
        <div style="padding: 16px 24px; border-top: 1px solid var(--color-border); display: flex; justify-content: flex-end; gap: 12px; background: #F8FAFC;">
          <button id="btn-cancel-form" style="padding: 10px 20px; border: 1px solid var(--color-border-strong); background: white; border-radius: var(--radius-md); cursor: pointer; font-weight: 500; color: var(--color-text);">Hủy Bỏ</button>
          <button style="padding: 10px 24px; border: none; background: var(--color-primary); color: white; border-radius: var(--radius-md); cursor: pointer; font-weight: 600; display: flex; align-items: center; gap: 6px; box-shadow: 0 4px 6px rgba(60,80,224,0.2);">
            <span class="material-symbols-outlined" style="font-size: 18px;">save</span>
            Lưu Dữ Liệu
          </button>
        </div>

      </div>
    `;

    $container.innerHTML = html;
    
    _bindEvents();
  }

  function _bindEvents() {
    var overlay = document.getElementById('visitor-form-overlay');
    var panel = document.getElementById('visitor-form-panel');
    var btnAdd = document.getElementById('btn-add-visitor');
    var btnClose = document.getElementById('btn-close-form');
    var btnCancel = document.getElementById('btn-cancel-form');
    
    // Nút chỉnh sửa trên lưới
    var btnsEdit = document.querySelectorAll('.btn-edit-visitor');

    function openPanel() {
      overlay.classList.add('active');
      panel.style.right = '0';
    }

    function closePanel() {
      overlay.classList.remove('active');
      panel.style.right = '-800px';
    }

    if(btnAdd) btnAdd.addEventListener('click', openPanel);
    if(btnClose) btnClose.addEventListener('click', closePanel);
    if(btnCancel) btnCancel.addEventListener('click', closePanel);
    if(overlay) overlay.addEventListener('click', closePanel);

    btnsEdit.forEach(function(btn) {
      btn.addEventListener('click', openPanel);
    });

    // Auto sum tables
    var inpMan = document.getElementById('inp-ban-man');
    var inpChay = document.getElementById('inp-ban-chay');
    var inpTong = document.getElementById('inp-tong-ban');

    function calcTotal() {
      var m = Math.max(0, parseInt(inpMan.value) || 0);
      var c = Math.max(0, parseInt(inpChay.value) || 0);
      // Clamp lại UI về 0 nếu user gõ số âm
      if (inpMan.value !== '' && parseInt(inpMan.value) < 0) inpMan.value = 0;
      if (inpChay.value !== '' && parseInt(inpChay.value) < 0) inpChay.value = 0;
      inpTong.value = m + c;
    }

    if(inpMan) inpMan.addEventListener('input', calcTotal);
    if(inpChay) inpChay.addEventListener('input', calcTotal);
  }

  return {
    render: render
  };
})();
