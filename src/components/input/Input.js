/**
 * Input Component
 * Sinh ra các ô nhập liệu (Text, Number, Date...) kèm Label bằng DOM Node chuẩn.
 * An toàn XSS, tiện lợi khi build Form hoàn toàn bằng JavaScript.
 */
var UIInput = (function () {

  /**
   * Sinh cấu trúc Label + DOM Input
   */
  function _createBaseWrapper(config, inputType) {
    var wrapper = document.createElement('div');
    wrapper.className = 'form-group ' + (config.className || '');

    if (config.label) {
      var lbl = document.createElement('label');
      lbl.innerText = config.label;
      if (config.required) {
        var req = document.createElement('span');
        req.innerText = ' *';
        req.style.color = 'var(--color-danger)';
        lbl.appendChild(req);
      }
      wrapper.appendChild(lbl);
    }

    var input = document.createElement('input');
    input.type = inputType;
    input.className = 'ui-input';
    if (config.id) input.id = config.id;
    if (config.name) input.name = config.name;
    if (config.placeholder) input.placeholder = config.placeholder;
    if (config.value !== undefined) input.value = config.value;
    if (config.disabled) input.disabled = true;
    if (config.readonly) input.readOnly = true;

    wrapper.appendChild(input);

    return { wrapper: wrapper, input: input };
  }

  /**
   * Ô nhập Text thông thường
   */
  function createText(config) {
    return _createBaseWrapper(config, 'text').wrapper;
  }

  /**
   * Ô nhập Số
   */
  function createNumber(config) {
    var obj = _createBaseWrapper(config, 'number');
    if (config.min !== undefined) obj.input.min = config.min;
    if (config.max !== undefined) obj.input.max = config.max;
    if (config.step !== undefined) obj.input.step = config.step;
    return obj.wrapper;
  }

  /**
   * Ô chọn Ngày
   */
  function createDate(config) {
    return _createBaseWrapper(config, 'date').wrapper;
  }

  /**
   * Hàm đọc số thành chữ tiếng Việt
   */
  function docSoTienVN(n) {
    if (!n || n === 0) return 'Không đồng';
    var dvDoc = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ', 'triệu tỷ', 'tỷ tỷ'];
    var soDoc = ['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
    function docNhom(so) {
      var tram = Math.floor(so / 100);
      var chuc = Math.floor((so % 100) / 10);
      var dv = so % 10;
      var kq = '';
      if (tram > 0) kq += soDoc[tram] + ' trăm ';
      if (chuc === 1) kq += 'mười ';
      else if (chuc > 1) kq += soDoc[chuc] + ' mươi ';
      if (dv === 1 && chuc > 1) kq += 'mốt ';
      else if (dv === 5 && chuc > 0) kq += 'lăm ';
      else if (dv > 0) kq += soDoc[dv] + ' ';
      return kq.trim();
    }
    var str = Math.round(n).toString();
    var groups = [];
    while (str.length > 0) {
      groups.unshift(str.slice(-3));
      str = str.slice(0, -3);
    }
    var result = '';
    groups.forEach(function (g, i) {
      var val = parseInt(g, 10);
      if (val > 0) {
        result += docNhom(val) + ' ' + dvDoc[groups.length - 1 - i] + ' ';
      }
    });
    return result.trim() + ' đồng';
  }

  /**
   * Cài đặt tự động format số tiền + hiển thị text cho một ô input có sẵn
   */
  function setupMoneyInput(inputEl, textEl) {
    if (!inputEl) return;
    
    function refresh() {
      var raw = parseInt(inputEl.value.replace(/\D/g, ''), 10) || 0;
      inputEl.value = raw === 0 ? '' : raw.toLocaleString('vi-VN');
      if (textEl) textEl.innerText = raw === 0 ? '' : docSoTienVN(raw);
    }

    inputEl.addEventListener('input', function () {
      var pos = this.selectionStart;
      var oldLen = this.value.length;
      var raw = parseInt(this.value.replace(/\D/g, ''), 10) || 0;
      
      this.value = raw === 0 ? '' : raw.toLocaleString('vi-VN');
      
      var diff = this.value.length - oldLen;
      if (pos !== null) {
        this.setSelectionRange(pos + diff, pos + diff);
      }
      
      if (textEl) textEl.innerText = raw === 0 ? '' : docSoTienVN(raw);
    });

    inputEl.addEventListener('blur', function () {
      refresh();
    });

    refresh();
  }

  return {
    createText: createText,
    createNumber: createNumber,
    createDate: createDate,
    docSoTienVN: docSoTienVN,
    setupMoneyInput: setupMoneyInput
  };
})();
