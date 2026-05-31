/**
 * Quản lý Kho & Định lượng (Inventory & Recipe Costing)
 * Phase 1: Danh mục Kho, Nguyên vật liệu, Định lượng Món ăn
 */
var InventoryPage = (function () {

  function render(containerId) {
    var container = document.getElementById(containerId);
    if (!container) return;

    // Các thành phần UI được load từ inventory.html bởi router
    _bindEvents();
    _renderKhoPane();
  }

  function _bindEvents() {
    var btnKho = document.getElementById('tab-kho-btn');
    var btnNvl = document.getElementById('tab-nvl-btn');
    var btnBom = document.getElementById('tab-bom-btn');

    var paneKho = document.getElementById('tab-kho-pane');
    var paneNvl = document.getElementById('tab-nvl-pane');
    var paneBom = document.getElementById('tab-bom-pane');

    if (!btnKho) return;

    function resetTabs() {
      btnKho.classList.remove('active');
      btnNvl.classList.remove('active');
      btnBom.classList.remove('active');
      btnKho.style.color = 'var(--color-text-secondary)';
      btnNvl.style.color = 'var(--color-text-secondary)';
      btnBom.style.color = 'var(--color-text-secondary)';
      btnKho.style.borderBottomColor = 'transparent';
      btnNvl.style.borderBottomColor = 'transparent';
      btnBom.style.borderBottomColor = 'transparent';

      paneKho.style.display = 'none';
      paneNvl.style.display = 'none';
      paneBom.style.display = 'none';
    }

    function setActive(btn, pane) {
      btn.classList.add('active');
      btn.style.color = 'var(--color-primary)';
      btn.style.borderBottomColor = 'var(--color-primary)';
      pane.style.display = 'block';
    }

    btnKho.onclick = function() {
      resetTabs();
      setActive(btnKho, paneKho);
      _renderKhoPane();
    };

    btnNvl.onclick = function() {
      resetTabs();
      setActive(btnNvl, paneNvl);
      _renderNvlPane();
    };

    btnBom.onclick = function() {
      resetTabs();
      setActive(btnBom, paneBom);
      _renderBomPane();
    };
  }

  function _renderKhoPane() {
    var container = document.getElementById('kho-list-view');
    if (!container) return;
    
    // Init KVTable for Kho
    if (typeof KVTable === 'undefined') return;
    KVTable.init({
      containerId: 'kho-list-view',
      title: 'Danh mục Kho',
      apiList: 'dmKho',
      allowAdd: true,
      allowEdit: true,
      allowDelete: true,
      columns: [
        { field: 'MaKho', title: 'Mã Kho', width: '120px' },
        { field: 'TenKho', title: 'Tên Kho', width: '250px' },
        { field: 'GhiChu', title: 'Ghi Chú', width: 'auto' }
      ]
    });
  }

  function _renderNvlPane() {
    var container = document.getElementById('nvl-list-view');
    if (!container || container.innerHTML.trim() !== '') return; // Already rendered
    
    // Init KVTable for NVL
    if (typeof KVTable === 'undefined') return;
    KVTable.init({
      containerId: 'nvl-list-view',
      title: 'Danh mục Nguyên vật liệu',
      apiList: 'dmNguyenvatlieu',
      allowAdd: true,
      allowEdit: true,
      allowDelete: true,
      columns: [
        { field: 'MaNVL', title: 'Mã NVL', width: '120px' },
        { field: 'TenNVL', title: 'Tên Nguyên Vật Liệu', width: '250px' },
        { field: 'DVT', title: 'ĐVT', width: '100px' },
        { field: 'GiaNhap', title: 'Giá Nhập Chuẩn', width: '150px', align: 'right', format: 'currency' },
        { field: 'GhiChu', title: 'Ghi Chú', width: 'auto' }
      ]
    });
  }

  function _renderBomPane() {
    var container = document.getElementById('bom-list-view');
    if (!container || container.innerHTML.trim() !== '') return;
    
    // Init KVTable for BOM
    if (typeof KVTable === 'undefined') return;
    KVTable.init({
      containerId: 'bom-list-view',
      title: 'Định lượng Món ăn (BOM)',
      apiList: 'dmHanghoadinhluong',
      allowAdd: true,
      allowEdit: true,
      allowDelete: true,
      columns: [
        { field: 'MaHang', title: 'Mã Món Ăn', width: '120px' },
        { field: 'MaNVL', title: 'Mã Nguyên Vật Liệu', width: '150px' },
        { field: 'SoLuong', title: 'Số lượng / Tỷ lệ', width: '150px', align: 'right' },
        { field: 'GhiChu', title: 'Ghi Chú', width: 'auto' }
      ]
    });
  }

  return {
    render: render
  };
})();
