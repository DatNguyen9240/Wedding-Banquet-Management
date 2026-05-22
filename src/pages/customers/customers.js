/**
 * Trang Quản lý Hồ sơ Khách hàng
 */
window.CustomersPage = (function () {

  var $container = null;
  var customersData = [];
  var selectedRow = null;
  var $inputSearch = null;

  // ── Helpers ──────────────────────────────────────────────
  function _currentGroup() {
    var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    return u.Group || u.GroupUser || u.GroupID || u.group || u.NhomQuyen || 'Admin';
  }

  function _currentUser() {
    var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    return u.Username || u.UserName || u.username || 'Admin';
  }

  // ── Render ────────────────────────────────────────────────
  function render(container) {
    if (!container) return;
    $container = container;

    fetch('./src/pages/customers/customers.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;

        // Action Toolbar
        var btnContainer = $container.querySelector('#customers-btn-container');
        if (btnContainer && typeof UIActionToolbar !== 'undefined') {
          var toolbar = UIActionToolbar.create({
            onAdd: _openAddForm,
            onEdit: function () {
              if (!selectedRow) return Alert.warning('Cảnh báo', 'Vui lòng chọn khách hàng cần sửa');
              _openEditForm(selectedRow);
            },
            onDelete: function () {
              if (!selectedRow) return Alert.warning('Cảnh báo', 'Vui lòng chọn khách hàng cần xóa');
              if (typeof ConfirmModal !== 'undefined') {
                ConfirmModal.show('Xác nhận xóa',
                  'Bạn có chắc muốn xóa khách hàng <b>' + selectedRow.TenKhach + '</b>?',
                  function () {
                    Alert.info('Thông báo', 'Chức năng xóa khách hàng đang phát triển');
                  }
                );
              }
            },
            onPrint: false,
            onClose: false
          });
          toolbar.style.display = 'inline-flex';
          toolbar.style.width = 'auto';
          btnContainer.appendChild(toolbar);
        }

        // Search bar
        var filterContainer = $container.querySelector('#customers-filter-container');
        if (filterContainer && typeof UIInput !== 'undefined') {
          var inputWrapper = UIInput.createText({
            id: 'input-search-customers',
            placeholder: 'Tìm kiếm theo mã, tên, số điện thoại...',
            className: ''
          });
          inputWrapper.style.flexDirection = 'row';
          inputWrapper.style.alignItems = 'center';
          $inputSearch = inputWrapper.querySelector('#input-search-customers');
          if ($inputSearch) {
            $inputSearch.style.width = '300px';
            $inputSearch.style.minWidth = '220px';
            $inputSearch.addEventListener('keydown', function (e) {
              if (e.key === 'Enter') _loadData($inputSearch.value);
            });
          }

          var btnSearch = document.createElement('button');
          btnSearch.className = 'btn btn-outline';
          btnSearch.id = 'btn-search-customers';
          btnSearch.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">search</span><span>Tìm kiếm</span>';
          btnSearch.addEventListener('click', function () {
            _loadData($inputSearch ? $inputSearch.value : '');
          });

          filterContainer.appendChild(inputWrapper);
          filterContainer.appendChild(btnSearch);
        }

        _loadData();
      })
      .catch(function (err) {
        $container.innerHTML = '<div class="p-4 text-danger">Lỗi tải giao diện: ' + err.message + '</div>';
      });
  }

  // ── Load Data ─────────────────────────────────────────────
  function _loadData(keyword) {
    var searchKey = keyword || '';
    var gridContainer = $container ? $container.querySelector('#customers-grid-container') : null;
    if (gridContainer) gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">Đang tải dữ liệu...</div>';

    if (typeof BookingService !== 'undefined') {
      BookingService.searchCustomer(searchKey).then(function (data) {
        customersData = data.map(function (item) {
          return {
            id: item.Id || item.Makh,
            Makh: item.Makh,
            MaKH: item.Makh || '---',
            TenKhach: [item.Tenchure, item.Tencodau].filter(Boolean).join(' & ') || item.Tenkh || 'Chưa có tên',
            Tenchure: item.Tenchure || '',
            Tencodau: item.Tencodau || '',
            DienThoai: item.Dienthoai || item.DTchure || item.DTcodau || '---',
            DTchure: item.DTchure || '',
            DTcodau: item.DTcodau || '',
            Email: item.Mail || '',
            DiaChi: item.Diachi || '',
            Ghichu: item.Ghichu || '',
            SoLanThamQuan: item.SoLanThamQuan || 0,
            SoHopDong: item.SoHopDong || 0
          };
        });
        _renderTable();
      }).catch(function (err) {
        console.error('Lỗi tải danh sách khách hàng:', err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Lỗi kết nối khi lấy danh sách khách hàng!');
        customersData = [];
        _renderTable();
      });
    }
  }

  // ── Render Table ──────────────────────────────────────────
  function _renderTable() {
    var gridContainer = $container.querySelector('#customers-grid-container');
    if (!gridContainer) return;
    gridContainer.innerHTML = '';
    selectedRow = null;

    if (typeof UITable !== 'undefined') {
      var tableEl = UITable.create({
        headers: [
          { label: 'Mã KH', width: '120px' },
          { label: 'Tên Khách Hàng', width: '250px' },
          { label: 'Điện thoại', width: '130px' },
          { label: 'Email', width: '200px' },
          { label: 'Địa chỉ' },
          { label: 'Tham quan', width: '100px', align: 'center' },
          { label: 'Hợp đồng', width: '100px', align: 'center' }
        ],
        data: customersData,
        columns: [
          { field: 'MaKH' },
          { field: 'TenKhach', render: function (v) { return '<span style="color:var(--color-primary);font-weight:600;">' + v + '</span>'; } },
          { field: 'DienThoai' },
          { field: 'Email' },
          { field: 'DiaChi' },
          { field: 'SoLanThamQuan', align: 'center' },
          { field: 'SoHopDong', align: 'center' }
        ]
      });

      gridContainer.appendChild(tableEl);

      var tbody = tableEl.querySelector('tbody');
      if (tbody) {
        tbody.addEventListener('click', function (e) {
          var tr = e.target.closest('tr');
          if (!tr || tr.children.length === 1) return;
          Array.from(tbody.querySelectorAll('tr')).forEach(function (r) { r.classList.remove('active'); });
          tr.classList.add('active');
          var idx = Array.from(tbody.children).indexOf(tr);
          selectedRow = customersData[idx] || null;
        });
        tbody.addEventListener('dblclick', function (e) {
          var tr = e.target.closest('tr');
          if (!tr || !selectedRow) return;
          _openEditForm(selectedRow);
        });
      }
    }
  }

  // ── Modal Form ────────────────────────────────────────────
  function _openAddForm() {
    _openModal(false, null);
  }

  function _openEditForm(row) {
    _openModal(true, row);
  }

  function _openModal(isEdit, row) {
    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    var grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gap = '12px';
    body.appendChild(grid);

    // Dùng UIInput để sinh các DOM Elements
    grid.appendChild(UIInput.createText({
      id: 'cust-tenchure', label: 'Tên Chú Rể', required: true,
      placeholder: 'Nguyễn Văn A', value: row ? (row.Tenchure || '') : ''
    }));
    grid.appendChild(UIInput.createText({
      id: 'cust-tencodau', label: 'Tên Cô Dâu',
      placeholder: 'Nguyễn Thị B', value: row ? (row.Tencodau || '') : ''
    }));
    grid.appendChild(UIInput.createText({
      id: 'cust-dtchure', label: 'SĐT Chú Rể', required: true,
      placeholder: '0912345678', value: row ? (row.DTchure || '') : ''
    }));
    grid.appendChild(UIInput.createText({
      id: 'cust-dtcodau', label: 'SĐT Cô Dâu',
      placeholder: '0987654321', value: row ? (row.DTcodau || '') : ''
    }));

    body.appendChild(UIInput.createText({
      id: 'cust-mail', label: 'Email',
      placeholder: 'email@example.com', value: row ? (row.Email || '') : ''
    }));
    body.appendChild(UIInput.createText({
      id: 'cust-diachi', label: 'Địa chỉ',
      placeholder: 'Số nhà, đường, phường/xã, quận/huyện...', value: row ? (row.DiaChi || '') : ''
    }));

    // Ghi chú
    var ghichuWrapper = document.createElement('div');
    ghichuWrapper.className = 'form-group';
    ghichuWrapper.innerHTML = `
      <label>Ghi chú</label>
      <textarea id="cust-ghichu" class="ui-input" rows="2" placeholder="Ghi chú thêm..." style="height:auto;resize:vertical;">${row ? (row.Ghichu || '') : ''}</textarea>
    `;
    body.appendChild(ghichuWrapper);

    // Footer buttons
    var footer = document.createElement('div');
    footer.style.display = 'flex';
    footer.style.gap = '10px';

    var btnCancel = document.createElement('button');
    btnCancel.className = 'btn btn-outline';
    btnCancel.textContent = 'Hủy';

    var btnSave = document.createElement('button');
    btnSave.className = 'btn btn-primary';
    btnSave.textContent = isEdit ? 'Lưu thay đổi' : 'Thêm mới';

    footer.appendChild(btnCancel);
    footer.appendChild(btnSave);

    var modal = UIModal.show({
      title: isEdit ? '✏️ Sửa Khách Hàng' : '➕ Thêm Khách Hàng Mới',
      width: '600px',
      content: body,
      footer: footer
    });

    btnCancel.onclick = function () { modal.close(); };
    btnSave.onclick = function () {
      _saveCustomer(isEdit, row, modal, body, btnSave);
    };

    // Focus first input
    setTimeout(function () {
      var first = body.querySelector('#cust-tenchure');
      if (first) first.focus();
    }, 100);
  }

  // ── Save ──────────────────────────────────────────────────
  function _saveCustomer(isEdit, row, modal, body, btnSave) {
    var tenchure = body.querySelector('#cust-tenchure').value.trim();
    var tencodau = body.querySelector('#cust-tencodau').value.trim();
    var dtchure = body.querySelector('#cust-dtchure').value.trim();
    var dtcodau = body.querySelector('#cust-dtcodau').value.trim();
    var mail = body.querySelector('#cust-mail').value.trim();
    var diachi = body.querySelector('#cust-diachi').value.trim();
    var ghichu = body.querySelector('#cust-ghichu').value.trim();

    if (!tenchure) return Alert.warning('Thiếu thông tin', 'Vui lòng nhập tên Chú Rể');
    if (!dtchure && !dtcodau) return Alert.warning('Thiếu thông tin', 'Vui lòng nhập ít nhất 1 số điện thoại');

    btnSave.disabled = true;
    btnSave.textContent = 'Đang lưu...';

    var endpoint = window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.CUSTOMER
      ? window.API_CONFIG.ENDPOINTS.CUSTOMER.SAVE : null;

    if (!endpoint) {
      Alert.error('Lỗi', 'Thiếu cấu hình API lưu khách hàng');
      btnSave.disabled = false;
      return;
    }

    var payload = {
      NhomNguoiDangThaoTac: _currentGroup(),
      Makh: isEdit ? row.Makh : '',
      Tenchure: tenchure,
      Tencodau: tencodau,
      DTchure: dtchure,
      DTcodau: dtcodau,
      Dienthoai: dtchure || dtcodau,
      Mail: mail,
      Diachi: diachi,
      Ghichu: ghichu,
      UserCreate: _currentUser(),
      IsEdit: isEdit ? 1 : 0
    };

    ApiClient.post(endpoint, payload)
      .then(function (res) {
        if (res && res.code === 0) {
          UIToast.show(isEdit ? 'Đã cập nhật khách hàng!' : 'Đã thêm khách hàng mới!', 'success');
          modal.closeNow();
          _loadData($inputSearch ? $inputSearch.value : '');
        } else {
          Alert.error('Lỗi', res && res.msg ? res.msg : 'Lưu thất bại');
          btnSave.disabled = false;
          btnSave.textContent = isEdit ? 'Lưu thay đổi' : 'Thêm mới';
        }
      })
      .catch(function () {
        Alert.error('Lỗi', 'Lỗi kết nối máy chủ');
        btnSave.disabled = false;
        btnSave.textContent = isEdit ? 'Lưu thay đổi' : 'Thêm mới';
      });
  }

  return { render: render };
})();
