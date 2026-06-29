/**
 * Format Utility
 * Các hàm tiện ích dùng chung (Tiền tệ, Thời gian, Số)
 */
var FormatUtils = (function () {

  /**
   * Định dạng tiền tệ VNĐ (VD: 1500000 -> 1.500.000 VNĐ)
   */
  function currency(amount) {
    if (amount === null || amount === undefined || isNaN(amount)) return '0 VNĐ';
    return Number(amount).toLocaleString('vi-VN') + ' VNĐ';
  }

  /**
   * Định dạng số có dấy tách thập phân (VD: 1500 -> 1.500)
   */
  function number(value) {
    if (value === null || value === undefined || isNaN(value)) return '0';
    return Number(value).toLocaleString('vi-VN');
  }

  /**
   * Định dạng ngày tháng VN (VD: YYYY-MM-DD -> DD/MM/YYYY)
   */
  function date(dateString) {
    if (!dateString) return '';
    var d = new Date(dateString);
    if (isNaN(d.getTime())) return dateString;
    var day = ('0' + d.getDate()).slice(-2);
    var month = ('0' + (d.getMonth() + 1)).slice(-2);
    return day + '/' + month + '/' + d.getFullYear();
  }

  /**
   * Đọc số thành chữ tiếng Việt (VD: 1500000 -> một triệu năm trăm nghìn đồng)
   */
  function docSoTienVN(n) {
    if (n === null || n === undefined || isNaN(n)) return '';
    var num = Number(n);
    if (num === 0) return 'không đồng';
    var isNegative = num < 0;
    num = Math.abs(num);
    
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
      else if (tram > 0 && dv > 0) kq += 'lẻ ';
      if (dv === 1 && chuc > 1) kq += 'mốt ';
      else if (dv === 5 && chuc > 0) kq += 'lăm ';
      else if (dv > 0) kq += soDoc[dv] + ' ';
      return kq.trim();
    }
    
    var str = Math.round(num).toString();
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
    
    var prefix = isNegative ? 'âm ' : '';
    return prefix + result.trim() + ' đồng';
  }

  /**
   * Định dạng chuỗi ngày sang định dạng ISO YYYY-MM-DDT00:00:00
   */
  function formatISO(val) {
    if (!val) return val;
    var trimmed = val.trim();
    // TH1: YYYY-MM-DD
    if (/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) {
      return trimmed + 'T00:00:00';
    }
    // TH2: DD/MM/YYYY
    var matchDMY = trimmed.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
    if (matchDMY) {
      return matchDMY[3] + '-' + matchDMY[2] + '-' + matchDMY[1] + 'T00:00:00';
    }
    // TH3: DD/MM/YYYY HH:mm or DD/MM/YYYY HH:mm:ss
    var matchDMYTime = trimmed.match(/^(\d{2})\/(\d{2})\/(\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?$/);
    if (matchDMYTime) {
      var hour = matchDMYTime[4];
      var min = matchDMYTime[5];
      var sec = matchDMYTime[6] || '00';
      return matchDMYTime[3] + '-' + matchDMYTime[2] + '-' + matchDMYTime[1] + 'T' + hour + ':' + min + ':' + sec;
    }
    return val;
  }

  return {
    currency: currency,
    number: number,
    date: date,
    docSoTienVN: docSoTienVN,
    formatISO: formatISO
  };
})();
