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

  // Khai báo Object chung để quản lý bộ lọc dễ dàng dán vào các input Date/Search sau này
  var filterParams = {
    Keyword: "",
    TuNgay: "2020-01-01", // Tương lai sẽ cập nhật lấy từ Component DatePicker
    DenNgay: "2026-12-31"
  };

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/booking/booking.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _bindEvents();
        _loadData();
      });
  }

  function _loadData() {
    var tbody = $container.querySelector('#booking-table tbody');
    if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center py-4" style="color: var(--color-text-secondary);">Đang tải dữ liệu...</td></tr>';

    // Quản lý Data Model: Chuyển Object filterParams thành chuỗi JSON và mã hóa URL an toàn
    var payloadString = encodeURIComponent(JSON.stringify(filterParams));
    var endpoint = API_CONFIG.ENDPOINTS.BOOKING.LIST + '?q=' + payloadString;
    
    ApiClient.get(endpoint)
      .then(function(res) {
        if (res && res.records) {
          bookingData = res.records;
        } else if (res && res.data) {
          bookingData = res.data;
        } else if (Array.isArray(res)) {
          bookingData = res;
        } else {
          bookingData = [];
        }
        _renderTable();
      })
      .catch(function(err) {
        console.error('Lỗi Load:', err);
        if (tbody) tbody.innerHTML = '<tr><td colspan="9" class="text-center text-danger py-4">Lỗi kết nối API lấy danh sách cọc!</td></tr>';
      });
  }

  function _formatMoney(val) {
    if (typeof val === 'string' && val.includes(',')) return val + ' đ';
    var num = parseFloat(val);
    if (isNaN(num)) return '0 đ';
    return new Intl.NumberFormat('vi-VN').format(num) + ' đ';
  }

  function _renderTable() {
    var tbody = $container.querySelector('#booking-table tbody');
    tbody.innerHTML = '';

    bookingData.forEach((row, idx) => {
      // Dùng tên trường của Backend trả về (TrangThai), dự phòng status cũ
      var currentStatus = row.TrangThai || row.status || '';
      var statusClass = currentStatus.includes('lần 1') ? 'status-badge warning' : 
                        currentStatus.includes('Hủy') ? 'status-badge danger' : 'status-badge success';
      
      var hallName = row.SanhDat || row.hall;
      var hallHtml = hallName ? hallName : '<span style="color:var(--color-text-secondary);font-style:italic;">Chưa xác định</span>';

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-center">${idx + 1}</td>
        <td class="fw-semibold" style="color: var(--color-primary);">${row.MaChungTu || row.id}</td>
        <td class="fw-medium">${row.TenKhachHang || row.customerName}</td>
        <td>${row.DienThoai || row.phone}</td>
        <td><span style="background: rgba(148, 163, 184, 0.1); padding:2px 8px; border-radius:4px; font-weight:500; border:1px solid var(--color-border);">${row.NgayToChuc || row.eventDate}</span></td>
        <td class="text-end">${row.SoBan != null ? row.SoBan : row.totalTables} bàn</td>
        <td>${hallHtml}</td>
        <td class="text-end fw-semibold" style="color: var(--color-success);">${_formatMoney(row.DaCocVND != null ? row.DaCocVND : row.deposit)}</td>
        <td class="text-center"><span class="${statusClass}">${currentStatus}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-add-deposit1').addEventListener('click', function () {
      UIToast.show('Mở form Nhập Biên nhận Cọc Lần 1...');
    });
    $container.querySelector('#btn-edit-deposit').addEventListener('click', function () {
      UIToast.show('Mở form Thay đổi Biên nhận Cọc...');
    });
    $container.querySelector('#btn-add-deposit2').addEventListener('click', function () {
      UIToast.show('Mở form Bổ sung Cọc Lần 2...');
    });
  }

  return { render: render };
})();
