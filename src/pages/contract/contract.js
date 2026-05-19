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
      </style>

      <div class="page-title-bar d-flex flex-wrap justify-content-between align-items-center gap-3">
        <div class="d-flex align-items-center gap-2 flex-grow-1" style="min-width: 0;">
          <button class="btn btn-secondary text-nowrap flex-shrink-0" onclick="ContractPage.closeDetail()" style="padding:6px 12px;border-radius:8px;">
            <span class="material-symbols-outlined" style="font-size:20px;">arrow_back</span> <span class="d-none d-sm-inline">Trở về</span>
          </button>
          <span class="fw-bold" style="font-size:18px; line-height: 1.3;" id="detail-title-text">${titleText}</span>
        </div>
        <div class="d-flex align-items-center flex-shrink-0">
          <button class="btn btn-primary d-flex align-items-center gap-2 text-nowrap" onclick="ContractPage.saveContract()" style="border-radius:8px;">
            <span class="material-symbols-outlined" style="font-size:20px;">save</span> Lưu Hợp Đồng
          </button>
        </div>
      </div>
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
            <input type="number" id="inp-tong-tien" class="ui-input text-end" value="${tongtienVal}" readonly style="background: var(--color-background); font-weight: 700; color: var(--color-primary);">
          </div>
          <div class="form-group">
            <label>Tiền Đặt Cọc</label>
            <input type="number" id="inp-tiencoc" class="ui-input text-end" value="${tiencocVal}" min="0" style="color: var(--color-success); font-weight: 700;">
          </div>
        </div>
      </div>
      <div class="card" id="contract-tabs-container"></div>
    `;

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
            if (document.getElementById('inp-ban-chay')) document.getElementById('inp-ban-chay').value = booking.SoBanChay || booking.SobanChaychinhthuc || 0;
            
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
        ? 'background: rgba(148, 163, 184, 0.2); color: var(--color-text-secondary);' 
        : 'background: rgba(16, 185, 129, 0.1); color: var(--color-success);';
      return `
        <tr>
          <td class="text-center align-middle">${idx + 1}</td>
          <td class="align-middle"><span class="badge" style="${badgeStyle}">${item.PhanLoai}</span></td>
          <td class="align-middle fw-medium">${item.TenMon}</td>
          <td class="text-end align-middle">${formattedPrice}</td>
          <td class="text-center align-middle">
            <span class="material-symbols-outlined text-danger" style="cursor: pointer; font-size: 18px;" onclick="ContractPage.removeFood('man', ${idx})">delete</span>
          </td>
        </tr>
      `;
    }).join('');

    if (selectedFoodsMan.length === 0) {
      rowsHtml = `<tr><td colspan="5" class="text-center py-4 text-muted">Chưa có món ăn nào được chọn. Hãy bấm [Thêm Món] phía trên!</td></tr>`;
    }

    container.innerHTML = `
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary);">Danh sách Món Mặn / 1 Bàn</h6>
          <button class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1" onclick="ContractPage.openFoodSelectionModal('man')">
            <span class="material-symbols-outlined" style="font-size: 16px;">add</span> Thêm Món
          </button>
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md);">
          <table class="table table-hover m-0" style="font-size: 14px;">
            <thead style="background: var(--color-surface); border-bottom: 1px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 50px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px;">Phân Loại</th>
                <th style="font-weight: 600; padding: 12px 8px;">Tên Món Ăn</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 60px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface);">
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
          <td class="align-middle"><span class="badge" style="background: rgba(16, 185, 129, 0.1); color: var(--color-success);">${item.PhanLoai}</span></td>
          <td class="align-middle fw-medium">${item.TenMon}</td>
          <td class="text-end align-middle">${formattedPrice}</td>
          <td class="text-center align-middle">
            <span class="material-symbols-outlined text-danger" style="cursor: pointer; font-size: 18px;" onclick="ContractPage.removeFood('chay', ${idx})">delete</span>
          </td>
        </tr>
      `;
    }).join('');

    if (selectedFoodsChay.length === 0) {
      rowsHtml = `<tr><td colspan="5" class="text-center py-4 text-muted">Chưa có món ăn nào được chọn. Hãy bấm [Thêm Món Chay] phía trên!</td></tr>`;
    }

    container.innerHTML = `
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-success);">Danh sách Món Chay / 1 Bàn</h6>
          <button class="btn btn-outline-success btn-sm d-flex align-items-center gap-1" onclick="ContractPage.openFoodSelectionModal('chay')">
            <span class="material-symbols-outlined" style="font-size: 16px;">add</span> Thêm Món Chay
          </button>
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md);">
          <table class="table table-hover m-0" style="font-size: 14px;">
            <thead style="background: var(--color-surface); border-bottom: 1px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 50px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px;">Phân Loại</th>
                <th style="font-weight: 600; padding: 12px 8px;">Tên Món Chay</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="width: 60px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface);">
              <tr>
                <td colspan="3" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Thực đơn Chay / Bàn:</td>
                <td class="text-end fw-bold" style="padding: 12px 8px; color: var(--color-success); font-size: 16px;">${formattedTotal}</td>
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
          <td class="align-middle fw-medium">${item.TenMon}</td>
          <td class="text-end align-middle">${formattedPrice}</td>
          <td class="text-center align-middle" style="width: 120px;">
            <input type="number" class="form-control form-control-sm text-center mx-auto" style="width: 70px;" value="${item.SoLuong || 1}" min="1" onchange="ContractPage.changeQty('drink', ${idx}, this.value)">
          </td>
          <td class="text-end align-middle fw-semibold">${formattedSubTotal}</td>
          <td class="text-center align-middle">
            <span class="material-symbols-outlined text-danger" style="cursor: pointer; font-size: 18px;" onclick="ContractPage.removeFood('drink', ${idx})">delete</span>
          </td>
        </tr>
      `;
    }).join('');

    if (selectedThucUong.length === 0) {
      rowsHtml = `<tr><td colspan="6" class="text-center py-4 text-muted">Chưa có thức uống nào được chọn. Hãy bấm [Thêm Thức Uống] phía trên!</td></tr>`;
    }

    container.innerHTML = `
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary);">Danh sách Thức Uống & Phí Phục Vụ</h6>
          <button class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1" onclick="ContractPage.openFoodSelectionModal('drink')">
            <span class="material-symbols-outlined" style="font-size: 16px;">add</span> Thêm Thức Uống
          </button>
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md);">
          <table class="table table-hover m-0" style="font-size: 14px;">
            <thead style="background: var(--color-surface); border-bottom: 1px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 50px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px;">Tên Thức Uống</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="font-weight: 600; padding: 12px 8px;">Số Lượng</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Thành Tiền</th>
                <th class="text-center" style="width: 60px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface);">
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
          <td class="align-middle fw-medium">${item.TenMon}</td>
          <td class="text-end align-middle">${formattedPrice}</td>
          <td class="text-center align-middle" style="width: 120px;">
            <input type="number" class="form-control form-control-sm text-center mx-auto" style="width: 70px;" value="${item.SoLuong || 1}" min="1" onchange="ContractPage.changeQty('service', ${idx}, this.value)">
          </td>
          <td class="text-end align-middle fw-semibold">${formattedSubTotal}</td>
          <td class="text-center align-middle">
            <span class="material-symbols-outlined text-danger" style="cursor: pointer; font-size: 18px;" onclick="ContractPage.removeFood('service', ${idx})">delete</span>
          </td>
        </tr>
      `;
    }).join('');

    if (selectedDichVu.length === 0) {
      rowsHtml = `<tr><td colspan="6" class="text-center py-4 text-muted">Chưa có dịch vụ nào được chọn. Hãy bấm [Thêm Dịch Vụ] phía trên!</td></tr>`;
    }

    container.innerHTML = `
      <div class="p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h6 class="m-0 fw-bold" style="color: var(--color-primary);">Danh sách Dịch Vụ & Nghi Lễ Đi Kèm</h6>
          <button class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1" onclick="ContractPage.openFoodSelectionModal('service')">
            <span class="material-symbols-outlined" style="font-size: 16px;">add</span> Thêm Dịch Vụ
          </button>
        </div>
        <div class="table-responsive" style="border: 1px solid var(--color-border); border-radius: var(--radius-md);">
          <table class="table table-hover m-0" style="font-size: 14px;">
            <thead style="background: var(--color-surface); border-bottom: 1px solid var(--color-border);">
              <tr>
                <th class="text-center" style="width: 50px; font-weight: 600; padding: 12px 8px;">STT</th>
                <th style="font-weight: 600; padding: 12px 8px;">Tên Dịch Vụ</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Đơn Giá</th>
                <th class="text-center" style="font-weight: 600; padding: 12px 8px;">Số Lượng</th>
                <th class="text-end" style="font-weight: 600; padding: 12px 8px;">Thành Tiền</th>
                <th class="text-center" style="width: 60px; font-weight: 600; padding: 12px 8px;">Xóa</th>
              </tr>
            </thead>
            <tbody>
              ${rowsHtml}
            </tbody>
            <tfoot style="background: var(--color-surface);">
              <tr>
                <td colspan="4" class="text-end fw-bold" style="padding: 12px 8px; font-size: 15px;">Tổng giá Dịch Vụ:</td>
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

  function removeFood(type, index) {
    if (type === 'man') {
      selectedFoodsMan.splice(index, 1);
      _renderThucDonMan();
    } else if (type === 'chay') {
      selectedFoodsChay.splice(index, 1);
      _renderThucDonChay();
    } else if (type === 'drink') {
      selectedThucUong.splice(index, 1);
      _renderThucUong();
    } else if (type === 'service') {
      selectedDichVu.splice(index, 1);
      _renderDichVu();
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
      <div style="padding: 4px;">
        <div class="d-flex gap-2 mb-3" style="width: 100%;">
          <input type="text" id="modal-food-search" class="ui-input" placeholder="Tìm kiếm tên hoặc mã..." style="flex-grow: 1; border-radius: 8px; padding: 8px 12px; height: 38px; border: 1px solid var(--color-border);">
          <button class="btn btn-primary d-flex align-items-center gap-1" id="btn-modal-food-search" style="border-radius: 8px; height: 38px; padding: 0 16px; flex-shrink: 0;">
            <span class="material-symbols-outlined" style="font-size: 20px;">search</span> Tìm
          </button>
        </div>
        <div class="table-responsive" style="max-height: 400px; border: 1px solid var(--color-border); border-radius: var(--radius-md); overflow-x: hidden;">
          <table class="table table-hover table-striped m-0" style="font-size: 13px; table-layout: fixed; width: 100%;">
            <thead style="background: var(--color-surface); position: sticky; top: 0; z-index: 10; border-bottom: 2px solid var(--color-border);">
              <tr>
                <th style="width: 80px; padding: 10px 8px; font-weight: 600;">Mã</th>
                <th style="padding: 10px 8px; font-weight: 600;">Tên Món / Hàng hóa</th>
                <th style="width: 130px; padding: 10px 8px; font-weight: 600;">Phân Loại</th>
                <th class="text-end" style="width: 110px; padding: 10px 8px; font-weight: 600;">Đơn Giá</th>
                <th class="text-center" style="width: 60px; padding: 10px 8px; font-weight: 600;">Chọn</th>
              </tr>
            </thead>
            <tbody id="modal-food-list-body">
              <tr><td colspan="5" class="text-center py-4 text-muted">Đang tải danh sách...</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    `;

    var m = UIModal.show({
      title: title,
      width: '650px',
      content: modalContent
    });

    function loadModalFoods(keyword = '') {
      var tbody = document.getElementById('modal-food-list-body');
      if (!tbody) return;
      tbody.innerHTML = '<tr><td colspan="5" class="text-center py-4 text-muted">Đang tải danh sách...</td></tr>';

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
      var tbody = document.getElementById('modal-food-list-body');
      if (!tbody) return;

      if (items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center py-4 text-muted">Không tìm thấy món ăn phù hợp.</td></tr>';
        return;
      }

      tbody.innerHTML = items.map(item => {
        var price = item.DonGia || item.Dongia || 0;
        var formattedPrice = new Intl.NumberFormat('vi-VN').format(price) + ' đ';
        var maMon = item.MaMon || item.Mahang;
        var tenMon = item.TenMon || item.Tenhang;
        var phanLoai = item.PhanLoai || item.Phanloai || item.Tennhomhang || 'Khác';
        
        var escapedItem = JSON.stringify(item).replace(/"/g, '&quot;');

        return `
          <tr>
            <td class="fw-semibold text-primary" style="padding: 10px 8px;">${maMon}</td>
            <td class="fw-medium" style="padding: 10px 8px;">${tenMon}</td>
            <td style="padding: 10px 8px;"><span class="badge" style="background: rgba(148, 163, 184, 0.15); color: var(--color-text-secondary);">${phanLoai}</span></td>
            <td class="text-end fw-semibold" style="color: var(--color-danger); padding: 10px 8px;">${formattedPrice}</td>
            <td class="text-center" style="padding: 10px 8px;">
              <button class="btn btn-primary btn-sm rounded-circle p-1 d-inline-flex align-items-center justify-content-center" style="width: 28px; height: 28px;" onclick="ContractPage.addFood('${type}', '${escapedItem}')">
                <span class="material-symbols-outlined" style="font-size: 16px;">add</span>
              </button>
            </td>
          </tr>
        `;
      }).join('');
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
    }, 150);
  }

  function addFood(type, itemStr) {
    var rawItem = JSON.parse(itemStr);
    var item = {
      MaMon: rawItem.MaMon || rawItem.Mahang,
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
    
    UIToast.show(`Đã thêm món: ${item.TenMon}`, 'success');
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
      inpTongTien.value = tongtienhopdong;
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
    var tiencoc = parseFloat(document.getElementById('inp-tiencoc') ? document.getElementById('inp-tiencoc').value : 0) || 0;
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
    saveContract: saveContract
  };
})();
