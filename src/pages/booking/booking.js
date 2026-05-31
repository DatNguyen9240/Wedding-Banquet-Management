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
    TuNgay: "",
    DenNgay: ""
  };

  function render(containerElement) {
    $container = containerElement;

    bookingData = [];

    fetch('./src/pages/booking/booking.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;

        // Bắt tham số date hoặc id từ URL (ví dụ: ?date=2023-03-03 hoặc ?id=BN123)
        var hashParts = window.location.hash.split('?');
        if (hashParts.length > 1) {
          var params = new URLSearchParams(hashParts[1]);
          var dateParam = params.get('date');
          var idParam = params.get('id');
          
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
        }

        _bindEvents();
        _loadData();
      });
  }

  var hallRecords = [];

  function _renderSanhPhu(sanhChinhId, selectedIds) {
    var container = $container.querySelector('#container-sanh-phu');
    if (!container) return;
    container.innerHTML = '';
    
    if (!sanhChinhId) {
      container.innerHTML = '<span class="text-secondary" style="font-size: 12px; margin: auto; font-style: italic;">Vui lòng chọn Sảnh Chính trước</span>';
      return;
    }
    
    var filtered = hallRecords.filter(function(r) { return r.Sanhtiecid !== sanhChinhId; });
    if (filtered.length === 0) {
      container.innerHTML = '<span class="text-secondary" style="font-size: 12px; margin: auto; font-style: italic;">Không có sảnh phụ nào khác</span>';
      return;
    }
    
    filtered.forEach(function(h) {
      var isChecked = (selectedIds || []).includes(h.Sanhtiecid) ? 'checked' : '';
      container.innerHTML += `
      <label class="modern-checkbox-wrapper mb-0" style="font-size: 13px; background: white; padding: 8px 14px; border-radius: 8px; border: 1px solid var(--color-border); min-width: 160px; display: flex; flex-direction: column; cursor: pointer; transition: all 0.2s;">
        <div class="d-flex align-items-center gap-2">
          <input type="checkbox" class="modern-checkbox chk-sanh-phu" value="${h.Sanhtiecid}" ${isChecked}>
          <span style="font-weight: 600; color: var(--color-primary);">${h.Tensanhtiec}</span>
        </div>
        <div style="font-size: 11px; color: var(--color-text-secondary); margin-left: 26px; margin-top: 2px;">Max: ${h.Succhua || 0} bàn</div>
      </label>
      `;
    });
  }

  function _loadData() {
    var tbody = $container.querySelector('#booking-table tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4" style="color: var(--color-text-secondary);">Đang tải dữ liệu...</td></tr>';

    BookingService.getList(filterParams)
      .then(function (data) {
        bookingData = data;
        _renderTable();
      })
      .catch(function (err) {
        console.error('Lỗi Load:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center text-danger py-4">Lỗi kết nối API lấy danh sách cọc!</td></tr>';
      });

    // Load Sảnh Tiệc
    if (typeof SystemDataService !== 'undefined') {
      SystemDataService.getHalls().then(function (records) {
        hallRecords = records;
        var selSanh = $container.querySelector('#sel-sanh');
        if (selSanh && records.length > 0) {
          selSanh.innerHTML = '<option value="">-- Chọn Sảnh --</option>';
          records.forEach(function (h) {
            selSanh.innerHTML += '<option value="' + h.Sanhtiecid + '">' + h.Tensanhtiec + ' (Max: ' + (h.Succhua || 0) + ')</option>';
          });
          
          selSanh.addEventListener('change', function() {
            _renderSanhPhu(this.value, []);
          });
        }
      }).catch(e => console.warn('Không load được sảnh', e));
      
      // Load Loại Tiệc
      SystemDataService.getBanquetTypes().then(function (records) {
        var selLoaiTiec = $container.querySelector('#sel-loaitiec');
        if (selLoaiTiec && records.length > 0) {
          selLoaiTiec.innerHTML = '<option value="">-- Chọn Loại Tiệc --</option>';
          records.forEach(function (lt) {
            var isHoiNghiFlag = (String(lt.isHoiNghi) === '1' || String(lt.isHoiNghi).toLowerCase() === 'true') ? '1' : '0';
            var tenLoai = lt.Tenloaihinhtiec || lt.Tenloaitiec || lt.Tenloaihinh || 'Không xác định';
            var idLoai = lt.Loaihinhtiecid || lt.Loaitiecid || '';
            selLoaiTiec.innerHTML += '<option value="' + idLoai + '" data-ishoinghi="' + isHoiNghiFlag + '">' + tenLoai + '</option>';
          });
        }
      }).catch(e => console.warn('Không load được loại tiệc', e));
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
    
    if (!bookingData || bookingData.length === 0) {
      tbody.innerHTML = '<tr><td colspan="9" class="text-center py-5" style="color: var(--color-text-secondary); font-size: 14px;">Không có dữ liệu cọc chỗ</td></tr>';
      return;
    }

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
    var filterContainer = $container.querySelector('#booking-filter');
    if (filterContainer && typeof UIFilter !== 'undefined') {
      UIFilter.create(filterContainer, {
        keyword: true,
        keywordPlaceholder: 'Tìm Mã phiếu, Số ĐT...',
        dateRange: true,
        dateLabel: 'Ngày tổ chức',
        status: [
          { value: '1', label: 'Giữ chỗ (Lần 1)' },
          { value: '2', label: 'Giữ chỗ (Lần 2)' },
          { value: '3', label: 'Đã lên Hợp đồng' },
          { value: '4', label: 'Đã hủy' }
        ],
        onFilter: function(params) {
          filterParams.Keyword = params.keyword || '';
          filterParams.TuNgay = params.fromDate || '';
          filterParams.DenNgay = params.toDate || '';
          filterParams.TrangThai = params.status || '';
          _loadData();
        }
      });
    }

    // Row selection logic
    var tbody = $container.querySelector('#booking-table tbody');
    if (window.UIControls && UIControls.utils && UIControls.utils.setupTableSelection) {
      UIControls.utils.setupTableSelection(tbody);
    } else {
      tbody.addEventListener('click', function (e) {
        var tr = e.target.closest('tr');
        if (!tr) return;
        Array.from(tbody.querySelectorAll('tr')).forEach(r => r.classList.remove('active'));
        tr.classList.add('active');
      });
    }

    $container.querySelector('#btn-add-deposit1').addEventListener('click', function () {
      openForm('add1', null);
    });
    
    var btnMobileAdd = $container.querySelector('#btn-add-deposit1-mobile');
    if (btnMobileAdd) {
      btnMobileAdd.addEventListener('click', function () {
        openForm('add1', null);
      });
    }

    $container.querySelector('#btn-add-deposit2').addEventListener('click', function () {
      var selected = getSelectedRow();
      if (!selected) {
        UIToast.show('Vui lòng chọn một Biên nhận cọc để bổ sung cọc lần 2!', 'warning');
        return;
      }
      openForm('add2', selected);
    });

    var btnEdit = $container.querySelector('#btn-edit-booking');
    if (btnEdit) {
      btnEdit.addEventListener('click', function() {
        var selected = getSelectedRow();
        if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận!', 'warning');
        openForm('edit', selected); 
      });
    }

    var btnCancel = $container.querySelector('#btn-cancel-booking');
    if (btnCancel) {
      btnCancel.addEventListener('click', function() {
        var selected = getSelectedRow();
        if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận để hủy!', 'warning');
        var docId = selected.MaChungTu || selected.id;
        ConfirmModal.show({
          title: 'Hủy Phiếu Cọc',
          message: 'Bạn có chắc chắn muốn hủy phiếu cọc <b>' + docId + '</b> không?',
          onConfirm: function() {
            if (API_CONFIG && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.BOOKING && API_CONFIG.ENDPOINTS.BOOKING.CANCEL) {
              BookingService.cancel({ DocumentID: docId, Lydohuy: 'Khách yêu cầu hủy' }).then(function () {
                UIToast.show('Hủy phiếu cọc thành công', 'success');
                _loadData();
              }).catch(function () { UIToast.show('Lỗi hủy phiếu', 'danger'); });
            } else {
              UIToast.show('Chưa cấu hình API CANCEL', 'warning');
            }
          }
        });
      });
    }

    var btnCreateContract = $container.querySelector('#btn-create-contract');
    if (btnCreateContract) {
      btnCreateContract.addEventListener('click', function() {
        var selected = getSelectedRow();
        if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận!', 'warning');
        var docId = selected.MaChungTu || selected.id;
        window.location.hash = '#/contract?bookingId=' + docId;
      });
    }

    var btnMore = $container.querySelector('#btn-booking-more');
    if (btnMore) {
      btnMore.addEventListener('click', function(e) {
        var selected = getSelectedRow();
        if (typeof UIContextMenu !== 'undefined') {
          UIContextMenu.show(e, [
            { 
              label: 'Thay Đổi Cọc', 
              icon: 'edit', 
              onClick: function() { 
                if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận!', 'warning');
                openForm('edit', selected); 
              } 
            },
            { 
              label: 'Lập Hợp Đồng', 
              icon: 'description', 
              onClick: function() { 
                if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận!', 'warning');
                var docId = selected.MaChungTu || selected.id;
                window.location.hash = '#/contract?bookingId=' + docId;
              } 
            },
            '|',
            { 
              label: '<span class="text-danger">Hủy Phiếu Cọc</span>', 
              icon: 'delete', 
              onClick: function() { 
                if (!selected) return UIToast.show('Vui lòng chọn một Biên nhận để hủy!', 'warning');
                var docId = selected.MaChungTu || selected.id;
                ConfirmModal.show({
                  title: 'Hủy Phiếu Cọc',
                  message: 'Bạn có chắc chắn muốn hủy phiếu cọc <b>' + docId + '</b> không?',
                  onConfirm: function() {
                    if (API_CONFIG && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.BOOKING && API_CONFIG.ENDPOINTS.BOOKING.CANCEL) {
                      BookingService.cancel({ DocumentID: docId, Lydohuy: 'Khách yêu cầu hủy' }).then(function () {
                        UIToast.show('Hủy phiếu cọc thành công', 'success');
                        _loadData();
                      }).catch(function () { UIToast.show('Lỗi hủy phiếu', 'danger'); });
                    } else {
                      UIToast.show('Chưa cấu hình API CANCEL', 'warning');
                    }
                  }
                });
              } 
            }
          ]);
        }
      });
    }

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
            BookingService.searchCustomer(keyword)
              .then(function (result) {
                renderResults(result.list);
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
              <span>${UIIcon.createHTML('call', 'font-size:12px;vertical-align:middle;')} ${kh.Dienthoai || '---'}</span>
              <span>${UIIcon.createHTML('pin_drop', 'font-size:12px;vertical-align:middle;')} ${kh.Diachi || '---'}</span>
            </div>
          `;
        },
        onSelect: function (kh) {
          var tenKhach = [kh.Tenchure, kh.Tencodau].filter(Boolean).join(' & ');
          if (!tenKhach) tenKhach = kh.Tenkh || 'Chưa có tên';

          $container.querySelector('#inp-tenchure').value = kh.Tenchure || '';
          $container.querySelector('#inp-dtchure').value = kh.DTchure || kh.Dienthoai || '';
          $container.querySelector('#inp-tencodau').value = kh.Tencodau || '';
          $container.querySelector('#inp-dtcodau').value = kh.DTcodau || '';
          $container.querySelector('#inp-diachi').value = kh.Diachi || '';
          $container.querySelector('#inp-nguoigd').value = kh.Nguoigd || '';
          $container.querySelector('#inp-dtdai-dien').value = kh.DienThoaiDaiDien || '';
          $container.querySelector('#inp-email').value = kh.Mail || '';
          if (window.UIToast) UIToast.show('Đã chọn: ' + tenKhach, 'success');
        }
      }));
    }

    $container.querySelector('#btn-save-booking').addEventListener('click', function () {
      var machungtu = $container.querySelector('#inp-machungtu').value;
      if (machungtu === 'BNCC-AUTO') machungtu = null; // Null để Server tự sinh mới

      var tenchure = $container.querySelector('#inp-tenchure').value;
      var dtchure = $container.querySelector('#inp-dtchure').value;
      var tencodau = $container.querySelector('#inp-tencodau').value;
      var dtcodau = $container.querySelector('#inp-dtcodau').value;
      var diachi = $container.querySelector('#inp-diachi').value;
      var nguoigd = $container.querySelector('#inp-nguoigd').value;
      var dtdaidien = $container.querySelector('#inp-dtdai-dien').value;
      var email = $container.querySelector('#inp-email').value;
      var eventDate = $container.querySelector('#inp-ngaytochuc').value;
      var caTiec = $container.querySelector('#sel-catiec').value;
      var banMan = parseInt($container.querySelector('#inp-ban-man').value) || 0;
      var banManDp = parseInt($container.querySelector('#inp-ban-man-dp').value) || 0;
      var banChay = parseInt($container.querySelector('#inp-ban-chay').value) || 0;
      var banChayDp = parseInt($container.querySelector('#inp-ban-chay-dp').value) || 0;
      var sanhId = $container.querySelector('#sel-sanh').value;
      var dsSanh = [];
      if (sanhId) dsSanh.push({ Sanhtiecid: sanhId, IsSanhchinh: 1 });
      
      var chkPhu = $container.querySelectorAll('.chk-sanh-phu:checked');
      Array.from(chkPhu).forEach(function(chk) {
        dsSanh.push({ Sanhtiecid: chk.value, IsSanhchinh: 0 });
      });

      var tienCocRaw = $container.querySelector('#inp-tiencoc').value || '0';
      var tienCoc = parseFloat(tienCocRaw.replace(/,/g, ''));
      var ghiChu = $container.querySelector('#inp-ghichu').value;
      var loaitiec = $container.querySelector('#sel-loaitiec').value;

      var isCocLan2 = $container.querySelector('#booking-form-title').textContent.includes('Lần 2');

      var payload = {
        DocumentID: machungtu,
        Tenchure: tenchure,
        Tencodau: tencodau,
        DTchure: dtchure,
        DTcodau: dtcodau,
        Diachi: diachi,
        Nguoigd: nguoigd,
        DienThoaiDaiDien: dtdaidien,
        Mail: email,
        Ngaytochuc: eventDate,
        Loaitiecid: loaitiec,
        Thoigianid: caTiec,
        SobanManchinhthuc: banMan,
        SobanManduphong: banManDp,
        SobanChaychinhthuc: banChay,
        SobanChayduphong: banChayDp,
        Tongtien: tienCoc,
        Solan: isCocLan2 ? 2 : 1,
        Ghichu: ghiChu,
        JsonSanhTiec: JSON.stringify(dsSanh)
      };

      // Kiểm tra và sử dụng ENDPOINT từ env.js
      if (typeof API_CONFIG !== 'undefined' && API_CONFIG.ENDPOINTS && API_CONFIG.ENDPOINTS.BOOKING && API_CONFIG.ENDPOINTS.BOOKING.SAVE) {
        BookingService.save(payload)
          .then(function (res) {
            UIToast.show('Lưu Biên nhận cọc thành công!', 'success');
            closeForm();
            _loadData();
          })
          .catch(function (err) {
            console.error('Lỗi lưu Cọc:', err);
            UIToast.show('Lỗi khi lưu: ' + (err.message || 'Có lỗi xảy ra'), 'danger');
          });
      } else {
        console.warn('Thiếu cấu hình API_CONFIG.ENDPOINTS.BOOKING.SAVE');
        UIToast.show('Đang mô phỏng lưu...', 'success');
      }
    });

    // Format Tiền Cọc
    var inpTienCoc = $container.querySelector('#inp-tiencoc');
    var vnTienCoc = $container.querySelector('#vn-tiencoc');
    if (typeof UIInput !== 'undefined' && UIInput.setupMoneyInput) {
      UIInput.setupMoneyInput(inpTienCoc, vnTienCoc);
    }

    // Removed auto calculate total tables as the UI uses dp fields now
    
    // Dynamic Form Loại Tiệc
    var selLoaiTiec = $container.querySelector('#sel-loaitiec');
    if (selLoaiTiec) {
      selLoaiTiec.addEventListener('change', function() {
        var selectedOption = this.options[this.selectedIndex];
        var isHoiNghi = selectedOption ? selectedOption.getAttribute('data-ishoinghi') : '0';

        var colCodau = $container.querySelector('#bk-col-ten-codau');
        var colDtCodau = $container.querySelector('#bk-col-dt-codau');
        var colChure = $container.querySelector('#bk-col-ten-chure');
        var colDtChure = $container.querySelector('#bk-col-dt-chure');
        var lblChure = $container.querySelector('#bk-lbl-ten-chure');
        var lblDtChure = $container.querySelector('#bk-lbl-dt-chure');
        var inpChure = $container.querySelector('#inp-tenchure');
        var inpDtChure = $container.querySelector('#inp-dtchure');
        var inpCodau = $container.querySelector('#inp-tencodau');

        if (isHoiNghi !== '1') {
          if (colCodau) colCodau.style.display = 'block';
          if (colDtCodau) colDtCodau.style.display = 'block';
          if (colChure) colChure.className = 'col-md-6';
          if (colDtChure) colDtChure.className = 'col-md-6';
          if (lblChure) lblChure.innerHTML = 'Tên Chú Rể <span style="color:var(--color-danger)">*</span>';
          if (inpChure) inpChure.placeholder = 'Nhập tên chú rể';
          if (lblDtChure) lblDtChure.innerText = 'ĐT Chú Rể';
          if (inpDtChure) inpDtChure.placeholder = 'SĐT chú rể';
        } else {
          if (colCodau) colCodau.style.display = 'none';
          if (colDtCodau) colDtCodau.style.display = 'none';
          if (colChure) colChure.className = 'col-md-6';
          if (colDtChure) colDtChure.className = 'col-md-6';
          if (inpCodau) {
            inpCodau.value = '';
          }
          if (lblChure) lblChure.innerHTML = 'Tên KH / Đơn vị <span style="color:var(--color-danger)">*</span>';
          if (inpChure) inpChure.placeholder = 'Nhập tên khách hàng...';
          if (lblDtChure) lblDtChure.innerText = 'SĐT Khách Hàng';
          if (inpDtChure) inpDtChure.placeholder = 'SĐT khách hàng';
        }
      });
    }

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
    $container.querySelector('#inp-dtchure').value = '';
    $container.querySelector('#inp-tencodau').value = '';
    $container.querySelector('#inp-dtcodau').value = '';
    $container.querySelector('#inp-diachi').value = '';
    $container.querySelector('#inp-nguoigd').value = '';
    $container.querySelector('#inp-dtdai-dien').value = '';
    $container.querySelector('#inp-email').value = '';
    $container.querySelector('#inp-ngaytochuc').value = '';
    var ltSel = $container.querySelector('#sel-loaitiec');
    if (ltSel) {
      ltSel.value = '';
      ltSel.dispatchEvent(new Event('change'));
    }
    $container.querySelector('#sel-catiec').value = 'T';
    $container.querySelector('#inp-ban-man').value = '';
    var manDp = $container.querySelector('#inp-ban-man-dp');
    if (manDp) manDp.value = '';
    $container.querySelector('#inp-ban-chay').value = '';
    var chayDp = $container.querySelector('#inp-ban-chay-dp');
    if (chayDp) chayDp.value = '';
    $container.querySelector('#sel-sanh').value = '';
    $container.querySelector('#inp-tiencoc').value = '';
    $container.querySelector('#inp-ghichu').value = '';
  }

  function _fillForm(data) {
    if (!data) return;
    $container.querySelector('#inp-machungtu').value = data.MaChungTu || data.id || '';
    var names = (data.TenKhachHang || data.customerName || '').split('&');
    $container.querySelector('#inp-tenchure').value = data.Tenchure || (names[0] ? names[0].trim() : '');
    $container.querySelector('#inp-dtchure').value = data.DTchure || data.DienThoai || data.phone || '';
    $container.querySelector('#inp-tencodau').value = data.Tencodau || (names[1] ? names[1].trim() : '');
    $container.querySelector('#inp-dtcodau').value = data.DTcodau || '';
    
    $container.querySelector('#inp-diachi').value = data.Diachi || '';
    $container.querySelector('#inp-nguoigd').value = data.Nguoigd || '';
    $container.querySelector('#inp-dtdai-dien').value = data.DienThoaiDaiDien || '';
    $container.querySelector('#inp-email').value = data.Mail || '';

    var eventDate = data.NgayToChuc || data.eventDate || '';
    if (eventDate.includes('/')) {
      var parts = eventDate.split('/');
      if (parts.length === 3) {
        $container.querySelector('#inp-ngaytochuc').value = parts[2] + '-' + parts[1] + '-' + parts[0];
      }
    } else {
      $container.querySelector('#inp-ngaytochuc').value = '';
    }

    // Trigger update for Loaihinhtiec
    var ltSel = $container.querySelector('#sel-loaitiec');
    if (ltSel) {
      ltSel.value = data.Loaihinhtiecid || '';
      ltSel.dispatchEvent(new Event('change'));
    }

    $container.querySelector('#sel-catiec').value = data.Thoigianid || 'T';
    $container.querySelector('#inp-ban-man').value = data.SobanManchinhthuc != null ? data.SobanManchinhthuc : (data.SoBan != null ? data.SoBan : data.totalTables);
    var manDp = $container.querySelector('#inp-ban-man-dp');
    if (manDp) manDp.value = data.SobanManduphong || 0;
    
    $container.querySelector('#inp-ban-chay').value = data.SobanChaychinhthuc || 0;
    var chayDp = $container.querySelector('#inp-ban-chay-dp');
    if (chayDp) chayDp.value = data.SobanChayduphong || 0;

    $container.querySelector('#sel-sanh').value = ''; // Reset select
    _renderSanhPhu('', []);
    var currentHall = data.SanhDat || data.hall || '';
    
    // Nếu có data.JsonSanhTiec, decode ra để fill sảnh chính và sảnh phụ
    var dsSanh = [];
    try {
      if (data.JsonSanhTiec) dsSanh = JSON.parse(data.JsonSanhTiec);
    } catch(e) {}
    
    if (dsSanh.length > 0) {
      var sanhChinh = dsSanh.find(s => s.IsSanhchinh === 1 || s.IsSanhchinh === true);
      if (sanhChinh) {
        $container.querySelector('#sel-sanh').value = sanhChinh.Sanhtiecid;
        var phuIds = dsSanh.filter(s => s.IsSanhchinh === 0 || s.IsSanhchinh === false).map(s => s.Sanhtiecid);
        _renderSanhPhu(sanhChinh.Sanhtiecid, phuIds);
      }
    } else {
      if (currentHall.includes('Diamond')) $container.querySelector('#sel-sanh').value = 'S01';
      else if (currentHall.includes('Ruby')) $container.querySelector('#sel-sanh').value = 'S02';
      else if (currentHall.includes('Queen')) $container.querySelector('#sel-sanh').value = 'S03';
      _renderSanhPhu($container.querySelector('#sel-sanh').value, []);
    }

    var depositStr = (data.DaCocVND != null ? data.DaCocVND : data.deposit).toString();
    var inpTienCoc = $container.querySelector('#inp-tiencoc');
    var vnTienCoc = $container.querySelector('#vn-tiencoc');
    if (inpTienCoc) {
      if (depositStr) {
        var val = depositStr.replace(/\D/g, '');
        if (val) {
          var raw = parseInt(val, 10);
          inpTienCoc.value = raw.toLocaleString('vi-VN');
          if (vnTienCoc) vnTienCoc.innerText = UIInput.docSoTienVN(raw);
        } else {
          inpTienCoc.value = '';
          if (vnTienCoc) vnTienCoc.innerText = '';
        }
      } else {
        inpTienCoc.value = '';
        if (vnTienCoc) vnTienCoc.innerText = '';
      }
    }
    
    $container.querySelector('#inp-ghichu').value = data.Ghichu || '';
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
