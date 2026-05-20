/**
 * Module Chương Trình Ưu Đãi / Combo (Promotions Page)
 * Route: #/promotions | Module: DanhMuc
 * HTML Template: src/pages/promotions/promotions.html
 */
var PromotionsPage = (function () {

  var _benefitRowCount = 2; // Số dòng ưu đãi hiện có

  function render($container) {
    fetch('./src/pages/promotions/promotions.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _bindEvents();
      });
  }

  // ── Mở / Đóng Panel ──────────────────────────────────────────────────
  function _openPanel() {
    var overlay = document.getElementById('promo-form-overlay');
    var panel   = document.getElementById('promo-form-panel');
    if (overlay) overlay.classList.add('active');
    if (panel)   panel.style.right = '0';
  }

  function _closePanel() {
    var overlay = document.getElementById('promo-form-overlay');
    var panel   = document.getElementById('promo-form-panel');
    if (overlay) overlay.classList.remove('active');
    if (panel)   panel.style.right = '-840px';
  }

  // ── Thêm dòng ưu đãi ─────────────────────────────────────────────────
  function _addBenefitRow() {
    _benefitRowCount++;
    var tbody = document.getElementById('promo-benefits-body');
    if (!tbody) return;
    var tr = document.createElement('tr');
    tr.setAttribute('data-row', _benefitRowCount);
    tr.innerHTML =
      '<td style="color: var(--color-text-secondary); font-size: 13px;">' + _benefitRowCount + '</td>' +
      '<td><input type="text" class="ui-input w-100" placeholder="Tên ưu đãi..." style="border: none; background: transparent;"></td>' +
      '<td><input type="text" class="ui-input w-100" placeholder="Số lượng / đơn vị" style="border: none; background: transparent;"></td>' +
      '<td><input type="number" class="ui-input w-100" placeholder="0" style="border: none; background: transparent;" min="0"></td>' +
      '<td>' + UIButton.createHTML({ icon: 'delete', type: 'tool', className: 'btn-remove-benefit', style: 'color: var(--color-danger);', iconStyle: 'font-size: 18px;' }) + '</td>';
    tbody.appendChild(tr);
    _bindRemoveBenefit(tr.querySelector('.btn-remove-benefit'));
  }

  function _bindRemoveBenefit(btn) {
    if (!btn) return;
    btn.addEventListener('click', function () {
      var row = btn.closest('tr');
      if (row) row.remove();
      _renumberRows();
    });
  }

  function _renumberRows() {
    var rows = document.querySelectorAll('#promo-benefits-body tr');
    rows.forEach(function (row, idx) {
      var firstTd = row.querySelector('td:first-child');
      if (firstTd) firstTd.textContent = idx + 1;
    });
    _benefitRowCount = rows.length;
  }

  // ── Bind Events ───────────────────────────────────────────────────────
  function _bindEvents() {
    var overlay    = document.getElementById('promo-form-overlay');
    var btnAdd     = document.getElementById('btn-add-promotion');
    var btnClose   = document.getElementById('btn-close-promo-form');
    var btnCancel  = document.getElementById('btn-cancel-promo-form');
    var btnSave    = document.getElementById('btn-save-promo');
    var btnAddRow  = document.getElementById('btn-add-benefit');
    var btnsEdit   = document.querySelectorAll('.btn-edit-promotion');
    var searchInp  = document.getElementById('promo-search');
    var filterSt   = document.getElementById('promo-filter-status');
    var btnViewGrid  = document.getElementById('btn-view-grid');
    var btnViewTable = document.getElementById('btn-view-table');

    if (btnAdd)    btnAdd.addEventListener('click', _openPanel);
    if (btnClose)  btnClose.addEventListener('click', _closePanel);
    if (btnCancel) btnCancel.addEventListener('click', _closePanel);
    if (overlay)   overlay.addEventListener('click', _closePanel);

    btnsEdit.forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.stopPropagation();
        _openPanel();
      });
    });

    // Thêm dòng ưu đãi
    if (btnAddRow) btnAddRow.addEventListener('click', _addBenefitRow);

    // Xóa dòng ưu đãi (bind cho dòng có sẵn)
    document.querySelectorAll('.btn-remove-benefit').forEach(function (btn) {
      _bindRemoveBenefit(btn);
    });

    // Save handler (stub — kết nối API sau)
    if (btnSave) {
      btnSave.addEventListener('click', function () {
        var name = document.getElementById('promo-inp-name');
        if (!name || !name.value.trim()) {
          alert('Vui lòng nhập tên gói combo!');
          return;
        }
        // TODO: Kết nối API_WA_LuuUuDai
        _closePanel();
      });
    }

    // Search filter cards
    if (searchInp) {
      searchInp.addEventListener('input', function () {
        _filterCards(searchInp.value);
      });
    }

    // View toggle Grid / List (stub)
    if (btnViewGrid) {
      btnViewGrid.addEventListener('click', function () {
        var grid = document.getElementById('promo-card-grid');
        if (grid) {
          grid.querySelectorAll('.col-md-6').forEach(function(col) { col.className = 'col-md-6 col-lg-4'; });
        }
        btnViewGrid.style.background = 'var(--color-primary)';
        btnViewGrid.style.color = '#fff';
        if (btnViewTable) { btnViewTable.style.background = ''; btnViewTable.style.color = ''; }
      });
    }
    if (btnViewTable) {
      btnViewTable.addEventListener('click', function () {
        var grid = document.getElementById('promo-card-grid');
        if (grid) {
          grid.querySelectorAll('[class*="col-md-6"]').forEach(function(col) { col.className = 'col-12'; });
        }
        btnViewTable.style.background = 'var(--color-primary)';
        btnViewTable.style.color = '#fff';
        if (btnViewGrid) { btnViewGrid.style.background = ''; btnViewGrid.style.color = ''; }
      });
    }
  }

  function _filterCards(keyword) {
    var cards = document.querySelectorAll('#promo-card-grid > .col-md-6, #promo-card-grid > .col-12');
    cards.forEach(function (col) {
      var text = col.textContent.toLowerCase();
      col.style.display = (!keyword || text.indexOf(keyword.toLowerCase()) > -1) ? '' : 'none';
    });
  }

  return { render: render };
})();
