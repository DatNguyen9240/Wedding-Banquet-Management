/**
 * MauTrangTriPlugin (REQ-07)
 * ─────────────────────────────────────────────────────────────────────
 * Thư viện / Gallery mẫu trang trí tiệc cưới & sự kiện.
 * Tự động gắn nút "Chọn Mẫu Trang Trí" trên form Hợp đồng (frmHopDong).
 * Cho phép xem hình ảnh trực quan, đơn giá, mô tả và áp dụng vào hợp đồng.
 */
var MauTrangTriPlugin = (function () {
  var SUPPORTED_FORMS = ['frmHopDong', 'v_DanhSachHopDong'];
  var _cachedDecorList = null;

  function _loadDecorThemes() {
    if (_cachedDecorList) return Promise.resolve(_cachedDecorList);

    return ApiClient.post('/api/API_Gateway_Router', {
      List: 'API_DanhSachMauTrangTri',
      Func: 'View'
    }).then(function (res) {
      var records = (res && res.records) ? res.records : ((res && res.data) ? res.data : (Array.isArray(res) ? res : []));
      if (!records || records.length === 0) {
        records = [
          { MauTrangTriID: 'MTT01', TenMau: 'Mẫu Tiêu Chuẩn (Standard)', HinhAnhUrl: '/assets/images/decor/decor_standard.jpg', DonGia: 0, MoTa: 'Gói trang trí bàn tiệc và lối đi tiêu chuẩn của sảnh' },
          { MauTrangTriID: 'MTT02', TenMau: 'Mẫu Rustic Garden (Hoa tươi mộc)', HinhAnhUrl: '/assets/images/decor/decor_rustic.jpg', DonGia: 5000000, MoTa: 'Phong cách vintage mộc mạc với hoa tươi và nến thơm' },
          { MauTrangTriID: 'MTT03', TenMau: 'Mẫu Royal Elegance (Hoàng gia)', HinhAnhUrl: '/assets/images/decor/decor_royal.jpg', DonGia: 10000000, MoTa: 'Tông vàng gold kết hợp hoa lụa cao cấp và backdrop pha lê' },
          { MauTrangTriID: 'MTT04', TenMau: 'Mẫu Luxury Crystal (Pha lê ánh sao)', HinhAnhUrl: '/assets/images/decor/decor_crystal.jpg', DonGia: 15000000, MoTa: 'Trần sao ánh sáng lung linh và tháp ly pha lê đặc biệt' }
        ];
      }
      _cachedDecorList = records;
      return records;
    }).catch(function (err) {
      console.warn('[MauTrangTriPlugin] Dùng danh mục mặc định:', err);
      _cachedDecorList = [
        { MauTrangTriID: 'MTT01', TenMau: 'Mẫu Tiêu Chuẩn (Standard)', HinhAnhUrl: '/assets/images/decor/decor_standard.jpg', DonGia: 0, MoTa: 'Gói trang trí bàn tiệc và lối đi tiêu chuẩn của sảnh' },
        { MauTrangTriID: 'MTT02', TenMau: 'Mẫu Rustic Garden (Hoa tươi mộc)', HinhAnhUrl: '/assets/images/decor/decor_rustic.jpg', DonGia: 5000000, MoTa: 'Phong cách vintage mộc mạc với hoa tươi và nến thơm' },
        { MauTrangTriID: 'MTT03', TenMau: 'Mẫu Royal Elegance (Hoàng gia)', HinhAnhUrl: '/assets/images/decor/decor_royal.jpg', DonGia: 10000000, MoTa: 'Tông vàng gold kết hợp hoa lụa cao cấp và backdrop pha lê' },
        { MauTrangTriID: 'MTT04', TenMau: 'Mẫu Luxury Crystal (Pha lê ánh sao)', HinhAnhUrl: '/assets/images/decor/decor_crystal.jpg', DonGia: 15000000, MoTa: 'Trần sao ánh sáng lung linh và tháp ly pha lê đặc biệt' }
      ];
      return _cachedDecorList;
    });
  }

  function _openGalleryModal(formEl) {
    _loadDecorThemes().then(function (themes) {
      var overlay = document.createElement('div');
      overlay.className = 'modal-backdrop fade in';
      overlay.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(15,23,42,0.75);z-index:99999;display:flex;align-items:center;justify-content:center;backdrop-filter:blur(4px);';

      var modal = document.createElement('div');
      modal.className = 'decor-gallery-modal';
      modal.style.cssText = 'background:#1e293b;border:1px solid rgba(255,255,255,0.15);border-radius:16px;width:90%;max-width:960px;max-height:88vh;display:flex;flex-direction:column;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);overflow:hidden;color:#f8fafc;font-family:inherit;animation:decorFadeIn 0.25s ease-out;';

      var currentDecorID = '';
      var inputTarget = formEl.querySelector('[name="MauTrangTriID"]');
      if (inputTarget) currentDecorID = inputTarget.value;

      var headerHtml = '<div style="padding:18px 24px;border-bottom:1px solid rgba(255,255,255,0.1);display:flex;justify-content:space-between;align-items:center;">' +
        '<div style="display:flex;align-items:center;gap:10px;">' +
          '<span style="font-size:24px;">🎨</span>' +
          '<div>' +
            '<h3 style="margin:0;font-size:18px;font-weight:600;color:#f1f5f9;">Thư Viện Mẫu Trang Trí Tiệc Cưới & Sự Kiện</h3>' +
            '<p style="margin:2px 0 0;font-size:13px;color:#94a3b8;">Chọn concept không gian trang trí cho hợp đồng</p>' +
          '</div>' +
        '</div>' +
        '<button type="button" class="btn-close-decor" style="background:none;border:none;color:#94a3b8;font-size:24px;cursor:pointer;line-height:1;">&times;</button>' +
      '</div>';

      var cardsHtml = '<div style="padding:24px;overflow-y:auto;display:grid;grid-template-columns:repeat(auto-fit, minmax(260px, 1fr));gap:20px;flex:1;">';

      themes.forEach(function (t) {
        var isSelected = currentDecorID === t.MauTrangTriID;
        var formattedPrice = Number(t.DonGia) > 0 ? (Number(t.DonGia).toLocaleString('vi-VN') + ' VNĐ') : 'Bao gồm trong gói';
        var borderStyle = isSelected ? 'border:2px solid #3b82f6;background:#1e3a8a25;' : 'border:1px solid rgba(255,255,255,0.08);background:#0f172a;';

        cardsHtml += '<div class="decor-card" data-id="' + t.MauTrangTriID + '" style="' + borderStyle + 'border-radius:12px;overflow:hidden;display:flex;flex-direction:column;transition:transform 0.2s, box-shadow 0.2s;cursor:pointer;">' +
          '<div style="height:140px;background:linear-gradient(135deg, #334155, #1e293b);position:relative;overflow:hidden;display:flex;align-items:center;justify-content:center;">' +
            '<div style="font-size:48px;opacity:0.6;">💐</div>' +
            '<div style="position:absolute;top:10px;right:10px;background:rgba(0,0,0,0.6);padding:4px 10px;border-radius:20px;font-size:12px;font-weight:600;color:#38bdf8;">' + formattedPrice + '</div>' +
          '</div>' +
          '<div style="padding:16px;flex:1;display:flex;flex-direction:column;justify-content:space-between;">' +
            '<div>' +
              '<h4 style="margin:0 0 6px;font-size:15px;font-weight:600;color:#f8fafc;">' + t.TenMau + '</h4>' +
              '<p style="margin:0 0 12px;font-size:13px;color:#94a3b8;line-height:1.4;">' + (t.MoTa || 'Mẫu trang trí tiêu chuẩn phong cách tiệc sang trọng.') + '</p>' +
            '</div>' +
            '<button type="button" class="btn-select-theme" data-id="' + t.MauTrangTriID + '" data-name="' + t.TenMau + '" style="width:100%;padding:8px 12px;border-radius:8px;font-weight:600;font-size:13px;border:none;cursor:pointer;' +
              (isSelected ? 'background:#3b82f6;color:#fff;' : 'background:#334155;color:#e2e8f0;') + '">' +
              (isSelected ? '✓ Đang chọn' : 'Chọn mẫu này') +
            '</button>' +
          '</div>' +
        '</div>';
      });

      cardsHtml += '</div>';

      var footerHtml = '<div style="padding:14px 24px;border-top:1px solid rgba(255,255,255,0.1);display:flex;justify-content:flex-end;gap:12px;background:#0f172a60;">' +
        '<button type="button" class="btn-close-decor" style="padding:8px 18px;border-radius:8px;background:#334155;color:#f1f5f9;border:none;font-weight:500;cursor:pointer;">Đóng</button>' +
      '</div>';

      modal.innerHTML = headerHtml + cardsHtml + footerHtml;
      overlay.appendChild(modal);
      document.body.appendChild(overlay);

      function _close() {
        if (overlay && overlay.parentNode) {
          overlay.parentNode.removeChild(overlay);
        }
      }

      overlay.querySelectorAll('.btn-close-decor').forEach(function (btn) {
        btn.addEventListener('click', _close);
      });

      overlay.addEventListener('click', function (e) {
        if (e.target === overlay) _close();
      });

      overlay.querySelectorAll('.btn-select-theme, .decor-card').forEach(function (elem) {
        elem.addEventListener('click', function (e) {
          e.stopPropagation();
          var id = this.getAttribute('data-id');
          var selectedTheme = themes.find(function (item) { return item.MauTrangTriID === id; });
          if (selectedTheme) {
            _applyTheme(formEl, selectedTheme);
            _close();
          }
        });
      });
    });
  }

  function _applyTheme(formEl, theme) {
    var input = formEl.querySelector('[name="MauTrangTriID"]');
    if (!input) {
      input = document.createElement('input');
      input.type = 'hidden';
      input.name = 'MauTrangTriID';
      formEl.appendChild(input);
    }
    input.value = theme.MauTrangTriID;

    // Trigger change event
    var evt = new Event('change', { bubbles: true });
    input.dispatchEvent(evt);

    // Cập nhật label/badge hiển thị trên form nếu có
    var badge = formEl.querySelector('.selected-decor-badge');
    if (!badge) {
      badge = document.createElement('span');
      badge.className = 'selected-decor-badge';
      badge.style.cssText = 'display:inline-flex;align-items:center;gap:6px;background:#1e3a8a;color:#93c5fd;padding:4px 10px;border-radius:20px;font-size:12px;font-weight:600;margin-left:10px;';
      var triggerBtn = formEl.querySelector('.btn-decor-gallery-trigger');
      if (triggerBtn && triggerBtn.parentNode) {
        triggerBtn.parentNode.insertBefore(badge, triggerBtn.nextSibling);
      }
    }
    badge.innerHTML = '🎨 ' + theme.TenMau;

    if (typeof UIToast !== 'undefined') {
      UIToast.show('Đã áp dụng mẫu trang trí: ' + theme.TenMau, 'success');
    }
  }

  function _injectButton(formEl) {
    if (formEl.querySelector('.btn-decor-gallery-trigger')) return;

    var targetContainer = formEl.querySelector('.form-header-actions') ||
      formEl.querySelector('.modal-header') ||
      formEl.querySelector('.action-toolbar') ||
      formEl.querySelector('.form-section-title') ||
      formEl.querySelector('.row:first-child');

    if (!targetContainer) targetContainer = formEl;

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn btn-secondary btn-decor-gallery-trigger';
    btn.style.cssText = 'display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:8px;font-size:13px;font-weight:500;background:linear-gradient(135deg, #475569, #334155);color:#f8fafc;border:1px solid rgba(255,255,255,0.15);cursor:pointer;margin:4px;';
    btn.innerHTML = '<span>🎨</span> <span>Mẫu Trang Trí</span>';

    btn.addEventListener('click', function (e) {
      e.preventDefault();
      _openGalleryModal(formEl);
    });

    targetContainer.appendChild(btn);
  }

  function init() {
    var _observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        if (!mutation.addedNodes || mutation.addedNodes.length === 0) return;
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType !== 1) return;
          var formBody = null;
          if (node.hasAttribute && node.hasAttribute('data-form-name')) {
            var fName = node.getAttribute('data-form-name');
            if (SUPPORTED_FORMS.indexOf(fName) !== -1) formBody = node;
          }
          if (!formBody) {
            var found = node.querySelector ? node.querySelector('[data-form-name="frmHopDong"]') : null;
            if (found) formBody = found;
          }
          if (formBody) {
            setTimeout(function () {
              _injectButton(formBody);
            }, 300);
          }
        });
      });
    });

    _observer.observe(document.body, { childList: true, subtree: true });
  }

  init();

  return {
    init: init,
    openGallery: _openGalleryModal
  };
})();
