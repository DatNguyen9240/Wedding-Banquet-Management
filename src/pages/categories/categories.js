/**
 * Màn hình Quản lý Danh mục (Master Data)
 * Hiển thị cấu trúc dạng Cây (Tree) bên trái và DataGrid bên phải.
 */
var CategoriesPage = (function () {
  var $container;
  var currentGridApi = null;

  // Dữ liệu giả lập Danh mục
  var treeData = [
    {
      id: "time",
      text: "Quản lý Thời gian",
      icon: "calendar_month",
      expanded: true,
      children: [
        { id: "time_solar", text: "Tạo Ngày tháng", icon: "event" },
        { id: "time_lunar", text: "Danh mục Năm Âm Lịch", icon: "brightness_3" }
      ]
    },
    {
      id: "location",
      text: "Quản lý Khu vực",
      icon: "map",
      expanded: true,
      children: [
        { id: "loc_q1", text: "Quận 1", icon: "location_on" },
        { id: "loc_q2", text: "Quận 2", icon: "location_on" },
        { id: "loc_pn", text: "Phú Nhuận", icon: "location_on" }
      ]
    },
    {
      id: "goods",
      text: "Hàng hóa & Dịch vụ",
      icon: "inventory_2",
      expanded: true,
      children: [
        { id: "goods_dv", text: "Dịch vụ (DV)", icon: "room_service" },
        { id: "goods_hh", text: "Hàng hóa / Món ăn (HH)", icon: "restaurant" },
        { id: "goods_tu", text: "Thức uống (TU)", icon: "local_bar" }
      ]
    },
    {
      id: "customer",
      text: "Đối tượng & Ý kiến",
      icon: "contact_page",
      expanded: false,
      children: [
        { id: "cust_feedback", text: "Ý kiến Khách tham quan", icon: "feedback" }
      ]
    }
  ];

  function toUnsigned(str) {
    if (!str) return "";
    return str.normalize("NFD")
              .replace(/[\u0300-\u036f]/g, "")
              .replace(/đ/g, "d")
              .replace(/Đ/g, "D");
  }

  // --- MODULES ---
  var TimeSolarModule = {
    render: function(node, $contentElement) {
      $contentElement.innerHTML = `
        <div style="padding: 24px; border-bottom: 1px solid var(--color-border); display: flex; gap: 16px; align-items: center; background: var(--color-surface);">
          <span style="font-weight: 600; font-size: 15px; color: var(--color-text);">Tháng/Năm tạo lịch: </span>
          <div style="position: relative; display: flex; align-items: center;">
            <input type="month" id="ts-month" class="form-control" style="width: 200px; padding: 10px 14px; border-radius: 8px; border: 1px solid var(--color-border-strong); box-shadow: 0 1px 2px rgba(0,0,0,0.05); font-size: 15px; outline: none; transition: border-color 0.2s;" onfocus="this.style.borderColor='var(--color-primary)'" onblur="this.style.borderColor='var(--color-border-strong)'" value="2026-07">
          </div>
          ${UIButton.createHTML({
            text: 'Sinh danh sách ngày',
            icon: 'calendar_month',
            type: 'primary',
            className: 'btn-sm',
            onClick: "CategoriesPage.triggerModuleAction('generate')"
          })}
        </div>
        <div id="time-solar-grid-container" style="flex: 1; height: 400px; width: 100%;"></div>
      `;
    },
    generate: function() {
      var monthVal = document.getElementById('ts-month').value;
      if(!monthVal) { UIToast.show('Vui lòng chọn tháng năm', 'error'); return; }
      
      var parts = monthVal.split('-');
      var year = parseInt(parts[0]);
      var month = parseInt(parts[1]);
      var daysInMonth = new Date(year, month, 0).getDate();
      
      var daysOfWeek = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
      var rowData = [];
      
      for(var i=1; i<=daysInMonth; i++) {
        var date = new Date(year, month - 1, i);
        var dayName = daysOfWeek[date.getDay()];
        var alDay = (i + 15) % 30; if (alDay===0) alDay = 30;
        var alMonth = month - 1; if(alMonth===0) { alMonth = 12; }
        
        rowData.push({
          stt: i,
          date_str: i.toString().padStart(2, '0') + '/' + month.toString().padStart(2, '0') + '/' + year,
          day_name: dayName,
          lunar_date: alDay.toString().padStart(2, '0') + '/' + alMonth.toString().padStart(2, '0') + '/' + year,
          lunar_stem: 'Năm dự kiến',
          is_leap: false
        });
      }

      var container = document.getElementById('time-solar-grid-container');
      if (container) {
        if (currentGridApi) {
          currentGridApi.destroy();
        }

        var gridOptions = {
          pagination: false,
          columnDefs: [
            { field: 'stt', headerName: 'STT', width: 80, cellStyle: { textAlign: 'center' }, headerClass: 'text-center' },
            { field: 'date_str', headerName: 'Ngày Dương', cellStyle: { fontWeight: '600' } },
            { field: 'day_name', headerName: 'Thứ' },
            { 
              field: 'lunar_date', 
              headerName: 'Ngày Âm Lịch',
              cellRenderer: function(params) {
                return '<input type="text" class="form-control" value="' + params.value + '" style="width: 120px; padding: 4px;">';
              }
            },
            { 
              field: 'lunar_stem', 
              headerName: 'Can Chi Âm Lịch',
              cellRenderer: function(params) {
                return '<input type="text" class="form-control" value="' + params.value + '" style="width: 150px; padding: 4px;">';
              }
            },
            { 
              field: 'is_leap', 
              headerName: 'Nhuận',
              cellStyle: { textAlign: 'center' },
              headerClass: 'text-center',
              cellRenderer: function(params) {
                var checked = params.value ? 'checked' : '';
                return '<label class="custom-checkbox" style="display:inline-flex;"><input type="checkbox" class="ui-checkbox" ' + checked + '><span class="checkmark"></span></label>';
              }
            }
          ],
          rowData: rowData
        };

        currentGridApi = AppGrid.create(container, gridOptions);
      }
      UIToast.show('Đã tạo thành công lịch cho tháng ' + monthVal);
    }
  };

  var GoodsModule = {
    render: function(node, $contentElement) {
      $contentElement.innerHTML = `
        <div style="flex: 1; display: flex; flex-direction: column; overflow: hidden; min-height: 0;">
          <!-- Khối lưới Master -->
          <div id="goods-grid-container" style="height: 300px; width: 100%; border-bottom: 2px solid var(--color-border);"></div>
          
          <!-- Khối Tabs Detail -->
          <div style="flex: 1; display: flex; flex-direction: column; background: var(--color-surface); overflow: hidden; min-height: 0;">
            <div class="tabs-header" style="border-bottom: 1px solid var(--color-border); display: flex; padding-top: 5px; background: var(--color-surface);">
               <div class="tab-item active" onclick="CategoriesPage.switchTab(this, 'tab-gia-ban')">Lịch sử Giá Bán</div>
               <div class="tab-item" onclick="CategoriesPage.switchTab(this, 'tab-dinh-luong')">Định lượng món ăn</div>
            </div>
            
            <div class="tabs-content" style="flex: 1; padding: 0; overflow-y: auto; background: var(--color-surface);">
              <div id="tab-gia-ban" class="tab-pane active" style="display: block; padding: 0;">
                 <table class="data-table">
                    <thead style="background: rgba(148, 163, 184, 0.1);"><tr><th>Ngày Áp Dụng</th><th>Đơn giá</th><th style="text-align: right;">Thao tác</th></tr></thead>
                    <tbody id="price-history-body">
                       <tr><td colspan="3" style="text-align:center; padding: 30px; color:#aaa;">(Chưa chọn Hàng hoá)</td></tr>
                    </tbody>
                 </table>
              </div>
              <div id="tab-dinh-luong" class="tab-pane" style="display: none; padding: 0;">
                 <table class="data-table">
                    <thead style="background: rgba(148, 163, 184, 0.1);"><tr><th>Mã NVL</th><th>Tên Nguyên Vật Liệu</th><th>ĐVT</th><th>Định mức</th></tr></thead>
                    <tbody id="inventory-parts-body">
                       <tr><td colspan="4" style="text-align:center; padding: 30px; color:#aaa;">(Chưa chọn Hàng hoá)</td></tr>
                    </tbody>
                 </table>
              </div>
            </div>
          </div>
        </div>
      `;
      this.loadMockTable(node);
    },
    loadMockTable: function(node) {
      var cat = node.id.split('_')[1].toUpperCase(); // HH, DV, TU
      var rowData = [];
      for(var i=1; i<=12; i++) {
        var tenCoDau = cat === 'HH' ? (`Súp bào ngư vi cá ${i}`) : (cat === 'DV' ? `Gói trang trí cơ bản ${i}` : `Bia Heineken lon ${i}`);
        var tenKhongDau = toUnsigned(tenCoDau).toLowerCase();
        rowData.push({
          id: cat + '_00' + i,
          code: cat + '00' + i,
          name: tenCoDau,
          name_unsigned: tenKhongDau,
          unit: cat === 'TU' ? 'Lon' : 'Phần'
        });
      }

      setTimeout(function() {
        var container = document.getElementById('goods-grid-container');
        if (!container) return;

        if (currentGridApi) {
          currentGridApi.destroy();
        }

        var gridOptions = {
          pagination: false,
          columnDefs: [
            { headerName: 'STT', valueGetter: 'node.rowIndex + 1', width: 80, cellStyle: { textAlign: 'center' }, headerClass: 'text-center' },
            { field: 'code', headerName: 'Mã Hàng', cellStyle: { fontWeight: '500', color: 'var(--color-primary)' } },
            { field: 'name', headerName: 'Tên Hàng (có dấu)', cellStyle: { fontWeight: '600' } },
            { field: 'name_unsigned', headerName: 'Tên Hàng (không dấu)', cellStyle: { color: '#666', fontSize: '13px' } },
            { field: 'unit', headerName: 'Đơn Vị Tính' }
          ],
          rowData: rowData,
          onRowClicked: function(event) {
            selectedRowId = event.data.id;
            GoodsModule.onSelectRow(event.data.id);
          }
        };

        currentGridApi = AppGrid.create(container, gridOptions);
      }, 100);
    },
    onSelectRow: function(id) {
       var basePrice = Math.floor(Math.random() * 500) * 1000 + 50000;
       document.getElementById('price-history-body').innerHTML = `
          <tr><td>01/01/2026</td><td style="color:#666;">${(basePrice).toLocaleString()} ₫</td><td style="text-align:right;">${UIIcon.createHTML('edit', 'font-size:18px;cursor:pointer;color:#888;')}</td></tr>
          <tr><td>15/10/2026</td><td style="font-weight: 600; color: var(--color-success);">${(basePrice + 20000).toLocaleString()} ₫ ${UIBadge.createHTML('Hiện hành', 'success', 'background:#def7ec;color:#03543f;font-size:10px;')}</td><td style="text-align:right;">${UIIcon.createHTML('edit', 'font-size:18px;cursor:pointer;color:#888;')}</td></tr>
       `;

       document.getElementById('inventory-parts-body').innerHTML = `
          <tr><td style="color:var(--color-primary);">NVL_001</td><td>Gà ác nguyên con</td><td>Con</td><td>1.0</td></tr>
          <tr><td style="color:var(--color-primary);">NVL_052</td><td>Nấm đông cô (Khô)</td><td>Kg</td><td>0.05</td></tr>
          <tr><td style="color:var(--color-primary);">NVL_104</td><td>Gia vị tổng hợp</td><td>Gói</td><td>2.0</td></tr>
       `;
    }
  };

  var SimpleModule = {
    render: function(node, $contentElement) {
      $contentElement.innerHTML = `
        <div id="simple-grid-container" style="flex: 1; height: 500px; width: 100%;"></div>
      `;
      this.loadMockTable(node);
    },
    loadMockTable: function(node) {
      var rowData = [];
      for(var i=1; i<=8; i++) {
        rowData.push({
          id: node.id + '_' + i,
          code: node.id.toUpperCase() + '_' + i.toString().padStart(3, '0'),
          name: 'Dữ liệu mô phỏng cho ' + node.text + ' số ' + i,
          status: 'Kích hoạt'
        });
      }

      setTimeout(function() {
        var container = document.getElementById('simple-grid-container');
        if (!container) return;

        if (currentGridApi) {
          currentGridApi.destroy();
        }

        var gridOptions = {
          pagination: false,
          columnDefs: [
            { headerName: 'STT', valueGetter: 'node.rowIndex + 1', width: 80, cellStyle: { textAlign: 'center' }, headerClass: 'text-center' },
            { field: 'code', headerName: 'Mã ' + node.text, cellStyle: { fontWeight: '500' } },
            { field: 'name', headerName: 'Tên / Diễn giải' },
            { 
              field: 'status', 
              headerName: 'Trạng thái sử dụng',
              cellRenderer: function(params) {
                return UIBadge.createHTML(params.value, 'success');
              }
            }
          ],
          rowData: rowData,
          onRowClicked: function(event) {
            selectedRowId = event.data.id;
          }
        };

        currentGridApi = AppGrid.create(container, gridOptions);
      }, 100);
    }
  };


  // --- MAIN LOGIC ---
  var currentNode = null;
  var selectedRowId = null;

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/categories/categories.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _injectHeaderActions();
        _injectCategoriesStyles();
        _renderTree();
      });
  }

  function _injectCategoriesStyles() {
    if (document.getElementById('categories-layout-style')) return;
    var style = document.createElement('style');
    style.id = 'categories-layout-style';
    style.textContent = [
      '@media(min-width:769px){#btn-mobile-open-tree,#btn-mobile-close-tree{display:none !important;}}',
      '@media(max-width:768px){#btn-mobile-open-tree,#btn-mobile-close-tree{display:block !important;}.categories-layout>.tree-column{display:none;}.categories-layout.show-tree>.tree-column{display:flex !important;position:absolute;z-index:10;background: var(--color-surface);width:100%;height:100%;border-right:none;}}',
      '.categories-layout .tab-item{padding:10px 20px;cursor:pointer;color:var(--color-text-secondary);border-bottom:2px solid transparent;font-weight:600;font-size:14px;transition:all 0.2s;}',
      '.categories-layout .tab-item:hover{color:var(--color-primary);background:var(--color-primary-light);}',
      '.categories-layout .tab-item.active{color:var(--color-primary);border-bottom:2px solid var(--color-primary);background: var(--color-surface);}',
      '.categories-layout .tab-pane{display:none;}',
      '.categories-layout .tab-pane.active{display:block;animation:fadeIn 0.3s ease;}',
      '.categories-layout .row-selected{background:var(--color-bg) !important;position:relative;}',
      '.categories-layout .row-selected td{border-bottom:1px solid var(--color-primary) !important;}'
    ].join('');
    document.head.appendChild(style);
  }

  function _injectHeaderActions() {
    var globalActions = document.getElementById('global-page-actions');
    if (!globalActions) return;

    globalActions.innerHTML = '';
    if (typeof UIActionToolbar !== 'undefined') {
      var toolbar = UIActionToolbar.create({
        onAdd: true, onEdit: true, onDelete: true, onFilter: true, onPrint: true, onClose: true,
        extras: []
      });
      globalActions.appendChild(toolbar);

      var addBtn = globalActions.querySelector('.btn-tool-add');
      if (addBtn) addBtn.onclick = function() { CategoriesPage.add(); };
      
      var editBtn = globalActions.querySelector('.btn-tool-edit');
      if (editBtn) editBtn.onclick = function() { CategoriesPage.edit(); };
      
      var deleteBtn = globalActions.querySelector('.btn-tool-delete');
      if (deleteBtn) deleteBtn.onclick = function() { CategoriesPage.remove(); };
      
      var filterBtn = globalActions.querySelector('.btn-tool-filter');
      if (filterBtn) filterBtn.onclick = function() { UIToast.show('Mở form Lọc chi tiết'); };
      
      var printBtn = globalActions.querySelector('.btn-tool-print');
      if (printBtn) printBtn.onclick = function() { UIToast.show('In dữ liệu danh mục hiện hành'); };
      
      var closeBtn = globalActions.querySelector('.btn-tool-close');
      if (closeBtn) closeBtn.onclick = function() { window.location.hash='#/dashboard'; };
    }
  }

  // --- TREE VIEW ---
  function _renderTree() {
    var $treeContainer = document.getElementById('categories-tree-container');
    $treeContainer.innerHTML = '';
    $treeContainer.appendChild(_buildTreeRecursive(treeData));
  }

  function _buildTreeRecursive(nodes) {
    var ul = document.createElement('ul');
    ul.className = 'ui-tree';

    nodes.forEach(function(node) {
      var li = document.createElement('li');
      var html = `
        <div class="ui-tree-node" data-id="${node.id}">
        <div class="ui-tree-toggle ${node.children ? '' : 'empty'}">
          ${node.children ? UIIcon.createHTML(node.expanded ? 'arrow_drop_down' : 'arrow_right') : ''}
        </div>
        ${UIIcon.createHTML(node.icon || 'folder', node.children ? 'color:var(--color-warning);' : 'color:var(--color-primary);', 'ui-tree-icon')}
        <span class="ui-tree-label">${node.text}</span>
        </div>
      `;
      li.innerHTML = html;

      if (node.children && node.children.length > 0) {
        var childrenUl = _buildTreeRecursive(node.children);
        if (node.expanded) childrenUl.classList.add('open');
        li.appendChild(childrenUl);

        var toggleBtn = li.querySelector('.ui-tree-toggle');
        toggleBtn.addEventListener('click', function(e) {
          e.stopPropagation();
          node.expanded = !node.expanded;
          toggleBtn.querySelector('span').innerText = node.expanded ? 'arrow_drop_down' : 'arrow_right';
          if (node.expanded) childrenUl.classList.add('open');
          else childrenUl.classList.remove('open');
        });
      }

      var nodeEl = li.querySelector('.ui-tree-node');
      nodeEl.addEventListener('click', function() {
        document.querySelectorAll('.ui-tree-node').forEach(el => { el.style.fontWeight = '400'; el.style.color = 'var(--color-text)'; el.style.background = 'transparent'; });
        nodeEl.style.fontWeight = '600';
        nodeEl.style.color = '#fff';
        nodeEl.style.background = 'var(--color-primary)';
        nodeEl.style.borderRadius = '4px';
        
        _loadCategoryData(node);
        document.querySelector('.categories-layout').classList.remove('show-tree');
      });

      ul.appendChild(li);
    });

    return ul;
  }

  // --- ROUTING LOGIC TỚI MODULES ---
  function _loadCategoryData(node) {
    if (currentGridApi) {
      currentGridApi.destroy();
      currentGridApi = null;
    }

    currentNode = node;
    selectedRowId = null; 
    document.getElementById('current-category-title').innerText = node.text;
    var $content = document.getElementById('category-content-container');

    if(node.children && node.children.length > 0) {
      $content.innerHTML = `<div style="text-align:center; padding: 40px; color: var(--color-text-secondary);">Thư mục gốc. Vui lòng sổ mũi tên để chọn các danh mục con.</div>`;
      return;
    }

    if (node.id === 'time_solar') {
      TimeSolarModule.render(node, $content);
    } else if (node.id.startsWith('goods_')) {
      GoodsModule.render(node, $content);
    } else {
      SimpleModule.render(node, $content);
    }
  }

  function switchTab(btn, targetId) {
    var tabs = btn.parentElement.querySelectorAll('.tab-item');
    tabs.forEach(t => t.classList.remove('active'));
    btn.classList.add('active');

    var panes = btn.parentElement.parentElement.querySelectorAll('.tab-pane');
    panes.forEach(p => { p.style.display = 'none'; p.classList.remove('active'); });
    
    var target = document.getElementById(targetId);
    if(target) {
      target.style.display = 'block';
      setTimeout(()=> target.classList.add('active'), 10);
    }
  }

  function triggerModuleAction(actionName) {
    if(currentNode && currentNode.id === 'time_solar' && actionName === 'generate') {
      TimeSolarModule.generate();
    }
  }

  // --- CRUD ACTIONS ---
  function add() {
    if (!currentNode || (currentNode.children && currentNode.children.length > 0)) {
      UIToast.show('Vui lòng chọn cụ thể 1 danh mục lẻ ở cây bên trái', 'warning');
      return;
    }
    UIToast.show('Mở biểu mẫu thêm cho danh mục: ' + currentNode.text);
  }

  function edit() {
    if (!selectedRowId) {
      UIToast.show('Vui lòng chọn 1 dòng dữ liệu trong bảng để chỉnh sửa!', 'warning');
      return;
    }
    UIToast.show('Sửa phần tử ID: ' + selectedRowId + ' của danh mục ' + currentNode.text);
  }

  function remove() {
    if (!selectedRowId) {
      UIToast.show('Vui lòng chọn 1 dòng dữ liệu trong bảng để xóa!', 'warning');
      return;
    }
    ConfirmModal.show({
      title: 'Xóa phần tử',
      message: 'Bạn có chắc chắn muốn xóa phần tử <b>' + selectedRowId + '</b> này?',
      confirmText: 'Xóa ngay',
      confirmClass: 'btn-danger',
      onConfirm: function() {
        UIToast.show('Đã xóa thành công ID: ' + selectedRowId);
      }
    });
  }

  return {
    render: render,
    switchTab: switchTab,
    triggerModuleAction: triggerModuleAction,
    add: add,
    edit: edit,
    remove: remove,
    selectYear: function (el, year) {
      if (!el) return;
      var items = el.parentElement.querySelectorAll('.year-item');
      items.forEach(function (item) { item.classList.remove('active'); });
      el.classList.add('active');
      UIToast.show('Đã chuyển sang xem Kỳ Kế Toán Năm ' + year);
      var headerText = document.getElementById('period-header-year');
      if (headerText) headerText.innerText = 'Tháng / Kỳ trong năm ' + year;
    }
  };
})();
