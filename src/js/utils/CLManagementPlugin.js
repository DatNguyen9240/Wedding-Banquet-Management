/**
 * CLManagementPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Tự động tính toán định biên nhân sự Casual Labor (CL) đề xuất dựa trên 
 * số bàn chính thức và định biên CL của từng loại hình tiệc.
 * Công thức: CL đề xuất = Định biên × Số bàn chính thức - Số NV phân công
 */
var CLManagementPlugin = (function () {

  // Tìm input element theo name (không phân biệt hoa thường)
  function _findInput(container, name) {
    if (!container || !name) return null;
    var target = name.toLowerCase();
    var inputs = container.querySelectorAll('input, select, textarea');
    for (var i = 0; i < inputs.length; i++) {
      var n = inputs[i].getAttribute('name');
      if (n && n.toLowerCase() === target) {
        return inputs[i];
      }
    }
    return null;
  }

  // Thực hiện tính toán và đồng bộ giao diện
  function calculateAndSync(container, ratioFromDb) {
    var tablesInput = _findInput(container, 'SobanManchinhthuc');
    var ratioInput = _findInput(container, 'DinhBienCL');
    var staffInput = _findInput(container, 'SoNVPhanCong');
    var proposedInput = _findInput(container, 'CLDeXuat');

    if (!ratioInput || !proposedInput) return;

    var tables = tablesInput ? parseFloat(tablesInput.value || 0) : 0;
    
    // Nếu có tỷ lệ định biên truyền trực tiếp (khi load cấu hình), ưu tiên sử dụng
    var ratio = ratioInput.value;
    if (ratioFromDb !== undefined && ratioFromDb !== null) {
      ratio = ratioFromDb;
      ratioInput.value = ratio;
      // Gửi event để cập nhật state trong form engine
      ratioInput.dispatchEvent(new Event('change', { bubbles: true }));
      ratioInput.dispatchEvent(new Event('input', { bubbles: true }));
    }
    ratio = parseFloat(ratio || 0);

    var staff = staffInput ? parseInt(staffInput.value || 0, 10) : 0;

    // Tính toán: CL đề xuất = Định biên × Số bàn - Số NV phân công (làm tròn số nguyên)
    var proposed = Math.max(0, Math.round(ratio * tables - staff));

    proposedInput.value = proposed;
    proposedInput.dispatchEvent(new Event('change', { bubbles: true }));
    proposedInput.dispatchEvent(new Event('input', { bubbles: true }));
  }

  function onInitModal(formName, isEdit, modalEl, targetRow, MODULE_CONFIG) {
    if (formName !== 'frmBEO') return;

    var container = modalEl.querySelector('.modal-body') || modalEl;

    // Chờ DOM hiển thị hoàn toàn để tìm chính xác các trường
    setTimeout(function () {
      var tablesInput = _findInput(container, 'SobanManchinhthuc');
      var ratioInput = _findInput(container, 'DinhBienCL');
      var staffInput = _findInput(container, 'SoNVPhanCong');

      if (!ratioInput) return;

      var loaiTiecId = targetRow ? (targetRow.Loaitiecid || targetRow.loaitiecid || '') : '';
      var loaiHinhSuKien = targetRow ? (targetRow.LoaiHinhSuKien || targetRow.loaihinhsukien || '') : '';

      // 1. Kiểm tra xem Định biên CL đã có lưu trên Hợp đồng chưa
      var savedRatio = targetRow ? targetRow.DinhBienCL : null;

      if (savedRatio !== null && savedRatio !== undefined && savedRatio !== '' && parseFloat(savedRatio) > 0) {
        // Đã có định biên lưu sẵn
        calculateAndSync(container);
      } else if (typeof SystemDataService !== 'undefined') {
        // Chưa có định biên lưu sẵn -> Tải định biên mặc định từ Danh mục loại hình tiệc
        SystemDataService.getBanquetTypes(true).then(function (types) {
          var matchedType = types.find(function (t) {
            var id = t.Loaitiecid || t['Mã loại'] || '';
            var name = t.Tenloaitiec || t['Loại hình tiệc'] || '';
            return (id && loaiTiecId && String(id).toLowerCase() === String(loaiTiecId).toLowerCase()) ||
                   (name && loaiHinhSuKien && String(name).toLowerCase() === String(loaiHinhSuKien).toLowerCase());
          });

          var ratio = matchedType ? parseFloat(matchedType['Định biên'] || matchedType.DinhBienCL || 0) : 0.20;
          calculateAndSync(container, ratio);
        }).catch(function (err) {
          console.error('[CLManagementPlugin] Lỗi tải danh mục loại hình tiệc:', err);
          calculateAndSync(container, 0.20); // Fallback mặc định
        });
      } else {
        calculateAndSync(container);
      }

      // 2. Gán các event listener để tính toán thời gian thực khi nhập liệu
      var handler = function () {
        calculateAndSync(container);
      };

      if (tablesInput) {
        tablesInput.addEventListener('input', handler);
        tablesInput.addEventListener('change', handler);
      }
      if (staffInput) {
        staffInput.addEventListener('input', handler);
        staffInput.addEventListener('change', handler);
      }
      if (ratioInput) {
        ratioInput.addEventListener('input', handler);
        ratioInput.addEventListener('change', handler);
      }
    }, 150);
  }

  return {
    onInitModal: onInitModal
  };
})();

// Đăng ký vào FormPlugins toàn cục
if (typeof window !== 'undefined') {
  window.FormPlugins = window.FormPlugins || [];
  var exists = window.FormPlugins.some(function (p) {
    return p.name === 'CLManagementPlugin';
  });
  if (!exists) {
    window.FormPlugins.push({
      name: 'CLManagementPlugin',
      onInitModal: CLManagementPlugin.onInitModal
    });
  }
}
