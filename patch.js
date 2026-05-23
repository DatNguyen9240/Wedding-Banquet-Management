const fs = require('fs');
const p = 'd:/Wedding-Banquet-Management/src/js/core/DynamicFormEngine.js';
let c = fs.readFileSync(p, 'utf8');

c = c.replace(
  "var alertBox = document.createElement('div');\r\n    alertBox.className = 'alert alert-info py-2 mb-0 d-flex align-items-center gap-2';\r\n    alertBox.style.fontSize = '13px';",
  "var alertBox = document.createElement('div');\r\n    alertBox.className = 'alert alert-info py-2 mb-0 d-flex align-items-center gap-2';\r\n    alertBox.style.fontSize = '13px';\r\n    var isEdit = !isAdd;"
);

c = c.replace(
  "if (field.showInEdit) {",
  "if (String(field.showInEdit) === '1' || field.showInEdit === true) {"
);

c = c.replace(
  "var comboLoading = UIControls.createDataComboBox({ placeholder: 'Đang tải...' });",
  "var comboLoading = UIControls.createDataComboBox({ placeholder: 'Đang tải...', disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true) });"
);

c = c.replace(
  "colFilterIndex: 1,\r\n                 onSelect: function(r) { hiddenInput.value = r[0]; }",
  "colFilterIndex: 1,\r\n                 disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true),\r\n                 onSelect: function(r) { hiddenInput.value = r[0]; }"
);

c = c.replace(
  "placeholder: '-- Chọn --', headers: headers, data: comboData, colFilterIndex: colFilterIndex,\r\n                   onSelect: function(r) { hiddenInput.value = r[0]; }",
  "placeholder: '-- Chọn --', headers: headers, data: comboData, colFilterIndex: colFilterIndex,\r\n                   disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true),\r\n                   onSelect: function(r) { hiddenInput.value = r[0]; }"
);

c = c.replace(
  "var comboEmpty = UIControls.createDataComboBox({ placeholder: 'Chưa có dữ liệu' });\r\n            inputEl.replaceChild(comboEmpty, comboLoading);",
  "var comboEmpty = UIControls.createDataComboBox({ placeholder: 'Chưa có dữ liệu', disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true) });\r\n            inputEl.replaceChild(comboEmpty, comboLoading);"
);

c = c.replace(
  "i.setAttribute('data-field-name', originalName);\r\n             });",
  "i.setAttribute('data-field-name', originalName);\r\n                if (isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true)) i.disabled = true;\r\n             });\r\n             if (isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true)) inputEl.classList.add('ui-input-disabled');"
);

c = c.replace(
  "if (!isVisible) {",
  "if (!(String(isVisible) === '1' || isVisible === true)) {"
);

c = c.replace(
  "colFilterIndex: 1, // Dùng cột Tên để hiển thị lên input\r\n               onSelect: function(row) {",
  "colFilterIndex: 1, // Dùng cột Tên để hiển thị lên input\r\n               disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true),\r\n               onSelect: function(row) {"
);

const oldFetch = ar endpoint = field.dataSource.startsWith('http') ? field.dataSource : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + field.dataSource); \r
\r
var finalUrl = endpoint; \r
var fetchPayload = {}; \r
if (endpoint.indexOf('?') > -1) {
\r
  var parts = endpoint.split('?'); \r
  finalUrl = parts[0]; \r
  var searchParams = new URLSearchParams(parts[1]); \r
  searchParams.forEach(function (value, key) {
  \r
    fetchPayload[key] = value; \r
  }); \r
} \r
// Thêm tham số user mặc định của hệ thống\r
if (!fetchPayload.UserName) fetchPayload.UserName = _currentUser(); \r
\r
ApiClient.post(finalUrl, fetchPayload).then(function (res) {
\r
  var comboData = []; \r
  var dataList = res.list || res.records; \r
  var headers = ['Mã', 'Tên']; // Fallback\r
  var colFilterIndex = 1; \r
  \r
  if (dataList && dataList.length > 0) {
  \r
    // Tự động trích xuất toàn bộ cấu trúc cột từ record đầu tiên\r
    var keys = Object.keys(dataList[0]); \r
    \r
    // Nếu có nhiều hơn 1 cột, dùng các key đó làm tiêu đề cột\r
    if (keys.length > 0) {
    \r
      headers = keys; \r
      // Tự động tìm cột hiển thị (Label): Ưu tiên các cột có tên chứa chữ "name, ten, label, desc"\r
      var labelRegex = /name|tên|ten|label|desc|title/i; \r
      var displayKey = keys.find(function (k) { return labelRegex.test(k); }); \r
      colFilterIndex = displayKey ? keys.indexOf(displayKey) : (keys.length > 1 ? 1 : 0); \r
      \r
      dataList.forEach(function (d) {
      \r
        var rowData = []; \r
        keys.forEach(function (k) { rowData.push(d[k] !== null && d[k] !== undefined ? d[k] : ''); }); \r
        comboData.push(rowData); \r
      }); \r
    } else {
    \r
      // Dự phòng trường hợp object rỗng\r
      dataList.forEach(function (d) { comboData.push(['', '']); }); \r
    } \r
  } \r
  \r
  var newCombo = UIControls.createDataComboBox({
  \r
                 placeholder: '-- Vui lòng chọn --', \r
                 headers: headers, \r
                 data: comboData, \r
                 colFilterIndex: colFilterIndex, \r
                 onSelect: function (row) {
    \r
      hiddenInput.value = row[0]; \r
    }\r
  }); \r
  \r
  var newDisplayInput = newCombo.querySelector('input.ui-input'); \r
  var matched = comboData.find(function (r) { return r[0] == field.value; }); \r
  if (matched && newDisplayInput) newDisplayInput.value = matched[1]; \r
  \r
  formGroupWrapper.replaceChild(newCombo, comboLoading); \r
}).catch(function (err) {
\r
  console.error('[DynamicFormEngine] DataComboBox error:', err); \r
  var displayInput = comboLoading.querySelector('input.ui-input'); \r
  if (displayInput) displayInput.placeholder = 'Lỗi tải dữ liệu'; \r
});;

