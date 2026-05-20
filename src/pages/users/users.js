/**
 * Màn hình Quản lý Danh sách Người dùng
 * HTML Template: src/pages/users.html
 */
var UsersPage = (function () {
  var $container;

  var usersData = window.MockData ? window.MockData.usersData : [];
  var groupData = window.MockData ? window.MockData.groupDataSimple : [];

  var selectedRowIndex = -1;

  var PAGE_SIZE = 8;
  var currentPage = 1;

  function render(containerElement) {
    $container = containerElement;
    selectedRowIndex = -1;
    currentPage = 1;

    LoadingSpinner.show('Đang tải danh sách người dùng...');
    fetch('./src/pages/users/users.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _mountToolbar();
        _renderTable();
        _bindEvents();
        LoadingSpinner.hide();
      });
  }

  function _mountToolbar() {
    var toolbarEl = $container.querySelector('#users-toolbar');
    if (!toolbarEl) return;
    toolbarEl.appendChild(UIActionToolbar.create({
      onAdd: function() { _openUserModal(null); },
      onEdit: function() {
        if (selectedRowIndex < 0) return Alert.warn('Vui lòng chọn 1 dòng để sửa!');
        _openUserModal(selectedRowIndex);
      },
      onDelete: function() {
        if (selectedRowIndex < 0) return Alert.warn('Vui lòng chọn 1 dòng để xóa!');
        var u = usersData[selectedRowIndex];
        ConfirmModal.show({
          title: 'Xác nhận xóa tài khoản',
          message: 'Bạn có chắc muốn xóa tài khoản <b>' + u.username + '</b>? Hành động này không thể hoàn tác.',
          onConfirm: function() {
            usersData.splice(selectedRowIndex, 1);
            selectedRowIndex = -1;
            currentPage = 1;
            _renderTable();
            UIToast.show('Đã xóa tài khoản thành công', 'success');
          }
        });
      },
      onPrint: function() { window.print(); },
      onClose: function() { Alert.info('Đóng trang Người dùng'); }
    }));
  }

  function _renderTable() {
    var tbody = $container.querySelector('#users-table tbody');
    tbody.innerHTML = '';

    var total = usersData.length;
    var startIdx = (currentPage - 1) * PAGE_SIZE;
    var pageData = usersData.slice(startIdx, startIdx + PAGE_SIZE);

    if (pageData.length === 0) {
      tbody.innerHTML = UIEmptyState.createTableRowHTML({ colspan: 6, text: 'Chưa có người dùng nào trong hệ thống.' });
    } else {
      pageData.forEach(function(user, idx) {
        var tr = document.createElement('tr');
        var absIdx = startIdx + idx;
        if (absIdx === selectedRowIndex) tr.classList.add('selected');

        var statusBadge = user.disabled
          ? UIBadge.createHTML('Khóa', 'danger', 'padding:2px 6px; border-radius:4px; font-size:11px;')
          : UIBadge.createHTML('Hoạt động', 'success', 'padding:2px 6px; border-radius:4px; font-size:11px;');

        tr.innerHTML = `
          <td class="text-center">${absIdx + 1}</td>
          <td class="fw-medium" style="color: var(--color-primary);">${user.id}</td>
          <td>${user.username}</td>
          <td>${user.name}</td>
          <td>${user.group}</td>
          <td class="text-center">${statusBadge}</td>
        `;

        tr.addEventListener('click', function() {
          tbody.querySelectorAll('tr').forEach(r => r.classList.remove('selected'));
          tr.classList.add('selected');
          selectedRowIndex = absIdx;
        });

        tbody.appendChild(tr);
      });
    }

    // Render Pagination
    var paginationEl = $container.querySelector('#users-pagination');
    if (paginationEl) {
      paginationEl.innerHTML = '';
      if (total > PAGE_SIZE) {
        paginationEl.appendChild(Pagination.create({
          totalItems: total,
          itemsPerPage: PAGE_SIZE,
          currentPage: currentPage,
          onPageChange: function(page) {
            currentPage = page;
            selectedRowIndex = -1;
            _renderTable();
          }
        }));
      }
    }
  }

  function _bindEvents() {
    // Toolbar buttons are mounted via UIActionToolbar — legacy buttons kept for fallback
    var btnAdd = $container.querySelector('#btn-add');
    var btnEdit = $container.querySelector('#btn-edit');
    var btnDel = $container.querySelector('#btn-delete');
    if (btnAdd) btnAdd.addEventListener('click', function() { _openUserModal(null); });
    if (btnEdit) btnEdit.addEventListener('click', function() {
      if (selectedRowIndex < 0) return Alert.warn('Vui lòng chọn 1 dòng để sửa!');
      _openUserModal(selectedRowIndex);
    });
    if (btnDel) btnDel.addEventListener('click', function() {
      if (selectedRowIndex < 0) return Alert.warn('Vui lòng chọn 1 dòng để xóa!');
      var u = usersData[selectedRowIndex];
      ConfirmModal.show({
        title: 'Xác nhận xóa tài khoản',
        message: 'Bạn có chắc muốn xóa tài khoản <b>' + u.username + '</b>?',
        onConfirm: function() {
          usersData.splice(selectedRowIndex, 1);
          selectedRowIndex = -1;
          currentPage = 1;
          _renderTable();
          UIToast.show('Đã xóa thành công', 'success');
        }
      });
    });
  }

  function _openUserModal(editIndex) {
    var isEdit = (editIndex !== null && editIndex >= 0);
    var uData = isEdit ? usersData[editIndex] : { id: '', name: '', username: '', group: '', disabled: false };

    var modalHtml = `
      <div class="modal-overlay" id="user-modal">
        <div class="modal-content" style="width: 500px;">
          <div class="modal-header">
            <h3>${isEdit ? 'Sửa thông tin tài khoản' : 'Thêm tài khoản mới'}</h3>
            <button class="btn-close-modal" id="btn-close">${UIIcon.createHTML('close')}</button>
          </div>
          <div class="modal-body p-3">
            <div class="form-group mb-3">
              <label>Mã Nhân Viên</label>
              <input type="text" class="ui-input" id="u-mid" value="${uData.id}" placeholder="NV..." ${isEdit ? 'disabled' : ''}>
            </div>
            <div class="form-group mb-3">
              <label>Họ Tên</label>
              <input type="text" class="ui-input" id="u-name" value="${uData.name}" placeholder="Nhập họ tên...">
            </div>
            <div class="form-group mb-3">
              <label>Tên Đăng Nhập</label>
              <input type="text" class="ui-input" id="u-user" value="${uData.username}" placeholder="Username...">
            </div>
            <div class="form-group mb-3">
              <label>Nhóm Quyền (Gõ để tìm kiếm)</label>
              <div id="u-group-wrapper"></div>
            </div>
            <div class="form-group mb-3" id="u-status-wrapper">
            </div>
          </div>
          <div class="modal-footer d-flex justify-content-end gap-2 p-3" style="border-top: 1px solid var(--color-border); background: var(--color-background);">
            ${UIButton.createHTML({ id: 'btn-cancel', text: 'Hủy bỏ', type: 'secondary' })}
            ${UIButton.createHTML({ id: 'btn-save', text: 'LƯU THÔNG TIN', type: 'primary' })}
          </div>
        </div>
      </div>
    `;

    var mContainer = document.getElementById('modal-container');
    mContainer.innerHTML = modalHtml;

    // Mout Custom Controls
    var uiGroupCombo = UIControls.createDataComboBox({
      placeholder: 'Chọn vào nhóm...',
      headers: ['Mã Nhóm', 'Tên Nhóm'],
      data: groupData,
      colFilterIndex: 1,
      colHighlightIndex: 1
    });
    if(isEdit) uiGroupCombo.querySelector('.ui-input').value = uData.group;
    mContainer.querySelector('#u-group-wrapper').appendChild(uiGroupCombo);

    var uiStatusCheck = UIControls.createCheckbox({
       label: 'Ngưng sử dụng (Khóa tài khoản)',
       checked: uData.disabled
    });
    mContainer.querySelector('#u-status-wrapper').appendChild(uiStatusCheck);

    // Event handlers
    function closeModal() { mContainer.innerHTML = ''; }
    mContainer.querySelector('#btn-close').addEventListener('click', closeModal);
    mContainer.querySelector('#btn-cancel').addEventListener('click', closeModal);

    mContainer.querySelector('#btn-save').addEventListener('click', function() {
       var newId = mContainer.querySelector('#u-mid').value.trim();
       var newName = mContainer.querySelector('#u-name').value.trim();
       var newUser = mContainer.querySelector('#u-user').value.trim();
       var newGroup = uiGroupCombo.querySelector('.ui-input').value.trim();
       var newStatus = uiStatusCheck.querySelector('input').checked;

       if(!newId || !newUser || !newName) { UIToast.show('Vui lòng nhập đủ thông tin bắt buộc!', 'warning'); return; }

       if (isEdit) {
         usersData[editIndex].name = newName;
         usersData[editIndex].username = newUser;
         usersData[editIndex].group = newGroup;
         usersData[editIndex].disabled = newStatus;
       } else {
         usersData.push({ id: newId, name: newName, username: newUser, group: newGroup, disabled: newStatus });
       }
       _renderTable();
       closeModal();
    });
  }

  return { render: render };
})();
