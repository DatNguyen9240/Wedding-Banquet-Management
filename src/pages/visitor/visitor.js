/**
 * Module Giao diện Khách Tham Quan (Visitor Page)
 * HTML Template: src/pages/visitor.html
 */
var VisitorPage = (function () {
  
  var $containerElement;
  var visitorData = [];
  var today = new Date();
  var firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  
  function _formatDateYYYYMMDD(date) {
    var d = date.getDate().toString().padStart(2, '0');
    var m = (date.getMonth() + 1).toString().padStart(2, '0');
    var y = date.getFullYear();
    return y + '-' + m + '-' + d;
  }

  var filterParams = {
    Keyword: "",
    TuNgay: _formatDateYYYYMMDD(firstDay),
    DenNgay: _formatDateYYYYMMDD(today)
  };

  function _initFilterDates() {
    var inpFrom = $containerElement.querySelector('#visitor-date-from');
    var inpTo = $containerElement.querySelector('#visitor-date-to');
    if (inpFrom) inpFrom.value = filterParams.TuNgay;
    if (inpTo) inpTo.value = filterParams.DenNgay;
  }

  function render($container) {
    $containerElement = $container;
    fetch('./src/pages/visitor/visitor.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _initFilterDates();
        _bindEvents();
        _loadData();
      });
  }

  function _loadData() {
    var tbody = $containerElement.querySelector('#visitor-tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4" style="color: var(--color-text-secondary);">Đang tải dữ liệu...</td></tr>';

    if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.VISITOR || !API_CONFIG.ENDPOINTS.VISITOR.LIST) {
      console.warn('Thiếu cấu hình API VISITOR.LIST');
      visitorData = [];
      _renderTable();
      return;
    }

    var payloadString = encodeURIComponent(JSON.stringify(filterParams));
    var endpoint = API_CONFIG.ENDPOINTS.VISITOR.LIST + '?q=' + payloadString;

    ApiClient.get(endpoint)
      .then(function (res) {
        if (res && res.records) {
          visitorData = res.records;
        } else if (res && res.data) {
          visitorData = res.data;
        } else if (Array.isArray(res)) {
          visitorData = res;
        } else {
          visitorData = [];
        }
        _renderTable();
      })
      .catch(function (err) {
        console.error('Lỗi Load Visitor:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Lỗi kết nối API lấy danh sách Khách tham quan!</td></tr>';
      });
  }

  function _renderTable() {
    var tbody = $containerElement.querySelector('#visitor-tbody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    if (!visitorData || visitorData.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4" style="color: var(--color-text-secondary);">Không có dữ liệu</td></tr>';
      return;
    }

    visitorData.forEach(function(row) {
      var currentStatus = row.TrangThai || 'Đang Tư Vấn';
      var statusClass = currentStatus.includes('Hủy') ? 'danger' : 
                        currentStatus.includes('Đã Đặt Cọc') ? 'success' : 'warning';
      
      var hallName = row.SanhTiec || '<span style="font-style:italic;opacity:0.5;">Chưa chọn</span>';
      var packageName = row.GoiTiec || 'Chưa Chọn';

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="fw-semibold">${row.MaPhieu || ''}</td>
        <td>
          <div class="fw-medium">${row.TenKhachHang || '---'}</div>
          <div style="font-size: 13px; color: var(--color-text-secondary);">${row.DienThoai || '---'}</div>
        </td>
        <td>
          ${row.NgayDuKien || '---'}
          <div style="font-size: 12px; color: var(--color-text-secondary);">${row.NgayAmLich || ''}</div>
        </td>
        <td>
          <div class="fw-medium">${packageName}</div>
          <div style="font-size: 13px; color: var(--color-text-secondary);">${hallName}</div>
        </td>
        <td><span class="status-badge ${statusClass}">${currentStatus}</span></td>
        <td class="text-end">
          ${UIButton.createHTML({ icon: 'edit', type: 'tool', className: 'btn-edit-visitor', data: { id: row.MaPhieu }, style: 'display: inline-flex;' })}
        </td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    var overlay = document.getElementById('visitor-form-overlay');
    var panel = document.getElementById('visitor-form-panel');
    var btnAdd = document.getElementById('btn-add-visitor');
    var btnClose = document.getElementById('btn-close-form');
    var btnCancel = document.getElementById('btn-cancel-form');
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

    // Dùng event delegation cho nút sửa vì row được sinh ra động
    var tbody = $containerElement.querySelector('#visitor-tbody');
    if (tbody) {
      tbody.addEventListener('click', function(e) {
        var btnEdit = e.target.closest('.btn-edit-visitor');
        if (btnEdit) {
          openPanel();
        }
      });
    }

    // Lọc theo Ngày
    var inpFrom = document.getElementById('visitor-date-from');
    var inpTo = document.getElementById('visitor-date-to');
    var searchInput = document.getElementById('visitor-search-input');

    if (inpFrom) {
      inpFrom.addEventListener('change', function(e) {
        filterParams.TuNgay = e.target.value;
        _loadData();
      });
    }

    if (inpTo) {
      inpTo.addEventListener('change', function(e) {
        filterParams.DenNgay = e.target.value;
        _loadData();
      });
    }

    if (searchInput) {
      var searchTimeout;
      searchInput.addEventListener('input', function(e) {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(function() {
          filterParams.Keyword = e.target.value;
          _loadData();
        }, 500);
      });
    }

    // Auto sum tables
    var inpMan = document.getElementById('inp-ban-man');
    var inpChay = document.getElementById('inp-ban-chay');
    var inpTong = document.getElementById('inp-tong-ban');

    function calcTotal() {
      var m = Math.max(0, parseInt(inpMan.value) || 0);
      var c = Math.max(0, parseInt(inpChay.value) || 0);
      if (inpMan.value !== '' && parseInt(inpMan.value) < 0) inpMan.value = 0;
      if (inpChay.value !== '' && parseInt(inpChay.value) < 0) inpChay.value = 0;
      inpTong.value = m + c;
    }

    if(inpMan) inpMan.addEventListener('input', calcTotal);
    if(inpChay) inpChay.addEventListener('input', calcTotal);
  }

  return { render: render };
})();
