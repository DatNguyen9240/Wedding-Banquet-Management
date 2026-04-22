/**
 * Màn hình Phân quyền Cán bộ
 * HTML Template: src/pages/permissions.html
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

        // Tiêm style nhỏ cho group-list
        var style = document.createElement('style');
        style.innerHTML = `
          .group-list li {
            padding: 12px 16px;
            border-bottom: 1px solid var(--color-border);
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: all 0.2s;
            font-weight: 500;
            color: var(--color-text-secondary);
          }
          .group-list li:hover { background: rgba(148, 163, 184, 0.1); color: var(--color-primary); }
          .group-list li.active {
            background: rgba(79, 70, 229, 0.1);
            color: var(--color-primary);
            border-left: 4px solid var(--color-primary);
          }
        `;
        $container.appendChild(style);

        _renderGroups();
        
        $container.querySelector('#btn-save-permission').addEventListener('click', function() {
           alert("Đã lưu phân quyền thành công! (Dữ liệu giả demo)");
        });
      });
  }

  function _renderGroups() {
    var ul = $container.querySelector('#group-list');
    ul.innerHTML = '';
    groups.forEach(function(g, idx) {
      var li = document.createElement('li');
      if(g.selected) li.classList.add('active');
      li.innerHTML = '<span class="material-symbols-outlined" style="font-size:20px;">' + g.icon + '</span>' + g.name;
      
      li.addEventListener('click', function() {
        groups.forEach(gx => gx.selected = false);
        g.selected = true;
        $container.querySelector('#matrix-title').innerText = 'Quyền hạn của: ' + g.name;
        _renderGroups();
      });
      ul.appendChild(li);

      if(g.selected) {
         _renderMatrix(g);
      }
    });
  }

  function _renderMatrix(group) {
    var tbody = $container.querySelector('#permission-table tbody');
    tbody.innerHTML = '';

    var isAdmin = group.name === 'Admin';
    var isSales = group.name.includes('lễ tân') || group.name === 'Quản lý';

    modules.forEach(function(modName, idx) {
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-medium">${modName}</td>
        <td class="text-center cell-xem"></td>
        <td class="text-center cell-them"></td>
        <td class="text-center cell-sua"></td>
        <td class="text-center cell-xoa"></td>
      `;

      var canXem = isAdmin || isSales;
      var canThem = isAdmin || (isSales && !modName.includes('Hệ thống') && !modName.includes('Báo cáo'));
      var canSua = canThem;
      var canXoa = isAdmin;

      function mountCb(cellClass, defaultVal) {
        var wrap = UIControls.createCheckbox({ label: '', checked: defaultVal });
        wrap.style.justifyContent = 'center';
        tr.querySelector(cellClass).appendChild(wrap);
      }

      mountCb('.cell-xem', canXem);
      mountCb('.cell-them', canThem);
      mountCb('.cell-sua', canSua);
      mountCb('.cell-xoa', canXoa);

      tbody.appendChild(tr);
    });
  }

  return { render: render };
})();
