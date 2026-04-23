/**
 * Trang Quản lý Hồ sơ Khách hàng
 */
window.CustomersPage = (function () {

  var grid = null;
  var btnBar = null;

  function render(container) {
    if (!container) return;

    // 1. Khởi tạo ActionToolbar
    if (typeof ActionToolbar !== 'undefined') {
      btnBar = new ActionToolbar({
        container: container.querySelector('#customers-btn-container'),
        module: 'HopDong',
        buttons: ['add', 'edit', 'delete', 'filter', 'print'],
        onAdd: _openAddForm,
        onEdit: function () {
          if (!grid) return;
          var selected = grid.getSelectedRow();
          if (!selected) return Alert.warn('Vui lòng chọn khách hàng cần sửa');
          _openEditForm(selected);
        },
        onDelete: function () {
          if (!grid) return;
          var selected = grid.getSelectedRow();
          if (!selected) return Alert.warn('Vui lòng chọn khách hàng cần xóa');
          if (typeof ConfirmModal !== 'undefined') {
            ConfirmModal.show('Xác nhận xóa', 'Bạn có chắc muốn xóa khách hàng <b>' + selected.TenKhach + '</b>?', function () {
              Alert.success('Đã xóa thành công');
              _loadData(); // reload
            });
          }
        },
        onPrint: function () {
          window.print();
        }
      });
    }

    // 2. Khởi tạo DataGrid (Table)
    if (typeof Table !== 'undefined') {
      grid = new Table({
        container: container.querySelector('#customers-grid-container'),
        columns: [
          { key: 'MaKH', label: 'Mã KH', width: '100px' },
          { key: 'TenKhach', label: 'Tên Khách Hàng', width: '250px' },
          { key: 'DienThoai', label: 'Điện thoại', width: '120px' },
          { key: 'Email', label: 'Email', width: '200px' },
          { key: 'DiaChi', label: 'Địa chỉ' },
          { key: 'SoLanThamQuan', label: 'Tham quan', width: '100px', align: 'center' },
          { key: 'SoHopDong', label: 'Hợp đồng', width: '100px', align: 'center' }
        ],
        onRowClick: function (row) {
          // Xử lý khi click dòng (highlight do component tự làm)
        },
        onRowDblClick: function (row) {
          _openEditForm(row);
        }
      });
    }

    // 3. Search action
    var btnSearch = container.querySelector('#btn-search-customers');
    if (btnSearch) {
      btnSearch.addEventListener('click', function() {
        var keyword = container.querySelector('#input-search-customers').value;
        Alert.info('Đang tìm kiếm: ' + keyword);
      });
    }

    _loadData();
  }

  function _loadData() {
    if (!grid) return;
    
    // Đọc từ mockData
    if (typeof MockData !== 'undefined' && MockData.khachHang) {
      grid.load(MockData.khachHang);
    } else {
      // Fallback nếu mockData chưa có mảng khachHang
      grid.load([
        { id: 1, MaKH: 'KH0001', TenKhach: 'Trương Vô Kỵ - Triệu Mẫn', DienThoai: '0901234567', Email: 'ky.man@gmail.com', DiaChi: 'Quận 1, TP.HCM', SoLanThamQuan: 2, SoHopDong: 1 },
        { id: 2, MaKH: 'KH0002', TenKhach: 'Quách Tĩnh - Hoàng Dung', DienThoai: '0912345678', Email: 'tinh.dung@gmail.com', DiaChi: 'Quận 3, TP.HCM', SoLanThamQuan: 1, SoHopDong: 1 },
        { id: 3, MaKH: 'KH0003', TenKhach: 'Dương Quá - Tiểu Long Nữ', DienThoai: '0923456789', Email: 'qua.nu@gmail.com', DiaChi: 'Quận 5, TP.HCM', SoLanThamQuan: 3, SoHopDong: 0 }
      ]);
    }
  }

  function _openAddForm() {
    if (typeof Alert !== 'undefined') {
      Alert.info('Chức năng Thêm Khách hàng đang phát triển');
    }
  }

  function _openEditForm(row) {
    if (typeof Alert !== 'undefined') {
      Alert.info('Chức năng Sửa Khách hàng [' + row.TenKhach + '] đang phát triển');
    }
  }

  return {
    render: render
  };

})();
