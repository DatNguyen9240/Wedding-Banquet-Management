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
  var totalPagesFromApi = 0;
  var lastTimestamp = '';

  // Lưu trữ state (page, sort, filter) theo từng FormName để giữ vết khi chuyển lại
  var moduleStates = {};
  var currentFormName = '';

  // Dữ liệu Từ điển lấy từ API (Database)
  var globalDictionary = {};
  var globalFormSchema = [];
  var globalRenderers = {};

  // Khôi phục moduleStates từ sessionStorage nếu có (để giữ filter khi F5)
  try {
    var cachedStates = sessionStorage.getItem('DynamicFormEngine_States');
    if (cachedStates) moduleStates = JSON.parse(cachedStates);
  } catch (e) { }

  function _saveModuleStates() {
    try {
      sessionStorage.setItem('DynamicFormEngine_States', JSON.stringify(moduleStates));
    } catch (e) { }
  }

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

  function _getValueFromRow(row, fieldName) {
    if (!row || !fieldName) return '';
    if (row[fieldName] !== undefined && row[fieldName] !== null) {
      return row[fieldName];
    }
    var targetKey = fieldName.toLowerCase();
    for (var key in row) {
      if (key.toLowerCase() === targetKey) {
        return row[key] !== undefined && row[key] !== null ? row[key] : '';
      }
    }
    return '';
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
          var isDbSuccess = true;
          var dbMsg = '';
          if (res && res.code === 0) {
            if (res.Success !== undefined && (String(res.Success) === '0' || res.Success === false)) {
              isDbSuccess = false;
              dbMsg = res.Message || res.msg || 'Lưu dữ liệu thất bại';
            } else if (res.records && res.records.length > 0) {
              var firstRec = res.records[0];
              if (firstRec.Success !== undefined && (String(firstRec.Success) === '0' || firstRec.Success === false)) {
                isDbSuccess = false;
                dbMsg = firstRec.Message || firstRec.msg || res.Message || 'Lưu dữ liệu thất bại';
              }
            }
          } else {
            isDbSuccess = false;
            dbMsg = res ? res.msg : 'Lỗi kết nối';
          }

          if (isDbSuccess) {
            successCount++;
            _next(i + 1);
          } else {
            var err = new Error(dbMsg);
            var stop = typeof onError === 'function' && onError(err, payloads[i], i) === false;
            if (!stop) _next(i + 1);
          }
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
    p.UserName = _currentUser();
    p.UserCreate = _currentUser();
    p.IsEdit = isEdit ? 1 : 0;
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

    // 1. Lưu lại state của module hiện tại trước khi chuyển sang module mới
    if (currentFormName) {
      moduleStates[currentFormName] = {
        keyword: currentKeyword,
        sortCol: currentSortCol,
        sortDir: currentSortDir,
        page: currentPage,
        filters: window.currentFilters
      };
    }

    $container = container;
    MODULE_CONFIG = config;
    currentFormName = config.FormName;

    // 2. Khôi phục state của module mới (nếu đã từng vào trước đó)
    var savedState = moduleStates[currentFormName];
    if (savedState) {
      currentKeyword = savedState.keyword;
      currentSortCol = savedState.sortCol;
      currentSortDir = savedState.sortDir;
      currentPage = savedState.page;
      window.currentFilters = savedState.filters;
    } else {
      // Nếu chưa từng vào thì reset về mặc định
      currentKeyword = '';
      currentSortCol = '';
      currentSortDir = '';
      currentPage = 1;
      window.currentFilters = null;
    }

    // Reset sạch sẽ Dictionary & Schema của Form cũ để tránh lây nhiễm (ví dụ API form mới bị lỗi thì không hiện rác của form cũ)
    globalDictionary = {};
    globalFormSchema = [];
    globalRenderers = {};

    // API defaults: FormBuilder dùng API chuyên biệt, các form khác dùng generic No-Code API
    _setDefaults(MODULE_CONFIG, {
      ApiSearch: '/api/API_Gateway_Router',
      ApiSave: '/api/API_Gateway_Router',
      ApiDelete: '/api/API_Gateway_Router'
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
          var _rowMap = { primaryKey: 'PrimaryKey' }; // Ngừng lấy formTitle và formSubtitle để ưu tiên router
          Object.keys(_rowMap).forEach(function (src) {
            if (firstRow[src]) MODULE_CONFIG[_rowMap[src]] = firstRow[src];
          });

          // Sinh nhãn mặc định — caller có thể override từ config
          _setDefaults(MODULE_CONFIG, {
            TitleAdd: '➕ Thêm ' + (MODULE_CONFIG.PageTitle || firstRow.formTitle || 'Mới'),
            TitleEdit: '✏️ Sửa ' + (MODULE_CONFIG.PageTitle || firstRow.formTitle || ''),
            BtnSaveAdd: 'Thêm mới',
            BtnSaveEdit: 'Lưu thay đổi',
            BtnSaveAll: 'Lưu Tất Cả',
            BtnCancel: 'Hủy bỏ',
            BtnSaveSaving: 'Đang lưu...',
            ToastAdd: 'Đã thêm mới thành công!',
            ToastEdit: 'Đã cập nhật thành công!',
            ToastDelete: 'Xóa thành công!',
            WarnMissingInfo: 'Thiếu thông tin',
            WarnMissingInput: 'Vui lòng điền đầy đủ thông tin: {0}',
            WarnSelectEdit: 'Vui lòng chọn dữ liệu cần sửa',
            WarnSelectDelete: 'Vui lòng chọn dữ liệu cần xóa',
            ConfirmDelete: 'Bạn có chắc muốn xóa {0}?',
            TextDeleteFallback: 'dòng này',
            AlertTitleConfirm: 'Xác nhận xóa',
            AlertTitleWarning: 'Cảnh báo',
            AlertTitleError: 'Lỗi',
            AlertTitleInfo: 'Thông báo',
            AlertApiMissing: 'Chưa cấu hình API lưu',
            AlertSaveFailed: 'Lưu dữ liệu thất bại',
            AlertDeleteFailed: 'Xóa dữ liệu thất bại',
            AlertNetworkError: 'Lỗi kết nối mạng',
            ModalWidth: '850px'
          });
        }

        dataList.forEach(function (item) {
          // Xây Dictionary cho Table
          globalDictionary[item.name] = item.label;


          // Xây dựng Custom Renderers Động từ cấu hình DB (tránh đè logic JSON của UITable)
          if (item.renderRule && item.renderRule.toLowerCase() !== 'js' && item.renderRule.toLowerCase() !== 'json') {
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
          var rawValidate = (item.validateRule || item.ValidateRule || '').trim();
          var rawVisible = (item.visibleRule || item.VisibleRule || '').trim();

          var formulaMatch = rawValidate.match(/formula:([^|]+)/i) || rawVisible.match(/formula:([^|]+)/i);
          var triggerMatch = rawValidate.match(/trigger:([^|]+)/i) || rawVisible.match(/trigger:([^|]+)/i);

          globalFormSchema.push({
            name: item.name || item.FieldName,
            label: item.label || item.CaptionVN,
            required: _bool(item.required, item.IsRequired),
            showInAdd: _bool(item.showInAdd, item.ShowInAdd),
            showInEdit: _bool(item.showInEdit, item.ShowInEdit),
            showInFilter: _bool(item.showInFilter, item.ShowInFilter),
            showInGrid: (item.showInGrid !== undefined || item.ShowInGrid !== undefined) ? _bool(item.showInGrid, item.ShowInGrid) : true,
            isReadOnlyEdit: _bool(item.isReadOnlyEdit, item.IsReadOnlyEdit),
            isReadOnlyAdd: _bool(item.isReadOnlyAdd, item.IsReadOnlyAdd),
            position: item.FormPosition || item.formPosition || item.position || '6',
            orderNo: item.OrderNo || item.orderNo || 0,
            renderRule: (item.renderRule || '').toLowerCase().trim(),
            dataSource: (item.dataSource || item.DataSource || '').trim(),
            validateRule: rawValidate,
            dependsOn: (item.dependsOn || item.DependsOn || '').trim(),
            visibleRule: rawVisible,
            formulaRule: formulaMatch ? formulaMatch[1].trim() : '',
            triggerApi: triggerMatch ? triggerMatch[1].trim() : ''
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
        <div id="dynamic-btn-container" style="display:none;"></div>
        <div class="card dynamic-grid-card" style="border: none; box-shadow: none; margin-bottom: 0; border-radius: var(--radius-sm); background: var(--color-surface); overflow: hidden;">
          <div class="card-body" style="padding: 0;">
            <div id="dynamic-filter-container" style="margin-bottom:16px;"></div>
            <div id="dynamic-grid-container"></div>
          </div>
        </div>
      `;

      // Action Toolbar (Gắn vào Global Header thay vì cục bộ)
      var globalActions = document.getElementById('global-page-actions');
      var btnContainer = globalActions || $container.querySelector('#dynamic-btn-container');

      // Xóa các nút cũ trong global header nếu có để tránh duplicate khi re-render
      if (globalActions) globalActions.innerHTML = '';

      if (btnContainer && typeof UIActionToolbar !== 'undefined') {
        var extraBtns = [];
        if (window.FormActionPlugins) {
          window.FormActionPlugins.forEach(function (plugin) {
            if (typeof plugin.getExtraButtons === 'function') {
              var getSelected = function () { return selectedRows; };
              var onReload = function () {
                window._uiConfigCache = {};
                $container.innerHTML = '';
                render($container, MODULE_CONFIG);
              };
              var btns = plugin.getExtraButtons(MODULE_CONFIG.FormName, getSelected, MODULE_CONFIG, onReload);
              if (btns && btns.length > 0) extraBtns = extraBtns.concat(btns);
            }
          });
        }

        var toolbar = UIActionToolbar.create({
          onAdd: MODULE_CONFIG.HideAddBtn ? false : (_hasPermission('ADD') ? _openAddForm : 'DISABLED'),
          onEdit: MODULE_CONFIG.HideEditBtn ? false : (_hasPermission('EDIT') ? function () {
            if (!selectedRows || selectedRows.length === 0) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectEdit);

            if (selectedRows.length > 1) {
              _openBulkEditForm();
            } else {
              _openEditForm(selectedRows[0]);
            }
          } : 'DISABLED'),
          onDelete: MODULE_CONFIG.HideDeleteBtn ? false : _hasPermission('DELETE') ? function () {
            if (!selectedRows || selectedRows.length === 0) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectDelete);

            // Hàm thực thi xóa gọi API
            var performDelete = function () {
              if (!MODULE_CONFIG.ApiDelete) {
                return Alert.info(MODULE_CONFIG.AlertTitleInfo, MODULE_CONFIG.InfoDeleteDev);
              }

              // Thực hiện xóa hàng loạt (Batch Delete) để tối ưu hiệu năng và khớp với API Gateway
              var pkField = MODULE_CONFIG.primaryKey || 'DocumentID';
              var pkValues = selectedRows.map(function (row) { return row[pkField]; }).filter(Boolean).join(',');

              var payload = {
                List: MODULE_CONFIG.FormName,
                Func: 'Delete',
                UserName: _currentUser()
              };

              // Bơm dữ liệu dòng đầu tiên kèm theo danh sách ID dạng batch (comma separated) để tránh mất các cột Not Null
              var rowData = Object.assign({}, selectedRows[0] || {});
              rowData.IsDeleted = 1; // Flag xóa mềm
              rowData[pkField] = pkValues;
              rowData['DocumentIDs'] = pkValues;
              rowData['Ids'] = pkValues;

              payload.JsonData = JSON.stringify(rowData);

              var deletePromises = [ApiClient.post(MODULE_CONFIG.ApiDelete, payload)];

              Promise.all(deletePromises).then(function (results) {
                var allSuccess = results.every(function (res) { return res && res.code === 0; });
                if (allSuccess) {
                  if (typeof UIToast !== 'undefined') UIToast.show(MODULE_CONFIG.ToastDelete, 'success');
                  selectedRows = [];
                  if (_isFormBuilder()) window._uiConfigCache = {};
                  _updateSelectionCounter();
                  _loadData();
                } else {
                  var failedResult = results.find(function (res) { return res && res.code !== 0; });
                  var dbErrorMsg = (failedResult && (failedResult.msg || failedResult.Message)) || MODULE_CONFIG.AlertDeleteFailed;
                  Alert.error(MODULE_CONFIG.AlertTitleError, dbErrorMsg);
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
          onFilter: MODULE_CONFIG.HideFilterBtn ? false : function () {
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
          onClose: false,
          extras: extraBtns
        });
        toolbar.style.display = 'inline-flex';
        toolbar.style.width = 'auto';

        // Custom Buttons
        var hasAdd = _hasPermission('ADD');
        if (!MODULE_CONFIG.HideAddBtn) {
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
        }


        btnContainer.appendChild(toolbar);
      }

      // Search bar (FilterComponent)
      var filterContainer = $container.querySelector('#dynamic-filter-container');
      if (filterContainer && typeof FilterComponent !== 'undefined') {
        filterContainer.innerHTML = ''; // Xóa placeholder nếu có

        // 1. Tự động lấy các trường cấu hình ShowInFilter từ Database
        var dynamicFilters = globalFormSchema
          .filter(function (f) { return f.showInFilter; })
          .map(function (f) {
            // Chuyển đổi định dạng từ FormEngine sang FilterComponent
            var filterType = 'text';
            if (f.renderRule === 'dt') filterType = 'date';
            if (f.renderRule === 'nm') filterType = 'number';
            if (f.renderRule === 'tm' || f.renderRule === 'time') filterType = 'time';

            var filterObj = {
              id: f.name,
              label: f.label,
              type: filterType,
              placeholder: f.label
            };

            // Parse DataSource cho trường Select/Dropdown
            if (f.renderRule === 'sl' || f.renderRule === 'sw' || f.renderRule === 'ml') {
              filterObj.type = 'select';
              filterObj.options = [];
              if (f.renderRule === 'sw') {
                filterObj.options = [{ value: 1, label: 'Có' }, { value: 0, label: 'Không' }];
              } else if (f.dataSource && f.dataSource.indexOf('STATIC:') === 0) {
                var parts = f.dataSource.replace('STATIC:', '').split(',');
                parts.forEach(function (p) {
                  var kv = p.split('|');
                  filterObj.options.push({ value: kv[0], label: kv[1] || kv[0] });
                });
              }
            }
            return filterObj;
          });

        // 2. Gom với cấu hình cứng trong AppModules.js (nếu có) hoặc xài Keyword mặc định
        var filters = [];
        if (dynamicFilters.length > 0) {
          filters = filters.concat(dynamicFilters);
        } else if (MODULE_CONFIG.Filters && MODULE_CONFIG.Filters.length > 0) {
          filters = MODULE_CONFIG.Filters;
        } else {
          filters = [{ id: 'keyword', label: MODULE_CONFIG.FilterKeywordLabel || 'Từ khóa', placeholder: MODULE_CONFIG.SearchPlaceholder }];
        }

        var filterNode = FilterComponent.create(filters, function (values) {
          // Lưu lại toàn bộ các giá trị filter thay vì chỉ keyword
          window.currentFilters = values;
          currentKeyword = values.keyword || '';
          currentPage = 1; // Reset về trang 1 khi lọc mới
          selectedRows = [];
          _updateSelectionCounter();
          _loadData();
        });
        filterContainer.appendChild(filterNode);
        filterContainer.style.display = 'none'; // Ẩn mặc định, ấn Lọc mới hiện
      }

      if (!MODULE_CONFIG.NoAutoLoad) {
        _loadData();
      }
    })
      .catch(function (err) {
        $container.innerHTML = '<div class="p-4 text-danger">' + MODULE_CONFIG.TextLoadingError + err.message + '</div>';
      });
  }

  // ── Load Data ─────────────────────────────────────────────
  var savedScrollY = 0; // Lưu vị trí scroll

  function _loadData() {
    // Đồng bộ state hiện tại vào cache để tránh mất filter khi F5
    if (currentFormName) {
      moduleStates[currentFormName] = {
        keyword: currentKeyword,
        sortCol: currentSortCol,
        sortDir: currentSortDir,
        page: currentPage,
        filters: window.currentFilters
      };
      _saveModuleStates();
    }

    var gridContainer = $container ? $container.querySelector('#dynamic-grid-container') : null;
    var existingTable = gridContainer ? gridContainer.querySelector('.table-wrapper') : null;

    if (existingTable && typeof existingTable.showLoading === 'function') {
      savedScrollY = window.scrollY;
      existingTable.showLoading(MODULE_CONFIG.TextLoading);
    } else if (gridContainer) {
      gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">' + MODULE_CONFIG.TextLoading + '</div>';
    }

    if (MODULE_CONFIG.ApiSearch) {
      // Gom các bộ lọc đang active (bỏ các trường rỗng)
      var activeFilters = {};
      if (window.currentFilters) {
        for (var k in window.currentFilters) {
          if (window.currentFilters[k] !== '' && window.currentFilters[k] !== null) {
            activeFilters[k] = window.currentFilters[k];
          }
        }
      }
      // Thêm Keyword vào filter JSON
      if (currentKeyword) activeFilters['Keyword'] = currentKeyword;

      // Đổi màu nút Lọc nếu có dữ liệu lọc
      var actionsContainer = document.getElementById('global-page-actions') || $container;
      if (actionsContainer) {
        var btns = actionsContainer.querySelectorAll('button');
        var filterBtn = null;
        for (var i = 0; i < btns.length; i++) {
          if (btns[i].innerHTML.indexOf('filter_alt') !== -1 || btns[i].innerText === 'Lọc' || btns[i].getAttribute('data-tooltip') === 'Lọc / Tìm kiếm dữ liệu') {
            filterBtn = btns[i];
            break;
          }
        }
        if (filterBtn) {
          var hasFilter = Object.keys(activeFilters).length > 0;
          if (hasFilter) {
            filterBtn.classList.remove('btn-outline-secondary');
            filterBtn.classList.remove('text-dark');
            filterBtn.classList.add('btn-primary');
            filterBtn.classList.add('text-white');

            filterBtn.style.setProperty('color', '#fff', 'important');
            filterBtn.style.setProperty('background-color', 'var(--color-primary, #3b82f6)', 'important');
            filterBtn.style.setProperty('border-color', 'var(--color-primary, #3b82f6)', 'important');
          } else {
            filterBtn.classList.remove('btn-primary');
            filterBtn.classList.remove('text-white');
            if (filterBtn.className.indexOf('btn-') === -1) {
              filterBtn.classList.add('btn-outline-secondary');
            }
            filterBtn.style.color = '';
            filterBtn.style.backgroundColor = '';
            filterBtn.style.borderColor = '';
            // Xóa dấu chấm đỏ nếu có
            var badge = filterBtn.querySelector('.filter-badge');
            if (badge) badge.remove();
          }
        }
      }

      var query = {
        List: MODULE_CONFIG.FormName,
        Func: 'View',
        UserName: _currentUser(),
        User: _currentUser(),
        Page: currentPage,
        Limit: currentLimit,
        SortColumn: currentSortCol || '',
        SortDir: currentSortDir || '',
        Keyword: currentKeyword || ''
      };

      if (Object.keys(activeFilters).length > 0) {
        query.JsonData = JSON.stringify(activeFilters);
      }
      ApiClient.post(MODULE_CONFIG.ApiSearch, query).then(function (result) {
        // Trả lại quyền sinh sát (tính phân trang) cho C# Backend
        totalRecords = result._recordtotal || 0;
        totalPagesFromApi = result._pagetotal || 0;

        lastTimestamp = result._timestamp || '';
        var dataList = result.list || result.records || [];
        gridData = dataList.map(function (item) {
          // Lấy khóa chính từ cấu hình, nếu không có thì tự động lấy cột đầu tiên của dữ liệu
          var firstKey = Object.keys(item).length > 0 ? Object.keys(item)[0] : null;
          item.id = item[MODULE_CONFIG.PrimaryKey] || (firstKey ? item[firstKey] : null) || Math.random();
          return item;
        });

        _renderTable();
      }).catch(function (err) {
        console.error('Lỗi tải danh sách:', err);
        if (typeof Alert !== 'undefined') Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertNetworkError);
        gridData = [];
        totalRecords = 0;
        totalPagesFromApi = 0;
        lastTimestamp = '';
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
      // Chỉ hiển thị các cột có cấu hình position là 'grid' hoặc các số lưới (12, 8, 6, 4, 3)
      var dictionary = {};
      globalFormSchema.forEach(function (f) {
        var pos = String(f.position || '').trim();
        var isGridPos = (pos === 'grid' || (!isNaN(pos) && pos !== ''));
        if (isGridPos && f.showInGrid !== false && String(f.showInGrid) !== '0' && pos !== 'hidden') {
          dictionary[f.name] = f.label;
        }
      });
      if (Object.keys(dictionary).length === 0) {
        dictionary = globalDictionary;
      }

      // Render các cột tùy chỉnh (Sinh ra tự động từ RenderRule trong DB)
      var customRenderers = globalRenderers;

      // Gọi UITable.createDynamic siêu cấp
      var tableEl = UITable.createDynamic(gridData, dictionary, {
        currentSort: { field: currentSortCol, dir: currentSortDir },
        onSort: function (field, dir) {
          currentSortCol = field;
          currentSortDir = dir;
          currentPage = 1;
          selectedRows = [];
          _updateSelectionCounter();
          _loadData();
        },
        actionRenderers: customRenderers
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
          totalPages: totalPagesFromApi,
          timestamp: lastTimestamp,
          itemsPerPage: currentLimit,
          currentPage: currentPage,
          onPageChange: function (page) {
            currentPage = page;
            _loadData();
          },
          onLimitChange: function (newLimit) {
            currentLimit = newLimit;
            currentPage = 1;
            selectedRows = [];
            _updateSelectionCounter();
            _loadData();
          },
          onRefresh: function () {
            selectedRows = [];
            _updateSelectionCounter();
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
            // Click don: Chon 1 dong (clear dong cu), click lai de bo chon
            var wasActive = tr.classList.contains('active');
            allTrsList.forEach(function (r) { r.classList.remove('active'); });
            selectedRows = [];
            if (!wasActive) {
              tr.classList.add('active');
              selectedRows.push(rData);
            }
            lastSelectedIdx = wasActive ? -1 : idx;
          }
          _updateSelectionCounter();
        });
        tbody.addEventListener('dblclick', function (e) {
          var tr = e.target.closest('tr');
          if (!tr) return;

          var idx = Array.from(tbody.children).indexOf(tr);
          var rData = gridData[idx];
          if (!rData) return;

          if (typeof MODULE_CONFIG.onRowDblClick === 'function') {
            MODULE_CONFIG.onRowDblClick(rData);
            return;
          }

          if (MODULE_CONFIG.HideEditBtn) return;

          // Nếu đang chọn nhiều dòng (và dòng được double click nằm trong số đó) thì mở sửa hàng loạt
          if (selectedRows.length > 1 && selectedRows.find(function (sr) { return sr.id === rData.id; })) {
            _openBulkEditForm();
          } else {
            // Mở form sửa cho dòng vừa được double click (bất kể trước đó có được bôi đen hay chưa)
            _openEditForm(rData);
          }
        });
      }

      _updateSelectionCounter();
    }
  }

  function _updateSelectionCounter() {
    _saveSelectedRows();

    var globalActions = document.getElementById('global-page-actions');
    var btnContainer = globalActions || $container.querySelector('#dynamic-btn-container');
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
          #dynamic-btn-container .button-bar,
          .page-title-actions .button-bar {
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
        <th style="width:140px;">Tên Cột (Database) *</th>
        <th style="width:160px;">Tiêu đề (Tiếng Việt)</th>
        <th style="width:120px;">Loại Input</th>
        <th style="width:70px; text-align:center;">Bắt buộc</th>
        <th style="width:160px;">Nguồn dữ liệu (API/STATIC)</th>
        <th style="width:80px;">Vị trí</th>
        <th style="width:150px;" title="Ví dụ: TrangThai=huy|doi">VisibleRule</th>
        <th style="width:60px; text-align:center;">Thêm</th>
        <th style="width:60px; text-align:center;">Sửa</th>
        <th style="width:60px; text-align:center;">Lọc</th>
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
            <option value="tm">Giờ (Time)</option>
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
        <td class="p-1"><input type="text" class="ui-input" name="VisibleRule" placeholder="VD: TrangThai=huy|doi"></td>
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
          <div class="d-flex justify-content-center h-100 align-items-center">
            <input type="checkbox" class="modern-checkbox" name="ShowInFilter" value="1" style="cursor: pointer; margin-top: 0;" title="Hiển thị bộ lọc">
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
        var visibleRule = tr.querySelector('[name="VisibleRule"]').value.trim();
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
            VisibleRule: visibleRule,
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
      hiddenPK.value = _getValueFromRow(row, MODULE_CONFIG.PrimaryKey);
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
        field.value = _getValueFromRow(row, field.name);
        var originalName = field.name;
        field.name = originalName + '_' + rowIdx;

        var inputEl;
        if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
          inputEl = UIInput.createSwitch(field);
        } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
          inputEl = UIInput.createDate(field);
        } else if (field.renderRule === 'tm' || field.renderRule === 'time') {
          inputEl = UIInput.createTime(field);
        } else if ((field.renderRule === 'sl' || field.renderRule === 'select' || field.renderRule === 'ml') && field.dataSource) {
          inputEl = document.createElement('div');
          inputEl.className = 'form-group';
          inputEl.style.marginBottom = '0';

          var hiddenInput = document.createElement('input');
          hiddenInput.type = 'hidden';
          hiddenInput.name = field.name;
          var initialValue = field.value || '';
          if (field.renderRule === 'ml' && initialValue.startsWith('[')) {
            try {
              var arr = JSON.parse(initialValue);
              if (Array.isArray(arr)) {
                initialValue = arr.map(function (x) { return String(x.Sanhtiecid || x.id || x.value || x); }).join(',');
              }
            } catch (e) { }
          }
          hiddenInput.value = initialValue;
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
                getValue: function () { return hiddenInput.value; },
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
                  showAddNew: true, // Bật nút Thêm mới
                  onF2: function () {
                    var targetFormName = field.dataSource;
                    if (targetFormName.includes('|')) targetFormName = targetFormName.split('|')[0];
                    if (targetFormName.includes('?')) {
                      var searchParams = new URLSearchParams(targetFormName.split('?')[1]);
                      var listParam = searchParams.get('List') || searchParams.get('list');
                      if (listParam) targetFormName = listParam;
                    }
                    
                    if (typeof window.openQuickAddModal === 'function') {
                      window.openQuickAddModal(targetFormName, function (newRecord) {
                        if (newRecord) {
                          ApiClient.post(MODULE_CONFIG.ApiSearch, { FormName: field.dataSource, Limit: 1000 }).then(function (res) {
                            var updatedComboData = [];
                            var dataList = res.list || res.records || [];
                            if (dataList && dataList.length > 0) {
                              var keys = Object.keys(dataList[0]);
                              var labelRegex = /name|tên|ten|label|desc|title/i;
                              var displayKey = keys.find(function (k) { return labelRegex.test(k); });
                              var localFilterIdx = displayKey ? keys.indexOf(displayKey) : (keys.length > 1 ? 1 : 0);
                              
                              dataList.forEach(function (d) {
                                var rd = [];
                                keys.forEach(function (k) { rd.push(d[k] !== null && d[k] !== undefined ? d[k] : ''); });
                                updatedComboData.push(rd);
                              });
                              
                              comboData.length = 0;
                              Array.prototype.push.apply(comboData, updatedComboData);
                              
                              var newlyAddedKey = Object.keys(newRecord)[0];
                              var matched = comboData.find(function (r) { return String(r[0]) === String(newRecord[newlyAddedKey]); });
                              if (matched) {
                                hiddenInput.value = matched[0];
                                var displayInp = newCombo.querySelector('input.ui-input');
                                if (displayInp) displayInp.value = matched[localFilterIdx];
                                hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
                              }
                            }
                          });
                        }
                      });
                    } else {
                      newCombo.querySelector('.ui-input').focus();
                    }
                  },
                  getValue: function () { return hiddenInput.value; },
                  onSelect: function (r) { hiddenInput.value = r[0]; },
                  onChange: function (val) { hiddenInput.value = val; } // Hỗ trợ gõ tay khách mới
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
        } else if (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn') {
          inputEl = UIInput.createMoney(field);
        } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
          inputEl = UIInput.createNumber(field);
        } else if (field.renderRule === 'rb' || field.renderRule === 'rulebuilder') {
          var wrapper = document.createElement('div');
          wrapper.className = 'form-group';
          var flexDiv = document.createElement('div');
          flexDiv.style.display = 'flex';
          flexDiv.style.gap = '8px';

          var input = document.createElement('input');
          input.type = 'text';
          input.className = 'ui-input';
          input.name = field.name;
          input.value = field.value || '';
          input.placeholder = 'Click nút Thiết lập...';
          input.readOnly = true;
          input.style.flex = '1';

          var btnWrapper = document.createElement('div');
          btnWrapper.innerHTML = UIButton.createHTML({ text: '', type: 'secondary', icon: 'settings', className: 'btn-icon-only' });
          var btn = btnWrapper.firstElementChild;
          btn.style.height = '100%';
          btn.onclick = function (e) {
            e.preventDefault();
            if (typeof RuleBuilderDialog !== 'undefined') {
              var formNameVal = row.FormName || row.formName || row.FORMNAME || '';
              RuleBuilderDialog.open({
                currentRule: input.value,
                targetFormName: formNameVal,
                onSave: function (newRule) {
                  input.value = newRule;
                  input.dispatchEvent(new Event('change', { bubbles: true }));
                }
              });
            } else {
              Alert.error('Lỗi', 'Chưa tải Component Rule Builder!');
            }
          };
          flexDiv.appendChild(input);
          flexDiv.appendChild(btn);
          wrapper.appendChild(flexDiv);
          inputEl = wrapper;
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

  function createJsonGridEditor(field, isReadOnly) {
    var wrapper = document.createElement('div');
    wrapper.className = 'form-group json-grid-editor-wrapper';
    wrapper.style.width = '100%';
    wrapper.style.marginBottom = '16px';

    if (field.label) {
      var lbl = document.createElement('label');
      lbl.innerText = field.label;
      lbl.style.fontWeight = '600';
      lbl.style.marginBottom = '6px';
      lbl.style.display = 'block';
      if (field.required) {
        var req = document.createElement('span');
        req.innerText = ' *';
        req.style.color = 'var(--color-danger)';
        lbl.appendChild(req);
      }
      wrapper.appendChild(lbl);
    }

    var hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    hiddenInput.name = field.name;
    hiddenInput.value = field.value || '[]';
    wrapper.appendChild(hiddenInput);

    // Parse initial value
    var dataList = [];
    try {
      if (field.value) {
        dataList = JSON.parse(field.value);
      }
    } catch (e) {
      console.warn('Failed to parse JSON for ' + field.name, e);
    }
    if (!Array.isArray(dataList)) {
      dataList = [];
    }

    // Parse columns dynamically from field.dataSource if configured in database
    var cols = [];
    if (field.dataSource) {
      var ds = field.dataSource.trim();
      if (ds.startsWith('[') && ds.endsWith(']')) {
        try {
          cols = JSON.parse(ds);
        } catch (e) {
          console.error('Failed to parse columns JSON from database metadata (DataSource) for field ' + field.name, e);
        }
      } else if (ds.indexOf('|') >= 0) {
        // Support shorthand format in DB: key1|label1|type1|width1,key2|label2|type2|width2
        var parts = ds.split(',');
        parts.forEach(function (p) {
          var sub = p.split('|');
          if (sub.length >= 2) {
            cols.push({
              key: sub[0].trim(),
              label: sub[1].trim(),
              type: (sub[2] || 'text').trim(),
              width: (sub[3] || 'auto').trim()
            });
          }
        });
      }
    }

    if (!cols || cols.length === 0) {
      console.error('DynamicFormEngine: JSON grid field "' + field.name + '" requires a column schema defined in the database (DataSource).');
      cols = [];
    }

    var tableContainer = document.createElement('div');
    tableContainer.style.cssText = 'border: 1px solid var(--color-border, #e2e8f0); border-radius: 6px; overflow: hidden; background: var(--color-surface, #fff); margin-top: 6px;';

    var table = document.createElement('table');
    table.className = 'table table-hover mb-0';
    table.style.cssText = 'width: 100%; border-collapse: collapse; margin-bottom: 0;';

    var thead = document.createElement('thead');
    thead.style.cssText = 'background: var(--color-bg-secondary, #f8fafc); border-bottom: 1px solid var(--color-border, #e2e8f0);';
    var trHead = document.createElement('tr');

    cols.forEach(function (col) {
      var th = document.createElement('th');
      th.innerText = col.label;
      th.style.cssText = 'padding: 8px 12px; font-size: 12px; font-weight: 600; text-align: left; color: var(--color-text-secondary, #64748b);' + (col.width !== 'auto' ? ' width: ' + col.width + ';' : '');
      trHead.appendChild(th);
    });

    // Action column header
    var thAction = document.createElement('th');
    thAction.style.cssText = 'padding: 8px 12px; width: 50px; text-align: center;';
    trHead.appendChild(thAction);

    thead.appendChild(trHead);
    table.appendChild(thead);

    var tbody = document.createElement('tbody');
    table.appendChild(tbody);
    tableContainer.appendChild(table);
    wrapper.appendChild(tableContainer);

    function updateHiddenValue() {
      var rows = tbody.querySelectorAll('tr');
      var list = [];
      rows.forEach(function (tr) {
        var obj = {};
        cols.forEach(function (col) {
          var input = tr.querySelector('[data-key="' + col.key + '"]');
          if (input) {
            var val = input.value.trim();
            if (col.type === 'number') {
              obj[col.key] = parseInt(val, 10) || 0;
            } else {
              obj[col.key] = val;
            }
          }
        });
        // Check if row has any non-empty data
        var hasData = Object.keys(obj).some(function (k) {
          return obj[k] !== '' && obj[k] !== 0;
        });
        if (hasData) {
          list.push(obj);
        }
      });
      hiddenInput.value = JSON.stringify(list);
      hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function addRow(itemData) {
      var tr = document.createElement('tr');
      tr.style.cssText = 'border-bottom: 1px solid var(--color-border, #e2e8f0);';

      cols.forEach(function (col) {
        var td = document.createElement('td');
        td.style.cssText = 'padding: 4px 8px; vertical-align: middle;';

        var input;
        if (col.type === 'select') {
          input = document.createElement('select');
          input.className = 'ui-input';
          input.dataset.key = col.key;
          input.style.cssText = 'width: 100%; height: 32px; padding: 4px 8px; border: 1px solid var(--color-border, #cbd5e1); border-radius: 4px; font-size: 12px; background: var(--color-surface, #fff); color: var(--color-text, #1e293b);';

          var optionsList = [];
          if (col.options) {
            if (typeof col.options === 'string') {
              var opts = col.options.split(',');
              opts.forEach(function (opt) {
                var p = opt.split('|');
                optionsList.push({ value: p[0].trim(), label: (p[1] || p[0]).trim() });
              });
            } else if (Array.isArray(col.options)) {
              optionsList = col.options;
            }
          }
          optionsList.forEach(function (opt) {
            var o = document.createElement('option');
            o.value = opt.value;
            o.textContent = opt.label;
            input.appendChild(o);
          });
          input.value = itemData ? (itemData[col.key] !== undefined ? itemData[col.key] : '') : '';
        } else {
          input = document.createElement('input');
          input.type = col.type === 'number' ? 'number' : 'text';
          input.className = 'ui-input';
          input.dataset.key = col.key;
          input.value = itemData ? (itemData[col.key] !== undefined ? itemData[col.key] : '') : '';
          input.style.cssText = 'width: 100%; height: 32px; padding: 4px 8px; border: 1px solid var(--color-border, #cbd5e1); border-radius: 4px; font-size: 12px; background: var(--color-surface, #fff); color: var(--color-text, #1e293b);';
        }

        if (isReadOnly) {
          input.disabled = true;
        } else {
          input.addEventListener('change', updateHiddenValue);
          if (col.type !== 'select') {
            input.addEventListener('input', updateHiddenValue);
          }
        }
        td.appendChild(input);
        tr.appendChild(td);
      });

      // Action button column
      var tdAction = document.createElement('td');
      tdAction.style.cssText = 'padding: 4px 8px; text-align: center; vertical-align: middle;';

      var btnDel = document.createElement('button');
      btnDel.type = 'button';
      btnDel.className = 'btn btn-sm btn-tool text-danger';
      btnDel.style.cssText = 'padding: 4px; display: inline-flex; align-items: center; justify-content: center; border: none; background: transparent; cursor: pointer;';
      btnDel.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px;">delete</span>';
      if (isReadOnly) {
        btnDel.disabled = true;
        btnDel.style.opacity = '0.5';
        btnDel.style.cursor = 'not-allowed';
      } else {
        btnDel.onclick = function () {
          tr.remove();
          updateHiddenValue();
        };
      }

      tdAction.appendChild(btnDel);
      tr.appendChild(tdAction);
      tbody.appendChild(tr);
    }

    // Add existing rows
    dataList.forEach(function (item) {
      addRow(item);
    });

    // If empty, add a default empty row
    if (dataList.length === 0 && !isReadOnly) {
      addRow(null);
    }

    if (!isReadOnly) {
      // Add "Add row" button
      var btnAdd = document.createElement('button');
      btnAdd.type = 'button';
      btnAdd.className = 'btn btn-outline-primary btn-sm';
      btnAdd.style.cssText = 'margin-top: 8px; display: inline-flex; align-items: center; gap: 4px; font-size: 11px; padding: 4px 10px; height: 28px;';
      btnAdd.innerHTML = '<span class="material-symbols-outlined" style="font-size:14px;">add</span> Thêm dòng mới';
      btnAdd.onclick = function () {
        addRow(null);
        updateHiddenValue();
      };
      wrapper.appendChild(btnAdd);
    }

    return wrapper;
  }

  function _openModal(isEdit, row) {
    if (isEdit && !row) return;

    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';
    body.setAttribute('data-form-name', MODULE_CONFIG.FormName || ''); // Plugin detection
    if (isEdit && row) {
      try {
        body.dataset.editRowJson = JSON.stringify(row);
      } catch (e) { /* ignore */ }
    }

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
        hiddenEl.value = row ? _getValueFromRow(row, field.name) : '';
        body.appendChild(hiddenEl);
        return;
      }

      // Tự động gán giá trị cũ (nếu đang Sửa 1 dòng).
      field.value = (isEdit && row) ? _getValueFromRow(row, field.name) : '';

      // Khởi tạo Ô nhập liệu tuỳ thuộc vào quy tắc renderRule
      var inputEl;
      if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
        inputEl = UIInput.createSwitch(field);
      } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
        inputEl = UIInput.createDate(field);
      } else if (field.renderRule === 'tm' || field.renderRule === 'time') {
        inputEl = UIInput.createTime(field);
      } else if ((field.renderRule === 'sl' || field.renderRule === 'sr' || field.renderRule === 'select' || field.renderRule === 'ml') && field.dataSource) {
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
        var initialValue = field.value || '';
        if (field.renderRule === 'ml' && initialValue.startsWith('[')) {
          try {
            var arr = JSON.parse(initialValue);
            if (Array.isArray(arr)) {
              initialValue = arr.map(function (x) { return String(x.Sanhtiecid || x.id || x.value || x); }).join(',');
            }
          } catch (e) { }
        }
        hiddenInput.value = initialValue;
        formGroupWrapper.appendChild(hiddenInput);

        if (field.dataSource) {
          if (String(field.dataSource).toUpperCase().startsWith('STATIC:')) {
            var staticStr = field.dataSource.substring(7);
            var staticData = staticStr.split(',').map(function (s) {
              var parts = s.split('|');
              return [parts[0], parts[1] || parts[0], parts[2] || ''];
            });

            var lazyStaticCombo = UIControls.createDataComboBox({
              placeholder: '-- Vui lòng chọn --',
              headers: ['Mã', 'Tên'],
              disabled: ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd)),
              readonlyInput: field.renderRule === 'ml' || field.renderRule === 'sr',
              multiple: field.renderRule === 'ml',
              getValue: function () { return hiddenInput.value; },
              onSearch: function (q, page) {
                return new Promise(function (resolve) {
                  var filtered = staticData;
                  if (field.dependsOn) {
                    var parents = field.dependsOn.split(',').map(function (p) { return p.trim(); });
                    filtered = staticData.filter(function (r) {
                      if (!r[2]) return true; // Ko cấu hình parent => luôn hiện
                      var parentValueNow = currentModalFormState[parents[0]] || '';
                      return String(r[2]) === String(parentValueNow);
                    });
                  }
                  if (q) {
                    filtered = filtered.filter(function (r) { return r[1].toLowerCase().indexOf(q.toLowerCase()) > -1; });
                  }
                  resolve({ headers: ['Mã', 'Tên'], data: filtered, colFilterIndex: 1 });
                });
              },
              onSelect: function (row) {
                hiddenInput.value = row[0]; // Cập nhật ID
                hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
              }
            });

            var displayInput = lazyStaticCombo.querySelector('input.ui-input');
            var matched = staticData.find(function (r) { return String(r[0]) === String(field.value); });
            if (matched && displayInput) displayInput.value = matched[1];

            hiddenInput.fetchDataForValue = function () {
              var displayInp = lazyStaticCombo.querySelector('input.ui-input');
              var matched = staticData.find(function (r) { return String(r[0]) === String(hiddenInput.value); });
              if (matched && displayInp) displayInp.value = matched[1];
              else if (displayInp) displayInp.value = hiddenInput.value || '';
            };

            formGroupWrapper.appendChild(lazyStaticCombo);
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

            var endpointRaw = field.dataSource;
            var maxCols = 4; // Mặc định hiển thị 4 cột
            if (endpointRaw.indexOf('|') > -1) {
              var dsParts = endpointRaw.split('|');
              endpointRaw = dsParts[0];
              var parsedCols = parseInt(dsParts[1], 10);
              if (!isNaN(parsedCols) && parsedCols > 0) maxCols = parsedCols;
            }
            var endpoint = endpointRaw.startsWith('http') ? endpointRaw : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + endpointRaw);
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
              var isGateway = finalUrl.indexOf('API_Gateway_Router') > -1;
              var dynamicFilters = {};

              if (typeof currentModalFormState !== 'undefined') {
                if (isGateway) {
                  dynamicFilters = Object.assign({}, currentModalFormState);
                  // Cũng gán các thuộc tính lên payload để resolve placeholder trên Gateway router
                  payload = Object.assign(payload, currentModalFormState);
                } else {
                  payload = Object.assign(payload, currentModalFormState);
                }
              }

              if (q) {
                payload.Keyword = q;
                if (isGateway) dynamicFilters.Keyword = q; // Nhét thêm Keyword vào JsonData dự phòng cho Gateway dễ truy vấn
              }

              if (isGateway && Object.keys(dynamicFilters).length > 0) {
                payload.JsonData = JSON.stringify(dynamicFilters);
              }

              return ApiClient.post(finalUrl, payload).then(function (res) {
                var comboData = [];
                var dataList = res.list || res.records;
                var headers = ['Mã', 'Tên'];
                var colFilterIndex = 1;
                if (dataList && dataList.length > 0) {
                  var keys = Object.keys(dataList[0]);
                  comboLoading.dataset.lastKeys = JSON.stringify(keys); // Lưu lại keys để dùng cho auto-fill
                  if (keys.length > 0) {
                    // Dùng từ điển hiện tại của form để dịch tiêu đề lưới (nếu có), CHỈ HIỆN MAX CỘT ĐƯỢC CHỈ ĐỊNH (mặc định 4)
                    var displayKeys = keys.slice(0, maxCols);
                    headers = displayKeys.map(function (k) {
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
              showAddNew: field.renderRule !== 'sr',
              readonlyInput: field.renderRule === 'ml' || field.renderRule === 'sr',
              multiple: field.renderRule === 'ml',
              onF2: function () {
                var targetFormName = field.dataSource;
                if (targetFormName.includes('|')) targetFormName = targetFormName.split('|')[0];
                if (targetFormName.includes('?')) {
                  var searchParams = new URLSearchParams(targetFormName.split('?')[1]);
                  var listParam = searchParams.get('List') || searchParams.get('list');
                  if (listParam) targetFormName = listParam;
                }
                
                if (typeof window.openQuickAddModal === 'function') {
                  window.openQuickAddModal(targetFormName, function (newRecord) {
                    if (newRecord) {
                      var keys = Object.keys(newRecord);
                      hiddenInput.value = newRecord[keys[0]];
                      if (typeof hiddenInput.fetchDataForValue === 'function') {
                        hiddenInput.fetchDataForValue();
                      }
                    }
                  });
                } else {
                  lazyCombo.querySelector('.ui-input').focus();
                }
              },
              getValue: function () { return hiddenInput.value; },
              onSearch: searchApiCall,
              onChange: function (val) { if (field.renderRule !== 'sr') hiddenInput.value = val; },
              onSelect: function (row) {
                hiddenInput.value = row[0];

                var savedKeysStr = comboLoading.dataset.lastKeys;
                if (savedKeysStr) {
                  var keys = JSON.parse(savedKeysStr);
                  keys.forEach(function (keyName, index) {
                    var form = hiddenInput.closest('.ui-modal') || hiddenInput.closest('body');
                    if (form) {
                      var targetInput = form.querySelector('[name="' + keyName + '" i]');
                      if (targetInput && targetInput !== hiddenInput && targetInput.value !== (row[index] || '')) {
                        targetInput.value = row[index] || '';
                        targetInput.dispatchEvent(new Event('change', { bubbles: true }));

                        if (typeof targetInput.fetchDataForValue === 'function') {
                          targetInput.fetchDataForValue();
                        }
                      }
                    }
                  });
                }

                hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
              }
            });

            if (field.value) {
              searchApiCall(field.value, 1).then(function (res) {
                var displayInput = lazyCombo.querySelector('input.ui-input');
                if (field.renderRule === 'ml') {
                  var vals = hiddenInput.value.split(',');
                  var matches = res.data.filter(function (r) { return vals.includes(String(r[0])); });
                  if (matches.length > 0 && displayInput) {
                    displayInput.value = matches.map(function (m) { return m[res.colFilterIndex || 1]; }).join(', ');
                  } else if (displayInput) {
                    displayInput.value = hiddenInput.value;
                  }
                } else {
                  var matched = res.data.find(function (r) { return String(r[0]) === String(field.value); });
                  if (matched && displayInput) {
                    displayInput.value = matched[res.colFilterIndex || 1];
                  } else if (displayInput) {
                    displayInput.value = field.value; // Fallback
                  }
                }
              }).catch(function (err) {
                console.error('[DynamicFormEngine] DataComboBox initial fetch error:', err);
                var displayInput = lazyCombo.querySelector('input.ui-input');
                if (displayInput) displayInput.placeholder = 'Lỗi tải dữ liệu';
              });
            }

            // Expose hàm để Auto-Fill gọi lại nhằm cập nhật Text
            hiddenInput.fetchDataForValue = function () {
              if (hiddenInput.value) {
                var displayInput = lazyCombo.querySelector('input.ui-input');
                if (displayInput) displayInput.value = 'Đang tải...';
                searchApiCall(hiddenInput.value, 1).then(function (res) {
                  var displayInp = lazyCombo.querySelector('input.ui-input');
                  if (field.renderRule === 'ml') {
                    var vals = hiddenInput.value.split(',');
                    var matches = res.data.filter(function (r) { return vals.includes(String(r[0])); });
                    if (matches.length > 0 && displayInp) displayInp.value = matches.map(function (m) { return m[res.colFilterIndex || 1]; }).join(', ');
                    else if (displayInp) displayInp.value = hiddenInput.value;
                  } else {
                    var matched = res.data.find(function (r) { return String(r[0]) === String(hiddenInput.value); });
                    if (matched && displayInp) displayInp.value = matched[res.colFilterIndex || 1];
                    else if (displayInp) displayInp.value = hiddenInput.value; // Fallback
                  }
                });
              } else {
                var displayInput = lazyCombo.querySelector('input.ui-input');
                if (displayInput) displayInput.value = '';
              }
            };

            formGroupWrapper.replaceChild(lazyCombo, comboLoading);
          }
        } else {
          var comboEmpty = UIControls.createDataComboBox({ placeholder: 'Chưa có dữ liệu' });
          formGroupWrapper.appendChild(comboEmpty);
          inputEl = formGroupWrapper;
        }
      } else if (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn') {
        inputEl = UIInput.createMoney(field);
      } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
        inputEl = UIInput.createNumber(field);
      } else if (field.renderRule === 'json' || field.renderRule === 'js') {
        var isReadOnly = ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd));
        inputEl = createJsonGridEditor(field, isReadOnly);
      } else if (field.renderRule === 'textarea' || field.renderRule === 'ta' || (field.renderRule === 'ml' && !field.dataSource) || field.name.toLowerCase().indexOf('note') >= 0 || field.name.toLowerCase().indexOf('ghichu') >= 0) {
        var formGroupWrapper = document.createElement('div');
        formGroupWrapper.className = 'form-group';
        formGroupWrapper.style.width = '100%';
        if (field.label) {
          var lbl = document.createElement('label');
          lbl.innerText = field.label;
          lbl.style.fontWeight = '600';
          lbl.style.marginBottom = '6px';
          lbl.style.display = 'block';
          if (field.required) {
            var req = document.createElement('span');
            req.innerText = ' *';
            req.style.color = 'var(--color-danger)';
            lbl.appendChild(req);
          }
          formGroupWrapper.appendChild(lbl);
        }
        var textarea = document.createElement('textarea');
        textarea.className = 'ui-input';
        textarea.name = field.name;
        textarea.value = field.value || '';
        textarea.style.minHeight = '80px';
        textarea.style.padding = '8px 12px';
        textarea.style.width = '100%';
        textarea.style.border = '1px solid var(--color-border, #cbd5e1)';
        textarea.style.borderRadius = '4px';
        textarea.style.background = 'var(--color-surface, #fff)';
        textarea.style.color = 'var(--color-text, #1e293b)';
        if (field.placeholder) textarea.placeholder = field.placeholder;
        formGroupWrapper.appendChild(textarea);
        inputEl = formGroupWrapper;
      } else if (field.renderRule === 'rb' || field.renderRule === 'rulebuilder') {
        var wrapper = document.createElement('div');
        wrapper.className = 'form-group';
        if (field.label) {
          var lbl = document.createElement('label');
          lbl.innerText = field.label;
          wrapper.appendChild(lbl);
        }
        var flexDiv = document.createElement('div');
        flexDiv.style.display = 'flex';
        flexDiv.style.gap = '8px';

        var input = document.createElement('input');
        input.type = 'text';
        input.className = 'ui-input';
        input.name = field.name;
        input.value = field.value || '';
        input.placeholder = 'Click [Thiết lập] để chọn điều kiện';
        input.readOnly = true;
        input.style.flex = '1';

        var btnWrapper = document.createElement('div');
        btnWrapper.innerHTML = UIButton.createHTML({ text: 'Thiết lập', type: 'secondary', icon: 'settings' });
        var btn = btnWrapper.firstElementChild;
        btn.onclick = function (e) {
          e.preventDefault();
          if (typeof RuleBuilderDialog !== 'undefined') {
            var formNameVal = row ? (row.FormName || row.formName || row.FORMNAME) : '';
            if (!formNameVal && typeof currentModalFormState !== 'undefined') formNameVal = currentModalFormState['FormName'] || '';
            if (!formNameVal) {
              var fnInput = document.querySelector('input[name="FormName"], select[name="FormName"]');
              if (fnInput) formNameVal = fnInput.value;
            }

            RuleBuilderDialog.open({
              currentRule: input.value,
              targetFormName: formNameVal,
              onSave: function (newRule) {
                input.value = newRule;
                input.dispatchEvent(new Event('change', { bubbles: true }));
              }
            });
          } else {
            Alert.error('Lỗi', 'Chưa tải Component Rule Builder!');
          }
        };

        flexDiv.appendChild(input);
        flexDiv.appendChild(btn);
        wrapper.appendChild(flexDiv);
        inputEl = wrapper;
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
      var span = String(field.position || 'hidden');
      if (span === 'grid') span = '6';
      if (span === 'body') span = '12';
      if (span === 'hidden') span = '12';
      if (!['12', '8', '6', '4', '3', '2'].includes(span)) span = '12';

      var wrapper = document.createElement('div');
      wrapper.className = 'df-col-' + span;
      // Gán VisibleRule lên wrapper để UIControls.utils.applyVisibleRules xử lý
      if (field.visibleRule) wrapper.dataset.visibleRule = field.visibleRule;

      wrapper.appendChild(inputEl);
      grid.appendChild(wrapper);

      // Gán giá trị mặc định vào currentModalFormState
      var val = field.value || '';
      if (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn') {
        val = String(val).replace(/\D/g, '');
      }
      currentModalFormState[field.name] = val;
    });

    // Áp VisibleRule: show/hide fields theo cấu hình trong SY_FormatFields.VisibleRule
    if (typeof UIControls !== 'undefined' && UIControls.utils && UIControls.utils.applyVisibleRules) {
      UIControls.utils.applyVisibleRules(body);
    }

    // Xử lý Disable ban đầu cho các trường có DependsOn nếu BẤT KỲ trường cha nào đang trống
    globalFormSchema.forEach(function (f) {
      if (f.dependsOn) {
        var parents = f.dependsOn.split(',').map(function (p) { return p.trim(); });
        var hasEmptyParent = parents.some(function (p) { return !currentModalFormState[p]; });
        if (hasEmptyParent) {
          var childInput = body.querySelector('input[name="' + f.name + '"]');
          if (childInput) {
            var comboWrap = childInput.closest('.form-group') || childInput.closest('.df-col-12, .df-col-6, .df-col-4');
            if (comboWrap) {
              var allInps = comboWrap.querySelectorAll('input:not([type="hidden"]), select, textarea, button');
              allInps.forEach(function (el) { el.disabled = true; });
              comboWrap.classList.add('ui-input-disabled');
            }
          }
        }
      }
    });

    // Lắng nghe sự kiện thay đổi để xử lý Phụ thuộc (Dependencies)
    body.addEventListener('change', function (e) {
      var changedName = e.target.name;
      if (changedName) {
        var val = e.target.value;
        var field = globalFormSchema.find(function (f) { return f.name === changedName; });
        if (field && (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn')) {
          val = val.replace(/\D/g, '');
        }
        currentModalFormState[changedName] = val;

        // 1. Tính toán giá trị tự động (FormulaRule)
        globalFormSchema.forEach(function (f) {
          if (f.formulaRule) {
            var formula = f.formulaRule;
            for (var key in currentModalFormState) {
              var valStr = String(currentModalFormState[key] || '');
              var isMoneyKey = globalFormSchema.some(function (schemaField) {
                return schemaField.name === key && (schemaField.renderRule === 'money' || schemaField.renderRule === 'm' || schemaField.renderRule === 'mn');
              });
              var v = 0;
              if (isMoneyKey) {
                v = parseFloat(valStr.replace(/\D/g, '')) || 0;
              } else {
                v = parseFloat(valStr) || 0;
              }
              formula = formula.split('{' + key + '}').join(v);
            }
            try {
              var result = new Function('return ' + formula)();
              if (!isNaN(result) && isFinite(result)) {
                var targetInput = body.querySelector('input[name="' + f.name + '"]');
                if (targetInput) {
                  var isMoneyTarget = (f.renderRule === 'money' || f.renderRule === 'm' || f.renderRule === 'mn');
                  var currentRaw = isMoneyTarget ? targetInput.value.replace(/\D/g, '') : targetInput.value;
                  var targetRaw = isMoneyTarget ? String(result).replace(/\D/g, '') : String(result);
                  if (currentRaw !== targetRaw) {
                    targetInput.value = result;
                    currentModalFormState[f.name] = result;
                    targetInput.dispatchEvent(new Event('change', { bubbles: true }));
                  }
                }
              }
            } catch (e) { }
          }
        });

        // 2. Trigger API (Gọi API ngoài)
        var changedSchema = globalFormSchema.find(function (s) { return s.name.toLowerCase() === changedName.toLowerCase(); });
        if (changedSchema && changedSchema.triggerApi && e.target.value) {
          var apiEndpoint = changedSchema.triggerApi;
          var payload = Object.assign({}, currentModalFormState);

          // Trích xuất các tham số từ URL query string (ví dụ: List, Func) và đưa vào payload body
          if (apiEndpoint.indexOf('?') > -1) {
            var parts = apiEndpoint.split('?');
            var searchParams = new URLSearchParams(parts[1]);
            searchParams.forEach(function (value, key) {
              payload[key] = value;
            });
          }

          payload.JsonData = JSON.stringify(currentModalFormState);

          ApiClient.post(apiEndpoint, payload).then(function (res) {
            var dataList = res.list || res.records || [];
            if (dataList && dataList.length > 0) {
              var row = dataList[0];
              Object.keys(row).forEach(function (keyName) {
                var targetInput = body.querySelector('[name="' + keyName + '" i]');
                if (targetInput && targetInput.value !== (row[keyName] || '')) {
                  targetInput.value = row[keyName] || '';
                  targetInput.dispatchEvent(new Event('change', { bubbles: true }));
                }
              });
            }
          }).catch(function () { });
        }

        // 3. Tìm các trường phụ thuộc vào trường vừa đổi (DependsOn)
        globalFormSchema.forEach(function (f) {
          if (f.dependsOn) {
            var parents = f.dependsOn.split(',').map(function (p) { return p.trim(); });
            if (parents.includes(changedName)) {
              currentModalFormState[f.name] = ''; // Reset state
              var childInput = body.querySelector('input[name="' + f.name + '"]');
              if (childInput) {
                childInput.value = ''; // Xóa value ẩn
                // Xóa luôn giá trị hiển thị trên màn hình nếu là combobox
                var comboWrap = childInput.closest('.form-group') || childInput.closest('.df-col-12, .df-col-6, .df-col-4');
                if (comboWrap) {
                  var displayInp = comboWrap.querySelector('input.ui-input');
                  if (displayInp) displayInp.value = '';

                  // Khóa/Mở khóa ô con dựa trên việc CÓ BẤT KỲ ô cha nào đang trống hay không
                  var hasEmptyParent = parents.some(function (p) { return !currentModalFormState[p]; });
                  var allInps = comboWrap.querySelectorAll('input:not([type="hidden"]), select, textarea, button');
                  allInps.forEach(function (el) { el.disabled = hasEmptyParent; });

                  if (hasEmptyParent) comboWrap.classList.add('ui-input-disabled');
                  else comboWrap.classList.remove('ui-input-disabled');
                }
                // Kích hoạt tiếp sự kiện change của thằng con để trigger chuỗi phụ thuộc (nếu có thằng cháu)
                childInput.dispatchEvent(new Event('change', { bubbles: true }));
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

    var modalWidth = MODULE_CONFIG.ModalWidth || '850px';
    var hasJsonField = formSchema.some(function (f) {
      var isVisible = isEdit ? f.showInEdit : f.showInAdd;
      return (String(isVisible) === '1' || isVisible === true) && (f.renderRule === 'json' || f.renderRule === 'js');
    });

    if (hasJsonField) {
      modalWidth = '1300px';
    }

    var modal = UIModal.show({
      title: isEdit ? MODULE_CONFIG.TitleEdit : MODULE_CONFIG.TitleAdd,
      width: modalWidth,
      content: body,
      footer: footer
    });

    btnCancel.onclick = function () { modal.close(); };
    btnSave.onclick = function () {
      _saveData(isEdit, row, modal, body, btnSave);
    };

    // Kích hoạt Trigger API ban đầu cho các trường có giá trị sẵn khi mở Form (nhất là trường hợp Sửa nhưng trường đích bị trống)
    globalFormSchema.forEach(function (f) {
      if (f.triggerApi && currentModalFormState[f.name]) {
        var el = body.querySelector('[name="' + f.name + '"]');
        if (el) {
          setTimeout(function () {
            el.dispatchEvent(new Event('change', { bubbles: true }));
          }, 150);
        }
      }
    });

    // Kích hoạt các FormPlugins toàn cục (nếu có)
    if (window.FormPlugins) {
      window.FormPlugins.forEach(function (plugin) {
        if (typeof plugin.onInitModal === 'function') {
          plugin.onInitModal(MODULE_CONFIG.FormName, isEdit, modal.node, row, MODULE_CONFIG);
        }
      });
    }

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
          var field = globalFormSchema.find(function (f) { return f.name === fieldName; });
          if (field && (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn')) {
            val = val.replace(/\D/g, '');
          }
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
    var finalPayloads = payloads;
    if (endpoint === '/api/API_Gateway_Router') {
      finalPayloads = payloads.map(function (p) {
        return {
          List: MODULE_CONFIG.FormName,
          Func: 'Save',
          JsonData: JSON.stringify(p)
        };
      });
    }

    _sendSequential(
      endpoint,
      finalPayloads,
      function (count) {             // onDone
        modal.closeNow();
        Alert.success('Thành công', 'Đã lưu xong ' + count + ' dòng!');
        if (!isAdd) selectedRows = [];
        if (_isFormBuilder()) {
          window._uiConfigCache = {};
          $container.innerHTML = '';
          render($container, MODULE_CONFIG);
        } else {
          _updateSelectionCounter();
          _loadData();
        }
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
        var val = el.value.trim();
        var field = globalFormSchema.find(function (f) { return f.name === el.name; });
        if (field && (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn')) {
          val = val.replace(/\D/g, '');
        }
        formInputData[el.name] = val;
      }
    });

    // 2. Validate Required và ValidateRule
    var isInvalid = false;
    for (var i = 0; i < globalFormSchema.length; i++) {
      var field = globalFormSchema[i];
      var val = formInputData[field.name];
      var isJsonField = (field.renderRule === 'json' || field.renderRule === 'js');
      var isEmptyJson = false;
      if (isJsonField) {
        if (!val || val === '[]' || val === 'null' || val === '{}') {
          isEmptyJson = true;
        }
      }
      if (field.required && (!val || isEmptyJson)) {
        Alert.warning(MODULE_CONFIG.WarnMissingInfo, MODULE_CONFIG.WarnMissingInput.replace('{0}', field.label));
        isInvalid = true;
        break;
      }
      if (val && field.validateRule) {
        var rules = field.validateRule.split('|').map(function (r) { return r.trim(); });
        for (var j = 0; j < rules.length; j++) {
          var rawRule = rules[j];
          var rule = rawRule.toLowerCase();
          if (!rule || rule.startsWith('formula:') || rule.startsWith('trigger:')) continue;

          if (rule.startsWith('min:')) {
            var min = parseInt(rule.split(':')[1]);
            if (val.length < min) { Alert.warning('Lỗi nhập liệu', field.label + ' phải có ít nhất ' + min + ' ký tự'); isInvalid = true; break; }
          } else if (rule.startsWith('max:')) {
            var max = parseInt(rule.split(':')[1]);
            if (val.length > max) { Alert.warning('Lỗi nhập liệu', field.label + ' không được vượt quá ' + max + ' ký tự'); isInvalid = true; break; }
          } else if (rule === 'email') {
            var emailRe = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
            if (!emailRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng Email'); isInvalid = true; break; }
          } else if (rule === 'phone') {
            var phoneRe = /(03|05|07|08|09|01[2|6|8|9])+([0-9]{8})\b/;
            if (!phoneRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng số điện thoại'); isInvalid = true; break; }
          } else if (rule === 'number') {
            var numRe = /^\d+$/;
            if (!numRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' chỉ được phép nhập số'); isInvalid = true; break; }
          } else if (rule === 'cccd') {
            var cccdRe = /^\d{9}(\d{3})?$/;
            if (!cccdRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' phải là 9 hoặc 12 số (CMND/CCCD)'); isInvalid = true; break; }
          } else if (rule === 'url') {
            var urlRe = /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/;
            if (!urlRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng đường dẫn trang web'); isInvalid = true; break; }
          } else if (rule === 'taxcode') {
            var taxRe = /^\d{10}(-\d{3})?$/;
            if (!taxRe.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' phải là 10 hoặc 13 số (Mã số thuế)'); isInvalid = true; break; }
          } else if (rule.startsWith('minval:')) {
            var minVal = parseFloat(rule.split(':')[1]);
            if (parseFloat(val) < minVal) { Alert.warning('Lỗi nhập liệu', field.label + ' phải lớn hơn hoặc bằng ' + minVal); isInvalid = true; break; }
          } else if (rule.startsWith('maxval:')) {
            var maxVal = parseFloat(rule.split(':')[1]);
            if (parseFloat(val) > maxVal) { Alert.warning('Lỗi nhập liệu', field.label + ' phải nhỏ hơn hoặc bằng ' + maxVal); isInvalid = true; break; }
          } else if (rule.startsWith('regex:')) {
            var reStr = rawRule.substring(6); // Dùng rawRule để không bị mất chữ Hoa/Thường của Regex
            try {
              var re = new RegExp(reStr);
              if (!re.test(val)) { Alert.warning('Lỗi nhập liệu', field.label + ' không đúng định dạng yêu cầu'); isInvalid = true; break; }
            } catch (e) { console.error('Lỗi Regex:', e); }
          } else if (rule.startsWith('gt:')) {
            var tF = rule.split(':')[1];
            if (formInputData[tF] && parseFloat(val) <= parseFloat(formInputData[tF])) { Alert.warning('Lỗi nhập liệu', field.label + ' phải lớn hơn ô liên quan'); isInvalid = true; break; }
          } else if (rule.startsWith('lt:')) {
            var tF = rule.split(':')[1];
            if (formInputData[tF] && parseFloat(val) >= parseFloat(formInputData[tF])) { Alert.warning('Lỗi nhập liệu', field.label + ' phải nhỏ hơn ô liên quan'); isInvalid = true; break; }
          } else if (rule.startsWith('gte:')) {
            var tF = rule.split(':')[1];
            if (formInputData[tF] && parseFloat(val) < parseFloat(formInputData[tF])) { Alert.warning('Lỗi nhập liệu', field.label + ' phải lớn hơn hoặc bằng ô liên quan'); isInvalid = true; break; }
          } else if (rule.startsWith('lte:')) {
            var tF = rule.split(':')[1];
            if (formInputData[tF] && parseFloat(val) > parseFloat(formInputData[tF])) { Alert.warning('Lỗi nhập liệu', field.label + ' phải nhỏ hơn hoặc bằng ô liên quan'); isInvalid = true; break; }
          }
        }
        if (isInvalid) break;
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
    var finalPayload = payloads[0];
    if (endpoint === '/api/API_Gateway_Router') {
      finalPayload = {
        List: MODULE_CONFIG.FormName,
        Func: 'Save',
        JsonData: JSON.stringify(payloads[0])
      };
    }
    ApiClient.post(endpoint, finalPayload)
      .then(function (res) {
        if (res && res.code === 0) {
          // Check DB level validation success
          var isDbSuccess = true;
          var dbMsg = '';

          if (res.Success !== undefined && (String(res.Success) === '0' || res.Success === false)) {
            isDbSuccess = false;
            dbMsg = res.Message || res.msg || MODULE_CONFIG.AlertSaveFailed;
          } else if (res.records && res.records.length > 0) {
            var firstRec = res.records[0];
            if (firstRec.Success !== undefined && (String(firstRec.Success) === '0' || firstRec.Success === false)) {
              isDbSuccess = false;
              dbMsg = firstRec.Message || firstRec.msg || res.Message || MODULE_CONFIG.AlertSaveFailed;
            }
          }

          if (!isDbSuccess) {
            Alert.error(MODULE_CONFIG.AlertTitleError, dbMsg);
            _restoreSaveBtn();
            return;
          }

          UIToast.show(isEdit ? MODULE_CONFIG.ToastEdit : MODULE_CONFIG.ToastAdd, 'success');
          modal.closeNow();
          if (_isFormBuilder()) {
            window._uiConfigCache = {}; // Cache Invalidate
            selectedRows = [];
            $container.innerHTML = '';
            render($container, MODULE_CONFIG);
          } else {
            selectedRows = [];
            _updateSelectionCounter();
            _loadData();
          }
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

  window.openQuickAddModal = function (formName, onSaved) {
    var dictionaryUrl = '/api/API_Gateway_Router';
    var detailUrl = '/api/API_Gateway_Router';
    
    var dictPayload = { List: 'SY_Dictionary', Func: 'View', UserName: 'Admin', Page: 1, Limit: 1000 };
    var schemaPayload = { List: 'SY_FormatFields', Func: 'View', UserName: 'Admin', Page: 1, Limit: 1000, Keyword: formName };
    
    Promise.all([
      ApiClient.post(dictionaryUrl, dictPayload).catch(function () { return { records: [] }; }),
      ApiClient.post(detailUrl, schemaPayload).catch(function () { return { records: [] }; })
    ]).then(function (results) {
      var dictRes = results[0];
      var schemaRes = results[1];
      
      var dictionary = {};
      (dictRes.records || []).forEach(function (d) {
        dictionary[d.FieldName] = d;
      });
      
      var rawSchema = (schemaRes.records || []).filter(function (f) {
        return f.FormName === formName;
      });
      
      if (rawSchema.length === 0) {
        Alert.error('Lỗi', 'Không tìm thấy cấu hình trường cho form: ' + formName);
        return;
      }
      
      var formSchema = rawSchema.map(function (f) {
        return {
          name: f.FieldName,
          label: f.CaptionVN || f.FieldName,
          required: _bool(f.IsRequired, f.isRequired),
          renderRule: (f.FormatID || '').toLowerCase(),
          dataSource: f.DataSource,
          position: f.FormPosition || '6',
          showInAdd: _bool(f.ShowInAdd, f.showInAdd),
          showInEdit: _bool(f.ShowInEdit, f.showInEdit),
          orderNo: f.OrderNo || 0,
          value: ''
        };
      });
      
      formSchema.sort(function (a, b) { return (a.orderNo || 0) - (b.orderNo || 0); });
      
      var body = document.createElement('div');
      body.style.display = 'flex';
      body.style.flexDirection = 'column';
      body.style.gap = '14px';
      
      var grid = document.createElement('div');
      grid.style.display = 'flex';
      grid.style.flexWrap = 'wrap';
      grid.style.gap = '12px 10px';
      body.appendChild(grid);
      
      var currentModalFormState = {};
      
      formSchema.forEach(function (field) {
        if (!field.showInAdd) {
          var hiddenEl = document.createElement('input');
          hiddenEl.type = 'hidden';
          hiddenEl.name = field.name;
          hiddenEl.value = '';
          body.appendChild(hiddenEl);
          return;
        }
        
        var inputEl;
        if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
          inputEl = UIInput.createSwitch(field);
        } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
          inputEl = UIInput.createDate(field);
        } else if (field.renderRule === 'tm' || field.renderRule === 'time') {
          inputEl = UIInput.createTime(field);
        } else if ((field.renderRule === 'sl' || field.renderRule === 'sr' || field.renderRule === 'select' || field.renderRule === 'ml') && field.dataSource) {
          var formGroupWrapper = document.createElement('div');
          formGroupWrapper.className = 'form-group';
          if (field.label) {
            var lbl = document.createElement('label');
            lbl.innerText = field.label;
            formGroupWrapper.appendChild(lbl);
          }
          var hiddenInput = document.createElement('input');
          hiddenInput.type = 'hidden';
          hiddenInput.name = field.name;
          formGroupWrapper.appendChild(hiddenInput);
          
          var staticCombo = UIControls.createDataComboBox({
            placeholder: '-- Chọn --',
            headers: ['Mã', 'Tên'],
            data: [],
            getValue: function () { return hiddenInput.value; },
            onSelect: function (r) { hiddenInput.value = r[0]; }
          });
          formGroupWrapper.appendChild(staticCombo);
          inputEl = formGroupWrapper;
        } else if (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn') {
          inputEl = UIInput.createMoney(field);
        } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
          inputEl = UIInput.createNumber(field);
        } else {
          inputEl = UIInput.createText(field);
        }
        
        var span = String(field.position || '6');
        if (!['12', '8', '6', '4', '3', '2'].includes(span)) span = '6';
        
        var wrapper = document.createElement('div');
        wrapper.className = 'df-col-' + span;
        wrapper.appendChild(inputEl);
        grid.appendChild(wrapper);
        
        currentModalFormState[field.name] = '';
      });
      
      var footer = document.createElement('div');
      footer.style.display = 'flex';
      footer.style.gap = '10px';
      
      var btnCancel = document.createElement('button');
      btnCancel.className = 'btn btn-outline';
      btnCancel.textContent = 'Hủy Bỏ';
      
      var btnSave = document.createElement('button');
      btnSave.className = 'btn btn-primary';
      btnSave.textContent = 'Lưu Lại';
      
      footer.appendChild(btnCancel);
      footer.appendChild(btnSave);
      
      var titleCaption = (dictRes.records && dictRes.records.find(function(d) { return d.FieldName === formName; }))?.CaptionVN || formName;
      var modal = UIModal.show({
        title: 'Thêm nhanh: ' + titleCaption,
        width: '800px',
        content: body,
        footer: footer
      });
      
      btnCancel.onclick = function () { modal.close(); };
      btnSave.onclick = function () {
        btnSave.disabled = true;
        btnSave.textContent = 'Đang lưu...';
        
        var payload = {};
        var inputs = body.querySelectorAll('input, select, textarea');
        inputs.forEach(function (el) {
          if (el.name) {
            var val = el.value.trim();
            var field = formSchema.find(function (f) { return f.name === el.name; });
            if (field && (field.renderRule === 'money' || field.renderRule === 'm' || field.renderRule === 'mn')) {
              val = val.replace(/\D/g, '');
            }
            payload[el.name] = val;
          }
        });
        
        var savePayload = {
          List: formName,
          Func: 'Save',
          JsonData: JSON.stringify(payload)
        };
        
        ApiClient.post('/api/API_Gateway_Router', savePayload).then(function (saveRes) {
          if (saveRes && saveRes.code === 0) {
            var firstRec = saveRes.records && saveRes.records[0];
            if (firstRec && (firstRec.Success === false || String(firstRec.Success) === '0')) {
              Alert.error('Lỗi', firstRec.Message || 'Lưu dữ liệu thất bại');
              btnSave.disabled = false;
              btnSave.textContent = 'Lưu Lại';
            } else {
              modal.closeNow();
              UIToast.show('Thêm mới thành công!', 'success');
              if (typeof onSaved === 'function') {
                var keys = Object.keys(payload);
                if (firstRec && firstRec.DocumentID) {
                  payload[keys[0]] = firstRec.DocumentID;
                }
                onSaved(payload);
              }
            }
          } else {
            Alert.error('Lỗi', (saveRes && saveRes.msg) || 'Lưu thất bại');
            btnSave.disabled = false;
            btnSave.textContent = 'Lưu Lại';
          }
        }).catch(function (err) {
          console.error(err);
          Alert.error('Lỗi', 'Không thể kết nối đến máy chủ');
          btnSave.disabled = false;
          btnSave.textContent = 'Lưu Lại';
        });
      };
    }).catch(function (err) {
      console.error(err);
      Alert.error('Lỗi', 'Không thể tải cấu hình thêm nhanh');
    });
  };

  return { render: render };
})();
