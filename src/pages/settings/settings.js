/**
 * Màn hình Thiết lập Hệ thống (Settings)
 * HTML Template: src/pages/settings.html
 */
var SettingsPage = (function () {
  var gridApi1 = null;
  var gridApi2 = null;

  function render($container) {
    fetch('./src/pages/settings/settings.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _mountTabs();
      });
  }

  function _mountTabs() {
    var tabsContainer = document.getElementById('settings-tabs-container');
    if (!tabsContainer) return;

    var tabs = UITabs.create([
      { title: 'Kỳ Kế Toán', icon: 'calendar_month', content: _buildPeriodTab() },
      { title: 'Định biên CL', icon: 'groups', content: _buildCLRatioTab() }
    ]);

    tabsContainer.appendChild(tabs);
    setTimeout(_attachFileUploadLogic, 100);
  }

  function _buildCompanyInfoTab() {
    // Giu nguyen nhu cu neu can thiet
    var wrapper = document.createElement('div');
    return wrapper;
  }

  function _attachFileUploadLogic() { }

  function _buildPeriodTab() {
    var wrapper = document.createElement('div');
    var currentYear = '2026';

    wrapper.innerHTML = `
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 mb-3">
          <div style="font-size:var(--font-size-lg); font-weight:600;">Quản lý Năm Sử Dụng & Kỳ Kế Toán</div>
          <div class="d-flex gap-2 flex-wrap">
            ${UIButton.createHTML({ text: 'Chuyển tới Kỳ Khác', type: 'secondary', onClick: "ConfirmModal.show({title:'Chuyển Kỳ',message:'Chuyển đổi dữ liệu sang kỳ làm việc khác?'})" })}
            ${UIButton.createHTML({ text: 'Tạo Mới Năm 2027', icon: 'add', type: 'primary', iconStyle: 'font-size:18px;margin-right:6px', onClick: "UIToast.show('Đã sinh thành công dữ liệu cho Năm 2027.')" })}
          </div>
        </div>
        <div class="row g-4">
          <div class="col-md-3">
            <label class="fw-semibold d-block mb-2">Năm Làm Việc</label>
            <ul style="list-style:none;padding:0;margin:0;" class="d-flex flex-column gap-2">
              <li class="year-item active" onclick="SettingsPage.selectYear(this,'2026')">Năm 2026 (Hiện tại)</li>
              <li class="year-item" onclick="SettingsPage.selectYear(this,'2025')">Năm 2025</li>
              <li class="year-item" onclick="SettingsPage.selectYear(this,'2024')">Năm 2024</li>
            </ul>
          </div>
          <div class="col-md-9">
            <div class="d-flex justify-content-between flex-wrap gap-2 align-items-center mb-3">
              <span class="fw-semibold" id="period-header-year">Tháng / Kỳ trong năm 2026</span>
              ${UIBadge.createHTML('Kỳ hiện hành: T10/2026', 'success', '', 'status-badge')}
            </div>
            <div id="period-grid-container" style="height: 480px; width: 100%;"></div>
          </div>
        </div>
      </div>`;

    var lockedPeriods = window.PeriodManager ? window.PeriodManager.getLockedPeriods() : {};
    var periodData = [];
    for (var i = 1; i <= 12; i++) {
      var key = i + '/' + currentYear;
      var isLocked = lockedPeriods[key] === true;
      periodData.push({
        month: i,
        year: currentYear,
        period: 'Tháng ' + (i < 10 ? '0' : '') + i + '/' + currentYear,
        quarter: 'Quý ' + Math.ceil(i / 3),
        status: isLocked
      });
    }

    setTimeout(function() {
      var container = wrapper.querySelector('#period-grid-container');
      if (!container) return;

      var gridOptions = {
        pagination: false,
        columnDefs: [
          { field: 'period', headerName: 'Kỳ (Tháng)' },
          { field: 'quarter', headerName: 'Phân Quý' },
          { 
            field: 'status', 
            headerName: 'Trạng Thái',
            cellRenderer: function(params) {
              return params.value ? UIBadge.createHTML('Đã Khóa', 'warning', '', 'status-badge') : UIBadge.createHTML('Đang Mở', 'success', '', 'status-badge');
            }
          },
          {
            headerName: 'Khóa / Mở Kỳ',
            cellStyle: { textAlign: 'right' },
            headerClass: 'text-end',
            cellRenderer: function(params) {
              var isLocked = params.value;
              var checked = isLocked ? 'checked' : '';
              var m = params.data.month;
              var y = params.data.year;
              
              var label = document.createElement('label');
              label.className = 'ui-checkbox-container';
              label.style.cssText = 'display:inline-flex; width:auto; margin:0;';
              label.innerHTML = '<input type="checkbox" class="chk-lock-period" data-month="' + m + '" data-year="' + y + '" ' + checked + '><span class="checkmark"></span> Khóa dữ liệu';
              return label;
            }
          }
        ],
        rowData: periodData
      };

      gridApi1 = AppGrid.create(container, gridOptions);
    }, 100);

    wrapper.addEventListener('change', function (e) {
      if (e.target.classList.contains('chk-lock-period')) {
        var isChecked = e.target.checked;
        var m = e.target.getAttribute('data-month');
        var y = e.target.getAttribute('data-year');
        if (window.PeriodManager) {
          window.PeriodManager.setLockedPeriod(m, y, isChecked);
          
          // Cap nhat lai model cua AG Grid
          if (gridApi1) {
            var rowNode = gridApi1.getRowNode(m - 1);
            if (rowNode) {
              rowNode.setDataValue('status', isChecked);
            }
          }

          if (window.UIToast) UIToast.show((isChecked ? 'Đã khóa' : 'Đã mở khóa') + ' dữ liệu tháng ' + m + '/' + y, isChecked ? 'warning' : 'success');
        }
      }
    });

    if (!document.getElementById('year-item-style')) {
      var style = document.createElement('style');
      style.id = 'year-item-style';
      style.textContent = '.year-item{padding:10px 16px;background: var(--color-surface);border:1px solid var(--color-border);color:var(--color-text);border-radius:6px;cursor:pointer;transition:all 0.2s;}.year-item:hover{border-color:var(--color-primary);}.year-item.active{background: var(--color-background);border:1px solid var(--color-primary);color:var(--color-primary);font-weight:600;}';
      document.head.appendChild(style);
    }

    return wrapper;
  }

  function _buildCLRatioTab() {
    var wrapper = document.createElement('div');
    wrapper.className = 'p-4';
    wrapper.innerHTML = `
      <div class="d-flex justify-content-between align-items-center mb-3">
        <div style="font-size:var(--font-size-lg); font-weight:600;">Cấu hình Định biên Nhân sự (Casual Labor - CL)</div>
      </div>
      <p style="font-size:14px; color:var(--color-text-secondary); margin-bottom:20px; line-height:1.5;">
        Thiết lập định số lượng nhân sự Casual Labor (CL) đề xuất trên mỗi bàn tiệc theo từng loại hình sự kiện.
        Công thức tính CL đề xuất: <code style="background: rgba(148, 163, 184, 0.1); padding:2px 6px; border-radius:4px;">Định biên × Số bàn chính thức - Số NV phân công</code>.
      </p>
      <div id="cl-ratio-grid-container" class="mb-4" style="height: 400px; width: 100%;"></div>
      <div class="d-flex gap-2 pt-3" style="border-top:1px solid var(--color-border);">
        ${UIButton.createHTML({ text: 'Lưu Cấu Hình Định Biên', type: 'primary', id: 'btn-save-cl-ratios' })}
      </div>
    `;

    // Load data
    if (typeof SystemDataService !== 'undefined') {
      SystemDataService.getBanquetTypes(true).then(function (types) {
        var container = wrapper.querySelector('#cl-ratio-grid-container');
        if (!container) return;

        var rowData = types.map(function(type, idx) {
          var id = type['Mã loại'] || type.Loaitiecid;
          var name = type['Loại hình tiệc'] || type.Tenloaitiec;
          var ratio = type['Định biên'] !== undefined ? type['Định biên'] : (type.DinhBienCL !== undefined ? type.DinhBienCL : 0.0);
          return { id: id, name: name, ratio: ratio };
        });

        var gridOptions = {
          pagination: false,
          columnDefs: [
            { headerName: 'STT', valueGetter: 'node.rowIndex + 1', width: 80, cellStyle: { textAlign: 'center' }, headerClass: 'text-center' },
            { field: 'id', headerName: 'Mã Loại Hình', cellStyle: { fontWeight: '600' } },
            { field: 'name', headerName: 'Loại Hình Sự Kiện / Tiệc' },
            { 
              field: 'ratio', 
              headerName: 'Định Biên (Nhân viên / Bàn)',
              cellStyle: { textAlign: 'right' },
              headerClass: 'text-end',
              cellRenderer: function(params) {
                var ratio = params.value;
                var id = params.data.id;
                var name = params.data.name;
                var div = document.createElement('div');
                div.style.cssText = 'display:inline-flex; justify-content:flex-end; width:100%;';
                div.innerHTML = '<input type="number" class="ui-input text-end cl-ratio-input" data-id="' + id + '" data-name="' + name + '" value="' + ratio + '" step="0.01" min="0" max="10" style="width: 120px; display: inline-block;">';
                return div;
              }
            }
          ],
          rowData: rowData
        };

        gridApi2 = AppGrid.create(container, gridOptions);

      }).catch(function (err) {
        console.error(err);
        var container = wrapper.querySelector('#cl-ratio-grid-container');
        if (container) container.innerHTML = '<div class="text-center py-4 text-danger">Lỗi tải dữ liệu. Vui lòng F5 thử lại!</div>';
      });
    }

    // Save action
    var saveBtn = wrapper.querySelector('#btn-save-cl-ratios');
    if (saveBtn) {
      saveBtn.addEventListener('click', function () {
        var inputs = wrapper.querySelectorAll('.cl-ratio-input');
        var promises = [];
        var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
        var username = u.Username || u.UserName || 'admin';

        inputs.forEach(function (input) {
          var id = input.getAttribute('data-id');
          var name = input.getAttribute('data-name');
          var val = parseFloat(input.value || 0);

          var payload = {
            List: 'dmLoaihinhtiec',
            Func: 'Save',
            UserName: username,
            JsonData: JSON.stringify({
              Loaitiecid: id,
              Tenloaitiec: name,
              DinhBienCL: val,
              IsEdit: 1
            })
          };

          promises.push(ApiClient.post('/api/API_Gateway_Router', payload));
        });

        saveBtn.disabled = true;
        var originalText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang lưu...';

        Promise.all(promises).then(function (results) {
          var allSuccess = results.every(function (res) { return res && res.code === 0; });
          if (allSuccess) {
            UIToast.show('Đã cập nhật cấu hình định biên CL thành công!', 'success');
            if (typeof SystemDataService !== 'undefined') SystemDataService.invalidateCache();
          } else {
            var failed = results.find(function (res) { return res && res.code !== 0; });
            var msg = failed ? (failed.msg || failed.Message) : 'Lưu dữ liệu thất bại';
            UIToast.show('Lỗi: ' + msg, 'danger');
          }
        }).catch(function (err) {
          console.error(err);
          UIToast.show('Lỗi kết nối máy chủ API Gateway!', 'danger');
        }).finally(function () {
          saveBtn.disabled = false;
          saveBtn.innerHTML = originalText;
        });
      });
    }

    return wrapper;
  }

  return {
    render: render,
    selectYear: function (el, year) {
      if (!el) return;
      var items = el.parentElement.querySelectorAll('.year-item');
      items.forEach(function (item) { item.classList.remove('active'); });
      el.classList.add('active');
      UIToast.show('Đã chuyển sang xem Kỳ Kế Toán Năm ' + year);
      var headerText = document.getElementById('period-header-year');
      if (headerText) headerText.innerText = 'Tháng / Kỳ trong năm ' + year;
    }
  };
})();
