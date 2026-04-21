/**
 * Màn hình Quản lý Hợp Đồng (Contract)
 * Xử lý luồng IV.7
 */
var ContractPage = (function () {
  var $container;

  // Mock data cho danh sách Hợp đồng
  var contractData = [
    { id: 'HDT-260101', customerName: 'Trương Tuấn Anh & Trần Thủy Tiên', eventDate: '15/11/2026', totalTables: 30, totalAmount: '120,500,000', status: 'Đã Ký' },
    { id: 'HDT-260105', customerName: 'Phạm Minh Phát & Lê Mai', eventDate: '22/11/2026', totalTables: 25, totalAmount: '95,000,000', status: 'Đã Quyết Toán' }
  ];

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div id="contract-list-view">
        <div class="page-title-bar">
          <span>Quản lý Hợp Đồng Tiệc</span>
        </div>

        <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
          <button class="btn btn-tool" id="btn-add-contract"><span class="material-symbols-outlined">add_circle</span>Lập Hợp Đồng Mới</button>
          <button class="btn btn-tool" id="btn-edit-contract"><span class="material-symbols-outlined">edit</span>Xem / Sửa</button>
          <div class="divider"></div>
          <button class="btn btn-tool text-danger" id="btn-delete"><span class="material-symbols-outlined">delete</span>Thanh Lý Hủy</button>
          <button class="btn btn-tool" id="btn-print"><span class="material-symbols-outlined">print</span>In Hợp Đồng</button>
        </div>

        <div class="card" style="animation: slideUp 0.4s ease forwards;">
          <div class="table-wrapper" style="overflow-x: auto; width: 100%;">
            <table class="data-table selectable" id="contract-table">
              <thead>
                <tr>
                  <th style="width: 50px; text-align: center;">STT</th>
                  <th>Số Hợp Đồng</th>
                  <th>Tên Khách Hàng (Cặp Đôi)</th>
                  <th>Ngày Tổ Chức</th>
                  <th>Số Bàn</th>
                  <th style="text-align: right;">Tổng Tiền (Dự Kiến)</th>
                  <th style="text-align: center;">Trạng thái</th>
                </tr>
              </thead>
              <tbody>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div id="contract-detail-view" style="display: none;"></div>
    `;

    $container.innerHTML = html;
    _renderTable();
    _bindEvents();
  }

  function _renderTable() {
    var tbody = $container.querySelector('#contract-table tbody');
    tbody.innerHTML = '';

    contractData.forEach((row, idx) => {
      var statusClass = row.status.includes('Ký') ? 'status-badge primary' : 'status-badge secondary';
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
    $container.querySelector('#btn-add-contract').addEventListener('click', function() {
      _showDetailView(true);
    });
    $container.querySelector('#btn-edit-contract').addEventListener('click', function() {
      _showDetailView(false);
    });
  }

  function _showDetailView(isNew) {
    document.getElementById('contract-list-view').style.display = 'none';
    var detailView = document.getElementById('contract-detail-view');
    detailView.style.display = 'block';
    detailView.style.animation = 'slideUp 0.3s ease forwards';

    detailView.innerHTML = `
      <div class="page-title-bar" style="justify-content: space-between;">
        <div style="display:flex; align-items:center; gap: 12px;">
          <button class="btn btn-secondary" onclick="ContractPage.closeDetail()" style="padding: 6px 12px; border-radius: 8px;">
            <span class="material-symbols-outlined" style="font-size: 20px;">arrow_back</span> Trở về
          </button>
          <span>${isNew ? 'Lập Hợp Đồng Tiệc Mới' : 'Chi Tiết Hợp Đồng HDT-260101'}</span>
        </div>
        <div class="button-bar" style="margin-bottom:0; background:transparent; padding:0; border:none; box-shadow:none;">
          <button class="btn btn-primary" onclick="UIToast.show('Đã lưu Hợp đồng thành công')"><span class="material-symbols-outlined">save</span> Lưu Hợp Đồng</button>
        </div>
      </div>
      
      <!-- Basic Info Header -->
      <div class="card mb-4" style="padding: 16px 24px; background: linear-gradient(to right, #F8FAFC, #EFF6FF); border-left: 4px solid var(--color-primary); display:flex; justify-content:space-between; align-items:center;">
         <div style="display:flex; gap: 48px; flex-wrap: wrap;">
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Tên Khách Hàng</label>
               <div style="font-weight:600; font-size:16px;">Trương Tuấn Anh & Trần Thủy Tiên</div>
            </div>
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Ngày Tổ Chức</label>
               <div style="font-weight:600; font-size:16px; color:var(--color-primary)">15/11/2026 (Nhằm 06/10 Âm lịch)</div>
            </div>
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Số Bàn Mặn/Chay</label>
               <div style="font-weight:600; font-size:16px;">30 Bàn Mặn / 0 Bàn Chay</div>
            </div>
            <div>
               <label style="font-size:13px; color:var(--color-text-secondary); margin-bottom:4px; display:block;">Sảnh Chính</label>
               <div style="font-weight:600; font-size:16px;">Sảnh Kim Cương</div>
            </div>
         </div>
      </div>

      <div class="card" id="contract-tabs-container"></div>
    `;

    var tabs = UITabs.create([
      { title: 'Bàn Tiệc', content: '<div style="padding:24px"><p>Giao diện chọn Gói Ưu Đãi (Combo) và thiết lập Giá bàn.</p></div>' },
      { title: 'Thực đơn Mặn', content: '<div style="padding:24px"><p>Danh sách các món rước từ Gói Combo hoặc chọn lẻ. Đánh dấu món Khai vị. Tính thành tiền.</p></div>' },
      { title: 'Thực đơn Chay', content: '<div style="padding:24px"><p>Tương tự thực đơn mặn nhưng thêm Lựa chọn: Tính Theo bàn hay Theo Phần.</p></div>' },
      { title: 'Thức uống', content: '<div style="padding:24px"><p>Danh sách thức uống. Đánh dấu có kèm theo Gói khuyến mãi hay tính phí lẻ.</p></div>' },
      { title: 'Dịch vụ & Ưu đãi', content: '<div style="padding:24px"><p>Các dịch vụ phát sinh (MC, Vũ đoàn...) và ưu đãi hệ thống tự sinh từ Gói.</p></div>' },
      { title: 'Ghi chú & Pháp lý', content: '<div style="padding:24px"><p>Điều khoản bổ sung in trực tiếp vào 1 mặt hợp đồng giấy.</p></div>' }
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
