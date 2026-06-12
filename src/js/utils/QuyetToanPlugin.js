/**
 * QuyetToanPlugin.js
 * ─────────────────────────────────────────────────────────────────────
 * Quản lý giao diện & logic của modal Quyết Toán Tiệc (frmQuyetToan).
 * Tự động tích hợp vào grid Hợp đồng để hiển thị nút "Quyết Toán".
 */
var QuyetToanPlugin = (function () {

  // Thêm styles cho giao diện modal quyết toán
  function _injectStyles() {
    if (document.getElementById('quyettoan-plugin-styles')) return;
    var style = document.createElement('style');
    style.id = 'quyettoan-plugin-styles';
    style.innerHTML = `
      .quyettoan-plugin-wrapper {
        display: flex;
        flex-direction: column;
        gap: 20px;
        font-family: inherit;
      }
      .quyettoan-card {
        border: 1px solid var(--color-border, #cbd5e1);
        border-radius: 8px;
        background: var(--color-surface, #fff);
        padding: 16px;
      }
      .quyettoan-title-sub {
        margin: 0 0 12px 0;
        font-size: 14px;
        color: var(--color-text-secondary, #64748b);
      }
      .quyettoan-form-section {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 16px;
      }
      @media (max-width: 768px) {
        .quyettoan-form-section {
          grid-template-columns: 1fr;
        }
      }
      .quyettoan-right-col {
        border-left: 1px solid var(--color-border, #e2e8f0);
        padding-left: 20px;
      }
      @media (max-width: 768px) {
        .quyettoan-right-col {
          border-left: none;
          padding-left: 0;
          border-top: 1px solid var(--color-border, #e2e8f0);
          padding-top: 16px;
        }
      }
      .quyettoan-summary-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 8px 0;
        border-bottom: 1px dashed var(--color-border, #e2e8f0);
      }
      .quyettoan-summary-row:last-child {
        border-bottom: none;
      }
      .quyettoan-summary-label {
        font-weight: 500;
        color: var(--color-text-secondary, #475569);
      }
      .quyettoan-summary-value {
        font-weight: 700;
        color: var(--color-text, #1e293b);
      }
      .quyettoan-summary-value.highlight {
        color: var(--color-danger, #ef4444);
        font-size: 16px;
      }
    `;
    document.head.appendChild(style);
  }

  function _generateDocument(sohopdong) {
    var DOC_API_BASE = (window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER) 
      ? window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API 
      : 'http://localhost:3000/api/document';

    if (typeof UIToast !== 'undefined') {
      UIToast.show('Đang khởi tạo tài liệu quyết toán...', 'info');
    }

    var headers = { 'Content-Type': 'application/json' };
    var token = '';
    if (typeof ApiClient !== 'undefined' && typeof ApiClient.getCookie === 'function') {
      token = ApiClient.getCookie('auth_token');
    } else {
      var match = document.cookie.match(/(?:^|; )auth_token=([^;]*)/);
      if (match) token = decodeURIComponent(match[1]);
    }
    if (token) {
      headers['Authorization'] = 'Bearer ' + token;
    }

    fetch(DOC_API_BASE + '/generate', {
      method: 'POST',
      headers: headers,
      body: JSON.stringify({
        templateType: 'quyet_toan',
        customerId: sohopdong,
        outputFileName: 'quyet_toan_' + sohopdong,
        rowData: { Sohopdong: sohopdong },
        sqlListName: 'API_DanhSachQuyetToan',
        convertFields: []
      })
    })
      .then(function (res) { return res.json(); })
      .then(function (json) {
        if (json.success) {
          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đã tạo tài liệu: ' + json.fileName, 'success');
          }
          sessionStorage.setItem('docmgr_open_file', json.fileName);
          window.location.hash = '#/document-manager';
        } else {
          if (typeof Alert !== 'undefined') {
            Alert.error('Lỗi xuất tài liệu', json.message || 'Không xác định');
          }
        }
      })
      .catch(function (err) {
        if (typeof Alert !== 'undefined') {
          Alert.error('Lỗi kết nối', 'Không thể kết nối tới Document Server.');
        }
        console.error('[QuyetToanPlugin]', err);
      });
  }

  function _showQuyetToanModal(contractRow, existingSettlement, details) {
    _injectStyles();

    var sohopdong = contractRow.Sohopdong || contractRow.sohopdong || contractRow.SoHopDong;
    var khachhang = contractRow.Khachhang || contractRow.Daidiendat || contractRow.TenKhachHang || '';
    
    // Tiền cọc đã thu từ hợp đồng
    var tongtiencoc = Number(contractRow.Tongtiencoc || contractRow.tongtiencoc || 
      ((contractRow.Sotiencoccho || 0) + (contractRow.Sotiencochopdong || 0)) || 0);

    var modalContent = document.createElement('div');
    modalContent.className = 'quyettoan-plugin-wrapper';
    
    // Gán dữ liệu form cho MutationObserver của FoodSelectionPlugin phát hiện
    modalContent.setAttribute('data-form-name', 'frmQuyetToan');

    modalContent.innerHTML = `
      <div class="quyettoan-card">
        <h5 style="margin-top:0; font-size:16px; color:var(--color-primary, #3b82f6); display:flex; align-items:center; gap:8px;">
          <span class="material-symbols-outlined">receipt</span>
          Quyết Toán Hợp Đồng Tiệc cưới / Hội nghị
        </h5>
        <div class="quyettoan-title-sub">
          Số Hợp đồng: <strong>${sohopdong}</strong> | Khách hàng: <strong>${khachhang}</strong>
        </div>

        <form id="frmQuyetToanSave">
          <input type="hidden" name="JsonBanTiec" id="inpJsonBanTiec" value="[]">
          <input type="hidden" name="JsonThucUong" id="inpJsonThucUong" value="[]">
          <input type="hidden" name="JsonDichVu" id="inpJsonDichVu" value="[]">
          <input type="hidden" name="JsonPhatSinh" id="inpJsonPhatSinh" value="[]">

          <div class="quyettoan-form-section">
            <!-- Cột trái: Thông tin chung & các chi phí phụ thu -->
            <div>
              <div class="mb-3">
                <label class="form-label fw-bold">Mã Phiếu Quyết Toán</label>
                <input type="text" id="inpDocumentID" class="ui-input" readonly placeholder="Hệ thống tự sinh..." style="width:100%;">
              </div>
              <div class="mb-3" id="containerNgayQuyetToan"></div>
              
              <div class="mb-3">
                <label class="form-label fw-bold">Người nộp tiền</label>
                <input type="text" id="inpNguoinop" class="ui-input" placeholder="Tên khách hàng nộp quyết toán..." style="width:100%;" required>
              </div>

              <div class="row">
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Bù chênh lệch sảnh (VND)</label>
                  <input type="number" id="inpPhiBuSanh" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Bù bàn tăng (VND)</label>
                  <input type="number" id="inpPhiBuBanTang" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
              </div>

              <div class="row">
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Bù trang trí sảnh (VND)</label>
                  <input type="number" id="inpPhiBuTTS" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Bù nước ngọt ngọt (VND)</label>
                  <input type="number" id="inpPhiBuNTL" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
              </div>

              <div class="row">
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Phí phục vụ tiệc (VND)</label>
                  <input type="number" id="inpPhiPhucVu" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
                <div class="col-6 mb-3">
                  <label class="form-label fw-bold">Chi phí phát sinh khác (VND)</label>
                  <input type="number" id="inpSotienphatsinh" class="ui-input fee-trigger" min="0" value="0" style="width:100%;">
                </div>
              </div>
            </div>

            <!-- Cột phải: Tính toán tiền & Thuế VAT -->
            <div class="quyettoan-right-col">
              <h6 style="margin-top:0; color:var(--color-text-secondary); border-bottom: 1px solid var(--color-border); padding-bottom: 8px;">TÓM TẮT TÀI CHÍNH</h6>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Tổng cọc đã thu:</span>
                <span class="quyettoan-summary-value text-success" id="valTongtiencoc">0 đ</span>
              </div>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Cấu hình VAT (%):</span>
                <select id="inpPTThueVAT" class="ui-input fee-trigger" style="width:100px; padding:4px 8px; font-size:13px; font-weight:700;">
                  <option value="0">0%</option>
                  <option value="8">8%</option>
                  <option value="10">10%</option>
                </select>
              </div>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Cộng chưa VAT:</span>
                <span class="quyettoan-summary-value" id="valTongCongChuaVAT">0 đ</span>
              </div>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Tiền thuế VAT:</span>
                <span class="quyettoan-summary-value" id="valTienThueVAT">0 đ</span>
              </div>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Tổng cộng hóa đơn:</span>
                <span class="quyettoan-summary-value highlight" id="valTongtienHoaDon">0 đ</span>
              </div>

              <div class="mb-3 mt-3">
                <label class="form-label fw-bold" style="color:var(--color-primary);">Thanh toán quyết toán đợt cuối (VND)</label>
                <input type="number" id="inpThanhtoan" class="ui-input fee-trigger" min="0" style="width:100%; font-weight:700; color:var(--color-primary); font-size:16px;">
              </div>

              <div class="quyettoan-summary-row">
                <span class="quyettoan-summary-label">Còn lại phải thu:</span>
                <span class="quyettoan-summary-value highlight" id="valConlai">0 đ</span>
              </div>

              <div class="mb-3 mt-3 d-flex align-items-center gap-2">
                <!-- Checkbox chốt sổ quyết toán -->
                <input type="checkbox" id="chkIsKetthuc" style="width: 18px; height: 18px; cursor: pointer;">
                <label for="chkIsKetthuc" class="m-0 fw-bold" style="cursor: pointer; font-size:13px;">Hoàn tất thanh toán (Đóng Hợp đồng)</label>
              </div>

              <div class="mb-3">
                <label class="form-label fw-bold">Ghi chú quyết toán</label>
                <textarea id="inpGhichu" class="ui-input" rows="2" style="width:100%; resize:vertical;" placeholder="Nhập ghi chú thanh lý hợp đồng..."></textarea>
              </div>
            </div>
          </div>

          <div class="d-flex justify-content-end gap-2 mt-4 pt-3" style="border-top:1px solid var(--color-border, #cbd5e1);">
            <button type="button" class="btn btn-outline-secondary" onclick="document.querySelector('.ui-modal-overlay').remove()">Hủy</button>
            <button type="submit" class="btn btn-success d-flex align-items-center gap-1">
              <span class="material-symbols-outlined" style="font-size:18px;">save</span> 
              Lưu & Xuất Quyết Toán Word
            </button>
          </div>
        </form>
      </div>
    `;

    var modalInstance = UIModal.show({
      title: 'Hồ Sơ Quyết Toán Hợp Đồng',
      width: '1000px',
      content: modalContent
    });

    // Tạo các trường ngày
    var today = new Date();
    var defaultToday = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
    
    var dateInput = UIInput.createDate({
      id: 'inpDocumentDate',
      label: 'Ngày Lập Quyết Toán',
      required: true,
      value: defaultToday
    });
    modalContent.querySelector('#containerNgayQuyetToan').appendChild(dateInput);

    // Gán dữ liệu ban đầu
    modalContent.querySelector('#inpJsonBanTiec').value = details.JsonBanTiec || '[]';
    modalContent.querySelector('#inpJsonThucUong').value = details.JsonThucUong || '[]';
    modalContent.querySelector('#inpJsonDichVu').value = details.JsonDichVu || '[]';
    modalContent.querySelector('#inpJsonPhatSinh').value = details.JsonPhatSinh || '[]';

    if (existingSettlement) {
      modalContent.querySelector('#inpDocumentID').value = existingSettlement.DocumentID || '';
      modalContent.querySelector('#inpNguoinop').value = existingSettlement.Nguoinop || khachhang;
      
      var docDate = existingSettlement.DocumentDate || '';
      if (docDate && docDate.indexOf('T') !== -1) docDate = docDate.split('T')[0];
      modalContent.querySelector('#inpDocumentDate').value = docDate;
      if (modalContent.querySelector('#inpDocumentDate_visible')) {
        var parts = docDate.split('-');
        if (parts.length === 3) modalContent.querySelector('#inpDocumentDate_visible').value = parts[2] + '/' + parts[1] + '/' + parts[0];
      }

      modalContent.querySelector('#inpPhiBuSanh').value = existingSettlement.PhiBuSanh || 0;
      modalContent.querySelector('#inpPhiBuBanTang').value = existingSettlement.PhiBuBantang || 0;
      modalContent.querySelector('#inpPhiBuTTS').value = existingSettlement.PhiBuTTS || 0;
      modalContent.querySelector('#inpPhiBuNTL').value = existingSettlement.PhiBuNTL || 0;
      modalContent.querySelector('#inpPhiPhucVu').value = existingSettlement.PhiPhucVu || 0;
      modalContent.querySelector('#inpSotienphatsinh').value = existingSettlement.Sotienphatsinh || 0;
      modalContent.querySelector('#inpPTThueVAT').value = existingSettlement.PTThueVAT || 0;
      
      modalContent.querySelector('#inpThanhtoan').value = existingSettlement.Thanhtoan || 0;
      modalContent.querySelector('#chkIsKetthuc').checked = existingSettlement.IsKetthuc ? true : false;
      modalContent.querySelector('#inpGhichu').value = existingSettlement.Ghichu || '';
    } else {
      modalContent.querySelector('#inpNguoinop').value = khachhang;
      modalContent.querySelector('#inpThanhtoan').value = 0;
      modalContent.querySelector('#chkIsKetthuc').checked = true;
    }

    // Thiết lập hiển thị tiền cọc
    modalContent.querySelector('#valTongtiencoc').innerText = tongtiencoc.toLocaleString('vi-VN') + ' đ';

    // Hàm tính toán lại các con số
    function recalculateTotals() {
      // 1. Tổng tiền từ danh mục grids (được quản lý bởi FoodSelectionPlugin)
      var totalBanTiec = 0, totalThucUong = 0, totalDichVu = 0, totalPhatSinh = 0;
      try { totalBanTiec = JSON.parse(modalContent.querySelector('#inpJsonBanTiec').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalThucUong = JSON.parse(modalContent.querySelector('#inpJsonThucUong').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalDichVu = JSON.parse(modalContent.querySelector('#inpJsonDichVu').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalPhatSinh = JSON.parse(modalContent.querySelector('#inpJsonPhatSinh').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}

      var totalGrid = totalBanTiec + totalThucUong + totalDichVu + totalPhatSinh;

      // 2. Chi phí phụ thu khác
      var phiSanh = Number(modalContent.querySelector('#inpPhiBuSanh').value || 0);
      var phiBanTang = Number(modalContent.querySelector('#inpPhiBuBanTang').value || 0);
      var phiTTS = Number(modalContent.querySelector('#inpPhiBuTTS').value || 0);
      var phiNTL = Number(modalContent.querySelector('#inpPhiBuNTL').value || 0);
      var phiPhucVu = Number(modalContent.querySelector('#inpPhiPhucVu').value || 0);
      var phatSinhManual = Number(modalContent.querySelector('#inpSotienphatsinh').value || 0);

      var subtotal = totalGrid + phiSanh + phiBanTang + phiTTS + phiNTL + phiPhucVu + phatSinhManual;
      
      // 3. Tính toán VAT
      var ptVAT = Number(modalContent.querySelector('#inpPTThueVAT').value || 0);
      var tienVAT = Math.round(subtotal * (ptVAT / 100));
      var tongHoaDon = subtotal + tienVAT;

      // Nếu lần đầu tạo mới, thiết lập đề xuất thanh toán = tổng hóa đơn trừ đi cọc
      if (!existingSettlement && Number(modalContent.querySelector('#inpThanhtoan').value || 0) === 0) {
        var suggestPayment = Math.max(0, tongHoaDon - tongtiencoc);
        modalContent.querySelector('#inpThanhtoan').value = suggestPayment;
      }

      var thanhToan = Number(modalContent.querySelector('#inpThanhtoan').value || 0);
      var conLai = tongHoaDon - tongtiencoc - thanhToan;

      // Cập nhật lên giao diện
      modalContent.querySelector('#valTongCongChuaVAT').innerText = subtotal.toLocaleString('vi-VN') + ' đ';
      modalContent.querySelector('#valTienThueVAT').innerText = tienVAT.toLocaleString('vi-VN') + ' đ';
      modalContent.querySelector('#valTongtienHoaDon').innerText = tongHoaDon.toLocaleString('vi-VN') + ' đ';
      modalContent.querySelector('#valConlai').innerText = conLai.toLocaleString('vi-VN') + ' đ';

      // Tự động tích chọn hoàn tất nếu số tiền còn lại <= 0
      if (conLai <= 0) {
        modalContent.querySelector('#chkIsKetthuc').checked = true;
      }
    }

    // Lắng nghe các sự kiện thay đổi dữ liệu
    modalContent.querySelectorAll('.fee-trigger').forEach(function (inp) {
      inp.addEventListener('input', recalculateTotals);
      inp.addEventListener('change', recalculateTotals);
    });

    ['inpJsonBanTiec', 'inpJsonThucUong', 'inpJsonDichVu', 'inpJsonPhatSinh'].forEach(function (id) {
      var el = modalContent.querySelector('#' + id);
      if (el) {
        el.addEventListener('change', recalculateTotals);
      }
    });

    // Kích hoạt việc vẽ các grids
    if (typeof FoodSelectionPlugin !== 'undefined' && typeof FoodSelectionPlugin.reloadForm === 'function') {
      // Đợi một tick để MutationObserver của FoodSelectionPlugin chạy vẽ grids trước rồi mới cập nhật số liệu tổng
      setTimeout(function () {
        FoodSelectionPlugin.reloadForm(modalContent);
        recalculateTotals();
      }, 60);
    } else {
      recalculateTotals();
    }

    // Submit handler
    var form = modalContent.querySelector('#frmQuyetToanSave');
    form.onsubmit = function (e) {
      e.preventDefault();

      var docId = modalContent.querySelector('#inpDocumentID').value.trim();
      var ngayLap = modalContent.querySelector('#inpDocumentDate').value;
      var nguoinop = modalContent.querySelector('#inpNguoinop').value.trim();

      var phiSanh = Number(modalContent.querySelector('#inpPhiBuSanh').value || 0);
      var phiBanTang = Number(modalContent.querySelector('#inpPhiBuBanTang').value || 0);
      var phiTTS = Number(modalContent.querySelector('#inpPhiBuTTS').value || 0);
      var phiNTL = Number(modalContent.querySelector('#inpPhiBuNTL').value || 0);
      var phiPhucVu = Number(modalContent.querySelector('#inpPhiPhucVu').value || 0);
      var phatSinh = Number(modalContent.querySelector('#inpSotienphatsinh').value || 0);

      var ptVAT = Number(modalContent.querySelector('#inpPTThueVAT').value || 0);
      var thanhtoan = Number(modalContent.querySelector('#inpThanhtoan').value || 0);
      var checkKetThuc = modalContent.querySelector('#chkIsKetthuc').checked ? 1 : 0;
      var ghichu = modalContent.querySelector('#inpGhichu').value.trim();

      // Recalculate variables for payload
      var totalBanTiec = 0, totalThucUong = 0, totalDichVu = 0, totalPhatSinh = 0;
      try { totalBanTiec = JSON.parse(modalContent.querySelector('#inpJsonBanTiec').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalThucUong = JSON.parse(modalContent.querySelector('#inpJsonThucUong').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalDichVu = JSON.parse(modalContent.querySelector('#inpJsonDichVu').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}
      try { totalPhatSinh = JSON.parse(modalContent.querySelector('#inpJsonPhatSinh').value || '[]').reduce(function (sum, item) { return sum + (item.Soluong * item.Dongia - (item.Sotiengiamgia || 0)); }, 0); } catch(e){}

      var subtotal = totalBanTiec + totalThucUong + totalDichVu + totalPhatSinh + phiSanh + phiBanTang + phiTTS + phiNTL + phiPhucVu + phatSinh;
      var tienVAT = Math.round(subtotal * (ptVAT / 100));
      var tongHoaDon = subtotal + tienVAT;
      var conLai = tongHoaDon - tongtiencoc - thanhtoan;

      var userObj = {};
      try { userObj = JSON.parse(localStorage.getItem('pmql_user') || '{}'); } catch (err) { }
      var currentUserName = userObj.Username || userObj.UserName || userObj.username || 'system';

      var payload = {
        DocumentID: docId,
        DocumentDate: ngayLap,
        Sohopdong: sohopdong,
        Nguoinop: nguoinop,
        Tongtiencoc: tongtiencoc,
        TongtienHoaDon: tongHoaDon,
        Thanhtoan: thanhtoan,
        Conlai: conLai,
        IsKetthuc: checkKetThuc,
        Ghichu: ghichu,
        UserName: currentUserName,

        Sotienphatsinh: phatSinh,
        PhiBuSanh: phiSanh,
        PhiBuBantang: phiBanTang,
        PhiBuTTS: phiTTS,
        PhiBuNTL: phiNTL,
        PhiPhucVu: phiPhucVu,
        PTThueVAT: ptVAT,
        TienThueVAT: tienVAT,

        JsonBanTiec: modalContent.querySelector('#inpJsonBanTiec').value,
        JsonThucUong: modalContent.querySelector('#inpJsonThucUong').value,
        JsonDichVu: modalContent.querySelector('#inpJsonDichVu').value,
        JsonPhatSinh: modalContent.querySelector('#inpJsonPhatSinh').value
      };

      var submitBtn = form.querySelector('button[type="submit"]');
      var originalBtnHtml = submitBtn.innerHTML;
      submitBtn.disabled = true;
      submitBtn.innerHTML = '<span class="material-symbols-outlined" style="animation:spin 1s linear infinite;">autorenew</span> Đang lưu quyết toán...';

      CheckoutService.save(payload).then(function (res) {
        if (res && !res.error) {
          if (modalInstance && typeof modalInstance.closeNow === 'function') {
            modalInstance.closeNow();
          } else {
            var overlay = document.querySelector('.ui-modal-overlay');
            if (overlay) overlay.remove();
          }

          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đã lưu phiếu quyết toán thành công!', 'success');
          }

          // Sinh file quyết toán Word
          try {
            _generateDocument(sohopdong);
          } catch(e) {
            console.error('[QuyetToanPlugin] Lỗi sinh file word:', e);
          }
        } else {
          if (typeof Alert !== 'undefined') Alert.error('Lỗi lưu', (res && res.message) || 'Có lỗi khi lưu phiếu quyết toán.');
          else alert('Lỗi khi lưu quyết toán.');
          submitBtn.disabled = false;
          submitBtn.innerHTML = originalBtnHtml;
        }
      }).catch(function (err) {
        console.error('[QuyetToanPlugin] Save error:', err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không thể lưu quyết toán lên server.');
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnHtml;
      });
    };
  }

  function getExtraButtons(formName, getSelectedRows) {
    if (formName !== 'frmHopDong') return [];

    return [{
      id: 'btn-create-quyettoan',
      text: 'Quyết Toán',
      icon: 'receipt',
      type: 'tool',
      onClick: function () {
        var selectedRows = getSelectedRows();
        if (!selectedRows || selectedRows.length !== 1) {
          if (typeof Alert !== 'undefined') {
            Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Hợp Đồng duy nhất để quyết toán.');
          } else {
            alert('Vui lòng chọn 1 Hợp Đồng!');
          }
          return;
        }

        var row = selectedRows[0];
        var sohopdong = row.Sohopdong || row.sohopdong || row.SoHopDong;

        if (typeof CheckoutService !== 'undefined') {
          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đang kiểm tra hồ sơ quyết toán...', 'info');
          }

          CheckoutService.getList({ Sohopdong: sohopdong }).then(function (history) {
            var existingSettlement = history && history.length > 0 ? history[0] : null;

            if (existingSettlement) {
              // Đã có quyết toán
              CheckoutService.getDetails({ DocumentID: existingSettlement.DocumentID }).then(function (details) {
                _showQuyetToanModal(row, existingSettlement, details || {});
              }).catch(function (err) {
                console.error('[QuyetToanPlugin] Lỗi tải chi tiết quyết toán cũ:', err);
                _showQuyetToanModal(row, existingSettlement, {});
              });
            } else {
              // Chưa có quyết toán, tải từ hợp đồng/phụ lục
              CheckoutService.getDetails({ Sohopdong: sohopdong }).then(function (details) {
                _showQuyetToanModal(row, null, details || {});
              }).catch(function (err) {
                console.error('[QuyetToanPlugin] Lỗi tải chi tiết từ hợp đồng:', err);
                _showQuyetToanModal(row, null, {});
              });
            }
          }).catch(function (err) {
            console.error('[QuyetToanPlugin] Lỗi check lịch sử quyết toán:', err);
            // Fallback load default
            CheckoutService.getDetails({ Sohopdong: sohopdong }).then(function (details) {
              _showQuyetToanModal(row, null, details || {});
            }).catch(function () {
              _showQuyetToanModal(row, null, {});
            });
          });
        } else {
          console.error('[QuyetToanPlugin] CheckoutService không tồn tại!');
        }
      }
    }];
  }

  // Đăng ký Plugin vào hệ thống nút bấm mở rộng của DynamicFormEngine
  window.FormActionPlugins = window.FormActionPlugins || [];
  window.FormActionPlugins.push({ getExtraButtons: getExtraButtons });

  return { getExtraButtons: getExtraButtons };
})();
