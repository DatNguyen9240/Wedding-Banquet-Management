/**
 * PromotionAutoFillPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Tự động tính toán tổng số bàn và tra cứu danh sách quà tặng ưu đãi (khuyến mãi)
 * dựa trên loại tiệc và số bàn chính thức. Tự động điền vào Ghi chú (đối với Phiếu cọc)
 * hoặc Khuyến mãi (đối với Hợp đồng).
 * Đồng thời chặn lưu form và tô đỏ ô nhập liệu nếu số bàn không hợp lệ so với sảnh.
 */
var PromotionAutoFillPlugin = (function () {
  var SUPPORTED_FORMS = ['frmBiennhancoccho', 'frmHopDong', 'frmKhachThamQuan'];
  var debounceTimeout = null;
  var hallCache = {};

  // Tải và cache danh sách sảnh kèm sức chứa (Min/Max bàn)
  function _ensureHallCache() {
    if (Object.keys(hallCache).length > 0) {
      return Promise.resolve(hallCache);
    }
    return ApiClient.post('/api/API_Gateway_Router', {
      List: 'API_DanhSachSanh',
      Func: 'View'
    }).then(function (res) {
      var records = (res && res.records) ? res.records : ((res && res.data) ? res.data : (Array.isArray(res) ? res : []));
      records.forEach(function (r) {
        var id = r['Mã sảnh'] || r.Sanhtiecid || r.id;
        if (id) {
          hallCache[id] = {
            id: id,
            name: r['Tên sảnh'] || r.Tensanhtiec || r.text || r.name,
            min: Number(r['Bàn tối thiểu (Min)'] || r.SLBanMin || 0),
            max: Number(r['Bàn tối đa (Max)'] || r.SLBanMax || 0)
          };
        }
      });
      return hallCache;
    }).catch(function (err) {
      console.error('[PromotionAutoFillPlugin] Lỗi tải danh sách sảnh:', err);
      return hallCache;
    });
  }

  function _getFormFields(modalContent, formName) {
    var loaiTiecEl = modalContent.querySelector('[name="Loaitiecid"]');
    var banManEl = null;
    var banChayEl = null;
    var targetEl = null;

    if (formName === 'frmKhachThamQuan') {
      banManEl = modalContent.querySelector('[name="SobanMan"]');
      banChayEl = modalContent.querySelector('[name="SobanChay"]');
      targetEl = modalContent.querySelector('[name="Ghichu"]');
    } else {
      banManEl = modalContent.querySelector('[name="SobanManchinhthuc"]');
      banChayEl = modalContent.querySelector('[name="SobanChaychinhthuc"]');
      if (formName === 'frmBiennhancoccho') {
        targetEl = modalContent.querySelector('[name="Ghichu"]');
      } else if (formName === 'frmHopDong') {
        targetEl = modalContent.querySelector('[name="DSKhuyenMai"]');
      }
    }

    return {
      loaiTiecEl: loaiTiecEl,
      banManEl: banManEl,
      banChayEl: banChayEl,
      targetEl: targetEl
    };
  }

  function _showErrorLabel(inputEl, msg) {
    if (!inputEl) return;
    var container = inputEl.parentNode;
    if (!container) return;

    var errLabel = container.querySelector('.promo-error-label');
    if (!errLabel) {
      errLabel = document.createElement('div');
      errLabel.className = 'promo-error-label';
      errLabel.style.cssText = 'color: #ef4444; font-size: 11px; margin-top: 4px; font-weight: 600; display: flex; align-items: center; gap: 4px; line-height: 1.2;';
    }
    errLabel.innerHTML = '<span class="material-symbols-outlined" style="font-size:14px; color:#ef4444; font-variation-settings:\'FILL\' 1;">error</span>' + msg;

    // Chèn ngay dưới inputEl
    if (inputEl.nextSibling) {
      container.insertBefore(errLabel, inputEl.nextSibling);
    } else {
      container.appendChild(errLabel);
    }
  }

  function _clearErrorLabel(inputEl) {
    if (!inputEl) return;
    var container = inputEl.parentNode;
    if (!container) return;
    var errLabel = container.querySelector('.promo-error-label');
    if (errLabel) {
      errLabel.remove();
    }
  }

  // Thực thi kiểm tra lỗi trực quan (tô đỏ ô nhập liệu) ngay lập tức
  function _validateLive(modalContent, formName) {
    var fields = _getFormFields(modalContent, formName);
    var sanhInput = modalContent.querySelector('[name="JsonSanhTiec"]') || modalContent.querySelector('[name="SanhTiecID"]');
    if (!fields.banManEl) return;

    var clearError = function () {
      fields.banManEl.style.removeProperty('border-color');
      fields.banManEl.style.removeProperty('background-color');
      fields.banManEl.removeAttribute('title');
      _clearErrorLabel(fields.banManEl);
      if (fields.banChayEl) {
        fields.banChayEl.style.removeProperty('border-color');
        fields.banChayEl.style.removeProperty('background-color');
        fields.banChayEl.removeAttribute('title');
        _clearErrorLabel(fields.banChayEl);
      }
    };

    if (!sanhInput || !sanhInput.value) {
      clearError();
      return;
    }

    var banMan = Number(fields.banManEl.value || 0);
    var banChay = fields.banChayEl ? Number(fields.banChayEl.value || 0) : 0;
    var totalTables = banMan + banChay;

    var selectedIds = sanhInput.value.split(',').map(function (id) { return id.trim(); }).filter(Boolean);
    if (selectedIds.length === 0) {
      clearError();
      return;
    }

    var totalMin = 0;
    var totalMax = 0;
    var names = [];
    var hasValidCache = false;

    selectedIds.forEach(function (id) {
      var hall = hallCache[id];
      if (hall) {
        totalMin += hall.min;
        totalMax += hall.max;
        names.push(hall.name);
        hasValidCache = true;
      }
    });

    if (!hasValidCache) {
      clearError();
      return;
    }

    var isInvalid = (totalMax > 0 && totalTables > totalMax);

    if (isInvalid) {
      var msg = '';
      var shortMsg = '';
      if (totalMax > 0 && totalTables > totalMax) {
        msg = 'Tổng số bàn chính thức (' + totalTables + ' bàn) vượt quá số bàn tối đa của sảnh ' + names.join(', ') + ' là ' + totalMax + ' bàn.';
        shortMsg = 'Tổng ' + totalTables + ' bàn (Tối đa: ' + totalMax + ')';
      }

      fields.banManEl.style.setProperty('border-color', '#ef4444', 'important');
      fields.banManEl.style.setProperty('background-color', 'rgba(239, 68, 68, 0.08)', 'important');
      fields.banManEl.setAttribute('title', msg);
      _showErrorLabel(fields.banManEl, shortMsg);

      if (fields.banChayEl) {
        fields.banChayEl.style.setProperty('border-color', '#ef4444', 'important');
        fields.banChayEl.style.setProperty('background-color', 'rgba(239, 68, 68, 0.08)', 'important');
        fields.banChayEl.setAttribute('title', msg);
        _showErrorLabel(fields.banChayEl, shortMsg);
      }
    } else {
      clearError();
    }
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
      JsonData: JSON.stringify({
        Loaitiecid: loaiTiec,
        Soluongban: totalTables,
        Nhahangid: ''
      })
    };

    ApiClient.post('/api/API_Gateway_Router', payload)
      .then(function (res) {
        var records = (res && res.records) ? res.records : ((res && res.data) ? res.data : (Array.isArray(res) ? res : []));
        if (!records || records.length === 0) {
          return;
        }

        // Format danh sách khuyến mãi với cơ chế fallback thông minh
        var formatted = records.map(function (item, idx) {
          var qty = Number(item.Soluong || item.soluong || 1);
          var qtyStr = qty > 1 ? ' (SL: ' + qty + ')' : '';

          // 1. Thử lấy từ các cột tên quen thuộc
          var name = item.Tenhang || item.TenHang || item.tenhang || item.tenHang || item.TenMon || item.tenMon || item.Tenmon || item.tenmon || '';

          // 2. Nếu trống, tìm cột nào có chứa chữ 'ten', 'name', 'diengiai', 'desc'
          if (!name) {
            var keys = Object.keys(item);
            for (var i = 0; i < keys.length; i++) {
              var k = keys[i];
              var kl = k.toLowerCase();
              if (kl.indexOf('ten') > -1 || kl.indexOf('name') > -1 || kl.indexOf('diengiai') > -1 || kl.indexOf('desc') > -1) {
                name = item[k];
                break;
              }
            }
          }

          // 3. Nếu vẫn trống, thử lấy từ cột mã hàng quen thuộc
          if (!name) {
            name = item.Mahang || item.mahang || item.MaHang || item.maHang || '';
          }

          // 4. Nếu vẫn trống, tìm cột nào có chứa chữ 'ma', 'code', 'id' (trừ cột ID hệ thống)
          if (!name) {
            var keys = Object.keys(item);
            for (var i = 0; i < keys.length; i++) {
              var k = keys[i];
              var kl = k.toLowerCase();
              if (kl !== 'userautoid' && kl !== 'documentid' && (kl.indexOf('ma') > -1 || kl.indexOf('id') > -1 || kl.indexOf('code') > -1)) {
                name = item[k];
                break;
              }
            }
          }

          // 5. Cuối cùng, nếu vẫn trống, lấy bất kỳ trường nào khác rỗng và không phải ID hệ thống
          if (!name) {
            var keys = Object.keys(item);
            for (var i = 0; i < keys.length; i++) {
              var k = keys[i];
              var kl = k.toLowerCase();
              if (kl !== 'userautoid' && kl !== 'documentid' && kl !== 'stt' && item[k]) {
                name = item[k];
                break;
              }
            }
          }

          return (idx + 1) + '. ' + (name || 'Ưu đãi') + qtyStr;
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
      _validateLive(modalContent, formName); // Thực thi kiểm tra tô đỏ trực quan ngay lập tức

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

    // Lắng nghe thêm cả sự thay đổi của Sảnh để kích hoạt nạp lại khuyến mãi khi Auto-fill điền bàn
    var sanhInput = modalContent.querySelector('[name="JsonSanhTiec"]') || modalContent.querySelector('[name="SanhTiecID"]');
    if (sanhInput) {
      sanhInput.addEventListener('change', handler);
    }

    // Thực thi check live một lần khi mới mở form
    _validateLive(modalContent, formName);
  }

  // Đã bỏ chặn lưu số bàn vượt quá sức chứa sảnh để người dùng vẫn nhập và lưu được bình thường (chỉ giữ lại cảnh báo trực quan)
  function _bindValidation(modalContent, formName) {
    // Không chặn lưu nữa
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

            // Đảm bảo cache sảnh đã được tải trước khi người dùng kịp tương tác
            _ensureHallCache();

            var checkInterval = setInterval(function () {
              var loaiTiecEl = modalContentEl.querySelector('[name="Loaitiecid"]');
              if (loaiTiecEl) {
                clearInterval(checkInterval);
                _bindForm(modalContentEl, formName);
                _bindValidation(modalContentEl, formName);
              }
            }, 100);
            setTimeout(function () { clearInterval(checkInterval); }, 5000);
          }
        });
      });
    });

    _observer.observe(document.body, { childList: true, subtree: true });
  }

  init();

  return {
    init: init
  };
})();
