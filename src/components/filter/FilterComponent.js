/**
 * Filter Component
 * Thanh công cụ lọc dữ liệu
 */
var FilterComponent = (function () {
  /**
   * Tạo component bộ lọc
   * @param {Array} filters - Cấu hình các trường (vd: { id, label, type, placeholder })
   * @param {function} onSearch - Hàm callback khi bấm "Lọc"
   * @returns {HTMLElement} wrapper
   */
  function create(filters, onSearch) {
    var wrapper = document.createElement('div');
    wrapper.className = 'filter-wrapper';

    var inputs = {};

    filters.forEach(function(f) {
      var item = document.createElement('div');
      item.className = 'filter-item';
      // Inline styling to force horizontal alignment
      item.style.flexDirection = 'row';
      item.style.alignItems = 'center';
      item.style.minWidth = 'auto';

      if (f.label) {
        var lbl = document.createElement('label');
        lbl.innerText = f.label + ':';
        lbl.style.marginBottom = '0';
        lbl.style.whiteSpace = 'nowrap';
        item.appendChild(lbl);
      }

      var input = document.createElement('input');
      input.type = f.type || 'text';
      input.className = 'ui-input';
      // Set placeholder properly
      input.placeholder = f.placeholder || f.label || '';
      input.id = f.id;

      inputs[f.id] = input;
      item.appendChild(input);
      wrapper.appendChild(item);
    });

    var actions = document.createElement('div');
    actions.className = 'filter-actions';
    // Reset fixed height from CSS to align horizontally with the inputs
    actions.style.height = 'auto';
    actions.style.alignItems = 'center';

    var btnSearch = document.createElement('button');
    btnSearch.className = 'btn btn-primary';
    btnSearch.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">search</span> Lọc dữ liệu';
    btnSearch.onclick = function() {
      if (typeof onSearch === 'function') {
        var values = {};
        for(var key in inputs) {
          values[key] = inputs[key].value;
        }
        onSearch(values);
      }
    };

    var btnReset = document.createElement('button');
    btnReset.className = 'btn btn-secondary';
    btnReset.innerText = 'Xóa bộ lọc';
    btnReset.onclick = function() {
      for(var key in inputs) {
        inputs[key].value = '';
      }
      if (typeof onSearch === 'function') onSearch({});
    };

    actions.appendChild(btnSearch);
    actions.appendChild(btnReset);
    wrapper.appendChild(actions);

    return wrapper;
  }

  return {
    create: create
  };
})();
