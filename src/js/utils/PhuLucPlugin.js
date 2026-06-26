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
      @media (max-width: 768px) {
        .phuluc-history-card, .phuluc-form-card {
          border: none !important;
          border-radius: 0px !important;
          padding: 12px 0px !important;
          background: transparent !important;
          box-shadow: none !important;
        }
      }
      .phuluc-history-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 0;
        margin-bottom: 8px;
      }
      .phuluc-history-title {
        margin: 0;
        font-size: 15px;
        color: var(--color-primary);
        display: flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
      }
      .phuluc-btn-create {
        white-space: nowrap;
        flex-shrink: 0;
      }
      .phuluc-table {
        width: 100%;
        min-width: 600px;
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
        white-space: nowrap;
      }
      .phuluc-table td {
        white-space: nowrap;
      }
      .phuluc-table td.phuluc-content-col {
        white-space: normal;
        word-break: break-word;
      }
      .phuluc-table tr.active-row {
        background: rgba(79, 70, 229, 0.15) !important;
      }
      .phuluc-table tr.active-row td {
        font-weight: 600;
        color: var(--color-primary, #4f46e5) !important;
      }
      .badge-mode {
        display: inline-block;
        padding: 4px 8px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 4px;
        margin-left: 8px;
        vertical-align: middle;
      }
      .badge-mode-new {
        background: rgba(16, 185, 129, 0.15);
        color: var(--color-success, #10b981);
        border: 1px solid rgba(16, 185, 129, 0.3);
      }
      .badge-mode-edit {
        background: rgba(245, 158, 11, 0.15);
        color: var(--color-warning, #f59e0b);
        border: 1px solid rgba(245, 158, 11, 0.3);
      }
      .phuluc-form-card label,
      .phuluc-form-card .form-label {
        white-space: nowrap !important;
        overflow: hidden !important;
        text-overflow: ellipsis !important;
        display: block !important;
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

  function _getProp(obj, key) {
    if (!obj) return undefined;
    if (obj[key] !== undefined) return obj[key];
    var lower = key.toLowerCase();
    for (var k in obj) {
      if (k.toLowerCase() === lower) return obj[k];
    }
    return undefined;
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

    var sohopdong = _getProp(contractRow, 'Sohopdong') || _getProp(contractRow, 'sohopdong') || _getProp(contractRow, 'SoHopDong');
    var khachhang = _getProp(contractRow, 'Khachhang') || _getProp(contractRow, 'Daidiendat') || _getProp(contractRow, 'TenKhachHang') || '';

    // Khai báo sẵn các trường mặc định từ hợp đồng gốc
    var qmTu = _getProp(contractRow, 'SanhQuyMoMin') || _getProp(contractRow, 'QuyMoBanTu') || _getProp(contractRow, 'quymobantu') || _getProp(contractRow, 'QuyMoBanTuTD') || '';
    var qmDen = _getProp(contractRow, 'SanhQuyMoMax') || _getProp(contractRow, 'QuyMoBanDen') || _getProp(contractRow, 'quymobanden') || _getProp(contractRow, 'QuyMoBanDenTD') || '';
    var donGia = _getProp(contractRow, 'Giabanman') || _getProp(contractRow, 'giabanman') || _getProp(contractRow, 'DonGiaBanTiec') || '';
    var soKhach = _getProp(contractRow, 'TiecSoKhach1Ban') || _getProp(contractRow, 'SoNguoiTrenBan') || _getProp(contractRow, 'SoKhachTrenBan') || 10;
    var tenDot = _getProp(contractRow, 'TenDotThanhToan') || 'Đợt 2';
    var soTienDot2 = _getProp(contractRow, 'Sotiencochopdong') || _getProp(contractRow, 'ThanhToanDot2SoTien') || '';
    var hinhThuc = _getProp(contractRow, 'Dot2HinhThuc') || _getProp(contractRow, 'HinhThucThanhToanDot2') || 'Chuyển khoản';
    var hanThanhToan = _getProp(contractRow, 'Ngayhopdong') || _getProp(contractRow, 'NgayHopDong') || _getProp(contractRow, 'HanThanhToanDot2') || '';
    if (hanThanhToan && hanThanhToan.indexOf('T') !== -1) hanThanhToan = hanThanhToan.split('T')[0];

    var chucVu = _getProp(contractRow, 'BenAChucVu') || _getProp(contractRow, 'BenAChucVuDaiDien') || '';
    var ngayToChuc = _getProp(contractRow, 'NgayToChuc') || _getProp(contractRow, 'Ngaytochuc') || '';
    if (ngayToChuc && ngayToChuc.indexOf('T') !== -1) ngayToChuc = ngayToChuc.split('T')[0];

    var nhamNgay = _getProp(contractRow, 'Nhamngay') || _getProp(contractRow, 'NhamNgay') || '';
    var dvTinhPhi = _getProp(contractRow, 'DichVuTinhPhiPhuLuc') || '';
    var uuDai = _getProp(contractRow, 'DSKhuyenMai') || _getProp(contractRow, 'Noidunguudai') || _getProp(contractRow, 'ThoaThuanPhuLucKhac') || '';
    var lyDo = _getProp(contractRow, 'Ghichu') || _getProp(contractRow, 'LyDoDieuChinh') || '';

    // Lấy lịch sử phụ lục
    ContractService.getPhuLucHistory(sohopdong).then(function (historyRecords) {
      var historyHtml = '';
      if (!historyRecords || historyRecords.length === 0) {
        historyHtml = '<tr><td colspan="5" class="text-center text-muted">Chưa có phụ lục / thay đổi nào.</td></tr>';
      } else {
        historyRecords.forEach(function (rec, index) {
          var id = _getProp(rec, 'SoPhuLuc') || _getProp(rec, 'Sothaydoi') || '';
          var ngay = _getProp(rec, 'Ngaythaydoi') || _getProp(rec, 'NgayLapPL') || _getProp(rec, 'NgayLap') || '';
          if (ngay && ngay.indexOf('T') !== -1) ngay = ngay.split('T')[0];
          var lydo = _getProp(rec, 'LyDoDieuChinh') || _getProp(rec, 'GhiChu') || _getProp(rec, 'Ghichu') || '';
          historyHtml += `
            <tr>
              <td class="text-center">${index + 1}</td>
              <td><a href="javascript:void(0)" class="btn-edit-pl" style="font-weight: 600; color: var(--color-primary); text-decoration: none;" data-idx="${index}">${id}</a></td>
              <td>${ngay}</td>
              <td class="phuluc-content-col">${lydo}</td>
              <td class="text-center">
                <button type="button" class="btn btn-sm btn-link btn-edit-pl" data-idx="${index}" title="Sửa" style="padding: 2px 4px; border: none; background: transparent; cursor: pointer; color: var(--color-primary);">
                  <span class="material-symbols-outlined" style="font-size: 18px; vertical-align: middle;">edit</span>
                </button>
                <button type="button" class="btn btn-sm btn-link text-danger btn-delete-pl" data-id="${id}" title="Xóa" style="padding: 2px 4px; border: none; background: transparent; cursor: pointer; color: var(--color-danger);">
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
          <div class="phuluc-history-header">
            <h5 class="phuluc-history-title">
              <span class="material-symbols-outlined" style="font-size: 20px;">history</span> 
              <span>Lịch Sử Phụ Lục / Thay Đổi</span>
            </h5>
            <button type="button" id="btnCreateNewPLTop" class="btn btn-sm btn-primary d-flex align-items-center gap-1 phuluc-btn-create" style="font-size: 12px; padding: 6px 12px; font-weight: 600;">
              <span class="material-symbols-outlined" style="font-size: 16px;">add</span> Tạo Mới Phụ Lục
            </button>
          </div>
          <p class="text-muted" style="margin-bottom: 12px; font-size: 13px;">Hợp đồng: <strong>${sohopdong}</strong> - Khách hàng: <strong>${khachhang}</strong></p>
          <div style="max-height: 150px; overflow-y: auto; overflow-x: auto;">
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
          <h5 id="form-title" style="margin-top: 0; font-size: 15px; color: var(--color-primary); display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
            <span class="material-symbols-outlined" style="font-size: 20px;">add_circle</span> 
            <span>Tạo Phụ Lục Mới</span>
            <span class="badge-mode badge-mode-new">CHẾ ĐỘ: TẠO MỚI</span>
          </h5>
          <p class="text-muted" style="margin-top: -6px; margin-bottom: 16px; font-size: 12px; font-style: italic;">
            * Form được điền sẵn thông tin gốc từ Hợp đồng để bạn dễ dàng đối chiếu và điều chỉnh.
          </p>
          <form id="frmPhuLucCreate">
            <input type="hidden" name="JsonBanTiec" id="inpJsonBanTiec" value="[]">
            <input type="hidden" name="JsonThucUong" id="inpJsonThucUong" value="[]">
            <input type="hidden" name="JsonDichVu" id="inpJsonDichVu" value="[]">
            <input type="hidden" name="JsonPhatSinh" id="inpJsonPhatSinh" value="[]">
            <div class="row">
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Phụ Lục</label>
                <input type="text" id="inpSothaydoi" class="ui-input" placeholder="Tự sinh nếu để trống" maxlength="20" style="width: 100%;">
              </div>
              <div class="col-6 mb-3" id="containerNgayLapPL"></div>
            </div>

            <div class="row">
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Quy Mô Bàn (Từ)</label>
                <input type="number" id="inpQuyMoBanTu" class="ui-input" style="width: 100%;" min="0">
              </div>
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Quy Mô Bàn (Đến)</label>
                <input type="number" id="inpQuyMoBanDen" class="ui-input" style="width: 100%;" min="0">
              </div>
            </div>

            <div class="row">
              <div class="col-6 mb-3" id="containerDonGia"></div>
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Khách / Bàn</label>
                <input type="number" id="inpSoKhachTrenBan" class="ui-input" style="width: 100%;" min="1" max="100">
              </div>
            </div>

            <div class="row">
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Đợt Thanh Toán</label>
                <input type="text" id="inpTenDotThanhToan" class="ui-input" placeholder="Ví dụ: Đợt 2" style="width: 100%;">
              </div>
              <div class="col-6 mb-3" id="containerThanhToanDot2"></div>
            </div>

            <div class="row">
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Hình Thức T.Toán</label>
                <select id="inpHinhThucThanhToanDot2" class="ui-input" style="width: 100%;">
                  <option value="">Giữ nguyên từ Hợp đồng</option>
                  <option value="Chuyển khoản">Chuyển khoản</option>
                  <option value="Tiền mặt">Tiền mặt</option>
                  <option value="Tiền mặt / Chuyển khoản">Tiền mặt / Chuyển khoản</option>
                </select>
              </div>
              <div class="col-6 mb-3" id="containerHanThanhToanDot2"></div>
            </div>

            <div class="row">
              <div class="col-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Chức Vụ Đại Diện</label>
                <input type="text" id="inpBenAChucVuDaiDien" class="ui-input" placeholder="Ví dụ: Đại diện kinh doanh" style="width: 100%;">
              </div>
              <div class="col-6 mb-3" id="containerNgayToChucTD"></div>
            </div>

            <div class="row">
              <div class="col-12 mb-3">
                <label class="form-label" style="font-weight: 600;">Dịch Vụ Tính Phí</label>
                <textarea id="inpDichVuTinhPhiPhuLuc" class="ui-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Ví dụ:&#10;1. MC tiệc cưới: 2.000.000 VND&#10;2. Màn hình LED: 5.000.000 VND"></textarea>
              </div>
            </div>

            <div class="row">
              <div class="col-12 mb-3">
                <label class="form-label" style="font-weight: 600;">Dịch Vụ Ưu Đãi</label>
                <textarea id="inpThoaThuanPhuLucKhac" class="ui-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Ví dụ:&#10;1. Sân khấu tiêu chuẩn&#10;2. Âm thanh ánh sáng"></textarea>
              </div>
            </div>

            <div class="row">
              <div class="col-12 mb-3">
                <label class="form-label" style="font-weight: 600;">Nội dung thỏa thuận</label>
                <textarea id="inpThoathuan" class="ui-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Nhập nội dung thỏa thuận..."></textarea>
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
        label: 'Ngày Lập PL',
        required: true,
        value: defaultToday
      });
      modalContent.querySelector('#containerNgayLapPL').appendChild(ngayLapInput);

      var hanThanhToanInput = UIInput.createDate({
        id: 'inpHanThanhToanDot2',
        label: 'Hạn Thanh Toán',
        value: ''
      });
      modalContent.querySelector('#containerHanThanhToanDot2').appendChild(hanThanhToanInput);

      var ngayToChucTDInput = UIInput.createDate({
        id: 'inpNgayToChucTD',
        label: 'Ngày Tổ Chức Mới',
        value: ''
      });
      modalContent.querySelector('#containerNgayToChucTD').appendChild(ngayToChucTDInput);

      // Cài đặt tự động format tiền tệ cho Đơn Giá và Số Tiền Đợt 2 bằng component UIInput.createMoney
      var donGiaInput = UIInput.createMoney({
        id: 'inpDonGiaBanTiec',
        label: 'Đơn Giá Bàn (VND)',
        value: ''
      });
      modalContent.querySelector('#containerDonGia').appendChild(donGiaInput);

      var thanhToanDot2Input = UIInput.createMoney({
        id: 'inpThanhToanDot2SoTien',
        label: 'Số Tiền Đợt 2 (VND)',
        value: ''
      });
      modalContent.querySelector('#containerThanhToanDot2').appendChild(thanhToanDot2Input);

      // Lấy username hiện hành
      var userObj = {};
      try {
        userObj = JSON.parse(localStorage.getItem('pmql_user') || '{}');
      } catch (err) { }
      var currentUserName = userObj.Username || userObj.UserName || userObj.username || 'system';

      // Định nghĩa các helper điền form/reset form
      function _setupFormPlaceholders() {
        var _formatDateVN = function (dateStr) {
          if (!dateStr) return '';
          var p = dateStr.split('-');
          if (p.length === 3) return p[2] + '/' + p[1] + '/' + p[0];
          return dateStr;
        };

        var _formatMoneyVN = function (val) {
          if (!val) return '0';
          var num = parseInt(String(val).replace(/\D/g, ''), 10);
          return isNaN(num) ? '0' : num.toLocaleString('vi-VN');
        };

        modalContent.querySelector('#inpQuyMoBanTu').placeholder = qmTu ? 'Hiện tại: ' + qmTu : 'Nhập quy mô từ...';
        modalContent.querySelector('#inpQuyMoBanDen').placeholder = qmDen ? 'Hiện tại: ' + qmDen : 'Nhập quy mô đến...';
        
        var inpDonGiaEl = modalContent.querySelector('#inpDonGiaBanTiec');
        if (inpDonGiaEl) {
          inpDonGiaEl.placeholder = donGia ? 'Hiện tại: ' + _formatMoneyVN(donGia) : 'Nhập đơn giá...';
        }

        modalContent.querySelector('#inpSoKhachTrenBan').placeholder = soKhach ? 'Hiện tại: ' + soKhach : 'Nhập số khách...';
        modalContent.querySelector('#inpTenDotThanhToan').placeholder = tenDot ? 'Hiện tại: ' + tenDot : 'Nhập tên đợt...';
        
        var inpThanhToanDot2El = modalContent.querySelector('#inpThanhToanDot2SoTien');
        if (inpThanhToanDot2El) {
          inpThanhToanDot2El.placeholder = soTienDot2 ? 'Hiện tại: ' + _formatMoneyVN(soTienDot2) : 'Nhập số tiền đợt 2...';
        }

        var inpHinhThucOpt = modalContent.querySelector('#inpHinhThucThanhToanDot2 option[value=""]');
        if (inpHinhThucOpt) {
          inpHinhThucOpt.innerText = hinhThuc ? 'Giữ nguyên: ' + hinhThuc : 'Giữ nguyên từ Hợp đồng';
        }

        var inpHanVisible = modalContent.querySelector('#inpHanThanhToanDot2_visible');
        if (inpHanVisible) {
          inpHanVisible.placeholder = hanThanhToan ? 'Hiện tại: ' + _formatDateVN(hanThanhToan) : 'Chọn hạn thanh toán...';
        }

        modalContent.querySelector('#inpBenAChucVuDaiDien').placeholder = chucVu ? 'Hiện tại: ' + chucVu : 'Nhập chức vụ...';

        var inpNgayTCVisible = modalContent.querySelector('#inpNgayToChucTD_visible');
        if (inpNgayTCVisible) {
          inpNgayTCVisible.placeholder = ngayToChuc ? 'Hiện tại: ' + _formatDateVN(ngayToChuc) : 'Chọn ngày tổ chức...';
        }

        modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').placeholder = 'Mỗi dòng 1 dịch vụ, cách bằng ";":\nVí dụ: MC tiệc; 2000000; Ghi chú\nMàn hình LED; 5000000;' + (dvTinhPhi ? '\n\n[Hợp đồng gốc: ' + dvTinhPhi + ']' : '');
        modalContent.querySelector('#inpThoaThuanPhuLucKhac').placeholder = uuDai ? 'Hiện tại:\n' + uuDai : 'Nhập dịch vụ ưu đãi...';
        modalContent.querySelector('#inpThoathuan').placeholder = lyDo ? 'Hiện tại:\n' + lyDo : 'Nhập nội dung thỏa thuận...';
      }

      function _fillFormForEdit(rec, rowElement) {
        modalContent.querySelectorAll('.phuluc-table tbody tr').forEach(function (tr) {
          tr.classList.remove('active-row');
        });
        if (rowElement) {
          rowElement.classList.add('active-row');
        }

        var id = _getProp(rec, 'SoPhuLuc') || _getProp(rec, 'Sothaydoi') || '';

        modalContent.querySelector('#form-title').innerHTML = `
          <span class="material-symbols-outlined" style="font-size: 20px; vertical-align: middle;">edit_document</span> 
          <span style="vertical-align: middle;">Cập Nhật Phụ Lục</span>
          <span class="badge-mode badge-mode-edit">ĐANG SỬA BẢN GHI: ${id}</span>
        `;
        modalContent.querySelector('#btnCancelEdit').style.display = 'block';

        modalContent.querySelector('#inpSothaydoi').value = id;
        modalContent.querySelector('#inpSothaydoi').disabled = true;

        var ngayLap = _getProp(rec, 'Ngaythaydoi') || _getProp(rec, 'NgayLapPL') || _getProp(rec, 'NgayLap') || '';
        if (ngayLap && ngayLap.indexOf('T') !== -1) ngayLap = ngayLap.split('T')[0];
        modalContent.querySelector('#inpNgayLapPL').value = ngayLap;

        var qmTu = _getProp(rec, 'QuyMoBanTu');
        modalContent.querySelector('#inpQuyMoBanTu').value = (qmTu !== null && qmTu !== undefined) ? qmTu : '';
        var qmDen = _getProp(rec, 'QuyMoBanDen');
        modalContent.querySelector('#inpQuyMoBanDen').value = (qmDen !== null && qmDen !== undefined) ? qmDen : '';

        var inpDonGiaEl = modalContent.querySelector('#inpDonGiaBanTiec');
        if (inpDonGiaEl) {
          var dg = _getProp(rec, 'DonGiaBanTiec');
          inpDonGiaEl.value = (dg !== null && dg !== undefined) ? dg : '';
          inpDonGiaEl.dispatchEvent(new Event('change'));
        }

        var sk = _getProp(rec, 'SoKhachTrenBan');
        modalContent.querySelector('#inpSoKhachTrenBan').value = (sk !== null && sk !== undefined) ? sk : '';

        modalContent.querySelector('#inpTenDotThanhToan').value = _getProp(rec, 'TenDotThanhToan') || '';

        var inpThanhToanDot2El = modalContent.querySelector('#inpThanhToanDot2SoTien');
        if (inpThanhToanDot2El) {
          var tt = _getProp(rec, 'ThanhToanDot2SoTien');
          inpThanhToanDot2El.value = (tt !== null && tt !== undefined) ? tt : '';
          inpThanhToanDot2El.dispatchEvent(new Event('change'));
        }
        modalContent.querySelector('#inpHinhThucThanhToanDot2').value = _getProp(rec, 'HinhThucThanhToanDot2') || '';

        var hanTT = _getProp(rec, 'HanThanhToanDot2') || '';
        if (hanTT && hanTT.indexOf('T') !== -1) hanTT = hanTT.split('T')[0];
        var inpHanTTEl = modalContent.querySelector('#inpHanThanhToanDot2');
        if (inpHanTTEl) {
          inpHanTTEl.value = hanTT;
          inpHanTTEl.dispatchEvent(new Event('change'));
        }

        modalContent.querySelector('#inpBenAChucVuDaiDien').value = _getProp(rec, 'BenAChucVuDaiDien') || '';

        var ngayTCTD = _getProp(rec, 'NgayToChuc') || '';
        if (ngayTCTD && ngayTCTD.indexOf('T') !== -1) ngayTCTD = ngayTCTD.split('T')[0];
        var inpNgayTCTDEl = modalContent.querySelector('#inpNgayToChucTD');
        if (inpNgayTCTDEl) {
          inpNgayTCTDEl.value = ngayTCTD;
          inpNgayTCTDEl.dispatchEvent(new Event('change'));
        }

        modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value = _getProp(rec, 'DichVuTinhPhiPhuLuc') || '';
        modalContent.querySelector('#inpThoaThuanPhuLucKhac').value = _getProp(rec, 'ThoaThuanPhuLucKhac') || '';
        modalContent.querySelector('#inpThoathuan').value = _getProp(rec, 'LyDoDieuChinh') || _getProp(rec, 'GhiChu') || _getProp(rec, 'Ghichu') || '';

        modalContent.querySelector('#inpJsonBanTiec').value = _stringifyJson(_getProp(rec, 'JsonBanTiec'));
        modalContent.querySelector('#inpJsonThucUong').value = _stringifyJson(_getProp(rec, 'JsonThucUong'));
        modalContent.querySelector('#inpJsonDichVu').value = _stringifyJson(_getProp(rec, 'JsonDichVu'));
        modalContent.querySelector('#inpJsonPhatSinh').value = _stringifyJson(_getProp(rec, 'JsonPhatSinh'));
        if (typeof FoodSelectionPlugin !== 'undefined' && typeof FoodSelectionPlugin.reloadForm === 'function') {
          FoodSelectionPlugin.reloadForm(modalContent);
        }
      }

      function _resetFormToNew() {
        modalContent.querySelectorAll('.phuluc-table tbody tr').forEach(function (tr) {
          tr.classList.remove('active-row');
        });

        modalContent.querySelector('#form-title').innerHTML = `
          <span class="material-symbols-outlined" style="font-size: 20px; vertical-align: middle;">add_circle</span> 
          <span style="vertical-align: middle;">Tạo Phụ Lục Mới</span>
          <span class="badge-mode badge-mode-new">CHẾ ĐỘ: TẠO MỚI</span>
        `;
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

        var inpDonGiaEl = modalContent.querySelector('#inpDonGiaBanTiec');
        if (inpDonGiaEl) {
          inpDonGiaEl.value = donGia;
          inpDonGiaEl.dispatchEvent(new Event('change'));
        }

        modalContent.querySelector('#inpSoKhachTrenBan').value = soKhach;
        modalContent.querySelector('#inpTenDotThanhToan').value = tenDot;

        var inpThanhToanDot2El = modalContent.querySelector('#inpThanhToanDot2SoTien');
        if (inpThanhToanDot2El) {
          inpThanhToanDot2El.value = soTienDot2;
          inpThanhToanDot2El.dispatchEvent(new Event('change'));
        }
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

        // Khi tạo MỚI: để trống để user chủ động nhập, không auto-fill từ HĐ gốc
        // (tránh junk text cũ như 'Dịch Vụ Tính Phí' bị gửi lên DB)
        modalContent.querySelector('#inpDichVuTinhPhiPhuLuc').value = '';
        modalContent.querySelector('#inpThoaThuanPhuLucKhac').value = uuDai;
        modalContent.querySelector('#inpThoathuan').value = '';

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
        var createNewBtnTop = e.target.closest('#btnCreateNewPLTop');
        if (createNewBtnTop) {
          _resetFormToNew();
          if (typeof UIToast !== 'undefined') {
            UIToast.show('Đã chuyển sang chế độ Tạo mới Phụ lục', 'info');
          }
          return;
        }

        var editBtn = e.target.closest('.btn-edit-pl');
        if (editBtn) {
          var idx = parseInt(editBtn.getAttribute('data-idx'));
          var rec = historyRecords[idx];
          if (rec) {
            var tr = editBtn.closest('tr');
            _fillFormForEdit(rec, tr);
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

      // Thiết lập placeholder và khởi tạo form trống với thông tin gốc làm placeholder
      _setupFormPlaceholders();
      _resetFormToNew();

      // Xử lý Form Submit
      var form = modalContent.querySelector('#frmPhuLucCreate');
      form.onsubmit = function (e) {
        e.preventDefault();

        var soPhuLuc = modalContent.querySelector('#inpSothaydoi').value.trim();
        var ngayLapPL = modalContent.querySelector('#inpNgayLapPL').value;

        var qmTuVal = modalContent.querySelector('#inpQuyMoBanTu').value;
        var qmDenVal = modalContent.querySelector('#inpQuyMoBanDen').value;
        var donGiaVal = modalContent.querySelector('#inpDonGiaBanTiec').value.replace(/\D/g, '');
        var soKhachVal = modalContent.querySelector('#inpSoKhachTrenBan').value;

        var tenDotVal = modalContent.querySelector('#inpTenDotThanhToan').value.trim();
        var soTienDot2Val = modalContent.querySelector('#inpThanhToanDot2SoTien').value.replace(/\D/g, '');
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

        var formatISO = function (val) {
          return typeof FormatUtils !== 'undefined' ? FormatUtils.formatISO(val) : val;
        };

        // Payload khớp với API_LuuPhuLucHopDong:
        var payload = {
          List: 'frmPhuLucHopDong',
          Func: 'Save',
          Sothaydoi: soPhuLuc,
          Sohopdong: sohopdong,
          Ngaythaydoi: formatISO(ngayLapPL),
          Ghichu: thoathuan,
          Status: 'DRAFT',
          UserName: currentUserName,
          JsonData: JSON.stringify({
            Sothaydoi: soPhuLuc,
            Sohopdong: sohopdong,
            Ngaythaydoi: formatISO(ngayLapPL),
            Ghichu: thoathuan,
            Status: 'DRAFT',
            UserName: currentUserName,

            SoPhuLuc: soPhuLuc,
            NgayLapPL: formatISO(ngayLapPL),
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
            HanThanhToanDot2: formatISO(hanThanhToan),
            HanThanhToanDot2TD: formatISO(hanThanhToanVal),

            BenAChucVuDaiDien: chucVu,
            BenAChucVuDaiDienTD: chucVuVal,
            NgayToChuc: formatISO(ngayToChuc),
            NgayToChucTD: formatISO(ngayToChucTDVal),
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
              if (res.records && res.records.length > 0) details = res.records[0];
              else if (res.data && res.data.length > 0) details = res.data[0];
              else if (Array.isArray(res) && res.length > 0) details = res[0];
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
