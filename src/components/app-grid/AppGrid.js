/**
 * AppGrid.js - AG Grid Helper for Wedding-Banquet-Management
 */
var AppGrid = {
  getThemeClass: function () {
    var isDark = document.body.classList.contains('dark-theme') ||
      localStorage.getItem('pmql_theme') === 'dark';
    return isDark ? 'ag-theme-quartz-dark' : 'ag-theme-quartz';
  },

  create: function (container, customOptions) {
    var self = this;

    // Set class ban dau cho container
    container.className = self.getThemeClass();

    // Chen style de hien thi duong ngan cach cot (vertical borders)
    if (!document.getElementById('ag-grid-borders-style')) {
      var style = document.createElement('style');
      style.id = 'ag-grid-borders-style';
      style.innerHTML = 
        '.ag-theme-quartz .ag-cell, .ag-theme-quartz-dark .ag-cell, ' +
        '.ag-theme-quartz .ag-header-cell, .ag-theme-quartz-dark .ag-header-cell { ' +
        '  border-right: 1px solid var(--ag-border-color, var(--color-border, #e2e8f0)) !important; ' +
        '}';
      document.head.appendChild(style);
    }

    var defaultOptions = {
      pagination: true,
      rowSelection: 'single',
      rowMultiSelectWithClick: true,
      enableCellTextSelection: true,
      ensureDomOrder: true,
      paginationPageSize: 10,
      paginationPageSizeSelector: [10, 20, 50, 100],
      defaultColDef: {
        sortable: true,
        filter: true,
        resizable: true,
        floatingFilter: true,
        flex: 1,
        minWidth: 100
      },
      localeText: {
        page: 'Trang',
        more: 'Thêm',
        to: 'đến',
        of: 'trong số',
        next: 'Tiếp',
        last: 'Cuối',
        first: 'Đầu',
        previous: 'Trước',
        loadingOoo: 'Đang tải...',
        noRowsToShow: 'Không có dữ liệu',
        filterOoo: 'Lọc...',
        applyFilter: 'Áp dụng...',
        equals: 'Bằng',
        notEqual: 'Khác',
        lessThan: 'Nhỏ hơn',
        lessThanOrEqual: 'Nhỏ hơn hoặc bằng',
        greaterThan: 'Lớn hơn',
        greaterThanOrEqual: 'Lớn hơn hoặc bằng',
        inRange: 'Trong khoảng',
        contains: 'Chứa',
        notContains: 'Không chứa',
        startsWith: 'Bắt đầu bằng',
        endsWith: 'Kết thúc bằng',
        blank: 'Trống',
        notBlank: 'Không trống',
        searchOoo: 'Tìm kiếm...',
        selectAll: 'Chọn tất cả',
        searchAndSelectAll: 'Tìm và chọn tất cả',
      }
    };

    // Tron option mac dinh voi option custom
    var mergedOptions = Object.assign({}, defaultOptions, customOptions);

    // Ghi de defaultColDef sau khi tron de dam bao an toan
    if (customOptions && customOptions.defaultColDef) {
      mergedOptions.defaultColDef = Object.assign({}, defaultOptions.defaultColDef, customOptions.defaultColDef);
    }

    // Load saved hidden columns state from localStorage
    var storageKey = 'grid_cols_hide_' + (container.id || 'default');
    var savedHidden = [];
    try {
      savedHidden = JSON.parse(localStorage.getItem(storageKey) || '[]');
    } catch (e) { }

    if (savedHidden && savedHidden.length > 0 && mergedOptions.columnDefs) {
      mergedOptions.columnDefs.forEach(function (col) {
        var colId = col.field || col.colId;
        if (colId && savedHidden.includes(colId)) {
          col.hide = true;
        }
      });
    }

    // Load saved filter state from localStorage
    var filterStorageKey = 'grid_filter_' + (container.id || 'default');
    var isFilterVisible = localStorage.getItem(filterStorageKey) === 'true'; // default to false

    if (!isFilterVisible) {
      if (mergedOptions.defaultColDef) {
        mergedOptions.defaultColDef.floatingFilter = false;
      }
      if (mergedOptions.columnDefs) {
        mergedOptions.columnDefs.forEach(function (col) {
          col.floatingFilter = false;
        });
      }
    }

    // Debounce row double click to prevent double invocation (custom double-tap + native double-click)
    var lastDoubleClickedTime = 0;
    var originalOnRowDoubleClicked = mergedOptions.onRowDoubleClicked;
    if (typeof originalOnRowDoubleClicked === 'function') {
      mergedOptions.onRowDoubleClicked = function (event) {
        var currentTime = Date.now();
        if (currentTime - lastDoubleClickedTime < 400) {
          return;
        }
        lastDoubleClickedTime = currentTime;
        originalOnRowDoubleClicked(event);
      };
    }

    // Toggle row selection on click (click again to deselect) + custom double-tap for mobile
    var lastSelectedNode = null;
    var lastTapTime = 0;
    var lastTapNode = null;
    var originalOnRowClicked = mergedOptions.onRowClicked;

    mergedOptions.onRowClicked = function (event) {
      var node = event.node;
      var currentTime = Date.now();
      var tapGap = currentTime - lastTapTime;

      // Kich hoat double tap (duoi 300ms tren cung mot dong) de ho tro man hinh dien thoai/tablet
      if (lastTapNode === node && tapGap < 300) {
        if (typeof mergedOptions.onRowDoubleClicked === 'function') {
          mergedOptions.onRowDoubleClicked(event);
        }
        lastTapTime = 0;
        lastTapNode = null;
        return;
      }

      lastTapTime = currentTime;
      lastTapNode = node;

      if (lastSelectedNode === node) {
        node.setSelected(false);
        lastSelectedNode = null;
      } else {
        lastSelectedNode = node.isSelected() ? node : null;
      }
      if (typeof originalOnRowClicked === 'function') {
        originalOnRowClicked(event);
      }
    };

    var gridApi = agGrid.createGrid(container, mergedOptions);

    // Create column selector floating button if it doesn't exist
    if (!container.querySelector('.grid-col-settings-btn')) {
      var origPos = window.getComputedStyle(container).position;
      if (origPos === 'static') {
        container.style.position = 'relative';
      }

      var btn = document.createElement('button');
      btn.className = 'grid-col-settings-btn';
      btn.innerHTML = '<span class="material-symbols-outlined" style="font-size: 16px; display: block;">view_column</span>';
      btn.title = 'Cấu hình cột & Bộ lọc';
      btn.style.position = 'absolute';
      btn.style.right = '6px';
      btn.style.top = '6px';
      btn.style.zIndex = '5';
      btn.style.width = '26px';
      btn.style.height = '26px';
      btn.style.borderRadius = '4px';
      btn.style.border = '1px solid var(--border, var(--color-border, #cbd5e1))';
      btn.style.background = 'var(--surface, var(--color-surface, #ffffff))';
      btn.style.color = 'var(--text-secondary, var(--color-text-secondary, #475569))';
      btn.style.cursor = 'pointer';
      btn.style.display = 'flex';
      btn.style.alignItems = 'center';
      btn.style.justifyContent = 'center';
      btn.style.boxShadow = '0 1px 2px rgba(0,0,0,0.05)';
      btn.style.transition = 'all 0.15s ease';

      btn.onmouseover = function () {
        btn.style.background = 'var(--bg, var(--color-background, #f1f5f9))';
      };
      btn.onmouseout = function () {
        btn.style.background = 'var(--surface, var(--color-surface, #ffffff))';
      };

      var popover = document.createElement('div');
      popover.className = 'grid-col-popover';
      popover.style.position = 'absolute';
      popover.style.right = '6px';
      popover.style.top = '36px';
      popover.style.zIndex = '1000';
      popover.style.background = 'var(--surface, var(--color-surface, #ffffff))';
      popover.style.border = '1px solid var(--border, var(--color-border, #cbd5e1))';
      popover.style.borderRadius = '6px';
      popover.style.padding = '10px';
      popover.style.boxShadow = '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)';
      popover.style.maxHeight = '240px';
      popover.style.overflowY = 'auto';
      popover.style.display = 'none';
      popover.style.flexDirection = 'column';
      popover.style.gap = '6px';
      popover.style.minWidth = '180px';

      container.appendChild(btn);
      container.appendChild(popover);

      function updatePopover() {
        popover.innerHTML = '';

        // Toggle Filter row at top of popover
        var filterLabel = document.createElement('label');
        filterLabel.style.display = 'flex';
        filterLabel.style.alignItems = 'center';
        filterLabel.style.gap = '8px';
        filterLabel.style.cursor = 'pointer';
        filterLabel.style.fontSize = '12px';
        filterLabel.style.fontWeight = '700';
        filterLabel.style.color = 'var(--text, var(--color-text, #1e293b))';
        filterLabel.style.borderBottom = '1px solid var(--border, var(--color-border, #cbd5e1))';
        filterLabel.style.paddingBottom = '6px';
        filterLabel.style.marginBottom = '6px';
        filterLabel.style.userSelect = 'none';

        var filterCheckbox = document.createElement('input');
        filterCheckbox.type = 'checkbox';
        filterCheckbox.style.cursor = 'pointer';
        filterCheckbox.checked = isFilterVisible;

        filterCheckbox.onchange = function () {
          var showFilter = filterCheckbox.checked;
          localStorage.setItem(filterStorageKey, showFilter ? 'true' : 'false');
          isFilterVisible = showFilter;

          var currentDefs = gridApi.getColumnDefs();
          var updatedDefs = currentDefs.map(function (col) {
            col.floatingFilter = showFilter;
            return col;
          });
          gridApi.setGridOption('columnDefs', updatedDefs);
        };

        filterLabel.appendChild(filterCheckbox);
        var filterSpan = document.createElement('span');
        filterSpan.innerText = 'Hiện ô tìm kiếm (Filter)';
        filterLabel.appendChild(filterSpan);
        popover.appendChild(filterLabel);

        // Column selection title
        var title = document.createElement('div');
        title.innerText = 'Ẩn/Hiện cột';
        title.style.fontWeight = '700';
        title.style.marginBottom = '6px';
        title.style.fontSize = '11px';
        title.style.textTransform = 'uppercase';
        title.style.color = 'var(--text-secondary, var(--color-text-secondary, #64748b))';
        popover.appendChild(title);

        var colDefs = mergedOptions.columnDefs || [];
        colDefs.forEach(function (col) {
          var colId = col.field || col.colId;
          var header = col.headerName;
          if (!colId || !header) return;

          var label = document.createElement('label');
          label.style.display = 'flex';
          label.style.alignItems = 'center';
          label.style.gap = '8px';
          label.style.cursor = 'pointer';
          label.style.fontSize = '12px';
          label.style.color = 'var(--text, var(--color-text, #1e293b))';
          label.style.userSelect = 'none';

          var checkbox = document.createElement('input');
          checkbox.type = 'checkbox';
          checkbox.style.cursor = 'pointer';

          var isVisible = true;
          var colState = gridApi.getColumnState().find(function (s) { return s.colId === colId; });
          if (colState) {
            isVisible = !colState.hide;
          }
          checkbox.checked = isVisible;

          checkbox.onchange = function () {
            var visible = checkbox.checked;
            gridApi.setColumnVisible(colId, visible);

            var currentHidden = [];
            var states = gridApi.getColumnState();
            states.forEach(function (s) {
              if (s.hide) {
                var foundDef = colDefs.find(function (d) { return (d.field || d.colId) === s.colId; });
                if (foundDef && foundDef.headerName) {
                  currentHidden.push(s.colId);
                }
              }
            });
            localStorage.setItem(storageKey, JSON.stringify(currentHidden));
          };

          label.appendChild(checkbox);
          var txtSpan = document.createElement('span');
          txtSpan.innerText = header;
          label.appendChild(txtSpan);
          popover.appendChild(label);
        });
      }

      btn.onclick = function (e) {
        e.stopPropagation();
        var isHidden = popover.style.display === 'none';
        if (isHidden) {
          updatePopover();
          popover.style.display = 'flex';
        } else {
          popover.style.display = 'none';
        }
      };

      document.addEventListener('click', function (e) {
        if (!popover.contains(e.target) && e.target !== btn && !btn.contains(e.target)) {
          popover.style.display = 'none';
        }
      });
    }

    // Lang nghe thay doi class cua body de doi theme
    var observer = new MutationObserver(function () {
      var newTheme = self.getThemeClass();
      if (container.className !== newTheme) {
        container.className = newTheme;
      }
    });
    observer.observe(document.body, { attributes: true, attributeFilter: ['class'] });

    // Luu lai ref de destroy neu can
    gridApi._observer = observer;

    return gridApi;
  }
};
