/**
 * Màn hình Phân quyền Cán bộ (Sử dụng Tree Table & Role Tabs)
 * HTML Template: src/pages/permissions/permissions.html
 */
var PermissionsPage = (function () {
  var $container;

  var groups = [];
  var modules = window.MockData ? window.MockData.permissionModules : [];
  var currentSelectedGroup = null;

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/permissions/permissions.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;

        // CSS nhỏ cho tree table và role tabs
        var style = document.createElement('style');
        style.innerHTML = `
          .tree-row { transition: background 0.2s; }
          .tree-row:hover { background: rgba(148, 163, 184, 0.05); }
          .tree-cell { display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; }
          .tree-toggle { font-size: 20px; transition: transform 0.2s; color: var(--color-text-secondary); width: 20px; text-align: center; }
          .tree-toggle.open { transform: rotate(90deg); }
          .tree-toggle.empty { opacity: 0; pointer-events: none; }
          .tree-icon { font-size: 20px; color: var(--color-primary); }
          .tree-row[data-hidden="true"] { display: none; }

          .role-tab { padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s; margin-bottom: 4px; display: flex; align-items: center; gap: 8px; font-weight: 500; color: var(--color-text); }
          .role-tab:hover { background: rgba(148, 163, 184, 0.1); }
          .role-tab.active { background: rgba(60, 80, 224, 0.1); color: var(--color-primary); }
        `;
        $container.appendChild(style);

        _renderRoleTabs();
        _setupTreeToggle();

        $container.querySelector('#btn-save-permission').addEventListener('click', _savePermissions);
        var btnSync = $container.querySelector('#btn-sync-permission');
        if (btnSync) btnSync.addEventListener('click', _syncPermissions);

        _fetchGroups();
      });
  }

  function _fetchGroups() {
    var container = $container.querySelector('#role-list-container');
    if (container) {
      container.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--color-text-secondary);">Đang tải dữ liệu...</div>';
    }

    ApiClient.get(window.API_CONFIG.ENDPOINTS.PERMISSIONS.GET_GROUP_LIST || '/api/API_SY_LayDanhSachNhom')
      .then(function (res) {
        if (res && res.code === 0 && res.records) {
          groups = res.records;
          _renderRoleTabs();
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', res.msg || 'Không lấy được danh sách nhóm quyền');
          if (container) container.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--color-danger);">Lỗi tải dữ liệu</div>';
        }
      })
      .catch(function (err) {
        console.error(err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Lỗi kết nối máy chủ');
        if (container) container.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--color-danger);">Lỗi kết nối</div>';
      });
  }

  function _renderRoleTabs() {
    var container = $container.querySelector('#role-list-container');
    container.innerHTML = '';

    groups.forEach(function (g, idx) {
      var div = document.createElement('div');
      div.className = 'role-tab';
      if (idx === 0) div.classList.add('active');
      div.innerHTML = `<span class="material-symbols-outlined">group</span> ${g.name}`;

      div.addEventListener('click', function () {
        container.querySelectorAll('.role-tab').forEach(function (el) { el.classList.remove('active'); });
        div.classList.add('active');
        currentSelectedGroup = g;
        _renderTreeTableForGroup(g);
      });

      container.appendChild(div);

      if (idx === 0) {
        currentSelectedGroup = g;
      }
    });

    if (currentSelectedGroup) {
      _renderTreeTableForGroup(currentSelectedGroup);
    }
  }

  function _renderTreeTableForGroup(group) {
    var roleNameEl = $container.querySelector('#current-role-name');
    if (roleNameEl) roleNameEl.innerText = group.name;

    var tbody = $container.querySelector('#permission-tree-table tbody');
    tbody.innerHTML = '<tr><td colspan="5" class="text-center" style="padding: 16px;">Đang tải cấu trúc quyền...</td></tr>';

    var endpoint = window.API_CONFIG.ENDPOINTS.PERMISSIONS.GET_MENU_BY_GROUP || '/api/API_WA_LayMenuTheoNhomQuyen';

    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    // Gửi POST request để lấy menu theo nhóm
    ApiClient.post(endpoint, {
      NhomNguoiDangThaoTac: myGroupId,
      UserGroupID: group.id
    })
      .then(function (res) {
        if (res && res.code === 0 && res.records) {
          _buildTreeTableFromApi(group, res.records);
        } else {
          // Fallback
          var data = res.records || res.data || [];
          _buildTreeTableFromApi(group, data);
        }
      })
      .catch(function (err) {
        console.error(err);
        tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger">Lỗi kết nối khi tải quyền</td></tr>';
      });
  }

  function _buildTreeTableFromApi(group, records) {
    var tbody = $container.querySelector('#permission-tree-table tbody');
    tbody.innerHTML = '';

    // Root
    var rootId = 'root';
    _appendRow(tbody, {
      id: rootId,
      parentId: null,
      level: 0,
      label: 'Hệ thống Quản lý Tiệc Cưới',
      icon: 'business',
      isFolder: true,
      expanded: true
    });

    if (!records || records.length === 0) {
      tbody.innerHTML += '<tr><td colspan="5" class="text-center text-muted">Chưa có dữ liệu phân quyền cho nhóm này</td></tr>';
      return;
    }

    records.forEach(function (item, mIdx) {
      var modId = item.id || item.Id || item.MenuId || ('mod_' + mIdx);
      var modName = item.label || item.Label || item.name || item.Name || item.TenMenu || item.MenuName || ('Chức năng ' + mIdx);
      var parent = item.parent || item.Parent;
      var parentId = parent ? parent : rootId;
      var level = parent ? 2 : 1;

      var isFolder = records.some(function (r) {
        return (r.parent || r.Parent) === modId;
      });

      var canXem = item.xem || item.Xem || item.CanView || item.View || item.IsRun || false;
      var canThem = item.them || item.Them || item.CanAdd || item.Add || item.IsAdd || false;
      var canSua = item.sua || item.Sua || item.CanEdit || item.Edit || item.IsUpdate || false;
      var canXoa = item.xoa || item.Xoa || item.CanDelete || item.Delete || item.IsDelete || false;

      var rawIcon = (item.icon || item.IconClass || '').toLowerCase().trim();
      var parsedIcon = 'folder';
      if (rawIcon) {
        if (rawIcon.includes('grid')) parsedIcon = 'grid_view';
        else if (rawIcon.includes('home')) parsedIcon = 'home';
        else if (rawIcon.includes('user') || rawIcon.includes('person') || rawIcon.includes('account')) parsedIcon = 'person';
        else if (rawIcon.includes('setting') || rawIcon.includes('gear') || rawIcon.includes('config')) parsedIcon = 'settings';
        else if (rawIcon.includes('report') || rawIcon.includes('chart') || rawIcon.includes('stats')) parsedIcon = 'bar_chart';
        else if (rawIcon.includes('list') || rawIcon.includes('table')) parsedIcon = 'list_alt';
        else if (rawIcon.includes('file') || rawIcon.includes('doc')) parsedIcon = 'description';
        else if (rawIcon.includes('bell') || rawIcon.includes('notify')) parsedIcon = 'notifications';
        else if (rawIcon.indexOf('-') === -1 && rawIcon.indexOf(' ') === -1) {
          // If it has no spaces or dashes, it might be a valid material icon name (e.g. 'business')
          parsedIcon = rawIcon;
        }
      }

      _appendRow(tbody, {
        id: modId,
        parentId: parentId,
        level: level,
        label: modName,
        icon: parsedIcon,
        isFolder: isFolder,
        expanded: isFolder, // Open folders by default
        hidden: false,
        perms: {
          xem: canXem,
          them: canThem,
          sua: canSua,
          xoa: canXoa
        }
      });
    });
  }

  function _setupTreeToggle() {
    var tbody = $container.querySelector('#permission-tree-table tbody');
    tbody.addEventListener('click', function (e) {
      var cell = e.target.closest('.tree-cell');
      if (!cell) return;
      var tr = cell.closest('tr');
      var isFolder = tr.getAttribute('data-is-folder') === 'true';
      if (!isFolder) return;

      var id = tr.getAttribute('data-id');
      var isExpanded = tr.getAttribute('data-expanded') === 'true';
      var toggleIcon = tr.querySelector('.tree-toggle');
      var folderIcon = tr.querySelector('.tree-icon');

      isExpanded = !isExpanded;
      tr.setAttribute('data-expanded', isExpanded);
      if (toggleIcon) {
        if (isExpanded) toggleIcon.classList.add('open');
        else toggleIcon.classList.remove('open');
      }
      if (folderIcon) {
        if (id === 'root') {
          folderIcon.innerText = 'business';
        } else {
          folderIcon.innerText = isExpanded ? 'folder_open' : 'folder';
        }
      }

      // Hide/show children recursively
      _toggleChildren(tbody, id, isExpanded);
    });
  }

  function _toggleChildren(tbody, parentId, show) {
    var children = tbody.querySelectorAll('tr[data-parent="' + parentId + '"]');
    children.forEach(function (childTr) {
      childTr.setAttribute('data-hidden', !show);

      var childId = childTr.getAttribute('data-id');
      var childExpanded = childTr.getAttribute('data-expanded') === 'true';
      if (!show) {
        _toggleChildren(tbody, childId, false);
      } else if (childExpanded) {
        _toggleChildren(tbody, childId, true);
      }
    });
  }

  function _appendRow(tbody, data) {
    var tr = document.createElement('tr');
    tr.className = 'tree-row';
    tr.setAttribute('data-id', data.id);
    tr.setAttribute('data-parent', data.parentId || '');
    tr.setAttribute('data-level', data.level);
    tr.setAttribute('data-is-folder', data.isFolder);
    tr.setAttribute('data-expanded', data.expanded);
    tr.setAttribute('data-hidden', data.hidden ? 'true' : 'false');

    // Create First Column (Tree)
    var tdTree = document.createElement('td');
    var paddingLeft = data.level * 32 + 16;

    var toggleHtml = data.isFolder
      ? `<span class="material-symbols-outlined tree-toggle ${data.expanded ? 'open' : ''}">chevron_right</span>`
      : `<span class="material-symbols-outlined tree-toggle empty">chevron_right</span>`;

    tdTree.innerHTML = `
      <div class="tree-cell" style="padding-left: ${paddingLeft}px;">
        ${toggleHtml}
        <span class="material-symbols-outlined tree-icon">${data.icon}</span>
        <span style="font-weight: ${data.isFolder ? '500' : '400'};">${data.label}</span>
      </div>
    `;
    tr.appendChild(tdTree);

    // Create Checkbox Columns
    if (data.perms) {
      tr.appendChild(_createCheckboxTd(data.perms.xem, 'xem'));
      tr.appendChild(_createCheckboxTd(data.perms.them, 'them'));
      tr.appendChild(_createCheckboxTd(data.perms.sua, 'sua'));
      tr.appendChild(_createCheckboxTd(data.perms.xoa, 'xoa'));
    } else {
      // Empty cells for folder rows
      for (var i = 0; i < 4; i++) {
        var td = document.createElement('td');
        tr.appendChild(td);
      }
    }

    tbody.appendChild(tr);
  }

  function _createCheckboxTd(checked, action) {
    var td = document.createElement('td');
    td.className = 'text-center';
    var wrap = UIControls.createCheckbox({ label: '', checked: checked });
    wrap.style.justifyContent = 'center';
    var chk = wrap.querySelector('input[type="checkbox"]');
    if (chk && action) {
      chk.classList.add('perm-chk');
      chk.setAttribute('data-action', action);
    }
    td.appendChild(wrap);
    return td;
  }

  function _savePermissions() {
    if (!currentSelectedGroup) return;

    var btn = $container.querySelector('#btn-save-permission');
    if (btn) {
      btn.disabled = true;
      btn.innerHTML = '<span class="material-symbols-outlined" style="font-size: 16px; margin-right: 4px; animation: spin 1s linear infinite;">refresh</span> Đang lưu...';
    }

    var tbody = $container.querySelector('#permission-tree-table tbody');
    var rows = tbody.querySelectorAll('tr[data-is-folder="false"]');
    var permissionsToSave = [];

    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.Group || currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    rows.forEach(function (tr) {
      var id = tr.getAttribute('data-id');
      var xem = tr.querySelector('.perm-chk[data-action="xem"]')?.checked || false;
      var them = tr.querySelector('.perm-chk[data-action="them"]')?.checked || false;
      var sua = tr.querySelector('.perm-chk[data-action="sua"]')?.checked || false;
      var xoa = tr.querySelector('.perm-chk[data-action="xoa"]')?.checked || false;

      permissionsToSave.push({
        NhomNguoiDangThaoTac: myGroupId,
        UserGroupID: currentSelectedGroup.id,
        MenuID: id,
        IsRun: xem ? 1 : 0,
        IsAdd: them ? 1 : 0,
        IsUpdate: sua ? 1 : 0,
        IsDelete: xoa ? 1 : 0
      });
    });

    var endpoint = window.API_CONFIG.ENDPOINTS.PERMISSIONS.SAVE_GROUP_PERMISSIONS || '/api/API_WA_LuuQuyenCuaNhom';
    
    // Gọi tuần tự (Sequential Save) vì SQL bắt buộc nhận từng Menu
    async function processQueue() {
        var hasError = false;
        var errorMsg = '';
        for (var i = 0; i < permissionsToSave.length; i++) {
            try {
                var res = await ApiClient.post(endpoint, permissionsToSave[i]);
                if (res && res.code !== 0) {
                    hasError = true;
                    errorMsg = res.msg || 'Có lỗi khi lưu quyền';
                    break;
                }
            } catch (err) {
                console.error(err);
                hasError = true;
                errorMsg = 'Lỗi kết nối mạng khi lưu quyền';
                break;
            }
        }

        if (btn) {
            btn.disabled = false;
            btn.innerText = 'Lưu Thay Đổi';
        }

        if (!hasError) {
            if (typeof Alert !== 'undefined') Alert.success('Thành công', 'Đã lưu phân quyền cho nhóm ' + currentSelectedGroup.name);
        } else {
            if (typeof Alert !== 'undefined') Alert.error('Lỗi', errorMsg);
        }
    }

    processQueue();
  }

  function _syncPermissions() {
    var btn = $container.querySelector('#btn-sync-permission');
    if (btn) {
      btn.disabled = true;
      btn.innerHTML = '<span class="material-symbols-outlined" style="font-size: 16px; margin-right: 4px; animation: spin 1s linear infinite;">sync</span> Đang đồng bộ...';
    }

    var endpoint = window.API_CONFIG.ENDPOINTS.PERMISSIONS.SYNC || '/api/API_WA_DongBoQuyenTruyCap';
    
    var currentUser = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    var myGroupId = currentUser.Group || currentUser.GroupUser || currentUser.GroupID || currentUser.group || currentUser.NhomQuyen || 'Admin';

    ApiClient.post(endpoint, { NhomNguoiDangThaoTac: myGroupId })
      .then(function (res) {
        if (res && res.code === 0) {
          if (typeof Alert !== 'undefined') Alert.success('Thành công', 'Đã đồng bộ quyền hệ thống');
          // Tải lại nhóm quyền hiện tại
          if (currentSelectedGroup) {
            _renderTreeTableForGroup(currentSelectedGroup);
          }
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', res.msg || 'Không thể đồng bộ quyền');
        }
      })
      .catch(function (err) {
        console.error(err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Lỗi kết nối khi đồng bộ');
      })
      .finally(function () {
        if (btn) {
          btn.disabled = false;
          btn.innerText = 'Đồng Bộ';
        }
      });
  }

  return { render: render };
})();
