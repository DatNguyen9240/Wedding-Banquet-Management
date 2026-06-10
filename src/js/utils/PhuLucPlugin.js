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
      }
      .phuluc-table th {
        background: var(--color-background);
        font-weight: 600;
        color: var(--color-text-secondary);
      }
    `;
    document.head.appendChild(style);
  }

  function _generateDocument(sothaydoi) {
    var DOC_API_BASE = (window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER) ? window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API : 'http://localhost:3000/api/document';
    var config = {
      docType: 'de_nghi_thay_doi',
      sqlListName: 'API_DanhSachThayDoi'
    };
    
    if (typeof Toast !== 'undefined') {
      Toast.show({ message: 'Đang khởi tạo tài liệu...', type: 'info' });
    }

    fetch(DOC_API_BASE + '/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        templateType: config.docType,
        customerId: sothaydoi,
        outputFileName: config.docType + '_' + sothaydoi,
        rowData: {}, // Backend will fetch from API_DanhSachThayDoi using customerId
        sqlListName: config.sqlListName
      })
    })
    .then(function (res) { return res.json(); })
    .then(function (json) {
      if (json.success) {
        if (typeof Toast !== 'undefined') {
          Toast.show({ message: 'Đã tạo tài liệu: ' + json.fileName, type: 'success' });
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

  function _showPhuLucModal(contractRow) {
    _injectStyles();

    var sohopdong = contractRow.Sohopdong || contractRow.sohopdong || contractRow.SoHopDong;
    var khachhang = contractRow.Khachhang || contractRow.Daidiendat || '';

    // Lấy lịch sử phụ lục
    ContractService.getPhuLucHistory(sohopdong).then(function (historyRecords) {
      var historyHtml = '';
      if (!historyRecords || historyRecords.length === 0) {
        historyHtml = '<tr><td colspan="4" class="text-center text-muted">Chưa có phụ lục / thay đổi nào.</td></tr>';
      } else {
        historyRecords.forEach(function (rec, index) {
          var ngay = rec.NgayLapPL || rec.Ngaythaydoi || '';
          if (ngay && ngay.indexOf('T') !== -1) ngay = ngay.split('T')[0];
          historyHtml += `
            <tr>
              <td class="text-center">${index + 1}</td>
              <td><strong>${rec.SoPhuLuc || rec.Sothaydoi || ''}</strong></td>
              <td>${ngay}</td>
              <td>${rec.LyDoDieuChinh || rec.GhiChu || ''}</td>
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
          <div style="max-height: 200px; overflow-y: auto;">
            <table class="phuluc-table">
              <thead>
                <tr>
                  <th style="width: 50px;" class="text-center">STT</th>
                  <th style="width: 120px;">Số Phụ Lục</th>
                  <th style="width: 120px;">Ngày Lập</th>
                  <th>Nội dung thỏa thuận</th>
                </tr>
              </thead>
              <tbody>
                ${historyHtml}
              </tbody>
            </table>
          </div>
        </div>

        <div class="phuluc-form-card">
          <h5 style="margin-top: 0; font-size: 15px; color: var(--color-primary);"><span class="material-symbols-outlined" style="vertical-align: middle; font-size: 18px;">add_circle</span> Tạo Phụ Lục Mới</h5>
          <form id="frmPhuLucCreate">
            <div class="row">
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Số Phụ Lục (Hệ thống tự sinh nếu để trống)</label>
                <input type="text" id="inpSothaydoi" class="ui-input" placeholder="Ví dụ: PL01/2026" maxlength="20" style="width: 100%;">
              </div>
              <div class="col-md-6 mb-3">
                <label class="form-label" style="font-weight: 600;">Ngày Lập Phụ Lục <span class="text-danger">*</span></label>
                <input type="date" id="inpNgayLapPL" class="ui-input" style="width: 100%;" required>
              </div>
              <div class="col-md-12 mb-3">
                <label class="form-label" style="font-weight: 600;">Nội dung thỏa thuận bổ sung</label>
                <textarea id="inpThoathuan" class="ui-input" rows="4" style="width: 100%; resize: vertical;" placeholder="Nhập các nội dung thay đổi như: Tăng bàn, Đổi sảnh, Thay đổi thực đơn..."></textarea>
              </div>
            </div>
            <div class="d-flex justify-content-end gap-2 mt-2">
              <button type="button" class="btn btn-outline-secondary" onclick="document.querySelector('.ui-modal-overlay').remove()">Hủy</button>
              <button type="submit" class="btn btn-success d-flex align-items-center gap-1"><span class="material-symbols-outlined" style="font-size: 18px;">save</span> Lưu & Tạo File Word</button>
            </div>
          </form>
        </div>
      `;

      var modalInstance = UIModal.show({
        title: 'Quản Lý Phụ Lục Hợp Đồng',
        width: '800px',
        content: modalContent
      });

      // Gán ngày hiện tại làm mặc định
      var today = new Date();
      var yyyy = today.getFullYear();
      var mm = String(today.getMonth() + 1).padStart(2, '0');
      var dd = String(today.getDate()).padStart(2, '0');
      modalContent.querySelector('#inpNgayLapPL').value = yyyy + '-' + mm + '-' + dd;

      // Xử lý Form Submit
      var form = modalContent.querySelector('#frmPhuLucCreate');
      form.onsubmit = function (e) {
        e.preventDefault();
        
        var soPhuLuc = document.getElementById('inpSothaydoi').value.trim();
        var ngayLapPL = document.getElementById('inpNgayLapPL').value;
        var thoathuan = document.getElementById('inpThoathuan').value;

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
        } catch (err) {}
        var currentUserName = userObj.Username || userObj.UserName || userObj.username || 'system';

        // Payload khớp với API_LuuThayDoi:
        // - Sothaydoi, Sohopdong, Ngaythaydoi, Ghichu, Status: tham số cấp cao
        // - JsonData: chứa các trường nghiệp vụ chi tiết
        var payload = {
          List: 'tbmk_PhuLucHopDong',
          Func: 'Save',
          Sothaydoi: soPhuLuc,
          Sohopdong: sohopdong,
          Ngaythaydoi: ngayLapPL,
          Ghichu: thoathuan,
          Status: 'DRAFT',
          UserName: currentUserName,
          JsonData: JSON.stringify({
            SoPhuLuc: soPhuLuc,
            NgayLapPL: ngayLapPL,
            NgayLapPLDay: nNgay,
            ThangLapPL: nThang,
            NamLapPL: nNam,
            ThoaThuanPhuLucKhacTD: thoathuan
          })
        };

        var submitBtn = form.querySelector('button[type="submit"]');
        var originalBtnHtml = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<span class="material-symbols-outlined" style="animation: spin 1s linear infinite;">autorenew</span> Đang lưu...';

        ContractService.savePhuLuc(payload).then(function(res) {
          if (res && (res.code === 0 || res.success || res.status === 200 || !res.error)) {
            // Đóng modal đúng tham chiếu
            if (modalInstance && typeof modalInstance.closeNow === 'function') {
              modalInstance.closeNow();
            } else {
              var overlay = document.querySelector('.ui-modal-overlay');
              if (overlay) overlay.remove();
            }
            if (typeof Toast !== 'undefined') {
              Toast.show({ message: 'Đã lưu phụ lục: ' + soPhuLuc, type: 'success' });
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
        }).catch(function(err) {
          console.error('[PhuLucPlugin] Save error:', err);
          if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không thể kết nối đến server.');
          submitBtn.disabled = false;
          submitBtn.innerHTML = originalBtnHtml;
        });
      };
    });
  }

  function getExtraButtons(formName, getSelectedRows) {
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
        _showPhuLucModal(row);
      }
    }];
  }

  // Đăng ký Plugin vào hệ thống
  window.FormActionPlugins = window.FormActionPlugins || [];
  window.FormActionPlugins.push({ getExtraButtons: getExtraButtons });

  return { getExtraButtons: getExtraButtons };
})();
