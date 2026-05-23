const fs = require('fs');
const p = 'd:/Wedding-Banquet-Management/src/js/core/DynamicFormEngine.js';
let c = fs.readFileSync(p, 'utf8');

const regex = /var endpoint = field\.dataSource\.startsWith.*?formGroupWrapper\.replaceChild\(newCombo, comboLoading\);\s*\}\)\.catch\(function \(err\) \{[\s\S]*?if \(displayInput\) displayInput\.placeholder = 'Lỗi tải dữ liệu';\s*\}\);/g;

const newFetch = \ar endpoint = field.dataSource.startsWith('http') ? field.dataSource : ((typeof API_CONFIG !== 'undefined' ? API_CONFIG.BASE_URL : '') + field.dataSource);
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
  if (q) payload.Keyword = q;
  return ApiClient.post(finalUrl, payload).then(function (res) {
    var comboData = [];
    var dataList = res.list || res.records;
    var headers = ['Mã', 'Tên'];
    var colFilterIndex = 1;
    if (dataList && dataList.length > 0) {
      var keys = Object.keys(dataList[0]);
      if (keys.length > 0) {
        headers = keys;
        var labelRegex = /name|tên|ten|label|desc|title/i;
        var displayKey = keys.find(function (k) { return labelRegex.test(k); });
        colFilterIndex = displayKey ? keys.indexOf(displayKey) : (keys.length > 1 ? 1 : 0);
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
  disabled: isEdit && (String(field.isReadOnlyEdit) === '1' || field.isReadOnlyEdit === true),
  onSearch: searchApiCall,
  onSelect: function (row) { hiddenInput.value = row[0]; }
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

formGroupWrapper.replaceChild(lazyCombo, comboLoading); \;

let matchCount = 0;
c = c.replace(regex, function (match) {
  matchCount++;
  return newFetch;
});

console.log('Matches replaced:', matchCount);
fs.writeFileSync(p, c, 'utf8');
