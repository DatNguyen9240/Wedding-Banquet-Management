/**
 * Màn hình Biên nhận Cọc chỗ (Booking)
 * Xử lý luồng IV.3 đến IV.6 trong REQUIREMENT.md
 */
var BookingPage = (function () {
  var $container;

  // Mock data cho danh sách Biên nhận cọc chỗ
  var bookingData = [
    { id: 'BNCC-260101', customerName: 'Trương Tuấn Anh & Trần Thủy Tiên', phone: '0901234567', eventDate: '15/11/2026', totalTables: 30, hall: 'Sảnh Kim Cương (Chính)', deposit: '20,000,000', status: 'Đã cọc lần 1' },
    { id: 'BNCC-260102', customerName: 'Lê Mai Hoa & Nguyễn Văn Toàn', phone: '0987654321', eventDate: '20/11/2026', totalTables: 45, hall: 'Sảnh Ngọc Trai (Chính)', deposit: '50,000,000', status: 'Đã cọc lần 2' }
  ];

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div class="page-title-bar">
        <span>Quản lý Biên nhận Cọc chỗ</span>
      </div>

      <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
        <button class="btn btn-tool" id="btn-add-deposit1"><span class="material-symbols-outlined">add_circle</span>Thêm Cọc Lần 1</button>
        <button class="btn btn-tool" id="btn-edit-deposit"><span class="material-symbols-outlined">edit</span>Thay đổi Cọc</button>
        <button class="btn btn-tool" id="btn-add-deposit2"><span class="material-symbols-outlined">payments</span>Tiếp nhận Cọc Lần 2</button>
        <div class="divider"></div>
        <button class="btn btn-tool text-danger" id="btn-delete"><span class="material-symbols-outlined">delete</span>Hủy Cọc</button>
        <button class="btn btn-tool" id="btn-print"><span class="material-symbols-outlined">print</span>In Biên nhận</button>
      </div>

      <div class="card" style="animation: slideUp 0.4s ease forwards;">
        <div class="table-wrapper" style="overflow-x: auto; width: 100%;">
          <table class="data-table selectable" id="booking-table">
            <thead>
              <tr>
                <th style="width: 50px; text-align: center;">STT</th>
                <th>Số Phiếu</th>
                <th>Tên Khách Hàng (Cặp Đôi)</th>
                <th>Điện Thoại</th>
                <th>Ngày Tổ Chức</th>
                <th>Số Bàn</th>
                <th>Sảnh Đặt</th>
                <th style="text-align: right;">Đã Cọc (VNĐ)</th>
                <th style="text-align: center;">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <!-- Render by JS -->
            </tbody>
          </table>
        </div>
      </div>
    `;

    $container.innerHTML = html;
    _renderTable();
    _bindEvents();
  }

  function _renderTable() {
    var tbody = $container.querySelector('#booking-table tbody');
    tbody.innerHTML = '';

    bookingData.forEach((row, idx) => {
      var statusClass = row.status.includes('lần 1') ? 'status-badge warning' : 'status-badge success';
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td style="text-align: center;">${idx + 1}</td>
        <td style="font-weight: 600; color: var(--color-primary);">${row.id}</td>
        <td style="font-weight: 500;">${row.customerName}</td>
        <td>${row.phone}</td>
        <td><span style="background:#F1F5F9; padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.eventDate}</span></td>
        <td style="text-align:right;">${row.totalTables} bàn</td>
        <td>${row.hall}</td>
        <td style="text-align: right; font-weight:600; color: var(--color-success);">${row.deposit}</td>
        <td style="text-align: center;"><span class="${statusClass}">${row.status}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-add-deposit1').addEventListener('click', function() {
      UIToast.show('Mở form Nhập Biên nhận Cọc Lần 1...');
    });
    $container.querySelector('#btn-edit-deposit').addEventListener('click', function() {
      UIToast.show('Mở form Thay đổi Biên nhận Cọc...');
    });
    $container.querySelector('#btn-add-deposit2').addEventListener('click', function() {
      UIToast.show('Mở form Bổ sung Cọc Lần 2...');
    });
  }

  return { render: render };
})();
