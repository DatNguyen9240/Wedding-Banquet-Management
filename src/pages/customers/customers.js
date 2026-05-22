/**
 * Trang Quản lý Hồ sơ Khách hàng
 */
window.CustomersPage = (function () {

  var $container = null;
  var customersData = [];
  var selectedRow = null;
  var $inputSearch = null; // tham chiếu tới UIInput element

  function render(container) {
    if (!container) return;
    $container = container;

    fetch('./src/pages/customers/customers.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;

        // 1. Action Toolbar (chỉ mount thanh nút, width = fit-content)
        var btnContainer = $container.querySelector('#customers-btn-container');
        if (btnContainer && typeof UIActionToolbar !== 'undefined') {
          var toolbar = UIActionToolbar.create({
            onAdd: _openAddForm,
            onEdit: function () {
              if (!selectedRow) return Alert.warning('Vui lòng chọn khách hàng cần sửa');
              _openEditForm(selectedRow);
            },
            onDelete: function () {
              if (!selectedRow) return Alert.warning('Vui lòng chọn khách hàng cần xóa');
              if (typeof ConfirmModal !== 'undefined') {
                ConfirmModal.show('Xác nhận xóa', 'Bạn có chắc muốn xóa khách hàng <b>' + selectedRow.TenKhach + '</b>?', function () {
                  Alert.success('Đã xóa thành công');
                  _loadData();
                });
              }
            },
            onPrint: function () { window.print(); }
          });
          // Co toolbar vừa nội dung (không chiếm toàn width)
          toolbar.style.display = 'inline-flex';
          toolbar.style.width = 'auto';
          btnContainer.appendChild(toolbar);
        }

        // 2. Search bar — dùng UIInput.createText() + nút tìm kiếm
        var filterContainer = $container.querySelector('#customers-filter-container');
        if (filterContainer && typeof UIInput !== 'undefined') {
          // Wrapper input không có label => dùng _createBaseWrapper thông qua createText với config không label
          var inputWrapper = UIInput.createText({
            id: 'input-search-customers',
            placeholder: 'Tìm kiếm theo mã, tên, số điện thoại...',
            className: '' // không cần form-group column, dùng inline
          });
          // UIInput trả về .form-group (flex-column) — cần override để inline
          inputWrapper.style.flexDirection = 'row';
          inputWrapper.style.alignItems = 'center';
          $inputSearch = inputWrapper.querySelector('#input-search-customers');
          if ($inputSearch) {
            $inputSearch.style.width = '300px';
            $inputSearch.style.minWidth = '220px';
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
      .catch(function(err) {
        $container.innerHTML = '<div class="p-4 text-danger">Lỗi tải giao diện: ' + err.message + '</div>';
      });
  }

  function _loadData(keyword) {
    var searchKey = keyword || '';

    var gridContainer = $container ? $container.querySelector('#customers-grid-container') : null;
    if (gridContainer) gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">Đang tải dữ liệu...</div>';

    if (typeof BookingService !== 'undefined') {
      BookingService.searchCustomer(searchKey).then(function(data) {
        customersData = data.map(function(item) {
          return {
            id: item.Id || item.Makh,
            MaKH: item.Makh || '---',
            TenKhach: [item.Tenchure, item.Tencodau].filter(Boolean).join(' & ') || item.Tenkh || 'Chưa có tên',
            DienThoai: item.Dienthoai || item.DTchure || item.DTcodau || '---',
            Email: item.Mail || '---',
            DiaChi: item.Diachi || '---',
            SoLanThamQuan: item.SoLanThamQuan || 0,
            SoHopDong: item.SoHopDong || 0
          };
        });
        _renderTable();
      }).catch(function(err) {
        console.error('Lỗi tải danh sách khách hàng:', err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi kết nối khi lấy danh sách khách hàng!');
        customersData = [];
        _renderTable();
      });
    } else {
      if (typeof Alert !== 'undefined') Alert.warning('Không tìm thấy BookingService để gọi API');
    }
  }

  function _renderTable() {
    var gridContainer = $container.querySelector('#customers-grid-container');
    if (!gridContainer) return;
    gridContainer.innerHTML = '';
    selectedRow = null;

    if (typeof UITable !== 'undefined') {
      var tableEl = UITable.create({
        headers: [
          { label: 'Mã KH', width: '100px' },
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
          { field: 'TenKhach', render: function(v) { return '<span style="color:var(--color-primary);font-weight:600;">' + v + '</span>'; } },
          { field: 'DienThoai' },
          { field: 'Email' },
          { field: 'DiaChi' },
          { field: 'SoLanThamQuan', align: 'center' },
          { field: 'SoHopDong', align: 'center' }
        ]
      });

      gridContainer.appendChild(tableEl);

      // Chọn dòng
      var tbody = tableEl.querySelector('tbody');
      if (tbody) {
        tbody.addEventListener('click', function(e) {
          var tr = e.target.closest('tr');
          if (!tr || tr.children.length === 1) return;
          Array.from(tbody.querySelectorAll('tr')).forEach(function(r) { r.classList.remove('active'); });
          tr.classList.add('active');
          var idx = Array.from(tbody.children).indexOf(tr);
          selectedRow = customersData[idx] || null;
        });
        tbody.addEventListener('dblclick', function(e) {
          var tr = e.target.closest('tr');
          if (!tr || !selectedRow) return;
          _openEditForm(selectedRow);
        });
      }
    } else {
      gridContainer.innerHTML = '<div class="text-danger p-4">Không tìm thấy component UITable</div>';
    }
  }

  function _openAddForm() {
    Alert.info('Chức năng Thêm Khách hàng đang phát triển');
  }

  function _openEditForm(row) {
    Alert.info('Chức năng Sửa Khách hàng [' + row.TenKhach + '] đang phát triển');
  }

  return {
    render: render
  };

})();
