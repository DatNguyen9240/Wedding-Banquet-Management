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
        try {
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
          _setupAutoSave();

          var btnSync = $container.querySelector('#btn-sync-permission');
          if (btnSync) btnSync.addEventListener('click', _syncPermissions);

          _fetchGroups();
        } catch (e) {
          $container.innerHTML = '<div style="color:red; padding: 20px;">Lỗi lập trình viên: ' + e.message + '<br>' + e.stack + '</div>';
        }
      });
  }

  function _fetchGroups() {
    var container = $container.querySelector('#role-list-container');
    if (container) {
      container.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--color-text-secondary);">Đang tải dữ liệu...</div>';
    }

    PermissionsService.getGroups()
      .then(function (records) {
        if (records.length > 0) {
          groups = records;
          _renderRoleTabs();
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không lấy được danh sách nhóm quyền');
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
      div.innerHTML = `${UIIcon.createHTML('group')} ${g.name}`;

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

    PermissionsService.getMenusByGroup(group.id)
      .then(function (records) {
        _buildTreeTableFromApi(group, records);
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
      tbody.innerHTML += UIEmptyState.createTableRowHTML({
        colspan: 12,
        text: 'Chưa có dữ liệu phân quyền cho nhóm này'
      });
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
      
      var isManager = item.isManager || false;
      var isAdmin = item.isAdmin || false;
      var isAutoLock = item.isAutoLock || false;
      var isHideAmount = item.isHideAmount || false;
      var isLockDoc = item.isLockDoc || false;
      var isUnLockDoc = item.isUnLockDoc || false;
      var isExportExcel = item.isExportExcel || false;

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
          xoa: canXoa,
          isManager: isManager,
          isAdmin: isAdmin,
          isAutoLock: isAutoLock,
          isHideAmount: isHideAmount,
          isLockDoc: isLockDoc,
          isUnLockDoc: isUnLockDoc,
          isExportExcel: isExportExcel
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

  function _setupAutoSave() {
    var tbody = $container.querySelector('#permission-tree-table tbody');
    tbody.addEventListener('change', function(e) {
      if (e.target.classList.contains('perm-chk')) {
         var tr = e.target.closest('tr');
         if(tr) _saveSingleRowPermission(tr);
      }
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
    tdTree.style.whiteSpace = 'nowrap';
    tdTree.style.minWidth = '220px';
    var paddingLeft = data.level * 20 + 8;

    var toggleHtml = data.isFolder
      ? UIIcon.createHTML('chevron_right', '', `tree-toggle ${data.expanded ? 'open' : ''}`)
      : UIIcon.createHTML('chevron_right', '', 'tree-toggle empty');

    tdTree.innerHTML = `
      <div class="tree-cell" style="padding-left: ${paddingLeft}px;">
        ${toggleHtml}
        ${UIIcon.createHTML(data.icon, '', 'tree-icon')}
        <span class="tree-label" style="font-weight: ${data.isFolder ? '500' : '400'};">${data.label}</span>
      </div>
    `;
    tr.appendChild(tdTree);

    // Create Checkbox Columns
    if (data.perms) {
      tr.appendChild(_createCheckboxTd(data.perms.xem, 'xem'));
      tr.appendChild(_createCheckboxTd(data.perms.them, 'them'));
      tr.appendChild(_createCheckboxTd(data.perms.sua, 'sua'));
      tr.appendChild(_createCheckboxTd(data.perms.xoa, 'xoa'));
      
      tr.appendChild(_createCheckboxTd(data.perms.isManager, 'isManager'));
      tr.appendChild(_createCheckboxTd(data.perms.isAdmin, 'isAdmin'));
      tr.appendChild(_createCheckboxTd(data.perms.isAutoLock, 'isAutoLock'));
      tr.appendChild(_createCheckboxTd(data.perms.isHideAmount, 'isHideAmount'));
      tr.appendChild(_createCheckboxTd(data.perms.isLockDoc, 'isLockDoc'));
      tr.appendChild(_createCheckboxTd(data.perms.isUnLockDoc, 'isUnLockDoc'));
      tr.appendChild(_createCheckboxTd(data.perms.isExportExcel, 'isExportExcel'));
    } else {
      // Empty cells for folder rows
      for (var i = 0; i < 11; i++) {
        var td = document.createElement('td');
        tr.appendChild(td);
      }
    }

    tbody.appendChild(tr);
  }

  function _createCheckboxTd(checked, action) {
    var td = document.createElement('td');
    td.className = 'text-center';
    td.style.padding = '4px 0';
    var wrap = UIControls.createCheckbox({ label: '', checked: checked });
    wrap.style.justifyContent = 'center';
    wrap.style.padding = '0';
    wrap.style.background = 'none';
    var chk = wrap.querySelector('input[type="checkbox"]');
    if (chk && action) {
      chk.classList.add('perm-chk');
      chk.setAttribute('data-action', action);
    }
    td.appendChild(wrap);
    return td;
  }

  function _saveSingleRowPermission(tr) {
    if (!currentSelectedGroup) return;



    var id = tr.getAttribute('data-id');
    var xem = tr.querySelector('.perm-chk[data-action="xem"]')?.checked || false;
    var them = tr.querySelector('.perm-chk[data-action="them"]')?.checked || false;
    var sua = tr.querySelector('.perm-chk[data-action="sua"]')?.checked || false;
    var xoa = tr.querySelector('.perm-chk[data-action="xoa"]')?.checked || false;
    
    var isManager = tr.querySelector('.perm-chk[data-action="isManager"]')?.checked || false;
    var isAdmin = tr.querySelector('.perm-chk[data-action="isAdmin"]')?.checked || false;
    var isAutoLock = tr.querySelector('.perm-chk[data-action="isAutoLock"]')?.checked || false;
    var isHideAmount = tr.querySelector('.perm-chk[data-action="isHideAmount"]')?.checked || false;
    var isLockDoc = tr.querySelector('.perm-chk[data-action="isLockDoc"]')?.checked || false;
    var isUnLockDoc = tr.querySelector('.perm-chk[data-action="isUnLockDoc"]')?.checked || false;
    var isExportExcel = tr.querySelector('.perm-chk[data-action="isExportExcel"]')?.checked || false;

    var payload = {
      NhomNguoiDangThaoTac: myGroupId,
      UserGroupID: currentSelectedGroup.id,
      MenuID: id,
      IsRun: xem ? 1 : 0,
      IsAdd: them ? 1 : 0,
      IsUpdate: sua ? 1 : 0,
      IsDelete: xoa ? 1 : 0,
      isManager: isManager ? 1 : 0,
      isAdmin: isAdmin ? 1 : 0,
      isAutoLock: isAutoLock ? 1 : 0,
      isHideAmount: isHideAmount ? 1 : 0,
      isLockDoc: isLockDoc ? 1 : 0,
      isUnLockDoc: isUnLockDoc ? 1 : 0,
      isExportExcel: isExportExcel ? 1 : 0
    };


    
    var label = tr.querySelector('.tree-label') ? tr.querySelector('.tree-label').innerText : id;

    PermissionsService.savePermission(payload).then(function(res) {
        if (res && res.code === 0) {
           UIToast.show('Đã cập nhật quyền: <b>' + label + '</b>', 'success');
        } else {
           UIToast.show(res.msg || 'Lỗi cập nhật quyền', 'error');
        }
    }).catch(function() {
        UIToast.show('Lỗi kết nối khi cập nhật quyền', 'error');
    });
  }

  function _syncPermissions() {
    var btn = $container.querySelector('#btn-sync-permission');
    if (btn) {
      btn.disabled = true;
      btn.innerHTML = `${UIIcon.createHTML('sync', 'font-size: 16px; margin-right: 4px; animation: spin 1s linear infinite;')} Đang đồng bộ...`;
    }



    PermissionsService.sync()
      .then(function (res) {
        if (res && res.code === 0) {
          if (typeof Alert !== 'undefined') Alert.success('Thành công', 'Đã đồng bộ quyền hệ thống');
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
