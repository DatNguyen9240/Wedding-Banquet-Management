/**
 * Dynamic Form Engine - Generic Metadata-Driven UI Engine
 */
window.DynamicFormEngine = (function () {

  var $container = null;
  var gridData = [];
  var selectedRow = null;

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

  function _hasPermission(action) {
     var perms = JSON.parse(localStorage.getItem('pmql_permissions') || 'null');
     if (!perms) return true; // Chưa ráp hệ thống phân quyền thì thả cửa
     
     // Ví dụ: perms = { 'frmStaff': { CanAdd: 1, CanEdit: 0, CanDelete: 0 } }
     var modulePerm = perms[MODULE_CONFIG.FormName];
     if (!modulePerm) return true; 

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

    // 1. Lấy Từ điển UI từ Database trước
    var configEndpoint = MODULE_CONFIG.ApiDictionary;
      
    var pConfig = configEndpoint ? ApiClient.post(configEndpoint, { FormName: MODULE_CONFIG.FormName }) : Promise.resolve(null);

    pConfig.then(function (resConfig) {

        // 2. Lưu Từ điển vào biến toàn cục
        if (resConfig && resConfig.code === 0 && resConfig.list) {
          globalDictionary = {};
          globalFormSchema = [];
          
          resConfig.list.forEach(function(item) {
            // Xây Dictionary cho Table
            globalDictionary[item.name] = item.label;
            
            // Xây dựng Custom Renderers Động từ cấu hình DB
            if (item.renderRule) {
               globalRenderers[item.name] = function(v) {
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

            // Xây Schema cho Form (Lưu toàn bộ để lấy Khóa chính, nhưng đánh dấu showInForm)
            globalFormSchema.push({
              name: item.name,
              label: item.label,
              required: !!item.required,
              position: item.position || 'grid', // Mặc định là grid nếu db null
              showInForm: !!item.showInForm,
              renderRule: (item.renderRule || '').toLowerCase().trim(),
              dataSource: (item.dataSource || '').trim()
            });
          });
          
          if (Object.keys(globalDictionary).length === 0) {
              console.warn('API returned no fields for FormName:', MODULE_CONFIG.FormName);
          }
        } else {
            console.warn('API Dictionary fetch failed or empty', resConfig);
        }
        // Tự động sinh mã HTML (Không cần file .html rời nữa)
        var html = 
          '<div class="page-title-bar">' +
            '<div class="page-title-info">' +
              '<h1 class="page-title-heading">' + (MODULE_CONFIG.PageTitle || 'Quản lý Dữ liệu') + '</h1>' +
              '<span class="page-title-sub">' + (MODULE_CONFIG.PageSubtitle || '') + '</span>' +
            '</div>' +
          '</div>' +
          '<div id="dynamic-btn-container" style="margin-bottom: 16px;"></div>' +
          '<div class="card">' +
            '<div class="card-body">' +
              '<div id="dynamic-filter-container" style="margin-bottom: 16px;"></div>' +
              '<div id="dynamic-grid-container"></div>' +
            '</div>' +
          '</div>';

        $container.innerHTML = html;

        // Action Toolbar
        var btnContainer = $container.querySelector('#dynamic-btn-container');
        if (btnContainer && typeof UIActionToolbar !== 'undefined') {
          var toolbar = UIActionToolbar.create({
            onAdd: _hasPermission('ADD') ? _openAddForm : false,
            onEdit: _hasPermission('EDIT') ? function () {
              if (!selectedRow) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectEdit);
              _openEditForm(selectedRow);
            } : false,
            onDelete: _hasPermission('DELETE') ? function () {
              if (!selectedRow) return Alert.warning(MODULE_CONFIG.AlertTitleWarning, MODULE_CONFIG.WarnSelectDelete);
              if (typeof ConfirmModal !== 'undefined') {
                var deleteName = selectedRow[MODULE_CONFIG.RowNameField] || MODULE_CONFIG.TextDeleteFallback;
                ConfirmModal.show(MODULE_CONFIG.AlertTitleConfirm,
                  MODULE_CONFIG.ConfirmDelete.replace('{0}', deleteName),
                  function () {
                    Alert.info(MODULE_CONFIG.AlertTitleInfo, MODULE_CONFIG.InfoDeleteDev);
                  }
                );
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
  function _loadData() {
    var gridContainer = $container ? $container.querySelector('#dynamic-grid-container') : null;
    if (gridContainer) gridContainer.innerHTML = '<div class="p-4 text-center" style="color:var(--color-text-secondary);">' + MODULE_CONFIG.TextLoading + '</div>';

    if (MODULE_CONFIG.ApiSearch) {
      ApiClient.post(MODULE_CONFIG.ApiSearch, {
        Keyword: currentKeyword,
        SortColumn: currentSortCol,
        SortDir: currentSortDir,
        Page: currentPage,
        Limit: currentLimit
      }).then(function (result) {
        totalRecords = result.total || 0;
        gridData = (result.list || []).map(function (item) {
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
        _renderTable();
      });
    }
  }

  // ── Render Table ──────────────────────────────────────────
  function _renderTable() {
    var gridContainer = $container.querySelector('#dynamic-grid-container');
    if (!gridContainer) return;
    gridContainer.innerHTML = '';
    selectedRow = null;

    if (typeof UITable !== 'undefined') {
      // Dùng bộ từ điển từ DB để dịch các cột sang Tiếng Việt
      var dictionary = globalDictionary;

      // Render các cột tùy chỉnh (Sinh ra tự động từ RenderRule trong DB)
      var customRenderers = globalRenderers;

      // Gọi UITable.createDynamic siêu cấp
      var tableEl = UITable.createDynamic(gridData, dictionary, {
        currentSort: { field: currentSortCol, dir: currentSortDir },
        onSort: function (field, dir) {
          currentSortCol = field;
          currentSortDir = dir;
          currentPage = 1;
          _loadData();
        },
        actionRenderers: customRenderers
      });

      // Bắt sự kiện Click Chuột Phải (Context Menu) để Copy
      if (typeof UIContextMenu !== 'undefined') {
        tableEl.addEventListener('contextmenu', function(e) {
          e.preventDefault(); // Ngăn menu mặc định của trình duyệt
          
          var td = e.target.closest('td');
          var tr = e.target.closest('tr');
          if (!td && !tr) return;

          // Hàm lấy nội dung của hàng (nối các ô bằng dấu cách hoặc tab)
          var getRowText = function(rowEl) {
            if (!rowEl) return '';
            var cells = rowEl.querySelectorAll('td');
            var textArr = [];
            for (var i = 0; i < cells.length; i++) {
              textArr.push(cells[i].innerText.trim());
            }
            return textArr.join(' | ');
          };

          UIContextMenu.show(e, [
            { 
              icon: 'content_copy', 
              label: MODULE_CONFIG.MenuCopyCell, 
              onClick: function () { 
                if (td) {
                  navigator.clipboard.writeText(td.innerText.trim());
                  if (typeof UIToast !== 'undefined') UIToast.show(MODULE_CONFIG.ToastCopyCell, 'success');
                }
              } 
            },
            { 
              icon: 'file_copy', 
              label: MODULE_CONFIG.MenuCopyRow, 
              onClick: function () { 
                if (tr) {
                  navigator.clipboard.writeText(getRowText(tr));
                  if (typeof UIToast !== 'undefined') UIToast.show(MODULE_CONFIG.ToastCopyRow, 'success');
                }
              } 
            }
          ]);
        });
      }

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

      var tbody = tableEl.querySelector('tbody');
      if (tbody) {
        tbody.addEventListener('click', function (e) {
          var tr = e.target.closest('tr');
          if (!tr || tr.children.length === 1) return;
          Array.from(tbody.querySelectorAll('tr')).forEach(function (r) { r.classList.remove('active'); });
          tr.classList.add('active');
          var idx = Array.from(tbody.children).indexOf(tr);
          selectedRow = gridData[idx] || null;
        });
        tbody.addEventListener('dblclick', function (e) {
          var tr = e.target.closest('tr');
          if (!tr || !selectedRow) return;
          _openEditForm(selectedRow);
        });
      }
    }
  }

  // ── Modal Form ────────────────────────────────────────────
  function _openAddForm() {
    _openModal(false, null);
  }

  function _openEditForm(row) {
    _openModal(true, row);
  }

  function _openModal(isEdit, row) {
    var body = document.createElement('div');
    body.style.display = 'flex';
    body.style.flexDirection = 'column';
    body.style.gap = '14px';

    var grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '1fr 1fr';
    grid.style.gap = '12px';
    body.appendChild(grid);

    // KHAI BÁO CẤU TRÚC FORM (SCHEMA-DRIVEN UI LẤY TỪ DB)
    var formSchema = globalFormSchema;

    // ENGINE VẼ FORM TỰ ĐỘNG
    formSchema.forEach(function(field) {
      if (!field.showInForm) {
        // Vẽ input ẩn cho các Khóa chính (Ví dụ Makh) để Auto-Serializer thu thập được
        var hiddenEl = document.createElement('input');
        hiddenEl.type = 'hidden';
        hiddenEl.name = field.name;
        hiddenEl.value = row ? (row[field.name] || '') : '';
        body.appendChild(hiddenEl);
        return;
      }

      // Tự động gán giá trị cũ (nếu đang Sửa)
      field.value = row ? (row[field.name] || '') : '';
      
      // Khởi tạo Ô nhập liệu tuỳ thuộc vào quy tắc renderRule
      var inputEl;
      if (field.renderRule === 'sw' || field.renderRule === 'boolean') {
          inputEl = UIInput.createSwitch(field);
      } else if (field.renderRule === 'dt' || field.renderRule === 'date') {
          inputEl = UIInput.createDate(field);
      } else if (field.renderRule === 'sl' || field.renderRule === 'select') {
          if (field.dataSource) {
              inputEl = UIInput.createSelect(field, [{ value: '', label: 'Đang tải...' }]);
              var selectDom = inputEl.querySelector('select');
              
              var endpoint = field.dataSource.startsWith('http') ? field.dataSource : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + field.dataSource);
              ApiClient.post(endpoint, {}).then(function(res) {
                  var opts = [];
                  if (res && res.list) {
                      opts = res.list.map(function(o) {
                          var keys = Object.keys(o);
                          return { value: o[keys[0]], label: o[keys[1] || keys[0]] };
                      });
                  }
                  // Xoá options cũ, bơm options mới
                  selectDom.innerHTML = '<option value="">-- Vui lòng chọn --</option>';
                  opts.forEach(function(opt) {
                      var o = document.createElement('option');
                      o.value = opt.value;
                      o.innerText = opt.label;
                      if (field.value == opt.value) o.selected = true;
                      selectDom.appendChild(o);
                  });
              }).catch(function() {
                  selectDom.innerHTML = '<option value="">Lỗi tải dữ liệu</option>';
              });
          } else {
              inputEl = UIInput.createSelect(field, []);
          }
      } else if (field.renderRule === 'nm' || field.renderRule === 'number') {
          inputEl = UIInput.createNumber(field);
      } else {
          inputEl = UIInput.createText(field);
      }

      // Phân bổ vị trí (nửa dòng vào grid, nguyên dòng vào body)
      if (field.position === 'grid') {
        grid.appendChild(inputEl);
      } else {
        body.appendChild(inputEl);
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

  // ── Save ──────────────────────────────────────────────────
  function _saveData(isEdit, row, modal, body, btnSave) {
    // 1. Khởi tạo Payload mặc định (Thuộc về Hệ thống chung)
    var payload = {
      NhomNguoiDangThaoTac: _currentGroup()
    };

    // 2. Tự động Quét toàn bộ Form (Auto Serialization)
    var inputs = body.querySelectorAll('input, select, textarea');
    inputs.forEach(function(el) {
      if (el.name) {
        payload[el.name] = el.value.trim();
      }
    });

    // KHÔNG CÒN BẤT KỲ LOGIC NGHIỆP VỤ NÀO Ở FRONTEND
    // 3. Validate tự động dựa trên cấu hình Database (Required)
    var isInvalid = false;
    for (var i = 0; i < globalFormSchema.length; i++) {
      var field = globalFormSchema[i];
      if (field.required && !payload[field.name]) {
        Alert.warning(MODULE_CONFIG.WarnMissingInfo, MODULE_CONFIG.WarnMissingInput.replace('{0}', field.label));
        isInvalid = true;
        break;
      }
    }
    
    if (isInvalid) return;

    btnSave.disabled = true;
    btnSave.textContent = MODULE_CONFIG.BtnSaveSaving;

    var endpoint = MODULE_CONFIG.ApiSave;

    if (!endpoint) {
      Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertApiMissing);
      btnSave.disabled = false;
      return;
    }
    payload.UserCreate = _currentUser();
    payload.IsEdit = isEdit ? 1 : 0;

    ApiClient.post(endpoint, payload)
      .then(function (res) {
        if (res && res.code === 0) {
          UIToast.show(isEdit ? MODULE_CONFIG.ToastEdit : MODULE_CONFIG.ToastAdd, 'success');
          modal.closeNow();
          _loadData();
        } else {
          Alert.error(MODULE_CONFIG.AlertTitleError, res && res.msg ? res.msg : MODULE_CONFIG.AlertSaveFailed);
          btnSave.disabled = false;
          btnSave.textContent = isEdit ? MODULE_CONFIG.BtnSaveEdit : MODULE_CONFIG.BtnSaveAdd;
        }
      })
      .catch(function () {
        Alert.error(MODULE_CONFIG.AlertTitleError, MODULE_CONFIG.AlertNetworkError);
        btnSave.disabled = false;
        btnSave.textContent = isEdit ? MODULE_CONFIG.BtnSaveEdit : MODULE_CONFIG.BtnSaveAdd;
      });
  }

  return { render: render };
})();
