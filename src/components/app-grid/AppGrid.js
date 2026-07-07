/**
 * AppGrid.js - AG Grid Helper for Wedding-Banquet-Management
 */
var AppGrid = {
  getThemeClass: function() {
    var isDark = document.body.classList.contains('dark-theme') || 
                 localStorage.getItem('pmql_theme') === 'dark';
    return isDark ? 'ag-theme-quartz-dark' : 'ag-theme-quartz';
  },

  create: function(container, customOptions) {
    var self = this;
    
    // Set class ban dau cho container
    container.className = self.getThemeClass();

    var defaultOptions = {
      pagination: true,
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

    var gridApi = agGrid.createGrid(container, mergedOptions);
    
    // Lang nghe thay doi class cua body de doi theme
    var observer = new MutationObserver(function() {
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