const newFetch = ar endpoint = field.dataSource.startsWith('http') ? field.dataSource : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + field.dataSource); \r
var finalUrl = endpoint; \r
var fetchPayload = {}; \r
if (endpoint.indexOf('?') > -1) {
\r
  var parts = endpoint.split('?'); \r
  finalUrl = parts[0]; \r
  var searchParams = new URLSearchParams(parts[1]); \r
  searchParams.forEach(function (value, key) { fetchPayload[key] = value; }); \r
} \r
if (!fetchPayload.UserName) fetchPayload.UserName = _currentUser(); \r
\r
var searchApiCall = function (q, page) {
\r
  var payload = Object.assign({}, fetchPayload); \r
  if (q) payload.Keyword = q; \r
  return ApiClient.post(finalUrl, payload).then(function (res) {
  \r
    var comboData = []; \r
    var dataList = res.list || res.records; \r
    var headers = ['Mã', 'Tên']; \r
    var colFilterIndex = 1; \r
    if (dataList && dataList.length > 0) {
    \r
      var keys = Object.keys(dataList[0]); \r
      if (keys.length > 0) {
      \r
        headers = keys; \r
        var labelRegex = /name|tên|ten|label|desc|title/i; \r
        var displayKey = keys.find(function (k) { return labelRegex.test(k); }); \r
        colFilterIndex = displayKey ? keys.indexOf(displayKey) : (keys.length > 1 ? 1 : 0); \r
        dataList.forEach(function (d) {
        \r
          var rowData = []; \r
          keys.forEach(function (k) { rowData.push(d[k] !== null && d[k] !== undefined ? d[k] : ''); }); \r
          comboData.push(rowData); \r
        }); \r
      } else {
      \r
        dataList.forEach(function (d) { comboData.push(['', '']); }); \r
      } \r
    } \r
    return { headers: headers, data: comboData, colFilterIndex: colFilterIndex }; \r
  }); \r
}; \r
\r
var lazyCombo = UIControls.createDataComboBox({
\r
               placeholder: '-- Vui lòng chọn --', \r
               headers: ['Mã', 'Tên'], \r
               disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true), \r
               onSearch: searchApiCall, \r
               onSelect: function (row) { hiddenInput.value = row[0]; }\r
}); \r
\r
if (field.value) {
\r
  searchApiCall('', 1).then(function (res) {
  \r
    var displayInput = lazyCombo.querySelector('input.ui-input'); \r
    var matched = res.data.find(function (r) { return r[0] == field.value; }); \r
    if (matched && displayInput) displayInput.value = matched[res.colFilterIndex || 1]; \r
  }).catch(function (err) {
  \r
    console.error('[DynamicFormEngine] DataComboBox initial fetch error:', err); \r
    var displayInput = lazyCombo.querySelector('input.ui-input'); \r
    if (displayInput) displayInput.placeholder = 'Lỗi tải dữ liệu'; \r
  }); \r
} \r
\r
formGroupWrapper.replaceChild(lazyCombo, comboLoading);;

c = c.replace(oldFetch, newFetch);

c = c.replace(
  "var span = String(field.position || 'body');",
  "if (isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true)) {\r\n        var innerFields = inputEl.querySelectorAll('input, select, textarea, button');\r\n        if (innerFields.length > 0) {\r\n          innerFields.forEach(function(el) { el.disabled = true; });\r\n        } else if (['INPUT', 'SELECT', 'TEXTAREA', 'BUTTON'].includes(inputEl.tagName)) {\r\n          inputEl.disabled = true;\r\n        }\r\n        inputEl.classList.add('ui-input-disabled');\r\n      }\r\n      var span = String(field.position || 'body');"
);

fs.writeFileSync(p, c, 'utf8');
