/**
 * Màn hình Báo cáo Chi phí Tiệc
 */
var ReportCostPage = (function () {
  var $container;

  // Mock data
  var costData = window.MockData ? window.MockData.demoCost : [];

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div class="page-title-bar">
        <span>Báo cáo Chi phí Tiệc</span>
      </div>

      <!-- THANH CÔNG CỤ -->
      <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
        <button class="btn btn-tool" id="btn-export-cost"><span class="material-symbols-outlined">download</span>Xuất Excel</button>
        <button class="btn btn-tool" id="btn-print-cost"><span class="material-symbols-outlined">print</span>In Báo Cáo</button>
      </div>

      <!-- BỘ LỌC -->
      <div id="filter-wrapper-cost" class="mb-4" style="animation: slideUp 0.4s ease forwards;"></div>

      <!-- BẢNG DỮ LIỆU -->
      <div class="card" style="animation: slideUp 0.5s ease forwards;">
        <div class="card-header">
          <span>Chi tiết Chi phí thực hiện Tiệc</span>
        </div>
        <div class="table-wrapper">
          <table class="data-table" id="cost-table">
            <thead>
              <tr>
                <th style="width: 100px;">Mã HĐ</th>
                <th>Khách hàng</th>
                <th style="width: 120px; text-align: center;">Ngày tổ chức</th>
                <th style="text-align: right;">Chi phí Thực đơn</th>
                <th style="text-align: right;">Chi phí Dịch vụ</th>
                <th style="text-align: right;">Chi phí Nhân sự</th>
                <th style="text-align: right;">Tổng Chi Phí</th>
              </tr>
            </thead>
            <tbody>
              <!-- RENDER BỞI JS -->
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- TOTAL BAR -->
      <div id="total-bar-wrapper-cost"></div>
    `;

    $container.innerHTML = html;

    _renderFilter();
    _renderTable();
    _bindEvents();
  }

  function _renderFilter() {
    var filterContainer = $container.querySelector('#filter-wrapper-cost');
    var filterEl = FilterComponent.create([
      { id: 'fc-from', label: 'Từ ngày', type: 'date' },
      { id: 'fc-to', label: 'Đến ngày', type: 'date' },
      { id: 'fc-code', label: 'Mã HĐ', type: 'text', placeholder: 'Nhập mã HĐ...' }
    ], function(values) {
      console.log('Đang lọc chi phí:', values);
      Alert.success('Đã tải lại báo cáo chi phí!');
    });
    
    var cardFilter = document.createElement('div');
    cardFilter.className = 'card';
    var cardBody = document.createElement('div');
    cardBody.className = 'card-body';
    cardBody.appendChild(filterEl);
    cardFilter.appendChild(cardBody);

    filterContainer.appendChild(cardFilter);
  }

  function _renderTable() {
    var tbody = $container.querySelector('#cost-table tbody');
    tbody.innerHTML = '';
    
    var sumFood = 0, sumService = 0, sumStaff = 0, sumTotal = 0;

    costData.forEach(function(item) {
      sumFood += item.foodCost;
      sumService += item.serviceCost;
      sumStaff += item.staffCost;
      sumTotal += item.totalCost;

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td style="font-weight: 500; color: var(--color-primary);">${item.id}</td>
        <td>${item.customer}</td>
        <td style="text-align: center;">${item.date}</td>
        <td style="text-align: right;">${item.foodCost.toLocaleString('vi-VN')}</td>
        <td style="text-align: right;">${item.serviceCost.toLocaleString('vi-VN')}</td>
        <td style="text-align: right;">${item.staffCost.toLocaleString('vi-VN')}</td>
        <td style="text-align: right; color: var(--color-danger); font-weight: 600;">${item.totalCost.toLocaleString('vi-VN')}</td>
      `;
      tbody.appendChild(tr);
    });

    var totalBarContainer = $container.querySelector('#total-bar-wrapper-cost');
    if (window.TotalBar) {
      var totalBar = new TotalBar({ container: totalBarContainer });
      totalBar.addTotal('Số lượng HĐ', costData.length);
      totalBar.addTotal('TỔNG CHI PHÍ', sumTotal.toLocaleString('vi-VN') + ' VNĐ', true);
    }
  }

  function _bindEvents() {
    $container.querySelector('#btn-print-cost').addEventListener('click', function() {
      window.print();
    });

    $container.querySelector('#btn-export-cost').addEventListener('click', function() {
      Alert.success('Đã xuất báo cáo chi phí ra Excel (Mock)');
    });
  }

  return { render: render };
})();
