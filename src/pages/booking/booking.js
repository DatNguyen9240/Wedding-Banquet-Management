/**
 * Màn hình Biên nhận Cọc chỗ (Booking)
 * HTML Template: src/pages/booking.html
 */
var BookingPage = (function () {
  var $container;

  var bookingData = [
    { id: 'BNCC-260101', customerName: 'Trương Tuấn Anh & Trần Thủy Tiên', phone: '0901234567', eventDate: '15/11/2026', totalTables: 30, hall: 'Sảnh Kim Cương (Chính)', deposit: '20,000,000', status: 'Đã cọc lần 1' },
    { id: 'BNCC-260102', customerName: 'Lê Mai Hoa & Nguyễn Văn Toàn', phone: '0987654321', eventDate: '20/11/2026', totalTables: 45, hall: 'Sảnh Ngọc Trai (Chính)', deposit: '50,000,000', status: 'Đã cọc lần 2' }
  ];

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/booking/booking.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderTable();
        _bindEvents();
      });
  }

  function _renderTable() {
    var tbody = $container.querySelector('#booking-table tbody');
    tbody.innerHTML = '';

    bookingData.forEach((row, idx) => {
      var statusClass = row.status.includes('lần 1') ? 'status-badge warning' : 'status-badge success';
      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-semibold" style="color: var(--color-primary);">${row.id}</td>
        <td class="fw-medium">${row.customerName}</td>
        <td>${row.phone}</td>
        <td><span style="background: rgba(148, 163, 184, 0.1); padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.eventDate}</span></td>
        <td class="text-end">${row.totalTables} bàn</td>
        <td>${row.hall}</td>
        <td class="text-end fw-semibold" style="color: var(--color-success);">${row.deposit}</td>
        <td class="text-center"><span class="${statusClass}">${row.status}</span></td>
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
