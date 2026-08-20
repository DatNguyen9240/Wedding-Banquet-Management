/**
 * Dynamic Form Engine - Generic Metadata-Driven UI Engine
 */
window.DynamicFormEngine = (function () {

  var $container = null;
  var gridData = [];
  var selectedRows = [];
  var lastSelectedIdx = -1;
  var activeGridApi = null;

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
    return u.UserGroupID || u.userGroupID || u.Group || u.GroupUser || u.GroupID || u.group || u.NhomQuyen || 'Admin';
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
  function _bool(v) {
    return String(v) === '1' || v === true || String(v).toLowerCase() === 'true';
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

  /** Ánh xạ FormatID từ DB (ví dụ: D, H, F, B, S, U, N) sang renderRule tiêu chuẩn của Frontend */
  function _mapRenderRule(formatId) {
    var fid = String(formatId || '').toUpperCase().trim();
    if (fid) {
      if (fid === 'D') return 'dt'; // Date Format
      if (fid === 'H') return 'tm'; // Time Format
      if (fid === 'F') return 'sw'; // Bit/Switch
      if (['B', 'S', 'U'].includes(fid)) return 'mn'; // BaseAmount, SourceAmount, UnitPrice -> money
      if (['1D', '2D', '3D', '4D', '5D', '6D', 'BU', 'N', 'N0', 'N1', 'N2', 'N3', 'N4', 'N5', 'N6', 'P', 'P1', 'P2', 'PN', 'Q', 'Y'].includes(fid)) return 'n'; // numbers
      return fid.toLowerCase();
    }
    // Tự động phân loại theo kiểu dữ liệu gốc nếu không cấu hình FormatID
    return '';
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

  function _applyFieldConstraints(inputEl, field) {
    var controls = [];
    if (['INPUT', 'SELECT', 'TEXTAREA'].includes(inputEl.tagName)) controls.push(inputEl);
    controls = controls.concat(Array.prototype.slice.call(inputEl.querySelectorAll ? inputEl.querySelectorAll('input, select, textarea') : []));

    controls.forEach(function (control) {
      if (field.maxLength !== null && field.maxLength !== undefined && Number(field.maxLength) > 0) {
        control.maxLength = Number(field.maxLength);
      }
      if (field.minValue !== null && field.minValue !== undefined && field.minValue !== '') control.min = field.minValue;
      if (field.maxValue !== null && field.maxValue !== undefined && field.maxValue !== '') control.max = field.maxValue;
      if (field.maskString && control.tagName === 'INPUT') control.pattern = field.maskString;
      if (field.numberDecimal !== null && field.numberDecimal !== undefined && control.type === 'number') {
        var decimals = Number(field.numberDecimal);
        control.step = decimals > 0 ? ('0.' + '0'.repeat(decimals - 1) + '1') : '1';
      }
      if (field.dropdownIsDisable) control.disabled = true;
    });
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
    var currentUser = _currentUser();
    p.UserName = currentUser;
    if (isEdit) {
      p.UserUpdate = currentUser;
      delete p.UserCreate;
    } else {
      p.UserCreate = currentUser;
      delete p.UserUpdate;
    }
    p.IsEdit = isEdit ? 1 : 0;
    return p;
  }

  function _hasPermission(action) {
    // Dynamic menu forms receive their effective user permission together
    // with the menu row. This avoids looking up a permission by DataSource
    // (a table/view name), which is not the permission key.
    if (action === 'ADD' && MODULE_CONFIG.UserCanAdd !== undefined) return MODULE_CONFIG.UserCanAdd === true;
    if (action === 'EDIT' && MODULE_CONFIG.UserCanEdit !== undefined) return MODULE_CONFIG.UserCanEdit === true;
    if (action === 'DELETE' && MODULE_CONFIG.UserCanDelete !== undefined) return MODULE_CONFIG.UserCanDelete === true;

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
    if (action === 'PRINT') return !!modulePerm.CanPrint;
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
      };
    }

    $container = container;
    MODULE_CONFIG = config;
    MODULE_CONFIG.HideFilterBtn = true;
    currentFormName = config.FormName;

    // Hiển thị skeleton loader ban đầu trong lúc tải cấu hình form (metadata)
    container.innerHTML = typeof UISkeleton !== 'undefined'
      ? UISkeleton.createHTML({ type: 'table', rows: 8, cols: 8 })
      : '<div class="p-4 text-center" style="color:var(--color-text-secondary);">Đang tải dữ liệu...</div>';

    // 2. Khôi phục state của module mới (nếu đã từng vào trước đó)
    var savedState = moduleStates[currentFormName];
    if (savedState) {
      currentKeyword = savedState.keyword;
      currentSortCol = savedState.sortCol;
      currentSortDir = savedState.sortDir;
      currentPage = savedState.page;
    } else {
      // Nếu chưa từng vào thì reset về mặc định
      currentKeyword = '';
      currentSortCol = '';
      currentSortDir = '';
      currentPage = 1;
    }

    // Reset sạch sẽ Dictionary & Schema của Form cũ để tránh lây nhiễm (ví dụ API form mới bị lỗi thì không hiện rác của form cũ)
    globalDictionary = {};
    globalFormSchema = [];
    globalRenderers = {};

    // API defaults: CRUD trực tiếp theo bảng vật lý và metadata chuẩn.
    _setDefaults(MODULE_CONFIG, {
      ApiSearch: '/api/API_TruyVanForm',
      ApiSave: '/api/API_LuuForm',
      ApiDelete: '/api/API_XoaForm'
    });
    _setDefaults(MODULE_CONFIG, { ApiDictionary: '/api/API_LoadFormMeta' });

    _loadSelectedRows();


    // 1. Lấy Từ điển UI từ Database trước (Cơ chế Caching siêu tốc)
    var configEndpoint = MODULE_CONFIG.ApiDictionary;
    var cacheKey = 'FormConfigCache_' + MODULE_CONFIG.FormName;
    var cachedData = null;

    // RAM Cache cho giao diện
    try { cachedData = window._uiConfigCache ? window._uiConfigCache[cacheKey] : null; } catch (e) { }

    var pConfig;
    if (cachedData) {
      pConfig = Promise.resolve(JSON.parse(cachedData));
    } else {
      pConfig = configEndpoint ? ApiClient.post(configEndpoint, { FormName: MODULE_CONFIG.FormName }).then(function (res) {
        if (res && res.code === 0) {
          window._uiConfigCache = window._uiConfigCache || {};
          window._uiConfigCache[cacheKey] = JSON.stringify(res);
        }
        return res;
      }) : Promise.resolve(null);
    }

    pConfig.then(function (resConfig) {

      // 2. Lưu Từ điển vào biến toàn cục
      var dataList = resConfig ? (resConfig.list || resConfig.records) : null;
      if (!resConfig || resConfig.code !== 0 || !Array.isArray(dataList) || dataList.length === 0) {
        var metadataError = (resConfig && (resConfig.msg || resConfig.message)) || 'Metadata form khong hop le hoac chua duoc dong bo.';
        console.error('Metadata loading failed for', MODULE_CONFIG.FormName, metadataError);
        $container.innerHTML = '<div class="p-4 text-danger">' + (MODULE_CONFIG.TextLoadingError || '') + metadataError + '</div>';
        return;
      }

      {

        // --- NO-CODE MAGIC: Đọc cấu hình cấp Form từ Record đầu tiên ---
        if (dataList.length > 0) {
          var firstRow = dataList[0];

          // Map API fields → MODULE_CONFIG (chỉ ghi nếu API trả về giá trị)
          var _rowMap = {
            primaryKey: 'PrimaryKey',
            hidePrintBtn: 'HidePrintBtn'
          };
          Object.keys(_rowMap).forEach(function (src) {
            if (firstRow[src] !== undefined && firstRow[src] !== null) MODULE_CONFIG[_rowMap[src]] = firstRow[src];
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
            ModalWidth: '850px',
            TextLoading: 'Đang tải dữ liệu...',
            TextLoadingError: 'Lỗi tải dữ liệu: '
          });
        }

        dataList.forEach(function (item) {
          // Xây Dictionary cho Table
          globalDictionary[item.name] = item.label;


          // Xây dựng Custom Renderers Động từ cấu hình DB (tránh đè logic JSON của UITable)
          if (item.renderRule) {
            var mappedRule = _mapRenderRule(item.renderRule);
            var outerRule = mappedRule.toLowerCase();
            var outerNameLower = (item.name || '').toLowerCase();

            globalRenderers[item.name] = function (v) {
              var rule = outerRule;
              var nameLower = outerNameLower;

              // Định dạng cho trường JSON để hiển thị text sạch đẹp trên Grid
              if (rule === 'js') {
                if (!v) return '';
                try {
                  var arr = typeof v === 'string' ? JSON.parse(v) : v;
                  if (Array.isArray(arr)) {
                    return arr.map(function (row) {
                      return Object.keys(row).map(function (k) { return row[k]; }).filter(Boolean).join(' - ');
                    }).join(' | ');
                  }
                } catch (e) { }
                return v;
              }

              // Các rule là boolean/switch
              if (rule === 'sw') {
                var isChecked = (String(v) === '1' || String(v).toLowerCase() === 'true');
                return isChecked
                  ? '<span style="color:var(--color-success);"><span class="material-symbols-outlined" style="font-size:18px;vertical-align:middle;">check_circle</span></span>'
                  : '<span style="color:var(--color-text-tertiary);">-</span>';
              }

              // Danh sách chọn tĩnh (STATIC) -> Hiển thị Tên thay vì Mã trên Grid
              if (item.dropdownType === 'STATIC' || (item.dataSource && item.dataSource.toUpperCase().startsWith('STATIC:'))) {
                var staticStr = item.dataSource;
                if (staticStr.toUpperCase().startsWith('STATIC:')) {
                  staticStr = staticStr.substring(7);
                }
                var staticData = staticStr.split(',').map(function (s) {
                  var parts = s.split('|');
                  return { value: parts[0], text: parts[1] || parts[0] };
                });
                var matched = staticData.find(function (x) { return String(x.value) === String(v); });
                if (matched) return matched.text;
              }

              // Định dạng tiền / số Việt Nam (dấu chấm phân tách, hover hiện chữ tiếng Việt có dấu)
              if (rule === 'mn' || rule === 'n') {
                if (v === null || v === undefined || v === '') return '';
                var num = Number(v);
                if (isNaN(num)) return v;
                var formatted = typeof FormatUtils !== 'undefined' ? FormatUtils.number(num) : num.toLocaleString('vi-VN');
                var words = typeof FormatUtils !== 'undefined' && typeof FormatUtils.docSoTienVN === 'function'
                  ? FormatUtils.docSoTienVN(num)
                  : (typeof UIControls !== 'undefined' && typeof UIControls.docSoTienVN === 'function' ? UIControls.docSoTienVN(num) : '');
                if (words) {
                  words = words.charAt(0).toUpperCase() + words.slice(1);
                  // Bỏ chữ "đồng" nếu là số thường (rule === 'n')
                  if (rule === 'n' && words.endsWith(' đồng')) {
                    words = words.substring(0, words.length - 5);
                  }
                  return '<span title="' + words + '">' + formatted + '</span>';
                }
                return '<span>' + formatted + '</span>';
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
            globalRenderers[item.name].renderRule = outerRule;
          }

          // Xây Schema cho Form
          globalFormSchema.push({
            name: item.name,
            label: item.label,
            required: _bool(item.required),
            showInAdd: _bool(item.showInAdd),
            showInEdit: _bool(item.showInEdit),
            showInFilter: _bool(item.showInFilter),
            showInGrid: _bool(item.showInGrid),
            isReadOnlyEdit: _bool(item.isReadOnlyEdit),
            isReadOnlyAdd: _bool(item.isReadOnlyAdd),
            position: item.position,
            orderNo: item.orderNo,
            renderRule: _mapRenderRule(item.renderRule),
            dataSource: item.dataSource,
            dataType: item.dataType,
            formatId: item.formatId,
            formatName: item.formatName,
            formatString: item.formatString,
            maskString: item.maskString,
            numberDecimal: item.numberDecimal,
            maxLength: item.maxLength,
            minValue: item.minValue,
            maxValue: item.maxValue,
            align: item.align,
            minWidth: item.minWidth,
            maxWidth: item.maxWidth,
            defaultValue: item.defaultValue,
            dropdownLinkColumn: item.dropdownLinkColumn,
            dropdownParaArr: item.dropdownParaArr,
            dropdownParaRequireArr: item.dropdownParaRequireArr,
            dropdownKeepValue: _bool(item.dropdownKeepValue),
            dropdownFilterColumn: item.dropdownFilterColumn,
            dropdownFilterValue: item.dropdownFilterValue,
            dropdownOnlyFilterValue: item.dropdownOnlyFilterValue,
            dropdownManualSearch: _bool(item.dropdownManualSearch),
            dropdownManualOrderBy: item.dropdownManualOrderBy,
            dropdownIsReload: _bool(item.dropdownIsReload),
            dropdownEditableColumns: item.dropdownEditableColumns,
            dropdownIsDisable: _bool(item.dropdownIsDisable),
            dropdownCaption: item.dropdownCaption,
            dropdownIsWordWrap: _bool(item.dropdownIsWordWrap),
            dropdownIsMultiValue: _bool(item.dropdownIsMultiValue),
            dropdownGroupCaption: item.dropdownGroupCaption,
            dropdownGroupColumnArr: item.dropdownGroupColumnArr,
            dropdownDisplayMember2: item.dropdownDisplayMember2,
            dropdownTreeViewColumn: item.dropdownTreeViewColumn,
            dropdownTreeViewColumnParent: item.dropdownTreeViewColumnParent,
            dropdownReloadType: item.dropdownReloadType,
            dropdownEditType: item.dropdownEditType,
            dropdownTriggerOnOpenForm: _bool(item.dropdownTriggerOnOpenForm),

            // Thêm các cấu hình Dropdown mới từ SY_FrmDrdwTbl
            dropdownType: item.dropdownType,
            dropdownValueColumn: item.dropdownValueColumn,
            dropdownDisplayColumn: item.dropdownDisplayColumn,
            dropdownColumnArr: item.dropdownColumnArr,
            dropdownWidthArr: item.dropdownWidthArr,
            dropdownIsMultiSelect: _bool(item.dropdownIsMultiSelect),
            dropdownIsNotInList: _bool(item.dropdownIsNotInList),
            dropdownDisableAddNew: _bool(item.dropdownDisableAddNew)
          });
        });

        if (Object.keys(globalDictionary).length === 0) {
          throw new Error('Metadata form khong co field hop le.');
        }

      }
      // Tự động sinh mã HTML (Không cần file .html rời nữa)
      $container.innerHTML = `
        <div id="dynamic-btn-container" style="display:none;"></div>
        <div class="card dynamic-grid-card" style="display: flex; flex-direction: column; height: calc(100vh - 195px); border: none; box-shadow: none; margin-bottom: 0; border-radius: var(--radius-sm); background: var(--color-surface); overflow: hidden;">
          <div class="card-body" style="padding: 0; display: flex; flex-direction: column; flex: 1; min-height: 0;">
            <div id="dynamic-grid-container" style="display: flex; flex-direction: column; flex: 1; min-height: 0;"></div>
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
          onCopy: MODULE_CONFIG.HideAddBtn ? false : (_hasPermission('ADD') ? function () {
            if (!selectedRows || selectedRows.length === 0) return typeof Alert !== 'undefined' ? Alert.warning(MODULE_CONFIG.AlertTitleWarning, 'Vui lòng chọn một dòng để sao chép!') : null;
            if (selectedRows.length > 1) return typeof Alert !== 'undefined' ? Alert.warning(MODULE_CONFIG.AlertTitleWarning, 'Chỉ sao chép được một dòng cùng lúc!') : null;
            _openModal(false, selectedRows[0]);
          } : 'DISABLED'),
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
              var pkField = MODULE_CONFIG.PrimaryKey || 'DocumentID';
              var pkValues = selectedRows.map(function (row) { return row[pkField]; }).filter(Boolean).join(',');

              var payload = {
                FormKey: MODULE_CONFIG.FormID,
                Ids: pkValues,
                UserName: _currentUser()
              };

              // Bơm dữ liệu dòng đầu tiên kèm theo danh sách ID dạng batch (comma separated) để tránh mất các cột Not Null


              var deletePromises = [ApiClient.post(MODULE_CONFIG.ApiDelete, payload)];

              Promise.all(deletePromises).then(function (results) {
                var allSuccess = results.every(function (res) { return res && res.code === 0; });
                if (allSuccess) {
                  if (typeof UIToast !== 'undefined') UIToast.show(MODULE_CONFIG.ToastDelete, 'success');
                  selectedRows = [];

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
          onPrint: (function() {
            var hideVal = MODULE_CONFIG.HidePrintBtn;
            var hide = (hideVal == 1 || hideVal === true || String(hideVal).toLowerCase() === 'true');
            var hasPerm = _hasPermission('PRINT');
            console.log('[DEBUG PRINT BUTTON]', {
              FormName: MODULE_CONFIG.FormName,
              RawHideVal: hideVal,
              ParsedHide: hide,
              HasPrintPermission: hasPerm,
              FinalShow: !(hide || !hasPerm)
            });
            return (hide || !hasPerm) ? false : function () {
              DocumentExportPlugin.generate(selectedRows, MODULE_CONFIG);
            };
          })(),
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
          // Chèn sau nút Thêm (bên trong dropdown menu)
          var btnAddOriginal = toolbar.querySelector('.btn-tool-add');
          if (btnAddOriginal) {
            btnAddOriginal.parentNode.insertBefore(btnBulkAdd, btnAddOriginal.nextSibling);
          } else {
            var menu = toolbar.querySelector('.action-dropdown-menu');
            if (menu) {
              menu.insertBefore(btnBulkAdd, menu.firstChild);
            } else {
              toolbar.insertBefore(btnBulkAdd, toolbar.firstChild);
            }
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
            if (f.renderRule === 'n') filterType = 'number';
            if (f.renderRule === 'tm') filterType = 'time';

            var filterObj = {
              id: f.name,
              label: f.label,
              type: filterType,
              placeholder: f.label
            };

            // Parse DataSource cho trường Select/Dropdown
            if (f.dataSource || f.renderRule === 'sw') {
              filterObj.type = 'select';
              filterObj.options = [];
              if (f.renderRule === 'sw') {
                filterObj.options = [{ value: 1, label: 'Có' }, { value: 0, label: 'Không' }];
              } else if (f.dropdownType === 'STATIC' || f.dataSource.toUpperCase().startsWith('STATIC:')) {
                var staticStr = f.dataSource;
                if (staticStr.toUpperCase().startsWith('STATIC:')) {
                  staticStr = staticStr.substring(7);
                }
                var parts = staticStr.split(',');
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
      if (typeof UISkeleton !== 'undefined') {
        var skeletonCols = [];
        if (Array.isArray(globalFormSchema) && globalFormSchema.length > 0) {
          globalFormSchema.forEach(function (f) {
            var pos = String(f.position || '').trim();
            var isGridPos = (pos === 'grid' || (!isNaN(pos) && pos !== ''));
            if (isGridPos && f.showInGrid !== false && String(f.showInGrid) !== '0' && pos !== 'hidden') {
              skeletonCols.push({ width: '60px' });
            }
          });
        }
        if (skeletonCols.length > 8) {
          skeletonCols = skeletonCols.slice(0, 8);
        } else if (skeletonCols.length === 0) {
          skeletonCols = 8;
        }
        gridContainer.innerHTML = UISkeleton.createTableHTML({
          rows: 8,
          cols: skeletonCols,
          hasHeader: true
        });
      } else {
        gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">' + MODULE_CONFIG.TextLoading + '</div>';
      }
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
        FormKey: MODULE_CONFIG.FormID,
        Page: currentPage,
        Limit: currentLimit,
        SortColumn: currentSortCol || '',
        SortDir: currentSortDir || '',
        Keyword: currentKeyword || ''
      };

      if (Object.keys(activeFilters).length > 0) {
        query.Data = JSON.stringify(activeFilters);
      }
      var searchPromise = ApiClient.post(MODULE_CONFIG.ApiSearch, query);

      searchPromise.then(function (result) {
        // Trả lại quyền sinh sát (tính phân trang) cho C# Backend
        var dataList = typeof MODULE_CONFIG.ExtractSearchRows === 'function'
          ? MODULE_CONFIG.ExtractSearchRows(result)
          : (result.list || result.records || []);
        if (MODULE_CONFIG.IsPaged === false) {
          totalRecords = dataList.length;
          totalPagesFromApi = dataList.length > 0 ? 1 : 0;
        } else {
          totalRecords = result._recordtotal || 0;
          totalPagesFromApi = result._pagetotal || 0;
        }
        lastTimestamp = result._timestamp || '';
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

    if (activeGridApi) {
      if (activeGridApi._observer) activeGridApi._observer.disconnect();
      activeGridApi.destroy();
      activeGridApi = null;
    }

    gridContainer.innerHTML = '';

    var gridDiv = document.createElement('div');
    gridDiv.style.flex = '1';
    gridDiv.style.minHeight = '0';
    gridDiv.style.width = '100%';
    gridContainer.appendChild(gridDiv);

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
      var columnDefs = [];

      Object.keys(dictionary).forEach(function (key) {
        var colDef = {
          field: key,
          headerName: dictionary[key],
          sortable: true,
          filter: true,
          resizable: true
        };

        // Tìm cấu hình trường từ schema metadata
        var fSchema = globalFormSchema.find(function (x) { return x.name === key; });

        // Cấu hình độ rộng cột: Ưu tiên MinWidth/MaxWidth từ metadata
        var colWidth = 150;
        if (fSchema) {
          if (fSchema.minWidth) colWidth = Number(fSchema.minWidth);
          else if (fSchema.maxWidth) colWidth = Number(fSchema.maxWidth);
        }
        colDef.width = colWidth;

        // Căn lề cột
        if (fSchema && fSchema.align) {
          colDef.cellStyle = { textAlign: fSchema.align };
          if (fSchema.align === 'right' || fSchema.align === 'end') colDef.headerClass = 'text-end';
          if (fSchema.align === 'center') colDef.headerClass = 'text-center';
        }

        // Custom Renderers
        if (globalRenderers[key]) {
          colDef.cellRenderer = function (params) {
            var val = params.value;
            return globalRenderers[key](val, key);
          };

          var rule = globalRenderers[key].renderRule;
          if (rule === 'mn' || rule === 'nm' || rule === 'n') {
            colDef.cellStyle = { textAlign: 'right' };
            colDef.headerClass = 'text-end';
          } else if (rule === 'dt') {
            colDef.cellStyle = { textAlign: 'center' };
            colDef.headerClass = 'text-center';
          }
        }

        columnDefs.push(colDef);
      });

      var gridOptions = {
        pagination: false,
        defaultColDef: {
          flex: 0
        },
        columnDefs: columnDefs,
        rowData: gridData,
        rowSelection: 'multiple',
        suppressRowClickSelection: false,
        onSelectionChanged: function (event) {
          selectedRows = event.api.getSelectedRows();
          _updateSelectionCounter();
        },
        onRowDoubleClicked: function (event) {
          var rData = event.data;
          if (!rData) return;

          if (typeof MODULE_CONFIG.onRowDblClick === 'function') {
            MODULE_CONFIG.onRowDblClick(rData);
            return;
          }

          if (MODULE_CONFIG.HideEditBtn) return;

          if (selectedRows.length > 1 && selectedRows.find(function (sr) { return sr.id === rData.id; })) {
            _openBulkEditForm();
          } else {
            _openEditForm(rData);
          }
        }
      };

      activeGridApi = AppGrid.create(gridDiv, gridOptions);

      // Restore selections
      if (selectedRows.length > 0 && activeGridApi) {
        activeGridApi.forEachNode(function (node) {
          if (node.data && selectedRows.some(function (sr) { return sr.id === node.data.id; })) {
            node.setSelected(true);
          }
        });
      }

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
        paginationEl.style.marginTop = 'auto';
        paginationEl.style.paddingTop = '16px';
        gridContainer.appendChild(paginationEl);
      }

      _updateSelectionCounter();
    }
  }

  function _updateSelectionCounter() {
    _saveSelectedRows();

    // Đính kèm thông tin Đã chọn vào Header Info (bên trái tiêu đề trang) để tránh chật thanh Actions
    var headerInfo = document.querySelector('#global-header .page-title-info');
    if (!headerInfo) {
      var globalActions = document.getElementById('global-page-actions');
      headerInfo = globalActions || $container.querySelector('#dynamic-btn-container');
    }
    if (!headerInfo) return;

    var counter = headerInfo.querySelector('#selection-counter');
    if (!counter) {
      if (!document.getElementById('selection-counter-style')) {
        var style = document.createElement('style');
        style.id = 'selection-counter-style';
        style.innerHTML = `
          #selection-counter {
            font-size: 12px;
            font-weight: 600;
            color: var(--color-primary);
            background: var(--color-primary-light, rgba(79, 70, 229, 0.1));
            padding: 4px 10px;
            border-radius: 12px;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            margin-left: 12px;
            align-self: center;
          }
        `;
        document.head.appendChild(style);
      }
      counter = document.createElement('div');
      counter.id = 'selection-counter';
      headerInfo.appendChild(counter);
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
          if (activeGridApi) activeGridApi.deselectAll();
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

    var globalActions = document.getElementById('global-page-actions');
    var btnContainer = globalActions || $container.querySelector('#dynamic-btn-container');
    if (!btnContainer) return;
    var actualToolbar = btnContainer.firstElementChild; // .button-bar
    if (!actualToolbar) return;
    var wrapper = actualToolbar.querySelector('.btn-scroll-wrapper');
    var updateActionbarArrows = function () {
      if (!wrapper) return;
      var scrollLeftBtn = actualToolbar.querySelector('.actionbar-scroll-left');
      var scrollRightBtn = actualToolbar.querySelector('.actionbar-scroll-right');
      if (!scrollLeftBtn || !scrollRightBtn) return;
      var scrollable = wrapper.scrollWidth > wrapper.clientWidth + 15;
      scrollLeftBtn.style.display = (scrollable && wrapper.scrollLeft > 10) ? 'flex' : 'none';
      scrollRightBtn.style.display = (scrollable && wrapper.scrollLeft < wrapper.scrollWidth - wrapper.clientWidth - 10) ? 'flex' : 'none';
    };
    if (typeof updateActionbarArrows === 'function') {
      setTimeout(updateActionbarArrows, 60);
    }
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
    body.className = 'dynamic-form-body';
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
        if (field.renderRule === 'sw') {
          inputEl = UIInput.createSwitch(field);
        } else if (field.renderRule === 'dt') {
          inputEl = UIInput.createDate(field);
        } else if (field.renderRule === 'tm') {
          inputEl = UIInput.createTime(field);
        } else if (field.dataSource) {
          inputEl = document.createElement('div');
          inputEl.className = 'form-group';
          inputEl.style.marginBottom = '0';

          var hiddenInput = document.createElement('input');
          hiddenInput.type = 'hidden';
          hiddenInput.name = field.name;
          var initialValue = field.value || '';
          if (field.dropdownIsMultiSelect && initialValue.startsWith('[')) {
            try {
              var arr = JSON.parse(initialValue);
              if (Array.isArray(arr)) {
                initialValue = arr.map(function (x) { return String(x[field.dropdownValueColumn] || x.id || x.value || x); }).join(',');
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
            if (field.dropdownType === 'STATIC' || String(field.dataSource).toUpperCase().startsWith('STATIC:')) {
              var staticStr = field.dataSource;
              if (staticStr.toUpperCase().startsWith('STATIC:')) {
                staticStr = staticStr.substring(7);
              }
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
              var endpointRaw = field.dataSource;
              if (endpointRaw.indexOf('|') > -1) {
                endpointRaw = endpointRaw.split('|')[0];
              }
              var finalUrl = endpointRaw;
              var fetchPayload = { Limit: 1000 };
              if (endpointRaw.indexOf('?') > -1) {
                var parts = endpointRaw.split('?');
                finalUrl = parts[0];
                var searchParams = new URLSearchParams(parts[1]);
                searchParams.forEach(function (value, key) { fetchPayload[key] = value; });
              } else {
                fetchPayload.FormName = endpointRaw;
              }
              if (!fetchPayload.UserName) fetchPayload.UserName = _currentUser();

              ApiClient.post(finalUrl, fetchPayload).then(function (res) {
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
                    var formIdParam = null;
                    if (targetFormName.includes('|')) {
                      var parts = targetFormName.split('|');
                      targetFormName = parts[0];
                      if (parts[1]) formIdParam = parts[1].trim();
                    }
                    if (targetFormName.includes('?')) {
                      var searchParams = new URLSearchParams(targetFormName.split('?')[1]);
                      formIdParam = formIdParam || searchParams.get('FormID') || searchParams.get('formId') || searchParams.get('FormName') || searchParams.get('formName');
                      var listParam = searchParams.get('List') || searchParams.get('list');
                      if (listParam && !formIdParam) targetFormName = listParam;
                    }
                    if (formIdParam) targetFormName = formIdParam;

                    if (typeof window.openQuickAddModal === 'function') {
                      window.openQuickAddModal(targetFormName, function (newRecord) {
                        if (newRecord) {
                          var endpointRaw = field.dataSource;
                          if (endpointRaw.indexOf('|') > -1) {
                            endpointRaw = endpointRaw.split('|')[0];
                          }
                          var finalUrl = endpointRaw;
                          var fetchPayload = { Limit: 1000 };
                          if (endpointRaw.indexOf('?') > -1) {
                            var parts = endpointRaw.split('?');
                            finalUrl = parts[0];
                            var searchParams = new URLSearchParams(parts[1]);
                            searchParams.forEach(function (value, key) { fetchPayload[key] = value; });
                          } else {
                            fetchPayload.FormName = endpointRaw;
                          }
                          if (!fetchPayload.UserName) fetchPayload.UserName = _currentUser();

                          ApiClient.post(finalUrl, fetchPayload).then(function (res) {
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
        } else if (field.renderRule === 'mn') {
          inputEl = UIInput.createMoney(field);
        } else if (field.renderRule === 'n') {
          inputEl = UIInput.createNumber(field);
        } else if (field.renderRule === 'rb') {
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
      btnAdd.style.cssText = 'margin-top: 8px; display: inline-flex; align-items: center; gap: 4px; font-size: 11px; padding: 4px 10px; height: 28px; width: fit-content; align-self: flex-start;';
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
    grid.className = 'dynamic-form-grid';
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

      // Tự động gán giá trị cũ (nếu đang Sửa hoặc Sao chép 1 dòng).
      if (field.name === MODULE_CONFIG.PrimaryKey && !isEdit) {
        field.value = '';
      } else {
        field.value = row ? _getValueFromRow(row, field.name) : (field.defaultValue == null ? '' : field.defaultValue);
      }

      // Khởi tạo Ô nhập liệu tuỳ thuộc vào quy tắc renderRule
      var inputEl;
      if (field.renderRule === 'sw') {
        inputEl = UIInput.createSwitch(field);
      } else if (field.renderRule === 'dt') {
        inputEl = UIInput.createDate(field);
      } else if (field.renderRule === 'tm') {
        inputEl = UIInput.createTime(field);
      } else if (field.dataSource) {
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
        if (field.dropdownIsMultiSelect && initialValue.startsWith('[')) {
          try {
            var arr = JSON.parse(initialValue);
            if (Array.isArray(arr)) {
              initialValue = arr.map(function (x) { return String(x[field.dropdownValueColumn] || x.id || x.value || x); }).join(',');
            }
          } catch (e) { }
        }
        hiddenInput.value = initialValue;
        formGroupWrapper.appendChild(hiddenInput);

        if (field.dataSource) {
          if (field.dropdownType === 'STATIC' || String(field.dataSource).toUpperCase().startsWith('STATIC:')) {
            var staticStr = field.dataSource;
            if (staticStr.toUpperCase().startsWith('STATIC:')) {
              staticStr = staticStr.substring(7);
            }
            var staticData = staticStr.split(',').map(function (s) {
              var parts = s.split('|');
              return [parts[0], parts[1] || parts[0], parts[2] || ''];
            });

            var lazyStaticCombo = UIControls.createDataComboBox({
              placeholder: '-- Vui lòng chọn --',
              headers: ['Mã', 'Tên'],
              disabled: ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd)),
              readonlyInput: field.dropdownIsMultiSelect || field.dropdownDisableAddNew,
              multiple: field.dropdownIsMultiSelect,
              getValue: function () { return hiddenInput.value; },
              onSearch: function (q, page) {
                return new Promise(function (resolve) {
                  var filtered = staticData;

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
                      if (field.dropdownValueColumn && String(k).toLowerCase() === String(field.dropdownValueColumn).toLowerCase()) {
                        return 'Mã';
                      }
                      if (field.dropdownDisplayColumn && String(k).toLowerCase() === String(field.dropdownDisplayColumn).toLowerCase() && field.dropdownCaption) {
                        return field.dropdownCaption;
                      }
                      var keyLower = k.toLowerCase();
                      if (typeof globalDictionary !== 'undefined') {
                        var foundKey = Object.keys(globalDictionary).find(function (gk) {
                          return gk.toLowerCase() === keyLower;
                        });
                        if (foundKey) {
                          var lbl = globalDictionary[foundKey];
                          if (lbl) {
                            if (typeof lbl === 'object' && lbl.CaptionVN) return lbl.CaptionVN;
                            if (typeof lbl === 'string') return lbl;
                          }
                        }
                      }
                      return k;
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
              showAddNew: !field.dropdownDisableAddNew,
              readonlyInput: field.dropdownIsMultiSelect || field.dropdownDisableAddNew,
              multiple: field.dropdownIsMultiSelect,
              onF2: function () {
                var targetFormName = field.dataSource;
                var formIdParam = null;
                if (targetFormName.includes('|')) {
                  var parts = targetFormName.split('|');
                  targetFormName = parts[0];
                  if (parts[1]) formIdParam = parts[1].trim();
                }
                if (targetFormName.includes('?')) {
                  var searchParams = new URLSearchParams(targetFormName.split('?')[1]);
                  formIdParam = formIdParam || searchParams.get('FormID') || searchParams.get('formId') || searchParams.get('FormName') || searchParams.get('formName');
                  var listParam = searchParams.get('List') || searchParams.get('list');
                  if (listParam && !formIdParam) targetFormName = listParam;
                }
                if (formIdParam) targetFormName = formIdParam;

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
                if (field.dropdownIsMultiSelect) {
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
                  if (field.dropdownIsMultiSelect) {
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
      } else if (field.renderRule === 'mn') {
        inputEl = UIInput.createMoney(field);
      } else if (field.renderRule === 'n') {
        inputEl = UIInput.createNumber(field);
      } else if (field.renderRule === 'js') {
        var isReadOnly = ((isEdit && field.isReadOnlyEdit) || (!isEdit && field.isReadOnlyAdd));
        inputEl = createJsonGridEditor(field, isReadOnly);
      } else if (field.renderRule === 'ta') {
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
      } else if (field.renderRule === 'rb') {
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

      _applyFieldConstraints(inputEl, field);

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
      var span = field.position;
      var wrapper = document.createElement('div');
      if (['12', '8', '6', '4', '3', '2'].includes(span)) {
        wrapper.className = 'df-col-' + span;
      } else {
        wrapper.className = 'df-col-custom';
        var w = span;
        if (!span.endsWith('%') && !span.endsWith('px')) {
          w = span + 'px';
        }
        wrapper.style.width = w;
        wrapper.style.flex = '0 0 ' + w;
        wrapper.style.maxWidth = w;
      }
      if (field.renderRule === 'dt') wrapper.classList.add('df-date-field');

      // Kích thước ô lấy từ MinWidth/MaxWidth trong SY_FmtFldTbl.
      var minFieldWidth = Number(field.minWidth);
      var maxFieldWidth = Number(field.maxWidth);
      if (Number.isFinite(minFieldWidth) && minFieldWidth > 0) {
        wrapper.style.minWidth = minFieldWidth + 'px';
      }
      if (Number.isFinite(maxFieldWidth) && maxFieldWidth > 0) {
        wrapper.style.maxWidth = maxFieldWidth + 'px';
        wrapper.style.flex = '0 1 ' + maxFieldWidth + 'px';
      }
      wrapper.style.boxSizing = 'border-box';


      wrapper.appendChild(inputEl);
      grid.appendChild(wrapper);

      // Gán giá trị mặc định vào currentModalFormState
      var val = field.value || '';
      if (field.renderRule === 'mn') {
        val = String(val).replace(/\D/g, '');
      }
      currentModalFormState[field.name] = val;
    });



    // Helper loại bỏ dấu tiếng Việt để so khớp không dấu
    function removeAccents(str) {
      if (!str) return '';
      return str
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/đ/g, 'd')
        .replace(/Đ/g, 'D')
        .trim();
    }

    function _executeLinkColumnRule(field, val, formContainer, formState) {
      if (!field || !field.dropdownLinkColumn || !formContainer) return;
      var ruleStr = String(field.dropdownLinkColumn).trim();
      if (!ruleStr) return;

      // TH1: Trigger Động qua API / Stored Procedure (api:API_Name)
      if (ruleStr.toLowerCase().indexOf('api:') === 0) {
        var apiName = ruleStr.substring(4).trim();
        var payloadData = Object.assign({}, formState || {});
        payloadData[field.name] = val;

        ApiClient.post('/api/API_Gateway_Router', {
          List: apiName,
          Func: 'View',
          JsonData: JSON.stringify(payloadData)
        }).then(function (res) {
          if (res && res.records && res.records.length > 0) {
            var returnData = res.records[0];
            Object.keys(returnData).forEach(function (colName) {
              var targetVal = returnData[colName];
              if (targetVal === null || targetVal === undefined) return;

              var targetEl = formContainer.querySelector('[name="' + colName + '"]');
              if (!targetEl) {
                var allInputs = formContainer.querySelectorAll('input, select, textarea');
                for (var inpIdx = 0; inpIdx < allInputs.length; inpIdx++) {
                  if (allInputs[inpIdx].name && allInputs[inpIdx].name.toLowerCase() === colName.toLowerCase()) {
                    targetEl = allInputs[inpIdx];
                    break;
                  }
                }
              }
              if (targetEl) {
                targetEl.value = targetVal;
                targetEl.dispatchEvent(new Event('input', { bubbles: true }));
                targetEl.dispatchEvent(new Event('change', { bubbles: true }));
                if (typeof targetEl.fetchDataForValue === 'function') {
                  targetEl.fetchDataForValue();
                }
              }
            });
          }
        }).catch(function (err) {
          console.warn('[DynamicFormEngine] Dynamic LinkColumn API Error (' + apiName + '):', err);
        });
        return;
      }

      // TH2: Trigger Tĩnh (Key:Col=Val|...)
      var rules = ruleStr.split('|');
      var matchedRule = null;
      for (var rIdx = 0; rIdx < rules.length; rIdx++) {
        var r = rules[rIdx].trim();
        var colonIdx = r.indexOf(':');
        if (colonIdx > -1) {
          var key = r.substring(0, colonIdx).trim();
          var cleanKey = removeAccents(key).toLowerCase();
          var cleanVal = removeAccents(val).toLowerCase();

          if (cleanKey === cleanVal) {
            matchedRule = r.substring(colonIdx + 1).trim();
            break;
          } else if (key.indexOf('?') > -1) {
            var escapedKey = key.replace(/[-\/\\^$*+?.()|[\]{}]/g, function (m) {
              return m === '?' ? '.' : '\\' + m;
            });
            var regex = new RegExp('^' + escapedKey + '$', 'i');
            if (regex.test(val)) {
              matchedRule = r.substring(colonIdx + 1).trim();
              break;
            }
          }
        }
      }
      if (matchedRule) {
        var pairs = matchedRule.split(',');
        pairs.forEach(function (p) {
          var eqIdx = p.indexOf('=');
          if (eqIdx > -1) {
            var targetCol = p.substring(0, eqIdx).trim();
            var targetVal = p.substring(eqIdx + 1).trim();

            var targetEl = formContainer.querySelector('[name="' + targetCol + '"]');
            if (!targetEl) {
              var allInputs = formContainer.querySelectorAll('input, select, textarea');
              for (var inpIdx = 0; inpIdx < allInputs.length; inpIdx++) {
                if (allInputs[inpIdx].name && allInputs[inpIdx].name.toLowerCase() === targetCol.toLowerCase()) {
                  targetEl = allInputs[inpIdx];
                  break;
                }
              }
            }

            if (targetEl) {
              targetEl.value = targetVal;
              targetEl.dispatchEvent(new Event('change', { bubbles: true }));
              if (typeof targetEl.fetchDataForValue === 'function') {
                targetEl.fetchDataForValue();
              }
            }
          }
        });
      }
    }

    // Lắng nghe sự kiện thay đổi để cập nhật currentModalFormState
    body.addEventListener('change', function (e) {
      var changedName = e.target.name;
      if (changedName) {
        var val = e.target.value;
        var field = globalFormSchema.find(function (f) { return f.name === changedName; });
        if (field && field.renderRule === 'mn') {
          val = val.replace(/\D/g, '');
        }
        currentModalFormState[changedName] = val;

        // Thực thi luật LinkColumn (Cả Tĩnh lẫn Động qua API)
        if (field && field.dropdownLinkColumn) {
          _executeLinkColumnRule(field, val, body, currentModalFormState);
        }
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

    var modalWidth = MODULE_CONFIG.ModalWidth || 'min(1180px, 95vw)';
    var hasJsonField = formSchema.some(function (f) {
      var isVisible = isEdit ? f.showInEdit : f.showInAdd;
      return (String(isVisible) === '1' || isVisible === true) && f.renderRule === 'js';
    });

    if (hasJsonField) {
      modalWidth = 'min(1380px, 96vw)';
    }

    var modal = UIModal.show({
      title: isEdit ? MODULE_CONFIG.TitleEdit : MODULE_CONFIG.TitleAdd,
      width: modalWidth,
      content: body,
      footer: footer
    });
    if (modal && modal.node) modal.node.classList.add('dynamic-form-modal');

    btnCancel.onclick = function () { modal.close(); };
    btnSave.onclick = function () {
      _saveData(isEdit, row, modal, body, btnSave);
    };



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
          if (field) {
            var rule = (field.renderRule || '').toLowerCase().trim();
            if (rule === 'money' || rule === 'm' || rule === 'mn') {
              val = val.replace(/\D/g, '');
            } else if (rule === 'dt' || rule === 'date') {
              val = (typeof FormatUtils !== 'undefined' && typeof FormatUtils.formatISO === 'function')
                ? FormatUtils.formatISO(val)
                : ((/^\d{4}-\d{2}-\d{2}$/.test(val)) ? val + 'T00:00:00' : val);
            }
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
    var finalPayloads = payloads.map(function (p) {
      return { FormKey: MODULE_CONFIG.FormID, Data: JSON.stringify(p) };
    });

    _sendSequential(
      endpoint,
      finalPayloads,
      function (count) {             // onDone
        modal.closeNow();
        Alert.success('Thành công', 'Đã lưu xong ' + count + ' dòng!');
        if (!isAdd) selectedRows = [];
        _updateSelectionCounter();
        _loadData();
      },
      function (err, payload, index) {               // onError → hiển thị lỗi và dừng chuỗi
        Alert.error('Lỗi ở dòng ' + (index + 1), err.message);
        btnSave.disabled = false;
        btnSave.textContent = MODULE_CONFIG.BtnSaveAll || 'Lưu Tất Cả';
        return false;
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
        if (field) {
          var isVisibleForMode = isEdit ? field.showInEdit : field.showInAdd;
          if (!_bool(isVisibleForMode) && field.name !== MODULE_CONFIG.PrimaryKey) return;
          var rule = (field.renderRule || '').toLowerCase().trim();
          if (rule === 'money' || rule === 'm' || rule === 'mn') {
            val = val.replace(/\D/g, '');
          } else if (rule === 'dt' || rule === 'date') {
            val = (typeof FormatUtils !== 'undefined' && typeof FormatUtils.formatISO === 'function')
              ? FormatUtils.formatISO(val)
              : ((/^\d{4}-\d{2}-\d{2}$/.test(val)) ? val + 'T00:00:00' : val);
          }
        }
        formInputData[el.name] = val;
      }
    });

    // 2. Validate Required
    var isInvalid = false;
    for (var i = 0; i < globalFormSchema.length; i++) {
      var field = globalFormSchema[i];
      var isVisibleForMode = isEdit ? field.showInEdit : field.showInAdd;
      if (!_bool(isVisibleForMode)) continue;
      var val = formInputData[field.name];
      var isJsonField = field.renderRule === 'js';
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
    var finalPayload = { FormKey: MODULE_CONFIG.FormID, Data: JSON.stringify(payloads[0]) };
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

  window.openQuickAddModal = function (formName, onSaved) {
    var detailUrl = '/api/API_LoadFormMeta';
    var schemaPayload = { FormName: formName };

    ApiClient.post(detailUrl, schemaPayload).then(function (schemaRes) {
      var rawSchema = schemaRes && (schemaRes.list || schemaRes.records) || [];

      if (!schemaRes || schemaRes.code !== 0 || !Array.isArray(rawSchema) || rawSchema.length === 0) {
        Alert.error('Lỗi', 'Không tìm thấy cấu hình trường cho form: ' + formName);
        return;
      }

      var formSchema = rawSchema.map(function (f) {
        return {
          name: f.name,
          label: f.label,
          required: _bool(f.required),
          renderRule: _mapRenderRule(f.renderRule),
          dataSource: f.dataSource,
          dropdownLinkColumn: f.dropdownLinkColumn || f.LinkColumn,
          position: f.position,
          showInAdd: _bool(f.showInAdd),
          showInEdit: _bool(f.showInEdit),
          orderNo: f.orderNo,
          value: f.defaultValue == null ? '' : f.defaultValue
        };
      });

      formSchema.sort(function (a, b) { return a.orderNo - b.orderNo; });

      var body = document.createElement('div');
      body.className = 'dynamic-form-body';
      body.style.display = 'flex';
      body.style.flexDirection = 'column';
      body.style.gap = '14px';

      var grid = document.createElement('div');
      grid.className = 'dynamic-form-grid';
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
          hiddenEl.value = field.value;
          body.appendChild(hiddenEl);
          return;
        }

        var inputEl;
        if (field.renderRule === 'sw') {
          inputEl = UIInput.createSwitch(field);
        } else if (field.renderRule === 'dt') {
          inputEl = UIInput.createDate(field);
        } else if (field.renderRule === 'tm') {
          inputEl = UIInput.createTime(field);
        } else if (field.dataSource) {
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
        } else if (field.renderRule === 'mn') {
          inputEl = UIInput.createMoney(field);
        } else if (field.renderRule === 'n') {
          inputEl = UIInput.createNumber(field);
        } else {
          inputEl = UIInput.createText(field);
        }

        var span = field.position;
        var wrapper = document.createElement('div');
        if (['12', '8', '6', '4', '3', '2'].includes(span)) {
          wrapper.className = 'df-col-' + span;
        } else {
          wrapper.className = 'df-col-custom';
          var w = span;
          if (!span.endsWith('%') && !span.endsWith('px')) {
            w = span + 'px';
          }
          wrapper.style.width = w;
          wrapper.style.flex = '0 0 ' + w;
          wrapper.style.maxWidth = w;
        }
        if (field.renderRule === 'dt') wrapper.classList.add('df-date-field');
        // Kích thước ô lấy từ MinWidth/MaxWidth trong SY_FmtFldTbl.
        var minFieldWidth = Number(field.minWidth);
        var maxFieldWidth = Number(field.maxWidth);
        if (Number.isFinite(minFieldWidth) && minFieldWidth > 0) {
          wrapper.style.minWidth = minFieldWidth + 'px';
        }
        if (Number.isFinite(maxFieldWidth) && maxFieldWidth > 0) {
          wrapper.style.maxWidth = maxFieldWidth + 'px';
        }
        wrapper.style.boxSizing = 'border-box';
        wrapper.appendChild(inputEl);
        grid.appendChild(wrapper);

        currentModalFormState[field.name] = field.value;
      });

      // Lắng nghe sự kiện thay đổi trên Form Thêm nhanh để kích hoạt Trigger / LinkColumn
      body.addEventListener('change', function (e) {
        var changedName = e.target.name;
        if (changedName) {
          var val = e.target.value;
          var field = formSchema.find(function (f) { return f.name === changedName; });
          if (field && field.renderRule === 'mn') {
            val = val.replace(/\D/g, '');
          }
          currentModalFormState[changedName] = val;

          // Thực thi luật LinkColumn (Cả Tĩnh lẫn Động qua API)
          if (field && field.dropdownLinkColumn) {
            _executeLinkColumnRule(field, val, body, currentModalFormState);
          }
        }
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

      var modal = UIModal.show({
        title: 'Thêm nhanh: ' + formName,
        width: '800px',
        content: body,
        footer: footer
      });
      if (modal && modal.node) modal.node.classList.add('dynamic-form-modal');

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
            if (field && field.renderRule === 'mn') {
              val = val.replace(/\D/g, '');
            } else if (field && field.renderRule === 'dt') {
              if (/^\d{4}-\d{2}-\d{2}$/.test(val)) {
                val = val + 'T00:00:00';
              }
            }
            payload[el.name] = val;
          }
        });

        var isInvalid = false;
        for (var i = 0; i < formSchema.length; i++) {
          var field = formSchema[i];
          if (!field.showInAdd) continue;
          var val = (payload[field.name] || '').trim();
          if (field.required && !val) {
            Alert.warning('Thiếu thông tin', 'Vui lòng nhập ' + field.label);
            isInvalid = true;
            break;
          }
        }

        if (isInvalid) {
          btnSave.disabled = false;
          btnSave.textContent = 'Lưu Lại';
          return;
        }

        var savePayload = { List: formName, Data: JSON.stringify(payload) };

        ApiClient.post('/api/API_LuuDong', savePayload).then(function (saveRes) {
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
