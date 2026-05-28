/**
 * DocumentExportPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin inject nút "Xuất tài liệu" vào toolbar của 3 trang:
 *   /contract   → frmHopDong   → Hợp đồng tiệc     (PK: Sohopdong)
 *   /booking    → frmDatCoc    → Biên nhận đặt cọc (PK: MaChungTu)
 *   /checkout   → frmQuyetToan → Quyết toán        (PK: Sohopdong)
 *
 * Cơ chế:
 *   1. Lắng nghe hashchange
 *   2. Nếu path thuộc danh sách target → dùng MutationObserver chờ
 *      DynamicFormEngine render xong (#dynamic-btn-container)
 *   3. Inject nút sau toolbar, track selected row qua rowSelectionToggled
 *   4. Click nút → POST /api/documents/generate → redirect #/document-manager
 */
var DocumentExportPlugin = (function () {

  // ── Cấu hình từng route ─────────────────────────────────────────────────
  var ROUTE_CONFIG = {
    '/contract': {
      docType: 'hop_dong',
      label: 'Xuất Hợp Đồng',
      icon: 'description',
      primaryKey: 'Sohopdong',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong']
    },
    '/booking': {
      docType: 'dat_coc',
      label: 'Xuất Biên Nhận Cọc',
      icon: 'receipt_long',
      primaryKey: 'MaChungTu',
      altKeys: ['MaChungTu', 'maChungTu', 'DocumentID', 'SoPhieu']
    },
    '/checkout': {
      docType: 'quyet_toan',
      label: 'Xuất Quyết Toán',
      icon: 'receipt',
      primaryKey: 'Sohopdong',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong']
    }
  };

  var DOC_API_BASE = 'http://127.0.0.1:5000/api/documents';

  // ── State ───────────────────────────────────────────────────────────────
  var _currentPath   = '';
  var _observer      = null;  // MutationObserver
  var _selectedRow   = null;  // Row hiện tại đang chọn
  var _exportBtn     = null;  // Nút đã inject

  // ── Lấy path từ hash ────────────────────────────────────────────────────
  function _getPath() {
    return window.location.hash.replace('#', '').split('?')[0] || '/dashboard';
  }

  // ── Đọc primary key từ row (thử nhiều tên field) ────────────────────────
  function _getPrimaryKey(row, config) {
    if (!row) return null;
    for (var i = 0; i < config.altKeys.length; i++) {
      var v = row[config.altKeys[i]];
      if (v !== undefined && v !== null && v !== '') return String(v);
    }
    return null;
  }

  // ── Inject nút vào toolbar ───────────────────────────────────────────────
  function _injectButton(container, config) {
    // Tránh inject 2 lần
    if (container.querySelector('#doc-export-btn')) return;

    _selectedRow = null;

    // Tạo nút
    var btn = document.createElement('button');
    btn.id = 'doc-export-btn';
    btn.title = config.label;
    btn.setAttribute('aria-label', config.label);

    // Style: giống các nút tool trong toolbar của project
    btn.className = 'btn btn-tool d-flex align-items-center gap-1';
    btn.style.cssText = '';
    btn.innerHTML =
      '<span class="material-symbols-outlined" style="font-size:18px;">' + config.icon + '</span>' +
      '<span>' + config.label + '</span>';

    // Disabled mặc định cho đến khi chọn row
    btn.disabled = true;
    btn.style.opacity = '0.5';
    btn.style.cursor = 'not-allowed';

    _exportBtn = btn;

    // Click handler
    btn.addEventListener('click', function () {
      if (!_selectedRow) {
        if (typeof Alert !== 'undefined') {
          Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 dòng để xuất tài liệu.');
        } else {
          alert('Vui lòng chọn 1 dòng để xuất tài liệu!');
        }
        return;
      }

      var docId = _getPrimaryKey(_selectedRow, config);
      if (!docId) {
        if (typeof Alert !== 'undefined') {
          Alert.error('Lỗi', 'Không tìm thấy mã chứng từ của dòng này. Kiểm tra lại cấu hình primaryKey.');
        } else {
          alert('Không tìm thấy ID của dòng này!');
        }
        return;
      }

      _generateDocument(docId, config, btn);
    });

    // Track selection thông qua event rowSelectionToggled trên tbody
    // (DynamicFormEngine fire event này khi chọn/bỏ chọn)
    _listenRowSelection(container, config);

    var toolbar = container.querySelector('.action-toolbar, [class*="toolbar"], .button-bar');
    if (toolbar) {
      // Thêm separator + nút VÀO TRONG toolbar để đồng bộ flexbox
      var sep = document.createElement('div');
      sep.style.cssText = 'width:1px;background:var(--color-border,rgba(0,0,0,.1));margin:4px 6px;align-self:stretch;';
      toolbar.appendChild(sep);
      toolbar.appendChild(btn);
    } else {
      container.appendChild(btn);
    }
  }

  // ── Theo dõi chọn row ────────────────────────────────────────────────────
  // -- Map route -> FormName (khop voi key sessionStorage cua DynamicFormEngine) ----
  var FORM_NAME_MAP = {
    '/contract': 'frmHopDong',
    '/booking':  'frmDatCoc',
    '/checkout': 'frmQuyetToan'
  };

  // -- Theo doi chon row: doc tu sessionStorage sau click --------------------
  function _listenRowSelection(btnContainer, config) {
    var _onAnyClick = function (e) {
      if (!e.target.closest('#dynamic-grid-container')) return;
      setTimeout(_syncFromSession, 80);
    };
    var _onToggle = function (e) {
      setTimeout(_syncFromSession, 80);
    };

    // Cleanup cu
    if (document.__depClickHandler)  document.removeEventListener('click', document.__depClickHandler, true);
    if (document.__depToggleHandler) document.removeEventListener('rowSelectionToggled', document.__depToggleHandler, true);

    document.__depClickHandler  = _onAnyClick;
    document.__depToggleHandler = _onToggle;

    document.addEventListener('click', _onAnyClick, true);
    document.addEventListener('rowSelectionToggled', _onToggle, true);

    // Sync ngay lần đầu load (vì table có thể khôi phục trạng thái chọn từ sessionStorage)
    setTimeout(_syncFromSession, 100);
  }

  // -- Doc selectedRows tu sessionStorage cua DynamicFormEngine ---------------
  function _syncFromSession() {
    var path = _getPath();
    var formName = FORM_NAME_MAP[path];
    if (!formName) return;

    var key = 'selectedRows_' + formName;
    var rows = [];
    try {
      var raw = sessionStorage.getItem(key);
      rows = raw ? JSON.parse(raw) : [];
    } catch (e) { rows = []; }

    if (rows.length === 0) {
      _selectedRow = null;
      _updateBtnState(false);
    } else if (rows.length === 1) {
      _selectedRow = rows[0];
      _updateBtnState(true);
    } else {
      // Nhieu dong chon -> chi cho chon 1
      _selectedRow = null;
      _updateBtnState(false, 'Chi chon 1 dong de xuat tai lieu');
    }
  }
  function _updateBtnState(enabled, tooltip) {
    if (!_exportBtn) return;
    _exportBtn.disabled = !enabled;
    _exportBtn.style.opacity = enabled ? '1' : '0.5';
    _exportBtn.style.cursor  = enabled ? 'pointer' : 'not-allowed';
    if (tooltip) _exportBtn.title = tooltip;
    else {
      var path = _getPath();
      var cfg = ROUTE_CONFIG[path];
      if (cfg) _exportBtn.title = cfg.label;
    }
  }

  // ── Gọi API generate document ────────────────────────────────────────────
  function _generateDocument(tiecId, config, btn) {
    var originalHTML = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;animation:spin 1s linear infinite;">autorenew</span><span class="d-none d-md-inline">Đang xuất...</span>';

    // Inject spin keyframe 1 lần
    if (!document.getElementById('__dep_spin__')) {
      var ks = document.createElement('style');
      ks.id = '__dep_spin__';
      ks.textContent = '@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}';
      document.head.appendChild(ks);
    }

    fetch(DOC_API_BASE + '/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        templateType: config.docType,
        customerId: tiecId,
        outputFileName: config.docType + '_' + tiecId,
        rowData: _selectedRow   // ← gửi thẳng data từ row đang chọn
      })
    })
      .then(function (res) { return res.json(); })
      .then(function (json) {
        if (json.success) {
          if (typeof Toast !== 'undefined') {
            Toast.show({ message: 'Đã tạo tài liệu: ' + json.fileName, type: 'success' });
          }
          // Lưu tên file vừa tạo để DocumentManagerPage tự highlight khi load
          sessionStorage.setItem('docmgr_open_file', json.fileName);
          // Navigate sang document-manager
          window.location.hash = '#/document-manager';
        } else {
          if (typeof Alert !== 'undefined') {
            Alert.error('Lỗi xuất tài liệu', json.message || 'Không xác định');
          } else {
            alert('Lỗi: ' + json.message);
          }
        }
      })
      .catch(function (err) {
        if (typeof Alert !== 'undefined') {
          Alert.error('Lỗi kết nối', 'Không thể kết nối tới Document Server.');
        } else {
          alert('Lỗi kết nối!');
        }
        console.error('[DocumentExportPlugin]', err);
      })
      .finally(function () {
        btn.disabled = false;
        btn.innerHTML = originalHTML;
        _updateBtnState(!!_selectedRow);
      });
  }

  // ── Observer: chờ DynamicFormEngine render xong ──────────────────────────
  function _watchForToolbar(config) {
    if (_observer) { _observer.disconnect(); _observer = null; }
    _exportBtn = null;
    _selectedRow = null;

    var appContent = document.getElementById('app-content');
    if (!appContent) return;

    _observer = new MutationObserver(function () {
      var container = document.getElementById('dynamic-btn-container');
      if (container && !container.querySelector('#doc-export-btn')) {
        _injectButton(container, config);
      }
    });

    _observer.observe(appContent, { childList: true, subtree: true });

    // Nếu đã render sẵn rồi (cache hit → render tức thì)
    var existing = document.getElementById('dynamic-btn-container');
    if (existing && !existing.querySelector('#doc-export-btn')) {
      _injectButton(existing, config);
    }
  }

  // ── Handle route change ──────────────────────────────────────────────────
  function _onRouteChange() {
    var path = _getPath();

    // Dọn sạch khi rời trang target
    if (_observer) { _observer.disconnect(); _observer = null; }
    _exportBtn = null;
    _selectedRow = null;

    var config = ROUTE_CONFIG[path];
    if (config) {
      _currentPath = path;
      _watchForToolbar(config);
    }
  }

  // ── Init ─────────────────────────────────────────────────────────────────
  function init() {
    window.addEventListener('hashchange', _onRouteChange);
    _onRouteChange(); // Check route hiện tại ngay khi load
  }

  return { init: init };
})();
