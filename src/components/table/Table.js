/**
 * Table Component
 * Sinh ra DataGrid Table với JS.
 */
var UITable = (function () {

  /**
   * Tạo Datagrid Table
   * @param {Object} config - { headers (Array), data (Array), columns (Array of mappings), className }
   */
  function create(config) {
    var wrapper = document.createElement('div');
    wrapper.className = 'table-wrapper ' + (config.className || '');

    var table = document.createElement('table');
    table.className = 'data-table';

    // Tbody
    var tbody = document.createElement('tbody');
    table.appendChild(tbody);

    var currentData = config.data ? config.data.slice() : [];
    var currentSort = config.currentSort ? { field: config.currentSort.field, dir: config.currentSort.dir } : { field: null, dir: 'asc' };

    function renderBody() {
      tbody.innerHTML = '';
      if (currentData && currentData.length > 0) {
        currentData.forEach(function(row) {
          var tr = document.createElement('tr');
          
          if (config.columns) {
            config.columns.forEach(function(col, idx) {
              var td = document.createElement('td');
              if (col.align) td.style.textAlign = col.align;
              
              if (config.headers && config.headers[idx] && config.headers[idx].label) {
                td.setAttribute('data-label', config.headers[idx].label);
              }
              
              var val = row[col.field];
              if (col.render) {
                var rendered = col.render(val, row);
                if (typeof rendered === 'string') td.innerHTML = rendered;
                else if (rendered instanceof Node) td.appendChild(rendered);
              } else {
                td.innerText = val !== undefined && val !== null ? val : '';
              }
              tr.appendChild(td);
            });
          } else {
            row.forEach(function(cellStr) {
              var td = document.createElement('td');
              if (typeof cellStr === 'string' && cellStr.indexOf('<') > -1) {
                td.innerHTML = cellStr;
              } else {
                td.innerText = cellStr;
              }
              tr.appendChild(td);
            });
          }

          tbody.appendChild(tr);
      });
    } else {
         var trEmpty = document.createElement('tr');
         var tdEmpty = document.createElement('td');
         tdEmpty.colSpan = config.headers ? config.headers.length : 1;
         tdEmpty.style.textAlign = 'center';
         tdEmpty.style.padding = '32px';
         tdEmpty.style.color = 'var(--color-text-secondary)';
         tdEmpty.innerText = 'Không có dữ liệu';
         trEmpty.appendChild(tdEmpty);
         tbody.appendChild(trEmpty);
      }
    }

    // Thead
    if (config.headers && config.headers.length > 0) {
      var thead = document.createElement('thead');
      var trHead = document.createElement('tr');
      
      config.headers.forEach(function(h, idx) {
        var th = document.createElement('th');
        
        var spanTxt = document.createElement('span');
        spanTxt.innerText = h.label || h;
        th.appendChild(spanTxt);

        if (h.width) th.style.width = h.width;
        if (h.align) th.style.textAlign = h.align;

        // Nếu header có sortable
        if (h.sortable && h.field) {
          th.style.cursor = 'pointer';
          th.style.userSelect = 'none';
          
          var icon = document.createElement('span');
          icon.className = 'material-symbols-outlined sort-icon';
          
          if (currentSort.field === h.field) {
            icon.innerText = currentSort.dir === 'asc' ? 'expand_less' : 'expand_more';
            icon.style.color = 'var(--color-primary)';
          } else {
            icon.innerText = 'unfold_more';
            icon.style.color = 'var(--color-text-secondary)';
          }
          
          icon.style.fontSize = '14px';
          icon.style.verticalAlign = 'middle';
          icon.style.marginLeft = '4px';
          th.appendChild(icon);

          th.addEventListener('click', function() {
            // Reset all icons
            trHead.querySelectorAll('.sort-icon').forEach(function(i) {
              i.innerText = 'unfold_more';
              i.style.color = 'var(--color-text-secondary)';
            });

            if (currentSort.field === h.field) {
              currentSort.dir = currentSort.dir === 'asc' ? 'desc' : 'asc';
            } else {
              currentSort.field = h.field;
              currentSort.dir = 'asc';
            }

            icon.innerText = currentSort.dir === 'asc' ? 'expand_less' : 'expand_more';
            icon.style.color = 'var(--color-primary)';

            if (typeof config.onSort === 'function') {
              // Server-side sort callback
              config.onSort(currentSort.field, currentSort.dir);
            } else {
              // Client-side sort
              currentData.sort(function(a, b) {
                var v1 = a[h.field];
                var v2 = b[h.field];
                if (v1 === v2) return 0;
                if (v1 == null) return currentSort.dir === 'asc' ? -1 : 1;
                if (v2 == null) return currentSort.dir === 'asc' ? 1 : -1;
                
                if (typeof v1 === 'string') v1 = v1.toLowerCase();
                if (typeof v2 === 'string') v2 = v2.toLowerCase();
                
                if (v1 < v2) return currentSort.dir === 'asc' ? -1 : 1;
                return currentSort.dir === 'asc' ? 1 : -1;
              });
              renderBody();
            }
            // Re-trigger re-selection logic if needed (handled by external click listener on tbody)
          });
        }
        
        trHead.appendChild(th);
      });
      thead.appendChild(trHead);
      table.appendChild(thead);
    }

    renderBody();
    wrapper.appendChild(table);

    return wrapper;
  }

  /**
   * Tạo Datagrid Table động từ dữ liệu SQL
   * @param {Array} data - Dữ liệu thô từ API
   * @param {Object} dictionary - Map tên cột { 'Makh': 'Mã KH' }
   * @param {Object} options - { onSort, currentSort, actionRenderers }
   */
  function createDynamic(data, dictionary, options) {
    dictionary = dictionary || {};
    options = options || {};

    var dynamicHeaders = [];
    var dynamicColumns = [];

    // Lấy keys từ data, nếu data rỗng thì lấy từ dictionary
    var keys = [];
    if (data && data.length > 0) {
      keys = Object.keys(data[0]);
    } else if (dictionary && Object.keys(dictionary).length > 0) {
      keys = Object.keys(dictionary);
    }

    if (keys.length > 0) {
      keys.forEach(function(key) {
        if (key === 'id' || key === 'Id') return;
        
        var headerLabel = dictionary[key] || key;
        var header = { label: headerLabel, sortable: true, field: key };
        var col = { field: key };

        // Default render: Tooltip
        col.render = function(v) { 
          if (v == null || v === '') return '';
          var safeVal = String(v).replace(/"/g, '&quot;');
          return '<span title="' + safeVal + '">' + safeVal + '</span>'; 
        };

        // Heuristic Width
        var keyLower = key.toLowerCase();
        if (keyLower.indexOf('dt') >= 0 || keyLower.indexOf('dienthoai') >= 0 || keyLower.indexOf('date') >= 0 || keyLower.indexOf('user') >= 0 || keyLower.indexOf('ma') === 0) {
          header.width = '120px';
        } else if (keyLower.indexOf('so') === 0 || keyLower.indexOf('sl') === 0 || keyLower.indexOf('số') === 0) {
          header.width = '90px';
        } else if (keyLower.indexOf('mail') >= 0) {
          header.width = '160px';
        } else if (keyLower.indexOf('diachi') >= 0 || keyLower.indexOf('địa chỉ') >= 0) {
          header.width = '200px';
        } else {
          header.width = '150px';
        }

        // Heuristic Format
        if (keyLower.indexOf('date') >= 0 || keyLower.indexOf('ngày') >= 0) {
          header.align = 'center';
          col.align = 'center';
          col.render = function(v) { return typeof FormatUtils !== 'undefined' ? FormatUtils.date(v) : v; };
        }

        // Custom renderer (nếu truyền vào)
        if (options.actionRenderers && options.actionRenderers[key]) {
          var customRender = options.actionRenderers[key];
          col.render = function(v) { return customRender(v, key); };
        } else if (options.actionRenderers && options.actionRenderers[headerLabel]) {
          // Hoặc kiểm tra theo label tiếng Việt nếu dev truyền key là label
          var customRenderLabel = options.actionRenderers[headerLabel];
          col.render = function(v) { return customRenderLabel(v, key); };
        }

        dynamicHeaders.push(header);
        dynamicColumns.push(col);
      });
    }

    var tableConfig = {
      headers: dynamicHeaders,
      columns: dynamicColumns,
      data: data,
      currentSort: options.currentSort,
      onSort: options.onSort,
      className: options.className
    };

    return create(tableConfig);
  }

  return {
    create: create,
    createDynamic: createDynamic
  };
})();
