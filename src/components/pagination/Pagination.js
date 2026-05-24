/**
 * Pagination Component
 * Trình phân trang cho DataGrid
 */
var Pagination = (function () {
  /**
   * Tạo component phân trang
   * @param {Object} options - { totalItems, itemsPerPage, currentPage, onPageChange }
   * @returns {HTMLElement} wrapper
   */
  function create(options) {
    var wrapper = document.createElement('div');
    wrapper.className = 'pagination-wrapper';

    var totalPages = Math.ceil(options.totalItems / (options.itemsPerPage || 10));
    var currentPage = options.currentPage || 1;

    var startItem = (currentPage - 1) * options.itemsPerPage + 1;
    var endItem = Math.min(currentPage * options.itemsPerPage, options.totalItems);
    if (options.totalItems === 0) { startItem = 0; endItem = 0; }

    var info = document.createElement('div');
    info.className = 'pagination-info';
    info.innerText = `Hiển thị ${startItem}-${endItem} trong số ${options.totalItems} bản ghi`;

    var controls = document.createElement('div');
    controls.className = 'pagination-controls';

    // Prev Button
    var btnPrev = document.createElement('button');
    btnPrev.className = 'page-btn';
    btnPrev.innerHTML = '<span class="material-symbols-outlined">chevron_left</span>';
    btnPrev.disabled = currentPage === 1;
    btnPrev.onclick = function() {
      if (typeof options.onPageChange === 'function') options.onPageChange(currentPage - 1);
    };
    controls.appendChild(btnPrev);

    // Page numbers logic with '...'
    var isMobile = window.innerWidth <= 480;
    var delta = isMobile ? 0 : 1; 
    var left = currentPage - delta;
    var right = currentPage + delta + 1;
    var range = [];
    var rangeWithDots = [];
    var l;

    for (var i = 1; i <= totalPages; i++) {
      if (i === 1 || i === totalPages || (i >= left && i < right)) {
        range.push(i);
      }
    }

    range.forEach(function(i) {
      if (l) {
        if (i - l === 2) {
          rangeWithDots.push(l + 1);
        } else if (i - l !== 1) {
          rangeWithDots.push('...');
        }
      }
      rangeWithDots.push(i);
      l = i;
    });

    rangeWithDots.forEach(function(i) {
      if (i === '...') {
        var dotBtn = document.createElement('span');
        dotBtn.className = 'page-btn dots';
        dotBtn.innerText = '...';
        controls.appendChild(dotBtn);
      } else {
        var pBtn = document.createElement('button');
        pBtn.className = 'page-btn' + (i === currentPage ? ' active' : '');
        pBtn.innerText = i;
        pBtn.onclick = function() {
          if (typeof options.onPageChange === 'function' && i !== currentPage) options.onPageChange(i);
        };
        controls.appendChild(pBtn);
      }
    });

    // Next Button
    var btnNext = document.createElement('button');
    btnNext.className = 'page-btn';
    btnNext.innerHTML = '<span class="material-symbols-outlined">chevron_right</span>';
    btnNext.disabled = currentPage === totalPages || totalPages === 0;
    btnNext.onclick = function() {
      if (typeof options.onPageChange === 'function') options.onPageChange(currentPage + 1);
    };
    controls.appendChild(btnNext);

    wrapper.appendChild(info);
    wrapper.appendChild(controls);

    return wrapper;
  }

  return {
    create: create
  };
})();
