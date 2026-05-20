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

    // ── Tab 1: Thống kê Sales ────────────────────────────────────────────
    var tabContent1 = document.createElement('div');
    tabContent1.innerHTML = `
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

    // ── Tab 2: Biểu đồ Khảo sát — dùng UIChart component ────────────────
    // Lấy màu từ Design Tokens
    var rs = getComputedStyle(document.documentElement);
    var cPrimary = rs.getPropertyValue('--color-primary').trim() || '#4F46E5';
    var cSuccess = rs.getPropertyValue('--color-success').trim() || '#10B981';
    var cWarning = rs.getPropertyValue('--color-warning').trim() || '#F59E0B';
    var cDanger  = rs.getPropertyValue('--color-danger').trim()  || '#F43F5E';
    var cInfo    = rs.getPropertyValue('--color-info').trim()    || '#0EA5E9';

    var makeChartData = function(dataArray, colors) {
      return {
        labels: dataArray.map(function(d) { return d.label; }),
        datasets: [{ data: dataArray.map(function(d) { return d.value; }), backgroundColor: colors }]
      };
    };

    var chartFactors = UIChart.create({
      title: 'Yếu tố quyết định đặt tiệc',
      type: 'pie',
      data: makeChartData(factorsData, [cPrimary, cSuccess, cWarning, cInfo, cDanger]),
      options: { plugins: { legend: { position: 'bottom' } } }
    });

    var chartChannels = UIChart.create({
      title: 'Kênh thông tin tiếp cận',
      type: 'pie',
      data: makeChartData(channelsData, [cWarning, cSuccess, cPrimary, cDanger]),
      options: { plugins: { legend: { position: 'bottom' } } }
    });

    var tabContent2 = document.createElement('div');
    tabContent2.className = 'row g-4 p-3';

    var col1 = document.createElement('div');
    col1.className = 'col-md-6';
    col1.appendChild(chartFactors);

    var col2 = document.createElement('div');
    col2.className = 'col-md-6';
    col2.appendChild(chartChannels);

    tabContent2.appendChild(col1);
    tabContent2.appendChild(col2);

    // ── Tạo UITabs với DOM element content ───────────────────────────────
    var tabsEl = UITabs.create([
      { id: 'tab-stats',   title: 'Thống kê (Cọc/Tiệc)',        content: tabContent1 },
      { id: 'tab-surveys', title: 'Khảo sát (Kênh/Yếu tố)',    content: tabContent2 }
    ]);

    wrapper.appendChild(tabsEl);
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
