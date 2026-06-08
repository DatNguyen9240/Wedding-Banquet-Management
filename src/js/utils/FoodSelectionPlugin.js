/**
 * FoodSelectionPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin quản lý việc Chọn Thực đơn & Dịch vụ dưới dạng lưới thẻ Card.
 * Tự động tích hợp vào các form động (frmHopDong, tbmk_Thaydoi, frmQuyetToan)
 * thông qua MutationObserver để ẩn các trường JSON thô và thay thế bằng UI đẹp mắt.
 */
var FoodSelectionPlugin = (function () {
  var catalogCache = null; // Bộ nhớ đệm danh mục món ăn từ API
  var activeModal = null; // Modal form đang sửa/thêm
  
  // Trạng thái các món đang chọn (lưu tạm)
  var selectedFoodsMan = [];
  var selectedFoodsChay = [];
  var selectedThucUong = [];
  var selectedDichVu = [];

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
        color: var(--color-primary);
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
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
          console.error('[FoodSelectionPlugin] Lỗi tải catalog từ ContractService:', err);
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

      return {
        MaMon: maMon,
        Mahang: maMon,
        TenMon: rawItem.TenHang || rawItem.TenMon || (catalogItem ? (catalogItem.Tenhang || catalogItem.TenMon) : ''),
        TenHang: rawItem.TenHang || rawItem.TenMon || (catalogItem ? (catalogItem.Tenhang || catalogItem.TenMon) : ''),
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

    var rawBanTiec = [];
    var rawThucUong = [];
    var rawDichVu = [];

    try { if (inpBanTiec && inpBanTiec.value) rawBanTiec = JSON.parse(inpBanTiec.value); } catch (e) {}
    try { if (inpThucUong && inpThucUong.value) rawThucUong = JSON.parse(inpThucUong.value); } catch (e) {}
    try { if (inpDichVu && inpDichVu.value) rawDichVu = JSON.parse(inpDichVu.value); } catch (e) {}

    var mappedBanTiec = _mapRawItems(rawBanTiec, 0);
    
    // Tách món mặn & món chay
    selectedFoodsMan = mappedBanTiec.filter(function (x) { return x.IsChay === 0 || x.IsChay === false; });
    selectedFoodsChay = mappedBanTiec.filter(function (x) { return x.IsChay === 1 || x.IsChay === true; });

    selectedThucUong = _mapRawItems(rawThucUong, 0);
    selectedDichVu = _mapRawItems(rawDichVu, 0);
  }

  // Ghi dữ liệu ngược lại các input ẩn và phát sự kiện change
  function _writeInputs(modal) {
    var inpBanTiec = modal.querySelector('[name="JsonBanTiec"]');
    var inpThucUong = modal.querySelector('[name="JsonThucUong"]');
    var inpDichVu = modal.querySelector('[name="JsonDichVu"]');

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

    var listDichVu = selectedDichVu.map(function (x) {
      return {
        Mahang: x.MaMon,
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

    _renderSummaryTables();
  }

  // Vẽ các bảng hiển thị tóm tắt trong Form cha
  function _renderSummaryTables() {
    var container = activeModal.querySelector('.food-selection-tables-wrapper');
    if (!container) return;

    var activeTab = container.dataset.activeTab || 'man';

    var renderTabButton = function (tabId, label, count) {
      var cls = activeTab === tabId ? 'active' : '';
      return `<button type="button" class="food-modal-tab-btn ${cls}" onclick="FoodSelectionPlugin.switchSummaryTab('${tabId}')">${label} (${count})</button>`;
    };

    var contentHtml = '';
    var totalText = '0 đ';

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
            <td><span class="badge bg-light text-dark">${item.PhanLoai}</span></td>
            <td class="fw-medium">${item.TenMon}</td>
            <td class="text-end text-danger fw-semibold">${item.DonGia.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">
              <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="FoodSelectionPlugin.removeItem('man', ${idx})">delete</span>
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
            <td><span class="badge bg-light text-dark">${item.PhanLoai}</span></td>
            <td class="fw-medium">${item.TenMon}</td>
            <td class="text-end text-success fw-semibold">${item.DonGia.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">
              <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="FoodSelectionPlugin.removeItem('chay', ${idx})">delete</span>
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
                <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="FoodSelectionPlugin.changeQty('drink', ${idx}, -1)">-</button>
                <span style="min-width: 24px; display:inline-block;" class="fw-bold">${item.SoLuong}</span>
                <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="FoodSelectionPlugin.changeQty('drink', ${idx}, 1)">+</button>
              </div>
            </td>
            <td class="text-end text-danger fw-semibold">${sub.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">
              <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="FoodSelectionPlugin.removeItem('drink', ${idx})">delete</span>
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
                <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="FoodSelectionPlugin.changeQty('service', ${idx}, -1)">-</button>
                <span style="min-width: 24px; display:inline-block;" class="fw-bold">${item.SoLuong}</span>
                <button type="button" class="btn btn-sm btn-light p-1" style="line-height:1" onclick="FoodSelectionPlugin.changeQty('service', ${idx}, 1)">+</button>
              </div>
            </td>
            <td class="text-end text-danger fw-semibold">${sub.toLocaleString('vi-VN')} đ</td>
            <td class="text-center">
              <span class="material-symbols-outlined text-danger cursor-pointer" style="font-size:18px" onclick="FoodSelectionPlugin.removeItem('service', ${idx})">delete</span>
            </td>
          </tr>`;
        });
      }
      contentHtml += `</tbody></table>`;
    }

    var grandTotal = 
      selectedFoodsMan.reduce(function (sum, item) { return sum + item.DonGia; }, 0) +
      selectedFoodsChay.reduce(function (sum, item) { return sum + item.DonGia; }, 0) +
      selectedThucUong.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0) +
      selectedDichVu.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0);

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

    var tabTotal = container.querySelector('.food-tab-total');
    if (tabTotal) tabTotal.innerText = totalText;

    var sumTotal = container.querySelector('.food-sum-total');
    if (sumTotal) sumTotal.innerText = grandTotal.toLocaleString('vi-VN') + ' đ';
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
  function changeQty(type, index, delta) {
    if (type === 'drink') {
      var item = selectedThucUong[index];
      item.SoLuong = Math.max(1, item.SoLuong + delta);
    } else if (type === 'service') {
      var item = selectedDichVu[index];
      item.SoLuong = Math.max(1, item.SoLuong + delta);
    }
    _writeInputs(activeModal);
  }

  // Xóa món ngoài form cha
  function removeItem(type, index) {
    if (type === 'man') selectedFoodsMan.splice(index, 1);
    else if (type === 'chay') selectedFoodsChay.splice(index, 1);
    else if (type === 'drink') selectedThucUong.splice(index, 1);
    else if (type === 'service') selectedDichVu.splice(index, 1);

    _writeInputs(activeModal);
    if (window.Toast) Toast.success('Đã xóa món ăn khỏi thực đơn!');
  }

  // Mở popup modal chọn món tập trung (Có Tabs trượt)
  function openSelectionModal() {
    _loadCatalog().then(function (catalog) {
      _showSelectorModal(catalog);
    });
  }

  // Vẽ chi tiết popup chọn món
  function _showSelectorModal(catalog) {
    var modalTab = 'man'; // Mặc định là món mặn
    var searchKeyword = '';

    // Sao chép sâu mảng tạm để tránh thay đổi trực tiếp trước khi ấn "Hoàn tất"
    var tempFoodsMan = JSON.parse(JSON.stringify(selectedFoodsMan));
    var tempFoodsChay = JSON.parse(JSON.stringify(selectedFoodsChay));
    var tempThucUong = JSON.parse(JSON.stringify(selectedThucUong));
    var tempDichVu = JSON.parse(JSON.stringify(selectedDichVu));

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
      return [];
    }

    // Phân loại các sản phẩm trong Catalog
    function filterCatalogByTab(tab, keyword) {
      var kw = (keyword || '').toLowerCase().trim();
      return catalog.filter(function (item) {
        var name = (item.Tenhang || item.TenMon || '').toLowerCase();
        var code = (item.Mahang || item.MaMon || '').toLowerCase();
        if (kw && !name.includes(kw) && !code.includes(kw)) return false;

        // Phân loại
        var isChay = item.IsChay === 1 || item.IsChay === true;
        var pLoai = item.PhanLoai || item.Phanloai || item.Tennhomhang || 'Khác';

        var isDrink = pLoai.includes('Bia') || pLoai.includes('Nước') || pLoai.includes('Thức uống') || pLoai.includes('Uống');
        var isService = pLoai.includes('Dịch vụ') || pLoai.includes('Nghi lễ');

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
              <span class="badge bg-light text-dark" style="font-size:11px;">${groupItems.length} sản phẩm</span>
            </div>
            <div class="food-grid-container">
        `;

        groupItems.forEach(function (item) {
          var code = item.Mahang || item.MaMon;
          var name = item.Tenhang || item.TenMon;
          var price = item.Dongia || item.DonGia || 0;
          var unit = item.DvtID || 'Đĩa';

          var currentList = getTempListByTab(modalTab);
          var isSelected = currentList.some(function (x) { return x.MaMon === code; });

          var cardStyle = isSelected ? 'border-color: var(--color-primary); background-color: rgba(79, 70, 229, 0.04);' : '';
          var btnStyle = isSelected ? 'background: #10B981; border: none; color: white;' : 'background: var(--color-primary); border: none; color: white;';
          var iconName = isSelected ? 'check' : 'add';

          html += `
            <div class="food-card" id="card-${code}" style="${cardStyle}">
              <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                <span class="badge bg-light text-muted" style="font-family: monospace; font-size:10px; padding: 2px 4px;">${code}</span>
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

        if (modalTab === 'drink' || modalTab === 'service') {
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
          var removed = currentList[idx];
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
        tempDichVu.reduce(function (sum, item) { return sum + item.DonGia * item.SoLuong; }, 0);

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

      _writeInputs(activeModal);
      m.closeNow();
      if (window.Toast) Toast.success('Đã cập nhật danh sách thực đơn & dịch vụ thành công!');
    };

    // Khởi chạy vẽ ban đầu trong Modal
    renderGrid();
    updateTotals();
    renderDrawer();
  }

  // Danh sách form name cần kích hoạt plugin
  var SUPPORTED_FORMS = ['tbmk_Thaydoi', 'frmThayDoiBoSung'];

  // Tự inject hidden input JSON nếu chưa có trong form
  function _ensureHiddenInputs(modalContent, row) {
    var jsonFields = ['JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh'];
    jsonFields.forEach(function (name) {
      if (!modalContent.querySelector('[name="' + name + '"]')) {
        var inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = name;
        inp.value = (row && row[name]) ? row[name] : '[]';
        modalContent.appendChild(inp);
      } else {
        // Nếu đã có nhưng rỗng, cố gắng lấy từ row
        var existing = modalContent.querySelector('[name="' + name + '"]');
        if ((!existing.value || existing.value === '') && row && row[name]) {
          existing.value = row[name];
        }
      }
    });
  }

  // Intercept và vẽ Block Thực đơn vào Edit Form của DynamicFormEngine
  function _interceptForm(modalContent, row) {
    // Ngăn không inject 2 lần
    if (modalContent.dataset.foodPluginDone === '1') return;
    modalContent.dataset.foodPluginDone = '1';

    activeModal = modalContent;
    // Tự động nới rộng Modal để đủ chỗ hiển thị bảng
    if (activeModal && activeModal.style) {
      activeModal.style.width = '1000px';
      activeModal.style.maxWidth = '95vw';
    }

    _injectStyles();

    // 1. Đảm bảo các hidden input JSON tồn tại (tự tạo nếu chưa có)
    _ensureHiddenInputs(modalContent, row);

    // 2. Quét đọc dữ liệu hiện có
    _readInputs(modalContent);

    // 3. Ẩn các Form Group của trường JSON thô nếu đang hiển thị
    var rawInputNames = ['JsonBanTiec', 'JsonThucUong', 'JsonDichVu', 'JsonPhatSinh'];
    rawInputNames.forEach(function (name) {
      var inp = modalContent.querySelector('[name="' + name + '"]');
      if (inp) {
        var col = inp.closest('.df-col-12, .df-col-6, .df-col-4, .form-group');
        if (col) col.style.display = 'none';
      }
    });

    // 4. Tìm vùng grid - ưu tiên div[data-form-name] (body của DFE), hoặc .ui-modal-body > div
    var grid = modalContent.querySelector('[data-form-name]');
    if (!grid) {
      // Fallback: tìm div flex chứa các trường form trong .ui-modal-body
      var modalBody = modalContent.querySelector('.ui-modal-body') || modalContent.querySelector('.card-body');
      if (modalBody) {
        grid = modalBody.querySelector('div');
      }
    }
    if (!grid) {
      grid = modalContent; // Last resort
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
          <button type="button" class="btn btn-outline-primary btn-sm d-flex align-items-center gap-1" onclick="FoodSelectionPlugin.openSelectionModal()">
            <span class="material-symbols-outlined" style="font-size:18px;">add_circle</span> Thiết lập Thực đơn & Dịch vụ
          </button>
        </div>

        <!-- Switch Tab hiển thị trong Form -->
        <div class="food-modal-tabs">
          <!-- Tải động từ render -->
        </div>

        <!-- Bảng danh sách mặt hàng -->
        <div class="table-responsive food-summary-grid-body" style="max-height: 280px; overflow-y: auto; border: 1px solid var(--color-border); border-radius: 8px;">
          <!-- Tải động từ render -->
        </div>

        <!-- Footer tóm tắt tiền -->
        <div class="d-flex justify-content-between align-items-center mt-3 pt-3" style="border-top: 1px solid var(--color-border);">
          <div style="font-size:13px; color:var(--color-text-secondary);">
            Tổng cộng Tab: <strong class="food-tab-total text-danger" style="font-size:14px;">0 đ</strong>
          </div>
          <div style="font-size:14px; font-weight:700;">
            Tổng cộng Hợp đồng: <strong class="food-sum-total text-danger" style="font-size:16px;">0 đ</strong>
          </div>
        </div>
      `;

      grid.appendChild(wrapper);
      _renderSummaryTables();
    }
  }

  // Khởi chạy MutationObserver để lắng nghe sự kiện xuất hiện modal mới
  var _observer = null;
  function init() {
    if (_observer) _observer.disconnect();

    _observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        mutation.addedNodes.forEach(function (node) {
          if (node.nodeType !== Node.ELEMENT_NODE) return;

          // UIModal thêm .modal-overlay vào #modal-container
          // Bên trong có .modal-content > .ui-modal-body > body[data-form-name]
          var formBody = null;

          // Cách 1: Tìm element có data-form-name
          var bodyWithFormName = node.querySelector('[data-form-name]');
          if (bodyWithFormName) {
            var formName = bodyWithFormName.getAttribute('data-form-name');
            if (SUPPORTED_FORMS.indexOf(formName) !== -1) {
              formBody = bodyWithFormName;
            }
          }

          // Cách 2: Fallback - tìm [name="JsonBanTiec"] đã có sẵn
          if (!formBody) {
            var modalContent = node.querySelector('.modal-content') ||
                               (node.classList && node.classList.contains('modal-content') ? node : null);
            if (modalContent) {
              var hasJsonField = modalContent.querySelector('[name="JsonBanTiec"]');
              if (hasJsonField) {
                formBody = modalContent;
              }
            }
          }

          if (formBody) {
            // Lấy .modal-content để dùng làm activeModal
            var modalContentEl = formBody.closest('.modal-content') || formBody;
            _loadCatalog();
            // Đợi một tick để DFE hoàn thành render form rồi mới inject
            setTimeout(function () {
              _interceptForm(modalContentEl, null);
            }, 50);
          }
        });
      });
    });

    _observer.observe(document.body, { childList: true, subtree: true });
  }

  // Auto-init khi load plugin
  init();

  return {
    openSelectionModal: openSelectionModal,
    switchSummaryTab: switchSummaryTab,
    removeItem: removeItem,
    changeQty: changeQty
  };
})();

