/**
 * Màn hình Quyết toán Tiệc (Checkout)
 * Xử lý luồng IV.11 trong REQUIREMENT.md
 */
var CheckoutPage = (function () {
  var $container;

  // Mock data cho danh sách Hợp đồng cần Quyết toán
  var checkoutData = [
    { id: 'HDT-260105', customerName: 'Phạm Minh Phát & Lê Mai', eventDate: '22/11/2026', totalTables: 25, totalAmount: '95,000,000', status: 'Chờ Quyết Toán' },
    { id: 'HDT-260103', customerName: 'Vũ Khắc Tiệp & Nguyễn Ngọc Trinh', eventDate: '10/11/2026', totalTables: 50, totalAmount: '200,000,000', status: 'Đã Hoàn Tất' }
  ];

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div id="checkout-list-view">
        <div class="page-title-bar">
          <span>Quyết Toán & Thanh Lý Tiệc</span>
        </div>

        <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
          <button class="btn btn-tool" id="btn-process-checkout"><span class="material-symbols-outlined">receipt_long</span>Lập Quyết Toán</button>
          <div class="divider"></div>
          <button class="btn btn-tool" id="btn-print"><span class="material-symbols-outlined">print</span>In Bản Kê Quyết Toán</button>
        </div>

        <div class="card" style="animation: slideUp 0.4s ease forwards;">
          <div class="table-wrapper" style="overflow-x: auto; width: 100%;">
            <table class="data-table selectable" id="checkout-table">
              <thead>
                <tr>
                  <th style="width: 50px; text-align: center;">STT</th>
                  <th>Số Hợp Đồng</th>
                  <th>Tên Khách Hàng</th>
                  <th>Ngày Tổ Chức</th>
                  <th>Số Bàn Thực Tế</th>
                  <th style="text-align: right;">Phải Thanh Toán (VNĐ)</th>
                  <th style="text-align: center;">Trạng thái</th>
                </tr>
              </thead>
              <tbody>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div id="checkout-detail-view" style="display: none;"></div>
    `;

    $container.innerHTML = html;
    _renderTable();
    _bindEvents();
  }

  function _renderTable() {
    var tbody = $container.querySelector('#checkout-table tbody');
    tbody.innerHTML = '';

    checkoutData.forEach((row, idx) => {
      var statusClass = row.status === 'Đã Hoàn Tất' ? 'status-badge success' : 'status-badge warning';
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td style="text-align: center;">${idx + 1}</td>
        <td style="font-weight: 600; color: var(--color-primary);">${row.id}</td>
        <td style="font-weight: 500;">${row.customerName}</td>
        <td><span style="background:#F1F5F9; padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.eventDate}</span></td>
        <td style="text-align:right;">${row.totalTables} bàn</td>
        <td style="text-align: right; font-weight:600; color: var(--color-danger);">${row.totalAmount} đ</td>
        <td style="text-align: center;"><span class="${statusClass}">${row.status}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-process-checkout').addEventListener('click', function() {
      _showDetailView();
    });
  }

  function _showDetailView() {
    document.getElementById('checkout-list-view').style.display = 'none';
    var detailView = document.getElementById('checkout-detail-view');
    detailView.style.display = 'block';
    detailView.style.animation = 'slideUp 0.3s ease forwards';

    detailView.innerHTML = `
      <div class="page-title-bar" style="justify-content: space-between;">
        <div style="display:flex; align-items:center; gap: 12px;">
          <button class="btn btn-secondary" onclick="CheckoutPage.closeDetail()" style="padding: 6px 12px; border-radius: 8px;">
            <span class="material-symbols-outlined" style="font-size: 20px;">arrow_back</span>
          </button>
          <span>Quyết Toán Tiệc: HDT-260105</span>
        </div>
        <div class="button-bar" style="margin-bottom:0; background:transparent; padding:0; border:none; box-shadow:none;">
          <button class="btn btn-primary" onclick="UIToast.show('Lưu Thành Công! Sảnh đã được trả về trạng thái Trống.')">
            <span class="material-symbols-outlined">task_alt</span> LƯU & GIẢI PHÓNG SẢNH
          </button>
        </div>
      </div>
      
      <!-- Basic Info Header -->
      <div class="card mb-4" style="padding: 16px 24px; background: linear-gradient(to right, #F8FAFC, #FFFBEB); border-left: 4px solid var(--color-warning); display:flex; justify-content:space-between; align-items:center;">
         <div style="display:flex; gap: 48px; flex-wrap: wrap;">
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Đại Diện</label>
               <div style="font-weight:600; font-size:16px;">Phạm Minh Phát</div>
            </div>
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Đã Đặt Cọc (Đã thu)</label>
               <div style="font-weight:600; font-size:16px; color:var(--color-success)">50,000,000 đ</div>
            </div>
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Giảm Giá Tổng (Triết Khấu)</label>
               <div style="color:var(--color-danger); display:flex; align-items:center; gap: 4px;">
                  <input type="text" class="ui-input" style="width:100px; padding:4px 8px;" value="0" /> đ
               </div>
            </div>
         </div>
         <div style="text-align:right">
            <div style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px;">CÒN PHẢI THU</div>
            <div style="font-weight:bold; font-size:24px; color:var(--color-primary)">45,000,000 đ</div>
         </div>
      </div>

      <div class="card" id="checkout-tabs-container"></div>
    `;

    var tabs = UITabs.create([
      { title: 'Bàn Tiệc & Dịch vụ', content: '<div style="padding:24px"><p>Đối chiếu dữ liệu Bàn và Dịch Vụ từ Hợp Đồng. Cho phép điều chỉnh giá theo thực tế.</p></div>' },
      { title: 'Thức uống', content: '<div style="padding:24px"><p>Nhập <b>Số lượng thực tế sử dụng</b> để tính toán thành tiền phát sinh thêm.</p></div>' },
      { title: 'Phát sinh (Khác)', content: '<div style="padding:24px"><p>Lập bảng các hạng mục phát sinh ngoài Hợp Đồng (Bể ly, thêm bàn chót...)</p></div>' },
      { title: 'Bảng Giảm Giá Chi Tiết', content: '<div style="padding:24px"><p>Liệt kê lại các khoản giảm giá theo từng Dòng / Tab.</p></div>' }
    ]);
    document.getElementById('checkout-tabs-container').appendChild(tabs);
  }

  function closeDetail() {
    document.getElementById('checkout-detail-view').style.display = 'none';
    document.getElementById('checkout-detail-view').innerHTML = '';
    document.getElementById('checkout-list-view').style.display = 'block';
  }

  return { render: render, closeDetail: closeDetail };
})();
