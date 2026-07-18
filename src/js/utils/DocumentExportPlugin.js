/*
 * Document export for metadata-driven forms.
 * SY_FormTbl is the single source for template, detail source and document ID.
 */
var DocumentExportPlugin = (function () {
  function _rowValue(row, fieldName) {
    if (!row || !fieldName) return '';
    if (row[fieldName] !== undefined && row[fieldName] !== null) return row[fieldName];
    var expected = fieldName.toLowerCase();
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

  function generate(selectedRows, config) {
    if (!selectedRows || selectedRows.length !== 1) {
      return Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn đúng một dòng để xuất tài liệu.');
    }

    var row = selectedRows[0];
    var documentId = _rowValue(row, config.DocumentIdField);
    if (documentId === '') {
      return Alert.error('Thiếu mã chứng từ', 'Dòng đang chọn không có giá trị cho cột ' + config.DocumentIdField + '.');
    }

    // TemplateFile is a business field returned by the selected record. When it
    // is populated, that record intentionally selects its own approved template.
    var templateType = _rowValue(row, 'TemplateFile') || config.DocumentTemplate;
    var documentBase = window.API_CONFIG && window.API_CONFIG.ENDPOINTS
      && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER
      && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API;
    if (!documentBase) {
      return Alert.error('Lỗi cấu hình', 'Chưa cấu hình DOCUMENT_MANAGER.BASE_API.');
    }

    fetch(documentBase + '/generate', {
      method: 'POST',
      headers: _authHeaders(),
      body: JSON.stringify({
        templateType: templateType,
        customerId: String(documentId),
        outputFileName: templateType + '_' + documentId,
        rowData: row,
        sqlListName: config.DocumentListName
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
      })
      .catch(function () {
        Alert.error('Không kết nối được', 'Không thể kết nối Document Server.');
      });
  }

  return { generate: generate };
})();
