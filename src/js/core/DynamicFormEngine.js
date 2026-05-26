/**
 * Dynamic Form Engine - Generic Metadata-Driven UI Engine
 */
window.DynamicFormEngine = (function () {

  var $container = null;
  var gridData = [];
  var selectedRows = [];
  var lastSelectedIdx = -1;

  var currentKeyword = '';
  var currentSortCol = '';
  var currentSortDir = '';
  var currentPage = 1;
  var currentLimit = 15;
  var totalRecords = 0;

  // Dữ liệu Từ điển lấy từ API (Database)
  var globalDictionary = {};
  var globalFormSchema = [];
  var globalRenderers = {};

  var MODULE_CONFIG = {};

  // ── Helpers ──────────────────────────────────────────────
  function _currentGroup() {
    var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    return u.Group || u.GroupUser || u.GroupID || u.group || u.NhomQuyen || 'Admin';
  }

  function _currentUser() {
    var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    return u.Username || u.UserName || u.username || 'Admin';
  }

  /**
   * Đọc giá trị boolean từ API field có thể trả về camelCase hoặc PascalCase
   * và có thể là '1'/true/1 hoặc '0'/false/0
   * @param {*} camel  - item.showInAdd, item.required ...
   * @param {*} pascal - item.ShowInAdd, item.IsRequired ...
   */
  function _bool(camel, pascal) {
    return String(camel) === '1' || camel === true || String(pascal) === '1' || pascal === true;
  }

  /**
   * Gọi API tuần tự cho mảng payload (tránh sập API khi gửi đồng loạt)
   * @param {string}   endpoint  - API URL
   * @param {Array}    payloads  - Mảng payload cần gọi lần lượt
   * @param {Function} onDone    - Gọi khi tất cả xong, nhận (successCount)
   * @param {Function} [onError] - Gọi khi 1 payload lỗi, nhận (err, payload, index)
   *                               Nếu return false → dừng chuỗi. Mặc định tiếp tục.
   */
  function _sendSequential(endpoint, payloads, onDone, onError) {
    var successCount = 0;
    function _next(i) {
      if (i >= payloads.length) { onDone(successCount); return; }
      ApiClient.post(endpoint, payloads[i])
        .then(function (res) {
          if (res && res.code === 0) successCount++;
          _next(i + 1);
        })
        .catch(function (err) {
          var stop = typeof onError === 'function' && onError(err, payloads[i], i) === false;
          if (!stop) _next(i + 1);
        });
    }
    _next(0);
  }

  /** Kiểm tra form hiện tại có phải Form Builder không */
  function _isFormBuilder() {
    return String(MODULE_CONFIG.FormName).toLowerCase() === 'frmformbuilder';
  }

  /**
   * Bật/tắt trạng thái loading trên nút bấm
   * @param {HTMLElement} btn
   * @param {boolean}     loading
   * @param {string}      [originalHTML] - HTML gốc để restore khi loading=false
   */
  function _setBtnLoading(btn, loading, originalHTML) {
    if (loading) {
      btn._originalHTML = btn.innerHTML;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang lưu...';
      btn.disabled = true;
    } else {
      btn.innerHTML = originalHTML || btn._originalHTML || btn.innerHTML;
      btn.disabled = false;
    }
  }

  /**
   * Áp giá trị mặc định cho object — chỉ ghi nếu chưa có (giống pattern X = X || default)
   * @param {Object} obj      - Object cần áp mặc định (ví dụ: MODULE_CONFIG)
   * @param {Object} defaults - Các giá trị mặc định { key: value }
   */
  function _setDefaults(obj, defaults) {
    Object.keys(defaults).forEach(function (k) {
      if (!obj[k]) obj[k] = defaults[k];
    });
  }

  /** Lưu selectedRows vào sessionStorage (silent fail) */
  function _saveSelectedRows() {
    try {
      sessionStorage.setItem('selectedRows_' + MODULE_CONFIG.FormName, JSON.stringify(selectedRows));
    } catch (e) { }
  }

  /** Đọc selectedRows từ sessionStorage (silent fail, trả mảng rỗng nếu lỗi) */
  function _loadSelectedRows() {
    try {
      var cached = sessionStorage.getItem('selectedRows_' + MODULE_CONFIG.FormName);
      selectedRows = cached ? JSON.parse(cached) : [];
    } catch (e) {
      selectedRows = [];
    }
  }

  /**
   * Khởi tạo payload chuẩn cho API: clone base, áp user + isEdit flag
   * @param {Object}  base   - Dữ liệu gốc (formInputData hoặc targetRow)
   * @param {boolean} isEdit - true = edit, false = add
   * @returns {Object} payload đã gắn UserName, UserCreate, IsEdit
   */
  function _buildPayload(base, isEdit) {
    var p = Object.assign({}, base);
    p.UserName   = _currentUser();
    p.UserCreate = _currentUser();
    p.IsEdit     = isEdit ? 1 : 0;
    return p;
  }

  function _hasPermission(action) {
    if (typeof Permission !== 'undefined') {
      var module = MODULE_CONFIG.FormName;
      if (action === 'ADD') return Permission.canAdd(module);
      if (action === 'EDIT') return Permission.canEdit(module);
      if (action === 'DELETE') return Permission.canDelete(module);
    }

    // Fallback logic
    var perms = JSON.parse(localStorage.getItem('pmql_permissions') || 'null');
    if (!perms) return true; // Chưa ráp hệ thống phân quyền thì thả cửa

    var targetKey = (MODULE_CONFIG.FormName || '').toLowerCase();
    var modulePerm = null;
    for (var key in perms) {
      if (key.toLowerCase() === targetKey) {
        modulePerm = perms[key];
        break;
      }
    }
    if (!modulePerm) return false; // Fail-closed

    if (action === 'ADD') return !!modulePerm.CanAdd;
    if (action === 'EDIT') return !!modulePerm.CanEdit;
    if (action === 'DELETE') return !!modulePerm.CanDelete;
    return true;
  }

  // ── Render ────────────────────────────────────────────────
  function render(container, config) {
    if (!container || !config) {
      console.error('DynamicFormEngine: Missing container or config');
      return;
    }
    $container = container;
    MODULE_CONFIG = config;

    // API defaults: FormBuilder dùng API chuyên biệt, các form khác dùng generic No-Code API
    _setDefaults(MODULE_CONFIG, _isFormBuilder() ? {
      ApiSearch: '/api/API_DanhSachTruongGiaoDien',
      ApiSave:   '/api/API_LuuTruongGiaoDien',
      ApiDelete: '/api/API_XoaTruongGiaoDien'
    } : {
      ApiSearch: '/api/API_TruyVanDong',
      ApiSave:   '/api/API_LuuDong',
      ApiDelete: '/api/API_XoaDong'
    });
    _setDefaults(MODULE_CONFIG, { ApiDictionary: '/api/API_LayCacTruongGiaoDien' });

    _loadSelectedRows();


    // 1. Lấy Từ điển UI từ Database trước (Cơ chế Caching siêu tốc)
    var configEndpoint = MODULE_CONFIG.ApiDictionary;
    var cacheKey = 'FormConfigCache_' + MODULE_CONFIG.FormName;
    var cachedData = null;

    // RAM Cache cho giao diện
    if (!_isFormBuilder()) {
      try { cachedData = window._uiConfigCache ? window._uiConfigCache[cacheKey] : null; } catch (e) { }
    }

    var pConfig;
    if (cachedData) {
      pConfig = Promise.resolve(JSON.parse(cachedData));
    } else {
      pConfig = configEndpoint ? ApiClient.post(configEndpoint, { FormName: MODULE_CONFIG.FormName }).then(function (res) {
        if (res && res.code === 0 && !_isFormBuilder()) {
          window._uiConfigCache = window._uiConfigCache || {};
          window._uiConfigCache[cacheKey] = JSON.stringify(res);
        }
        return res;
      }) : Promise.resolve(null);
    }

    pConfig.then(function (resConfig) {

      // 2. Lưu Từ điển vào biến toàn cục
      var dataList = resConfig ? (resConfig.list || resConfig.records) : null;
      if (resConfig && resConfig.code === 0 && dataList) {

        // --- NO-CODE MAGIC: Đọc cấu hình cấp Form từ Record đầu tiên ---
        if (dataList.length > 0) {
          var firstRow = dataList[0];

          // Map API fields → MODULE_CONFIG (chỉ ghi nếu API trả về giá trị)
          var _rowMap = { formTitle: 'PageTitle', primaryKey: 'PrimaryKey', formSubtitle: 'PageSubtitle' };
          Object.keys(_rowMap).forEach(function (src) {
            if (firstRow[src]) MODULE_CONFIG[_rowMap[src]] = firstRow[src];
          });

          // Sinh nhãn mặc định — caller có thể override từ config
          _setDefaults(MODULE_CONFIG, {
            TitleAdd:           '➕ Thêm ' + (firstRow.formTitle || 'Mới'),
            TitleEdit:          '✏️ Sửa '  + (firstRow.formTitle || ''),
            BtnSaveAdd:         'Thêm mới',
            BtnSaveEdit:        'Lưu thay đổi',
            BtnSaveAll:         'Lưu Tất Cả',
            BtnCancel:          'Hủy bỏ',
            BtnSaveSaving:      'Đang lưu...',
            ToastAdd:           'Đã thêm mới thành công!',
            ToastEdit:          'Đã cập nhật thành công!',
            ToastDelete:        'Xóa thành công!',
            WarnMissingInfo:    'Thiếu thông tin',
            WarnMissingInput:   'Vui lòng điền đầy đủ thông tin: {0}',
            WarnSelectEdit:     'Vui lòng chọn dữ liệu cần sửa',
            WarnSelectDelete:   'Vui lòng chọn dữ liệu cần xóa',
            ConfirmDelete:      'Bạn có chắc muốn xóa {0}?',
            TextDeleteFallback: 'dòng này',
            AlertTitleConfirm:  'Xác nhận xóa',
            AlertTitleWarning:  'Cảnh báo',
            AlertTitleError:    'Lỗi',
            AlertTitleInfo:     'Thông báo',
            AlertApiMissing:    'Chưa cấu hình API lưu',
            AlertSaveFailed:    'Lưu dữ liệu thất bại',
            AlertDeleteFailed:  'Xóa dữ liệu thất bại',
            AlertNetworkError:  'Lỗi kết nối mạng',
            ModalWidth:         '600px'
          });
        }

        globalDictionary = {};
        globalFormSchema = [];

        dataList.forEach(function (item) {
          // Xây Dictionary cho Table
          globalDictionary[item.name] = item.label;

          // Xây dựng Custom Renderers Động từ cấu hình DB
          if (item.renderRule) {
            globalRenderers[item.name] = function (v) {
              var rule = item.renderRule.toLowerCase();

              // Các rule là boolean/switch
              if (rule === 'sw' || rule === 'boolean') {
                var isChecked = (String(v) === '1' || String(v).toLowerCase() === 'true');
                return isChecked
                  ? '<span style="color:var(--color-success);"><span class="material-symbols-outlined" style="font-size:18px;vertical-align:middle;">check_circle</span></span>'
                  : '<span style="color:var(--color-text-tertiary);">-</span>';
              }

              if (!v || v === '0' || v === 0) return (rule.indexOf('badge:') === 0 || rule === 'bg' || rule === 'br' || rule === 'bw') ? '-' : v;

              // Phím tắt 2 ký tự cho FormatID (varchar 2)
              if (rule === 'bg') return '<span class="status-badge success">' + v + '</span>';
              if (rule === 'br') return '<span class="status-badge danger">' + v + '</span>';
              if (rule === 'bw') return '<span class="status-badge warning">' + v + '</span>';
              if (rule === 'cr') return '<span style="color:var(--color-danger);font-weight:600;">' + v + '</span>';
              if (rule === 'cg') return '<span style="color:var(--color-success);font-weight:600;">' + v + '</span>';
              if (rule === 'cb') return '<span style="color:var(--color-primary);font-weight:600;">' + v + '</span>';

              // Logic cũ (nếu xài text dài)
              if (item.renderRule.indexOf('Badge:') === 0) {
                var color = item.renderRule.split(':')[1];
                return '<span class="status-badge ' + color + '">' + v + '</span>';
              } else if (item.renderRule.indexOf('Color:') === 0) {
                var color = item.renderRule.split(':')[1];
                var safeVal = String(v).replace(/"/g, '&quot;');
                return '<span title="' + safeVal + '" style="color:var(--color-' + color + ');font-weight:600;">' + safeVal + '</span>';
              }
              return v;
            };
          }

          // Xây Schema cho Form (Lưu toàn bộ để lấy Khóa chính)
          globalFormSchema.push({
            name:          item.name         || item.FieldName,
            label:         item.label        || item.CaptionVN,
            required:      _bool(item.required,      item.IsRequired),
            showInAdd:     _bool(item.showInAdd,     item.ShowInAdd),
            showInEdit:    _bool(item.showInEdit,    item.ShowInEdit),
            isReadOnlyEdit:_bool(item.isReadOnlyEdit,item.IsReadOnlyEdit),
            isReadOnlyAdd: _bool(item.isReadOnlyAdd, item.IsReadOnlyAdd),
            position:      item.FormPosition || item.formPosition || item.position || 'grid',
            orderNo:       item.OrderNo      || item.orderNo     || 0,
            renderRule:    (item.renderRule  || '').toLowerCase().trim(),
            dataSource:    (item.dataSource  || item.DataSource  || '').trim(),
            validateRule:  (item.validateRule|| item.ValidateRule|| '').trim(),
            dependsOn:     (item.dependsOn   || item.DependsOn  || '').trim(),
            visibleRule:   (item.visibleRule  || item.VisibleRule || '').trim()
          });
        });

        if (Object.keys(globalDictionary).length === 0) {
          console.warn('API returned no fields for FormName:', MODULE_CONFIG.FormName);
        }
      } else {
        console.warn('API Dictionary fetch failed or empty', resConfig);
      }
      // Tự động sinh mã HTML (Không cần file .html rời nữa)
      $container.innerHTML = `
        <div class="page-title-bar">
          <div class="page-title-info">
            <h1 class="page-title-heading">${MODULE_CONFIG.PageTitle || 'Quản lý Dữ liệu'}</h1>
            <span class="page-title-sub">${MODULE_CONFIG.PageSubtitle || ''}</span>
          </div>
        </div>
        <div id="dynamic-btn-container" style="margin-bottom:16px;"></div>
        <div class="card dynamic-grid-card">
          <div class="card-body">
            <div id="dynamic-filter-container" style="margin-bottom:16px;"></div>
            <div id="dynamic-grid-container"></div>
          </div>
        </div>
      `;

      // Action Toolbar
      var btnContainer = $container.querySelector('#dynamic-btn-container');
      if (btnContainer && typeof UIActionToolbar !== 'undefined') {
        var toolbar = UIActionToolbar.create({
          onAdd: _hasPermission('ADD') ? _openAddForm : 'DISABLED',
          onEdit: _hasPermission('EDIT') ? function () {
            if (!selectedRows || selectedRows.length === 0) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectEdit);
            if (selectedRows.length > 1) {
              _openBulkEditForm();
            } else {
              _openEditForm(selectedRows[0]);
            }
          } : 'DISABLED',
          onDelete: _hasPermission('DELETE') ? function () {
            if (!selectedRows || selectedRows.length === 0) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectDelete);

            // Hàm thực thi xóa gọi API
            var performDelete = function () {
              if (!MODULE_CONFIG.ApiDelete) {
                return Alert.info(MODULE_CONFIG.AlertTitleInfo, MODULE_CONFIG.InfoDeleteDev);
              }

              var payload = {
                FormName: MODULE_CONFIG.FormName,
                UserName: _currentUser()
              };

              // Thu thập danh sách ID của các dòng đã chọn
              var ids = selectedRows.map(function (r) { return r[MODULE_CONFIG.PrimaryKey] || r.Id || r.AutoID; });
              payload.IDs = ids.join(',');

              ApiClient.post(MODULE_CONFIG.ApiDelete, payload).then(function (res) {
                if (res && res.code === 0) {
                  if (typeof Toast !== 'undefined') Toast.success(MODULE_CONFIG.ToastDelete);
                  selectedRows = [];
                  if (_isFormBuilder()) window._uiConfigCache = {};
                  _updateSelectionCounter();
                  _loadData();
                } else {
                  Alert.error(MODULE_CONFIG.AlertTitleError, res.message || MODULE_CONFIG.AlertDeleteFailed);
                }
              }).catch(function (err) {
                Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertNetworkError);
              });
            };

            // Xóa hàng loạt
            if (selectedRows.length > 1) {
              if (typeof ConfirmModal !== 'undefined') {
                ConfirmModal.show({
                  title: MODULE_CONFIG.AlertTitleConfirm,
                  message: `Bạn có chắc muốn xóa ${selectedRows.length} dòng đã chọn?`,
                  onConfirm: performDelete
                });
              }
            } else {
              var deleteName = selectedRows[0][MODULE_CONFIG.RowNameField] || MODULE_CONFIG.TextDeleteFallback;
              if (typeof ConfirmModal !== 'undefined') {
                ConfirmModal.show({
                  title: MODULE_CONFIG.AlertTitleConfirm,
                  message: MODULE_CONFIG.ConfirmDelete.replace('{0}', deleteName),
                  onConfirm: performDelete
                });
              }
            }
          } : false,
          onFilter: function () {
            var filterContainer = $container.querySelector('#dynamic-filter-container');
            if (filterContainer) {
              if (filterContainer.style.display === 'none') {
                filterContainer.style.display = 'flex';
                var inputKeyword = filterContainer.querySelector('#keyword');
                if (inputKeyword) inputKeyword.focus();
              } else {
                filterContainer.style.display = 'none';
              }
            }
          },
          onPrint: false,
          onClose: false
        });
        toolbar.style.display = 'inline-flex';
        toolbar.style.width = 'auto';

        // Custom Buttons
        var hasAdd = _hasPermission('ADD');
        var btnBulkAdd = UIButton.create({
          text: 'Thêm nhiều',
          icon: 'post_add',
          type: 'tool',
          disabled: !hasAdd,
          onClick: function () {
            if (!hasAdd) return typeof Alert !== 'undefined' ? Alert.warning('Từ chối', 'Bạn không có quyền thao tác chức năng này!') : null;
            var emptyRows = [];
            for (var i = 0; i < 3; i++) emptyRows.push({});
            _openBulkGridEditForm(emptyRows, true);
          }
        });
        // Chèn sau nút Thêm
        var btnAddOriginal = toolbar.querySelector('.btn-primary, [title*="Thêm bản ghi mới"]');
        if (btnAddOriginal) {
          btnAddOriginal.parentNode.insertBefore(btnBulkAdd, btnAddOriginal.nextSibling);
        } else {
          toolbar.insertBefore(btnBulkAdd, toolbar.firstChild);
        }

        // HACK: Thiết kế Layout dành riêng cho Form Builder
        if (_isFormBuilder()) {
          var divider = document.createElement('div');
          divider.className = 'divider';
          toolbar.appendChild(divider);

          var btnLayout = UIButton.create({
            text: 'Thiết kế Layout',
            icon: 'design_services',
            type: 'tool',
            onClick: _promptLayoutBuilder
          });
          toolbar.appendChild(btnLayout);
        }

        btnContainer.appendChild(toolbar);
      }

      // Search bar (FilterComponent)
      var filterContainer = $container.querySelector('#dynamic-filter-container');
      if (filterContainer && typeof FilterComponent !== 'undefined') {
        filterContainer.innerHTML = ''; // Xóa placeholder nếu có
        var filters = [
          { id: 'keyword', label: MODULE_CONFIG.FilterKeywordLabel, placeholder: MODULE_CONFIG.SearchPlaceholder }
        ];
        var filterNode = FilterComponent.create(filters, function (values) {
          currentKeyword = values.keyword || '';
          currentPage = 1; // Reset về trang 1 khi lọc mới
          _loadData();
        });
        filterContainer.appendChild(filterNode);
        filterContainer.style.display = 'none'; // Ẩn mặc định, ấn Lọc mới hiện
      }

      _loadData();
    })
      .catch(function (err) {
        $container.innerHTML = '<div class="p-4 text-danger">' + MODULE_CONFIG.TextLoadingError + err.message + '</div>';
      });
  }

  // ── Load Data ─────────────────────────────────────────────
  var savedScrollY = 0; // Lưu vị trí scroll

  function _loadData() {
    var gridContainer = $container ? $container.querySelector('#dynamic-grid-container') : null;
    var existingTable = gridContainer ? gridContainer.querySelector('.table-wrapper') : null;

    if (existingTable && typeof existingTable.showLoading === 'function') {
      savedScrollY = window.scrollY;
      existingTable.showLoading(MODULE_CONFIG.TextLoading);
    } else if (gridContainer) {
      gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">' + MODULE_CONFIG.TextLoading + '</div>';
    }

    if (MODULE_CONFIG.ApiSearch) {
      var query = {
        FormName: MODULE_CONFIG.FormName,
        UserName: _currentUser(),
        Keyword: currentKeyword, // Bỏ hack ép FormName vào Keyword để tránh API_TruyVanDong tìm kiếm sai
        SortColumn: currentSortCol,
        SortDir: currentSortDir,
        Page: currentPage,
        Limit: currentLimit
      };
      ApiClient.post(MODULE_CONFIG.ApiSearch, query).then(function (result) {
        totalRecords = result._recordtotal || 0;
        var dataList = result.list || result.records || [];
        gridData = dataList.map(function (item) {
          // Gắn ID tạm để Table hoạt động
          item.id = item[MODULE_CONFIG.PrimaryKey] || item.Id || item.AutoID || Math.random();
          return item;
        });
        _renderTable();
      }).catch(function (err) {
        console.error('Lỗi tải danh sách:', err);
        if (typeof Alert !== 'undefined') Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertNetworkError);
        gridData = [];
        totalRecords = 0;
        selectedRows = [];
        _updateSelectionCounter();
        _renderTable();
      });
    }
  }

  // ── Render Table ──────────────────────────────────────────
  function _renderTable() {
    var gridContainer = $container.querySelector('#dynamic-grid-container');
    if (!gridContainer) return;
    gridContainer.innerHTML = '';
    lastSelectedIdx = -1;

    if (typeof UITable !== 'undefined') {
      // Dùng bộ từ điển từ DB để dịch các cột sang Tiếng Việt
      var dictionary = globalDictionary;

      // Render các cột tùy chỉnh (Sinh ra tự động từ RenderRule trong DB)
      var customRenderers = globalRenderers;

      // Lọc ra các cột cần ẩn khỏi Lưới (Grid)
      var hiddenCols = globalFormSchema.filter(function(f) { return f.position !== 'grid'; }).map(function(f) { return f.name; });

      // Gọi UITable.createDynamic siêu cấp
      var tableEl = UITable.createDynamic(gridData, dictionary, {
        currentSort: { field: currentSortCol, dir: currentSortDir },
        onSort: function (field, dir) {
          currentSortCol = field;
          currentSortDir = dir;
          currentPage = 1;
          _loadData();
        },
        actionRenderers: customRenderers,
        hiddenColumns: hiddenCols
      });

      var actualTable = tableEl.querySelector('table');
      if (actualTable) actualTable.classList.add('no-mobile-stack');

      // Các tính năng nâng cao (Copy, Vuốt chọn) giờ đã được chuẩn hóa trong UITable
      // (Sẽ gọi sau khi gán gridData và selectedRows)

      gridContainer.appendChild(tableEl);

      // Thêm Pagination xuống dưới Table
      if (typeof Pagination !== 'undefined') {
        var paginationEl = Pagination.create({
          totalItems: totalRecords,
          itemsPerPage: currentLimit,
          currentPage: currentPage,
          onPageChange: function (page) {
            currentPage = page;
            _loadData();
          }
        });
        gridContainer.appendChild(paginationEl);
      }

      // Phục hồi vị trí cuộn trang
      if (savedScrollY > 0) {
        setTimeout(function () { window.scrollTo(0, savedScrollY); }, 10);
      }

      var tbody = tableEl.querySelector('tbody');
      if (tbody) {
        // Phục hồi trạng thái Active cho các dòng đã chọn trước đó (Cross-page Selection)
        var allTrs = Array.from(tbody.querySelectorAll('tr'));
        allTrs.forEach(function (tr, idx) {
          var rData = gridData[idx];
          if (rData && selectedRows.find(function (sr) { return sr.id === rData.id; })) {
            tr.classList.add('active');
          }
        });
        // Lắng nghe sự kiện từ Global Drag Select (Trạm gác UITable)
        tbody.addEventListener('rowSelectionToggled', function (e) {
          var rData = gridData[e.detail.rowIndex];
          if (!rData) return;
          if (e.detail.action === 'add') {
            if (!selectedRows.find(function (sr) { return sr.id === rData.id; })) selectedRows.push(rData);
          } else {
            selectedRows = selectedRows.filter(function (sr) { return sr.id !== rData.id; });
          }
          _updateSelectionCounter();
        });

        tbody.addEventListener('click', function (e) {
          if (typeof tbody.isDragSelecting === 'function' && tbody.isDragSelecting()) return;
          var tr = e.target.closest('tr');
          if (!tr || tr.children.length === 1) return;
          var idx = Array.from(tbody.children).indexOf(tr);
          var allTrsList = Array.from(tbody.querySelectorAll('tr'));
          var rData = gridData[idx];

          if (e.shiftKey && lastSelectedIdx !== -1) {
            // Shift + Click: Chọn một dải
            document.getSelection().removeAllRanges(); // Tránh bôi đen text
            var start = Math.min(idx, lastSelectedIdx);
            var end = Math.max(idx, lastSelectedIdx);
            for (var i = start; i <= end; i++) {
              allTrsList[i].classList.add('active');
              if (!selectedRows.find(function (sr) { return sr.id === gridData[i].id; })) {
                selectedRows.push(gridData[i]);
              }
            }
          } else if (e.ctrlKey || e.metaKey) {
            // Ctrl + Click: Chọn thêm hoặc Bỏ chọn
            tr.classList.toggle('active');
            if (tr.classList.contains('active')) {
              if (!selectedRows.find(function (sr) { return sr.id === rData.id; })) selectedRows.push(rData);
            } else {
              selectedRows = selectedRows.filter(function (sr) { return sr.id !== rData.id; });
            }
            lastSelectedIdx = idx;
          } else {
            // Click bình thường: Xoá hết, chỉ chọn 1
            allTrsList.forEach(function (r) { r.classList.remove('active'); });
            tr.classList.add('active');
            selectedRows = [rData];
            lastSelectedIdx = idx;
          }
          _updateSelectionCounter();
        });
        tbody.addEventListener('dblclick', function (e) {
          var tr = e.target.closest('tr');
          if (!tr || selectedRows.length === 0) return;
          if (selectedRows.length > 1) {
            _openBulkEditForm();
          } else {
            _openEditForm(selectedRows[0]);
          }
        });
      }

      _updateSelectionCounter();
    }
  }

  function _updateSelectionCounter() {
    _saveSelectedRows();

    var btnContainer = $container.querySelector('#dynamic-btn-container');
    if (!btnContainer) return;

    var actualToolbar = btnContainer.firstElementChild; // .button-bar
    if (!actualToolbar) return;

    var counter = actualToolbar.querySelector('#selection-counter');
    if (!counter) {
      // Bọc các nút bấm hiện tại vào một vùng cuộn riêng để bảo toàn background trắng của toolbar gốc
      if (!actualToolbar.querySelector('.btn-scroll-wrapper')) {
        var wrapper = document.createElement('div');
        wrapper.className = 'btn-scroll-wrapper';
        while (actualToolbar.firstChild) {
          wrapper.appendChild(actualToolbar.firstChild);
        }
        actualToolbar.appendChild(wrapper);
      }

      if (!document.getElementById('selection-counter-style')) {
        var style = document.createElement('style');
        style.id = 'selection-counter-style';
        style.innerHTML = `
          /* Toolbar gốc: Cho phép rớt dòng để chứa counter ở dưới trên mobile */
          #dynamic-btn-container .button-bar {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 10px;
          }
          /* Wrapper chứa nút bấm: Cuộn ngang, không rớt dòng */
          .btn-scroll-wrapper {
            display: flex;
            flex-wrap: nowrap;
            overflow-x: auto;
            flex: 1 1 auto;
            min-width: 0;
            gap: 8px;
            -ms-overflow-style: none;
            scrollbar-width: none;
            padding-bottom: 2px;
          }
          .btn-scroll-wrapper::-webkit-scrollbar {
            display: none;
          }
          /* Badge Đã chọn */
          #selection-counter {
            margin-left: auto;
            font-size: 13px;
            font-weight: 500;
            color: var(--color-primary);
            background: var(--color-primary-light);
            padding: 4px 8px 4px 12px;
            border-radius: 20px;
            white-space: nowrap;
            flex-shrink: 0;
            display: none;
            align-items: center;
            gap: 4px;
          }
          @media (max-width: 768px) {
            .btn-scroll-wrapper {
              flex: 1 1 100%;
              width: 100%;
            }
            #selection-counter {
              margin-left: 0;
              margin-top: 4px;
              width: 100%;
              flex: 1 1 100%;
              justify-content: center;
            }
          }
        `;
        document.head.appendChild(style);
      }
      counter = document.createElement('div');
      counter.id = 'selection-counter';
      actualToolbar.appendChild(counter);
    }

    if (selectedRows.length > 0) {
      counter.style.display = 'inline-flex';
      counter.innerHTML = `
        <span>Đã chọn ${selectedRows.length} dòng</span>
        <span class="material-symbols-outlined btn-clear-selection" title="Bỏ chọn" style="font-size: 16px; cursor: pointer; border-radius: 50%; padding: 2px;">close</span>
      `;
      var btnClear = counter.querySelector('.btn-clear-selection');
      if (btnClear) {
        btnClear.onmouseover = function () { this.style.backgroundColor = 'rgba(0,0,0,0.05)'; };
        btnClear.onmouseout = function () { this.style.backgroundColor = 'transparent'; };
        btnClear.onclick = function () {
          selectedRows = [];
          _updateSelectionCounter();
          // Bỏ check tất cả checkbox trên giao diện
          var checkboxes = $container.querySelectorAll('tbody .form-check-input');
          if (checkboxes) checkboxes.forEach(function (cb) { cb.checked = false; });
          var checkAll = $container.querySelector('thead .form-check-input');
          if (checkAll) checkAll.checked = false;
          // Bỏ bôi đen (highlight) tất cả các dòng
          var allTrs = $container.querySelectorAll('tbody tr');
          if (allTrs) allTrs.forEach(function (tr) { tr.classList.remove('active', 'selected', 'table-active', 'table-primary'); });
        };
      }
    } else {
      counter.style.display = 'none';
      counter.innerHTML = '';
    }
  }

  // ── Modal Form ────────────────────────────────────────────
  function _openBulkAddForm() {
    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    // Form đích
    var targetFormInput = UIInput.createText({
      label: 'Nhập cho Tên Form nào? (*)',
      required: true,
      placeholder: 'Ví dụ: frmCustomer'
    });
    body.appendChild(targetFormInput);

    // Vùng cuộn chứa Table
    var tableWrap = document.createElement('div');
    tableWrap.style.overflowX = 'auto';
    tableWrap.style.border = '1px solid var(--color-border)';
    tableWrap.style.borderRadius = '8px';

    var table = document.createElement('table');
    table.className = 'table table-hover mb-0';
    table.style.minWidth = '800px';

    var thead = document.createElement('thead');
    thead.innerHTML = `
      <tr>
        <th style="width:150px;">Tên Cột (Database) *</th>
        <th style="width:180px;">Tiêu đề (Tiếng Việt)</th>
        <th style="width:130px;">Loại Input</th>
        <th style="width:80px; text-align:center;">Bắt buộc</th>
        <th style="width:180px;">Nguồn dữ liệu (API/STATIC)</th>
        <th style="width:80px;">Vị trí</th>
        <th style="width:70px; text-align:center;">Thêm</th>
        <th style="width:70px; text-align:center;">Sửa</th>
        <th style="width:40px;"></th>
      </tr>
    `;
    table.appendChild(thead);

    var tbody = document.createElement('tbody');
    table.appendChild(tbody);
    tableWrap.appendChild(table);
    body.appendChild(tableWrap);

    // Nút thêm dòng
    var btnAddRow = document.createElement('button');
    btnAddRow.className = 'btn btn-outline-primary d-flex align-items-center mt-2';
    btnAddRow.style.width = 'fit-content';
    btnAddRow.innerHTML = '<span class="material-symbols-outlined me-1" style="font-size:18px;">add</span> Thêm dòng mới';

    // Logic đẻ ra dòng mới
    function addRow() {
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="p-1"><input type="text" class="ui-input" name="FieldName" placeholder="Ví dụ: CustomerID"></td>
        <td class="p-1"><input type="text" class="ui-input" name="CaptionVN" placeholder="Tiêu đề hiển thị"></td>
        <td class="p-1">
          <select class="ui-input" name="FormatID">
            <option value="">Chữ (Text)</option>
            <option value="nm">Số (Number)</option>
            <option value="dt">Ngày tháng (Date)</option>
            <option value="sw">Công tắc (Switch)</option>
            <option value="sl">Dropdown (Select)</option>
          </select>
        </td>
        <td class="p-1 text-center align-middle">
          <div class="d-flex justify-content-center h-100 align-items-center">
            <input type="checkbox" class="modern-checkbox" name="IsRequired" value="1" style="cursor: pointer; margin-top: 0;">
          </div>
        </td>
        <td class="p-1"><input type="text" class="ui-input" name="DataSource" placeholder="/api/... hoặc STATIC:..."></td>
        <td class="p-1"><input type="text" class="ui-input" name="FormPosition" placeholder="grid/6/4/12..."></td>
        <td class="p-1 text-center align-middle">
          <div class="d-flex justify-content-center h-100 align-items-center">
            <input type="checkbox" class="modern-checkbox" name="ShowInAdd" value="1" checked style="cursor: pointer; margin-top: 0;" title="Hiển thị khi Thêm Mới">
          </div>
        </td>
        <td class="p-1 text-center align-middle">
          <div class="d-flex justify-content-center h-100 align-items-center">
            <input type="checkbox" class="modern-checkbox" name="ShowInEdit" value="1" checked style="cursor: pointer; margin-top: 0;" title="Hiển thị khi Chỉnh Sửa">
          </div>
        </td>
        <td class="p-1 text-center align-middle">
          <button class="btn btn-sm btn-tool text-danger p-1 mt-1" onclick="this.closest('tr').remove()" title="Xóa dòng">
            <span class="material-symbols-outlined" style="font-size:18px;">delete</span>
          </button>
        </td>
      `;
      tbody.appendChild(tr);
    }

    // Mặc định tạo sẵn 3 dòng
    addRow(); addRow(); addRow();

    btnAddRow.onclick = addRow;
    body.appendChild(btnAddRow);

    var footerNode = document.createElement('div');
    footerNode.style.cssText = 'display: flex; gap: 12px;';
    footerNode.innerHTML =
      UIButton.createHTML({ text: 'Hủy bỏ', className: 'btn-close-bulk', type: 'secondary' }) +
      UIButton.createHTML({ text: 'Lưu toàn bộ', className: 'btn-submit-bulk', type: 'primary', icon: 'save' });

    var modalBulk = UIModal.show({
      title: 'Thêm Nhiều Trường (Lưới nhập liệu động)',
      content: body,
      width: '1200px', // Cho modal rộng ra để chứa bảng nhiều cột hơn
      footer: footerNode
    });

    footerNode.querySelector('.btn-close-bulk').onclick = function () {
      modalBulk.closeNow();
    };

    footerNode.querySelector('.btn-submit-bulk').onclick = function () {
      var targetForm = targetFormInput.querySelector('input').value.trim();
      if (!targetForm) return Alert.warning('Cảnh báo', 'Vui lòng nhập Tên Form đích!');

      var rows = tbody.querySelectorAll('tr');
      var payloads = [];

      rows.forEach(function (tr) {
        var fieldName = tr.querySelector('[name="FieldName"]').value.trim();
        var captionVN = tr.querySelector('[name="CaptionVN"]').value.trim() || fieldName;
        var formatID = tr.querySelector('[name="FormatID"]').value;
        var isRequired = tr.querySelector('[name="IsRequired"]').checked ? 1 : 0;
        var dataSource = tr.querySelector('[name="DataSource"]').value.trim();
        var formPosition = tr.querySelector('[name="FormPosition"]').value.trim();
        var showInAdd = tr.querySelector('[name="ShowInAdd"]').checked ? 1 : 0;
        var showInEdit = tr.querySelector('[name="ShowInEdit"]').checked ? 1 : 0;

        if (fieldName) {
          payloads.push({
            AutoID: '',
            FormName: targetForm,
            FieldName: fieldName,
            CaptionVN: captionVN,
            FormatID: formatID,
            IsRequired: isRequired,
            DataSource: dataSource,
            ShowInAdd: showInAdd,
            ShowInEdit: showInEdit,
            FormPosition: formPosition,
            OrderNo: 0
          });
        }
      });

      if (payloads.length === 0) return Alert.warning('Lỗi', 'Chưa có dòng dữ liệu nào hợp lệ!');

      _setBtnLoading(btn, true);

      // Gọi API tuần tự
      _sendSequential(
        MODULE_CONFIG.ApiSave,
        payloads,
        function () {                // onDone
          modalBulk.closeNow();
          Alert.success('Thành công', 'Đã lưu thành công ' + payloads.length + ' trường!');
          if (_isFormBuilder()) window._uiConfigCache = {};
          _loadData();
        },
        function (err, payload) {   // onError → return false để dừng chuỗi
          Alert.error('Lỗi ở dòng: ' + payload.FieldName, err.message);
          _setBtnLoading(btn, false);
          return false;
        }
      );
    };
  }

  function _openAddForm() {
    _openModal(false, null);
  }

  // ── Visual Layout Builder ────────────────────────────────────────────
  function _promptLayoutBuilder() {
    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    var targetFormInput = UIInput.createText({
      label: 'Nhập Tên Form cần thiết kế layout (*)',
      required: true,
      placeholder: 'Ví dụ: frmCustomer'
    });
    body.appendChild(targetFormInput);

    var footerNode = document.createElement('div');
    footerNode.style.cssText = 'display: flex; gap: 12px;';
    footerNode.innerHTML =
      UIButton.createHTML({ text: 'Hủy', className: 'btn-close-prompt', type: 'secondary' }) +
      UIButton.createHTML({ text: 'Mở thiết kế', className: 'btn-submit-prompt', type: 'primary' });

    var modalPrompt = UIModal.show({
      title: 'Thiết kế Layout trực quan',
      content: body,
      footer: footerNode
    });

    footerNode.querySelector('.btn-close-prompt').onclick = function () {
      modalPrompt.closeNow();
    };

    footerNode.querySelector('.btn-submit-prompt').onclick = function () {
      var formName = targetFormInput.querySelector('input').value.trim();
      if (!formName) return Alert.warning('Cảnh báo', 'Vui lòng nhập Tên Form');
      modalPrompt.closeNow();
      _openVisualLayoutBuilder(formName);
    };

    // Bắt sự kiện phím Enter
    var inputEl = targetFormInput.querySelector('input');
    if (inputEl) {
      setTimeout(function () { inputEl.focus(); }, 100); // Tự động focus vào ô nhập
      inputEl.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          var formName = inputEl.value.trim();
          if (!formName) return Alert.warning('Cảnh báo', 'Vui lòng nhập Tên Form');
          modalPrompt.closeNow();
          _openVisualLayoutBuilder(formName);
        }
      });
    }
  }

  function _openVisualLayoutBuilder(targetFormName) {
    var loadingModal = UIModal.show({ title: 'Đang tải layout...', content: '<div class="text-center p-4">Đang tải cấu hình form...</div>', buttons: [] });

    // Truyền cả FormName và Keyword để đảm bảo Backend SQL nào cũng nhận diện được và lọc đúng form
    ApiClient.post(MODULE_CONFIG.ApiSearch, { FormName: targetFormName, Keyword: targetFormName, Limit: 1000 })
      .then(function (res) {
        loadingModal.closeNow();
        var fields = res.list || res.records || [];
        if (fields.length === 0) {
          return Alert.warning('Cảnh báo', 'Không tìm thấy trường nào cho form ' + targetFormName);
        }

        // Sắp xếp mảng theo OrderNo ASC
        fields.sort(function (a, b) { return (a.OrderNo || 0) - (b.OrderNo || 0); });

        var body = document.createElement('div');
        body.style.display = 'flex';
        body.style.flexDirection = 'column';
        body.style.gap = '12px';

        var help = document.createElement('div');
        help.className = 'alert alert-info py-2 mb-0 d-flex align-items-center gap-2';
        help.innerHTML = '<span class="material-symbols-outlined">info</span> Kéo thả các khối để sắp xếp thứ tự. Bấm các nút phần trăm để chỉnh độ rộng. Layout hiển thị đúng tỷ lệ khung màn hình.';
        body.appendChild(help);

        var dropZone = document.createElement('div');
        dropZone.style.display = 'flex';
        dropZone.style.flexWrap = 'wrap';
        dropZone.style.gap = '10px 10px';
        dropZone.style.padding = '15px';
        dropZone.style.border = '2px dashed var(--color-border)';
        dropZone.style.borderRadius = '8px';
        dropZone.style.background = 'var(--color-background)';
        dropZone.style.minHeight = '300px';
        dropZone.style.position = 'relative';

        var draggedEl = null;

        fields.forEach(function (f) {
          var card = document.createElement('div');
          // Giải mã giá trị cũ (grid -> 6, body -> 12) để hiển thị trong Builder
          var span = f.FormPosition || 'body';
          if (span === 'grid') span = '6';
          if (span === 'body') span = '12';
          if (!['12', '6', '4', '3'].includes(span)) span = '12';

          card.className = 'layout-card';
          card.draggable = true;
          card.dataset.id = f.FieldName;
          card.dataset.span = span;
          card.dataset.orig = JSON.stringify(f);

          card.style.border = '1px solid var(--color-border)';
          card.style.borderRadius = '6px';
          card.style.background = 'var(--color-surface)';
          card.style.padding = '12px';
          card.style.boxShadow = '0 1px 3px rgba(0,0,0,0.05)';
          card.style.cursor = 'grab';
          card.style.display = 'flex';
          card.style.flexDirection = 'column';
          card.style.gap = '10px';
          card.style.transition = 'width 0.2s ease, opacity 0.2s ease, transform 0.1s ease';

          card.innerHTML = `
             <div style="font-weight:600; font-size:14px; color:var(--color-primary); pointer-events:none; display:flex; align-items:center; gap:6px;">
               <span class="material-symbols-outlined" style="font-size:18px; color:#888;">drag_indicator</span> 
               <span class="text-truncate">${f.CaptionVN || f.FieldName}</span>
               <small style="color:#aaa; font-weight:400;">(${f.FieldName})</small>
             </div>
             <div class="d-flex gap-1 mt-auto">
               <button type="button" class="btn btn-sm btn-outline-secondary btn-span py-0 px-2" style="font-size:11px;" data-val="3">25%</button>
               <button type="button" class="btn btn-sm btn-outline-secondary btn-span py-0 px-2" style="font-size:11px;" data-val="4">33%</button>
               <button type="button" class="btn btn-sm btn-outline-secondary btn-span py-0 px-2" style="font-size:11px;" data-val="6">50%</button>
               <button type="button" class="btn btn-sm btn-outline-secondary btn-span py-0 px-2" style="font-size:11px;" data-val="12">100%</button>
             </div>
           `;

          // Logic Gắn Kích Thước
          function applyWidth(sp) {
            card.dataset.span = sp;
            card.className = card.className.replace(/df-col-\d+/g, '').trim() + ' df-col-' + sp;

            // Update Highlights
            var btns = card.querySelectorAll('.btn-span');
            var label = sp === '12' ? '100%' : sp === '6' ? '50%' : sp === '4' ? '33%' : '25%';
            btns.forEach(function (b) {
              if (b.innerText.includes(label)) {
                b.classList.remove('btn-outline-secondary');
                b.classList.add('btn-primary');
                b.style.color = '#fff';
              } else {
                b.classList.remove('btn-primary');
                b.classList.add('btn-outline-secondary');
                b.style.color = '';
              }
            });
          }

          applyWidth(span);

          // Sự kiện Căn chỉnh
          card.querySelectorAll('.btn-span').forEach(function (b) {
            b.onclick = function () { applyWidth(b.dataset.val); };
          });

          // Drag events
          card.addEventListener('dragstart', function (e) {
            draggedEl = card;
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/html', card.innerHTML);
            setTimeout(function () { card.style.opacity = '0.4'; card.style.transform = 'scale(0.98)'; }, 0);
          });
          card.addEventListener('dragend', function (e) {
            draggedEl = null;
            card.style.opacity = '1';
            card.style.transform = 'scale(1)';
            dropZone.querySelectorAll('.layout-card').forEach(function (c) { c.style.border = '1px solid var(--color-border)'; });
          });
          card.addEventListener('dragover', function (e) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'move';
            if (draggedEl && draggedEl !== card) {
              var rect = card.getBoundingClientRect();
              var midY = rect.top + rect.height / 2;
              var midX = rect.left + rect.width / 2;
              // Tính toán chèn trước hay chèn sau
              var isAfter = e.clientY > midY || (Math.abs(e.clientY - midY) < 30 && e.clientX > midX);
              if (isAfter) dropZone.insertBefore(draggedEl, card.nextSibling);
              else dropZone.insertBefore(draggedEl, card);
            }
          });

          dropZone.appendChild(card);
        });

        body.appendChild(dropZone);

        var footerNode = document.createElement('div');
        footerNode.style.cssText = 'display: flex; gap: 12px;';
        footerNode.innerHTML =
          UIButton.createHTML({ text: 'Đóng', className: 'btn-close-layout', type: 'secondary' }) +
          UIButton.createHTML({ text: 'Lưu Layout', className: 'btn-save-layout', type: 'primary', icon: 'save' });

        var modalLayout = UIModal.show({
          title: 'Thiết kế Layout: ' + targetFormName,
          content: body,
          width: '900px',
          footer: footerNode
        });

        footerNode.querySelector('.btn-close-layout').onclick = function () {
          modalLayout.closeNow();
        };

        footerNode.querySelector('.btn-save-layout').onclick = function () {
          var cards = dropZone.querySelectorAll('.layout-card');
          var payloads = [];

          cards.forEach(function (c, index) {
            var orig = JSON.parse(c.dataset.orig);
            orig.OrderNo = index + 1; // Đánh số thứ tự từ 1
            orig.orderNo = index + 1; // Truyền thêm định dạng camelCase

            // Map 12 -> 'body' và 6 -> 'grid' để lách validation của C# Backend
            var savedSpan = c.dataset.span;
            if (savedSpan === '12') savedSpan = 'body';
            if (savedSpan === '6') savedSpan = 'grid';

            orig.FormPosition = savedSpan;
            orig.formPosition = savedSpan;
            orig.position = savedSpan;
            payloads.push(orig);
          });

          if (payloads.length === 0) return;

          var btn = this;
          var origTxt = btn.innerHTML;
          btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span> Đang lưu...';
          btn.disabled = true;

          // Lưu liên hoàn API
          var saveEndpoint = window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.SYSTEM ? window.API_CONFIG.ENDPOINTS.SYSTEM.SAVE_FIELD : null;
          if (!saveEndpoint) {
            Alert.error('Lỗi', 'Chưa cấu hình API_CONFIG.ENDPOINTS.SYSTEM.SAVE_FIELD');
            return;
          }

          // Gọi API tuần tự
          _sendSequential(
            saveEndpoint,
            payloads,
            function () {              // onDone
              modalLayout.closeNow();
              Alert.success('Thành công', 'Đã cập nhật xong cấu hình Layout!');
              _loadData();
            },
            function (err, payload) { // onError → không dừng, tiếp tục lưu các trường khác
              console.error('Lỗi khi lưu field', payload.FieldName, err);
            }
          );
        };

      })
      .catch(function (e) {
        if (loadingModal) loadingModal.closeNow();
        Alert.error('Lỗi', 'Không thể tải cấu hình form: ' + e.message);
      });
  }

  function _openEditForm(row) {
    _openModal(true, row);
  }

  function _openBulkEditForm() {
    _openBulkGridEditForm(selectedRows, false);
  }

  function _openBulkGridEditForm(rows, isAdd) {
    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    var alertBox = document.createElement('div');
    alertBox.className = 'alert alert-info py-2 mb-0 d-flex align-items-center gap-2';
    alertBox.style.fontSize = '13px';
    var isEdit = !isAdd;

    if (isAdd) {
      alertBox.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px">playlist_add</span>' +
        '<strong>Chế độ Thêm Hàng Loạt:</strong> Nhập dữ liệu để tạo mới nhiều dòng cùng lúc. Để trống dòng nếu không muốn thêm.';
    } else {
      alertBox.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px">grid_on</span>' +
        '<strong>Chế độ Sửa Từng Dòng:</strong> Chỉnh sửa dữ liệu trực tiếp trên bảng.';
    }
    body.appendChild(alertBox);

    var tableContainer = document.createElement('div');
    tableContainer.style.overflowX = 'auto';
    tableContainer.style.maxHeight = '65vh';

    var styleNode = document.createElement('style');
    styleNode.innerHTML = `
        .table-bulk-edit { margin-bottom: 0; border-collapse: separate; border-spacing: 0; }
        .table-bulk-edit thead th { position: sticky; top: 0; z-index: 2; background: var(--color-surface); border-bottom: 2px solid var(--color-border); }
        .table-bulk-edit tbody td { padding: 0 !important; vertical-align: middle; border-bottom: 1px solid var(--color-border); border-right: 1px solid var(--color-border); position: relative; }
        .table-bulk-edit tbody td:first-child { padding: 0 8px !important; }
        .table-bulk-edit tbody tr:hover td { background: rgba(255, 255, 255, 0.02); }
        .table-bulk-edit .form-group { margin-bottom: 0 !important; height: 100%; display: flex; align-items: center; width: 100%; }
        .table-bulk-edit input.ui-input, .table-bulk-edit .dropdown-wrapper, .table-bulk-edit .dropdown-wrapper input {
            border: none !important; border-radius: 0 !important; background: transparent !important; box-shadow: none !important;
            width: 100%; height: 100%; min-height: 40px; padding: 0 12px !important; outline: none !important;
        }
        .table-bulk-edit input.ui-input:focus { background: rgba(255,255,255,0.05) !important; }
        .table-bulk-edit .switch { justify-content: center; padding: 0; margin: 0; width: 100%; height: 100%; display: flex; align-items: center; min-height: 40px; }
        .table-bulk-edit .dropdown-wrapper .material-symbols-outlined { right: 8px; }
        
        /* Custom Scrollbar cho bảng */
        .table-bulk-edit-container::-webkit-scrollbar { width: 8px; height: 8px; }
        .table-bulk-edit-container::-webkit-scrollbar-track { background: transparent; }
        .table-bulk-edit-container::-webkit-scrollbar-thumb { background: rgba(0, 0, 0, 0.2); border-radius: 4px; }
        .table-bulk-edit-container::-webkit-scrollbar-thumb:hover { background: rgba(0, 0, 0, 0.3); }
        body.dark-theme .table-bulk-edit-container::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.2); }
        body.dark-theme .table-bulk-edit-container::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.3); }
        .table-bulk-edit-container::-webkit-scrollbar-corner { background: transparent; }
    `;
    tableContainer.appendChild(styleNode);
    tableContainer.classList.add('table-bulk-edit-container');

    var table = document.createElement('table');
    table.className = 'table table-bordered table-hover table-bulk-edit';
    table.style.width = 'max-content';
    table.style.minWidth = '100%';

    var formSchema = globalFormSchema;
    formSchema.sort(function (a, b) { return (a.orderNo || 0) - (b.orderNo || 0); });

    var editableFields = [];
    var thead = document.createElement('thead');
    thead.style.position = 'sticky';
    thead.style.top = '0';
    thead.style.zIndex = '1';
    thead.style.background = 'var(--color-surface)';
    var trHead = document.createElement('tr');

    var thStt = document.createElement('th');
    thStt.innerText = '#';
    thStt.style.width = '50px';
    thStt.style.textAlign = 'center';
    trHead.appendChild(thStt);

    formSchema.forEach(function (field) {
      if (String(field.showInEdit) === '1' || field.showInEdit === true) {
        editableFields.push(field);
        var th = document.createElement('th');
        th.innerText = field.label || field.name;
        if (field.required) {
          var req = document.createElement('span');
          req.innerText = ' *';
          req.style.color = 'var(--color-danger)';
          th.appendChild(req);
        }
        th.style.whiteSpace = 'nowrap';
        th.style.padding = '10px';
        trHead.appendChild(th);
      }
    });
    thead.appendChild(trHead);
    table.appendChild(thead);

    var tbody = document.createElement('tbody');
    var currentRowCount = rows.length;

    function appendRow(row, rowIdx) {
      var tr = document.createElement('tr');

      var tdStt = document.createElement('td');
      tdStt.innerText = rowIdx + 1;
      tdStt.style.textAlign = 'center';
      tdStt.style.verticalAlign = 'middle';
      tr.appendChild(tdStt);

      // Hidden PK
      var hiddenPK = document.createElement('input');
      hiddenPK.type = 'hidden';
      hiddenPK.name = MODULE_CONFIG.PrimaryKey + '_' + rowIdx;
      hiddenPK.value = row[MODULE_CONFIG.PrimaryKey] || '';
      hiddenPK.setAttribute('data-row-index', rowIdx);
      hiddenPK.setAttribute('data-field-name', MODULE_CONFIG.PrimaryKey);
      tr.appendChild(hiddenPK);

      // Hidden OrderNo
      var hiddenOrder = document.createElement('input');
      hiddenOrder.type = 'hidden';
      hiddenOrder.name = 'OrderNo_' + rowIdx;
      hiddenOrder.value = row.OrderNo || 0;
      hiddenOrder.setAttribute('data-row-index', rowIdx);
      hiddenOrder.setAttribute('data-field-name', 'OrderNo');
      tr.appendChild(hiddenOrder);

      editableFields.forEach(function (fieldTemplate) {
        var td = document.createElement('td');
        td.style.verticalAlign = 'middle';
        td.style.minWidth = '200px';
        td.style.padding = '0'; // Đã CSS trong class

        var field = Object.assign({}, fieldTemplate);
        field.value = row[field.name] !== undefined && row[field.name] !== null ? row[field.name] : '';
        var originalName = field.name;
        field.name = originalName + '_' + rowIdx;

        var inputEl;
        if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
          inputEl = UIInput.createSwitch(field);
        } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
          inputEl = UIInput.createDate(field);
        } else if (field.renderRule === 'sl' || field.renderRule === 'select') {
          inputEl = document.createElement('div');
          inputEl.className = 'form-group';
          inputEl.style.marginBottom = '0';

          var hiddenInput = document.createElement('input');
          hiddenInput.type = 'hidden';
          hiddenInput.name = field.name;
          hiddenInput.value = field.value || '';
          hiddenInput.setAttribute('data-row-index', rowIdx);
          hiddenInput.setAttribute('data-field-name', originalName);
          inputEl.appendChild(hiddenInput);

          var comboLoading = UIControls.createDataComboBox({ placeholder: 'Đang tải...', disabled: ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd)) });
          inputEl.appendChild(comboLoading);

          if (field.dataSource) {
            if (String(field.dataSource).toUpperCase().startsWith('STATIC:')) {
              var staticStr = field.dataSource.substring(7);
              var staticData = staticStr.split(',').map(function (s) {
                var parts = s.split('|');
                return [parts[0], parts[1] || parts[0]];
              });
              var newCombo = UIControls.createDataComboBox({
                placeholder: '-- Chọn --',
                headers: ['ID', 'Tên'],
                data: staticData,
                colFilterIndex: 1,
                onSelect: function (r) { hiddenInput.value = r[0]; }
              });
              var newDisplayInput = newCombo.querySelector('input.ui-input');
              var matched = staticData.find(function (r) { return r[0] == field.value; });
              if (matched && newDisplayInput) newDisplayInput.value = matched[1];
              inputEl.replaceChild(newCombo, comboLoading);
            } else {
              ApiClient.post(MODULE_CONFIG.ApiSearch, { FormName: field.dataSource, Limit: 1000 }).then(function (res) {
                var comboData = [];
                var headers = ['Mã', 'Tên'];
                var colFilterIndex = 1;
                var dataList = res.list || res.records || [];
                if (dataList && dataList.length > 0) {
                  var keys = Object.keys(dataList[0]);
                  if (keys.length > 0) {
                    headers = keys;
                    var labelRegex = /name|tên|ten|label|desc|title/i;
                    var displayKey = keys.find(function (k) { return labelRegex.test(k); });
                    colFilterIndex = displayKey ? keys.indexOf(displayKey) : (keys.length > 1 ? 1 : 0);
                    dataList.forEach(function (d) {
                      var rd = [];
                      keys.forEach(function (k) { rd.push(d[k] !== null && d[k] !== undefined ? d[k] : ''); });
                      comboData.push(rd);
                    });
                  }
                }
                var newCombo = UIControls.createDataComboBox({
                  placeholder: '-- Chọn --', headers: headers, data: comboData, colFilterIndex: colFilterIndex,
                  onSelect: function (r) { hiddenInput.value = r[0]; }
                });
                var newDisplayInput = newCombo.querySelector('input.ui-input');
                var matched = comboData.find(function (r) { return r[0] == field.value; });
                if (matched && newDisplayInput) newDisplayInput.value = matched[colFilterIndex];
                inputEl.replaceChild(newCombo, comboLoading);
              }).catch(function (err) {
                var displayInput = comboLoading.querySelector('input.ui-input');
                if (displayInput) displayInput.placeholder = 'Lỗi tải dữ liệu';
              });
            }
          } else {
            var comboEmpty = UIControls.createDataComboBox({ placeholder: 'Chưa có dữ liệu' });
            inputEl.replaceChild(comboEmpty, comboLoading);
          }
        } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
          inputEl = UIInput.createNumber(field);
        } else {
          inputEl = UIInput.createText(field);
        }

        if (inputEl) {
          var lbl = inputEl.querySelector('label');
          if (lbl && !inputEl.classList.contains('switch')) {
            lbl.style.display = 'none';
          }
          if (inputEl.classList && inputEl.classList.contains('form-group')) {
            inputEl.style.marginBottom = '0';
          }
          var allInputs = inputEl.querySelectorAll('input, select, textarea');
          allInputs.forEach(function (i) {
            i.setAttribute('data-row-index', rowIdx);
            i.setAttribute('data-field-name', originalName);
            if (((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd))) i.disabled = true;
          });
          if (((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd))) inputEl.classList.add('ui-input-disabled');
          td.appendChild(inputEl);
        }
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    }

    rows.forEach(function (row, rowIdx) {
      appendRow(row, rowIdx);
    });

    table.appendChild(tbody);
    tableContainer.appendChild(table);
    body.appendChild(tableContainer);

    if (isAdd) {
      var btnAddMore = document.createElement('button');
      btnAddMore.className = 'btn btn-outline-primary btn-sm';
      btnAddMore.style.alignSelf = 'flex-start';
      btnAddMore.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px; vertical-align:bottom;">add</span> Thêm 1 dòng nữa';
      btnAddMore.onclick = function () {
        appendRow({}, currentRowCount);
        currentRowCount++;
        // scroll to bottom
        setTimeout(function () { tableContainer.scrollTop = tableContainer.scrollHeight; }, 50);
      };
      body.appendChild(btnAddMore);
    }

    var footer = document.createElement('div');
    footer.style.display = 'flex';
    footer.style.gap = '10px';

    var btnCancel = document.createElement('button');
    btnCancel.className = 'btn btn-outline';
    btnCancel.textContent = MODULE_CONFIG.BtnCancel;

    var btnSave = document.createElement('button');
    btnSave.className = 'btn btn-primary';
    btnSave.textContent = MODULE_CONFIG.BtnSaveAll;

    footer.appendChild(btnCancel);
    footer.appendChild(btnSave);

    var modal = UIModal.show({
      title: isAdd ? 'Thêm hàng loạt (' + rows.length + ' dòng)' : 'Sửa hàng loạt (' + rows.length + ' dòng)',
      width: '90%',
      content: body,
      footer: footer
    });

    btnCancel.onclick = function () { modal.close(); };
    btnSave.onclick = function () { _saveGridData(rows, modal, body, btnSave, isAdd); };
  }

  function _openModal(isEdit, row) {
    if (isEdit && !row) return;

    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    var currentModalFormState = {}; // Trạng thái form để truyền cho các Combobox gọi API

    var grid = document.createElement('div');
    grid.style.display = 'flex';
    grid.style.flexWrap = 'wrap';
    grid.style.gap = '12px 10px'; // Dòng cách dòng 12px, ô cách ô 10px
    body.appendChild(grid);

    // KHAI BÁO CẤU TRÚC FORM (SCHEMA-DRIVEN UI LẤY TỪ DB)
    var formSchema = globalFormSchema;

    // Sắp xếp lại theo OrderNo (Nếu có)
    formSchema.sort(function (a, b) { return (a.orderNo || 0) - (b.orderNo || 0); });

    // ENGINE VẼ FORM TỰ ĐỘNG
    formSchema.forEach(function (field) {
      var isVisible = isEdit ? field.showInEdit : field.showInAdd;
      if (!(String(isVisible) === '1' || isVisible === true)) {
        // Vẽ input ẩn cho các Khóa chính (Ví dụ Makh) để Auto-Serializer thu thập được
        var hiddenEl = document.createElement('input');
        hiddenEl.type = 'hidden';
        hiddenEl.name = field.name;
        hiddenEl.value = row ? (row[field.name] || '') : '';
        body.appendChild(hiddenEl);
        return;
      }

      // Tự động gán giá trị cũ (nếu đang Sửa 1 dòng).
      field.value = (isEdit && row) ? (row[field.name] || '') : '';

      // Khởi tạo Ô nhập liệu tuỳ thuộc vào quy tắc renderRule
      var inputEl;
      if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
        inputEl = UIInput.createSwitch(field);
      } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
        inputEl = UIInput.createDate(field);
      } else if (field.renderRule === 'sl' || field.renderRule === 'select') {
        var formGroupWrapper = document.createElement('div');
        formGroupWrapper.className = 'form-group';

        if (field.label) {
          var lbl = document.createElement('label');
          lbl.innerText = field.label;
          if (field.required) {
            var req = document.createElement('span');
            req.innerText = ' *';
            req.style.color = 'var(--color-danger)';
            lbl.appendChild(req);
          }
          formGroupWrapper.appendChild(lbl);
        }

        // Hidden input lưu giá trị thực (ID) để hàm Auto Serialize nhặt được
        var hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = field.name;
        hiddenInput.value = field.value || '';
        formGroupWrapper.appendChild(hiddenInput);

        if (field.dataSource) {
          if (String(field.dataSource).toUpperCase().startsWith('STATIC:')) {
            var staticStr = field.dataSource.substring(7);
            var staticData = staticStr.split(',').map(function (s) {
              var parts = s.split('|');
              return [parts[0], parts[1] || parts[0]];
            });

            var combo = UIControls.createDataComboBox({
              placeholder: '-- Vui lòng chọn --',
              headers: ['Mã', 'Tên'],
              data: staticData,
              colFilterIndex: 1, // Dùng cột Tên để hiển thị lên input
              disabled: ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd)),
              onSelect: function (row) {
                hiddenInput.value = row[0]; // Cập nhật ID
                hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
              }
            });

            var displayInput = combo.querySelector('input.ui-input');
            var matched = staticData.find(function (r) { return r[0] == field.value; });
            if (matched && displayInput) displayInput.value = matched[1];

            formGroupWrapper.appendChild(combo);
            inputEl = formGroupWrapper;
          } else {
            // Hiển thị tạm lúc đang tải
            var comboLoading = UIControls.createDataComboBox({
              placeholder: 'Đang tải...',
              headers: ['Mã', 'Tên'],
              data: [],
              colFilterIndex: 1
            });
            formGroupWrapper.appendChild(comboLoading);
            inputEl = formGroupWrapper;

            var endpoint = field.dataSource.startsWith('http') ? field.dataSource : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + field.dataSource);
            var finalUrl = endpoint;
            var fetchPayload = {};
            if (endpoint.indexOf('?') > -1) {
              var parts = endpoint.split('?');
              finalUrl = parts[0];
              var searchParams = new URLSearchParams(parts[1]);
              searchParams.forEach(function (value, key) { fetchPayload[key] = value; });
            }
            if (!fetchPayload.UserName) fetchPayload.UserName = _currentUser();

            var searchApiCall = function (q, page) {
              var payload = Object.assign({}, fetchPayload);
              if (typeof currentModalFormState !== 'undefined') {
                payload = Object.assign(payload, currentModalFormState);
              }
              if (q) payload.Keyword = q;
              return ApiClient.post(finalUrl, payload).then(function (res) {
                var comboData = [];
                var dataList = res.list || res.records;
                var headers = ['Mã', 'Tên'];
                var colFilterIndex = 1;
                if (dataList && dataList.length > 0) {
                  var keys = Object.keys(dataList[0]);
                  comboLoading.dataset.lastKeys = JSON.stringify(keys); // Lưu lại keys để dùng cho auto-fill
                  if (keys.length > 0) {
                    // Dùng từ điển hiện tại của form để dịch tiêu đề lưới (nếu có), CHỈ HIỆN MAX 3 CỘT ĐẦU cho đỡ chật
                    var displayKeys = keys.slice(0, 3);
                    headers = displayKeys.map(function(k) { 
                       return (typeof currentDictionary !== 'undefined' && currentDictionary[k]) ? currentDictionary[k].CaptionVN : k; 
                    });
                    var labelRegex = /name|tên|ten|label|desc|title/i;
                    var displayKey = displayKeys.find(function (k) { return labelRegex.test(k); });
                    colFilterIndex = displayKey ? displayKeys.indexOf(displayKey) : (displayKeys.length > 1 ? 1 : 0);
                    dataList.forEach(function (d) {
                      var rowData = [];
                      keys.forEach(function (k) { rowData.push(d[k] !== null && d[k] !== undefined ? d[k] : ''); });
                      comboData.push(rowData);
                    });
                  } else {
                    dataList.forEach(function (d) { comboData.push(['', '']); });
                  }
                }
                return { headers: headers, data: comboData, colFilterIndex: colFilterIndex };
              });
            };

            var lazyCombo = UIControls.createDataComboBox({
              placeholder: '-- Vui lòng chọn --',
              headers: ['Mã', 'Tên'],
              disabled: ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd)),
              onSearch: searchApiCall,
              onSelect: function (row) {
                hiddenInput.value = row[0];
                
                // === AUTO FILL LOGIC ===
                // Lấy lại danh sách keys đã lưu
                var savedKeysStr = comboLoading.dataset.lastKeys;
                if (savedKeysStr) {
                    var keys = JSON.parse(savedKeysStr);
                    // Duyệt qua các cột trả về từ API
                    keys.forEach(function(keyName, index) {
                        // Tìm xem trong Form hiện tại có Input nào tên trùng với tên Cột không (bỏ qua chính nó)
                        // Chuẩn hóa tên cột để dễ map (loại bỏ dấu cách, ký tự đặc biệt nếu cần, nhưng tốt nhất API nên trả về đúng ID)
                        // Tìm container bao ngoài form (do form động render vào div chứ không phải thẻ <form>)
                        var form = hiddenInput.closest('.ui-modal') || hiddenInput.closest('body');
                        if (form) {
                            var targetInput = form.querySelector('[name="' + keyName + '"]');
                            if (targetInput && targetInput !== hiddenInput) {
                                // Điền giá trị
                                targetInput.value = row[index] || '';
                                // Kích hoạt sự kiện để UI update (nếu là ô chọn ngày, số lượng...)
                                targetInput.dispatchEvent(new Event('change', { bubbles: true }));
                            }
                        }
                    });
                }
                // =======================

                hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
              }
            });

            if (field.value) {
              searchApiCall('', 1).then(function (res) {
                var displayInput = lazyCombo.querySelector('input.ui-input');
                var matched = res.data.find(function (r) { return r[0] == field.value; });
                if (matched && displayInput) displayInput.value = matched[res.colFilterIndex || 1];
              }).catch(function (err) {
                console.error('[DynamicFormEngine] DataComboBox initial fetch error:', err);
                var displayInput = lazyCombo.querySelector('input.ui-input');
                if (displayInput) displayInput.placeholder = 'Lỗi tải dữ liệu';
              });
            }

            formGroupWrapper.replaceChild(lazyCombo, comboLoading);
          }
        } else {
          var comboEmpty = UIControls.createDataComboBox({ placeholder: 'Chưa có dữ liệu' });
          formGroupWrapper.appendChild(comboEmpty);
          inputEl = formGroupWrapper;
        }
      } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
        inputEl = UIInput.createNumber(field);
      } else {
        inputEl = UIInput.createText(field);
      }

      // Áp dụng kích thước FlexBox từ field.position
      if (((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd))) {
        var innerFields = inputEl.querySelectorAll('input, select, textarea, button');
        if (innerFields.length > 0) {
          innerFields.forEach(function (el) { el.disabled = true; });
        } else if (['INPUT', 'SELECT', 'TEXTAREA', 'BUTTON'].includes(inputEl.tagName)) {
          inputEl.disabled = true;
        }
        inputEl.classList.add('ui-input-disabled');
      }
      var span = String(field.position || 'body');
      if (span === 'grid') span = '6';
      if (span === 'body') span = '12';
      if (!['12', '6', '4', '3'].includes(span)) span = '12';

      var wrapper = document.createElement('div');
      wrapper.className = 'df-col-' + span;
      // Gán VisibleRule lên wrapper để UIControls.utils.applyVisibleRules xử lý
      if (field.visibleRule) wrapper.dataset.visibleRule = field.visibleRule;

      wrapper.appendChild(inputEl);
      grid.appendChild(wrapper);

      // Gán giá trị mặc định vào currentModalFormState
      currentModalFormState[field.name] = field.value || '';
    });

    // Áp VisibleRule: show/hide fields theo cấu hình trong SY_FormatFields.VisibleRule
    if (typeof UIControls !== 'undefined' && UIControls.utils && UIControls.utils.applyVisibleRules) {
      UIControls.utils.applyVisibleRules(body);
    }

    // Lắng nghe sự kiện thay đổi để xử lý Phụ thuộc (Dependencies)
    body.addEventListener('change', function (e) {
      var changedName = e.target.name;
      if (changedName) {
        currentModalFormState[changedName] = e.target.value;
        // Tìm các trường phụ thuộc vào trường vừa đổi
        globalFormSchema.forEach(function (f) {
          if (f.dependsOn === changedName) {
            currentModalFormState[f.name] = ''; // Reset state
            var childInput = body.querySelector('input[name="' + f.name + '"]');
            if (childInput) {
              childInput.value = ''; // Xóa value ẩn
              // Xóa luôn giá trị hiển thị trên màn hình nếu là combobox
              var comboWrap = childInput.closest('.form-group');
              if (comboWrap) {
                var displayInp = comboWrap.querySelector('input.ui-input');
                if (displayInp) displayInp.value = '';
              }
            }
          }
        });
      }
    });

    // Footer buttons
    var footer = document.createElement('div');
    footer.style.display = 'flex';
    footer.style.gap = '10px';

    var btnCancel = document.createElement('button');
    btnCancel.className = 'btn btn-outline';
    btnCancel.textContent = MODULE_CONFIG.BtnCancel;

    var btnSave = document.createElement('button');
    btnSave.className = 'btn btn-primary';
    btnSave.textContent = isEdit ? MODULE_CONFIG.BtnSaveEdit : MODULE_CONFIG.BtnSaveAdd;

    footer.appendChild(btnCancel);
    footer.appendChild(btnSave);

    var modal = UIModal.show({
      title: isEdit ? MODULE_CONFIG.TitleEdit : MODULE_CONFIG.TitleAdd,
      width: MODULE_CONFIG.ModalWidth,
      content: body,
      footer: footer
    });

    btnCancel.onclick = function () { modal.close(); };
    btnSave.onclick = function () {
      _saveData(isEdit, row, modal, body, btnSave);
    };

    // Focus ô nhập liệu đầu tiên (không bị ẩn)
    setTimeout(function () {
      var first = body.querySelector('input:not([type="hidden"])');
      if (first) first.focus();
    }, 100);
  }

  function _saveGridData(rows, modal, body, btnSave, isAdd) {
    var endpoint = MODULE_CONFIG.ApiSave;
    if (!endpoint) {
      Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertApiMissing);
      return;
    }

    btnSave.disabled = true;
    btnSave.textContent = MODULE_CONFIG.BtnSaveSaving;

    var payloads = [];
    rows.forEach(function (targetRow, rowIdx) {
      var payload = _buildPayload(targetRow, !isAdd);

      var inputs = body.querySelectorAll('input[data-row-index="' + rowIdx + '"], select[data-row-index="' + rowIdx + '"], textarea[data-row-index="' + rowIdx + '"]');
      var hasData = false;
      inputs.forEach(function (el) {
        var fieldName = el.getAttribute('data-field-name');
        var val = el.value.trim();
        if (fieldName) {
          payload[fieldName] = val;
          if (val && fieldName !== MODULE_CONFIG.PrimaryKey && fieldName !== 'OrderNo') {
            hasData = true;
          }
        }
      });

      if (isAdd) {
        if (hasData) payloads.push(payload);
      } else {
        payloads.push(payload);
      }
    });

    if (payloads.length === 0) {
      Alert.warning(MODULE_CONFIG.AlertTitleInfo, 'Không có dữ liệu hợp lệ để lưu.');
      _setBtnLoading(btnSave, false);
      return;
    }

    // Gọi API tuần tự
    _sendSequential(
      endpoint,
      payloads,
      function (count) {             // onDone
        modal.closeNow();
        Alert.success('Thành công', 'Đã lưu xong ' + count + ' dòng!');
        if (!isAdd) selectedRows = [];
        if (_isFormBuilder()) window._uiConfigCache = {};
        _updateSelectionCounter();
        _loadData();
      },
      function (err) {               // onError → tiếp tục
        console.error('Grid Edit Error', err);
      }
    );
  }

  // ── Save ──────────────────────────────────────────────────
  function _saveData(isEdit, rowData, modal, body, btnSave) {
    var endpoint = MODULE_CONFIG.ApiSave;
    if (!endpoint) {
      Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertApiMissing);
      return;
    }

    // 1. Quét Form: Thu thập các giá trị người dùng vừa gõ vào
    var formInputData = {};
    var inputs = body.querySelectorAll('input, select, textarea');
    inputs.forEach(function (el) {
      if (el.name) {
        formInputData[el.name] = el.value.trim();
      }
    });

    // 2. Validate Required và ValidateRule
    var isInvalid = false;
    for (var i = 0; i < globalFormSchema.length; i++) {
      var field = globalFormSchema[i];
      var val = formInputData[field.name];
      if (field.required && !val) {
        Alert.warning(MODULE_CONFIG.WarnMissingInfo, MODULE_CONFIG.WarnMissingInput.replace('{0}', field.label));
        isInvalid = true;
        break;
      }
      if (val && field.validateRule) {
        var rule = field.validateRule.toLowerCase();
        if (rule.startsWith('min:')) {
          var min = parseInt(rule.split(':')[1]);
          if (val.length < min) { Alert.warning('Lỗi nhập liệu', field.label + ' phải có ít nhất ' + min + ' ký tự'); isInvalid = true; break; }
        } else if (rule.startsWith('max:')) {
          var max = parseInt(rule.split(':')[1]);
          if (val.length > max) { Alert.warning('Lỗi nhập liệu', field.label + ' không được vượt quá ' + max + ' ký tự'); isInvalid = true; break; }
        } else if (rule === 'email') {
          var emailRe = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
          if (!emailRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng Email'); isInvalid = true; break; }
        } else if (rule.startsWith('regex:')) {
          var reStr = field.validateRule.substring(6);
          try {
            var re = new RegExp(reStr);
            if (!re.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng yêu cầu'); isInvalid = true; break; }
          } catch (e) { console.error('Lỗi Regex:', e); }
        }
      }
    }
    if (isInvalid) return;

    // 3. Lưu — bật loading, tắt khi xong (dùng _setBtnLoading thóat khỏi duplicate)
    _setBtnLoading(btnSave, true);
    var _restoreSaveBtn = function () { _setBtnLoading(btnSave, false); };

    // 4. Xây dựng danh sách Payload
    var payloads = [];
    var singlePayload = _buildPayload(formInputData, isEdit);
    singlePayload.OrderNo = rowData && rowData.OrderNo ? rowData.OrderNo : 0;

    if (isEdit && rowData && MODULE_CONFIG.PrimaryKey && !singlePayload[MODULE_CONFIG.PrimaryKey]) {
      singlePayload[MODULE_CONFIG.PrimaryKey] = rowData[MODULE_CONFIG.PrimaryKey];
    }
    payloads.push(singlePayload);

    if (payloads.length === 0) { modal.closeNow(); return; }

    // 5. Gọi API Lưu
    ApiClient.post(endpoint, payloads[0])
      .then(function (res) {
        if (res && res.code === 0) {
          UIToast.show(isEdit ? MODULE_CONFIG.ToastEdit : MODULE_CONFIG.ToastAdd, 'success');
          modal.closeNow();
          if (_isFormBuilder()) window._uiConfigCache = {}; // Cache Invalidate
          selectedRows = [];
          _updateSelectionCounter();
          _loadData();
        } else {
          Alert.error(MODULE_CONFIG.AlertTitleError, res && res.msg ? res.msg : MODULE_CONFIG.AlertSaveFailed);
          _restoreSaveBtn();
        }
      })
      .catch(function () {
        Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertNetworkError);
        _restoreSaveBtn();
      });
  }

  return { render: render };
})();
