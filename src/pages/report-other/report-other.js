/**
 * Màn hình Báo cáo Quản lý Khác (Khảo sát, Thống kê)
 * HTML Template: src/pages/report-other.html
 */
var ReportOtherPage = (function () {
  var $container;
  var factorsData = window.MockData ? window.MockData.demoSurveyFactors : [];
  var channelsData = window.MockData ? window.MockData.demoSurveyChannels : [];

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/report-other/report-other.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderFilter();
        _renderTabs();
        _bindEvents();
      })
      .catch(function(err) {
        $container.innerHTML = '<div class="card"><div class="card-body text-danger">Lỗi tải template: ' + err.message + '</div></div>';
      });
  }

  function _renderFilter() {
    var filterContainer = $container.querySelector('#filter-wrapper-other');
    var filterEl = FilterComponent.create([
      { id: 'fo-year', label: 'Năm', type: 'number', placeholder: 'Năm...' }
    ], function(values) {
      Alert.success('Đã tải lại báo cáo!');
    });

    var cardFilter = document.createElement('div');
    cardFilter.className = 'card';
    var cardBody = document.createElement('div');
    cardBody.className = 'card-body';
    cardBody.appendChild(filterEl);
    cardFilter.appendChild(cardBody);
    filterContainer.appendChild(cardFilter);
  }

  function _renderTabs() {
    var wrapper = $container.querySelector('#tabs-wrapper-other');

    // Tab 1: Thống kê Sales
    var tabContent1 = `
      <div class="card mb-4">
        <div class="card-header">Lũy kế nhận tiệc trong năm theo Sales</div>
        <div class="table-wrapper">
          <table class="data-table">
            <thead>
              <tr>
                <th>Nhân viên Sales</th>
                <th class="text-center">Số lượng Bàn</th>
                <th class="text-end">Doanh thu ước tính</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>Trương Du Kỳ</td><td class="text-center">150</td><td class="text-end">650,000,000</td></tr>
              <tr><td>Triệu Minh</td><td class="text-center">85</td><td class="text-end">320,000,000</td></tr>
              <tr><td>Châu Chỉ Nhược</td><td class="text-center">210</td><td class="text-end">945,000,000</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    `;

    // Tab 2: Khảo sát - Dùng Bootstrap row/col chia đôi biểu đồ
    var tabContent2 = `
      <div class="row g-4 p-3">
        <div class="col-md-6">
          <div class="card">
            <div class="card-header">Yếu tố quyết định đặt tiệc</div>
            <div class="card-body d-flex justify-content-center">
              <canvas id="chart-factors" width="300" height="300"></canvas>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card">
            <div class="card-header">Kênh thông tin tiếp cận</div>
            <div class="card-body d-flex justify-content-center">
              <canvas id="chart-channels" width="300" height="300"></canvas>
            </div>
          </div>
        </div>
      </div>
    `;

    var tabsEl = UITabs.create([
      { id: 'tab-stats', title: 'Thống kê (Cọc/Tiệc)', content: tabContent1 },
      { id: 'tab-surveys', title: 'Khảo sát (Kênh/Yếu tố)', content: tabContent2 }
    ]);

    wrapper.appendChild(tabsEl);

    // Lấy hệ màu động từ Design Tokens
    var rootStyles = getComputedStyle(document.documentElement);
    var cPrimary = rootStyles.getPropertyValue('--color-primary').trim() || '#4F46E5';
    var cSuccess = rootStyles.getPropertyValue('--color-success').trim() || '#10B981';
    var cWarning = rootStyles.getPropertyValue('--color-warning').trim() || '#F59E0B';
    var cDanger  = rootStyles.getPropertyValue('--color-danger').trim() || '#F43F5E';
    var cInfo    = rootStyles.getPropertyValue('--color-info').trim() || '#0EA5E9';

    _renderPieChart('chart-factors', factorsData, [cPrimary, cSuccess, cWarning, cInfo, cDanger]);
    _renderPieChart('chart-channels', channelsData, [cWarning, cSuccess, cPrimary, cDanger]);
  }

  function _renderPieChart(canvasId, dataArray, colors) {
    var ctx = document.getElementById(canvasId);
    if (!ctx) return;

    var labels = dataArray.map(function(d) { return d.label; });
    var values = dataArray.map(function(d) { return d.value; });

    new Chart(ctx.getContext('2d'), {
      type: 'pie',
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: colors
        }]
      },
      options: {
        responsive: false,
        plugins: { legend: { position: 'bottom' } }
      }
    });
  }

  function _bindEvents() {
    $container.querySelector('#btn-print-other').addEventListener('click', function() {
      window.print();
    });

    $container.querySelector('#btn-export-other').addEventListener('click', function() {
      Alert.success('Đã xuất báo cáo ra Excel (Mock)');
    });
  }

  return { render: render };
})();
