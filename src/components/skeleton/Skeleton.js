/**
 * UISkeleton - Reusable Skeleton Loader Component
 * Hỗ trợ tạo skeleton dynamic cho các cấu trúc: Table, Grid/Card, List, Form.
 */
var UISkeleton = (function () {
  
  /**
   * Tạo độ rộng ngẫu nhiên cho skeleton text để trông tự nhiên hơn
   */
  function getRandomWidth(min, max) {
    return Math.floor(Math.random() * (max - min + 1) + min) + '%';
  }

  /**
   * Tạo Skeleton dạng Bảng dữ liệu (Table)
   * @param {Object} options 
   *   - rows: số lượng dòng (mặc định 5)
   *   - cols: số lượng cột hoặc mảng các object cấu hình cột { width } (mặc định 4)
   *   - hasHeader: có hiển thị tiêu đề cột không (mặc định true)
   */
  function createTableHTML(options) {
    options = options || {};
    var rows = options.rows || 5;
    var cols = options.cols || 4;
    var hasHeader = options.hasHeader !== false;

    var colsConfig = [];
    if (typeof cols === 'number') {
      for (var i = 0; i < cols; i++) {
        colsConfig.push({ width: getRandomWidth(40, 80) });
      }
    } else if (Array.isArray(cols)) {
      colsConfig = cols.map(function(c) {
        if (typeof c === 'string' || typeof c === 'number') {
          return { width: c };
        }
        return c || {};
      });
    }

    var html = '<div class="table-wrapper">';
    html += '<table class="data-table skeleton-table">';
    
    if (hasHeader) {
      html += '<thead><tr>';
      colsConfig.forEach(function(col) {
        var w = col.width || '100px';
        html += '<th><div class="skeleton skeleton-text" style="width: ' + w + '; margin: 0;"></div></th>';
      });
      html += '</tr></thead>';
    }

    html += '<tbody>';
    for (var r = 0; r < rows; r++) {
      html += '<tr>';
      colsConfig.forEach(function(col) {
        var w = col.width || getRandomWidth(30, 80);
        html += '<td><div class="skeleton skeleton-text" style="width: ' + w + '; margin: 0;"></div></td>';
      });
      html += '</tr>';
    }
    html += '</tbody></table></div>';
    return html;
  }

  /**
   * Tạo Skeleton dạng Lưới thẻ (Grid Cards)
   * @param {Object} options 
   *   - count: số lượng card (mặc định 6)
   *   - gridClass: class bootstrap chia cột (mặc định 'col-12 col-md-6 col-lg-4')
   *   - hasMedia: có hiển thị phần hình ảnh/media không (mặc định false)
   */
  function createGridHTML(options) {
    options = options || {};
    var count = options.count || 6;
    var gridClass = options.gridClass || 'col-12 col-md-6 col-lg-4';
    var hasMedia = !!options.hasMedia;

    var html = '<div class="row g-4">';
    for (var i = 0; i < count; i++) {
      html += '<div class="' + gridClass + '">';
      html += '  <div class="card" style="height: 100%; border: 1px solid var(--color-border); border-radius: 8px; overflow: hidden; background: var(--color-surface);">';
      
      if (hasMedia) {
        html += '    <div class="skeleton" style="height: 160px; border-radius: 0;"></div>';
      }
      
      html += '    <div class="card-body" style="padding: 16px;">';
      html += '      <div class="skeleton skeleton-title" style="width: ' + getRandomWidth(50, 80) + ';"></div>';
      html += '      <div class="skeleton skeleton-text" style="width: 90%;"></div>';
      html += '      <div class="skeleton skeleton-text" style="width: 75%;"></div>';
      html += '      <div class="skeleton skeleton-text" style="width: 50%; margin-bottom: 0;"></div>';
      html += '    </div>';
      html += '  </div>';
      html += '</div>';
    }
    html += '</div>';
    return html;
  }

  /**
   * Tạo Skeleton dạng Danh sách (List)
   * @param {Object} options 
   *   - rows: số lượng dòng (mặc định 5)
   *   - hasAvatar: có hiển thị hình đại diện tròn không (mặc định true)
   */
  function createListHTML(options) {
    options = options || {};
    var rows = options.rows || 5;
    var hasAvatar = options.hasAvatar !== false;

    var html = '<div class="skeleton-list" style="display: flex; flex-direction: column; gap: 16px;">';
    for (var i = 0; i < rows; i++) {
      html += '<div class="skeleton-list-item" style="display: flex; align-items: center; gap: 16px; padding: 12px; background: var(--color-surface); border-radius: 8px; border: 1px solid var(--color-border);">';
      if (hasAvatar) {
        html += '  <div class="skeleton skeleton-avatar" style="flex-shrink: 0;"></div>';
      }
      html += '  <div style="flex-grow: 1;">';
      html += '    <div class="skeleton skeleton-title" style="width: ' + getRandomWidth(30, 60) + '; margin-bottom: 8px;"></div>';
      html += '    <div class="skeleton skeleton-text" style="width: ' + getRandomWidth(70, 95) + '; margin-bottom: 0;"></div>';
      html += '  </div>';
      html += '</div>';
    }
    html += '</div>';
    return html;
  }

  /**
   * Tạo Skeleton dạng Form nhập liệu
   * @param {Object} options 
   *   - fields: số lượng trường nhập liệu (mặc định 4)
   *   - gridClass: class bootstrap chia cột cho từng field (mặc định 'col-12 col-md-6')
   */
  function createFormHTML(options) {
    options = options || {};
    var fields = options.fields || 4;
    var gridClass = options.gridClass || 'col-12 col-md-6';

    var html = '<div class="row g-4">';
    for (var i = 0; i < fields; i++) {
      html += '<div class="' + gridClass + '">';
      html += '  <div class="form-group">';
      html += '    <div class="skeleton skeleton-text" style="width: ' + getRandomWidth(25, 45) + '; height: 14px; margin-bottom: 8px;"></div>';
      html += '    <div class="skeleton" style="height: 38px; border-radius: var(--radius-sm);"></div>';
      html += '  </div>';
      html += '</div>';
    }
    html += '</div>';
    return html;
  }

  /**
   * Tạo đối tượng DOM Skeleton
   * @param {Object} options 
   *   - type: 'table' | 'grid' | 'card' | 'list' | 'form' (mặc định 'list')
   *   - các cấu hình tương ứng tùy loại
   */
  function create(options) {
    options = options || {};
    var type = options.type || 'list';
    var html = '';
    
    switch (type) {
      case 'table':
        html = createTableHTML(options);
        break;
      case 'grid':
      case 'card':
        html = createGridHTML(options);
        break;
      case 'form':
        html = createFormHTML(options);
        break;
      case 'list':
      default:
        html = createListHTML(options);
        break;
    }
    
    var div = document.createElement('div');
    div.className = 'skeleton-container';
    div.innerHTML = html;
    return div;
  }

  return {
    create: create,
    createHTML: function(options) {
      options = options || {};
      var type = options.type || 'list';
      switch (type) {
        case 'table': return createTableHTML(options);
        case 'grid':
        case 'card': return createGridHTML(options);
        case 'form': return createFormHTML(options);
        case 'list':
        default: return createListHTML(options);
      }
    },
    createTableHTML: createTableHTML,
    createGridHTML: createGridHTML,
    createListHTML: createListHTML,
    createFormHTML: createFormHTML
  };
})();
