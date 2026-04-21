/**
 * Màn hình Quản lý Danh sách Người dùng
 */
var UsersPage = (function () {
  var $container;

  var usersData = window.MockData ? window.MockData.usersData : [];
  var groupData = window.MockData ? window.MockData.groupDataSimple : [];

  var selectedRowIndex = -1;

  function render(containerElement) {
    $container = containerElement;
    selectedRowIndex = -1; // reset

    var html = `
      <div class="page-title-bar">
        <span>Danh sách Người dùng Hệ thống</span>
      </div>

      <!-- THANH CÔNG CỤ (BUTTON BAR) -->
      <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
        <button class="btn btn-tool" id="btn-add"><span class="material-symbols-outlined">add_circle</span>Thêm</button>
        <button class="btn btn-tool" id="btn-edit"><span class="material-symbols-outlined">edit</span>Sửa</button>
        <button class="btn btn-tool text-danger" id="btn-delete"><span class="material-symbols-outlined">delete</span>Xóa</button>
        <div class="divider"></div>
        <button class="btn btn-tool" id="btn-filter"><span class="material-symbols-outlined">filter_list</span>Lọc</button>
        <button class="btn btn-tool" id="btn-print"><span class="material-symbols-outlined">print</span>In</button>
      </div>

      <!-- DATAGRID -->
      <div class="card" style="animation: slideUp 0.4s ease forwards;">
        <div class="table-wrapper">
          <table class="data-table selectable" id="users-table">
            <thead>
              <tr>
                <th style="width: 50px; text-align: center;">STT</th>
                <th>Mã NV</th>
                <th>Tên Đăng Nhập</th>
                <th>Họ Tên</th>
                <th>Nhóm Quyền</th>
                <th style="text-align: center;">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <!-- RENDER BỞI JS -->
            </tbody>
          </table>
        </div>
      </div>
    `;

    $container.innerHTML = html;
    _renderTable();
    _bindEvents();
  }

  function _renderTable() {
    var tbody = $container.querySelector('#users-table tbody');
    tbody.innerHTML = '';

    usersData.forEach(function(user, idx) {
      var tr = document.createElement('tr');
      if (idx === selectedRowIndex) tr.classList.add('selected');
      
      var statusIcon = user.disabled 
        ? '<span class="status-badge" style="background:var(--color-danger); color:#fff; padding:2px 6px; border-radius:4px; font-size:11px;">Khóa</span>'
        : '<span class="status-badge" style="background:var(--color-success); color:#fff; padding:2px 6px; border-radius:4px; font-size:11px;">Hoạt động</span>';

      tr.innerHTML = `
        <td style="text-align: center;">${idx + 1}</td>
        <td style="font-weight: 500; color: var(--color-primary);">${user.id}</td>
        <td>${user.username}</td>
        <td>${user.name}</td>
        <td>${user.group}</td>
        <td style="text-align: center;">${statusIcon}</td>
      `;

      tr.addEventListener('click', function() {
        // Đổi màu dòng chọn
        var rows = tbody.querySelectorAll('tr');
        rows.forEach(r => r.classList.remove('selected'));
        tr.classList.add('selected');
        selectedRowIndex = idx;
      });

      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-add').addEventListener('click', function() {
      _openUserModal(null);
    });

    $container.querySelector('#btn-edit').addEventListener('click', function() {
      if (selectedRowIndex < 0) return alert('Vui lòng chọn 1 dòng để sửa!');
      _openUserModal(selectedRowIndex);
    });

    $container.querySelector('#btn-delete').addEventListener('click', function() {
      if (selectedRowIndex < 0) return alert('Vui lòng chọn 1 dòng để xóa!');
      var confirmDel = confirm('Bạn có chắc muốn xóa tải khoản ' + usersData[selectedRowIndex].username + '?');
      if(confirmDel) {
         usersData.splice(selectedRowIndex, 1);
         selectedRowIndex = -1;
         _renderTable();
      }
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
            <button class="btn-close-modal" id="btn-close"><span class="material-symbols-outlined">close</span></button>
          </div>
          <div class="modal-body" style="padding: 20px;">
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
          <div class="modal-footer" style="padding: 16px 20px; border-top: 1px solid var(--color-border); display: flex; justify-content: flex-end; gap: 12px; background: #F8FAFC;">
            <button class="btn btn-secondary" id="btn-cancel">Hủy bỏ</button>
            <button class="btn btn-primary" id="btn-save">LƯU THÔNG TIN</button>
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
    // Set value if edit
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

       if(!newId || !newUser || !newName) return alert('Vui lòng nhập đủ thông tin bắt buộc!');

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
