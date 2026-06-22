/**
 * PhatSinhPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin quản lý việc Chọn Thực đơn & Dịch vụ Phát Sinh dưới dạng lưới thẻ Card.
 * Chạy độc lập thông qua nút bấm "Nhập Phát Sinh" trên Grid Hợp đồng.
 */
var PhatSinhPlugin = (function () {
  var catalogCache = null; // Bộ nhớ đệm danh mục món ăn từ API
  var activeModal = null; // Modal form đang sửa/thêm

  // Trạng thái các món đang chọn (lưu tạm)
  var selectedFoodsMan = [];
  var selectedFoodsChay = [];
  var selectedThucUong = [];
  var selectedDichVu = [];
  var selectedPhatSinh = [];
  var contractPhatSinh = [];

  // Trạng thái các món gốc trong Hợp đồng/Phụ lục để đối chiếu (Quyết toán)
  var contractFoodsMan = [];
  var contractFoodsChay = [];
  var contractThucUong = [];
  var contractDichVu = [];
  var contractPhatSinh = [];

  // Thêm styles cho giao diện plugin
  function _injectStyles() {
    if (document.getElementById('food-selection-plugin-styles')) return;
    var style = document.createElement('style');
    style.id = 'food-selection-plugin-styles';
    style.innerHTML = `
      .food-plugin-wrapper {
        margin-top: 15px;
        border: 1px solid var(--color-border);
        border-radius: 12px;
        background: var(--color-surface);
        padding: 20px;
        box-shadow: var(--shadow-sm);
        max-width: 100%;
        box-sizing: border-box;
      }
      .food-plugin-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        border-bottom: 1px solid var(--color-border);
        padding-bottom: 12px;
      }
      .food-plugin-title {
        font-size: 16px;
        font-weight: 700;
        color: var(--color-text);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
      }
      .food-badge-type {
        background: var(--color-background);
        border: 1px solid var(--color-border);
        color: var(--color-text);
        padding: 3px 8px;
        border-radius: 6px;
        font-size: 11px;
        font-weight: 500;
      }
      /* Selector Modal Styles */
      .food-modal-tabs {
        display: flex;
        gap: 8px;
        border-bottom: 2px solid var(--color-border);
        padding-bottom: 0;
        margin-bottom: 16px;
      }
      .food-modal-tab-btn {
        background: none;
        border: none;
        padding: 10px 18px;
        font-size: 14px;
        font-weight: 600;
        color: var(--color-text-secondary);
        cursor: pointer;
        border-bottom: 3px solid transparent;
        transition: all 0.15s ease;
        display: flex;
        align-items: center;
        gap: 6px;
      }
      .food-modal-tab-btn:hover {
        color: var(--color-primary);
      }
      .food-modal-tab-btn.active {
        color: var(--color-primary);
        border-bottom-color: var(--color-primary);
      }
      .food-grid-container {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 10px;
        margin-bottom: 24px;
      }
      .food-card {
        border: 1px solid var(--color-border);
        border-radius: var(--radius-md);
        padding: 8px;
        background: var(--color-surface);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        height: 100%;
        min-height: 85px;
        box-shadow: var(--shadow-sm);
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
      }
      .food-card:hover {
        border-color: var(--color-primary);
        box-shadow: 0 4px 12px rgba(15, 23, 42, 0.08);
      }
      @media (max-width: 1400px) {
        .food-grid-container {
          grid-template-columns: repeat(4, minmax(0, 1fr));
        }
      }
      @media (max-width: 1100px) {
        .food-grid-container {
          grid-template-columns: repeat(3, minmax(0, 1fr));
        }
      }
      @media (max-width: 900px) {
        .food-grid-container {
          grid-template-columns: repeat(3, minmax(0, 1fr));
        }
      }
      @media (max-width: 768px) {
        .food-grid-container {
          grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
          gap: 6px !important;
        }
        .food-card {
          padding: 6px !important;
          min-height: 80px !important;
        }
      }
      .food-card .food-card-title {
        font-size: 12px;
        line-height: 1.2;
        margin: 4px 0;
      }
      /* Selected Drawer */
      .selected-drawer {
        position: absolute;
        bottom: 64px;
        left: 16px;
        right: 16px;
        background: var(--color-surface);
        border: 1px solid var(--color-border-strong);
        border-radius: 12px 12px 0 0;
        box-shadow: 0 -10px 30px rgba(15, 23, 42, 0.18);
        z-index: 105;
        display: flex;
        flex-direction: column;
        max-height: 320px;
        transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
        transform: translateY(0);
        opacity: 1;
      }
      .selected-drawer.collapsed {
        transform: translateY(30px);
        opacity: 0;
        pointer-events: none;
      }
      .drawer-header {
        padding: 12px 18px;
        border-bottom: 1px solid var(--color-border);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: var(--color-background);
        border-radius: 12px 12px 0 0;
      }
      .close-drawer-btn {
        cursor: pointer;
        color: var(--color-text-secondary);
        transition: color 0.15s ease;
      }
      .close-drawer-btn:hover {
        color: var(--color-primary);
      }
      .drawer-body {
        flex: 1;
        overflow-y: auto;
        padding: 16px;
      }
      .modal-bottom-bar {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 64px;
        background: var(--color-surface);
        border-top: 1px solid var(--color-border-strong);
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 20px;
        z-index: 100;
        box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.05);
      }
      @media (max-width: 600px) {
        .modal-main-container {
          height: 100% !important;
          padding-bottom: 110px !important;
        }
        .modal-bottom-bar {
          height: 110px !important;
          flex-direction: column !important;
          justify-content: space-around !important;
          padding: 10px 10px !important;
          align-items: stretch !important;
        }
        .selected-drawer {
          bottom: 110px !important;
        }
      }
    `;
    document.head.appendChild(style);
  }

  // Khởi chạy API tải danh mục
  function _loadCatalog() {
    if (catalogCache) return Promise.resolve(catalogCache);

    if (typeof ContractService !== 'undefined' && typeof ContractService.getFoods === 'function') {
      return ContractService.getFoods({ Keyword: '', PhanLoai: '', IsChay: -1 })
        .then(function (items) {
          catalogCache = items;
          return catalogCache;
        })
        .catch(function (err) {
          console.error('[PhatSinhPlugin] Lỗi tải catalog từ ContractService:', err);
          return [];
        });
    }

    return Promise.resolve([]);
  }

  // Ánh xạ danh sách thô từ DB sang thông tin đầy đủ từ danh mục
  function _mapRawItems(rawList, defaultIsChay) {
    if (!Array.isArray(rawList)) return [];
    return rawList.map(function (rawItem) {
      var maMon = rawItem.Mahang || rawItem.MaMon || '';
      var catalogItem = catalogCache ? catalogCache.find(function (c) { return (c.Mahang || c.MaMon) === maMon; }) : null;

      var isChayVal = defaultIsChay;
      if (catalogItem && catalogItem.IsChay !== undefined) isChayVal = catalogItem.IsChay;
      else if (rawItem.IsChay !== undefined) isChayVal = rawItem.IsChay;
      else if (rawItem.TenHang && rawItem.TenHang.toLowerCase().includes('chay')) isChayVal = 1;

      // Chuẩn hóa thành 0 hoặc 1 (để tránh lệch kiểu dữ liệu string "0"/"1" từ API)
      isChayVal = (isChayVal == 1 || isChayVal === true) ? 1 : 0;

      var nameVal = rawItem.TenHang || rawItem.TenMon || '';
      if (nameVal === 'PHATSINH' || nameVal.startsWith('PS_')) {
        nameVal = '';
      }
      var finalName = nameVal || rawItem.GhiChuPhatSinh || rawItem.GhiChu || (catalogItem ? (catalogItem.Tenhang || catalogItem.TenMon) : '');

      return {
        MaMon: maMon,
        Mahang: maMon,
        TenMon: finalName,
        TenHang: finalName,
        PhanLoai: rawItem.PhanLoai || (catalogItem ? catalogItem.PhanLoai : 'Khác'),
        DvtID: rawItem.DvtID || (catalogItem ? catalogItem.DvtID : 'Đĩa'),
        DonGia: parseFloat(rawItem.Dongia || rawItem.DonGia || (catalogItem ? catalogItem.Dongia : 0) || 0),
        Dongia: parseFloat(rawItem.Dongia || rawItem.DonGia || (catalogItem ? catalogItem.Dongia : 0) || 0),
        SoLuong: parseFloat(rawItem.Soluong || rawItem.SoLuong || 1),
        Soluong: parseFloat(rawItem.Soluong || rawItem.SoLuong || 1),
        IsChay: isChayVal,
        IsKhuyenmai: rawItem.IsKhuyenmai ? 1 : 0
      };
    });
  }

  // Đọc dữ liệu từ các input ẩn của Form
  function _readInputs(modal) {
    var inpBanTiec = modal.querySelector('[name="JsonBanTiec"]');
    var inpThucUong = modal.querySelector('[name="JsonThucUong"]');
    var inpDichVu = modal.querySelector('[name="JsonDichVu"]');
    var inpPhatSinh = modal.querySelector('[name="JsonPhatSinh"]');

    var rawBanTiec = [];
    var rawThucUong = [];
    var rawDichVu = [];
    var rawPhatSinh = [];

    try { if (inpBanTiec && inpBanTiec.value) rawBanTiec = JSON.parse(inpBanTiec.value); } catch (e) { }
    try { if (inpThucUong && inpThucUong.value) rawThucUong = JSON.parse(inpThucUong.value); } catch (e) { }
    try { if (inpDichVu && inpDichVu.value) rawDichVu = JSON.parse(inpDichVu.value); } catch (e) { }
    try { if (inpPhatSinh && inpPhatSinh.value) rawPhatSinh = JSON.parse(inpPhatSinh.value); } catch (e) { }

    var mappedBanTiec = _mapRawItems(rawBanTiec, 0);

    // Tách món mặn & món chay
    selectedFoodsMan = mappedBanTiec.filter(function (x) { return x.IsChay === 0 || x.IsChay === false; });
    selectedFoodsChay = mappedBanTiec.filter(function (x) { return x.IsChay === 1 || x.IsChay === true; });

    selectedThucUong = _mapRawItems(rawThucUong, 0);
    selectedDichVu = _mapRawItems(rawDichVu, 0);
    selectedPhatSinh = _mapRawItems(rawPhatSinh, 0);

    // Đọc dữ liệu hợp đồng đối chiếu (dành cho Quyết toán)
    var inpBanTiecHD = modal.querySelector('[name="JsonBanTiecHopDong"]');
    var inpThucUongHD = modal.querySelector('[name="JsonThucUongHopDong"]');
    var inpDichVuHD = modal.querySelector('[name="JsonDichVuHopDong"]');
    var inpPhatSinhHD = modal.querySelector('[name="JsonPhatSinhHopDong"]');

    var rawBanTiecHD = [];
    var rawThucUongHD = [];
    var rawDichVuHD = [];
    var rawPhatSinhHD = [];

    try { if (inpBanTiecHD && inpBanTiecHD.value) rawBanTiecHD = JSON.parse(inpBanTiecHD.value); } catch (e) { }
    try { if (inpThucUongHD && inpThucUongHD.value) rawThucUongHD = JSON.parse(inpThucUongHD.value); } catch (e) { }
    try { if (inpDichVuHD && inpDichVuHD.value) rawDichVuHD = JSON.parse(inpDichVuHD.value); } catch (e) { }
    try { if (inpPhatSinhHD && inpPhatSinhHD.value) rawPhatSinhHD = JSON.parse(inpPhatSinhHD.value); } catch (e) { }

    var mappedBanTiecHD = _mapRawItems(rawBanTiecHD, 0);
    contractFoodsMan = mappedBanTiecHD.filter(function (x) { return x.IsChay === 0 || x.IsChay === false; });
    contractFoodsChay = mappedBanTiecHD.filter(function (x) { return x.IsChay === 1 || x.IsChay === true; });
    contractThucUong = _mapRawItems(rawThucUongHD, 0);
    contractDichVu = _mapRawItems(rawDichVuHD, 0);
    contractPhatSinh = _mapRawItems(rawPhatSinhHD, 0);
  }

  // Ghi dữ liệu ngược lại các input ẩn và phát sự kiện change
  function _writeInputs(modal) {
    var inpBanTiec = modal.querySelector('[name="JsonBanTiec"]');
    var inpThucUong = modal.querySelector('[name="JsonThucUong"]');
    var inpDichVu = modal.querySelector('[name="JsonDichVu"]');
    var inpPhatSinh = modal.querySelector('[name="JsonPhatSinh"]');

    // Nối món mặn & món chay
    var listBanTiec = selectedFoodsMan.concat(selectedFoodsChay).map(function (x) {
      return {
        Mahang: x.MaMon,
        TenHang: x.TenMon,
        DvtID: x.DvtID || 'Đĩa',
        Soluong: x.SoLuong || 1,
        Dongia: x.DonGia,
        Giamgia: 0,
        Sotiengiamgia: 0
      };
    });

    var listThucUong = selectedThucUong.map(function (x) {
      return {
        Mahang: x.MaMon,
        IsKhuyenmai: x.IsKhuyenmai ? 1 : 0,
        Soluong: x.SoLuong || 1,
        Dongia: x.DonGia,
        Giamgia: 0,
        Sotiengiamgia: 0,
        Soluongle: 0,
        Dongiale: 0,
        Ghichuthucuong: ''
      };
    });

    var listPhatSinh = selectedPhatSinh.map(function (x) {
      return {
        Mahang: x.MaMon,
        TenHang: x.TenMon || '',
        DvtID: x.DvtID || '',
        Soluong: x.SoLuong || 1,
        Dongia: x.DonGia,
        GhiChuPhatSinh: x.TenMon || ''
      };
    });

    var listDichVu = selectedDichVu.map(function (x) {
      return {
        Mahang: x.MaMon,
        TenHang: x.TenMon || '',
        DvtID: x.DvtID || '',
        Soluong: x.SoLuong || 1,
        Dongia: x.DonGia,
        Giamgia: 0,
        Sotiengiamgia: 0
      };
    });

    if (inpBanTiec) {
      inpBanTiec.value = JSON.stringify(listBanTiec);
      inpBanTiec.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (inpThucUong) {
      inpThucUong.value = JSON.stringify(listThucUong);
      inpThucUong.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (inpDichVu) {
      inpDichVu.value = JSON.stringify(listDichVu);
      inpDichVu.dispatchEvent(new Event('change', { bubbles: true }));
    }
    
    if (!inpPhatSinh) {
      inpPhatSinh = document.createElement('input');
      inpPhatSinh.type = 'hidden';
      inpPhatSinh.name = 'JsonPhatSinh';
      var theForm = modal.closest('form') || document.querySelector('form');
      if (theForm) {
          theForm.appendChild(inpPhatSinh);
      } else {
          modal.appendChild(inpPhatSinh);
      }
    }
    inpPhatSinh.value = JSON.stringify(listPhatSinh);
    inpPhatSinh.dispatchEvent(new Event('change', { bubbles: true }));

    _renderSummaryTables();
  }

  // Lấy danh sách đối chiếu so sánh giữa thực tế và hợp đồng
  function _getComparisonList(selectedList, contractList) {
    var result = [];
    var processedMaMons = {};

    selectedList.forEach(function (selItem) {
      var maMon = selItem.MaMon || selItem.Mahang || '';
      processedMaMons[maMon] = true;

      var conItem = contractList.find(function (c) {
        return (c.MaMon || c.Mahang) === maMon;
      });

      var contractQty = conItem ? (conItem.SoLuong || conItem.Soluong || 0) : 0;
      var contractPrice = conItem ? (conItem.DonGia || conItem.Dongia || 0) : 0;
      var actualQty = selItem.SoLuong || selItem.Soluong || 0;
      var actualPrice = selItem.DonGia || selItem.Dongia || 0;

      var status = 'normal';
      if (!conItem) {
        status = 'added';
      } else if (contractQty !== actualQty || contractPrice !== actualPrice) {
        status = 'modified';
      }

      result.push({
        MaMon: maMon,
        TenMon: selItem.TenMon || selItem.TenHang || '',
        PhanLoai: selItem.PhanLoai || 'Khác',
        DvtID: selItem.DvtID || 'Đĩa',
        contractQty: contractQty,
        contractPrice: contractPrice,
        actualQty: actualQty,
        actualPrice: actualPrice,
        contractSubtotal: contractQty * contractPrice,
        actualSubtotal: actualQty * actualPrice,
        diffQty: actualQty - contractQty,
        diffSubtotal: (actualQty * actualPrice) - (contractQty * contractPrice),
        status: status,
        rawItem: selItem
      });
    });

    contractList.forEach(function (conItem) {
      var maMon = conItem.MaMon || conItem.Mahang || '';
      if (processedMaMons[maMon]) return;

      var contractQty = conItem.SoLuong || conItem.Soluong || 0;
      var contractPrice = conItem.DonGia || conItem.Dongia || 0;

      result.push({
        MaMon: maMon,
        TenMon: conItem.TenMon || conItem.TenHang || '',
        PhanLoai: conItem.PhanLoai || 'Khác',
        DvtID: conItem.DvtID || 'Đĩa',
        contractQty: contractQty,
        contractPrice: contractPrice,
        actualQty: 0,
        actualPrice: conItem.DonGia || conItem.Dongia || 0,
        contractSubtotal: contractQty * contractPrice,
        actualSubtotal: 0,
        diffQty: -contractQty,
        diffSubtotal: -(contractQty * contractPrice),
        status: 'deleted',
        rawItem: conItem
      });
    });

    return result;
  }

  // Lấy chi tiết tính tổng của một tab
  function _getTabSums(type) {
    var selectedList = [];
    var contractList = [];

    if (type === 'man') {
      selectedList = selectedFoodsMan;
      contractList = contractFoodsMan;
    } else if (type === 'chay') {
      selectedList = selectedFoodsChay;
      contractList = contractFoodsChay;
    } else if (type === 'drink') {
      selectedList = selectedThucUong;
      contractList = contractThucUong;
    } else if (type === 'service') {
      selectedList = selectedDichVu;
      contractList = contractDichVu;
    }

    var isFood = (type === 'man' || type === 'chay');

    var contractSum = contractList.reduce(function (sum, item) {
      var qty = isFood ? 1 : (item.SoLuong || item.Soluong || 0);
      var price = item.DonGia || item.Dongia || 0;
      return sum + (qty * price);
    }, 0);

    var actualSum = selectedList.reduce(function (sum, item) {
      var qty = isFood ? 1 : (item.SoLuong || item.Soluong || 0);
      var price = item.DonGia || item.Dongia || 0;
      return sum + (qty * price);
    }, 0);

    return {
      contract: contractSum,
      actual: actualSum,
      diff: actualSum - contractSum
    };
  }

  // Vẽ các bảng hiển thị tóm tắt trong Form cha
  function _renderSummaryTables() {
    var container = activeModal.querySelector('.food-selection-tables-wrapper');
    if (!container) return;

    var activeTab = container.dataset.activeTab || 'man';
    var formBody = activeModal ? (activeModal.querySelector('[data-form-name]') || activeModal) : null;
    var isQuyetToan = formBody && formBody.getAttribute('data-form-name') === 'frmQuyetToan';

    var renderTabButton = function (tabId, label, count) {
      var cls = activeTab === tabId ? 'active' : '';
      if (isQuyetToan) {
        var sums = _getTabSums(tabId);
        var diffText = '';
        if (sums.diff > 0) {
          diffText = ` <span style="font-size:11px; color:#ef4444; font-weight:700;">(+${sums.diff.toLocaleString('vi-VN')}đ)</span>`;
        } else if (sums.diff < 0) {
          diffText = ` <span style="font-size:11px; color:#10b981; font-weight:700;">(-${Math.abs(sums.diff).toLocaleString('vi-VN')}đ)</span>`;
        }

        var selectedList = (tabId === 'man') ? selectedFoodsMan : (tabId === 'chay') ? selectedFoodsChay : (tabId === 'drink') ? selectedThucUong : selectedDichVu;
        var contractList = (tabId === 'man') ? contractFoodsMan : (tabId === 'chay') ? contractFoodsChay : (tabId === 'drink') ? contractThucUong : contractDichVu;
        var hasChanges = (sums.diff !== 0) || (selectedList.length !== contractList.length) ||
          selectedList.some(function (sel) {
            var con = contractList.find(function (c) { return (c.MaMon || c.Mahang) === (sel.MaMon || sel.Mahang); });
            return !con || (sel.SoLuong || sel.Soluong) !== (con.SoLuong || con.Soluong) || (sel.DonGia || sel.Dongia) !== (con.DonGia || con.Dongia);
          });

        var changeIndicator = hasChanges ? `<span class="material-symbols-outlined" style="font-size:14px; color:#f59e0b; vertical-align:middle; margin-left:3px;" title="Có thay đổi so với hợp đồng">warning</span>` : '';
        return `<button type="button" class="food-modal-tab-btn ${cls}" onclick="PhatSinhPlugin.switchSummaryTab('${tabId}')">${label} (${count})${diffText}${changeIndicator}</button>`;
      } else {
        return `<button type="button" class="food-modal-tab-btn ${cls}" onclick="PhatSinhPlugin.switchSummaryTab('${tabId}')">${label} (${count})</button>`;
      }
    };

    var contentHtml = '';
    var totalText = '0 đ';

    if (isQuyetToan) {
      // RENDERING COMPARISON TABLE
      if (activeTab === 'man' || activeTab === 'chay') {
        var compList = _getComparisonList(
          activeTab === 'man' ? selectedFoodsMan : selectedFoodsChay,
          activeTab === 'man' ? contractFoodsMan : contractFoodsChay
        );

        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 50px;">STT</th>
              <th style="width: 100px;">Phân Loại</th>
              <th>Tên Món Ăn</th>
              <th class="text-center" style="width: 60px;">HĐ</th>
              <th class="text-center" style="width: 80px;">Thực Tế</th>
              <th class="text-center" style="width: 100px;">Trạng Thái</th>
              <th class="text-end" style="width: 120px;">Đơn Giá</th>
              <th class="text-center" style="width: 100px;">Thao Tác</th>
            </tr>
          </thead>
          <tbody>`;

        if (compList.length === 0) {
          contentHtml += `<tr><td colspan="8" class="text-center text-muted py-3">Không có món nào.</td></tr>`;
        } else {
          compList.forEach(function (item, idx) {
            var rowStyle = '';
            var statusBadge = '';
            var actionButton = '';
            var nameStyle = 'fw-medium';

            var hdCheck = item.contractQty > 0 ? '<span class="material-symbols-outlined text-primary" style="font-size: 18px;">check</span>' : '';
            var ttCheck = item.actualQty > 0 ? '<span class="material-symbols-outlined text-success" style="font-size: 18px;">check</span>' : '';

            if (item.status === 'added') {
              statusBadge = '<span class="badge" style="background-color:#dcfce7; color:#15803d; padding:4px 8px; border-radius:4px;">Thêm mới</span>';
              actionButton = `<span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('${activeTab}', '${item.MaMon}')">delete</span>`;
              rowStyle = 'style="background-color: rgba(220, 252, 231, 0.25);"';
            } else if (item.status === 'deleted') {
              statusBadge = '<span class="badge" style="background-color:#fee2e2; color:#b91c1c; padding:4px 8px; border-radius:4px;">Đã bỏ</span>';
              actionButton = `<button type="button" class="btn btn-sm btn-outline-primary py-0 px-2 d-inline-flex align-items-center gap-1" style="font-size: 11px; font-weight:600;" onclick="PhatSinhPlugin.addBack('${activeTab}', '${item.MaMon}')"><span class="material-symbols-outlined" style="font-size:14px;">add</span> Thêm lại</button>`;
              nameStyle = 'text-decoration: line-through; color: #94a3b8; font-style: italic;';
              rowStyle = 'style="background-color: rgba(254, 226, 226, 0.25);"';
            } else {
              statusBadge = '<span class="badge" style="background-color:#f1f5f9; color:#475569; padding:4px 8px; border-radius:4px;">Hợp đồng</span>';
              actionButton = `<span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('${activeTab}', '${item.MaMon}')">delete</span>`;
            }

            contentHtml += `<tr ${rowStyle}>
              <td class="text-center">${idx + 1}</td>
              <td><span class="food-badge-type">${item.PhanLoai}</span></td>
              <td style="${nameStyle}">${item.TenMon}</td>
              <td class="text-center">${hdCheck}</td>
              <td class="text-center">${ttCheck}</td>
              <td class="text-center">${statusBadge}</td>
              <td class="text-end text-danger fw-semibold">${item.actualPrice.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">${actionButton}</td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;
      } else if (activeTab === 'drink' || activeTab === 'service') {
        var compList = _getComparisonList(
          activeTab === 'drink' ? selectedThucUong : selectedDichVu,
          activeTab === 'drink' ? contractThucUong : contractDichVu
        );

        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 45px;">STT</th>
              <th>Tên Mặt Hàng</th>
              <th class="text-end" style="width: 100px;">Đơn Giá</th>
              <th class="text-center" style="width: 70px;">Lượng HĐ</th>
              <th class="text-center" style="width: 125px;">Lượng TT</th>
              <th class="text-center" style="width: 80px;">Lệch</th>
              <th class="text-center" style="width: 90px;">Trạng Thái</th>
              <th class="text-end" style="width: 110px;">Thành Tiền TT</th>
              <th class="text-end" style="width: 110px;">Chênh Lệch</th>
              <th class="text-center" style="width: 90px;">Thao Tác</th>
            </tr>
          </thead>
          <tbody>`;

        if (compList.length === 0) {
          contentHtml += `<tr><td colspan="10" class="text-center text-muted py-3">Không có mặt hàng nào.</td></tr>`;
        } else {
          compList.forEach(function (item, idx) {
            var rowStyle = '';
            var statusBadge = '';
            var actionButton = '';
            var nameStyle = 'fw-medium';
            var qtyControls = '';

            var diffQtyText = item.diffQty > 0 ? `+${item.diffQty}` : item.diffQty;
            var diffQtyClass = item.diffQty > 0 ? 'text-danger fw-bold' : (item.diffQty < 0 ? 'text-success fw-bold' : 'text-muted');

            var diffSubText = item.diffSubtotal > 0 ? `+${item.diffSubtotal.toLocaleString('vi-VN')} đ` : (item.diffSubtotal < 0 ? `-${Math.abs(item.diffSubtotal).toLocaleString('vi-VN')} đ` : '0 đ');
            var diffSubClass = item.diffSubtotal > 0 ? 'text-danger fw-bold' : (item.diffSubtotal < 0 ? 'text-success fw-bold' : 'text-muted');

            if (item.status === 'added') {
              statusBadge = '<span class="badge" style="background-color:#dcfce7; color:#15803d; padding:4px 8px; border-radius:4px;">Thêm mới</span>';
              actionButton = `<span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('${activeTab}', '${item.MaMon}')">delete</span>`;
              rowStyle = 'style="background-color: rgba(220, 252, 231, 0.25);"';
              qtyControls = `
                <div class="d-inline-flex align-items-center gap-2">
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', -1)">-</button>
                  <span style="min-width: 20px; display:inline-block;" class="fw-bold text-success">${item.actualQty}</span>
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', 1)">+</button>
                </div>`;
            } else if (item.status === 'deleted') {
              statusBadge = '<span class="badge" style="background-color:#fee2e2; color:#b91c1c; padding:4px 8px; border-radius:4px;">Đã bỏ</span>';
              actionButton = `<button type="button" class="btn btn-sm btn-outline-primary py-0 px-2 d-inline-flex align-items-center gap-1" style="font-size: 11px; font-weight:600;" onclick="PhatSinhPlugin.addBack('${activeTab}', '${item.MaMon}')"><span class="material-symbols-outlined" style="font-size:14px;">add</span> Thêm lại</button>`;
              nameStyle = 'text-decoration: line-through; color: #94a3b8; font-style: italic;';
              rowStyle = 'style="background-color: rgba(254, 226, 226, 0.25);"';
              qtyControls = `<span class="text-muted fw-bold">0</span>`;
            } else if (item.status === 'modified') {
              statusBadge = '<span class="badge" style="background-color:#fef3c7; color:#b45309; padding:4px 8px; border-radius:4px;">Sửa lượng</span>';
              actionButton = `<span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('${activeTab}', '${item.MaMon}')">delete</span>`;
              rowStyle = 'style="background-color: rgba(254, 243, 199, 0.25);"';
              qtyControls = `
                <div class="d-inline-flex align-items-center gap-2">
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', -1)">-</button>
                  <span style="min-width: 20px; display:inline-block;" class="fw-bold text-warning">${item.actualQty}</span>
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', 1)">+</button>
                </div>`;
            } else {
              statusBadge = '<span class="badge" style="background-color:#f1f5f9; color:#475569; padding:4px 8px; border-radius:4px;">Hợp đồng</span>';
              actionButton = `<span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('${activeTab}', '${item.MaMon}')">delete</span>`;
              qtyControls = `
                <div class="d-inline-flex align-items-center gap-2">
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', -1)">-</button>
                  <span style="min-width: 20px; display:inline-block;" class="fw-bold text-dark">${item.actualQty}</span>
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('${activeTab}', '${item.MaMon}', 1)">+</button>
                </div>`;
            }

            contentHtml += `<tr ${rowStyle}>
              <td class="text-center">${idx + 1}</td>
              <td style="${nameStyle}">${item.TenMon}</td>
              <td class="text-end">${item.actualPrice.toLocaleString('vi-VN')} đ</td>
              <td class="text-center fw-semibold text-secondary">${item.contractQty}</td>
              <td class="text-center">${qtyControls}</td>
              <td class="text-center ${diffQtyClass}">${diffQtyText}</td>
              <td class="text-center">${statusBadge}</td>
              <td class="text-end text-dark fw-bold">${item.actualSubtotal.toLocaleString('vi-VN')} đ</td>
              <td class="text-end ${diffSubClass}">${diffSubText}</td>
              <td class="text-center">${actionButton}</td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;
      }
    } else {
      // RENDERING STANDARD TAB VIEWS
      if (activeTab === 'man') {
        var total = selectedFoodsMan.reduce(function (sum, item) { return sum + item.DonGia; }, 0);
        totalText = total.toLocaleString('vi-VN') + ' đ';
        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 60px;">STT</th>
              <th>Phân Loại</th>
              <th>Tên Món Ăn</th>
              <th class="text-end" style="width: 140px;">Đơn Giá</th>
              <th class="text-center" style="width: 60px;">Xóa</th>
            </tr>
          </thead>
          <tbody>`;
        if (selectedFoodsMan.length === 0) {
          contentHtml += '<tr><td colspan="5" class="text-center text-muted py-3">Chưa chọn món mặn nào.</td></tr>';
        } else {
          selectedFoodsMan.forEach(function (item, idx) {
            contentHtml += `<tr>
              <td class="text-center">${idx + 1}</td>
              <td><span class="food-badge-type">${item.PhanLoai}</span></td>
              <td class="fw-medium">${item.TenMon}</td>
              <td class="text-end text-danger fw-semibold">${item.DonGia.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('man', ${idx})">delete</span>
              </td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;

      } else if (activeTab === 'chay') {
        var total = selectedFoodsChay.reduce(function (sum, item) { return sum + item.DonGia; }, 0);
        totalText = total.toLocaleString('vi-VN') + ' đ';
        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 60px;">STT</th>
              <th>Phân Loại</th>
              <th>Tên Món Chay</th>
              <th class="text-end" style="width: 140px;">Đơn Giá</th>
              <th class="text-center" style="width: 60px;">Xóa</th>
            </tr>
          </thead>
          <tbody>`;
        if (selectedFoodsChay.length === 0) {
          contentHtml += '<tr><td colspan="5" class="text-center text-muted py-3">Chưa chọn món chay nào.</td></tr>';
        } else {
          selectedFoodsChay.forEach(function (item, idx) {
            contentHtml += `<tr>
              <td class="text-center">${idx + 1}</td>
              <td><span class="food-badge-type">${item.PhanLoai}</span></td>
              <td class="fw-medium">${item.TenMon}</td>
              <td class="text-end text-success fw-semibold">${item.DonGia.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('chay', ${idx})">delete</span>
              </td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;

      } else if (activeTab === 'drink') {
        var total = selectedThucUong.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0);
        totalText = total.toLocaleString('vi-VN') + ' đ';
        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 60px;">STT</th>
              <th>Tên Đồ Uống / Dịch Vụ Phục Vụ</th>
              <th class="text-end" style="width: 130px;">Đơn Giá</th>
              <th class="text-center" style="width: 120px;">Số Lượng</th>
              <th class="text-end" style="width: 140px;">Thành Tiền</th>
              <th class="text-center" style="width: 60px;">Xóa</th>
            </tr>
          </thead>
          <tbody>`;
        if (selectedThucUong.length === 0) {
          contentHtml += '<tr><td colspan="6" class="text-center text-muted py-3">Chưa chọn thức uống nào.</td></tr>';
        } else {
          selectedThucUong.forEach(function (item, idx) {
            var sub = item.DonGia * item.SoLuong;
            contentHtml += `<tr>
              <td class="text-center">${idx + 1}</td>
              <td class="fw-medium">${item.TenMon}</td>
              <td class="text-end">${item.DonGia.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <div class="d-inline-flex align-items-center gap-2">
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('drink', ${idx}, -1)">-</button>
                  <span style="min-width: 24px; display:inline-block;" class="fw-bold">${item.SoLuong}</span>
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('drink', ${idx}, 1)">+</button>
                </div>
              </td>
              <td class="text-end text-danger fw-semibold">${sub.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('drink', ${idx})">delete</span>
              </td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;

      } else if (activeTab === 'service') {
        var total = selectedDichVu.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0);
        totalText = total.toLocaleString('vi-VN') + ' đ';
        contentHtml = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
          <thead>
            <tr>
              <th class="text-center" style="width: 60px;">STT</th>
              <th>Tên Dịch Vụ & Nghi Lễ Đi Kèm</th>
              <th class="text-end" style="width: 130px;">Đơn Giá</th>
              <th class="text-center" style="width: 120px;">Số Lượng</th>
              <th class="text-end" style="width: 140px;">Thành Tiền</th>
              <th class="text-center" style="width: 60px;">Xóa</th>
            </tr>
          </thead>
          <tbody>`;
        if (selectedDichVu.length === 0) {
          contentHtml += '<tr><td colspan="6" class="text-center text-muted py-3">Chưa chọn dịch vụ nào.</td></tr>';
        } else {
          selectedDichVu.forEach(function (item, idx) {
            var sub = item.DonGia * item.SoLuong;
            contentHtml += `<tr>
              <td class="text-center">${idx + 1}</td>
              <td class="fw-medium">${item.TenMon}</td>
              <td class="text-end">${item.DonGia.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <div class="d-inline-flex align-items-center gap-2">
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('service', ${idx}, -1)">-</button>
                  <span style="min-width: 24px; display:inline-block;" class="fw-bold">${item.SoLuong}</span>
                  <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="PhatSinhPlugin.changeQty('service', ${idx}, 1)">+</button>
                </div>
              </td>
              <td class="text-end text-danger fw-semibold">${sub.toLocaleString('vi-VN')} đ</td>
              <td class="text-center">
                <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="PhatSinhPlugin.removeItem('service', ${idx})">delete</span>
              </td>
            </tr>`;
          });
        }
        contentHtml += `</tbody></table>`;
      }
    }

    var grandContract =
      contractFoodsMan.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0); }, 0) +
      contractFoodsChay.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0); }, 0) +
      contractThucUong.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0) * (item.SoLuong || item.Soluong || 0); }, 0) +
      contractDichVu.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0) * (item.SoLuong || item.Soluong || 0); }, 0);

    var grandTotal =
      selectedFoodsMan.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0); }, 0) +
      selectedFoodsChay.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0); }, 0) +
      selectedThucUong.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0) * (item.SoLuong || item.Soluong || 0); }, 0) +
      selectedDichVu.reduce(function (sum, item) { return sum + (item.DonGia || item.Dongia || 0) * (item.SoLuong || item.Soluong || 0); }, 0);

    var grandDiff = grandTotal - grandContract;

    var headerTabs = container.querySelector('.food-modal-tabs');
    if (headerTabs) {
      headerTabs.innerHTML =
        renderTabButton('man', 'Món mặn', selectedFoodsMan.length) +
        renderTabButton('chay', 'Món chay', selectedFoodsChay.length) +
        renderTabButton('drink', 'Thức uống', selectedThucUong.length) +
        renderTabButton('service', 'Dịch vụ', selectedDichVu.length);
    }

    var gridBody = container.querySelector('.food-summary-grid-body');
    if (gridBody) gridBody.innerHTML = contentHtml;

    // Cập nhật Footer Container động
    var footerContainer = container.querySelector('.food-footer-container');
    if (footerContainer) {
      if (isQuyetToan) {
        var sums = _getTabSums(activeTab);
        var diffColor = sums.diff > 0 ? '#ef4444' : (sums.diff < 0 ? '#10b981' : 'var(--color-text)');
        var diffSign = sums.diff > 0 ? '+' : '';

        var tabDetailHtml = `Tab này: HĐ gốc: <strong class="text-dark">${sums.contract.toLocaleString('vi-VN')} đ</strong> | Thực tế: <strong class="text-primary">${sums.actual.toLocaleString('vi-VN')} đ</strong> | Chênh lệch: <strong style="color:${diffColor};">${diffSign}${sums.diff.toLocaleString('vi-VN')} đ</strong>`;

        var grandDiffColor = grandDiff > 0 ? '#ef4444' : (grandDiff < 0 ? '#10b981' : 'var(--color-text)');
        var grandDiffSign = grandDiff > 0 ? '+' : '';
        var grandDetailHtml = `Tổng Quyết Toán: HĐ gốc: <strong class="text-dark">${grandContract.toLocaleString('vi-VN')} đ</strong> | Thực tế: <strong class="text-primary">${grandTotal.toLocaleString('vi-VN')} đ</strong> | Bù/Bớt: <strong style="color:${grandDiffColor}; font-size:16px;">${grandDiffSign}${grandDiff.toLocaleString('vi-VN')} đ</strong>`;

        footerContainer.innerHTML = `
          <div style="font-size:13px; color:var(--color-text-secondary); display:flex; flex-direction:column; gap:4px;">
            ${tabDetailHtml}
          </div>
          <div style="font-size:14px; font-weight:700; text-align:right; display:flex; flex-direction:column; gap:4px;">
            ${grandDetailHtml}
          </div>
        `;
      } else {
        footerContainer.innerHTML = `
          <div style="font-size:13px; color:var(--color-text-secondary);">
            Tổng cộng Tab: <strong class="food-tab-total text-danger" style="font-size:14px;">${totalText}</strong>
          </div>
          <div style="font-size:14px; font-weight:700;">
            Tổng cộng Hợp đồng: <strong class="food-sum-total text-danger" style="font-size:16px;">${grandTotal.toLocaleString('vi-VN')} đ</strong>
          </div>
        `;
      }
    }
  }

  // Chuyển tab tóm tắt ngoài form cha
  function switchSummaryTab(tabId) {
    var container = activeModal.querySelector('.food-selection-tables-wrapper');
    if (container) {
      container.dataset.activeTab = tabId;
      _renderSummaryTables();
    }
  }

  // Thay đổi số lượng ngoài form cha
  function changeQty(type, key, delta) {
    var list = [];
    if (type === 'drink') list = selectedThucUong;
    else if (type === 'service') list = selectedDichVu;
    else if (type === 'phatsinh') list = selectedPhatSinh;

    var item = null;
    if (typeof key === 'number') {
      item = list[key];
    } else {
      item = list.find(function (x) { return (x.MaMon || x.Mahang) === key; });
    }

    if (item) {
      item.SoLuong = Math.max(1, item.SoLuong + delta);
      item.Soluong = item.SoLuong;
    }
    _writeInputs(activeModal);
  }

  // Xóa món ngoài form cha
  function removeItem(type, key) {
    var list = [];
    if (type === 'man') list = selectedFoodsMan;
    else if (type === 'chay') list = selectedFoodsChay;
    else if (type === 'drink') list = selectedThucUong;
    else if (type === 'service') list = selectedDichVu;

    if (typeof key === 'number') {
      list.splice(key, 1);
    } else {
      var idx = list.findIndex(function (x) { return (x.MaMon || x.Mahang) === key; });
      if (idx > -1) list.splice(idx, 1);
    }

    _writeInputs(activeModal);
    if (window.Toast) Toast.success('Đã xóa món khỏi thực đơn!');
  }

  // Thêm lại món từ hợp đồng
  function addBack(type, maMon) {
    var contractList = [];
    var selectedList = [];

    if (type === 'man') {
      contractList = contractFoodsMan;
      selectedList = selectedFoodsMan;
    } else if (type === 'chay') {
      contractList = contractFoodsChay;
      selectedList = selectedFoodsChay;
    } else if (type === 'drink') {
      contractList = contractThucUong;
      selectedList = selectedThucUong;
    } else if (type === 'service') {
      contractList = contractDichVu;
      selectedList = selectedDichVu;
    }

    var conItem = contractList.find(function (c) {
      return (c.MaMon || c.Mahang) === maMon;
    });

    if (conItem) {
      var newItem = JSON.parse(JSON.stringify(conItem));
      newItem.SoLuong = conItem.SoLuong || conItem.Soluong || 1;
      newItem.Soluong = newItem.SoLuong;
      selectedList.push(newItem);

      _writeInputs(activeModal);
      if (window.Toast) Toast.success('Đã khôi phục món từ hợp đồng!');
    }
  }

  // Mở popup modal chọn món tập trung (Có Tabs trượt)
  function openSelectionModal() {
    _loadCatalog().then(function (catalog) {
      _showSelectorModal(catalog);
    });
  }

  // Vẽ chi tiết popup chọn món
  function _showSelectorModal(catalog, onSaveCallback) {
    _injectStyles();
    var modalTab = 'man'; // Mặc định là món mặn
    var searchKeyword = '';

    // Sao chép sâu mảng tạm để tránh thay đổi trực tiếp trước khi ấn "Hoàn tất"
    var tempFoodsMan = JSON.parse(JSON.stringify(selectedFoodsMan));
    var tempFoodsChay = JSON.parse(JSON.stringify(selectedFoodsChay));
    var tempThucUong = JSON.parse(JSON.stringify(selectedThucUong));
    var tempDichVu = JSON.parse(JSON.stringify(selectedDichVu));
    var tempPhatSinh = JSON.parse(JSON.stringify(selectedPhatSinh));

    var modalContent = document.createElement('div');
    modalContent.className = 'modal-main-container';
    modalContent.style.cssText = 'position: relative; display: flex; flex-direction: column; height: calc(85vh - 60px); min-height: 500px; margin: -16px; padding: 16px; padding-bottom: 80px;';

    modalContent.innerHTML = `
      <!-- Modal Tabs Switcher -->
      <div class="food-modal-tabs">
        <button type="button" class="food-modal-tab-btn active" data-tab="man">
          <span class="material-symbols-outlined" style="font-size:20px">restaurant</span> Món Mặn
        </button>
        <button type="button" class="food-modal-tab-btn" data-tab="chay">
          <span class="material-symbols-outlined" style="font-size:20px">eco</span> Món Chay
        </button>
        <button type="button" class="food-modal-tab-btn" data-tab="drink">
          <span class="material-symbols-outlined" style="font-size:20px">local_bar</span> Thức Uống
        </button>
        <button type="button" class="food-modal-tab-btn" data-tab="service">
          <span class="material-symbols-outlined" style="font-size:20px">content_cut</span> Dịch Vụ
        </button>
        <button type="button" class="food-modal-tab-btn" data-tab="phatsinh">
          <span class="material-symbols-outlined" style="font-size:20px">add_box</span> Phát Sinh
        </button>
      </div>

      <!-- Search Bar -->
      <div class="d-flex gap-2 mb-3">
        <input type="text" id="modal-food-search" class="ui-input" placeholder="Tìm kiếm theo tên hoặc mã hàng..." style="flex-grow: 1; border-radius: 8px; padding: 8px 12px; height: 38px;">
        <button type="button" id="btn-modal-food-search" class="btn btn-primary d-flex align-items-center gap-1" style="height:38px; border-radius:8px;">
          <span class="material-symbols-outlined" style="font-size:20px">search</span> Tìm
        </button>
      </div>

      <!-- Food Grid Wrapper -->
      <div id="modal-food-grid-wrapper" style="flex: 1; overflow-y: auto; padding: 16px; background: var(--color-background); border-radius: 12px; border: 1px solid var(--color-border);">
        <div class="text-center py-4 text-muted">Đang tải dữ liệu...</div>
      </div>

      <!-- Popover Drawer selected items -->
      <div id="modal-selected-drawer" class="selected-drawer collapsed">
        <div class="drawer-header">
          <span class="fw-bold d-flex align-items-center gap-2" style="font-size: 14px; color: var(--color-text);">
            <span class="material-symbols-outlined" style="color:var(--color-primary); font-size:20px">assignment</span>
            Danh sách đã chọn trong tab này
          </span>
          <span class="material-symbols-outlined close-drawer-btn" id="drawer-toggle-arrow">expand_less</span>
        </div>
        <div id="modal-sidebar-list" class="drawer-body">
          <div class="text-center py-4 text-muted">Chưa chọn món nào</div>
        </div>
      </div>

      <!-- Bottom Bar -->
      <div class="modal-bottom-bar">
        <div>
          <button type="button" id="btn-toggle-drawer" class="btn btn-outline-primary d-flex align-items-center gap-2" style="height: 38px; border-radius: 8px; font-weight:600;">
            <span class="material-symbols-outlined">shopping_cart</span>
            <span>Đã chọn: <strong id="modal-sidebar-count">0</strong> món</span>
          </button>
        </div>
        <div class="d-flex align-items-center gap-3">
          <div class="text-end">
            <span class="text-muted" style="font-size: 12px; display: block; line-height: 1;">Tổng cộng:</span>
            <span class="fw-bold text-danger" id="modal-sidebar-total" style="font-size: 18px;">0 đ</span>
          </div>
          <button type="button" id="btn-modal-confirm" class="btn btn-success d-flex align-items-center gap-2" style="height: 40px; border-radius: 8px; font-weight:700;">
            <span class="material-symbols-outlined">check_circle</span> Hoàn Tất & Đóng
          </button>
        </div>
      </div>
    `;

    var m = UIModal.show({
      title: 'Hộp thoại Chọn thực đơn & Dịch vụ tiệc',
      width: '950px',
      content: modalContent
    });

    // Helper: Trả về danh sách tương ứng với tab hiện tại
    function getTempListByTab(tab) {
      if (tab === 'man') return tempFoodsMan;
      if (tab === 'chay') return tempFoodsChay;
      if (tab === 'drink') return tempThucUong;
      if (tab === 'service') return tempDichVu;
      if (tab === 'phatsinh') return tempPhatSinh;
      return [];
    }

    // Phân loại các sản phẩm trong Catalog theo tab
    function filterCatalogByTab(tab, keyword) {
      var kw = (keyword || '').toLowerCase().trim();
      
      // Tab phát sinh tự do cho phép nhập text tùy biến
      if (tab === 'phatsinh') {
        return [];
      }

      return catalog.filter(function (item) {
        var name = (item.Tenhang || item.TenMon || '').toLowerCase();
        var code = (item.Mahang || item.MaMon || '').toLowerCase();
        if (kw && !name.includes(kw) && !code.includes(kw)) return false;

        var isChay = item.IsChay == 1;
        var isDrink = item.IsDrink == 1;
        var isService = item.IsDichVu == 1;

        if (tab === 'man') return !isChay && !isDrink && !isService;
        if (tab === 'chay') return isChay && !isDrink && !isService;
        if (tab === 'drink') return isDrink;
        if (tab === 'service') return isService;

        return false;
      });
    }

    // Vẽ danh sách Card món ăn lên Grid
    function renderGrid() {
      var gridWrapper = modalContent.querySelector('#modal-food-grid-wrapper');
      if (!gridWrapper) return;

      if (modalTab === 'phatsinh') {
        // Vẽ form nhập phát sinh tự do
        gridWrapper.innerHTML = `
          <div class="p-3" style="max-width: 500px; margin: 0 auto; background: var(--color-surface); border-radius: 8px; border: 1px solid var(--color-border);">
            <h6 style="margin-top:0; margin-bottom:15px; font-weight:700;">Nhập món phát sinh tự do</h6>
            <div class="mb-3">
              <label class="form-label" style="font-weight:600; font-size:13px; display:block; margin-bottom:4px;">Tên mặt hàng/Ghi chú:</label>
              <input type="text" id="inp-free-name" class="ui-input" placeholder="Ví dụ: Thêm 2 con tôm hùm, Hộp quẹt..." style="width:100%;">
            </div>
            <div class="row g-2 mb-3">
              <div class="col-6">
                <label class="form-label" style="font-weight:600; font-size:13px; display:block; margin-bottom:4px;">Số lượng:</label>
                <input type="number" id="inp-free-qty" class="ui-input" min="1" value="1" style="width:100%;">
              </div>
              <div class="col-6">
                <label class="form-label" style="font-weight:600; font-size:13px; display:block; margin-bottom:4px;">Đơn giá (VNĐ):</label>
                <input type="number" id="inp-free-price" class="ui-input" min="0" value="0" style="width:100%;">
              </div>
            </div>
            <button type="button" id="btn-free-add" class="btn btn-primary d-flex align-items-center justify-content-center gap-1 w-100" style="height:38px; font-weight:600;">
              <span class="material-symbols-outlined">add</span> Thêm vào danh sách
            </button>
          </div>
        `;

        modalContent.querySelector('#btn-free-add').onclick = function () {
          var name = modalContent.querySelector('#inp-free-name').value.trim();
          var qty = parseFloat(modalContent.querySelector('#inp-free-qty').value || 1);
          var price = parseFloat(modalContent.querySelector('#inp-free-price').value || 0);

          if (!name) {
            alert('Vui lòng nhập tên mặt hàng phát sinh!');
            return;
          }

          var code = 'PS_' + Date.now();
          var newItem = {
            MaMon: code,
            Mahang: code,
            TenMon: name,
            TenHang: name,
            PhanLoai: 'Phát Sinh',
            DvtID: 'Lần',
            DonGia: price,
            Dongia: price,
            SoLuong: qty,
            Soluong: qty,
            IsChay: 0,
            IsKhuyenmai: 0
          };

          tempPhatSinh.push(newItem);
          modalContent.querySelector('#inp-free-name').value = '';
          modalContent.querySelector('#inp-free-qty').value = 1;
          modalContent.querySelector('#inp-free-price').value = 0;

          updateTotals();
          renderDrawer();
          if (window.Toast) Toast.success('Đã thêm món phát sinh tự do!');
        };
        return;
      }

      var filtered = filterCatalogByTab(modalTab, searchKeyword);
      if (filtered.length === 0) {
        gridWrapper.innerHTML = '<div class="text-center py-5 text-muted">Không tìm thấy mặt hàng nào phù hợp.</div>';
        return;
      }

      // Nhóm theo nhóm hàng hóa
      var groups = {};
      filtered.forEach(function (item) {
        var groupName = item.PhanLoai || item.Phanloai || item.Tennhomhang || 'Khác';
        if (!groups[groupName]) groups[groupName] = [];
        groups[groupName].push(item);
      });

      var html = '';
      Object.keys(groups).forEach(function (groupName) {
        var groupItems = groups[groupName];
        html += `
          <div class="food-category-section mb-4">
            <div style="font-size: 14px; font-weight: 700; color: var(--color-text); border-bottom: 2px solid var(--color-primary); padding-bottom: 6px; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between;">
              <span class="d-flex align-items-center gap-2">
                <span class="material-symbols-outlined text-primary" style="font-size:20px">folder</span>
                <span>${groupName}</span>
              </span>
              <span class="food-badge-type" style="font-size:11px;">${groupItems.length} sản phẩm</span>
            </div>
            <div class="food-grid-container">
        `;

        groupItems.forEach(function (item) {
          var code = item.Mahang || item.MaMon;
          var name = item.Tenhang || item.TenMon;
          var price = parseFloat(item.Dongia || item.DonGia || 0);
          var unit = item.DvtID || 'Đĩa';

          var currentList = getTempListByTab(modalTab);
          var isSelected = currentList.some(function (x) { return x.MaMon === code; });

          var cardStyle = isSelected ? 'border-color: var(--color-primary); background-color: rgba(79, 70, 229, 0.04);' : '';
          var btnStyle = isSelected ? 'background: #10B981; border: none; color: white;' : 'background: var(--color-primary); border: none; color: white;';
          var iconName = isSelected ? 'check' : 'add';

          html += `
            <div class="food-card" id="card-${code}" style="${cardStyle}">
              <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                <span class="food-badge-type" style="font-family: monospace; font-size:10px; padding: 2px 4px; color: var(--color-text-secondary);">${code}</span>
                <span class="text-muted" style="font-size: 11px;">ĐVT: ${unit}</span>
              </div>
              <div class="fw-bold food-card-title" style="color: var(--color-text); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;" title="${name}">
                ${name}
              </div>
              <div style="display: flex; justify-content: space-between; align-items: center; margin-top: auto; padding-top: 6px; border-top: 1px dashed var(--color-border);">
                <span class="fw-bold text-danger" style="font-size: 12px;">${price.toLocaleString('vi-VN')} đ</span>
                <button type="button" class="btn rounded-circle p-0 d-inline-flex align-items-center justify-content-center btn-card-toggle" data-code="${code}" style="width: 24px; height: 24px; min-width: 24px; ${btnStyle}">
                  <span class="material-symbols-outlined" style="font-size: 14px;">${iconName}</span>
                </button>
              </div>
            </div>
          `;
        });

        html += `</div></div>`;
      });

      gridWrapper.innerHTML = html;

      // Đăng ký sự kiện Click cho các nút Card
      gridWrapper.querySelectorAll('.btn-card-toggle').forEach(function (btn) {
        btn.onclick = function (e) {
          e.preventDefault();
          var code = this.getAttribute('data-code');
          var catalogItem = catalog.find(function (c) { return (c.Mahang || c.MaMon) === code; });
          if (catalogItem) {
            toggleItemSelect(catalogItem);
          }
        };
      });
    }

    // Toggle chọn/bỏ chọn sản phẩm
    function toggleItemSelect(item) {
      var code = item.Mahang || item.MaMon;
      var currentList = getTempListByTab(modalTab);
      var idx = currentList.findIndex(function (x) { return x.MaMon === code; });

      var card = modalContent.querySelector('#card-' + code);
      var btn = card ? card.querySelector('.btn-card-toggle') : null;

      if (idx > -1) {
        currentList.splice(idx, 1);
        if (card) {
          card.style.borderColor = '';
          card.style.backgroundColor = '';
        }
        if (btn) {
          btn.style.background = 'var(--color-primary)';
          btn.querySelector('.material-symbols-outlined').innerText = 'add';
        }
      } else {
        var newItem = {
          MaMon: code,
          Mahang: code,
          TenMon: item.Tenhang || item.TenMon,
          TenHang: item.Tenhang || item.TenMon,
          PhanLoai: item.PhanLoai || item.Phanloai || item.Tennhomhang || 'Khác',
          DvtID: item.DvtID || 'Đĩa',
          DonGia: parseFloat(item.Dongia || item.DonGia || 0),
          Dongia: parseFloat(item.Dongia || item.DonGia || 0),
          SoLuong: 1,
          Soluong: 1,
          IsChay: modalTab === 'chay' ? 1 : 0,
          IsKhuyenmai: 0
        };
        currentList.push(newItem);
        if (card) {
          card.style.borderColor = 'var(--color-primary)';
          card.style.backgroundColor = 'rgba(79, 70, 229, 0.04)';
        }
        if (btn) {
          btn.style.background = '#10B981';
          btn.querySelector('.material-symbols-outlined').innerText = 'check';
        }
      }

      updateTotals();
      renderDrawer();
    }

    // Vẽ danh sách ngăn kéo Drawer đã chọn
    function renderDrawer() {
      var drawerBody = modalContent.querySelector('#modal-sidebar-list');
      if (!drawerBody) return;

      var currentList = getTempListByTab(modalTab);
      if (currentList.length === 0) {
        drawerBody.innerHTML = '<div class="text-center py-4 text-muted">Chưa chọn món nào trong tab này.</div>';
        return;
      }

      var html = `<table class="table table-hover align-middle m-0" style="font-size: 13px;">
        <thead>
          <tr>
            <th class="text-center" style="width: 50px;">STT</th>
            <th>Tên Mặt Hàng</th>
            <th class="text-end" style="width: 120px;">Đơn Giá</th>
            <th class="text-center" style="width: 100px;">Số Lượng</th>
            <th class="text-end" style="width: 120px;">Thành Tiền</th>
            <th class="text-center" style="width: 50px;">Xóa</th>
          </tr>
        </thead>
        <tbody>`;

      currentList.forEach(function (item, idx) {
        var sub = item.DonGia * item.SoLuong;
        var qtyControl = '';

        // Tab Thức uống, Dịch vụ và Phát sinh cho phép sửa số lượng trực tiếp
        if (modalTab === 'drink' || modalTab === 'service' || modalTab === 'phatsinh') {
          qtyControl = `
            <div class="d-inline-flex align-items-center gap-1">
              <button type="button" class="btn btn-sm btn-light px-2 py-0 btn-drawer-qty" data-idx="${idx}" data-delta="-1">-</button>
              <span class="fw-bold">${item.SoLuong}</span>
              <button type="button" class="btn btn-sm btn-light px-2 py-0 btn-drawer-qty" data-idx="${idx}" data-delta="1">+</button>
            </div>
          `;
        } else {
          qtyControl = `<span class="fw-bold">${item.SoLuong}</span>`;
        }

        html += `
          <tr>
            <td class="text-center">${idx + 1}</td>
            <td class="fw-semibold">${item.TenMon}</td>
            <td class="text-end">${item.DonGia.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">${qtyControl}</td>
            <td class="text-end fw-bold text-danger">${sub.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">
              <span class="material-symbols-outlined text-danger cursor-pointer btn-drawer-remove" data-idx="${idx}" style="font-size:18px">delete</span>
            </td>
          </tr>
        `;
      });

      html += `</tbody></table>`;
      drawerBody.innerHTML = html;

      // Event listeners cho các nút tăng giảm số lượng trong drawer
      drawerBody.querySelectorAll('.btn-drawer-qty').forEach(function (btn) {
        btn.onclick = function () {
          var idx = parseInt(this.getAttribute('data-idx'));
          var delta = parseInt(this.getAttribute('data-delta'));
          currentList[idx].SoLuong = Math.max(1, currentList[idx].SoLuong + delta);
          currentList[idx].Soluong = currentList[idx].SoLuong;
          updateTotals();
          renderDrawer();
          renderGrid();
        };
      });

      // Event listener cho nút xóa trong drawer
      drawerBody.querySelectorAll('.btn-drawer-remove').forEach(function (btn) {
        btn.onclick = function () {
          var idx = parseInt(this.getAttribute('data-idx'));
          currentList.splice(idx, 1);

          updateTotals();
          renderDrawer();
          renderGrid();
        };
      });
    }

    // Cập nhật tổng số lượng & tổng tiền ở Bottom Bar
    function updateTotals() {
      var total =
        tempFoodsMan.reduce(function (sum, item) { return sum + item.DonGia; }, 0) +
        tempFoodsChay.reduce(function (sum, item) { return sum + item.DonGia; }, 0) +
        tempThucUong.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0) +
        tempDichVu.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0) +
        tempPhatSinh.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0);

      var activeList = getTempListByTab(modalTab);

      var countEl = modalContent.querySelector('#modal-sidebar-count');
      var totalEl = modalContent.querySelector('#modal-sidebar-total');

      if (countEl) countEl.innerText = activeList.length;
      if (totalEl) totalEl.innerText = total.toLocaleString('vi-VN') + ' đ';
    }

    // Chuyển đổi tab chọn món trong popup
    modalContent.querySelectorAll('.food-modal-tab-btn').forEach(function (btn) {
      btn.onclick = function () {
        modalContent.querySelectorAll('.food-modal-tab-btn').forEach(function (b) { b.classList.remove('active'); });
        this.classList.add('active');
        modalTab = this.getAttribute('data-tab');

        // Reset bộ lọc tìm kiếm
        var searchInp = modalContent.querySelector('#modal-food-search');
        if (searchInp) searchInp.value = '';
        searchKeyword = '';

        // Đóng drawer khi đổi tab
        var drawer = modalContent.querySelector('#modal-selected-drawer');
        if (drawer) drawer.classList.add('collapsed');

        renderGrid();
        updateTotals();
        renderDrawer();
      };
    });

    // Sự kiện Tìm kiếm
    var btnSearch = modalContent.querySelector('#btn-modal-food-search');
    var txtSearch = modalContent.querySelector('#modal-food-search');

    if (btnSearch && txtSearch) {
      var doSearch = function () {
        searchKeyword = txtSearch.value;
        renderGrid();
      };
      btnSearch.onclick = doSearch;
      txtSearch.onkeydown = function (e) {
        if (e.key === 'Enter') doSearch();
      };
    }

    // Toggle Drawer slide-up
    var btnToggle = modalContent.querySelector('#btn-toggle-drawer');
    var drawer = modalContent.querySelector('#modal-selected-drawer');
    var arrow = modalContent.querySelector('#drawer-toggle-arrow');

    if (btnToggle && drawer) {
      btnToggle.onclick = function () {
        if (drawer.classList.contains('collapsed')) {
          drawer.classList.remove('collapsed');
          if (arrow) arrow.innerText = 'expand_more';
        } else {
          drawer.classList.add('collapsed');
          if (arrow) arrow.innerText = 'expand_less';
        }
      };
    }
    if (arrow && drawer) {
      arrow.onclick = function () {
        drawer.classList.add('collapsed');
        if (arrow) arrow.innerText = 'expand_less';
      };
    }

    // Xác nhận và Đóng Modal
    var btnConfirm = modalContent.querySelector('#btn-modal-confirm');
    btnConfirm.onclick = function () {
      // Sao chép lại danh sách tạm vào danh sách chính thức
      selectedFoodsMan = tempFoodsMan;
      selectedFoodsChay = tempFoodsChay;
      selectedThucUong = tempThucUong;
      selectedDichVu = tempDichVu;
      selectedPhatSinh = tempPhatSinh;

      if (typeof onSaveCallback === 'function') {
        onSaveCallback(m);
      } else {
        _writeInputs(activeModal);
        m.closeNow();
        if (window.Toast) Toast.success('Đã cập nhật danh sách thực đơn & dịch vụ thành công!');
      }
    };

    // Khởi chạy vẽ ban đầu trong Modal
    renderGrid();
    updateTotals();
    renderDrawer();
  }

  // Danh sách form name cần kích hoạt plugin (đóng băng form, chạy độc lập qua toolbar button)
  var SUPPORTED_FORMS = [];

  function _resolveEditRow(modalContent, row) {
    if (row) return row;
    var formBody = modalContent.querySelector('[data-form-name]') || modalContent;
    var rowJson = formBody.dataset ? formBody.dataset.editRowJson : '';
    if (!rowJson) return null;
    try { return JSON.parse(rowJson); } catch (e) { return null; }
  }

  // Tự inject hidden input JSON nếu chưa có trong form
  function _ensureHiddenInputs(modalContent, row) {
    var editRow = _resolveEditRow(modalContent, row);
    var jsonFields = ['JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh', 'JsonBanTiecHopDong', 'JsonThucUongHopDong', 'JsonDichVuHopDong'];
    jsonFields.forEach(function (name) {
      var rawVal = (editRow && editRow[name]) ? editRow[name] : '[]';
      var stringVal = '[]';
      if (rawVal) {
        if (typeof rawVal === 'string') {
          stringVal = rawVal;
        } else {
          try { stringVal = JSON.stringify(rawVal); } catch (e) { stringVal = '[]'; }
        }
      }

      if (!modalContent.querySelector('[name="' + name + '"]')) {
        var inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = name;
        inp.value = stringVal;
        modalContent.appendChild(inp);
      } else {
        // Nếu đã có nhưng rỗng hoặc bị cast thành [object Object], ghi đè lại bằng JSON string
        var existing = modalContent.querySelector('[name="' + name + '"]');
        if ((!existing.value || existing.value === '' || existing.value === '[]' || existing.value.indexOf('[object Object]') !== -1) && editRow && editRow[name]) {
          existing.value = stringVal;
        }
      }
    });
  }

  // Intercept và vẽ Block Thực đơn vào Edit Form của DynamicFormEngine
  function _interceptForm(modalContent, row) {
    // Ngăn không inject 2 lần
    if (modalContent.dataset.foodPluginDone === '1') return;
    modalContent.dataset.foodPluginDone = '1';

    var actualModal = modalContent.closest('.modal-content');
    if (actualModal) {
      actualModal.style.width = '1150px';
    } else {
      modalContent.style.width = '1150px';
    }

    activeModal = modalContent;

    _injectStyles();

    // 1. Đảm bảo các hidden input JSON tồn tại (tự tạo nếu chưa có)
    _ensureHiddenInputs(modalContent, row);

    // 2. Quét đọc dữ liệu hiện có
    _readInputs(modalContent);

    // 2.5 Lắng nghe sự thay đổi của Gói tiệc (GoiThucDonID)
    var selectGoiThucDon = modalContent.querySelector('[name="GoiThucDonID"]');
    if (selectGoiThucDon) {
      selectGoiThucDon.addEventListener('change', function (event) {
        var goiThucDonId = this.value;
        if (!goiThucDonId) return;

        var hasExisting = selectedFoodsMan.length > 0 || selectedFoodsChay.length > 0 || selectedThucUong.length > 0 || selectedDichVu.length > 0;
        
        if (!event.isTrusted) {
          if (hasExisting) {
            return;
          }
        } else {
          if (hasExisting && !confirm('Bạn có muốn tự động tải thực đơn mẫu từ gói này không? Thực đơn hiện tại sẽ bị ghi đè.')) {
            return;
          }
        }

        _loadCatalog().then(function (catalog) {
          var matchedItems = catalog.filter(function (item) {
            return item.GoiThucDonID === goiThucDonId;
          });

          if (matchedItems.length === 0) {
            if (window.Toast) Toast.warning('Gói thực đơn này chưa có cấu hình món ăn mẫu nào!');
            return;
          }

          // Phân loại các món
          selectedFoodsMan = matchedItems.filter(function (x) { return x.IsChay === 0 && x.IsDrink === 0 && x.IsDichVu === 0; });
          selectedFoodsChay = matchedItems.filter(function (x) { return x.IsChay === 1 && x.IsDrink === 0 && x.IsDichVu === 0; });
          selectedThucUong = matchedItems.filter(function (x) { return x.IsDrink === 1; });
          selectedDichVu = matchedItems.filter(function (x) { return x.IsDichVu === 1; });

          _writeInputs(modalContent);
          
          if (window.Toast) {
            var selectedText = selectGoiThucDon.options && selectGoiThucDon.options[selectGoiThucDon.selectedIndex] 
              ? selectGoiThucDon.options[selectGoiThucDon.selectedIndex].text 
              : 'gói tiệc';
            Toast.success('Đã tải thành công thực đơn của ' + selectedText + '!');
          }
        });
      });
    }

    var rawInputNames = ['JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh'];
    rawInputNames.forEach(function (name) {
      var inp = modalContent.querySelector('[name="' + name + '"]');
      if (inp) {
        var col = inp.closest('.df-col-12, .df-col-6, .df-col-4, .form-group');
        if (col) col.style.display = 'none';
      }
    });

    var grid = modalContent.querySelector('[data-form-name]');
    if (!grid) {
      var modalBody = modalContent.querySelector('.ui-modal-body') || modalContent.querySelector('.card-body');
      if (modalBody) {
        grid = modalBody.querySelector('div');
      }
    }
    if (!grid) {
      grid = modalContent;
    }

    if (!grid.querySelector('.food-selection-tables-wrapper')) {
      var wrapper = document.createElement('div');
      wrapper.className = 'df-col-12 food-plugin-wrapper food-selection-tables-wrapper';
      wrapper.dataset.activeTab = 'man';

      wrapper.innerHTML = `
        <div class="food-plugin-header">
          <h5 class="food-plugin-title">
            <span class="material-symbols-outlined">restaurant_menu</span>
            Thực đơn & Dịch vụ đính kèm
          </h5>
          <button type="button" class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1" onclick="PhatSinhPlugin.openSelectionModal()">
            <span class="material-symbols-outlined" style="font-size:18px;">add_circle</span> Thiết lập Thực đơn & Dịch vụ
          </button>
        </div>

        <div class="food-modal-tabs">
        </div>

        <div class="table-responsive food-summary-grid-body" style="max-height: 280px; overflow-y: auto; overflow-x: auto; width: 100%; border: 1px solid var(--color-border); border-radius: 8px;">
        </div>

        <div class="food-footer-container d-flex justify-content-between align-items-center mt-3 pt-3" style="border-top: 1px solid var(--color-border);">
          <div style="font-size:13px; color:var(--color-text-secondary);">
            Tổng cộng Tab: <strong class="food-tab-total text-danger" style="font-size:14px;">0 đ</strong>
          </div>
          <div style="font-size:14px; font-weight:700;">
            Tổng cộng Hợp đồng: <strong class="food-sum-total text-danger" style="font-size:16px;">0 đ</strong>
          </div>
        </div>
      `;

      var buttonsRow = grid.querySelector('.justify-content-end') || grid.querySelector('.d-flex.justify-content-end') || grid.querySelector('form > .d-flex');
      if (buttonsRow) {
        buttonsRow.parentNode.insertBefore(wrapper, buttonsRow);
      } else {
        grid.appendChild(wrapper);
      }
      _renderSummaryTables();
    }

    setTimeout(function () {
      _readInputs(modalContent);
      _renderSummaryTables();
    }, 200);
  }

  // Khởi chạy MutationObserver để lắng nghe sự kiện xuất hiện modal mới
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
            } else {
              return;
            }
          }

          if (formBody) {
            var modalContentEl = formBody.closest('.modal-content') || formBody;
            _loadCatalog();
            var checkInterval = setInterval(function () {
              if (modalContentEl.querySelector('.df-col-12, .df-col-6, .df-col-4, .form-group, [name="JsonBanTiec"]')) {
                clearInterval(checkInterval);
                _interceptForm(modalContentEl, null);
              }
            }, 100);
            setTimeout(function () { clearInterval(checkInterval); }, 5000);
          }
        });
      });
    });

    _observer.observe(document.body, { childList: true, subtree: true });
  }

  function openPhatSinhModalDirect(sohopdong, onReload) {
    _injectStyles();
    if (typeof ApiClient === 'undefined' || !window.API_CONFIG || !window.API_CONFIG.ENDPOINTS) {
      if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không tìm thấy cấu hình ApiClient.');
      return;
    }

    if (typeof UIToast !== 'undefined') {
      UIToast.show('Đang tải danh sách phát sinh...', 'info');
    }

    _loadCatalog().then(function (catalog) {
      ApiClient.post(window.API_CONFIG.ENDPOINTS.ROUTER, {
        List: 'API_DanhSachPhatSinh',
        Func: 'View',
        Keyword: sohopdong
      }).then(function (res) {
        var details = null;
        if (res) {
          if (res.records && res.records.length > 0)      details = res.records[0];
          else if (res.data && res.data.length > 0)       details = res.data[0];
          else if (res.records && Array.isArray(res.records)) details = res.records[0];
          else if (Array.isArray(res) && res.length > 0)  details = res[0];
          else if (!res.records && !res.data && !Array.isArray(res)) details = res;
        }

        var rawPhatSinh = [];
        if (details && details.MenuPhatSinh) {
          var rawVal = details.MenuPhatSinh;
          if (typeof rawVal === 'string') {
            try { rawPhatSinh = JSON.parse(rawVal); } catch (e) { }
          } else if (Array.isArray(rawVal)) {
            rawPhatSinh = rawVal;
          }
        }

        // Phân loại vào các tab
        var mappedPhatSinh = _mapRawItems(rawPhatSinh, 0);

        selectedFoodsMan = [];
        selectedFoodsChay = [];
        selectedThucUong = [];
        selectedDichVu = [];
        selectedPhatSinh = [];

        mappedPhatSinh.forEach(function (item) {
          var maMon = item.MaMon;
          var catalogItem = catalog.find(function (c) { return (c.Mahang || c.MaMon) === maMon; });

          if (catalogItem) {
            if (catalogItem.IsDrink === 1 || catalogItem.IsDrink === true) {
              selectedThucUong.push(item);
            } else if (catalogItem.IsDichVu === 1 || catalogItem.IsDichVu === true) {
              selectedDichVu.push(item);
            } else if (catalogItem.IsChay === 1 || catalogItem.IsChay === true) {
              selectedFoodsChay.push(item);
            } else {
              selectedFoodsMan.push(item);
            }
          } else {
            selectedPhatSinh.push(item);
          }
        });

        // Callback khi bấm "Hoàn tất & Đóng"
        var onSaveCallback = function (modalInstance) {
          var allItems = [];
          
          selectedFoodsMan.forEach(function (x) {
            allItems.push({
              Mahang: x.MaMon || x.Mahang,
              Soluong: x.SoLuong || x.Soluong || 1,
              Dongia: x.DonGia || x.Dongia || 0,
              GhiChuPhatSinh: ''
            });
          });

          selectedFoodsChay.forEach(function (x) {
            allItems.push({
              Mahang: x.MaMon || x.Mahang,
              Soluong: x.SoLuong || x.Soluong || 1,
              Dongia: x.DonGia || x.Dongia || 0,
              GhiChuPhatSinh: ''
            });
          });

          selectedThucUong.forEach(function (x) {
            allItems.push({
              Mahang: x.MaMon || x.Mahang,
              Soluong: x.SoLuong || x.Soluong || 1,
              Dongia: x.DonGia || x.Dongia || 0,
              GhiChuPhatSinh: ''
            });
          });

          selectedDichVu.forEach(function (x) {
            allItems.push({
              Mahang: x.MaMon || x.Mahang,
              Soluong: x.SoLuong || x.Soluong || 1,
              Dongia: x.DonGia || x.Dongia || 0,
              GhiChuPhatSinh: ''
            });
          });

          selectedPhatSinh.forEach(function (x) {
            allItems.push({
              Mahang: x.MaMon || x.Mahang || 'PHATSINH',
              Soluong: x.SoLuong || x.Soluong || 1,
              Dongia: x.DonGia || x.Dongia || 0,
              GhiChuPhatSinh: x.TenMon || x.TenHang || ''
            });
          });

          if (typeof UIToast !== 'undefined') UIToast.show('Đang lưu phát sinh...', 'info');

          var userName = 'system';
          if (typeof _currentUser === 'function') {
            userName = _currentUser();
          } else {
            try {
              var userStr = localStorage.getItem('pmql_user');
              if (userStr) {
                var userObj = JSON.parse(userStr);
                userName = userObj.Username || userObj.UserName || userName;
              }
            } catch (e) {}
          }

          var jsonData = {
            Sohopdong: sohopdong,
            JsonPhatSinh: JSON.stringify(allItems),
            UserName: userName,
            User: userName
          };

          ApiClient.post(window.API_CONFIG.ENDPOINTS.ROUTER, {
            List: 'frmHopDong',
            Func: 'SavePhatSinh',
            JsonData: JSON.stringify(jsonData)
          }).then(function (saveRes) {
            var isOk = false;
            var msg = 'Đã lưu danh sách phát sinh thành công!';
            if (saveRes) {
              var checkSuccess = function (obj) {
                if (!obj) return false;
                var s = obj.Success !== undefined ? obj.Success : obj.success;
                return s == 1 || s === true || String(s) === '1' || String(s).toLowerCase() === 'true';
              };

              if (Array.isArray(saveRes)) {
                if (saveRes.length > 0) {
                  isOk = checkSuccess(saveRes[0]);
                  msg = saveRes[0].Message || saveRes[0].message || saveRes[0].msg || msg;
                }
              } else {
                var records = saveRes.records || saveRes.data || saveRes.list;
                if (Array.isArray(records) && records.length > 0) {
                  isOk = checkSuccess(records[0]);
                  msg = records[0].Message || records[0].message || records[0].msg || msg;
                } else if (saveRes.code === 0 || saveRes.Success === 1 || saveRes.Success === true || saveRes.success === true) {
                  isOk = true;
                  msg = saveRes.Message || saveRes.msg || msg;
                }
              }
            }

            if (isOk) {
              modalInstance.closeNow();
              if (typeof Alert !== 'undefined') Alert.success('Thành công', msg);
              else if (window.Toast) Toast.success(msg);
              if (typeof onReload === 'function') onReload();
            } else {
              if (typeof Alert !== 'undefined') Alert.error('Lỗi', msg);
              else alert('Lỗi: ' + msg);
            }
          }).catch(function (err) {
            console.error('[PhatSinhPlugin] Lỗi lưu phát sinh:', err);
            if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không thể gửi yêu cầu lưu phát sinh.');
          });
        };

        // Mở popup chọn món
        _showSelectorModal(catalog, onSaveCallback);
      }).catch(function (err) {
        console.error('[PhatSinhPlugin] Lỗi tải thông tin phát sinh:', err);
        if (typeof Alert !== 'undefined') Alert.error('Lỗi', 'Không thể tải thông tin phát sinh của hợp đồng.');
      });
    });
  }

  function getExtraButtons(formName, getSelectedRows, moduleConfig, onReload) {
    if (formName !== 'frmHopDong') return [];

    return [{
      id: 'btn-nhap-phatsinh',
      text: 'Nhập Phát Sinh',
      icon: 'add_box',
      type: 'tool',
      onClick: function () {
        var selectedRows = getSelectedRows();
        if (!selectedRows || selectedRows.length !== 1) {
          if (typeof Alert !== 'undefined') {
            Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Hợp Đồng duy nhất để nhập phát sinh.');
          } else {
            alert('Vui lòng chọn 1 Hợp Đồng!');
          }
          return;
        }

        var row = selectedRows[0];
        var sohopdong = row.Sohopdong || row.sohopdong || row.SoHopDong;

        openPhatSinhModalDirect(sohopdong, onReload);
      }
    }];
  }

  // Auto-init khi load plugin
  init();

  return {
    openSelectionModal: openSelectionModal,
    switchSummaryTab: switchSummaryTab,
    removeItem: removeItem,
    changeQty: changeQty,
    addBack: addBack,
    getExtraButtons: getExtraButtons,
    openPhatSinhModalDirect: openPhatSinhModalDirect,
    reloadForm: function (modal) {
      if (modal) {
        activeModal = modal;
        if (modal.dataset.foodPluginDone !== '1') {
          _interceptForm(modal, null);
        } else {
          _readInputs(modal);
          _renderSummaryTables();
        }
      }
    }
  };
})();

// Đăng ký Plugin vào hệ thống FormActionPlugins
window.FormActionPlugins = window.FormActionPlugins || [];
window.FormActionPlugins.push({ getExtraButtons: PhatSinhPlugin.getExtraButtons });
