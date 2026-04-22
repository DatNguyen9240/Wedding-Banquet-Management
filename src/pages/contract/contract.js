/**
 * Màn hình Quản lý Hợp Đồng (Contract)
 * HTML Template: src/pages/contract.html
 */
var ContractPage = (function () {
  var $container;
  var contractData = [
    { id: 'HDT-260101', customerName: 'Trương Tuấn Anh & Trần Thủy Tiên', eventDate: '15/11/2026', totalTables: 30, totalAmount: '120,500,000', status: 'Đã Ký' },
    { id: 'HDT-260105', customerName: 'Phạm Minh Phát & Lê Mai', eventDate: '22/11/2026', totalTables: 25, totalAmount: '95,000,000', status: 'Đã Quyết Toán' }
  ];

  function render(containerElement) {
    $container = containerElement;
    fetch('./src/pages/contract/contract.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderTable();
        _bindEvents();
      });
  }

  function _renderTable() {
    var tbody = $container.querySelector('#contract-table tbody');
    tbody.innerHTML = '';
    contractData.forEach((row, idx) => {
      var statusClass = row.status.includes('Ký') ? 'status-badge primary' : 'status-badge secondary';
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
    $container.querySelector('#btn-add-contract').addEventListener('click', function() { _showDetailView(true); });
    $container.querySelector('#btn-edit-contract').addEventListener('click', function() { _showDetailView(false); });
  }

  function _showDetailView(isNew) {
    document.getElementById('contract-list-view').style.display = 'none';
    var dv = document.getElementById('contract-detail-view');
    dv.style.display = 'block';
    dv.style.animation = 'slideUp 0.3s ease forwards';
    dv.innerHTML = '<div class="page-title-bar d-flex justify-content-between align-items-center"><div class="d-flex align-items-center gap-2"><button class="btn btn-secondary" onclick="ContractPage.closeDetail()" style="padding:6px 12px;border-radius:8px;"><span class="material-symbols-outlined" style="font-size:20px;">arrow_back</span> Trở về</button><span>' + (isNew ? 'Lập Hợp Đồng Tiệc Mới' : 'Chi Tiết Hợp Đồng HDT-260101') + '</span></div><div class="button-bar" style="margin-bottom:0;background:transparent;padding:0;border:none;box-shadow:none;"><button class="btn btn-primary" onclick="UIToast.show(\'Đã lưu Hợp đồng thành công\')"><span class="material-symbols-outlined">save</span> Lưu Hợp Đồng</button></div></div><div class="card mb-4" style="padding:16px 24px;background:linear-gradient(to right,#F8FAFC,#EFF6FF);border-left:4px solid var(--color-primary);"><div class="row g-4"><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Tên Khách Hàng</label><div class="fw-semibold" style="font-size:16px;">Trương Tuấn Anh & Trần Thủy Tiên</div></div><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Ngày Tổ Chức</label><div class="fw-semibold" style="font-size:16px;color:var(--color-primary)">15/11/2026</div></div><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Số Bàn</label><div class="fw-semibold" style="font-size:16px;">30 Bàn Mặn / 0 Chay</div></div><div class="col-md-3"><label class="d-block mb-1" style="font-size:13px;color:var(--color-text-secondary);">Sảnh Chính</label><div class="fw-semibold" style="font-size:16px;">Sảnh Kim Cương</div></div></div></div><div class="card" id="contract-tabs-container"></div>';

    var tabs = UITabs.create([
      { title: 'Bàn Tiệc', content: '<div class="p-4"><p>Giao diện chọn Gói Ưu Đãi và thiết lập Giá bàn.</p></div>' },
      { title: 'Thực đơn Mặn', content: '<div class="p-4"><p>Danh sách các món từ Gói Combo hoặc chọn lẻ.</p></div>' },
      { title: 'Thực đơn Chay', content: '<div class="p-4"><p>Tương tự thực đơn mặn, thêm tính Theo bàn/Phần.</p></div>' },
      { title: 'Thức uống', content: '<div class="p-4"><p>Danh sách thức uống kèm Gói KM hoặc phí lẻ.</p></div>' },
      { title: 'Dịch vụ & Ưu đãi', content: '<div class="p-4"><p>Dịch vụ phát sinh và ưu đãi từ Gói.</p></div>' },
      { title: 'Ghi chú & Pháp lý', content: '<div class="p-4"><p>Điều khoản bổ sung in vào hợp đồng giấy.</p></div>' }
    ]);
    document.getElementById('contract-tabs-container').appendChild(tabs);
  }

  function closeDetail() {
    document.getElementById('contract-detail-view').style.display = 'none';
    document.getElementById('contract-detail-view').innerHTML = '';
    document.getElementById('contract-list-view').style.display = 'block';
  }

  return { render: render, closeDetail: closeDetail };
})();
