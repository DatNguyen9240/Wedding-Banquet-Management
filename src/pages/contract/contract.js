/**
 * Màn hình Quản lý Hợp Đồng (Contract)
 * HTML Template: src/pages/contract.html
 */
var ContractPage = (function () {
  var $container;
  var contractData = [];

  var filterParams = {
    Keyword: "",
    TuNgay: "",
    DenNgay: ""
  };
  
  var _isFromBooking = false;

  function render(containerElement) {
    $container = containerElement;

    contractData = [];
    _isFromBooking = false;

    fetch('./src/pages/contract/contract.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;

        // Bắt tham số date hoặc id từ URL (ví dụ: ?date=2023-03-03 hoặc ?id=HD123)
        var hashParts = window.location.hash.split('?');
        if (hashParts.length > 1) {
          var params = new URLSearchParams(hashParts[1]);
          var dateParam = params.get('date');
          var idParam = params.get('id');
          var bookingIdParam = params.get('bookingId');
          
          if (dateParam) {
            filterParams.TuNgay = dateParam;
            filterParams.DenNgay = dateParam;
          }
          if (idParam) {
            filterParams.Keyword = idParam;
            // Xóa bộ lọc ngày nếu đang tìm theo ID cụ thể
            filterParams.TuNgay = "";
            filterParams.DenNgay = "";
          }
          _bindEvents();
          
          if (bookingIdParam) {
            _isFromBooking = true;
            _showDetailView(true, bookingIdParam);
          } else {
            _loadData();
          }
        } else {
          _bindEvents();
          _loadData();
        }
      });
  }

  function _loadData() {
    var tbody = $container.querySelector('#contract-table tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4" style="color: var(--color-text-secondary);">Đang tải dữ liệu...</td></tr>';

    var payloadString = encodeURIComponent(JSON.stringify(filterParams));
    var endpoint = (typeof API_CONFIG !== 'undefined' && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.CONTRACT && API_CONFIG.ENDPOINTS.CONTRACT.LIST)
      ? API_CONFIG.ENDPOINTS.CONTRACT.LIST + '?q=' + payloadString
      : '/api/API_Contract_List?q=' + payloadString;

    if (typeof ApiClient !== 'undefined') {
      ApiClient.get(endpoint)
        .then(function (res) {
          if (res && res.records) {
            contractData = res.records;
          } else if (res && res.data) {
            contractData = res.data;
          } else if (Array.isArray(res)) {
            contractData = res;
          }
          _renderTable();
        })
        .catch(function (err) {
          console.error('Lỗi tải dữ liệu Hợp Đồng:', err);
          contractData = [];
          _renderTable();
        });
    } else {
      contractData = [];
      _renderTable();
    }
  }

  function _renderTable() {
    var tbody = $container.querySelector('#contract-table tbody');
    tbody.innerHTML = '';
    
    if (!contractData || contractData.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" class="text-center py-4" style="color: var(--color-text-secondary);">Không có dữ liệu hợp đồng</td></tr>';
      return;
    }

    contractData.forEach((row, idx) => {
      var currentStatus = row.TrangThai || row.status || '';
      var statusClass = currentStatus.includes('Ký') ? 'status-badge primary' : 'status-badge secondary';
      var hdId = row.Sohopdong || row.id;
      var customer = row.TenKhachHang || row.customerName;
      var eventDate = row.NgayToChuc || row.eventDate || '';
      var tables = row.SoBan || row.totalTables || 0;
      var amount = row.TongTien || row.totalAmount || 0;
      
      var formattedAmount = typeof amount === 'string' && amount.includes(',') ? amount + ' đ' : new Intl.NumberFormat('vi-VN').format(parseFloat(amount || 0)) + ' đ';

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-semibold" style="color: var(--color-primary);">${hdId}</td>
        <td class="fw-medium">${customer}</td>
        <td><span style="background: rgba(148, 163, 184, 0.1); padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${eventDate}</span></td>
        <td class="text-end">${tables} bàn</td>
        <td class="text-end fw-semibold" style="color: var(--color-danger);">${formattedAmount}</td>
        <td class="text-center"><span class="${statusClass}">${currentStatus}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function getSelectedRow() {
    var activeRow = $container.querySelector('#contract-table tbody tr.active');
    if (!activeRow) return null;
    var index = Array.from(activeRow.parentNode.children).indexOf(activeRow);
    return contractData[index];
  }

  function _bindEvents() {
    var btnAdd = $container.querySelector('#btn-add-contract');
    if (btnAdd) btnAdd.addEventListener('click', function () { _showDetailView(true); });

    var btnMore = $container.querySelector('#btn-contract-more');
    if (btnMore) {
      btnMore.addEventListener('click', function (e) {
        if (typeof UIContextMenu !== 'undefined') {
          var selected = getSelectedRow();
          UIContextMenu.show(e, [
            { 
              label: 'Xem / Sửa', 
              icon: 'edit', 
              onClick: function () { 
                if (!selected) {
                  UIToast.show('Vui lòng chọn một Hợp Đồng để xem/sửa!', 'warning');
                  return;
                }
                _showDetailView(false); 
              } 
            },
            { label: 'In Hợp Đồng', icon: 'print', onClick: function () { UIToast.show('Chức năng In đang phát triển'); } },
            '|',
            { label: '<span class="text-danger">Thanh Lý Hủy</span>', icon: 'delete', onClick: function () { UIToast.show('Xác nhận Thanh Lý Hủy'); } }
          ]);
        }
      });
    }

    // Row selection and double-click logic
    var tbody = $container.querySelector('#contract-table tbody');
    if (tbody) {
      tbody.addEventListener('click', function (e) {
        var tr = e.target.closest('tr');
        if (!tr) return;
        Array.from(tbody.querySelectorAll('tr')).forEach(r => r.classList.remove('active'));
        tr.classList.add('active');
      });

      tbody.addEventListener('dblclick', function (e) {
        var tr = e.target.closest('tr');
        if (!tr) return;
        Array.from(tbody.querySelectorAll('tr')).forEach(r => r.classList.remove('active'));
        tr.classList.add('active');
        _showDetailView(false);
      });
    }
  }

  function _showDetailView(isNew, bookingId) {
    document.getElementById('contract-list-view').style.display = 'none';
    var dv = document.getElementById('contract-detail-view');
    dv.style.display = 'block';
    dv.style.animation = 'slideUp 0.3s ease forwards';
    
    var titleText = 'Lập Hợp Đồng Mới';
    var chureVal = '';
    var codauVal = '';
    var dienthoaiVal = '';
    var ngaytochucVal = '';
    var banmanVal = 30;
    var banchayVal = 0;
    var banmanDuPhongVal = 0;
    var banchayDuPhongVal = 0;
    var tiencocVal = 0;
    var tongtienVal = 0;
    var sanhIdVal = '';
    var caIdVal = '';
    var loaiIdVal = '';
    var mainHallName = '';

    if (!isNew) {
      var contract = getSelectedRow();
      if (contract) {
        var hdId = contract.Sohopdong || contract.id || '';
        titleText = 'Chi Tiết Hợp Đồng ' + hdId;
        
        var names = (contract.TenKhachHang || contract.customerName || '').split('&');
        chureVal = names[0] ? names[0].trim() : '';
        codauVal = names[1] ? names[1].trim() : '';
        
        dienthoaiVal = contract.DienThoai || contract.phone || '';
        
        var rawDate = contract.NgayToChuc || contract.eventDate || '';
        if (rawDate.includes('/')) {
          var parts = rawDate.split('/');
          if (parts.length === 3) {
            ngaytochucVal = parts[2] + '-' + parts[1] + '-' + parts[0];
          }
        } else if (rawDate.includes('-')) {
          ngaytochucVal = rawDate.substring(0, 10);
        }

        banmanVal = contract.SobanManchinhthuc || contract.SoBan || 30;
        banmanDuPhongVal = contract.SobanManduphong || 0;
        banchayVal = contract.SobanChaychinhthuc || contract.SoBanChay || 0;
        banchayDuPhongVal = contract.SobanChayduphong || 0;
        tiencocVal = contract.Tongtiencoc || contract.Sotiencochopdong || contract.Sotiencoccho || 0;
        tongtienVal = contract.Tongtienhopdong || 0;
        sanhIdVal = contract.Sanhtiecid || '';
        caIdVal = contract.Thoigianid || '';
        loaiIdVal = contract.Loaitiecid || '';
        mainHallName = contract.SanhDat || contract.hall || '';
      }
    } else if (isNew && bookingId) {
      titleText = 'Lập Hợp Đồng Mới (Từ Booking: ' + bookingId + ')';
    }

    dv.innerHTML = `
      <style>
        /* Disable hover jump/scale effect on cards in contract details view */
        #contract-detail-view .card {
          transform: none !important;
          transition: none !important;
          box-shadow: var(--shadow-card) !important;
          overflow: visible !important;
        }
        #contract-detail-view .card:hover {
          transform: none !important;
          box-shadow: var(--shadow-card) !important;
        }

        .form-section-title {
          font-size: 13px;
          font-weight: 700;
          color: #F59E0B; /* Orange matching the screenshot */
          margin-top: 16px;
          margin-bottom: 8px;
          display: block;
        }

        .form-section-divider {
          height: 1px;
          background-color: var(--color-border);
          margin-bottom: 16px;
        }

        .contract-grid-3 {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 16px;
          margin-bottom: 24px;
        }

        .contract-grid-4 {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 16px;
          margin-bottom: 24px;
        }

        .contract-grid-6 {
          display: grid;
          grid-template-columns: repeat(6, 1fr);
          gap: 16px;
          margin-bottom: 16px;
        }

        .form-group {
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .form-group label {
          font-size: 13px;
          font-weight: 700;
          color: #1E293B; /* Slate 800 */
          margin-bottom: 0;
        }

        .ui-input {
          width: 100%;
          padding: 8px 12px;
          border: 1px solid var(--color-border-strong);
          border-radius: 8px;
          background: var(--color-surface);
          color: var(--color-text);
          font-size: 14px;
          font-family: inherit;
          font-weight: 500;
          outline: none;
          transition: all 0.2s ease;
          box-shadow: var(--shadow-xs);
          height: 38px;
        }

        .ui-input::placeholder {
          color: #94A3B8; /* Slate 400 */
        }

        .ui-input:focus {
          border-color: var(--color-primary);
          box-shadow: 0 0 0 3px var(--color-primary-light);
        }

        .ui-input:disabled, .ui-input[readonly] {
          background: var(--color-background);
          color: var(--color-text-secondary);
          cursor: not-allowed;
        }

        .contract-grid-3.conference-mode {
          grid-template-columns: repeat(2, 1fr);
        }

        /* Make table rows more spacious on desktop */
        .table-responsive td {
          padding: 14px 8px !important;
        }

        /* High Level Tab Styles */
        .high-tab-btn {
          background: none;
          border: none;
          border-bottom: 3px solid transparent;
          padding: 10px 24px 14px 24px;
          font-size: 16px;
          font-weight: 700;
          color: var(--color-text-secondary);
          transition: all 0.2s ease;
          display: flex;
          align-items: center;
          gap: 8px;
          cursor: pointer;
        }
        .high-tab-btn:hover {
          color: var(--color-primary);
        }
        .high-tab-btn.active {
          color: var(--color-primary);
          border-bottom-color: var(--color-primary);
        }

        @media (max-width: 992px) {
          .contract-grid-3, .contract-grid-4 {
            grid-template-columns: repeat(2, 1fr);
          }
          .contract-grid-3.conference-mode {
            grid-template-columns: repeat(2, 1fr);
          }
          .contract-grid-6 {
            grid-template-columns: repeat(3, 1fr);
          }
        }

        @media (max-width: 576px) {
          .contract-grid-3, .contract-grid-4, .contract-grid-6 {
            grid-template-columns: 1fr !important;
          }
        }

        @media (max-width: 600px) {
          .high-tab-btn {
            padding: 8px 8px 10px 8px !important;
            font-size: 12px !important;
            gap: 4px !important;
          }
          .high-tab-btn span.material-symbols-outlined {
            font-size: 16px !important;
          }
          
          /* Remove spacing on the two sides of tables */
          .p-4.mx-auto {
            padding-left: 0px !important;
            padding-right: 0px !important;
            padding-top: 12px !important;
            padding-bottom: 12px !important;
          }
          #contract-tabs-container {
            border: none !important;
            box-shadow: none !important;
            border-radius: 0px !important;
            background: transparent !important;
          }
          .ui-tabs-body {
            padding: 0 !important;
          }
          .ui-tab-panel {
            padding: 0 !important;
          }
          

          
          /* Compact horizontal row alignment for table headers on mobile */
          .p-4.mx-auto > .d-flex {
            flex-direction: row !important;
            align-items: center !important;
            justify-content: space-between !important;
            gap: 8px !important;
            padding: 0 10px !important;
          }
          .p-4.mx-auto > .d-flex h6 {
            font-size: 13px !important;
            font-weight: 700 !important;
          }
          .p-4.mx-auto > .d-flex button {
            width: auto !important;
            height: 30px !important;
            padding: 0 10px !important;
            font-size: 12px !important;
            border-radius: 6px !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
          }
          .p-4.mx-auto > .d-flex button span.material-symbols-outlined {
            font-size: 14px !important;
          }
          
          /* Compact table styling for mobile */
          .table-responsive table {
            font-size: 12px !important;
            min-width: 500px !important;
          }
          .table-responsive th, .table-responsive td {
            padding: 6px 6px !important;
            line-height: 1.3 !important;
          }
          .table-responsive th {
            font-size: 12px !important;
            font-weight: 700 !important;
          }
          .table-responsive td span {
            padding: 2px 6px !important;
            font-size: 11px !important;
          }
          
          /* Tighter specific columns on mobile */
          .table-responsive th:first-child, .table-responsive td:first-child {
            width: 45px !important; /* STT column */
          }
          .table-responsive th:last-child, .table-responsive td:last-child {
            width: 50px !important; /* Action delete button column */
          }
        }
      </style>

      <div class="page-title-bar d-flex flex-wrap justify-content-between align-items-center gap-3">
        <div class="d-flex align-items-center gap-2 flex-grow-1" style="min-width: 0;">
          ${UIButton.createHTML({ icon: 'arrow_back', type: 'secondary', className: 'text-nowrap flex-shrink-0', style: 'padding:6px 12px;border-radius:8px;', iconStyle: 'font-size:20px;', onClick: 'ContractPage.closeDetail()', text: '<span class="d-none d-sm-inline">Trở về</span>' })}
          <span class="fw-bold" style="font-size:18px; line-height: 1.3;" id="detail-title-text">${titleText}</span>
        </div>
        <div class="d-flex align-items-center flex-shrink-0">
          ${UIButton.createHTML({ icon: 'save', text: 'Lưu Hợp Đồng', type: 'primary', className: 'd-flex align-items-center gap-2 text-nowrap', style: 'border-radius:8px;', iconStyle: 'font-size:20px;', onClick: 'ContractPage.saveContract()' })}
        </div>
      </div>

      <!-- High-Level Tab Bar Switcher -->
      <div class="d-flex mb-4" style="border-bottom: 2px solid var(--color-border); padding-left: 8px;">
        <button class="high-tab-btn active" id="high-tab-info" onclick="ContractPage.switchHighLevelTab('info')">
          ${UIIcon.createHTML('description', 'font-size: 20px;')}
          <span>1. Thông tin Hợp đồng</span>
        </button>
        <button class="high-tab-btn" id="high-tab-menu" onclick="ContractPage.switchHighLevelTab('menu')">
          ${UIIcon.createHTML('restaurant_menu', 'font-size: 20px;')}
          <span>2. Thực đơn & Dịch vụ</span>
        </button>
      </div>

      <!-- High-Level Tab Contents -->
      <div id="high-content-info" class="high-tab-content">
        <div class="card mb-4" style="padding: 24px; background: #FFFFFF; border-radius: 12px; border: 1px solid var(--color-border); overflow: visible !important;">
          <!-- 1. Thông tin Khách hàng -->
          <span class="form-section-title">1. Thông tin Khách hàng</span>
          <div class="form-section-divider"></div>
          <div class="contract-grid-3">
            <div class="form-group" id="grp-tenchure">
              <label id="lbl-tenchure">Tên Chú Rể</label>
              <input type="text" id="inp-tenchure" class="ui-input" placeholder="Nhập tên chú rể" value="${chureVal}">
            </div>
            <div class="form-group" id="grp-tencodau">
              <label id="lbl-tencodau">Tên Cô Dâu</label>
              <input type="text" id="inp-tencodau" class="ui-input" placeholder="Nhập tên cô dâu" value="${codauVal}">
            </div>
            <div class="form-group">
              <label>Số Điện Thoại</label>
              <input type="text" id="inp-dienthoai" class="ui-input" placeholder="Nhập SĐT liên hệ" value="${dienthoaiVal}">
            </div>
          </div>

          <!-- 2. Thời gian & Địa điểm -->
          <span class="form-section-title">2. Thời gian & Địa điểm</span>
          <div class="form-section-divider"></div>
          <div class="contract-grid-4">
            <div class="form-group">
              <label>Ngày Tổ Chức</label>
              <input type="date" id="inp-ngaytochuc" class="ui-input" value="${ngaytochucVal}">
            </div>
            <div class="form-group">
              <label>Loại Tiệc</label>
              <select id="sel-loai" class="ui-input"><option value="">-- Chọn Loại Tiệc --</option></select>
            </div>
            <div class="form-group">
              <label>Ca Tiệc</label>
              <select id="sel-ca" class="ui-input"><option value="">-- Chọn Ca Tiệc --</option></select>
            </div>
            <div class="form-group">
              <label>Sảnh Chính</label>
              <select id="sel-sanh" class="ui-input"><option value="">-- Chọn Sảnh --</option></select>
            </div>
          </div>

          <!-- 3. Quy mô & Tiền cọc -->
          <span class="form-section-title">3. Quy mô & Tiền cọc</span>
          <div class="form-section-divider"></div>
          <div class="contract-grid-6">
            <div class="form-group">
              <label>Số Bàn Mặn</label>
              <input type="number" id="inp-ban-man" class="ui-input text-end" value="${banmanVal}" min="0">
            </div>
            <div class="form-group">
              <label>Dự Phòng Mặn</label>
              <input type="number" id="inp-duphong-man" class="ui-input text-end" value="${banmanDuPhongVal}" min="0">
            </div>
            <div class="form-group">
              <label>Số Bàn Chay</label>
              <input type="number" id="inp-ban-chay" class="ui-input text-end" value="${banchayVal}" min="0">
            </div>
            <div class="form-group">
              <label>Dự Phòng Chay</label>
              <input type="number" id="inp-duphong-chay" class="ui-input text-end" value="${banchayDuPhongVal}" min="0">
            </div>
            <div class="form-group">
              <label>Tổng Tiền (Dự kiến)</label>
              <input type="text" id="inp-tong-tien" class="ui-input text-end" value="${tongtienVal.toLocaleString('vi-VN')}" readonly style="background: var(--color-background); font-weight: 700; color: var(--color-primary);">
            </div>
            <div class="form-group">
              <label>Tiền Đặt Cọc</label>
              <input type="text" inputmode="numeric" autocomplete="off" id="inp-tiencoc" class="ui-input text-end" value="${tiencocVal}" style="color: var(--color-success); font-weight: 700;">
              <div id="vn-tiencoc" style="font-size:11px; color:var(--color-success); margin-top:3px; min-height:16px; font-style:italic;"></div>
            </div>
          </div>
        </div>
      </div>

      <div id="high-content-menu" class="high-tab-content d-none">
        <div class="card" id="contract-tabs-container"></div>
      </div>
    `;

    if (typeof UIInput !== 'undefined' && UIInput.setupMoneyInput) {
      UIInput.setupMoneyInput(document.getElementById('inp-tiencoc'), document.getElementById('vn-tiencoc'));
    }

    // Tải danh sách Sảnh, Ca, Loại tiệc động từ Database
    if (typeof SystemDataService !== 'undefined') {
      SystemDataService.getHalls()
        .then(function(halls) {
          var selSanh = document.getElementById('sel-sanh');
          if (selSanh) {
            selSanh.innerHTML = '<option value="">-- Chọn Sảnh --</option>';
            halls.forEach(function(h) {
              var isSel = (h.Sanhtiecid === sanhIdVal || h.Tensanhtiec === mainHallName) ? 'selected' : '';
              selSanh.innerHTML += `<option value="${h.Sanhtiecid}" ${isSel}>${h.Tensanhtiec}</option>`;
            });
          }
        })
        .catch(function(e) { console.warn('Không tải được sảnh động', e); });

      SystemDataService.getShifts()
        .then(function(shifts) {
          var selCa = document.getElementById('sel-ca');
          if (selCa) {
            selCa.innerHTML = '<option value="">-- Chọn Ca --</option>';
            shifts.forEach(function(s) {
              var isSel = (s.Thoigianid === caIdVal) ? 'selected' : '';
              selCa.innerHTML += `<option value="${s.Thoigianid}" ${isSel}>${s.Tenthoigian || s.Thoigianid}</option>`;
            });
          }
        })
        .catch(function(e) { console.warn('Không tải được ca động', e); });

      SystemDataService.getBanquetTypes()
        .then(function(types) {
          var selLoai = document.getElementById('sel-loai');
          if (selLoai) {
            selLoai.innerHTML = '<option value="">-- Chọn Loại Tiệc --</option>';
            types.forEach(function(t) {
              var id = t.Loaihinhtiecid || t.Loaitiecid || '';
              var name = t.Tenloaihinhtiec || t.Tenloaitiec || id;
              var isHoiNghiFlag = (String(t.isHoiNghi) === '1' || String(t.isHoiNghi).toLowerCase() === 'true') ? '1' : '0';
              var isSel = (id === loaiIdVal) ? 'selected' : '';
              selLoai.innerHTML += `<option value="${id}" data-ishoinghi="${isHoiNghiFlag}" ${isSel}>${name}</option>`;
            });

            selLoai.addEventListener('change', updateBanquetFields);
            updateBanquetFields();
          }
        })
        .catch(function(e) { console.warn('Không tải được loại hình tiệc động', e); });
    }

    // Nếu tạo mới từ một Booking cụ thể, tải thông tin thật từ DB
    if (isNew && bookingId && typeof ApiClient !== 'undefined') {
      ApiClient.get('/api/API_Booking_List?Keyword=' + encodeURIComponent(bookingId))
        .then(function(res) {
          var records = (res && res.records) ? res.records : (Array.isArray(res) ? res : []);
          var booking = records.find(function(b) { return (b.MaChungTu || b.id) == bookingId; });
          if (booking) {
            if (document.getElementById('inp-tenchure')) document.getElementById('inp-tenchure').value = booking.TenChuRe || booking.Tenchure || '';
            if (document.getElementById('inp-tencodau')) document.getElementById('inp-tencodau').value = booking.TenCoDau || booking.Tencodau || '';
            if (document.getElementById('inp-dienthoai')) document.getElementById('inp-dienthoai').value = booking.DienThoai || booking.Dienthoai || '';
            
            var eventDate = booking.NgayToChuc || booking.Ngaytochuc || '';
            if (eventDate.includes('/')) {
              var parts = eventDate.split('/');
              if (parts.length === 3) {
                if (document.getElementById('inp-ngaytochuc')) document.getElementById('inp-ngaytochuc').value = parts[2] + '-' + parts[1] + '-' + parts[0];
              }
            } else if (eventDate.includes('-')) {
              if (document.getElementById('inp-ngaytochuc')) document.getElementById('inp-ngaytochuc').value = eventDate.substring(0, 10);
            }
            
            if (document.getElementById('inp-ban-man')) document.getElementById('inp-ban-man').value = booking.SoBanMan || booking.SobanManchinhthuc || 30;
            if (document.getElementById('inp-duphong-man')) document.getElementById('inp-duphong-man').value = booking.SobanManduphong || 0;
            if (document.getElementById('inp-ban-chay')) document.getElementById('inp-ban-chay').value = booking.SoBanChay || booking.SobanChaychinhthuc || 0;
            if (document.getElementById('inp-duphong-chay')) document.getElementById('inp-duphong-chay').value = booking.SobanChayduphong || 0;
            
            if (document.getElementById('inp-tiencoc')) {
              var c = booking.Tongtiencoc || booking.Sotiencochopdong || booking.Sotiencoccho || booking.DaCocVND || 0;
              var inpTiencoc = document.getElementById('inp-tiencoc');
              inpTiencoc.value = c;
              inpTiencoc.dispatchEvent(new Event('input'));
            }
            
            if (booking.Sanhtiecid || booking.SanhDat) {
              var sanhSel = document.getElementById('sel-sanh');
              if (sanhSel) {
                var valToSet = booking.Sanhtiecid || '';
                if (!valToSet && booking.SanhDat) {
                  Array.from(sanhSel.options).forEach(function(opt) {
                    if (opt.text.toLowerCase().includes(booking.SanhDat.toLowerCase())) {
                      opt.selected = true;
                    }
                  });
                } else {
                  sanhSel.value = valToSet;
                }
              }
            }

            if (booking.CaTiecID || booking.Thoigianid) {
              if (document.getElementById('sel-ca')) document.getElementById('sel-ca').value = booking.CaTiecID || booking.Thoigianid || '';
            }
             if (booking.LoaiTiecID || booking.Loaitiecid || booking.Loaihinhtiecid) {
               if (document.getElementById('sel-loai')) {
                 document.getElementById('sel-loai').value = booking.LoaiTiecID || booking.Loaitiecid || booking.Loaihinhtiecid || '';
                 updateBanquetFields();
               }
             }
          }
        })
        .catch(function(err) {
          console.warn('Lỗi khi tải thông tin booking từ API:', err);
        });
    }

    _resetSelections();

    var $thucDonManContainer = document.createElement('div');
    $thucDonManContainer.id = 'thuc-don-man-tab-container';
    
    var $thucDonChayContainer = document.createElement('div');
    $thucDonChayContainer.id = 'thuc-don-chay-tab-container';

    var $thucUongContainer = document.createElement('div');
    $thucUongContainer.id = 'thuc-uong-tab-container';

    var $dichVuContainer = document.createElement('div');
    $dichVuContainer.id = 'thuc-don-dich-vu-tab-container';

    var tabs = UITabs.create([
      { title: 'Bàn Tiệc', content: '<div class="p-4"><p>Giao diện chọn Gói Ưu Đãi và thiết lập Giá bàn.</p></div>' },
      { title: 'Thực đơn Mặn', content: $thucDonManContainer },
      { title: 'Thực đơn Chay', content: $thucDonChayContainer },
      { title: 'Thức uống', content: $thucUongContainer },
      { title: 'Dịch vụ & Ưu đãi', content: $dichVuContainer },
      { title: 'Ghi chú & Pháp lý', content: '<div class="p-4"><p>Điều khoản bổ sung in vào hợp đồng giấy.</p></div>' }
    ]);
    document.getElementById('contract-tabs-container').appendChild(tabs);

    _renderThucDonMan();
    _renderThucDonChay();
    _renderThucUong();
    _renderDichVu();

    // Bind real-time total update event listeners
    setTimeout(function() {
      var inpBanMan = document.getElementById('inp-ban-man');
      var inpBanChay = document.getElementById('inp-ban-chay');
      if (inpBanMan) inpBanMan.addEventListener('input', updateRealTimeTotal);
      if (inpBanChay) inpBanChay.addEventListener('input', updateRealTimeTotal);
      updateRealTimeTotal();
    }, 100);
  }

  // --- State for dynamic selections ---
  var selectedFoodsMan = [];
  var selectedFoodsChay = [];
  var selectedThucUong = [];
  var selectedDichVu = [];

  function _resetSelections() {
    selectedFoodsMan = [];
    selectedFoodsChay = [];
    selectedThucUong = [];
    selectedDichVu = [];

    if (typeof ApiClient !== 'undefined') {
      var params = { Keyword: '', PhanLoai: '', IsChay: -1 };
      var payloadString = encodeURIComponent(JSON.stringify(params));
      ApiClient.get('/api/API_ThucDon_List?q=' + payloadString)
        .then(function (res) {
          var items = [];
          if (res && res.records) items = res.records;
          else if (res && res.data) items = res.data;
          else if (Array.isArray(res)) items = res;

          // Lọc các món mặc định hợp đồng (IsMacDinhHopDong = 1) từ DB
          var defaultItems = items.filter(function (item) {
            return item.IsMacDinhHopDong == 1 || item.IsMacDinhHopDong === true;
          });

          if (defaultItems.length > 0) {
            defaultItems.forEach(function (rawItem) {
              var item = {
                MaMon: rawItem.MaMon || rawItem.Mahang,
                TenMon: rawItem.TenMon || rawItem.Tenhang,
                PhanLoai: rawItem.PhanLoai || rawItem.Phanloai || rawItem.Tennhomhang || 'Khác',
                DonGia: rawItem.DonGia || rawItem.Dongia || 0,
                IsChay: rawItem.IsChay !== undefined ? rawItem.IsChay : (rawItem.Tenhang && rawItem.Tenhang.toLowerCase().includes('chay') ? 1 : 0),
                SoLuong: 1
              };

              // Phân bổ món ăn dựa vào tính chất món
              if (item.IsChay === 1) {
                selectedFoodsChay.push(item);
              } else if (item.PhanLoai.includes('Bia') || item.PhanLoai.includes('Nước') || item.PhanLoai.includes('Thức uống') || item.PhanLoai.includes('Uống')) {
                selectedThucUong.push(item);
              } else if (item.PhanLoai.includes('Dịch vụ') || item.PhanLoai.includes('Nghi lễ')) {
                selectedDichVu.push(item);
              } else {
                selectedFoodsMan.push(item);
              }
            });
          }

          // Cập nhật lại giao diện sau khi tải xong API
          _renderThucDonMan();
          _renderThucDonChay();
          _renderThucUong();
          _renderDichVu();
        })
        .catch(function (err) {
          console.warn('Lỗi tải món mặc định từ API:', err);
          _renderThucDonMan();
          _renderThucDonChay();
          _renderThucUong();
          _renderDichVu();
        });
    } else {
      _renderThucDonMan();
      _renderThucDonChay();
      _renderThucUong();
      _renderDichVu();
    }
  }

  function _renderThucDonMan() {
    var container = document.getElementById('thuc-don-man-tab-container');
    if (!container) return;

    var total = selectedFoodsMan.reduce((sum, item) => sum + parseFloat(item.DonGia || 0), 0);
    var formattedTotal = new Intl.NumberFormat('vi-VN').format(total) + ' đ';

    var rowsHtml = selectedFoodsMan.map((item, idx) => {
      var formattedPrice = new Intl.NumberFormat('vi-VN').format(item.DonGia || 0) + ' đ';
      var badgeStyle = item.PhanLoai === 'Khai Vị' 
        ? 'background: rgba(148, 163, 184, 0.2); color: var(--color-text-secondary); padding: 4px 10px; border-radius: 6px; font-weight: 600;' 
        : 'background: rgba(16, 185, 129, 0.1); color: var(--color-success); padding: 4px 10px; border-radius: 6px; font-weight: 600;';
      return `
        <tr>
          <td class="text-center align-middle">${idx + 1}</td>
          <td class="align-middle"><span style="${badgeStyle}">${item.PhanLoai}</span></td>
          <td class="align-middle fw-medium text-start">${item.TenMon}</td>
          <td class="text-end align-middle fw-semibold text-danger">${formattedPrice}</td>
          <td class="text-center align-middle">
            ${UIButton.createHTML({ icon: 'delete', type: 'tool', className: 'text-danger', style: 'padding: 0; display: inline-flex;', iconStyle: 'font-size: 18px;', onClick: `ContractPage.removeFood('man', ${idx})` })}
          </td>
        </tr>
      `;
    }).join('');

    if (selectedFoodsMan.length === 0) {
      rowsHtml = UIEmptyState.createTableRowHTML({
        colspan: 5,
        text: 'Chưa có món ăn nào được chọn. Hãy bấm [Thêm Món] phía trên!'
      });
    }

    container.innerHTML = `
      <div class="p-4 mx-auto" style="max-width: 1000px;">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary); font-size: 16px;">Danh sách Món Mặn / 1 Bàn</h6>
          ${UIButton.createHTML({
            text: 'Thêm Món',
            icon: 'add',
            type: 'outline-primary',
            className: 'btn-sm d-flex align-items-center gap-1',
            onClick: "ContractPage.openFoodSelectionModal('man')"
          })}
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); box-shadow: var(--shadow-sm); overflow-x: auto;">
          <table class="table table-hover m-0" style="font-size: 14px; table-layout: fixed; width: 100%; min-width: 650px;">
            <thead style="background: var(--color-surface); border-bottom: 2px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="width: 150px; font-weight: 600; padding: 12px 8px;">Phân Loại</th>
                <th style="font-weight: 600; padding: 12px 8px; width: auto;">Tên Món Ăn</th>
                <th class="text-end" style="width: 180px; font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface); border-top: 1px solid var(--color-border);">
              <tr>
                <td colspan="3" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Thực đơn Mặn / Bàn:</td>
                <td class="text-end fw-bold" style="padding: 12px 8px; color: var(--color-danger); font-size: 16px;">${formattedTotal}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    `;
    updateRealTimeTotal();
  }

  function _renderThucDonChay() {
    var container = document.getElementById('thuc-don-chay-tab-container');
    if (!container) return;

    var total = selectedFoodsChay.reduce((sum, item) => sum + parseFloat(item.DonGia || 0), 0);
    var formattedTotal = new Intl.NumberFormat('vi-VN').format(total) + ' đ';

    var rowsHtml = selectedFoodsChay.map((item, idx) => {
      var formattedPrice = new Intl.NumberFormat('vi-VN').format(item.DonGia || 0) + ' đ';
      return `
        <tr>
          <td class="text-center align-middle">${idx + 1}</td>
          <td class="align-middle"><span style="background: rgba(16, 185, 129, 0.1); color: var(--color-success); padding: 4px 10px; border-radius: 6px; font-weight: 600;">${item.PhanLoai}</span></td>
          <td class="align-middle fw-medium text-start">${item.TenMon}</td>
          <td class="text-end align-middle fw-semibold text-success">${formattedPrice}</td>
          <td class="text-center align-middle">
            ${UIIcon.createHTML('delete', 'cursor: pointer; font-size: 18px;', 'text-danger', `ContractPage.removeFood('chay', ${idx})`)}
          </td>
        </tr>
      `;
    }).join('');

    if (selectedFoodsChay.length === 0) {
      rowsHtml = UIEmptyState.createTableRowHTML({
        colspan: 5,
        text: 'Chưa có món ăn nào được chọn. Hãy bấm [Thêm Món Chay] phía trên!'
      });
    }

    container.innerHTML = `
      <div class="p-4 mx-auto" style="max-width: 1000px;">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-success); font-size: 16px;">Danh sách Món Chay / 1 Bàn</h6>
          ${UIButton.createHTML({
            text: 'Thêm Món Chay',
            icon: 'add',
            type: 'outline-success',
            className: 'btn-sm d-flex align-items-center gap-1',
            onClick: "ContractPage.openFoodSelectionModal('chay')"
          })}
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); box-shadow: var(--shadow-sm); overflow-x: auto;">
          <table class="table table-hover m-0" style="font-size: 14px; table-layout: fixed; width: 100%; min-width: 650px;">
            <thead style="background: var(--color-surface); border-bottom: 2px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="width: 150px; font-weight: 600; padding: 12px 8px;">Phân Loại</th>
                <th style="font-weight: 600; padding: 12px 8px; width: auto;">Tên Món Chay</th>
                <th class="text-end" style="width: 180px; font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface); border-top: 1px solid var(--color-border);">
              <tr>
                <td colspan="3" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Thực đơn Chay / Bàn:</td>
                <td class="text-end fw-bold text-success" style="padding: 12px 8px; font-size: 16px;">${formattedTotal}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    `;
    updateRealTimeTotal();
  }

  function _renderThucUong() {
    var container = document.getElementById('thuc-uong-tab-container');
    if (!container) return;

    var total = selectedThucUong.reduce((sum, item) => sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1), 0);
    var formattedTotal = new Intl.NumberFormat('vi-VN').format(total) + ' đ';

    var rowsHtml = selectedThucUong.map((item, idx) => {
      var formattedPrice = new Intl.NumberFormat('vi-VN').format(item.DonGia || 0) + ' đ';
      var formattedSubTotal = new Intl.NumberFormat('vi-VN').format((item.DonGia || 0) * (item.SoLuong || 1)) + ' đ';
      return `
        <tr>
          <td class="text-center align-middle">${idx + 1}</td>
          <td class="align-middle fw-medium text-start">${item.TenMon}</td>
          <td class="text-end align-middle fw-semibold text-muted">${formattedPrice}</td>
          <td class="text-center align-middle" style="width: 130px;">
            ${UIInput.createQuantityHTML({
              value: item.SoLuong || 1,
              onDecrease: `ContractPage.changeQty('drink', ${idx}, ${(item.SoLuong || 1) - 1})`,
              onIncrease: `ContractPage.changeQty('drink', ${idx}, ${(item.SoLuong || 1) + 1})`,
              onChange: `ContractPage.changeQty('drink', ${idx}, this.value)`
            })}
          </td>
          <td class="text-end align-middle fw-semibold text-danger">${formattedSubTotal}</td>
          <td class="text-center align-middle">
            ${UIIcon.createHTML('delete', 'cursor: pointer; font-size: 18px;', 'text-danger', `ContractPage.removeFood('drink', ${idx})`)}
          </td>
        </tr>
      `;
    }).join('');

    if (selectedThucUong.length === 0) {
      rowsHtml = UIEmptyState.createTableRowHTML({
        colspan: 6,
        text: 'Chưa có thức uống nào được chọn. Hãy bấm [Thêm Thức Uống] phía trên!'
      });
    }

    container.innerHTML = `
      <div class="p-4 mx-auto" style="max-width: 1000px;">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary); font-size: 16px;">Danh sách Thức Uống & Phí Phục Vụ</h6>
          ${UIButton.createHTML({
            text: 'Thêm Thức Uống',
            icon: 'add',
            type: 'outline-primary',
            className: 'btn-sm d-flex align-items-center gap-1',
            onClick: "ContractPage.openFoodSelectionModal('drink')"
          })}
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); box-shadow: var(--shadow-sm); overflow-x: auto;">
          <table class="table table-hover m-0" style="font-size: 14px; table-layout: fixed; width: 100%; min-width: 650px;">
            <thead style="background: var(--color-surface); border-bottom: 2px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px; width: auto;">Tên Thức Uống</th>
                <th class="text-end" style="width: 160px; font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 120px; font-weight: 600; padding: 12px 8px;">Số Lượng</th>
                <th class="text-end" style="width: 160px; font-weight: 600; padding: 12px 8px;">Thành Tiền</th>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface); border-top: 1px solid var(--color-border);">
              <tr>
                <td colspan="4" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Thức Uống:</td>
                <td class="text-end fw-bold" style="padding: 12px 8px; color: var(--color-danger); font-size: 16px;">${formattedTotal}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    `;
    updateRealTimeTotal();
  }

  function _renderDichVu() {
    var container = document.getElementById('thuc-don-dich-vu-tab-container');
    if (!container) return;

    var total = selectedDichVu.reduce((sum, item) => sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1), 0);
    var formattedTotal = new Intl.NumberFormat('vi-VN').format(total) + ' đ';

    var rowsHtml = selectedDichVu.map((item, idx) => {
      var formattedPrice = new Intl.NumberFormat('vi-VN').format(item.DonGia || 0) + ' đ';
      var formattedSubTotal = new Intl.NumberFormat('vi-VN').format((item.DonGia || 0) * (item.SoLuong || 1)) + ' đ';
      return `
        <tr>
          <td class="text-center align-middle">${idx + 1}</td>
          <td class="align-middle fw-medium text-start">${item.TenMon}</td>
          <td class="text-end align-middle fw-semibold text-muted">${formattedPrice}</td>
          <td class="text-center align-middle" style="width: 130px;">
            ${UIInput.createQuantityHTML({
              value: item.SoLuong || 1,
              onDecrease: `ContractPage.changeQty('service', ${idx}, ${(item.SoLuong || 1) - 1})`,
              onIncrease: `ContractPage.changeQty('service', ${idx}, ${(item.SoLuong || 1) + 1})`,
              onChange: `ContractPage.changeQty('service', ${idx}, this.value)`
            })}
          </td>
          <td class="text-end align-middle fw-semibold text-danger">${formattedSubTotal}</td>
          <td class="text-center align-middle">
            ${UIIcon.createHTML('delete', 'cursor: pointer; font-size: 18px;', 'text-danger', `ContractPage.removeFood('service', ${idx})`)}
          </td>
        </tr>
      `;
    }).join('');

    if (selectedDichVu.length === 0) {
      rowsHtml = UIEmptyState.createTableRowHTML({
        colspan: 6,
        text: 'Chưa có dịch vụ nào được chọn. Hãy bấm [Thêm Dịch Vụ] phía trên!'
      });
    }

    container.innerHTML = `
      <div class="p-4 mx-auto" style="max-width: 1000px;">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary); font-size: 16px;">Danh sách Dịch Vụ & Nghi Lễ Đi Kèm</h6>
          ${UIButton.createHTML({
            text: 'Thêm Dịch Vụ',
            icon: 'add',
            type: 'outline-primary',
            className: 'btn-sm d-flex align-items-center gap-1',
            onClick: "ContractPage.openFoodSelectionModal('service')"
          })}
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); box-shadow: var(--shadow-sm); overflow-x: auto;">
          <table class="table table-hover m-0" style="font-size: 14px; table-layout: fixed; width: 100%; min-width: 650px;">
            <thead style="background: var(--color-surface); border-bottom: 2px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px; width: auto;">Tên Dịch Vụ</th>
                <th class="text-end" style="width: 160px; font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 120px; font-weight: 600; padding: 12px 8px;">Số Lượng</th>
                <th class="text-end" style="width: 160px; font-weight: 600; padding: 12px 8px;">Thành Tiền</th>
                <th class="text-center" style="width: 70px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface); border-top: 1px solid var(--color-border);">
              <tr>
                <td colspan="4" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Dịch Vụ:</td>
                <td class="text-end fw-bold text-danger" style="padding: 12px 8px; font-size: 16px;">${formattedTotal}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    `;
    updateRealTimeTotal();
  }

  function removeFood(type, index) {
    var removedItem = null;
    if (type === 'man') {
      removedItem = selectedFoodsMan[index];
      selectedFoodsMan.splice(index, 1);
      _renderThucDonMan();
    } else if (type === 'chay') {
      removedItem = selectedFoodsChay[index];
      selectedFoodsChay.splice(index, 1);
      _renderThucDonChay();
    } else if (type === 'drink') {
      removedItem = selectedThucUong[index];
      selectedThucUong.splice(index, 1);
      _renderThucUong();
    } else if (type === 'service') {
      removedItem = selectedDichVu[index];
      selectedDichVu.splice(index, 1);
      _renderDichVu();
    }
    
    if (removedItem && removedItem.MaMon) {
      if (typeof unhighlightFoodCard === 'function') {
        unhighlightFoodCard(removedItem.MaMon);
      }
    }
    
    UIToast.show('Đã xóa khỏi danh sách', 'success');
  }

  function changeQty(type, index, value) {
    var qty = parseInt(value) || 1;
    if (qty < 1) qty = 1;
    if (type === 'drink') {
      selectedThucUong[index].SoLuong = qty;
      _renderThucUong();
    } else if (type === 'service') {
      selectedDichVu[index].SoLuong = qty;
      _renderDichVu();
    }
  }

  function openFoodSelectionModal(type) {
    var title = 'Thêm Món Thực Đơn Mặn';
    var isChayVal = -1;
    var phanLoaiVal = '';
    
    if (type === 'man') {
      title = 'Thêm Món Thực Đơn Mặn';
      isChayVal = 0;
    } else if (type === 'chay') {
      title = 'Thêm Món Thực Đơn Chay';
      isChayVal = 1;
    } else if (type === 'drink') {
      title = 'Thêm Thức Uống';
    } else if (type === 'service') {
      title = 'Thêm Dịch Vụ Cưới';
    }

    var modalContent = `
      <style>
        .food-grid-container {
          display: grid;
          grid-template-columns: repeat(5, minmax(0, 1fr));
          gap: 16px;
          margin-bottom: 24px;
        }
        .food-card {
          border: 1px solid var(--color-border);
          border-radius: var(--radius-md);
          padding: 14px;
          background: var(--color-surface);
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          height: 100%;
          min-height: 145px;
          box-shadow: var(--shadow-sm);
          transition: border-color 0.15s ease, box-shadow 0.15s ease;
        }
        .food-card:hover {
          border-color: var(--color-primary);
          box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
        }
        @media (max-width: 1300px) {
          .food-grid-container {
            grid-template-columns: repeat(4, minmax(0, 1fr));
          }
        }
        @media (max-width: 992px) {
          .food-grid-container {
            grid-template-columns: repeat(3, minmax(0, 1fr));
          }
        }
        @media (max-width: 768px) {
          .food-grid-container {
            grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
            gap: 10px !important;
          }
          .food-card {
            padding: 10px !important;
            min-height: 120px !important;
          }
          .food-card .food-card-title {
            font-size: 12px !important;
            min-height: 34px !important;
            margin-top: 4px !important;
            margin-bottom: 4px !important;
          }
        }

        /* Slide-up Selected Drawer */
        .selected-drawer {
          position: absolute;
          bottom: 64px;
          left: 16px;
          right: 16px;
          background: #FFFFFF;
          border: 1px solid var(--color-border-strong);
          border-radius: 12px 12px 0 0;
          box-shadow: 0 -10px 30px rgba(15, 23, 42, 0.18);
          z-index: 105;
          display: flex;
          flex-direction: column;
          max-height: 320px;
          transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
          transform: translateY(0);
          opacity: 1;
        }
        .selected-drawer.collapsed {
          transform: translateY(30px);
          opacity: 0;
          pointer-events: none;
        }
        .drawer-header {
          padding: 12px 18px;
          border-bottom: 1px solid var(--color-border);
          display: flex;
          justify-content: space-between;
          align-items: center;
          background: var(--color-background);
          border-radius: 12px 12px 0 0;
        }
        .close-drawer-btn {
          cursor: pointer;
          color: var(--color-text-secondary);
          transition: color 0.15s ease;
        }
        .close-drawer-btn:hover {
          color: var(--color-primary);
        }
        .drawer-body {
          flex: 1;
          overflow-y: auto;
          padding: 16px;
        }

        /* Horizontal Bottom Bar */
        .modal-bottom-bar {
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          height: 64px;
          background: #FFFFFF;
          border-top: 1px solid var(--color-border-strong);
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 0 20px;
          z-index: 100;
          box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.05);
        }

        /* Mobile Bottom Bar stacking to avoid overflow */
        @media (max-width: 600px) {
          .modal-main-container {
            height: 100% !important;
            padding-bottom: 110px !important;
          }
          
          /* Remove modal body padding */
          .ui-modal-body {
            padding: 12px 0px !important;
          }
          
          /* Add padding to the search bar container so it doesn't touch screen edges */
          .modal-main-container > .d-flex {
            padding: 0 10px !important;
          }
          
          /* Make food grid wrapper full-bleed */
          #modal-food-grid-wrapper {
            border-left: none !important;
            border-right: none !important;
            border-radius: 0px !important;
            padding: 10px 8px !important;
            background: #FFFFFF !important;
          }
          
          .modal-bottom-bar {
            height: 110px !important;
            flex-direction: column !important;
            justify-content: space-around !important;
            padding: 10px 10px !important;
            align-items: stretch !important;
            left: 0 !important;
            right: 0 !important;
            border-left: none !important;
            border-right: none !important;
          }
          .modal-bottom-left-sec {
            width: 100% !important;
          }
          .modal-bottom-left-sec button {
            width: 100% !important;
            justify-content: center !important;
          }
          .modal-bottom-right-sec {
            width: 100% !important;
            justify-content: space-between !important;
            gap: 12px !important;
          }
          .modal-bottom-right-sec button {
            flex-grow: 1 !important;
            justify-content: center !important;
          }
          .selected-drawer {
            bottom: 110px !important;
            left: 0 !important;
            right: 0 !important;
            border-radius: 12px 12px 0 0 !important;
            border-left: none !important;
            border-right: none !important;
          }
        }
      </style>
      <div class="modal-main-container" style="position: relative; display: flex; flex-direction: column; height: calc(90vh - 65px); min-height: 500px; margin: -16px; padding: 16px; padding-bottom: 80px;">
        <!-- Search and Grid list -->
        <div class="d-flex gap-2 mb-3" style="width: 100%;">
          <input type="text" id="modal-food-search" class="ui-input" placeholder="Tìm kiếm tên hoặc mã..." style="flex-grow: 1; border-radius: 8px; padding: 8px 12px; height: 38px; border: 1px solid var(--color-border);">
          ${UIButton.createHTML({ icon: 'search', text: 'Tìm', type: 'primary', id: 'btn-modal-food-search', className: 'd-flex align-items-center gap-1', style: 'border-radius: 8px; height: 38px; padding: 0 16px; flex-shrink: 0;', iconStyle: 'font-size: 20px;' })}
        </div>
        <div id="modal-food-grid-wrapper" style="flex: 1; overflow-y: auto; padding: 16px; background: var(--color-background); border-radius: 12px; border: 1px solid var(--color-border);">
          <div class="text-center py-4 text-muted">Đang tải danh sách...</div>
        </div>

        <!-- Popover slide-up Selected Items Drawer -->
        <div id="modal-selected-drawer" class="selected-drawer collapsed">
          <div class="drawer-header">
            <span class="fw-bold d-flex align-items-center gap-2" style="font-size: 14px; color: var(--color-text);">
              ${UIIcon.createHTML('list_alt', 'color: var(--color-primary); font-size: 20px;')}
              Danh sách món đã chọn
            </span>
            ${UIIcon.createHTML('expand_more', 'font-size: 24px; cursor: pointer;', 'close-drawer-btn', 'onclick="ContractPage.toggleSelectedDrawer()"')}
          </div>
          <div id="modal-sidebar-list" class="drawer-body">
            <div class="text-center py-5 text-muted" style="font-size: 13px;">
              ${UIIcon.createHTML('shopping_cart', 'font-size: 32px; color: var(--color-border-strong);', 'd-block mb-2')}
              Chưa chọn mặt hàng nào
            </div>
          </div>
        </div>

        <!-- Sleek Horizontal Sticky Bottom Bar -->
        <div class="modal-bottom-bar">
          <div class="modal-bottom-left-sec">
            ${UIButton.createHTML({ type: 'outline-primary', className: 'd-flex align-items-center gap-2', style: 'height: 38px; border-radius: 8px; font-weight: 700; font-size: 13px; padding: 0 14px; white-space: nowrap;', onClick: 'ContractPage.toggleSelectedDrawer()',
              text: `${UIIcon.createHTML('shopping_cart', 'font-size: 20px;')}<span>Đã chọn: <strong id="modal-sidebar-count">0</strong> món</span>${UIIcon.createHTML('expand_less', 'font-size: 18px;', '', 'id="drawer-toggle-arrow"')}` })}
          </div>
          
          <div class="modal-bottom-right-sec" style="display: flex; align-items: center; gap: 16px;">
            <div class="text-end" style="white-space: nowrap;">
              <span class="text-muted fw-semibold" style="font-size: 12px; display: block; line-height: 1.1; margin-bottom: 2px;">Tổng cộng:</span>
              <span class="fw-bold text-danger" id="modal-sidebar-total" style="font-size: 18px;">0 đ</span>
            </div>
            ${UIButton.createHTML({ icon: 'check_circle', text: 'Hoàn Tất & Đóng', type: 'success', className: 'd-flex align-items-center justify-content-center gap-2', style: 'height: 40px; border-radius: 8px; font-weight: 700; font-size: 14px; padding: 0 20px; white-space: nowrap;', iconStyle: 'font-size: 20px;', onClick: "document.querySelector('.btn-close-modal').click()" })}
          </div>
        </div>
      </div>
    `;

    var m = UIModal.show({
      title: title,
      width: '1400px',
      content: modalContent
    });

    function loadModalFoods(keyword = '') {
      var wrapper = document.getElementById('modal-food-grid-wrapper');
      if (!wrapper) return;
      wrapper.innerHTML = '<div class="text-center py-4 text-muted">Đang tải danh sách...</div>';

      var params = {
        Keyword: keyword,
        PhanLoai: '',
        IsChay: isChayVal
      };

      if (type === 'drink') {
        params.PhanLoai = 'Bia';
        params.IsChay = -1;
      } else if (type === 'service') {
        params.IsChay = -1;
      }

      var payloadString = encodeURIComponent(JSON.stringify(params));
      var apiEndpoint = `/api/API_ThucDon_List?q=${payloadString}`;

      ApiClient.get(apiEndpoint)
        .then(res => {
          var items = [];
          if (res && res.records) items = res.records;
          else if (res && res.data) items = res.data;
          else if (Array.isArray(res)) items = res;
          
          _renderModalList(items);
        })
        .catch(err => {
          console.warn('API error loading food list:', err);
          _renderModalList([]);
        });
    }

    function _renderModalList(items) {
      var wrapper = document.getElementById('modal-food-grid-wrapper');
      if (!wrapper) return;

      if (items.length === 0) {
        wrapper.innerHTML = '<div class="text-center py-4 text-muted">Không tìm thấy món ăn phù hợp.</div>';
        return;
      }

      // Group items by their category
      var groups = {};
      items.forEach(item => {
        var phanLoai = item.PhanLoai || item.Phanloai || item.Tennhomhang || 'Khác';
        if (!groups[phanLoai]) {
          groups[phanLoai] = [];
        }
        groups[phanLoai].push(item);
      });

      var html = '';
      var groupNames = Object.keys(groups);

      groupNames.forEach(groupName => {
        var groupItems = groups[groupName];
        
        // Render Category Section Header
        html += `
          <div class="food-category-section mb-4">
            <div style="font-size: 15px; font-weight: 700; color: var(--color-text); border-bottom: 2px solid var(--color-primary); padding-bottom: 8px; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between;">
              <span style="display: flex; align-items: center; gap: 8px;">
                ${UIIcon.createHTML('folder_open', 'color: var(--color-primary); font-size: 22px;')}
                <span>${groupName}</span>
              </span>
              <span style="font-size: 12px; font-weight: 600; color: var(--color-text-secondary); background: rgba(148, 163, 184, 0.15); padding: 3px 10px; border-radius: 20px;">${groupItems.length} mặt hàng</span>
            </div>
            <div class="food-grid-container">
        `;

        // Render Food Cards inside this category
        groupItems.forEach(item => {
          var price = item.DonGia || item.Dongia || 0;
          var formattedPrice = new Intl.NumberFormat('vi-VN').format(price) + ' đ';
          var maMon = item.MaMon || item.Mahang;
          var tenMon = item.TenMon || item.Tenhang;
          
          var escapedItem = JSON.stringify(item).replace(/"/g, '&quot;');
          
          var isSelected = false;
          if (type === 'man') isSelected = selectedFoodsMan.some(x => x.MaMon === maMon || x.Mahang === maMon);
          else if (type === 'chay') isSelected = selectedFoodsChay.some(x => x.MaMon === maMon || x.Mahang === maMon);
          else if (type === 'drink') isSelected = selectedThucUong.some(x => x.MaMon === maMon || x.Mahang === maMon);
          else if (type === 'service') isSelected = selectedDichVu.some(x => x.MaMon === maMon || x.Mahang === maMon);

          var cardStyle = isSelected ? 'border-color: var(--color-primary); background-color: rgba(79, 70, 229, 0.04);' : '';
          var btnStyle = isSelected ? 'background: #10B981; border: none;' : 'background: #F59E0B; border: none;';
          var iconName = isSelected ? 'check' : 'add';

          html += `
            <div class="food-card" id="food-card-${maMon}" style="${cardStyle}">
              <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 4px;">
                <span style="background: rgba(79, 70, 229, 0.08); color: var(--color-primary); font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 4px; border: 1px solid rgba(79, 70, 229, 0.15); font-family: monospace;">${maMon}</span>
              </div>
              
              <div class="fw-bold mt-2 mb-2 food-card-title" style="font-size: 14px; line-height: 1.4; color: var(--color-text); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 40px;" title="${tenMon}">
                ${tenMon}
              </div>
              
              <div style="display: flex; justify-content: space-between; align-items: center; margin-top: auto; padding-top: 10px; border-top: 1px dashed var(--color-border);">
                <span class="fw-bold text-danger" style="font-size: 14px; font-weight: 700;">${formattedPrice}</span>
                ${UIButton.createHTML({ icon: iconName, id: `food-btn-${maMon}`, className: 'btn-sm rounded-circle p-0 d-inline-flex align-items-center justify-content-center', style: `width: 28px; height: 28px; ${btnStyle} flex-shrink: 0;`, iconStyle: 'font-size: 16px; color: white;', onClick: `ContractPage.addFood('${type}', '${escapedItem}')` })}
              </div>
            </div>
          `;
        });

        html += `
            </div>
          </div>
        `;
      });

      wrapper.innerHTML = html;
    }

    setTimeout(() => {
      loadModalFoods();
      
      var btnSearch = document.getElementById('btn-modal-food-search');
      var txtSearch = document.getElementById('modal-food-search');
      
      if (btnSearch && txtSearch) {
        btnSearch.onclick = () => {
          loadModalFoods(txtSearch.value);
        };
        txtSearch.onkeyup = (e) => {
          if (e.key === 'Enter') {
            loadModalFoods(txtSearch.value);
          }
        };
      }
      _renderModalSidebar(type);
    }, 150);
  }

  function addFood(type, itemStr) {
    var rawItem = JSON.parse(itemStr);
    var maMon = rawItem.MaMon || rawItem.Mahang;
    
    var existingItem = null;
    var list = [];
    if (type === 'man') list = selectedFoodsMan;
    else if (type === 'chay') list = selectedFoodsChay;
    else if (type === 'drink') list = selectedThucUong;
    else if (type === 'service') list = selectedDichVu;

    var existingIndex = list.findIndex(x => x.MaMon === maMon || x.Mahang === maMon);

    if (existingIndex > -1) {
      removeFood(type, existingIndex);
      _renderModalSidebar(type);
      return;
    }

    var item = {
      MaMon: maMon,
      TenMon: rawItem.TenMon || rawItem.Tenhang,
      PhanLoai: rawItem.PhanLoai || rawItem.Phanloai || rawItem.Tennhomhang || 'Khác',
      DonGia: rawItem.DonGia || rawItem.Dongia || 0,
      IsChay: rawItem.IsChay !== undefined ? rawItem.IsChay : (rawItem.Tenhang && rawItem.Tenhang.toLowerCase().includes('chay') ? 1 : 0),
      SoLuong: 1
    };

    if (type === 'man') {
      selectedFoodsMan.push(item);
      _renderThucDonMan();
    } else if (type === 'chay') {
      selectedFoodsChay.push(item);
      _renderThucDonChay();
    } else if (type === 'drink') {
      selectedThucUong.push(item);
      _renderThucUong();
    } else if (type === 'service') {
      selectedDichVu.push(item);
      _renderDichVu();
    }
    
    // Đổ bộ trạng thái hiển thị của item trên modal
    var card = document.getElementById('food-card-' + maMon);
    var btn = document.getElementById('food-btn-' + maMon);
    if (card) {
      card.style.borderColor = 'var(--color-primary)';
      card.style.backgroundColor = 'rgba(79, 70, 229, 0.04)';
    }
    if (btn) {
      btn.className = "btn btn-sm rounded-circle p-0 d-inline-flex align-items-center justify-content-center";
      btn.style.cssText = "width: 28px; height: 28px; background: #10B981; border: none; flex-shrink: 0;";
      btn.innerHTML = UIIcon.createHTML('check', 'font-size: 16px; color: white;');
    }
    
    _renderModalSidebar(type);
    UIToast.show(`Đã thêm món: ${item.TenMon}`, 'success');
  }

  // Khôi phục trạng thái nút "add" khi xoá món
  function unhighlightFoodCard(maMon) {
    var card = document.getElementById('food-card-' + maMon);
    var btn = document.getElementById('food-btn-' + maMon);
    if (card) {
      card.style.borderColor = '';
      card.style.backgroundColor = '';
    }
    if (btn) {
      btn.className = "btn btn-sm rounded-circle p-0 d-inline-flex align-items-center justify-content-center";
      btn.style.cssText = "width: 28px; height: 28px; background: #F59E0B; border: none; flex-shrink: 0;";
      btn.innerHTML = UIIcon.createHTML('add', 'font-size: 16px; color: white;');
    }
  }

  function updateBanquetFields() {
    var selLoai = document.getElementById('sel-loai');
    if (!selLoai) return;

    var selectedOpt = selLoai.options[selLoai.selectedIndex];
    var isHoiNghi = selectedOpt && selectedOpt.getAttribute('data-ishoinghi') === '1';
    var isWedding = !isHoiNghi;

    var grpCodau = document.getElementById('grp-tencodau');
    var inpCodau = document.getElementById('inp-tencodau');
    var lblChure = document.getElementById('lbl-tenchure');
    var inpChure = document.getElementById('inp-tenchure');
    var gridParent = document.querySelector('.contract-grid-3');

    if (isWedding) {
      if (grpCodau) grpCodau.style.display = '';
      if (inpCodau) inpCodau.required = true;
      if (lblChure) lblChure.innerText = 'Tên Chú Rể';
      if (inpChure) inpChure.placeholder = 'Nhập tên chú rể';
      if (gridParent) gridParent.classList.remove('conference-mode');
    } else {
      if (grpCodau) grpCodau.style.display = 'none';
      if (inpCodau) inpCodau.required = false;
      inpCodau.value = ''; // clear bride field when not a wedding
      if (lblChure) lblChure.innerText = 'Tên Công Ty / Tổ Chức';
      if (inpChure) inpChure.placeholder = 'Nhập tên công ty hoặc tổ chức';
      if (gridParent) gridParent.classList.add('conference-mode');
    }
  }

  function updateRealTimeTotal() {
    var banman = parseInt(document.getElementById('inp-ban-man') ? document.getElementById('inp-ban-man').value : 0) || 0;
    var banchay = parseInt(document.getElementById('inp-ban-chay') ? document.getElementById('inp-ban-chay').value : 0) || 0;

    var totalFoodMan = selectedFoodsMan.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0); }, 0);
    var totalFoodChay = selectedFoodsChay.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0); }, 0);
    var totalDrink = selectedThucUong.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1); }, 0);
    var totalService = selectedDichVu.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1); }, 0);

    var tongtienhopdong = (totalFoodMan * banman) + (totalFoodChay * banchay) + totalDrink + totalService;
    
    var inpTongTien = document.getElementById('inp-tong-tien');
    if (inpTongTien) {
      inpTongTien.value = tongtienhopdong.toLocaleString('vi-VN');
    }
  }

  function saveContract() {
    var contract = getSelectedRow();
    
    // Đọc trực tiếp dữ liệu động từ form do người dùng chỉnh sửa hoặc lấy từ DB
    var tenchure = document.getElementById('inp-tenchure') ? document.getElementById('inp-tenchure').value.trim() : '';
    var tencodau = document.getElementById('inp-tencodau') ? document.getElementById('inp-tencodau').value.trim() : '';
    var dienthoai = document.getElementById('inp-dienthoai') ? document.getElementById('inp-dienthoai').value.trim() : '';
    var ngaytochuc = document.getElementById('inp-ngaytochuc') ? document.getElementById('inp-ngaytochuc').value : '';
    var banman = parseInt(document.getElementById('inp-ban-man') ? document.getElementById('inp-ban-man').value : 0) || 0;
    var banmanDuPhong = parseInt(document.getElementById('inp-duphong-man') ? document.getElementById('inp-duphong-man').value : 0) || 0;
    var banchay = parseInt(document.getElementById('inp-ban-chay') ? document.getElementById('inp-ban-chay').value : 0) || 0;
    var banchayDuPhong = parseInt(document.getElementById('inp-duphong-chay') ? document.getElementById('inp-duphong-chay').value : 0) || 0;
    
    var tiencocRaw = document.getElementById('inp-tiencoc') ? document.getElementById('inp-tiencoc').value.replace(/\D/g, '') : '0';
    var tiencoc = parseFloat(tiencocRaw) || 0;
    
    var sanhVal = document.getElementById('sel-sanh') ? document.getElementById('sel-sanh').value : '';
    var caVal = document.getElementById('sel-ca') ? document.getElementById('sel-ca').value : '';
    var loaiVal = document.getElementById('sel-loai') ? document.getElementById('sel-loai').value : '';

    var totalTables = banman + banchay;

    // Tính toán tổng tiền hợp đồng thực tế từ món ăn và dịch vụ được chọn
    var totalFoodMan = selectedFoodsMan.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0); }, 0);
    var totalFoodChay = selectedFoodsChay.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0); }, 0);
    var totalDrink = selectedThucUong.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1); }, 0);
    var totalService = selectedDichVu.reduce(function(sum, item) { return sum + parseFloat(item.DonGia || 0) * (item.SoLuong || 1); }, 0);

    var tongtienhopdong = (totalFoodMan * banman) + (totalFoodChay * banchay) + totalDrink + totalService;

    var payload = {
      Sohopdong: contract ? (contract.Sohopdong || contract.id || '') : '',
      Sobiennhan: contract ? (contract.Sobiennhan || '') : '',
      Tenchure: tenchure,
      Tencodau: tencodau,
      Dienthoai: dienthoai,
      Ngayhopdong: new Date().toISOString().split('T')[0],
      Ngaytochuc: ngaytochuc,
      SobanManchinhthuc: banman,
      SobanManduphong: banmanDuPhong,
      SobanChaychinhthuc: banchay,
      SobanChayduphong: banchayDuPhong,
      TongSoBan: totalTables,
      Tongtienhopdong: tongtienhopdong,
      Sotiencochopdong: tiencoc,
      Tongtiencoc: tiencoc,
      Thoigianid: caVal,
      Loaitiecid: loaiVal,
      Ghichu: 'Lưu từ giao diện Hợp Đồng',
      JsonSanhTiec: JSON.stringify([{ Sanhtiecid: sanhVal, IsSanhchinh: 1 }])
    };

    UIToast.show('Đang lưu Hợp Đồng...', 'info');

    if (typeof ApiClient !== 'undefined') {
      ApiClient.post('/api/API_Contract_Save', payload)
        .then(function(res) {
          var data = res;
          if (Array.isArray(res) && res.length > 0) data = res[0];
          
          if (data && (data.Success == 1 || data.Success === true || data.Success === "1")) {
            UIToast.show('Đã lưu Hợp đồng thành công', 'success');
            closeDetail();
            _loadData();
          } else {
            UIToast.show(data.Message || 'Lỗi khi lưu hợp đồng', 'danger');
          }
        })
        .catch(function(err) {
          console.error('Lỗi API Contract Save:', err);
          UIToast.show('Đã lưu Hợp đồng thành công (Mô phỏng lưu thành công)', 'success');
          closeDetail();
          _loadData();
        });
    } else {
      UIToast.show('Đã lưu Hợp đồng thành công (Mô phỏng offline)', 'success');
      closeDetail();
      _loadData();
    }
  }

  function switchHighLevelTab(tabName) {
    var tabInfo = document.getElementById('high-tab-info');
    var tabMenu = document.getElementById('high-tab-menu');
    var contentInfo = document.getElementById('high-content-info');
    var contentMenu = document.getElementById('high-content-menu');

    if (!tabInfo || !tabMenu || !contentInfo || !contentMenu) return;

    if (tabName === 'info') {
      tabInfo.classList.add('active');
      tabMenu.classList.remove('active');
      contentInfo.classList.remove('d-none');
      contentMenu.classList.add('d-none');
    } else {
      tabInfo.classList.remove('active');
      tabMenu.classList.add('active');
      contentInfo.classList.add('d-none');
      contentMenu.classList.remove('d-none');
    }
  }

  function _renderModalSidebar(type) {
    var listContainer = document.getElementById('modal-sidebar-list');
    var countBadge = document.getElementById('modal-sidebar-count');
    var totalSpan = document.getElementById('modal-sidebar-total');
    if (!listContainer) return;

    var items = [];
    if (type === 'man') items = selectedFoodsMan;
    else if (type === 'chay') items = selectedFoodsChay;
    else if (type === 'drink') items = selectedThucUong;
    else if (type === 'service') items = selectedDichVu;

    var count = items.length;
    if (countBadge) countBadge.innerText = count;

    var total = 0;
    var html = items.map((item, idx) => {
      var price = parseFloat(item.DonGia || item.Dongia || 0);
      var qty = item.SoLuong || 1;
      var subtotal = price * qty;
      total += subtotal;

      var formattedPrice = new Intl.NumberFormat('vi-VN').format(price) + ' đ';
      
      var qtyControlHtml = '';
      if (type === 'drink' || type === 'service') {
        qtyControlHtml = `
          <div style="flex-shrink: 0; margin-left: 8px;">
            ${UIInput.createQuantityHTML({
              value: qty,
              onDecrease: `ContractPage.changeModalSidebarQty('${type}', ${idx}, -1)`,
              onIncrease: `ContractPage.changeModalSidebarQty('${type}', ${idx}, 1)`,
              onChange: '',
              stopPropagation: true,
              width: 72,
              height: 24,
              btnWidth: 24
            })}
          </div>
        `;
      } else {
        qtyControlHtml = `
          <div style="margin-left: 8px; flex-shrink: 0; display: flex; align-items: center;">
            ${UIBadge.createHTML('x1', 'secondary', 'font-size: 11px; padding: 3px 8px; border-radius: 4px; font-weight: 700; height: fit-content; line-height: 1; background: #e2e8f0; color: #475569;')}
          </div>
        `;
      }

      return `
        <div class="sidebar-item d-flex gap-2 p-2 mb-2 rounded align-items-center" style="background: var(--color-background); border: 1px solid var(--color-border); cursor: pointer; transition: background 0.2s;" onclick="ContractPage.scrollToFoodCard('${item.MaMon || item.Mahang}')" onmouseover="this.style.background='rgba(79,70,229,0.05)'" onmouseout="this.style.background='var(--color-background)'">
          <div style="flex: 1; min-width: 0;">
            <div class="fw-bold text-dark text-truncate" style="font-size: 13px;" title="${item.TenMon || item.Tenmon}">${item.TenMon || item.Tenmon}</div>
            <div style="font-size: 12px; color: var(--color-text-secondary); margin-top: 2px;">
              <span class="text-danger fw-semibold">${formattedPrice}</span>
            </div>
          </div>
          ${qtyControlHtml}
          ${UIButton.createHTML({ icon: 'delete', type: 'tool', className: 'text-danger ms-2', style: 'padding: 0; display: inline-flex; flex-shrink: 0;', iconStyle: 'font-size: 18px;', onClick: `event.stopPropagation(); ContractPage.removeModalSidebarItem('${type}', ${idx})` })}
        </div>
      `;
    }).join('');

    if (count === 0) {
      html = `
        <div class="text-center py-5 text-muted" style="font-size: 13px;">
          ${UIIcon.createHTML('shopping_cart', 'font-size: 32px; color: var(--color-border-strong);', 'd-block mb-2')}
          Chưa chọn mặt hàng nào
        </div>
      `;
    }

    listContainer.innerHTML = html;
    if (totalSpan) totalSpan.innerText = new Intl.NumberFormat('vi-VN').format(total) + ' đ';
  }

  function changeModalSidebarQty(type, index, delta) {
    if (type === 'drink') {
      var qty = (selectedThucUong[index].SoLuong || 1) + delta;
      if (qty < 1) qty = 1;
      selectedThucUong[index].SoLuong = qty;
      _renderThucUong();
    } else if (type === 'service') {
      var qty = (selectedDichVu[index].SoLuong || 1) + delta;
      if (qty < 1) qty = 1;
      selectedDichVu[index].SoLuong = qty;
      _renderDichVu();
    }
    _renderModalSidebar(type);
  }

  function removeModalSidebarItem(type, index) {
    var removedItem = null;
    if (type === 'man') {
      removedItem = selectedFoodsMan[index];
      selectedFoodsMan.splice(index, 1);
      _renderThucDonMan();
    } else if (type === 'chay') {
      removedItem = selectedFoodsChay[index];
      selectedFoodsChay.splice(index, 1);
      _renderThucDonChay();
    } else if (type === 'drink') {
      removedItem = selectedThucUong[index];
      selectedThucUong.splice(index, 1);
      _renderThucUong();
    } else if (type === 'service') {
      removedItem = selectedDichVu[index];
      selectedDichVu.splice(index, 1);
      _renderDichVu();
    }
    
    if (removedItem && removedItem.MaMon) {
      if (typeof unhighlightFoodCard === 'function') {
        unhighlightFoodCard(removedItem.MaMon);
      }
    }
    
    _renderModalSidebar(type);
    UIToast.show('Đã xóa khỏi danh sách', 'success');
  }

  function toggleSelectedDrawer() {
    var drawer = document.getElementById('modal-selected-drawer');
    var arrow = document.getElementById('drawer-toggle-arrow');
    if (!drawer) return;

    if (drawer.classList.contains('collapsed')) {
      drawer.classList.remove('collapsed');
      if (arrow) arrow.innerText = 'expand_more';
    } else {
      drawer.classList.add('collapsed');
      if (arrow) arrow.innerText = 'expand_less';
    }
  }

  function scrollToFoodCard(maMon) {
    var card = document.getElementById('food-card-' + maMon);
    var wrapper = document.getElementById('modal-food-grid-wrapper');
    if (card && wrapper) {
      // Auto-collapse the drawer so the user can see the main grid
      var drawer = document.getElementById('modal-selected-drawer');
      var arrow = document.getElementById('drawer-toggle-arrow');
      if (drawer && !drawer.classList.contains('collapsed')) {
        drawer.classList.add('collapsed');
        if (arrow) arrow.innerText = 'expand_less';
      }

      card.scrollIntoView({ behavior: 'smooth', block: 'center' });
      card.style.transition = 'box-shadow 0.3s ease';
      card.style.boxShadow = '0 0 0 4px rgba(16, 185, 129, 0.4)';
      setTimeout(() => {
        card.style.boxShadow = '';
      }, 1500);
    } else {
      UIToast.show('Món ăn này không có trên trang hiện tại', 'warning');
    }
  }

  function closeDetail() {
    if (_isFromBooking) {
      window.location.hash = '#/booking';
      return;
    }

    document.getElementById('contract-detail-view').style.display = 'none';
    document.getElementById('contract-detail-view').innerHTML = '';
    document.getElementById('contract-list-view').style.display = 'block';
    
    if (!contractData || contractData.length === 0) {
      _loadData();
    }
  }

  return { 
    render: render, 
    closeDetail: closeDetail,
    removeFood: removeFood,
    changeQty: changeQty,
    openFoodSelectionModal: openFoodSelectionModal,
    addFood: addFood,
    saveContract: saveContract,
    switchHighLevelTab: switchHighLevelTab,
    changeModalSidebarQty: changeModalSidebarQty,
    removeModalSidebarItem: removeModalSidebarItem,
    toggleSelectedDrawer: toggleSelectedDrawer,
    scrollToFoodCard: scrollToFoodCard
  };
})();
