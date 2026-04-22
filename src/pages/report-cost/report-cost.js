/**
 * Màn hình Báo cáo Chi phí Tiệc
 * HTML Template: src/pages/report-cost.html
 */
var ReportCostPage = (function () {
  var $container;
  var costData = window.MockData ? window.MockData.demoCost : [];

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/report-cost/report-cost.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderFilter();
        _renderTable();
        _bindEvents();
      })
      .catch(function(err) {
        $container.innerHTML = '<div class="card"><div class="card-body text-danger">Lỗi tải template: ' + err.message + '</div></div>';
      });
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
        <td class="fw-medium" style="color: var(--color-primary);">${item.id}</td>
        <td>${item.customer}</td>
        <td class="text-center">${item.date}</td>
        <td class="text-end">${item.foodCost.toLocaleString('vi-VN')}</td>
        <td class="text-end">${item.serviceCost.toLocaleString('vi-VN')}</td>
        <td class="text-end">${item.staffCost.toLocaleString('vi-VN')}</td>
        <td class="text-end fw-semibold" style="color: var(--color-danger);">${item.totalCost.toLocaleString('vi-VN')}</td>
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
