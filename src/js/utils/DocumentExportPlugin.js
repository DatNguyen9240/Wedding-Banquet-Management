/* Document export: the user selects a live template from Document Server. */
var DocumentExportPlugin = (function () {
  function _rowValue(row, fieldName) {
    if (!row || !fieldName) return '';
    if (row[fieldName] !== undefined && row[fieldName] !== null) return row[fieldName];
    var expected = String(fieldName).toLowerCase();
    for (var key in row) {
      if (key.toLowerCase() === expected && row[key] !== null && row[key] !== undefined) return row[key];
    }
    return '';
  }

  function _authHeaders() {
    var headers = { 'Content-Type': 'application/json' };
    var token = typeof ApiClient !== 'undefined' && typeof ApiClient.getCookie === 'function'
      ? ApiClient.getCookie('auth_token')
      : '';
    if (token) headers.Authorization = 'Bearer ' + token;
    return headers;
  }

  function _documentBase() {
    return window.API_CONFIG && window.API_CONFIG.ENDPOINTS
      && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER
      && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API;
  }

  function _escapeHtml(value) {
    return String(value || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function _chooseTemplate(templates) {
    return new Promise(function (resolve) {
      var overlay = document.createElement('div');
      overlay.style.cssText = 'position:fixed;inset:0;z-index:10000;background:rgba(15,23,42,.45);display:flex;align-items:center;justify-content:center;padding:16px;';

      var options = templates.map(function (template, index) {
        var label = template.fileName || template.relPath || ('Mẫu ' + (index + 1));
        return '<option value="' + index + '">' + _escapeHtml(label) + '</option>';
      }).join('');

      overlay.innerHTML = '<div style="width:min(520px,100%);background:var(--color-surface,#fff);border-radius:10px;padding:20px;box-shadow:0 20px 45px rgba(15,23,42,.25);">'
        + '<div style="font-size:18px;font-weight:600;margin-bottom:14px;">Chọn mẫu in</div>'
        + '<select data-template-select style="width:100%;padding:10px;border:1px solid var(--color-border,#cbd5e1);border-radius:6px;background:var(--color-surface,#fff);">' + options + '</select>'
        + '<div style="display:flex;justify-content:flex-end;gap:8px;margin-top:18px;">'
        + '<button type="button" data-template-cancel class="btn btn-secondary">Hủy</button>'
        + '<button type="button" data-template-confirm class="btn btn-primary">Tạo tài liệu</button>'
        + '</div></div>';

      function close(value) {
        if (overlay.parentNode) overlay.parentNode.removeChild(overlay);
        resolve(value);
      }

      overlay.querySelector('[data-template-cancel]').onclick = function () { close(null); };
      overlay.querySelector('[data-template-confirm]').onclick = function () {
        var index = Number(overlay.querySelector('[data-template-select]').value);
        close(templates[index] || null);
      };
      overlay.onclick = function (event) { if (event.target === overlay) close(null); };
      document.body.appendChild(overlay);
    });
  }

  function _generateDocument(documentBase, template, row, config, documentId) {
    var templatePath = template.relPath || template.fileName || '';
    var templateType = templatePath.replace(/\.docx$/i, '');
    var outputBase = (template.fileName || templateType).replace(/\.docx$/i, '').replace(/[^a-zA-Z0-9_-]+/g, '_');

    return fetch(documentBase + '/generate', {
      method: 'POST',
      headers: _authHeaders(),
      body: JSON.stringify({
        templateType: templateType,
        customerId: String(documentId),
        outputFileName: outputBase + '_' + documentId,
        rowData: row,
        sqlListName: config.FormName
      })
    })
      .then(function (response) { return response.json(); })
      .then(function (result) {
        if (!result.success) {
          Alert.error('Không thể tạo DOCX', result.message || 'Server không trả về file tài liệu.');
          return;
        }
        sessionStorage.setItem('docmgr_open_file', result.fileName);
        if (typeof UIToast !== 'undefined') UIToast.show('Đã tạo DOCX: ' + result.fileName, 'success');
        window.location.hash = '#/document-manager';
      });
  }

  function generate(selectedRows, config) {
    if (!selectedRows || selectedRows.length !== 1) {
      return Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn đúng một dòng để xuất tài liệu.');
    }

    var row = selectedRows[0];
    var idField = config.PrimaryKey || 'DocumentID';
    var documentId = _rowValue(row, idField);
    if (documentId === '') {
      return Alert.error('Thiếu mã chứng từ', 'Dòng đang chọn không có giá trị cho cột ' + idField + '.');
    }

    var documentBase = _documentBase();
    if (!documentBase) {
      return Alert.error('Lỗi cấu hình', 'Chưa cấu hình DOCUMENT_MANAGER.BASE_API.');
    }

    fetch(documentBase + '/templates', { headers: _authHeaders() })
      .then(function (response) { return response.json(); })
      .then(function (result) {
        var templates = result && Array.isArray(result.data) ? result.data.filter(function (item) {
          var name = item && (item.relPath || item.fileName) || '';
          return /\.docx$/i.test(name);
        }) : [];
        if (templates.length === 0) {
          Alert.warning('Chưa có mẫu in', 'Vui lòng thêm mẫu trong Quản lý tài liệu trước khi in.');
          return null;
        }
        return _chooseTemplate(templates);
      })
      .then(function (template) {
        if (!template) return;
        return _generateDocument(documentBase, template, row, config, documentId);
      })
      .catch(function () {
        Alert.error('Không kết nối được', 'Không thể kết nối Document Server.');
      });
  }

  return { generate: generate };
})();
