var MenusPage = (function () {
  var $container;
  var allMenus = [];

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/menus/menus.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _bindEvents();
        _loadMenus();
      });
  }

  function _bindEvents() {
    $container.querySelector('#btn-refresh-menus').addEventListener('click', _loadMenus);
    
    $container.querySelector('#btn-add-menu').addEventListener('click', function() {
      _openModal(false);
    });

    $container.querySelector('#btn-close-modal').addEventListener('click', _closeModal);
    $container.querySelector('#btn-cancel-modal').addEventListener('click', _closeModal);
    
    $container.querySelector('#btn-save-menu').addEventListener('click', _saveMenu);

    $container.querySelector('#menu-tree-table tbody').addEventListener('click', function (e) {
      var btnEdit = e.target.closest('.btn-edit-menu');
      if (btnEdit) {
        var id = btnEdit.getAttribute('data-id');
        var menu = allMenus.find(m => m.id === id);
        if (menu) _openModal(true, menu);
      }

      var btnDel = e.target.closest('.btn-delete-menu');
      if (btnDel) {
        var id = btnDel.getAttribute('data-id');
        if (confirm('Bạn có chắc chắn muốn xóa Menu ' + id + ' không? Lưu ý: Hành động này sẽ xóa luôn các Menu con của nó.')) {
          _deleteMenu(id);
        }
      }
    });
  }

  function _loadMenus() {
    var tbody = $container.querySelector('#menu-tree-table tbody');
    tbody.innerHTML = '<tr><td colspan="5" class="text-center">Đang tải danh sách...</td></tr>';
    
    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.Group || currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    var endpoint = window.API_CONFIG?.ENDPOINTS?.MENUS?.GET_ALL || '/api/API_WA_LayDanhSachMenuAll';
    ApiClient.post(endpoint, { NhomNguoiDangThaoTac: myGroupId })
      .then(function(res) {
        if (res && res.code === 0) {
          allMenus = res.records || [];
          _renderMenus();
        } else {
          tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Lỗi: ' + (res.msg || 'Không thể tải') + '</td></tr>';
        }
      })
      .catch(function(err) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Lỗi kết nối máy chủ</td></tr>';
      });
  }

  function _renderMenus() {
    var tbody = $container.querySelector('#menu-tree-table tbody');
    
    // Tìm các node root (parent rỗng hoặc không có parent)
    var rootNodes = allMenus.filter(m => !m.parent || m.parent.trim() === '');
    
    // Build tree function
    function buildNodeHTML(node, level) {
      var padding = level * 30 + 12;
      var hasChildren = allMenus.some(m => m.parent === node.id);
      
      var iconHtml = UIIcon.renderHtml(node.icon, 'vertical-align: middle; font-size: 18px;');
      var folderIcon = hasChildren ? 'folder_open' : 'insert_drive_file';
      
      var html = `
        <tr>
          <td style="padding-left: ${padding}px;">
            <div style="display: flex; align-items: center; gap: 8px;">
              <span class="material-symbols-outlined" style="color: ${hasChildren ? 'var(--color-primary)' : 'var(--color-text-secondary)'}; font-size: 20px;">
                ${folderIcon}
              </span>
              <span style="font-weight: ${hasChildren ? '600' : '400'};">${node.label || '(Không tên)'}</span>
            </div>
          </td>
          <td style="color: var(--color-text-secondary);">${node.en || '<span style="opacity: 0.3;">(Trống)</span>'}</td>
          <td><code style="background: rgba(0,0,0,0.05); padding: 2px 6px; border-radius: 4px;">${node.id}</code></td>
          <td style="color: var(--color-text-secondary);">
            ${node.formName || '<i>(Nhóm cha)</i>'}
            ${node.isDisable ? '<span class="badge bg-danger" style="margin-left: 8px; font-size: 10px; padding: 2px 6px; border-radius: 4px;">Đã Ẩn</span>' : ''}
          </td>
          <td style="color: var(--color-text-secondary);">
            ${iconHtml}
            ${node.icon ? `<span style="font-size: 12px; opacity: 0.7; margin-left: 4px;">(${node.icon})</span>` : ''}
          </td>
          <td class="text-center" style="white-space: nowrap;">
            <button class="btn btn-sm btn-secondary btn-edit-menu" data-id="${node.id}" style="padding: 4px 8px;" title="Sửa">
              <span class="material-symbols-outlined" style="font-size: 16px;">edit</span>
            </button>
            <button class="btn btn-sm btn-danger btn-delete-menu" data-id="${node.id}" style="padding: 4px 8px; margin-left: 4px;" title="Xóa">
              <span class="material-symbols-outlined" style="font-size: 16px;">delete</span>
            </button>
          </td>
        </tr>
      `;
      
      // Tìm các con của node này và đệ quy
      var children = allMenus.filter(m => m.parent === node.id);
      children.forEach(child => {
        html += buildNodeHTML(child, level + 1);
      });
      
      return html;
    }

    var finalHtml = '';
    rootNodes.forEach(root => {
      finalHtml += buildNodeHTML(root, 0);
    });

    if (finalHtml === '') finalHtml = '<tr><td colspan="5" class="text-center">Chưa có Menu nào. Vui lòng Thêm mới.</td></tr>';
    tbody.innerHTML = finalHtml;
  }

  function _openModal(isEdit, menu = null) {
    var modal = $container.querySelector('#modal-menu-form');
    var title = $container.querySelector('#modal-menu-title');
    var isEditInput = $container.querySelector('#menu-is-edit');
    var oldIdInput = $container.querySelector('#menu-old-id');
    
    // Render dropdown Parent
    var selectParent = $container.querySelector('#menu-parent');
    var rootNodes = allMenus.filter(m => !m.parent || m.parent.trim() === '');
    var optionsHtml = '<option value="">-- Là Nhóm Cha (Root) --</option>';
    rootNodes.forEach(n => {
      // Không cho tự chọn chính mình làm cha
      if (!isEdit || n.id !== menu.id) {
        optionsHtml += `<option value="${n.id}">${n.label} (${n.id})</option>`;
      }
    });
    selectParent.innerHTML = optionsHtml;

    if (isEdit && menu) {
      title.innerText = 'Sửa Menu: ' + menu.label;
      isEditInput.value = '1';
      oldIdInput.value = menu.id;
      
      $container.querySelector('#menu-id').value = menu.id || '';
      $container.querySelector('#menu-parent').value = menu.parent || '';
      $container.querySelector('#menu-label').value = menu.label || '';
      $container.querySelector('#menu-en').value = menu.en || '';
      $container.querySelector('#menu-formname').value = menu.formName || '';
      $container.querySelector('#menu-icon').value = menu.icon || '';
      $container.querySelector('#menu-is-disable').checked = (menu.isDisable === 1 || menu.isDisable === true);
    } else {
      title.innerText = 'Thêm mới Menu';
      isEditInput.value = '0';
      oldIdInput.value = '';
      
      $container.querySelector('#menu-id').value = '';
      $container.querySelector('#menu-parent').value = '';
      $container.querySelector('#menu-label').value = '';
      $container.querySelector('#menu-en').value = '';
      $container.querySelector('#menu-formname').value = '';
      $container.querySelector('#menu-icon').value = '';
      $container.querySelector('#menu-is-disable').checked = false;
    }

    modal.style.display = 'flex';
  }

  function _closeModal() {
    $container.querySelector('#modal-menu-form').style.display = 'none';
  }

  function _saveMenu() {
    var id = $container.querySelector('#menu-id').value.trim();
    var label = $container.querySelector('#menu-label').value.trim();
    var en = $container.querySelector('#menu-en').value.trim();
    var parent = $container.querySelector('#menu-parent').value;
    var formName = $container.querySelector('#menu-formname').value.trim();
    var icon = $container.querySelector('#menu-icon').value.trim();
    var isDisable = $container.querySelector('#menu-is-disable').checked ? 1 : 0;
    var isEdit = $container.querySelector('#menu-is-edit').value === '1';
    var oldId = $container.querySelector('#menu-old-id').value;

    if (!id || !label) {
      if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Vui lòng nhập Menu ID và Tên Menu');
      return;
    }

    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.Group || currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    var payload = {
      NhomNguoiDangThaoTac: myGroupId,
      MenuID: id,
      OldMenuID: oldId,
      ParentID: parent,
      Label: label,
      EN: en,
      FormName: formName,
      Icon: icon,
      IsDisable: isDisable,
      IsEdit: isEdit ? 1 : 0
    };

    var btn = $container.querySelector('#btn-save-menu');
    btn.disabled = true;
    btn.innerText = 'Đang lưu...';

    var endpoint = window.API_CONFIG?.ENDPOINTS?.MENUS?.SAVE || '/api/API_WA_LuuMenu';
    ApiClient.post(endpoint, payload)
      .then(function(res) {
        if (res && res.code === 0) {
          if (typeof Alert !== 'undefined') Alert.success('Thành công', 'Đã lưu Menu thành công!');
          _closeModal();
          _loadMenus(); // Reload grid
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', res.msg || 'Lưu thất bại');
        }
      })
      .catch(function(err) {
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Kết nối máy chủ bị gián đoạn');
      })
      .finally(function() {
        btn.disabled = false;
        btn.innerText = 'Lưu Thông Tin';
      });
  }

  function _deleteMenu(menuId) {
    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.Group || currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    var endpoint = window.API_CONFIG?.ENDPOINTS?.MENUS?.DELETE || '/api/API_WA_XoaMenu';
    ApiClient.post(endpoint, { NhomNguoiDangThaoTac: myGroupId, MenuID: menuId })
      .then(function(res) {
        if (res && res.code === 0) {
          if (typeof Alert !== 'undefined') Alert.success('Thành công', 'Đã xóa Menu thành công!');
          _loadMenus(); // Reload grid
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', res.msg || 'Xóa thất bại');
        }
      })
      .catch(function(err) {
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Kết nối máy chủ bị gián đoạn');
      });
  }

  return { render: render };
})();
