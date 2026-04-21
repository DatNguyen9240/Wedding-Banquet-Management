/**
 * Trang minh họa (Demo) cho các Custom Controls (Checkbox, ComboBox, Grid Dropdown)
 */
var ComponentsDemoPage = (function () {

  function render($container) {
    // 1. Tạo Layout HTML thô
    var html = `
      <div class="page-title-bar">
        <span>Minh họa UI Components (Dropdown, ComboBox, Checkbox)</span>
      </div>
      
      <!-- CHECKBOX GROUP -->
      <div class="card mb-4" style="animation: slideUp 0.3s ease forwards;">
        <div class="card-header">1. Nhóm Checkbox</div>
        <div class="card-body" style="display: flex; gap: 24px; padding: 24px; flex-wrap: wrap;" id="demo-checkbox-group">
          <!-- Inject Checkboxes by JS -->
        </div>
      </div>

      <!-- COMBOBOX -->
      <div class="card mb-4" style="animation: slideUp 0.4s ease forwards;">
        <div class="card-header">2. ComboBox Chọn Nhân Viên (với DataGrid xổ xuống)</div>
        <div class="card-body" style="padding: 24px;">
          <div style="max-width: 400px;">
            <label style="display:block; font-size:13px; font-weight:500; margin-bottom:6px; color:var(--color-text-secondary);">Người bán (Nhấn F4 hiển thị, F3 tra cứu, F2 thêm)</label>
            <div id="demo-combobox-wrapper"></div>
          </div>
        </div>
      </div>

      <!-- GRID DROPDOWN -->
      <div class="card" style="animation: slideUp 0.5s ease forwards;">
        <div class="card-header">3. Dropdown trong Datagrid (dành cho chọn Hàng Hóa)</div>
        <div class="card-body" style="padding: 0;">
          <div class="table-wrapper">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Mã kho</th>
                  <th style="width: 300px;">Mã hàng (Click/Focus để chọn)</th>
                  <th>Tên hàng</th>
                  <th>ĐVT</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>K001</td>
                  <td id="td-grid-dropdown-1" style="padding:0;"></td>
                  <td id="lbl-tenhang-1"></td>
                  <td id="lbl-dvt-1"></td>
                </tr>
                <tr>
                  <td>K001</td>
                  <td id="td-grid-dropdown-2" style="padding:0;"></td>
                  <td id="lbl-tenhang-2"></td>
                  <td id="lbl-dvt-2"></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;

    $container.innerHTML = html;

    _mountComponents();
  }

  function _mountComponents() {
    // ---- 1. MOUNT CHECKBOXES ----
    var cbGroup = document.getElementById('demo-checkbox-group');
    if (cbGroup) {
      cbGroup.appendChild(UIControls.createCheckbox({ label: 'Khách hàng', checked: true }));
      cbGroup.appendChild(UIControls.createCheckbox({ label: 'Nhà cung cấp', checked: true }));
      cbGroup.appendChild(UIControls.createCheckbox({ label: 'Nhân viên', checked: false }));
    }

    // ---- 2. MOUNT COMBOBOX ----
    var cbWrapper = document.getElementById('demo-combobox-wrapper');
    if (cbWrapper) {
      var nvData = window.MockData ? window.MockData.demoEmployees : [];
      var combo = UIControls.createDataComboBox({
        placeholder: 'Chọn nhân viên...',
        headers: ['Mã nhân viên', 'Tên nhân viên', 'Điện thoại'],
        data: nvData,
        colFilterIndex: 1, // Lọc theo Tên và điền tên vào input
        colHighlightIndex: 1, // Highlight tên
        onSelect: function(row) {
          console.log('Selected NV:', row);
        },
        onF2: function() { alert('Mở form Thêm nhân viên (F2)'); },
        onF3: function() { alert('Mở form Tra cứu nhân viên (F3)'); }
      });
      cbWrapper.appendChild(combo);
    }

    // ---- 3. MOUNT GRID DROPDOWN ----
    var hhData = window.MockData ? window.MockData.demoItems : [];

    var td1 = document.getElementById('td-grid-dropdown-1');
    var td2 = document.getElementById('td-grid-dropdown-2');

    var dropOpts1 = {
      placeholder: 'Gõ mã hàng...',
      headers: ['Mã hàng', 'Tên hàng', 'ĐVT', 'Quy đổi', 'Chẵn', 'Lẻ', 'SL Tồn'],
      data: hhData,
      colFilterIndex: 0,
      colHighlightIndex: 0,
      onSelect: function(row) {
        document.getElementById('lbl-tenhang-1').innerText = row[1];
        document.getElementById('lbl-dvt-1').innerText = row[2];
      }
    };

    var dropOpts2 = Object.assign({}, dropOpts1, {
      onSelect: function(row) {
        document.getElementById('lbl-tenhang-2').innerText = row[1];
        document.getElementById('lbl-dvt-2').innerText = row[2];
      }
    });

    if (td1) td1.appendChild(UIControls.createGridDropdown(dropOpts1));
    if (td2) td2.appendChild(UIControls.createGridDropdown(dropOpts2));
  }

  return {
    render: render
  };
})();
