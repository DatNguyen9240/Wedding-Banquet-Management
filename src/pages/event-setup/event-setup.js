/**
 * Module Thông Tin Sắp Đặt Tiệc (BEO - Banquet Event Order)
 * Route: #/event-setup
 */
var EventSetupPage = (function () {

  function render($container) {
    fetch('./src/pages/event-setup/event-setup.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _injectHeaderActions();
        _bindEvents();
      });
  }

  function _injectHeaderActions() {
    var globalActions = document.getElementById('global-page-actions');
    if (!globalActions) return;

    globalActions.innerHTML = '';
    if (typeof UIActionToolbar !== 'undefined') {
      var toolbar = UIActionToolbar.create({
        onAdd: false, onEdit: false, onDelete: false, onFilter: false, onPrint: false, onClose: false,
        extras: [
          { id: 'btn-select-contract', text: 'Tìm Hợp Đồng...', icon: 'search', type: 'tool', onClick: function() { _showSearchModal(); } },
          { id: 'btn-print-beo', text: 'In Lệnh BEO (A4)', icon: 'print', type: 'tool', onClick: function() { window.print(); } }
        ]
      });
      globalActions.appendChild(toolbar);
    }
  }

  function _bindEvents() {
    // Không cần bind lại sự kiện ở đây nữa, vì UIActionToolbar đã tự động gắn `onClick` khi khởi tạo nút.
  }

  function _showSearchModal() {
    var content = document.createElement('div');
    content.className = 'p-3';
    content.innerHTML = `
      <p class="text-secondary mb-2">Nhập số hợp đồng hoặc tên khách hàng để tìm kiếm...</p>
      <div class="d-flex gap-2 mb-3">
          <input type="text" id="beo-search-input" class="ui-input flex-grow-1" placeholder="VD: HĐ10426/001...">
          <button class="btn btn-primary d-flex align-items-center gap-1" id="beo-search-btn">
              <span class="material-symbols-outlined" style="font-size:18px;">search</span> Tìm
          </button>
      </div>
      <div id="beo-search-results" class="list-group" style="max-height: 250px; overflow-y: auto; border-radius:6px; border:1px solid var(--color-border);">
          <!-- Kết quả tìm kiếm sẽ hiện ở đây -->
      </div>
    `;

    var modalIns = UIModal.show({
      title: 'Chọn Hợp Đồng Tiệc',
      width: '500px',
      content: content,
      footer: '<button class="btn btn-secondary btn-close-modal">Đóng</button>'
    });

    modalIns.node.querySelector('.btn-close-modal').onclick = function () {
      modalIns.closeNow();
    };

    var btn = content.querySelector('#beo-search-btn');
    var inp = content.querySelector('#beo-search-input');
    var res = content.querySelector('#beo-search-results');

    function doSearch() {
      var kw = inp.value.trim();
      res.innerHTML = '<div class="text-center p-3 text-secondary"><span class="spinner-border spinner-border-sm me-2"></span>Đang tìm dữ liệu...</div>';

      var payload = {
        List: 'frmHopDong',
        Func: 'View',
        Keyword: kw,
        Limit: 10
      };

      ApiClient.post('/api/API_Gateway_Router', payload).then(function (response) {
        var list = response.list || response.records || [];
        if (list.length === 0) {
          res.innerHTML = '<div class="text-center p-3 text-muted">Không tìm thấy hợp đồng nào phù hợp.</div>';
          return;
        }

        res.innerHTML = '';
        list.forEach(function (item) {
          var a = document.createElement('a');
          a.className = 'list-group-item list-group-item-action d-flex justify-content-between align-items-center cursor-pointer';
          a.style.border = 'none';
          a.style.borderBottom = '1px solid var(--color-border)';
          
          var tenKh = item.Tenkh || item.Tenchure || item.Tencodau || 'Khách Hàng Trống';
          var soHd = item.Sohopdong || item.AutoID || 'N/A';
          var ngayTc = item.Ngaytochuc || 'Chưa xác định';
          
          a.innerHTML = `
              <div>
                  <h6 class="mb-1" style="font-size:14px; font-weight:600; color:var(--color-primary);">${tenKh}</h6>
                  <small class="text-muted d-block" style="font-size:12px;">Số HĐ: <b>${soHd}</b> &nbsp;|&nbsp; Ngày tiệc: ${ngayTc}</small>
              </div>
              <button class="btn btn-sm btn-outline-primary" style="border-radius:20px; padding:2px 10px; font-size:12px;">Chọn</button>
          `;
          a.onclick = function () {
            _loadContractToBEO(item);
            modalIns.closeNow();
          };
          res.appendChild(a);
        });
      }).catch(function (err) {
        res.innerHTML = '<div class="text-center p-3 text-danger">Lỗi kết nối khi tải danh sách hợp đồng.</div>';
      });
    }

    btn.onclick = doSearch;
    inp.onkeydown = function (e) { if (e.key === 'Enter') doSearch(); };

    // Tự động tìm khi vừa mở popup
    doSearch();
  }

  function _loadContractToBEO(data) {
    document.getElementById('beo-hd-no').innerText = data.Sohopdong || data.AutoID || 'N/A';

    // Tên Khách Hàng (Ưu tiên tên ghép)
    var tenKh = '';
    if (data.Tencodau && data.Tenchure) {
      tenKh = data.Tenchure + ' & ' + data.Tencodau;
    } else {
      tenKh = data.Tenkh || data.Tenchure || data.Tencodau || 'N/A';
    }
    document.getElementById('beo-customer').innerText = tenKh;

    // Ngày tổ chức
    document.getElementById('beo-date').innerText = data.Ngaytochuc || 'N/A';

    // Sảnh tiệc (Lấy từ dữ liệu API nếu có)
    var elmHall = document.getElementById('beo-hall');
    if (elmHall) elmHall.innerText = data.Tensanh || data.SanhTiec || 'Sảnh Kim Cương (Tầng 1)';

    // Các mục con (bếp, trang trí, v.v...) thường cần query 1 API detail khác. 
    // Tuy nhiên do đây là Demo BEO, ta cập nhật 1 số trường có sẵn và giữ nguyên cấu trúc hiển thị mẫu của HTML
    var menuList = document.getElementById('beo-menu-list');
    if (data.ThucDon && data.ThucDon.length > 0) {
      // Nếu API sau này có gộp sẵn array ThucDon
      menuList.innerHTML = '';
      data.ThucDon.forEach(function(mon, idx) {
        menuList.innerHTML += '<li>' + (idx+1) + '. ' + (mon.TenMon || mon.Tenhhoa) + '</li>';
      });
    } else {
      // Mock tạm 1 dòng để thể hiện là dữ liệu được render động 1 phần
      var htmlOriginal = menuList.innerHTML;
      menuList.innerHTML = '<li><i>(Dữ liệu thực đơn chi tiết sẽ được lấy từ các bảng con tbmk_HopDong_ThucDon...)</i></li>' + htmlOriginal;
    }

    if (typeof UIToast !== 'undefined') {
      UIToast.show('Đã tải thành công dữ liệu Hợp đồng ' + (data.Sohopdong || ''), 'success');
    }
  }

  return { render: render };
})();
