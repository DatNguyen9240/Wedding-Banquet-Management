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
    var currentSort = { field: null, dir: 'asc' };

    function renderBody() {
      tbody.innerHTML = '';
      if (currentData && currentData.length > 0) {
        currentData.forEach(function(row) {
          var tr = document.createElement('tr');
          
          if (config.columns) {
            config.columns.forEach(function(col) {
              var td = document.createElement('td');
              if (col.align) td.style.textAlign = col.align;
              
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
          icon.innerText = 'unfold_more';
          icon.style.fontSize = '14px';
          icon.style.verticalAlign = 'middle';
          icon.style.marginLeft = '4px';
          icon.style.color = 'var(--color-text-secondary)';
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

  return {
    create: create
  };
})();
