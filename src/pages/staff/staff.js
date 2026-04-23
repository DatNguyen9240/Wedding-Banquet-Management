/**
 * Trang Quản lý Nhân viên Phục vụ Tiệc
 */
window.StaffPage = (function () {

  var grid = null;
  var btnBar = null;

  function render(container) {
    if (!container) return;

    if (typeof ActionToolbar !== 'undefined') {
      btnBar = new ActionToolbar({
        container: container.querySelector('#staff-btn-container'),
        module: 'NhanSu',
        buttons: ['add', 'edit', 'delete', 'filter', 'print'],
        onAdd: _openAddForm,
        onEdit: function () {
          if (!grid) return;
          var selected = grid.getSelectedRow();
          if (!selected) return Alert.warn('Vui lòng chọn nhân viên cần sửa');
          _openEditForm(selected);
        },
        onDelete: function () {
          if (!grid) return;
          var selected = grid.getSelectedRow();
          if (!selected) return Alert.warn('Vui lòng chọn nhân viên cần xóa');
          if (typeof ConfirmModal !== 'undefined') {
            ConfirmModal.show('Xác nhận xóa', 'Bạn có chắc muốn xóa nhân viên <b>' + selected.HoTen + '</b>?', function () {
              Alert.success('Đã xóa thành công');
              _loadData();
            });
          }
        },
        onPrint: function () {
          window.print();
        }
      });
    }

    if (typeof Table !== 'undefined') {
      grid = new Table({
        container: container.querySelector('#staff-grid-container'),
        columns: [
          { key: 'MaNV', label: 'Mã NV', width: '90px' },
          { key: 'HoTen', label: 'Họ tên', width: '200px' },
          { key: 'GioiTinh', label: 'Giới tính', width: '90px', align: 'center' },
          { key: 'DienThoai', label: 'Điện thoại', width: '120px' },
          { key: 'LoaiHopDong', label: 'Loại HĐ', width: '130px' },
          { key: 'MucLuong', label: 'Mức lương', width: '130px', type: 'currency', align: 'right' },
          { key: 'DanhGia', label: 'Đánh giá', width: '100px', align: 'center' }
        ],
        onRowClick: function (row) {},
        onRowDblClick: function (row) {
          _openEditForm(row);
        }
      });
    }

    var btnSearch = container.querySelector('#btn-search-staff');
    if (btnSearch) {
      btnSearch.addEventListener('click', function() {
        Alert.info('Đang tìm kiếm nhân sự...');
      });
    }

    _loadData();
  }

  function _loadData() {
    if (!grid) return;
    
    if (typeof MockData !== 'undefined' && MockData.nhanVienPhucVu) {
      grid.load(MockData.nhanVienPhucVu);
    } else {
      grid.load([
        { id: 1, MaNV: 'PV001', HoTen: 'Nguyễn Văn Tèo', GioiTinh: 'Nam', DienThoai: '0901234567', LoaiHopDong: 'Thời vụ', MucLuong: 200000, DanhGia: '8.5' },
        { id: 2, MaNV: 'PV002', HoTen: 'Trần Thị Nở', GioiTinh: 'Nữ', DienThoai: '0912345678', LoaiHopDong: 'Bán thời gian', MucLuong: 4000000, DanhGia: '9.0' },
        { id: 3, MaNV: 'PV003', HoTen: 'Lê Chí Phèo', GioiTinh: 'Nam', DienThoai: '0923456789', LoaiHopDong: 'Fulltime', MucLuong: 6000000, DanhGia: '7.5' },
        { id: 4, MaNV: 'PV004', HoTen: 'Thị Kính', GioiTinh: 'Nữ', DienThoai: '0988888888', LoaiHopDong: 'Thời vụ', MucLuong: 250000, DanhGia: '9.5' }
      ]);
    }
  }

  function _openAddForm() {
    if (typeof Alert !== 'undefined') {
      Alert.info('Chức năng Thêm Nhân viên đang phát triển');
    }
  }

  function _openEditForm(row) {
    if (typeof Alert !== 'undefined') {
      Alert.info('Chức năng Sửa Nhân viên [' + row.HoTen + '] đang phát triển');
    }
  }

  return {
    render: render
  };

})();
