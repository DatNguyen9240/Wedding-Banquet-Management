/**
 * DocumentExportPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin cấu hình nút "Xuất tài liệu" cho các form:
 *   frmHopDong   → Hợp đồng tiệc     (PK: Sohopdong)
 *   frmBiennhancoccho    → Biên nhận đặt cọc (PK: MaChungTu)
 *   frmQuyetToan → Quyết toán        (PK: Sohopdong)
 */
var DocumentExportPlugin = (function () {
  var DOC_API_BASE = window.API_CONFIG.ENDPOINTS.DOCUMENT_MANAGER.BASE_API;

  var FORM_CONFIG = {
    'frmHopDong': {
      docType: 'hop_dong',
      label: 'Xuất Hợp Đồng',
      icon: 'description',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong'],
      sqlListName: 'API_DanhSachHopDong'
    },
    'frmBiennhancoccho': {
      docType: 'phieu_thu',
      label: 'Xuất Phiếu Thu',
      icon: 'receipt_long',
      altKeys: ['MaChungTu', 'maChungTu', 'DocumentID', 'SoPhieu'],
      sqlListName: 'API_DanhSachPhieuCoc'
    },
    'frmQuyetToan': {
      docType: 'quyet_toan',
      label: 'Xuất Quyết Toán',
      icon: 'receipt',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong'],
      sqlListName: 'API_DanhSachQuyetToan'
    },
    'tbmk_Thaydoi': {
      docType: 'de_nghi_thay_doi',
      label: 'Xuất Phiếu Thay Đổi',
      icon: 'edit_note',
      altKeys: ['Sothaydoi', 'sothaydoi', 'SoThayDoi', 'Sohopdong', 'sohopdong'],
      sqlListName: 'API_DanhSachThayDoi',
      convertFields: ['ThoaThuanPhuLucKhac']
    },
    'frmPhuLucHopDong': {
      docType: 'phu_luc_hop_dong',
      label: 'Xuất Phụ Lục HĐ',
      icon: 'description',
      altKeys: ['SoPhuLuc', 'soPhuLuc', 'Sothaydoi', 'sothaydoi', 'Sohopdong', 'sohopdong'],
      sqlListName: 'frmPhuLucHopDong',
      convertFields: ['DichVuTinhPhiPhuLuc', 'ThoaThuanPhuLucKhac']
    },
    'frmThayDoiBoSung': {
      docType: 'phu_luc_hop_dong',
      label: 'Xuất Phụ Lục HĐ',
      icon: 'description',
      altKeys: ['SoPhuLuc', 'soPhuLuc', 'Sothaydoi', 'sothaydoi', 'Sohopdong', 'sohopdong'],
      sqlListName: 'frmPhuLucHopDong',
      convertFields: ['DichVuTinhPhiPhuLuc', 'ThoaThuanPhuLucKhac']
    },
    'frmBEO': {
      docType: 'beo_tiec_cuoi',
      label: 'Xuất BEO',
      icon: 'print',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong'],
      sqlListName: 'frmBEO',
      convertFields: ['ThongTinSetup', 'NoteBaoVe', 'NoteBieuNgu', 'NoteKyThuat', 'NoteLobby'],
      getDocType: function (row) {
        var lh = (row.LoaiHinhSuKien || row.LoaiHinhSK || '').toString().toLowerCase();
        if (lh.includes('hội nghị') || lh.includes('hoi nghi') || lh.includes('conference')) {
          return 'BEO_Hoi_Nghi';
        }
        return 'BEO_Tiec_Cuoi';
      }
    },
    'frmBaoGia': {
      docType: 'bao_gia',
      label: 'Xuất Báo Giá',
      icon: 'request_quote',
      altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong'],
      sqlListName: 'frmBaoGia',
      convertFields: ['LuuYChung', 'GhiChuSanh1', 'GhiChuSanh2', 'GhiChuSanh3']
    }
  };

  function _getPrimaryKey(row, config) {
    if (!row) return null;
    for (var i = 0; i < config.altKeys.length; i++) {
      var v = row[config.altKeys[i]];
      if (v !== undefined && v !== null && v !== '') return String(v);
    }
    return null;
  }

  function _generateDocument(row, config) {
    var docId = _getPrimaryKey(row, config);
    if (!docId) {
      if (typeof Alert !== 'undefined') {
        Alert.error('Lỗi', 'Không tìm thấy mã chứng từ của dòng này. Kiểm tra lại cấu hình primaryKey.');
      } else {
        alert('Không tìm thấy ID của dòng này!');
      }
      return;
    }

    // Đọc tên file mẫu từ DB (được cấu hình trong bảng tbmk_LoaitiecAddfile qua View)
    var actualDocType = config.docType;
    if (row.TemplateFile && !config.ignoreTemplateFile) {
      actualDocType = row.TemplateFile;
    } else if (typeof config.getDocType === 'function') {
      actualDocType = config.getDocType(row);
    }

    var btn = document.getElementById('btn-export-doc-' + config.docType);
    var originalHTML = btn ? btn.innerHTML : '';
    if (btn) {
      btn.disabled = true;
      btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;animation:spin 1s linear infinite;">autorenew</span><span class="d-none d-md-inline">Đang xuất...</span>';
    }

    if (!document.getElementById('__dep_spin__')) {
      var ks = document.createElement('style');
      ks.id = '__dep_spin__';
      ks.textContent = '@keyframes spin{from{transform:rotate(0)}to{transform:rotate(360deg)}}';
      document.head.appendChild(ks);
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
        templateType: actualDocType,
        customerId: docId,
        outputFileName: actualDocType + '_' + docId,
        rowData: row,
        sqlListName: config.sqlListName,
        convertFields: config.convertFields || []
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
        console.error('[DocumentExportPlugin]', err);
      })
      .finally(function () {
        if (btn) {
          btn.disabled = false;
          btn.innerHTML = originalHTML;
        }
      });
  }

  function getExtraButtons(formName, getSelectedRows) {
    var config = FORM_CONFIG[formName];
    if (!config) return [];

    var buttons = [{
      id: 'btn-export-doc-' + config.docType,
      text: config.label,
      icon: config.icon,
      type: 'tool',
      onClick: function () {
        var selectedRows = getSelectedRows();
        if (!selectedRows || selectedRows.length !== 1) {
          if (typeof Alert !== 'undefined') {
            Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 dòng duy nhất để xuất tài liệu.');
          } else {
            alert('Vui lòng chọn 1 dòng để xuất tài liệu!');
          }
          return;
        }

        var row = selectedRows[0];
        // Bỏ chặn xuất lại file cho Hợp đồng/Phiếu đã chốt (Đã ký) theo yêu cầu
        /*
        var st = (row.Status || row.TrangThai || '').toString().toLowerCase();
        if (st.includes('đã ký')) {
          if (typeof Alert !== 'undefined') {
            Alert.warning('Bị khóa', 'Không thể xuất lại file cho Hợp đồng/Phiếu đã chốt (Đã ký).');
          } else {
            alert('Không thể xuất lại file cho Hợp đồng/Phiếu đã chốt (Đã ký).');
          }
          return;
        }
        */

        _generateDocument(row, config);
      }
    }];

    if (formName === 'frmHopDong' || formName === 'frmQuyetToan') {
      buttons.push({
        id: 'btn-export-phatsinh',
        text: 'Xuất BB Phát Sinh',
        icon: 'post_add',
        type: 'tool',
        onClick: function () {
          var selectedRows = getSelectedRows();
          if (!selectedRows || selectedRows.length !== 1) {
            if (typeof Alert !== 'undefined') Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 dòng dữ liệu duy nhất.');
            else alert('Vui lòng chọn 1 dòng dữ liệu!');
            return;
          }
          _generateDocument(selectedRows[0], {
            docType: 'phat_sinh.docx',
            altKeys: ['Sohopdong', 'sohopdong', 'SoHopDong'],
            sqlListName: 'API_DanhSachPhatSinh',
            ignoreTemplateFile: true
          });
        }
      });
    }

    return buttons;
  }

  // Đăng ký Plugin vào hệ thống
  window.FormActionPlugins = window.FormActionPlugins || [];
  window.FormActionPlugins.push({ getExtraButtons: getExtraButtons });

  return { getExtraButtons: getExtraButtons };
})();
