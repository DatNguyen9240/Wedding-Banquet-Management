/**
 * Màn hình Biên nhận Cọc chỗ (Booking)
 * HTML Template: src/pages/booking.html
 */
var BookingPage = (function () {
  var $container;

  var bookingData = [
    { id: 'BNCC-260101', customerName: 'Trương Tuấn Anh & Trần Thủy Tiên', phone: '0901234567', eventDate: '15/11/2026', totalTables: 30, hall: 'Sảnh Kim Cương (Chính)', deposit: '20,000,000', status: 'Đã cọc lần 1' },
    { id: 'BNCC-260102', customerName: 'Lê Mai Hoa & Nguyễn Văn Toàn', phone: '0987654321', eventDate: '20/11/2026', totalTables: 45, hall: 'Sảnh Ngọc Trai (Chính)', deposit: '50,000,000', status: 'Đã cọc lần 2' }
  ];

  // Khai báo Object chung để quản lý bộ lọc dễ dàng dán vào các input Date/Search sau này
  var filterParams = {
    Keyword: "",
    TuNgay: "2020-01-01", // Tương lai sẽ cập nhật lấy từ Component DatePicker
    DenNgay: "2026-12-31"
  };

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/booking/booking.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _bindEvents();
        _loadData();
      });
  }

  function _loadData() {
    var tbody = $container.querySelector('#booking-table tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4" style="color: var(--color-text-secondary);">Đang tải dữ liệu...</td></tr>';

    var payloadString = encodeURIComponent(JSON.stringify(filterParams));
    var endpoint = API_CONFIG.ENDPOINTS.BOOKING.LIST + '?q=' + payloadString;

    ApiClient.get(endpoint)
      .then(function (res) {
        if (res && res.records) {
          bookingData = res.records;
        } else if (res && res.data) {
          bookingData = res.data;
        } else if (Array.isArray(res)) {
          bookingData = res;
        } else {
          bookingData = [];
        }
        _renderTable();
      })
      .catch(function (err) {
        console.error('Lỗi Load:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center text-danger py-4">Lỗi kết nối API lấy danh sách cọc!</td></tr>';
      });

    // Load Sảnh Tiệc
    if (API_CONFIG && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.SYSTEM && API_CONFIG.ENDPOINTS.SYSTEM.HALLS) {
      ApiClient.get(API_CONFIG.ENDPOINTS.SYSTEM.HALLS).then(function (halls) {
        var records = (halls && halls.records) ? halls.records : (Array.isArray(halls) ? halls : []);
        var selSanh = $container.querySelector('#sel-sanh');
        if (selSanh && records.length > 0) {
          selSanh.innerHTML = '<option value="">-- Chọn Sảnh --</option>';
          records.forEach(function (h) {
            selSanh.innerHTML += '<option value="' + h.Sanhtiecid + '">' + h.Tensanhtiec + '</option>';
          });
        }
      }).catch(e => console.warn('Không load được sảnh', e));
    }
  }

  function _formatMoney(val) {
    if (typeof val === 'string' && val.includes(',')) return val + ' đ';
    var num = parseFloat(val);
    if (isNaN(num)) return '0 đ';
    return new Intl.NumberFormat('vi-VN').format(num) + ' đ';
  }

  function _renderTable() {
    var tbody = $container.querySelector('#booking-table tbody');
    tbody.innerHTML = '';

    bookingData.forEach((row, idx) => {
      // Dùng tên trường của Backend trả về (TrangThai), dự phòng status cũ
      var currentStatus = row.TrangThai || row.status || '';
      var statusClass = currentStatus.includes('lần 1') ? 'status-badge warning' :
        currentStatus.includes('Hủy') ? 'status-badge danger' : 'status-badge success';

      var hallName = row.SanhDat || row.hall;
      var hallHtml = hallName ? hallName : '<span style="color:var(--color-text-secondary);font-style:italic;">Chưa xác định</span>';

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-semibold" style="color: var(--color-primary);">${row.MaChungTu || row.id}</td>
        <td class="fw-medium">${row.TenKhachHang || row.customerName}</td>
        <td>${row.DienThoai || row.phone}</td>
        <td><span style="background: rgba(148, 163, 184, 0.1); padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.NgayToChuc || row.eventDate}</span></td>
        <td class="text-end">${row.SoBan != null ? row.SoBan : row.totalTables} bàn</td>
        <td>${hallHtml}</td>
        <td class="text-end fw-semibold" style="color: var(--color-success);">${_formatMoney(row.DaCocVND != null ? row.DaCocVND : row.deposit)}</td>
        <td class="text-center"><span class="${statusClass}">${currentStatus}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    // Row selection logic
    var tbody = $container.querySelector('#booking-table tbody');
    tbody.addEventListener('click', function (e) {
      var tr = e.target.closest('tr');
      if (!tr) return;
      Array.from(tbody.querySelectorAll('tr')).forEach(r => r.classList.remove('active'));
      tr.classList.add('active');
    });

    $container.querySelector('#btn-add-deposit1').addEventListener('click', function () {
      openForm('add1', null);
    });

    $container.querySelector('#btn-edit-deposit').addEventListener('click', function () {
      var selected = getSelectedRow();
      if (!selected) {
        UIToast.show('Vui lòng chọn một Biên nhận cọc để sửa!', 'warning');
        return;
      }
      openForm('edit', selected);
    });

    $container.querySelector('#btn-add-deposit2').addEventListener('click', function () {
      var selected = getSelectedRow();
      if (!selected) {
        UIToast.show('Vui lòng chọn một Biên nhận cọc để bổ sung cọc lần 2!', 'warning');
        return;
      }
      openForm('add2', selected);
    });

    $container.querySelector('#btn-delete').addEventListener('click', function () {
      var selected = getSelectedRow();
      if (!selected) {
        UIToast.show('Vui lòng chọn một Biên nhận cọc để hủy!', 'warning');
        return;
      }
      var docId = selected.MaChungTu || selected.id;
      if (confirm('Bạn có chắc chắn muốn hủy phiếu cọc ' + docId + ' không?')) {
        if (API_CONFIG && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.BOOKING && API_CONFIG.ENDPOINTS.BOOKING.CANCEL) {
          var payload = { DocumentID: docId, Lydohuy: 'Khách yêu cầu hủy' };
          ApiClient.post(API_CONFIG.ENDPOINTS.BOOKING.CANCEL, payload).then(function () {
            UIToast.show('Hủy phiếu cọc thành công', 'success');
            _loadData();
          }).catch(function () { UIToast.show('Lỗi hủy phiếu', 'danger'); });
        } else {
          UIToast.show('Chưa cấu hình API CANCEL', 'warning');
        }
      }
    });

    // Form events - using the new UISidePanel component
    var bookingPanel = null;
    if (window.UISidePanel) {
      var panelEl = $container.querySelector('#booking-form-panel');
      if (panelEl) bookingPanel = new UISidePanel(panelEl);
    }

    // Customer search using integrated UI Component
    var searchContainer = $container.querySelector('#customer-search-container');
    if (searchContainer && window.UIControls && UIControls.createSearchDropdown) {
      searchContainer.appendChild(UIControls.createSearchDropdown({
        placeholder: 'SĐT / Tên...',
        width: '320px',
        requireKeyword: true,
        onSearch: function (keyword, renderResults, hideDropdown) {
          if (API_CONFIG && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.CUSTOMER && API_CONFIG.ENDPOINTS.CUSTOMER.SEARCH) {
            ApiClient.get(API_CONFIG.ENDPOINTS.CUSTOMER.SEARCH + '?Keyword=' + encodeURIComponent(keyword))
              .then(function (res) {
                var list = (res && res.records) ? res.records : (Array.isArray(res) ? res : []);
                renderResults(list);
              })
              .catch(function () {
                renderResults([]);
                if (window.UIToast) UIToast.show('Lỗi kết nối khi tìm khách hàng!', 'error');
              });
          } else {
            if (window.UIToast) UIToast.show('Đang mô phỏng tìm KH: ' + keyword, 'success');
            hideDropdown();
          }
        },
        renderItem: function (kh) {
          var tenKhach = [kh.Tenchure, kh.Tencodau].filter(Boolean).join(' & ');
          if (!tenKhach) tenKhach = kh.Tenkh || 'Chưa có tên';

          return `
            <div class="fw-bold" style="font-size: 13px; color: var(--color-text);">${tenKhach}</div>
            <div class="text-secondary mt-1" style="font-size: 12px; display: flex; gap: 8px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
              <span><span class="material-symbols-outlined" style="font-size:12px;vertical-align:middle;">call</span> ${kh.Dienthoai || '---'}</span>
              <span><span class="material-symbols-outlined" style="font-size:12px;vertical-align:middle;">pin_drop</span> ${kh.Diachi || '---'}</span>
            </div>
          `;
        },
        onSelect: function (kh) {
          var tenKhach = [kh.Tenchure, kh.Tencodau].filter(Boolean).join(' & ');
          if (!tenKhach) tenKhach = kh.Tenkh || 'Chưa có tên';

          $container.querySelector('#inp-tenchure').value = kh.Tenchure || '';
          $container.querySelector('#inp-tencodau').value = kh.Tencodau || '';
          $container.querySelector('#inp-dienthoai').value = kh.Dienthoai || '';
          $container.querySelector('#inp-email').value = kh.Mail || '';
          if (window.UIToast) UIToast.show('Đã chọn: ' + tenKhach, 'success');
        }
      }));
    }

    $container.querySelector('#btn-save-booking').addEventListener('click', function () {
      var machungtu = $container.querySelector('#inp-machungtu').value;
      if (machungtu === 'BNCC-AUTO') machungtu = null; // Null để Server tự sinh mới

      var tenchure = $container.querySelector('#inp-tenchure').value;
      var tencodau = $container.querySelector('#inp-tencodau').value;
      var phone = $container.querySelector('#inp-dienthoai').value;
      var email = $container.querySelector('#inp-email').value;
      var eventDate = $container.querySelector('#inp-ngaytochuc').value;
      var caTiec = $container.querySelector('#sel-catiec').value;
      var banMan = parseInt($container.querySelector('#inp-ban-man').value) || 0;
      var banChay = parseInt($container.querySelector('#inp-ban-chay').value) || 0;
      var sanhId = $container.querySelector('#sel-sanh').value;
      var tienCocRaw = $container.querySelector('#inp-tiencoc').value || '0';
      var tienCoc = parseFloat(tienCocRaw.replace(/,/g, ''));
      var ghiChu = $container.querySelector('#inp-ghichu').value;

      var isCocLan2 = $container.querySelector('#booking-form-title').textContent.includes('Lần 2');

      var payload = {
        DocumentID: machungtu,
        Tenchure: tenchure,
        Tencodau: tencodau,
        Dienthoai: phone,
        Mail: email,
        Ngaytochuc: eventDate,
        Thoigianid: caTiec,
        SobanManchinhthuc: banMan,
        SobanChaychinhthuc: banChay,
        Tongtien: tienCoc,
        Solan: isCocLan2 ? 2 : 1,
        Ghichu: ghiChu,
        JsonSanhTiec: sanhId ? JSON.stringify([{ Sanhtiecid: sanhId, IsSanhchinh: 1 }]) : "[]"
      };

      // Kiểm tra và sử dụng ENDPOINT từ env.js
      if (typeof API_CONFIG !== 'undefined' && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.BOOKING && API_CONFIG.ENDPOINTS.BOOKING.SAVE) {
        ApiClient.post(API_CONFIG.ENDPOINTS.BOOKING.SAVE, payload)
          .then(function (res) {
            UIToast.show('Lưu Biên nhận cọc thành công!', 'success');
            closeForm();
            _loadData(); // Tải lại danh sách sau khi lưu
          })
          .catch(function (err) {
            console.error('Lỗi lưu Cọc:', err);
            UIToast.show('Lỗi khi lưu: ' + (err.message || 'Có lỗi xảy ra'), 'danger');
          });
      } else {
        console.warn('Thiếu cấu hình API_CONFIG.ENDPOINTS.BOOKING.SAVE');
        UIToast.show('Đang mô phỏng lưu...', 'success');
        setTimeout(closeForm, 800);
      }
    });

    // Auto calculate total tables
    var inpMan = $container.querySelector('#inp-ban-man');
    var inpChay = $container.querySelector('#inp-ban-chay');
    var inpTong = $container.querySelector('#inp-tong-ban');

    function calcTotal() {
      var m = parseInt(inpMan.value) || 0;
      var c = parseInt(inpChay.value) || 0;
      inpTong.value = m + c;
    }
    inpMan.addEventListener('input', calcTotal);
    inpChay.addEventListener('input', calcTotal);
    inpChay.addEventListener('input', calcTotal);

  function openForm(mode, data) {
    var title = $container.querySelector('#booking-form-title');
    if (mode === 'add1') {
      title.textContent = 'Thêm Biên nhận Cọc Lần 1';
      _clearForm();
    } else if (mode === 'edit') {
      title.textContent = 'Thay đổi Biên nhận Cọc';
      _fillForm(data);
    } else if (mode === 'add2') {
      title.textContent = 'Tiếp nhận Cọc Lần 2';
      _fillForm(data);
    }

    if (bookingPanel) {
      bookingPanel.show();
    }
  }

  function closeForm() {
    if (bookingPanel) {
      bookingPanel.hide();
    }
  }

  function _clearForm() {
    $container.querySelector('#inp-machungtu').value = 'BNCC-AUTO';
    $container.querySelector('#inp-tenchure').value = '';
    $container.querySelector('#inp-tencodau').value = '';
    $container.querySelector('#inp-dienthoai').value = '';
    $container.querySelector('#inp-email').value = '';
    $container.querySelector('#inp-ngaytochuc').value = '';
    $container.querySelector('#sel-catiec').value = 'T';
    $container.querySelector('#inp-ban-man').value = '';
    $container.querySelector('#inp-ban-chay').value = '';
    $container.querySelector('#inp-tong-ban').value = '';
    $container.querySelector('#sel-sanh').value = '';
    $container.querySelector('#inp-tiencoc').value = '';
    $container.querySelector('#inp-ghichu').value = '';
  }

  function _fillForm(data) {
    if (!data) return;
    $container.querySelector('#inp-machungtu').value = data.MaChungTu || data.id || '';

    var names = (data.TenKhachHang || data.customerName || '').split('&');
    $container.querySelector('#inp-tenchure').value = names[0] ? names[0].trim() : '';
    $container.querySelector('#inp-tencodau').value = names[1] ? names[1].trim() : '';

    $container.querySelector('#inp-dienthoai').value = data.DienThoai || data.phone || '';
    $container.querySelector('#inp-email').value = '';

    var eventDate = data.NgayToChuc || data.eventDate || '';
    if (eventDate.includes('/')) {
      var parts = eventDate.split('/');
      if (parts.length === 3) {
        $container.querySelector('#inp-ngaytochuc').value = parts[2] + '-' + parts[1] + '-' + parts[0];
      }
    } else {
      $container.querySelector('#inp-ngaytochuc').value = '';
    }

    $container.querySelector('#sel-catiec').value = 'T';
    $container.querySelector('#inp-ban-man').value = data.SoBan != null ? data.SoBan : data.totalTables;
    $container.querySelector('#inp-ban-chay').value = 0;
    $container.querySelector('#inp-tong-ban').value = data.SoBan != null ? data.SoBan : data.totalTables;

    $container.querySelector('#sel-sanh').value = ''; // Reset select
    var currentHall = data.SanhDat || data.hall || '';
    if (currentHall.includes('Diamond')) $container.querySelector('#sel-sanh').value = 'S01';
    else if (currentHall.includes('Ruby')) $container.querySelector('#sel-sanh').value = 'S02';
    else if (currentHall.includes('Queen')) $container.querySelector('#sel-sanh').value = 'S03';

    var depositStr = (data.DaCocVND != null ? data.DaCocVND : data.deposit).toString();
    $container.querySelector('#inp-tiencoc').value = depositStr;
    $container.querySelector('#inp-ghichu').value = '';
  }

  function getSelectedRow() {
    var activeRow = $container.querySelector('#booking-table tbody tr.active');
    if (!activeRow) return null;
    var index = Array.from(activeRow.parentNode.children).indexOf(activeRow);
    return bookingData[index];
  }

  }

  return { render: render };
})();
