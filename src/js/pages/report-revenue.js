/**
 * Màn hình Báo cáo Doanh Thu Tiệc
 */
var ReportRevenuePage = (function () {
  var $container;

  // Mock data
  var revenueData = window.MockData ? window.MockData.demoRevenue : [];
  var chartInstance = null;

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div class="page-title-bar">
        <span>Báo cáo Doanh Thu Tiệc</span>
      </div>

      <!-- THANH CÔNG CỤ -->
      <div class="button-bar mb-4" style="animation: slideUp 0.3s ease forwards;">
        <button class="btn btn-tool" id="btn-export"><span class="material-symbols-outlined">download</span>Xuất Excel</button>
        <button class="btn btn-tool" id="btn-print"><span class="material-symbols-outlined">print</span>In Báo Cáo</button>
      </div>

      <!-- BỘ LỌC -->
      <div id="filter-wrapper" class="mb-4" style="animation: slideUp 0.4s ease forwards;"></div>

      <div class="stats-grid mb-4" style="animation: slideUp 0.5s ease forwards;">
        <!-- BIỂU ĐỒ -->
        <div class="card" style="grid-column: span 2;">
          <div class="card-header">
            <span>Biểu đồ Doanh thu các tháng</span>
          </div>
          <div class="card-body" id="chart-tabs-wrapper" style="padding: 0;">
            <!-- TABS SẼ RENDER Ở ĐÂY -->
          </div>
        </div>
      </div>

      <!-- BẢNG DỮ LIỆU -->
      <div class="card" style="animation: slideUp 0.6s ease forwards;">
        <div class="card-header">
          <span>Chi tiết Doanh thu theo tháng</span>
        </div>
        <div class="table-wrapper">
          <table class="data-table" id="revenue-table">
            <thead>
              <tr>
                <th style="width: 80px; text-align: center;">Tháng</th>
                <th style="text-align: center;">Số lượng Tiệc</th>
                <th style="text-align: right;">Tổng Doanh Thu (VNĐ)</th>
              </tr>
            </thead>
            <tbody>
              <!-- RENDER BỞI JS -->
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- TOTAL BAR -->
      <div id="total-bar-wrapper"></div>
    `;

    $container.innerHTML = html;

    _renderFilter();
    _renderChartTabs();
    _renderTable();
    _bindEvents();
  }

  function _renderFilter() {
    var filterContainer = $container.querySelector('#filter-wrapper');
    var filterEl = FilterComponent.create([
      { id: 'f-from', label: 'Từ tháng', type: 'month' },
      { id: 'f-to', label: 'Đến tháng', type: 'month' }
    ], function(values) {
      // Mock logic: Nếu lọc, reload lại chart giả
      console.log('Đang lọc dữ liệu:', values);
      Alert.success('Đã làm mới dữ liệu biểu đồ!');
    });
    
    // Thêm card style cho filter để đồng bộ UI
    var cardFilter = document.createElement('div');
    cardFilter.className = 'card';
    var cardBody = document.createElement('div');
    cardBody.className = 'card-body';
    cardBody.appendChild(filterEl);
    cardFilter.appendChild(cardBody);

    filterContainer.appendChild(cardFilter);
  }

  function _renderChartTabs() {
    var wrapper = $container.querySelector('#chart-tabs-wrapper');
    
    // Khởi tạo Tabs component
    var tabsEl = UITabs.create([
      { id: 'tab-bar', title: 'Biểu đồ Cột', content: '<div style="padding:20px;"><canvas id="revenue-chart-bar" height="80"></canvas></div>' },
      { id: 'tab-line', title: 'Biểu đồ Đường', content: '<div style="padding:20px;"><canvas id="revenue-chart-line" height="80"></canvas></div>' }
    ]);
    
    wrapper.appendChild(tabsEl);

    // Khởi tạo cả 2 biểu đồ
    _initChart('revenue-chart-bar', 'bar');
    _initChart('revenue-chart-line', 'line');
  }

  function _initChart(canvasId, type) {
    var ctx = $container.querySelector('#' + canvasId).getContext('2d');
    var labels = revenueData.map(function(item) { return item.month; });
    var data = revenueData.map(function(item) { return item.revenue; });

    // Lấy màu động từ CSS variables (Design Tokens) để không bị hard code
    var rootStyles = getComputedStyle(document.documentElement);
    var primaryColor = rootStyles.getPropertyValue('--color-primary').trim() || '#4F46E5';
    var primaryLight = rootStyles.getPropertyValue('--color-primary-light').trim() || 'rgba(79, 70, 229, 0.1)';

    new Chart(ctx, {
      type: type,
      data: {
        labels: labels,
        datasets: [{
          label: 'Doanh thu (VNĐ)',
          data: data,
          backgroundColor: type === 'line' ? primaryLight : primaryColor,
          borderColor: primaryColor,
          borderWidth: type === 'line' ? 2 : 0,
          fill: type === 'line',
          tension: 0.4,
          borderRadius: type === 'bar' ? 4 : 0
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: { display: false }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) {
                return (value / 1000000) + ' Tr';
              }
            }
          }
        }
      }
    });
  }

  function _renderTable() {
    var tbody = $container.querySelector('#revenue-table tbody');
    tbody.innerHTML = '';
    
    var totalRev = 0;
    var totalCount = 0;

    revenueData.forEach(function(item) {
      totalRev += item.revenue;
      totalCount += item.count;

      var tr = document.createElement('tr');
      tr.innerHTML = `
        <td style="text-align: center; font-weight: 500;">${item.month}</td>
        <td style="text-align: center;">${item.count} tiệc</td>
        <td style="text-align: right; color: var(--color-primary); font-weight: 500;">${item.revenue.toLocaleString('vi-VN')}</td>
      `;
      tbody.appendChild(tr);
    });

    // Render Total Bar
    var totalBarContainer = $container.querySelector('#total-bar-wrapper');
    if (window.TotalBar) {
      var totalBar = new TotalBar({ container: totalBarContainer });
      totalBar.addTotal('Tổng số tiệc', totalCount);
      totalBar.addTotal('TỔNG DOANH THU', totalRev.toLocaleString('vi-VN') + ' VNĐ', true);
    }
  }

  function _bindEvents() {
    $container.querySelector('#btn-print').addEventListener('click', function() {
      window.print();
    });

    $container.querySelector('#btn-export').addEventListener('click', function() {
      // Mock Action
      Alert.success('Đã xuất báo cáo ra Excel (Mock)');
      console.log('Xuất Excel Triggered');
    });
  }

  return { render: render };
})();
