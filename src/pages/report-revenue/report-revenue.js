/**
 * Màn hình Báo cáo Doanh Thu Tiệc
 * HTML Template: src/pages/report-revenue.html
 */
var ReportRevenuePage = (function () {
  var $container;
  var revenueData = window.MockData ? window.MockData.demoRevenue : [];
  var charts = {};

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
      { id: 'f-from', label: 'Từ ngày', type: 'date' },
      { id: 'f-to', label: 'Đến ngày', type: 'date' }
    ], function(values) {
      if (values['f-from'] && values['f-to']) {
        var d1 = new Date(values['f-from']);
        var d2 = new Date(values['f-to']);
        revenueData = [];
        for (var d = new Date(d1); d <= d2; d.setDate(d.getDate() + 1)) {
          var dateStr = d.getDate().toString().padStart(2, '0') + '/' + (d.getMonth() + 1).toString().padStart(2, '0');
          var rev = Math.floor(Math.random() * 200000000) + 50000000;
          var count = Math.floor(Math.random() * 5) + 1;
          revenueData.push({ month: dateStr, revenue: rev, count: count });
        }
        var chartTitle = $container.querySelector('#chart-title');
        if (chartTitle) chartTitle.innerText = 'Biểu đồ Doanh thu từ ' + d1.toLocaleDateString('vi-VN') + ' đến ' + d2.toLocaleDateString('vi-VN');
      } else {
        revenueData = window.MockData ? window.MockData.demoRevenue : [];
        var chartTitle = $container.querySelector('#chart-title');
        if (chartTitle) chartTitle.innerText = 'Biểu đồ Doanh thu';
      }
      _renderChartTabs();
      _renderTable();
      Alert.success('Đã làm mới dữ liệu!');
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
      { id: 'tab-bar', title: 'Biểu đồ Cột', content: '<div class="p-3" style="height: 380px; position: relative;"><canvas id="revenue-chart-bar"></canvas></div>' },
      { id: 'tab-line', title: 'Biểu đồ Đường', content: '<div class="p-3" style="height: 380px; position: relative;"><canvas id="revenue-chart-line"></canvas></div>' }
    ]);

    wrapper.innerHTML = '';
    wrapper.appendChild(tabsEl);
    if (charts['bar']) charts['bar'].destroy();
    if (charts['line']) charts['line'].destroy();
    charts['bar'] = _initChart('revenue-chart-bar', 'bar');
    charts['line'] = _initChart('revenue-chart-line', 'line');
  }

  function _initChart(canvasId, type) {
    var ctx = $container.querySelector('#' + canvasId).getContext('2d');
    var labels = revenueData.map(function(item) { return item.month; });
    var data = revenueData.map(function(item) { return item.revenue; });

    var rootStyles = getComputedStyle(document.documentElement);
    var primaryColor = rootStyles.getPropertyValue('--color-primary').trim() || '#4F46E5';
    var primaryLight = rootStyles.getPropertyValue('--color-primary-light').trim() || 'rgba(79, 70, 229, 0.1)';

        var textColor = rootStyles.getPropertyValue('--color-text-secondary').trim() || '#64748B';
    var gridColor = rootStyles.getPropertyValue('--color-border').trim() || '#E2E8F0';

    return new Chart(ctx, {
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
        maintainAspectRatio: false,
        animation: {
          y: {
            duration: 1200,
            easing: 'easeOutQuart',
            from: 1000
          }
        },
        plugins: { legend: { display: false } },
        scales: {
          x: {
            ticks: { color: textColor },
            grid: { color: gridColor, drawBorder: false }
          },
          y: {
            beginAtZero: true,
            ticks: {
              color: textColor,
              callback: function(value) { return (value / 1000000) + ' Tr'; }
            },
            grid: { color: gridColor, drawBorder: false }
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
      var csvContent = "data:text/csv;charset=utf-8,\\uFEFF";
      csvContent += "Thời gian,Số lượng tiệc,Doanh thu (VNĐ)\\n";
      revenueData.forEach(function(item) {
        csvContent += item.month + "," + item.count + "," + item.revenue + "\\n";
      });
      var encodedUri = encodeURI(csvContent);
      var link = document.createElement("a");
      link.setAttribute("href", encodedUri);
      link.setAttribute("download", "Bao_Cao_Doanh_Thu.csv");
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      Alert.success('Đã xuất báo cáo ra Excel (CSV) thành công!');
    });
  }

  return { render: render };
})();
