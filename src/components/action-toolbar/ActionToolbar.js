var UIActionToolbar = (function () {

  /**
   * Sinh thanh Toolbar nghiệp vụ dạng Dropdown gọn gàng
   * @param {Object} actions - { onAdd, onEdit, onDelete, onFilter, onPrint, onClose }
   */
  function create(actions) {
    actions = actions || {};
    
    var buttons = [
      { text: 'Thêm',  icon: 'add',        type: 'tool', onClick: actions.onAdd,    className: 'btn-tool-add',    attrs: 'data-tooltip="Thêm bản ghi mới (Ins)"' },
      { text: 'Sửa',   icon: 'edit',       type: 'tool', onClick: actions.onEdit,   className: 'btn-tool-edit',   attrs: 'data-tooltip="Sửa bản ghi đã chọn (F2)"' },
      { text: 'Xóa',   icon: 'delete',     type: 'tool', onClick: actions.onDelete, className: 'btn-tool-delete', attrs: 'data-tooltip="Xóa bản ghi đã chọn (Del)"' },
      { text: 'Lọc',   icon: 'filter_alt', type: 'tool', onClick: actions.onFilter, className: 'btn-tool-filter', attrs: 'data-tooltip="Lọc / Tìm kiếm dữ liệu"' },
      { text: 'In',    icon: 'print',      type: 'tool', onClick: actions.onPrint,  className: 'btn-tool-print',  attrs: 'data-tooltip="In danh sách (Ctrl+P)"' },
      { text: 'Đóng',  icon: 'close',      type: 'tool', onClick: actions.onClose,  className: 'btn-tool-close',  attrs: 'data-tooltip="Đóng trang hiện tại"' }
    ];

    if (actions.extras && Array.isArray(actions.extras)) {
      actions.extras.forEach(function (btn) {
        buttons.push(btn);
      });
    }

    var filteredButtons = [];
    buttons.forEach(function(b) {
      if (b.onClick === false) return; // Hide button
      if (b.onClick === 'DISABLED' || b.onClick === 'disabled') {
        b.disabled = true;
        b.onClick = function() {
          if (typeof Alert !== 'undefined') Alert.warning('Từ chối', 'Bạn không có quyền thao tác chức năng này!');
        };
      }
      filteredButtons.push(b);
    });

    // 1. Tạo container của Dropdown
    var container = document.createElement('div');
    container.className = 'action-dropdown button-bar';

    // 2. Tạo Trigger Button
    var trigger = document.createElement('button');
    trigger.className = 'btn btn-primary action-dropdown-trigger';
    trigger.innerHTML = `
      <span class="material-symbols-outlined icon-settings">settings</span>
      <span>Thao tác</span>
      <span class="material-symbols-outlined icon-arrow">arrow_drop_down</span>
    `;
    container.appendChild(trigger);

    // 3. Tạo Menu Container
    var menu = document.createElement('div');
    menu.className = 'action-dropdown-menu';
    container.appendChild(menu);

    // 4. Tạo các buttons bên trong menu
    filteredButtons.forEach(function(bConfig) {
      var btn = UIButton.create(bConfig);
      menu.appendChild(btn);
    });

    // 5. Toggle logic
    trigger.addEventListener('click', function(e) {
      e.stopPropagation();
      var isVisible = menu.style.display === 'block';
      
      // Đóng tất cả các action dropdown khác trước khi mở cái này
      document.querySelectorAll('.action-dropdown-menu').forEach(function(m) {
        m.style.display = 'none';
      });

      menu.style.display = isVisible ? 'none' : 'block';
    });

    // Close when clicking outside
    document.addEventListener('click', function() {
      menu.style.display = 'none';
    });

    return container;
  }

  return {
    create: create
  };
})();
