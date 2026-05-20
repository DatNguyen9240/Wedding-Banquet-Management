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
      var revData = window.MockData ? window.MockData.demoRevenue : [];
      var cData = window.MockData ? window.MockData.demoCost : [];
      
      // Calculate totals
      var totalRev = 0;
      var totalCount = 0;
      revData.forEach(function(item) {
        totalRev += item.revenue;
        totalCount += item.count;
      });
      
      var sumFood = 0, sumService = 0, sumStaff = 0, totalCost = 0;
      cData.forEach(function(item) {
        sumFood += item.foodCost;
        sumService += item.serviceCost;
        sumStaff += item.staffCost;
        totalCost += item.totalCost;
      });
      
      var profit = totalRev - totalCost;

      var html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">';
      html += '<head><meta charset="utf-8"></head><body style="font-family: Arial, sans-serif;">';
      
      html += '<h2 style="text-align: center; color: #4F46E5; font-size: 24px;">BÁO CÁO TỔNG HỢP DOANH THU & CHI PHÍ</h2>';
      html += '<p style="text-align: center; font-style: italic; color: #64748b;">(Xuất tự động từ hệ thống quản lý)</p><br>';

      // TỔNG QUAN LỢI NHUẬN
      html += '<table border="1" style="border-collapse: collapse; margin-bottom: 30px; width: 600px; border: 2px solid #000;">';
      html += '<thead><tr><th colspan="2" style="background-color: #F59E0B; color: white; padding: 15px; font-size: 18px;">TỔNG QUAN KẾT QUẢ KINH DOANH</th></tr></thead>';
      html += '<tbody>';
      html += '<tr><td style="padding: 12px; font-weight: bold; font-size: 16px;">Tổng Doanh Thu</td><td style="padding: 12px; text-align: right; color: #10B981; font-weight: bold; font-size: 16px;">' + totalRev.toLocaleString('vi-VN') + ' VNĐ</td></tr>';
      html += '<tr><td style="padding: 12px; font-weight: bold; font-size: 16px;">Tổng Chi Phí</td><td style="padding: 12px; text-align: right; color: #EF4444; font-weight: bold; font-size: 16px;">' + totalCost.toLocaleString('vi-VN') + ' VNĐ</td></tr>';
      html += '<tr><td style="padding: 15px; font-weight: bold; background-color: #f1f5f9; font-size: 18px;">LỢI NHUẬN TỊNH</td><td style="padding: 15px; text-align: right; color: #4F46E5; font-weight: bold; font-size: 18px; background-color: #f1f5f9;">' + profit.toLocaleString('vi-VN') + ' VNĐ</td></tr>';
      html += '</tbody></table><br><br>';

      // BẢNG DOANH THU
      html += '<table border="1" style="border-collapse: collapse; margin-bottom: 30px;">';
      html += '<thead>';
      html += '<tr><th colspan="3" style="font-size: 16px; font-weight: bold; text-align: left; background-color: #10B981; color: white; padding: 12px;">1. CHI TIẾT DOANH THU (' + totalCount + ' tiệc)</th></tr>';
      html += '<tr>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; width: 120px; padding: 10px;">Thời gian</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; width: 150px; padding: 10px;">Số lượng tiệc</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; width: 200px; padding: 10px;">Doanh thu (VNĐ)</th>';
      html += '</tr></thead><tbody>';
      
      revData.forEach(function(item) {
        html += '<tr>';
        html += '<td style="text-align: center; padding: 8px;">' + item.month + '</td>';
        html += '<td style="text-align: center; padding: 8px;">' + item.count + '</td>';
        html += '<td style="text-align: right; padding: 8px;">' + item.revenue.toLocaleString('vi-VN') + '</td>';
        html += '</tr>';
      });
      html += '</tbody><tfoot><tr>';
      html += '<td style="font-weight: bold; text-align: center; background-color: #e2e8f0; padding: 10px;">TỔNG CỘNG</td>';
      html += '<td style="font-weight: bold; text-align: center; background-color: #e2e8f0; padding: 10px;">' + totalCount + '</td>';
      html += '<td style="font-weight: bold; color: #10B981; text-align: right; background-color: #e2e8f0; padding: 10px;">' + totalRev.toLocaleString('vi-VN') + '</td>';
      html += '</tr></tfoot></table><br><br>';

      // BẢNG CHI PHÍ
      html += '<table border="1" style="border-collapse: collapse;">';
      html += '<thead>';
      html += '<tr><th colspan="7" style="font-size: 16px; font-weight: bold; text-align: left; background-color: #EF4444; color: white; padding: 12px;">2. CHI TIẾT CHI PHÍ</th></tr>';
      html += '<tr>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Mã HĐ</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Khách hàng</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Ngày tổ chức</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Chi phí Thực đơn</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Chi phí Dịch vụ</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Chi phí Nhân sự</th>';
      html += '<th style="background-color: #f1f5f9; font-weight: bold; padding: 10px;">Tổng Chi Phí</th>';
      html += '</tr></thead><tbody>';
      
      cData.forEach(function(item) {
        html += '<tr>';
        html += '<td style="text-align: center; padding: 8px;">' + item.id + '</td>';
        html += '<td style="padding: 8px;">' + item.customer + '</td>';
        html += '<td style="text-align: center; padding: 8px;">' + item.date + '</td>';
        html += '<td style="text-align: right; padding: 8px;">' + item.foodCost.toLocaleString('vi-VN') + '</td>';
        html += '<td style="text-align: right; padding: 8px;">' + item.serviceCost.toLocaleString('vi-VN') + '</td>';
        html += '<td style="text-align: right; padding: 8px;">' + item.staffCost.toLocaleString('vi-VN') + '</td>';
        html += '<td style="text-align: right; padding: 8px; color: #EF4444; font-weight: bold;">' + item.totalCost.toLocaleString('vi-VN') + '</td>';
        html += '</tr>';
      });
      html += '</tbody><tfoot><tr>';
      html += '<td colspan="3" style="font-weight: bold; text-align: center; background-color: #e2e8f0; padding: 10px;">TỔNG CỘNG</td>';
      html += '<td style="font-weight: bold; text-align: right; background-color: #e2e8f0; padding: 10px;">' + sumFood.toLocaleString('vi-VN') + '</td>';
      html += '<td style="font-weight: bold; text-align: right; background-color: #e2e8f0; padding: 10px;">' + sumService.toLocaleString('vi-VN') + '</td>';
      html += '<td style="font-weight: bold; text-align: right; background-color: #e2e8f0; padding: 10px;">' + sumStaff.toLocaleString('vi-VN') + '</td>';
      html += '<td style="font-weight: bold; color: #EF4444; text-align: right; background-color: #e2e8f0; padding: 10px;">' + totalCost.toLocaleString('vi-VN') + '</td>';
      html += '</tr></tfoot></table>';
      
      html += '</body></html>';

      var blob = new Blob([html], { type: 'application/vnd.ms-excel' });
      var link = document.createElement("a");
      link.setAttribute("href", URL.createObjectURL(blob));
      link.setAttribute("download", "Bao_Cao_Tong_Hop_Kinh_Doanh.xls");
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      Alert.success('Đã xuất Báo Cáo Tổng Hợp ra Excel thành công!');
    });
  }

  return { render: render };
})();
