/**
 * PromotionAutoFillPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Tự động tính toán tổng số bàn và tra cứu danh sách quà tặng ưu đãi (khuyến mãi)
 * dựa trên loại tiệc và số bàn chính thức. Tự động điền vào Ghi chú (đối với Phiếu cọc)
 * hoặc Khuyến mãi (đối với Hợp đồng).
 */
var PromotionAutoFillPlugin = (function () {
  var SUPPORTED_FORMS = ['frmBiennhancoccho', 'frmHopDong'];
  var debounceTimeout = null;

  function _getFormFields(modalContent, formName) {
    var loaiTiecEl = modalContent.querySelector('[name="Loaitiecid"]');
    var banManEl = modalContent.querySelector('[name="SobanManchinhthuc"]');
    var banChayEl = modalContent.querySelector('[name="SobanChaychinhthuc"]');
    var targetEl = null;

    if (formName === 'frmBiennhancoccho') {
      targetEl = modalContent.querySelector('[name="Ghichu"]');
    } else if (formName === 'frmHopDong') {
      targetEl = modalContent.querySelector('[name="DSKhuyenMai"]');
    }

    return {
      loaiTiecEl: loaiTiecEl,
      banManEl: banManEl,
      banChayEl: banChayEl,
      targetEl: targetEl
    };
  }

  function _fetchAndFill(modalContent, formName) {
    var fields = _getFormFields(modalContent, formName);
    if (!fields.loaiTiecEl || !fields.targetEl) return;

    var loaiTiec = fields.loaiTiecEl.value;
    var banMan = fields.banManEl ? Number(fields.banManEl.value || 0) : 0;
    var banChay = fields.banChayEl ? Number(fields.banChayEl.value || 0) : 0;
    var totalTables = banMan + banChay;

    if (!loaiTiec || totalTables <= 0) {
      return;
    }

    var payload = {
      List: 'API_LayDichVuUuDaiTheoLoaiTiec',
      Func: 'View',
      Loaitiecid: loaiTiec,
      Soluongban: totalTables
    };

    ApiClient.post('/api/API_Gateway_Router', payload)
      .then(function (res) {
        var records = (res && res.records) ? res.records : ((res && res.data) ? res.data : (Array.isArray(res) ? res : []));
        if (!records || records.length === 0) {
          return;
        }

        // Format danh sách khuyến mãi
        var formatted = records.map(function (item, idx) {
          var qty = Number(item.Soluong || 1);
          var qtyStr = qty > 1 ? ' (SL: ' + qty + ')' : '';
          return (idx + 1) + '. ' + item.Tenhang + qtyStr;
        }).join('\n');

        var currentVal = fields.targetEl.value ? fields.targetEl.value.trim() : '';
        if (currentVal === formatted.trim()) {
          return;
        }

        var doUpdate = function () {
          fields.targetEl.value = formatted;
          fields.targetEl.dispatchEvent(new Event('change', { bubbles: true }));
          fields.targetEl.dispatchEvent(new Event('input', { bubbles: true }));
          
          // Thêm style đổi màu nhẹ để báo hiệu vừa được điền tự động
          fields.targetEl.style.setProperty('background-color', 'rgba(16, 185, 129, 0.1)', 'important');
          fields.targetEl.style.setProperty('border-color', '#10b981', 'important');
          setTimeout(function () {
            fields.targetEl.style.removeProperty('background-color');
            fields.targetEl.style.removeProperty('border-color');
          }, 2000);
        };

        if (!currentVal) {
          doUpdate();
        } else {
          // Nếu đã có sẵn nội dung, hỏi xác nhận từ người dùng để tránh đè dữ liệu custom
          if (confirm('Số lượng bàn hoặc loại tiệc đã thay đổi. Bạn có muốn tự động tải lại danh sách khuyến mãi tương ứng không? Nội dung khuyến mãi hiện tại sẽ bị thay thế.')) {
            doUpdate();
          }
        }
      })
      .catch(function (err) {
        console.error('[PromotionAutoFillPlugin] Lỗi tải ưu đãi:', err);
      });
  }

  function _bindForm(modalContent, formName) {
    if (modalContent.dataset.promoAutofillDone === '1') return;
    modalContent.dataset.promoAutofillDone = '1';

    var fields = _getFormFields(modalContent, formName);
    if (!fields.loaiTiecEl) return;

    var handler = function () {
      if (debounceTimeout) clearTimeout(debounceTimeout);
      debounceTimeout = setTimeout(function () {
        _fetchAndFill(modalContent, formName);
      }, 500);
    };

    fields.loaiTiecEl.addEventListener('change', handler);
    if (fields.banManEl) {
      fields.banManEl.addEventListener('input', handler);
      fields.banManEl.addEventListener('change', handler);
    }
    if (fields.banChayEl) {
      fields.banChayEl.addEventListener('input', handler);
      fields.banChayEl.addEventListener('change', handler);
    }
  }

  var _observer = null;
  function init() {
    if (_observer) _observer.disconnect();

    _observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType !== Node.ELEMENT_NODE) return;

          var formBody = null;
          var bodyWithFormName = node.querySelector('[data-form-name]');
          if (bodyWithFormName) {
            var formName = bodyWithFormName.getAttribute('data-form-name');
            if (SUPPORTED_FORMS.indexOf(formName) !== -1) {
              formBody = bodyWithFormName;
            }
          }

          if (formBody) {
            var modalContentEl = formBody.closest('.modal-content') || formBody;
            var formName = formBody.getAttribute('data-form-name');
            
            var checkInterval = setInterval(function () {
              // Chờ cho các control input xuất hiện trong form động
              var loaiTiecEl = modalContentEl.querySelector('[name="Loaitiecid"]');
              if (loaiTiecEl) {
                clearInterval(checkInterval);
                _bindForm(modalContentEl, formName);
              }
            }, 100);
            setTimeout(function () { clearInterval(checkInterval); }, 5000);
          }
        });
      });
    });

    _observer.observe(document.body, { childList: true, subtree: true });
  }

  // Khởi chạy khi load plugin
  init();

  return {
    init: init
  };
})();
