/**
 * DoiMonPlugin (REQ-03, REQ-04)
 * ─────────────────────────────────────────────────────────────────────
 * Quản lý tính năng Đổi Món & Bù Giá cho Hợp đồng tiệc cưới.
 * Cho phép chọn món gốc cần thay thế, món mới trong thực đơn,
 * tự động tính chênh lệch đơn giá x số lượng bàn và lưu qua API SaveDoiMon.
 */
var DoiMonPlugin = (function () {
  var SUPPORTED_FORMS = ['frmHopDong', 'v_DanhSachHopDong', '0540', 'tbmk_Hopdong'];
  var _menuCatalogCache = null;

  function _loadCatalog() {
    if (_menuCatalogCache) return Promise.resolve(_menuCatalogCache);

    return ApiClient.post('/api/API_Gateway_Router', {
      List: 'dmHanghoa',
      Func: 'View'
    }).then(function (res) {
      var list = (res && res.records) ? res.records : ((res && res.data) ? res.data : (Array.isArray(res) ? res : []));
      _menuCatalogCache = list;
      return list;
    }).catch(function (err) {
      console.error('[DoiMonPlugin] Lỗi tải danh mục món:', err);
      return [];
    });
  }

  function _openDoiMonModal(formEl) {
    var sohopdongInput = formEl.querySelector('[name="Sohopdong"]');
    var sohopdong = sohopdongInput ? sohopdongInput.value : '';

    var soBanInput = formEl.querySelector('[name="TongSoBan"]') || formEl.querySelector('[name="SobanManchinhthuc"]');
    var soBan = soBanInput ? (parseFloat(soBanInput.value) || 10) : 10;

    _loadCatalog().then(function (catalog) {
      var overlay = document.createElement('div');
      overlay.className = 'modal-backdrop fade in';
      overlay.style.cssText = 'position:fixed;top:0;left:0;width:100vw;height:100vh;background:rgba(15,23,42,0.8);z-index:99999;display:flex;align-items:center;justify-content:center;backdrop-filter:blur(4px);';

      var modal = document.createElement('div');
      modal.style.cssText = 'background:#1e293b;border:1px solid rgba(255,255,255,0.15);border-radius:16px;width:92%;max-width:850px;max-height:88vh;display:flex;flex-direction:column;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);overflow:hidden;color:#f8fafc;font-family:inherit;';

      var headerHtml = '<div style="padding:18px 24px;border-bottom:1px solid rgba(255,255,255,0.1);display:flex;justify-content:space-between;align-items:center;">' +
        '<div style="display:flex;align-items:center;gap:10px;">' +
          '<span style="font-size:24px;">🔄</span>' +
          '<div>' +
            '<h3 style="margin:0;font-size:18px;font-weight:600;color:#f1f5f9;">Đổi Món & Bù Giá Thực Đơn</h3>' +
            '<p style="margin:2px 0 0;font-size:13px;color:#94a3b8;">Hợp đồng: ' + (sohopdong || 'Đang tạo mới') + ' | Quy mô: ' + soBan + ' bàn</p>' +
          '</div>' +
        '</div>' +
        '<button type="button" class="btn-close-doimon" style="background:none;border:none;color:#94a3b8;font-size:24px;cursor:pointer;">&times;</button>' +
      '</div>';

      var bodyHtml = '<div style="padding:24px;overflow-y:auto;flex:1;display:flex;flex-direction:column;gap:16px;">' +
        '<div style="background:#0f172a;padding:16px;border-radius:12px;border:1px solid rgba(255,255,255,0.08);display:grid;grid-template-columns:1fr 1fr;gap:16px;">' +
          '<div>' +
            '<label style="display:block;font-size:13px;font-weight:500;color:#94a3b8;margin-bottom:6px;">Món gốc cần đổi (Từ thực đơn đã chọn)</label>' +
            '<select id="selMonGoc" style="width:100%;padding:9px 12px;border-radius:8px;background:#1e293b;color:#f8fafc;border:1px solid rgba(255,255,255,0.2);font-size:14px;">' +
              '<option value="">-- Chọn món trong thực đơn --</option>' +
            '</select>' +
            '<div id="lblGiaGoc" style="font-size:12px;color:#38bdf8;margin-top:6px;font-weight:500;">Đơn giá gốc: 0 VNĐ</div>' +
          '</div>' +
          '<div>' +
            '<label style="display:block;font-size:13px;font-weight:500;color:#94a3b8;margin-bottom:6px;">Món mới thay thế (Từ danh mục)</label>' +
            '<select id="selMonMoi" style="width:100%;padding:9px 12px;border-radius:8px;background:#1e293b;color:#f8fafc;border:1px solid rgba(255,255,255,0.2);font-size:14px;">' +
              '<option value="">-- Chọn món thay thế --</option>' +
            '</select>' +
            '<div id="lblGiaMoi" style="font-size:12px;color:#4ade80;margin-top:6px;font-weight:500;">Đơn giá mới: 0 VNĐ</div>' +
          '</div>' +
        '</div>' +

        '<div style="background:#0f172a;padding:16px;border-radius:12px;border:1px solid rgba(255,255,255,0.08);display:grid;grid-template-columns:repeat(3, 1fr);gap:16px;align-items:center;">' +
          '<div>' +
            '<label style="font-size:12px;color:#94a3b8;">Chênh lệch / bàn</label>' +
            '<div id="lblChenhLech" style="font-size:16px;font-weight:700;color:#f59e0b;margin-top:4px;">0 VNĐ</div>' +
          '</div>' +
          '<div>' +
            '<label style="font-size:12px;color:#94a3b8;">Số lượng bàn áp dụng</label>' +
            '<input type="number" id="txtSoLuongBan" value="' + soBan + '" min="1" style="width:100%;padding:6px 10px;border-radius:6px;background:#1e293b;color:#f8fafc;border:1px solid rgba(255,255,255,0.2);margin-top:4px;font-size:14px;">' +
          '</div>' +
          '<div>' +
            '<label style="font-size:12px;color:#94a3b8;">Tổng tiền bù phát sinh</label>' +
            '<div id="lblTongBu" style="font-size:18px;font-weight:700;color:#10b981;margin-top:4px;">0 VNĐ</div>' +
          '</div>' +
        '</div>' +

        '<div>' +
          '<label style="display:block;font-size:13px;font-weight:500;color:#94a3b8;margin-bottom:6px;">Ghi chú đổi món</label>' +
          '<input type="text" id="txtGhiChuDoiMon" placeholder="VD: Khách đổi món súp sang bào ngư theo yêu cầu..." style="width:100%;padding:8px 12px;border-radius:8px;background:#0f172a;color:#f8fafc;border:1px solid rgba(255,255,255,0.2);font-size:13px;">' +
        '</div>' +
      '</div>';

      var footerHtml = '<div style="padding:16px 24px;border-top:1px solid rgba(255,255,255,0.1);display:flex;justify-content:flex-end;gap:12px;background:#0f172a60;">' +
        '<button type="button" class="btn-close-doimon" style="padding:9px 18px;border-radius:8px;background:#334155;color:#f1f5f9;border:none;font-weight:500;cursor:pointer;">Hủy bỏ</button>' +
        '<button type="button" id="btnSaveDoiMon" style="padding:9px 22px;border-radius:8px;background:#2563eb;color:#fff;border:none;font-weight:600;cursor:pointer;">Lưu Đổi Món & Bù Giá</button>' +
      '</div>';

      modal.innerHTML = headerHtml + bodyHtml + footerHtml;
      overlay.appendChild(modal);
      document.body.appendChild(overlay);

      // Điền options cho món gốc từ form hiện tại
      var selGoc = modal.querySelector('#selMonGoc');
      var selMoi = modal.querySelector('#selMonMoi');
      var lblGiaGoc = modal.querySelector('#lblGiaGoc');
      var lblGiaMoi = modal.querySelector('#lblGiaMoi');
      var lblChenhLech = modal.querySelector('#lblChenhLech');
      var txtSoLuongBan = modal.querySelector('#txtSoLuongBan');
      var lblTongBu = modal.querySelector('#lblTongBu');

      catalog.forEach(function (m) {
        var opt = document.createElement('option');
        opt.value = m.Mahang || m.id;
        opt.textContent = (m.Tenhang || m.name) + ' (' + Number(m.Dongia || 0).toLocaleString('vi-VN') + ' đ)';
        opt.dataset.price = m.Dongia || 0;
        opt.dataset.name = m.Tenhang || m.name;
        selGoc.appendChild(opt.cloneNode(true));
        selMoi.appendChild(opt);
      });

      function _calc() {
        var optGoc = selGoc.selectedOptions[0];
        var optMoi = selMoi.selectedOptions[0];
        var pGoc = optGoc ? (parseFloat(optGoc.dataset.price) || 0) : 0;
        var pMoi = optMoi ? (parseFloat(optMoi.dataset.price) || 0) : 0;
        var diff = pMoi - pGoc;
        var sl = parseFloat(txtSoLuongBan.value) || 1;
        var total = diff * sl;

        lblGiaGoc.textContent = 'Đơn giá gốc: ' + pGoc.toLocaleString('vi-VN') + ' VNĐ';
        lblGiaMoi.textContent = 'Đơn giá mới: ' + pMoi.toLocaleString('vi-VN') + ' VNĐ';
        lblChenhLech.textContent = (diff >= 0 ? '+' : '') + diff.toLocaleString('vi-VN') + ' VNĐ';
        lblTongBu.textContent = (total >= 0 ? '+' : '') + total.toLocaleString('vi-VN') + ' VNĐ';
        lblTongBu.style.color = total >= 0 ? '#10b981' : '#ef4444';
      }

      selGoc.addEventListener('change', _calc);
      selMoi.addEventListener('change', _calc);
      txtSoLuongBan.addEventListener('input', _calc);

      function _close() {
        if (overlay && overlay.parentNode) {
          overlay.parentNode.removeChild(overlay);
        }
      }

      modal.querySelectorAll('.btn-close-doimon').forEach(function (b) { b.addEventListener('click', _close); });
      overlay.addEventListener('click', function (e) { if (e.target === overlay) _close(); });

      modal.querySelector('#btnSaveDoiMon').addEventListener('click', function () {
        var optGoc = selGoc.selectedOptions[0];
        var optMoi = selMoi.selectedOptions[0];

        if (!selGoc.value || !selMoi.value) {
          alert('Vui lòng chọn đầy đủ món gốc và món thay thế.');
          return;
        }

        var payload = [{
          MonGocMahang: selGoc.value,
          MonGocTen: optGoc.dataset.name,
          DonGiaGoc: parseFloat(optGoc.dataset.price) || 0,
          MonMoiMahang: selMoi.value,
          MonMoiTen: optMoi.dataset.name,
          DonGiaMoi: parseFloat(optMoi.dataset.price) || 0,
          Soluongban: parseFloat(txtSoLuongBan.value) || 1,
          GhiChu: modal.querySelector('#txtGhiChuDoiMon').value || ''
        }];

        if (sohopdong) {
          ApiClient.post('/api/API_Gateway_Router', {
            List: 'frmHopDong',
            Func: 'SaveDoiMon',
            Sohopdong: sohopdong,
            JsonDoiMon: JSON.stringify(payload)
          }).then(function () {
            if (typeof UIToast !== 'undefined') {
              UIToast.show('Đã lưu thông tin đổi món và bù giá thành công!', 'success');
            }
            _close();
          }).catch(function (err) {
            console.error('Lỗi lưu đổi món:', err);
            alert('Lỗi lưu đổi món: ' + err.message);
          });
        } else {
          // Lưu tạm trên memory form
          formEl._pendingDoiMon = payload;
          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đã ghi nhận đổi món (sẽ lưu khi bấm Lưu Hợp Đồng).', 'info');
          }
          _close();
        }
      });
    });
  }

  function _injectButton(formEl) {
    if (formEl.querySelector('.btn-doimon-trigger')) return;

    var targetContainer = formEl.querySelector('.form-header-actions') ||
      formEl.querySelector('.modal-header') ||
      formEl.querySelector('.action-toolbar') ||
      formEl.querySelector('.form-section-title') ||
      formEl.querySelector('.row:first-child');

    if (!targetContainer) targetContainer = formEl;

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'btn btn-secondary btn-doimon-trigger';
    btn.style.cssText = 'display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:8px;font-size:13px;font-weight:500;background:linear-gradient(135deg, #0284c7, #0369a1);color:#f8fafc;border:1px solid rgba(255,255,255,0.15);cursor:pointer;margin:4px;';
    btn.innerHTML = '<span>🔄</span> <span>Đổi Món Bù Giá</span>';

    btn.addEventListener('click', function (e) {
      e.preventDefault();
      _openDoiMonModal(formEl);
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
            SUPPORTED_FORMS.forEach(function (name) {
              if (!formBody && node.querySelector) {
                var found = node.querySelector('[data-form-name="' + name + '"]');
                if (found) formBody = found;
              }
            });
          }
          if (!formBody && node.querySelector && (node.querySelector('[name="Sohopdong"]') || node.querySelector('[name="Sobiennhan"]'))) {
            formBody = node.querySelector('form') || node;
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
    openDoiMonModal: _openDoiMonModal
  };
})();
