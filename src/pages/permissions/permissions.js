/**
 * Màn hình Phân quyền Cán bộ (Sử dụng Tree Table)
 * HTML Template: src/pages/permissions/permissions.html
 */
var PermissionsPage = (function () {
  var $container;

  var groups = window.MockData ? window.MockData.groups : [];
  var modules = window.MockData ? window.MockData.permissionModules : [];

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/permissions/permissions.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        
        // CSS nhỏ cho tree table
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
        `;
        $container.appendChild(style);

        _renderTreeTable();
        
        $container.querySelector('#btn-save-permission').addEventListener('click', function() {
           alert("Đã lưu phân quyền thành công! (Dữ liệu giả demo)");
        });
      });
  }

  function _renderTreeTable() {
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

    // Roles
    groups.forEach(function(g, gIdx) {
      var roleId = 'role_' + gIdx;
      var isAdmin = g.name === 'Admin';
      var isSales = g.name.includes('lễ tân') || g.name === 'Quản lý';

      _appendRow(tbody, {
        id: roleId,
        parentId: rootId,
        level: 1,
        label: 'Nhóm quyền: ' + g.name,
        icon: 'group',
        isFolder: true,
        expanded: false,
        hidden: false
      });

      // Modules for Role
      modules.forEach(function(modName, mIdx) {
        var modId = roleId + '_mod_' + mIdx;
        var canXem = isAdmin || isSales;
        var canThem = isAdmin || (isSales && !modName.includes('Hệ thống') && !modName.includes('Báo cáo'));
        var canSua = canThem;
        var canXoa = isAdmin;

        _appendRow(tbody, {
          id: modId,
          parentId: roleId,
          level: 2,
          label: 'Chức năng: ' + modName,
          icon: 'folder',
          isFolder: false, // Leaf level for the tree
          expanded: false,
          hidden: true,
          perms: {
            xem: canXem,
            them: canThem,
            sua: canSua,
            xoa: canXoa
          }
        });
      });
    });

    // Handle toggle
    tbody.addEventListener('click', function(e) {
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
        } else if (tr.getAttribute('data-level') === '1') {
          folderIcon.innerText = 'group';
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
    children.forEach(function(childTr) {
      childTr.setAttribute('data-hidden', !show);
      
      // If hiding, also hide all descendants. 
      // If showing, only show if this child was expanded.
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
      tr.appendChild(_createCheckboxTd(data.perms.xem));
      tr.appendChild(_createCheckboxTd(data.perms.them));
      tr.appendChild(_createCheckboxTd(data.perms.sua));
      tr.appendChild(_createCheckboxTd(data.perms.xoa));
    } else {
      // Empty cells for folder rows
      for(var i = 0; i < 4; i++) {
        var td = document.createElement('td');
        tr.appendChild(td);
      }
    }

    tbody.appendChild(tr);
  }

  function _createCheckboxTd(checked) {
    var td = document.createElement('td');
    td.className = 'text-center';
    var wrap = UIControls.createCheckbox({ label: '', checked: checked });
    wrap.style.justifyContent = 'center';
    td.appendChild(wrap);
    return td;
  }

  return { render: render };
})();
