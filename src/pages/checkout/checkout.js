/**
 * Màn hình Quyết toán Tiệc (Checkout)
 * HTML Template: src/pages/checkout.html
 */
var CheckoutPage = (function () {
  var $container;
  var checkoutData = [
    { id: 'HDT-260105', customerName: 'Phạm Minh Phát & Lê Mai', eventDate: '22/11/2026', totalTables: 25, totalAmount: '95,000,000', status: 'Chờ Quyết Toán' },
    { id: 'HDT-260103', customerName: 'Vũ Khắc Tiệp & Nguyễn Ngọc Trinh', eventDate: '10/11/2026', totalTables: 50, totalAmount: '200,000,000', status: 'Đã Hoàn Tất' }
  ];

  function render(containerElement) {
    $container = containerElement;
    fetch('./src/pages/checkout/checkout.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderTable();
        _bindEvents();
      });
  }

  function _renderTable() {
    var tbody = $container.querySelector('#checkout-table tbody');
    tbody.innerHTML = '';
    checkoutData.forEach((row, idx) => {
      var statusClass = row.status === 'Đã Hoàn Tất' ? 'status-badge success' : 'status-badge warning';
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-semibold" style="color: var(--color-primary);">${row.id}</td>
        <td class="fw-medium">${row.customerName}</td>
        <td><span style="background: rgba(148, 163, 184, 0.1); padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.eventDate}</span></td>
        <td class="text-end">${row.totalTables} bàn</td>
        <td class="text-end fw-semibold" style="color: var(--color-danger);">${row.totalAmount} đ</td>
        <td class="text-center"><span class="${statusClass}">${row.status}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-process-checkout').addEventListener('click', function() { _showDetailView(); });
  }

  function _showDetailView() {
    document.getElementById('checkout-list-view').style.display = 'none';
    var dv = document.getElementById('checkout-detail-view');
    dv.style.display = 'block';
    dv.style.animation = 'slideUp 0.3s ease forwards';
    dv.innerHTML = '<div class="page-title-bar d-flex justify-content-between align-items-center"><div class="d-flex align-items-center gap-2">' + UIButton.createHTML({ icon: 'arrow_back', type: 'secondary', style: 'padding:6px 12px;border-radius:8px;', iconStyle: 'font-size:20px;', onClick: 'CheckoutPage.closeDetail()' }) + '<span>Quyết Toán Tiệc: HDT-260105</span></div><div class="button-bar" style="margin-bottom:0;background:transparent;padding:0;border:none;box-shadow:none;">' + UIButton.createHTML({ text: 'LƯU & GIẢI PHÓNG SẢNH', icon: 'task_alt', type: 'primary', onClick: "UIToast.show('Lưu Thành Công! Sảnh đã được trả.')" }) + '</div></div><div class="card mb-4" style="padding:16px 24px;background:var(--color-surface);border-left:4px solid var(--color-warning);"><div class="row g-4 align-items-center"><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Đại Diện</label><div class="fw-semibold" style="font-size:16px;">Phạm Minh Phát</div></div><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Đã Đặt Cọc</label><div class="fw-semibold" style="font-size:16px;color:var(--color-success)">50,000,000 đ</div></div><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Giảm Giá</label><div style="color:var(--color-danger);display:flex;align-items:center;gap:4px;"><input type="text" class="ui-input" style="width:100px;padding:4px 8px;" value="0"> đ</div></div><div class="col-md-3 text-end"><div style="font-size:13px;color:var(--color-text-secondary);margin-bottom:4px;">CÒN PHẢI THU</div><div class="fw-bold" style="font-size:24px;color:var(--color-primary)">45,000,000 đ</div></div></div></div><div class="card" id="checkout-tabs-container"></div>';

    var tabs = UITabs.create([
      { title: 'Bàn Tiệc & Dịch vụ', content: '<div class="p-4"><p>Đối chiếu Bàn và Dịch Vụ từ HĐ. Cho phép điều chỉnh giá.</p></div>' },
      { title: 'Thức uống', content: '<div class="p-4"><p>Nhập Số lượng thực tế sử dụng để tính phát sinh.</p></div>' },
      { title: 'Phát sinh (Khác)', content: '<div class="p-4"><p>Hạng mục phát sinh ngoài HĐ.</p></div>' },
      { title: 'Bảng Giảm Giá', content: '<div class="p-4"><p>Liệt kê giảm giá theo từng Dòng / Tab.</p></div>' }
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
