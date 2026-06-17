/**
 * PhuLucPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin cấu hình nút "Tạo Phụ Lục" cho form Hợp đồng tiệc.
 * Cho phép xem lịch sử và tạo mới Đề nghị thay đổi / Phụ lục.
 */
var PhuLucPlugin = (function () {

  // Thêm styles cho giao diện modal
  function _injectStyles() {
    if (document.getElementById('phuluc-plugin-styles')) return;
    var style = document.createElement('style');
    style.id = 'phuluc-plugin-styles';
    style.innerHTML = `
      .phuluc-plugin-wrapper {
        display: flex;
        flex-direction: column;
        gap: 20px;
        color: var(--color-text, #ffffff);
      }
      .phuluc-plugin-wrapper .text-muted {
        color: var(--color-text-secondary, #94a3b8) !important;
      }
      .phuluc-history-card {
        border: 1px solid var(--color-border);
        border-radius: 8px;
        background: var(--color-surface);
        padding: 16px;
      }
      .phuluc-form-card {
        border: 1px solid var(--color-border);
        border-radius: 8px;
        background: var(--color-surface);
        padding: 16px;
      }
      .phuluc-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
      }
      .phuluc-table th, .phuluc-table td {
        border: 1px solid var(--color-border);
        padding: 8px 12px;
        text-align: left;
        color: var(--color-text, #ffffff);
      }
      .phuluc-table th {
        background: var(--color-background);
        font-weight: 600;
        color: var(--color-text-secondary, #94a3b8);
      }
    `;
    document.head.appendChild(style);
  }

  function _stringifyJson(val) {
    if (!val) return '[]';
    if (typeof val === 'string') {
      var trimmed = val.trim();
      if ((trimmed.startsWith('[') && trimmed.endsWith(']')) || (trimmed.startsWith('{') && trimmed.endsWith('}'))) {
        return val;
      }
      if (val === '[object Object]' || val.indexOf('[object Object]') !== -1) return '[]';
      return val;
    }
    try {
      return JSON.stringify(val);
    } catch (e) {
      console.error('[PhuLucPlugin] Error stringifying JSON:', e);
      return '[]';
    }
  }

  function _generateDocument(sothaydoi) {
    var DOC_API_BASE = (window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER) ? window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API : 'http://localhost:3000/api/document';
    var config = {
      docType: 'phu_luc_hop_dong',
      sqlListName: 'frmPhuLucHopDong'
    };

    if (typeof UIToast !== 'undefined') {
      UIToast.show('Đang khởi tạo tài liệu...', 'info');
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
        templateType: config.docType,
        customerId: sothaydoi,
        outputFileName: config.docType + '_' + sothaydoi,
        rowData: {}, // Backend will fetch from API_DanhSachPhuLuc using customerId
        sqlListName: config.sqlListName,
        convertFields: ['DichVuTinhPhiPhuLuc', 'ThoaThuanPhuLucKhac']
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
        console.error('[PhuLucPlugin]', err);
      });
  }

  function _showPhuLucModal(contractRow, defaultJsonBanTiec, defaultJsonThucUong, defaultJsonDichVu, defaultJsonPhatSinh, onReload) {
    _injectStyles();

    defaultJsonBanTiec = _stringifyJson(defaultJsonBanTiec);
    defaultJsonThucUong = _stringifyJson(defaultJsonThucUong);
    defaultJsonDichVu = _stringifyJson(defaultJsonDichVu);
    defaultJsonPhatSinh = _stringifyJson(defaultJsonPhatSinh);

    var sohopdong = contractRow.Sohopdong || contractRow.sohopdong || contractRow.SoHopDong;
    var khachhang = contractRow.Khachhang || contractRow.Daidiendat || contractRow.TenKhachHang || '';

    // Khai báo sẵn các trường mặc định từ hợp đồng gốc
    var qmTu = contractRow.SanhQuyMoMin || contractRow.QuyMoBanTu || contractRow.quymobantu || contractRow.QuyMoBanTuTD || '';
    var qmDen = contractRow.SanhQuyMoMax || contractRow.QuyMoBanDen || contractRow.quymobanden || contractRow.QuyMoBanDenTD || '';
    var donGia = contractRow.Giabanman || contractRow.giabanman || contractRow.DonGiaBanTiec || '';
    var soKhach = contractRow.TiecSoKhach1Ban || contractRow.SoNguoiTrenBan || contractRow.SoKhachTrenBan || 10;
    var tenDot = contractRow.TenDotThanhToan || 'Đợt 2';
    var soTienDot2 = contractRow.Sotiencochopdong || contractRow.ThanhToanDot2SoTien || '';
    var hinhThuc = contractRow.Dot2HinhThuc || contractRow.HinhThucThanhToanDot2 || 'Chuyển khoản';
    var hanThanhToan = contractRow.Ngayhopdong || contractRow.NgayHopDong || contractRow.HanThanhToanDot2 || '';
    if (hanThanhToan && hanThanhToan.indexOf('T') !== -1) hanThanhToan = hanThanhToan.split('T')[0];

    var chucVu = contractRow.BenAChucVu || contractRow.BenAChucVuDaiDien || '';
    var ngayToChuc = contractRow.NgayToChuc || contractRow.Ngaytochuc || '';
    if (ngayToChuc && ngayToChuc.indexOf('T') !== -1) ngayToChuc = ngayToChuc.split('T')[0];

    var nhamNgay = contractRow.Nhamngay || contractRow.NhamNgay || '';
    var dvTinhPhi = contractRow.DichVuTinhPhiPhuLuc || '';
    var uuDai = contractRow.DSKhuyenMai || contractRow.Noidunguudai || contractRow.ThoaThuanPhuLucKhac || '';
    var lyDo = contractRow.Ghichu || contractRow.LyDoDieuChinh || '';

    // Lấy lịch sử phụ lục
    ContractService.getPhuLucHistory(sohopdong).then(function (historyRecords) {
      var historyHtml = '';
      if (!historyRecords || historyRecords.length === 0) {
        historyHtml = '<tr><td colspan="5" class="text-center text-muted">Chưa có phụ lục / thay đổi nào.</td></tr>';
      } else {
        historyRecords.forEach(function (rec, index) {
          var ngay = rec.NgayLapPL || rec.Ngaythaydoi || '';
          if (ngay && ngay.indexOf('T') !== -1) ngay = ngay.split('T')[0];
          historyHtml += `
            <tr>
              <td class="text-center">${index + 1}</td>
              <td><a href="javascript:void(0)" class="btn-edit-pl" style="font-weight: 600; color: var(--color-primary); text-decoration: none;" data-idx="${index}">${rec.SoPhuLuc || rec.Sothaydoi || ''}</a></td>
              <td>${ngay}</td>
              <td>${rec.LyDoDieuChinh || rec.GhiChu || rec.Ghichu || ''}</td>
              <td class="text-center">
                <button type="button" class="btn btn-sm btn-link btn-edit-pl" data-idx="${index}" title="Sửa" style="padding: 2px 4px; border: none; background: transparent; cursor: pointer; color: var(--color-primary);">
                  <span class="material-symbols-outlined" style="font-size: 18px; vertical-align: middle;">edit</span>
                </button>
                <button type="button" class="btn btn-sm btn-link text-danger btn-delete-pl" data-id="${rec.SoPhuLuc || rec.Sothaydoi || ''}" title="Xóa" style="padding: 2px 4px; border: none; background: transparent; cursor: pointer; color: var(--color-danger);">
                  <span class="material-symbols-outlined" style="font-size: 18px; vertical-align: middle;">delete</span>
                </button>
              </td>
            </tr>
          `;
        });
      }

      var modalContent = document.createElement('div');
      modalContent.className = 'phuluc-plugin-wrapper';
      modalContent.innerHTML = `
        <div class="phuluc-history-card">
          <h5 style="margin-top: 0; font-size: 15px; color: var(--color-primary);"><span class="material-symbols-outlined" style="vertical-align: middle; font-size: 18px;">history</span> Lịch Sử Phụ Lục / Thay Đổi</h5>
          <p class="text-muted" style="margin-bottom: 12px; font-size: 13px;">Hợp đồng: <strong>${sohopdong}</strong> - Khách hàng: <strong>${khachhang}</strong></p>
          <div style="max-height: 150px; overflow-y: auto;">
            <table class="phuluc-table">
              <thead>
                <tr>
                  <th style="width: 50px;" class="text-center">STT</th>
                  <th style="width: 120px;">Số Phụ Lục</th>
                  <th style="width: 120px;">Ngày Lập</th>
                  <th>Nội dung thỏa thuận</th>
                  <th style="width: 100px;" class="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                ${historyHtml}
              </tbody>
            </table>
          </div>
        </div>

        <div class="phuluc-form-card">
          <h5 id="form-title" style="margin-top: 0; font-size: 15px; color: var(--color-primary);"><span class="material-symbols-outlined" style="vertical-align: middle; font-size: 18px;">add_circle</span> Tạo Phụ Lục Mới</h5>
          <form id="frmPhuLucCreate">
            <input type="hidden" name="JsonBanTiec" id="inpJsonBanTiec" value="[]">
            <input type="hidden" name="JsonThucUong" id="inpJsonThucUong" value="[]">
            <input type="hidden" name="JsonDichVu" id="inpJsonDichVu" value="[]">
            <input type="hidden" name="JsonPhatSinh" id="inpJsonPhatSinh" value="[]">
            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Phụ Lục (Hệ thống tự sinh nếu để trống)</label>
                <input type="text" id="inpSothaydoi" class="ui-input" placeholder="Ví dụ: PL01/2026" maxlength="20" style="width: 100%;">
              </div>
              <div class="col-md-6" id="containerNgayLapPL"></div>
            </div>

            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Quy Mô Bàn (Từ)</label>
                <input type="number" id="inpQuyMoBanTu" class="ui-input" style="width: 100%;" min="0">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Quy Mô Bàn (Đến)</label>
                <input type="number" id="inpQuyMoBanDen" class="ui-input" style="width: 100%;" min="0">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Đơn Giá Bàn Tiệc (VND)</label>
                <input type="number" id="inpDonGiaBanTiec" class="ui-input" style="width: 100%;" min="0" step="1000">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Khách / Bàn</label>
                <input type="number" id="inpSoKhachTrenBan" class="ui-input" style="width: 100%;" min="1" max="100">
              </div>
            </div>

            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Tên Đợt Thanh Toán</label>
                <input type="text" id="inpTenDotThanhToan" class="ui-input" placeholder="Ví dụ: Đợt 2" style="width: 100%;">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Tiền Đợt 2 (VND)</label>
                <input type="number" id="inpThanhToanDot2SoTien" class="ui-input" style="width: 100%;" min="0" step="1000">
              </div>
              <div class="col-md-3 mb-3">
                <label class="form-label" style="font-weight: 600;">Hình Thức T.Toán</label>
                <select id="inpHinhThucThanhToanDot2" class="ui-input" style="width: 100%;">
                  <option value="Chuyển khoản">Chuyển khoản</option>
                  <option value="Tiền mặt">Tiền mặt</option>
                  <option value="Tiền mặt / Chuyển khoản">Tiền mặt / Chuyển khoản</option>
                </select>
              </div>
              <div class="col-md-3" id="containerHanThanhToanDot2"></div>
            </div>

            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Chức vụ đại diện ký Bên A</label>
                <input type="text" id="inpBenAChucVuDaiDien" class="ui-input" placeholder="Ví dụ: Đại diện kinh doanh" style="width: 100%;">
              </div>
              <div class="col-md-6" id="containerNgayToChucTD"></div>
            </div>

            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Dịch vụ tính phí phụ lục (Mỗi dòng 1 mục)</label>
                <textarea id="inpDichVuTinhPhiPhuLuc" class="ui-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Ví dụ:&#10;1. MC tiệc cưới: 2.000.000 VND&#10;2. Màn hình LED: 5.000.000 VND"></textarea>
              </div>
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Dịch vụ ưu đãi & thỏa thuận khác (Mỗi dòng 1 mục)</label>
                <textarea id="inpThoaThuanPhuLucKhac" class="ui-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Ví dụ:&#10;1. Tặng 1 xe hoa rước dâu&#10;2. Miễn phí phí phục vụ nước ngọt"></textarea>
              </div>
            </div>

            <div class="row">
              <div class="col-md-12 mb-3">
                <label class="form-label" style="font-weight: 600;">Nội dung thỏa thuận</label>
                <textarea id="inpThoathuan" class="ui-input" rows="2" style="width: 100%; resize: vertical;" placeholder="Nhập nội dung thỏa thuận..."></textarea>
              </div>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-2">
              <button type="button" id="btnCancelEdit" class="btn btn-outline-warning" style="display: none; margin-right: auto;">Hủy sửa / Tạo mới</button>
              <button type="button" id="btnCancelModal" class="btn btn-outline-secondary">Hủy</button>
              <button type="submit" class="btn btn-success d-flex align-items-center gap-1"><span class="material-symbols-outlined" style="font-size: 18px;">save</span> Lưu & Tạo File Word</button>
            </div>
          </form>
        </div>
      `;

      var modalInstance = UIModal.show({
        title: 'Quản Lý Phụ Lục Hợp Đồng',
        width: '1150px',
        content: modalContent
      });

      // Tạo các trường ngày dùng component UIInput.createDate có sẵn
      var today = new Date();
      var yyyy = today.getFullYear();
      var mm = String(today.getMonth() + 1).padStart(2, '0');
      var dd = String(today.getDate()).padStart(2, '0');
      var defaultToday = yyyy + '-' + mm + '-' + dd;

      var ngayLapInput = UIInput.createDate({
        id: 'inpNgayLapPL',
        label: 'Ngày Lập Phụ Lục',
        required: true,
        value: defaultToday
      });
      modalContent.querySelector('#containerNgayLapPL').appendChild(ngayLapInput);

      var hanThanhToanInput = UIInput.createDate({
        id: 'inpHanThanhToanDot2',
        label: 'Hạn Thanh Toán Đợt 2',
        value: hanThanhToan
      });
      modalContent.querySelector('#containerHanThanhToanDot2').appendChild(hanThanhToanInput);

      var ngayToChucTDInput = UIInput.createDate({
        id: 'inpNgayToChucTD',
        label: 'Điều chỉnh Ngày Tổ Chức (Nếu có)',
        value: ngayToChuc
      });
      modalContent.querySelector('#containerNgayToChucTD').appendChild(ngayToChucTDInput);

      // Lấy username hiện hành
      var userObj = {};
      try {
        userObj = JSON.parse(localStorage.getItem('pmql_user') || '{}');
      } catch (err) { }
      var currentUserName = userObj.Username || userObj.UserName || userObj.username || 'system';

      // Định nghĩa các helper điền form/reset form
      function _fillFormForEdit(rec) {
        modalContent.querySelector('#form-title').innerHTML = `<span class="material-symbols-outlined" style="vertical-align: middle; font-size: 18px;">edit_document</span> Cập Nhật Phụ Lục: <strong style="color: var(--color-primary);">${rec.SoPhuLuc || rec.Sothaydoi || ''}</strong>`;
        modalContent.querySelector('#btnCancelEdit').style.display = 'block';

        modalContent.querySelector('#inpSothaydoi').value = rec.SoPhuLuc || rec.Sothaydoi || '';
        modalContent.querySelector('#inpSothaydoi').disabled = true;

        var ngayLap = rec.NgayLapPL || rec.Ngaythaydoi || rec.NgayLap || '';
        if (ngayLap && ngayLap.indexOf('T') !== -1) ngayLap = ngayLap.split('T')[0];
        modalContent.querySelector('#inpNgayLapPL').value = ngayLap;

        modalContent.querySelector('#inpQuyMoBanTu').value = (rec.QuyMoBanTu !== null && rec.QuyMoBanTu !== undefined) ? rec.QuyMoBanTu : '';
        modalContent.querySelector('#inpQuyMoBanDen').value = (rec.QuyMoBanDen !== null && rec.QuyMoBanDen !== undefined) ? rec.QuyMoBanDen : '';
        modalContent.querySelector('#inpDonGiaBanTiec').value = (rec.DonGiaBanTiec !== null && rec.DonGiaBanTiec !== undefined) ? rec.DonGiaBanTiec : '';
        modalContent.querySelector('#inpSoKhachTrenBan').value = (rec.SoKhachTrenBan !== null && rec.SoKhachTrenBan !== undefined) ? rec.SoKhachTrenBan : '';

        modalContent.querySelector('#inpTenDotThanhToan').value = rec.TenDotThanhToan || '';
        modalContent.querySelector('#inpThanhToanDot2SoTien').value = (rec.ThanhToanDot2SoTien !== null && rec.ThanhToanDot2SoTien !== undefined) ? rec.ThanhToanDot2SoTien : '';
        modalContent.querySelector('#inpHinhThucThanhToanDot2').value = rec.HinhThucThanhToanDot2 || 'Chuyển khoản';

        var hanTT = rec.HanThanhToanDot2 || '';
        if (hanTT && hanTT.indexOf('T') !== -1) hanTT = hanTT.split('T')[0];
        modalContent.querySelector('#inpHanThanhToanDot2').value = hanTT;

        modalContent.querySelector('#inpBenAChucVuDaiDien').value = rec.BenAChucVuDaiDien || '';

        var ngayTCTD = rec.NgayToChuc || '';
        if (ngayTCTD && ngayTCTD.indexOf('T') !== -1) ngayTCTD = ngayTCTD.split('T')[0];
        modalContent.querySelector('#inpNgayToChucTD').value = ngayTCTD;

        modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value = rec.DichVuTinhPhiPhuLuc || '';
        modalContent.querySelector('#inpThoaThuanPhuLucKhac').value = rec.ThoaThuanPhuLucKhac || '';
        modalContent.querySelector('#inpThoathuan').value = rec.LyDoDieuChinh || rec.GhiChu || rec.Ghichu || '';

        modalContent.querySelector('#inpJsonBanTiec').value = _stringifyJson(rec.JsonBanTiec);
        modalContent.querySelector('#inpJsonThucUong').value = _stringifyJson(rec.JsonThucUong);
        modalContent.querySelector('#inpJsonDichVu').value = _stringifyJson(rec.JsonDichVu);
        modalContent.querySelector('#inpJsonPhatSinh').value = _stringifyJson(rec.JsonPhatSinh);
        if (typeof FoodSelectionPlugin !== 'undefined' && typeof FoodSelectionPlugin.reloadForm === 'function') {
          FoodSelectionPlugin.reloadForm(modalContent);
        }
      }

      function _resetFormToNew() {
        modalContent.querySelector('#form-title').innerHTML = `<span class="material-symbols-outlined" style="vertical-align: middle; font-size: 18px;">add_circle</span> Tạo Phụ Lục Mới`;
        modalContent.querySelector('#btnCancelEdit').style.display = 'none';

        modalContent.querySelector('#inpSothaydoi').value = '';
        modalContent.querySelector('#inpSothaydoi').disabled = false;

        var today = new Date();
        var yyyy = today.getFullYear();
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var dd = String(today.getDate()).padStart(2, '0');
        modalContent.querySelector('#inpNgayLapPL').value = yyyy + '-' + mm + '-' + dd;

        modalContent.querySelector('#inpQuyMoBanTu').value = qmTu;
        modalContent.querySelector('#inpQuyMoBanDen').value = qmDen;
        modalContent.querySelector('#inpDonGiaBanTiec').value = donGia;
        modalContent.querySelector('#inpSoKhachTrenBan').value = soKhach;
        modalContent.querySelector('#inpTenDotThanhToan').value = tenDot;
        modalContent.querySelector('#inpThanhToanDot2SoTien').value = soTienDot2;
        modalContent.querySelector('#inpHinhThucThanhToanDot2').value = hinhThuc;
        modalContent.querySelector('#inpHanThanhToanDot2').value = hanThanhToan;
        modalContent.querySelector('#inpBenAChucVuDaiDien').value = chucVu;
        modalContent.querySelector('#inpNgayToChucTD').value = ngayToChuc;
        modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value = dvTinhPhi;
        modalContent.querySelector('#inpThoaThuanPhuLucKhac').value = uuDai;
        modalContent.querySelector('#inpThoathuan').value = lyDo;

        modalContent.querySelector('#inpJsonBanTiec').value = _stringifyJson(defaultJsonBanTiec);
        modalContent.querySelector('#inpJsonThucUong').value = _stringifyJson(defaultJsonThucUong);
        modalContent.querySelector('#inpJsonDichVu').value = _stringifyJson(defaultJsonDichVu);
        modalContent.querySelector('#inpJsonPhatSinh').value = _stringifyJson(defaultJsonPhatSinh);
        if (typeof FoodSelectionPlugin !== 'undefined' && typeof FoodSelectionPlugin.reloadForm === 'function') {
          FoodSelectionPlugin.reloadForm(modalContent);
        }
      }

      function _deletePhuLuc(id) {
        var performDelete = function () {
          ContractService.deletePhuLuc(id, currentUserName).then(function (res) {
            if (res && (res.code === 0 || res.success || res.status === 200 || !res.error)) {
              if (modalInstance && typeof modalInstance.closeNow === 'function') {
                modalInstance.closeNow();
              } else {
                var overlay = document.querySelector('.modal-overlay');
                if (overlay) overlay.remove();
              }
              if (typeof onReload === 'function') {
                try { onReload(); } catch (err) { }
              }
              // Mở lại modal để refresh danh sách
              _showPhuLucModal(contractRow, defaultJsonBanTiec, defaultJsonThucUong, defaultJsonDichVu, defaultJsonPhatSinh, onReload);
            } else {
              var errMsg = (res && (res.message || res.msg)) || 'Có lỗi khi xóa phụ lục.';
              if (typeof Alert !== 'undefined') {
                Alert.error('Lỗi xóa phụ lục', errMsg);
              } else {
                alert(errMsg);
              }
            }
          }).catch(function (err) {
            console.error('[PhuLucPlugin] Delete error:', err);
            if (typeof Alert !== 'undefined') {
              Alert.error('Lỗi', 'Không thể kết nối đến server.');
            }
          });
        };

        if (typeof ConfirmModal !== 'undefined') {
          ConfirmModal.show({
            title: 'Xác nhận xóa phụ lục',
            message: `Bạn có chắc chắn muốn xóa phụ lục <strong>${id}</strong>? Hành động này không thể hoàn tác và không được phép xóa phụ lục đã duyệt chốt.`,
            confirmText: 'Đồng ý xóa',
            confirmClass: 'btn-danger',
            onConfirm: performDelete
          });
        } else {
          if (confirm(`Bạn có chắc chắn muốn xóa phụ lục ${id}?`)) {
            performDelete();
          }
        }
      }

      // Đăng ký sự kiện Click (Event delegation) cho History table và Cancel button
      modalContent.addEventListener('click', function (e) {
        var editBtn = e.target.closest('.btn-edit-pl');
        if (editBtn) {
          var idx = parseInt(editBtn.getAttribute('data-idx'));
          var rec = historyRecords[idx];
          if (rec) {
            _fillFormForEdit(rec);
          }
          return;
        }

        var deleteBtn = e.target.closest('.btn-delete-pl');
        if (deleteBtn) {
          var id = deleteBtn.getAttribute('data-id');
          if (id) {
            _deletePhuLuc(id);
          }
          return;
        }

        var cancelBtn = e.target.closest('#btnCancelEdit');
        if (cancelBtn) {
          _resetFormToNew();
          return;
        }

        var cancelModalBtn = e.target.closest('#btnCancelModal');
        if (cancelModalBtn) {
          if (modalInstance && typeof modalInstance.close === 'function') {
            modalInstance.close();
          } else {
            var overlay = document.querySelector('.modal-overlay');
            if (overlay) overlay.remove();
          }
          return;
        }
      });

      // Gán ngày hiện tại làm mặc định
      var inpNgayLap = modalContent.querySelector('#inpNgayLapPL');
      if (inpNgayLap) {
        inpNgayLap.value = defaultToday;
        inpNgayLap.dispatchEvent(new Event('change'));
      }

      // Điền sẵn các giá trị mặc định từ hợp đồng gốc
      modalContent.querySelector('#inpJsonBanTiec').value = _stringifyJson(defaultJsonBanTiec);
      modalContent.querySelector('#inpJsonThucUong').value = _stringifyJson(defaultJsonThucUong);
      modalContent.querySelector('#inpJsonDichVu').value = _stringifyJson(defaultJsonDichVu);
      modalContent.querySelector('#inpJsonPhatSinh').value = _stringifyJson(defaultJsonPhatSinh);
      
      if (typeof FoodSelectionPlugin !== 'undefined' && typeof FoodSelectionPlugin.reloadForm === 'function') {
        FoodSelectionPlugin.reloadForm(modalContent);
      }

      modalContent.querySelector('#inpQuyMoBanTu').value = qmTu;
      modalContent.querySelector('#inpQuyMoBanDen').value = qmDen;
      modalContent.querySelector('#inpDonGiaBanTiec').value = donGia;
      modalContent.querySelector('#inpSoKhachTrenBan').value = soKhach;
      modalContent.querySelector('#inpTenDotThanhToan').value = tenDot;
      modalContent.querySelector('#inpThanhToanDot2SoTien').value = soTienDot2;
      modalContent.querySelector('#inpHinhThucThanhToanDot2').value = hinhThuc;

      var inpHan = modalContent.querySelector('#inpHanThanhToanDot2');
      if (inpHan) {
        inpHan.value = hanThanhToan;
        inpHan.dispatchEvent(new Event('change'));
      }

      modalContent.querySelector('#inpBenAChucVuDaiDien').value = chucVu;

      var inpNgayTC = modalContent.querySelector('#inpNgayToChucTD');
      if (inpNgayTC) {
        inpNgayTC.value = ngayToChuc;
        inpNgayTC.dispatchEvent(new Event('change'));
      }

      modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value = dvTinhPhi;
      modalContent.querySelector('#inpThoaThuanPhuLucKhac').value = uuDai;
      modalContent.querySelector('#inpThoathuan').value = lyDo;

      // Xử lý Form Submit
      var form = modalContent.querySelector('#frmPhuLucCreate');
      form.onsubmit = function (e) {
        e.preventDefault();

        var soPhuLuc = modalContent.querySelector('#inpSothaydoi').value.trim();
        var ngayLapPL = modalContent.querySelector('#inpNgayLapPL').value;

        var qmTuVal = modalContent.querySelector('#inpQuyMoBanTu').value;
        var qmDenVal = modalContent.querySelector('#inpQuyMoBanDen').value;
        var donGiaVal = modalContent.querySelector('#inpDonGiaBanTiec').value;
        var soKhachVal = modalContent.querySelector('#inpSoKhachTrenBan').value;

        var tenDotVal = modalContent.querySelector('#inpTenDotThanhToan').value.trim();
        var soTienDot2Val = modalContent.querySelector('#inpThanhToanDot2SoTien').value;
        var hinhThucVal = modalContent.querySelector('#inpHinhThucThanhToanDot2').value;
        var hanThanhToanVal = modalContent.querySelector('#inpHanThanhToanDot2').value;

        var chucVuVal = modalContent.querySelector('#inpBenAChucVuDaiDien').value.trim();
        var ngayToChucTDVal = modalContent.querySelector('#inpNgayToChucTD').value;

        var dvTinhPhiVal = modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value;
        var uuDaiVal = modalContent.querySelector('#inpThoaThuanPhuLucKhac').value;
        var thoathuan = modalContent.querySelector('#inpThoathuan').value;

        var jsonBanTiecVal = modalContent.querySelector('#inpJsonBanTiec').value;
        var jsonThucUongVal = modalContent.querySelector('#inpJsonThucUong').value;
        var jsonDichVuVal = modalContent.querySelector('#inpJsonDichVu').value;
        var jsonPhatSinhVal = modalContent.querySelector('#inpJsonPhatSinh').value;

        // Sinh Sothaydoi kỹ thuật nếu chưa nhập (tối đa 20 ký tự theo DB)
        if (!soPhuLuc) {
          var timeStr = new Date().getTime().toString().slice(-8);
          soPhuLuc = 'PL' + timeStr;
        }

        var parts = ngayLapPL.split('-'); // YYYY-MM-DD
        var nNam = parts[0];
        var nThang = parts[1];
        var nNgay = parts[2];

        var userObj = {};
        try {
          userObj = JSON.parse(localStorage.getItem('pmql_user') || '{}');
        } catch (err) { }
        var currentUserName = userObj.Username || userObj.UserName || userObj.username || 'system';

        // Payload khớp với API_LuuPhuLucHopDong:
        var payload = {
          List: 'frmPhuLucHopDong',
          Func: 'Save',
          Sothaydoi: soPhuLuc,
          Sohopdong: sohopdong,
          Ngaythaydoi: ngayLapPL,
          Ghichu: thoathuan,
          Status: 'DRAFT',
          UserName: currentUserName,
          JsonData: JSON.stringify({
            Sothaydoi: soPhuLuc,
            Sohopdong: sohopdong,
            Ngaythaydoi: ngayLapPL,
            Ghichu: thoathuan,
            Status: 'DRAFT',
            UserName: currentUserName,

            SoPhuLuc: soPhuLuc,
            NgayLapPL: ngayLapPL,
            NgayLapPLDay: nNgay,
            ThangLapPL: nThang,
            NamLapPL: nNam,

            QuyMoBanTu: qmTu,
            QuyMoBanTuTD: qmTuVal,
            QuyMoBanDen: qmDen,
            QuyMoBanDenTD: qmDenVal,

            DonGiaBanTiec: donGia,
            DonGiaBanTiecTD: donGiaVal,
            SoKhachTrenBan: soKhach,
            SoKhachTrenBanTD: soKhachVal,

            TenDotThanhToan: tenDot,
            TenDotThanhToanTD: tenDotVal,
            ThanhToanDot2SoTien: soTienDot2,
            ThanhToanDot2SoTienTD: soTienDot2Val,
            HinhThucThanhToanDot2: hinhThuc,
            HinhThucThanhToanDot2TD: hinhThucVal,
            HanThanhToanDot2: hanThanhToan,
            HanThanhToanDot2TD: hanThanhToanVal,

            BenAChucVuDaiDien: chucVu,
            BenAChucVuDaiDienTD: chucVuVal,
            NgayToChuc: ngayToChuc,
            NgayToChucTD: ngayToChucTDVal,
            NhamNgay: nhamNgay,
            NhamNgayTD: (ngayToChucTDVal === ngayToChuc) ? nhamNgay : '',

            DichVuTinhPhiPhuLuc: dvTinhPhi,
            DichVuTinhPhiPhuLucTD: dvTinhPhiVal,
            ThoaThuanPhuLucKhac: uuDai,
            ThoaThuanPhuLucKhacTD: uuDaiVal,

            Ghichu: thoathuan,

            JsonBanTiec: JSON.parse(jsonBanTiecVal || '[]'),
            JsonThucUong: JSON.parse(jsonThucUongVal || '[]'),
            JsonDichVu: JSON.parse(jsonDichVuVal || '[]'),
            JsonPhatSinh: JSON.parse(jsonPhatSinhVal || '[]')
          })
        };

        var submitBtn = form.querySelector('button[type="submit"]');
        var originalBtnHtml = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="material-symbols-outlined" style="animation: spin 1s linear infinite;">autorenew</span> Đang lưu...';

        ContractService.savePhuLuc(payload).then(function (res) {
          if (res && (res.code === 0 || res.success || res.status === 200 || !res.error)) {
            // Đóng modal đúng tham chiếu
            if (modalInstance && typeof modalInstance.closeNow === 'function') {
              modalInstance.closeNow();
            } else {
              var overlay = document.querySelector('.modal-overlay');
              if (overlay) overlay.remove();
            }
            if (typeof UIToast !== 'undefined') {
              UIToast.show('Đã lưu phụ lục: ' + soPhuLuc, 'success');
            }
            if (typeof onReload === 'function') {
              try { onReload(); } catch (err) { }
            }
            // Sinh tài liệu DOCX ngay lập tức
            try {
              _generateDocument(soPhuLuc);
            } catch (e) {
              console.error('[PhuLucPlugin] Lỗi _generateDocument:', e);
            }
          } else {
            if (typeof Alert !== 'undefined') Alert.error('Lỗi lưu', (res && res.message) || 'Có lỗi khi lưu phụ lục.');
            else alert('Có lỗi khi lưu phụ lục.');
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalBtnHtml;
          }
        }).catch(function (err) {
          console.error('[PhuLucPlugin] Save error:', err);
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không thể kết nối đến server.');
          submitBtn.disabled = false;
          submitBtn.innerHTML = originalBtnHtml;
        });
      };
    });
  }

  function getExtraButtons(formName, getSelectedRows, moduleConfig, onReload) {
    if (formName !== 'frmHopDong') return [];

    return [{
      id: 'btn-create-phuluc',
      text: 'Tạo Phụ Lục',
      icon: 'post_add',
      type: 'tool',
      onClick: function () {
        var selectedRows = getSelectedRows();
        if (!selectedRows || selectedRows.length !== 1) {
          if (typeof Alert !== 'undefined') {
            Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Hợp Đồng duy nhất để tạo Phụ Lục.');
          } else {
            alert('Vui lòng chọn 1 Hợp Đồng!');
          }
          return;
        }

        var row = selectedRows[0];
        var sohopdong = row.Sohopdong || row.sohopdong || row.SoHopDong;

        if (typeof ApiClient !== 'undefined' && window.API_CONFIG && window.API_CONFIG.ENDPOINTS) {
          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đang tải thực đơn hợp đồng...', 'info');
          }

          // Gọi API GetDetails của frmHopDong để lấy thực đơn chi tiết từ CSDL
          ApiClient.post(window.API_CONFIG.ENDPOINTS.ROUTER, {
            List: 'frmHopDong',
            Func: 'GetDetails',
            Keyword: sohopdong
          }).then(function (res) {
            var details = {};
            if (res) {
              if (res.records && res.records.length > 0)      details = res.records[0];
              else if (res.data && res.data.length > 0)       details = res.data[0];
              else if (Array.isArray(res) && res.length > 0)  details = res[0];
              else if (!res.records && !res.data && !Array.isArray(res)) details = res;
            }
            var jsonBanTiec = details.JsonBanTiec || '[]';
            var jsonThucUong = details.JsonThucUong || '[]';
            var jsonDichVu = details.JsonDichVu || '[]';
            var jsonPhatSinh = details.JsonPhatSinh || '[]';

            // Gộp dữ liệu chi tiết của hợp đồng gốc vào row để điền các trường cũ
            var mergedRow = Object.assign({}, row, details);
            _showPhuLucModal(mergedRow, jsonBanTiec, jsonThucUong, jsonDichVu, jsonPhatSinh, onReload);
          }).catch(function (err) {
            console.error('[PhuLucPlugin] Lỗi tải thực đơn:', err);
            _showPhuLucModal(row, '[]', '[]', '[]', '[]', onReload);
          });
        } else {
          _showPhuLucModal(row, '[]', '[]', '[]', '[]', onReload);
        }
      }
    }];
  }

  // Đăng ký Plugin vào hệ thống
  window.FormActionPlugins = window.FormActionPlugins || [];
  window.FormActionPlugins.push({ getExtraButtons: getExtraButtons });

  return { getExtraButtons: getExtraButtons };
})();
