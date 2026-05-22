/**
 * Action Toolbar Component
 * Thanh công cụ chuẩn 6 nút: Thêm, Sửa, Xóa, Lọc, In, Đóng theo REQUIREMENT.md
 */
var UIActionToolbar = (function () {

  /**
   * Sinh thanh Toolbar nghiệp vụ
   * @param {Object} actions - { onAdd, onEdit, onDelete, onFilter, onPrint, onClose }
   */
  function create(actions) {
    actions = actions || {};
    
    return UIButton.createBar([
      { text: 'Thêm',  icon: 'add',        type: 'tool', onClick: actions.onAdd,    attrs: 'data-tooltip="Thêm bản ghi mới (Ins)"' },
      { text: 'Sửa',   icon: 'edit',       type: 'tool', onClick: actions.onEdit,   attrs: 'data-tooltip="Sửa bản ghi đã chọn (F2)"' },
      { text: 'Xóa',   icon: 'delete',     type: 'tool', onClick: actions.onDelete, attrs: 'data-tooltip="Xóa bản ghi đã chọn (Del)"' },
      { text: 'Lọc',   icon: 'filter_alt', type: 'tool', onClick: actions.onFilter, attrs: 'data-tooltip="Lọc / Tìm kiếm dữ liệu"' },
      { text: 'In',    icon: 'print',      type: 'tool', onClick: actions.onPrint,  attrs: 'data-tooltip="In danh sách (Ctrl+P)"' },
      { text: 'Đóng',  icon: 'close',      type: 'tool', onClick: actions.onClose,  attrs: 'data-tooltip="Đóng trang hiện tại"' }
    ]);
  }

  return {
    create: create
  };
})();
