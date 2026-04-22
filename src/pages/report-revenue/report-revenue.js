/**
 * Màn hình Báo cáo Doanh Thu Tiệc
 * HTML Template: src/pages/report-revenue.html
 */
var ReportRevenuePage = (function () {
  var $container;
  var revenueData = window.MockData ? window.MockData.demoRevenue : [];

  function render(containerElement) {
    $container = containerElement;

    // Load HTML template rồi mới init logic
    fetch('./src/pages/report-revenue/report-revenue.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderFilter();
        _renderChartTabs();
        _renderTable();
        _bindEvents();
      })
      .catch(function(err) {
        $container.innerHTML = '<div class="card"><div class="card-body text-danger">Lỗi tải template: ' + err.message + '</div></div>';
      });
  }

  function _renderFilter() {
    var filterContainer = $container.querySelector('#filter-wrapper');
    var filterEl = FilterComponent.create([
      { id: 'f-from', label: 'Từ tháng', type: 'month' },
      { id: 'f-to', label: 'Đến tháng', type: 'month' }
    ], function(values) {
      console.log('Đang lọc dữ liệu:', values);
      Alert.success('Đã làm mới dữ liệu biểu đồ!');
    });

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

    var tabsEl = UITabs.create([
      { id: 'tab-bar', title: 'Biểu đồ Cột', content: '<div class="p-3"><canvas id="revenue-chart-bar" height="80"></canvas></div>' },
      { id: 'tab-line', title: 'Biểu đồ Đường', content: '<div class="p-3"><canvas id="revenue-chart-line" height="80"></canvas></div>' }
    ]);

    wrapper.appendChild(tabsEl);
    _initChart('revenue-chart-bar', 'bar');
    _initChart('revenue-chart-line', 'line');
  }

  function _initChart(canvasId, type) {
    var ctx = $container.querySelector('#' + canvasId).getContext('2d');
    var labels = revenueData.map(function(item) { return item.month; });
    var data = revenueData.map(function(item) { return item.revenue; });

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
        plugins: { legend: { display: false } },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              callback: function(value) { return (value / 1000000) + ' Tr'; }
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
        <td class="text-center fw-medium">${item.month}</td>
        <td class="text-center">${item.count} tiệc</td>
        <td class="text-end fw-medium" style="color: var(--color-primary);">${item.revenue.toLocaleString('vi-VN')}</td>
      `;
      tbody.appendChild(tr);
    });

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
      Alert.success('Đã xuất báo cáo ra Excel (Mock)');
    });
  }

  return { render: render };
})();
