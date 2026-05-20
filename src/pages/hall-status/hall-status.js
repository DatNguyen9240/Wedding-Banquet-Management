/**
 * Trang Trạng thái Sảnh Tiệc
 */
window.HallStatusPage = (function () {
  
  function render(container) {
    if (!container) return;

    var dateInput = container.querySelector('#hall-status-date');
    if (dateInput) {
      dateInput.valueAsDate = new Date();
      dateInput.addEventListener('change', function() {
        _renderHalls(container);
      });
    }

    _renderHalls(container);
  }

  function _renderHalls(container) {
    var grid = container.querySelector('#hall-status-grid');
    if (!grid) return;

    var halls = [];
    if (typeof MockData !== 'undefined' && MockData.sanhTiec) {
      halls = MockData.sanhTiec;
    } else {
      // Fallback data
      halls = [
        { id: 'S01', name: 'Sảnh Kim Cương', status: 'TRONG', capacity: 50 },
        { id: 'S02', name: 'Sảnh Bạch Kim', status: 'DA_COC', capacity: 40, customer: 'Trương Vô Kỵ', session: 'Trưa' },
        { id: 'S03', name: 'Sảnh Vàng', status: 'DA_KY', capacity: 30, customer: 'Quách Tĩnh', session: 'Tối' },
        { id: 'S04', name: 'Sảnh Bạc', status: 'BAO_TRI', capacity: 20 },
        { id: 'S05', name: 'Sảnh Đồng', status: 'TRONG', capacity: 25 },
        { id: 'S06', name: 'Sảnh Ngọc Trai', status: 'DA_COC', capacity: 35, customer: 'Dương Quá', session: 'Tối' }
      ];
    }

    var html = '';
    halls.forEach(function(hall) {
      var color = '';
      var statusText = '';
      if (hall.status === 'TRONG') { color = 'var(--color-success)'; statusText = 'Trống - Sẵn sàng'; }
      else if (hall.status === 'DA_COC') { color = 'var(--color-warning)'; statusText = 'Đã cọc chỗ'; }
      else if (hall.status === 'DA_KY') { color = 'var(--color-danger)'; statusText = 'Đã ký HĐ'; }
      else { color = '#64748b'; statusText = 'Bảo trì'; }

      var details = '';
      if (hall.status === 'DA_COC' || hall.status === 'DA_KY') {
        details = '<div style="font-size:13px;margin-top:12px;border-top:1px solid var(--color-border);padding-top:8px;">' +
                    '<div style="margin-bottom:4px;"><b>Khách:</b> ' + (hall.customer || 'N/A') + '</div>' +
                    '<div><b>Ca:</b> ' + UIBadge.createHTML(hall.session || 'N/A', 'light', 'padding:2px 6px;') + '</div>' +
                  '</div>';
      } else {
        details = '<div style="font-size:13px;margin-top:12px;border-top:1px solid var(--color-border);padding-top:8px;">' +
                    '<div style="color:var(--color-text-secondary)">Sức chứa: <b>' + hall.capacity + '</b> bàn</div>' +
                  '</div>';
      }

      var cardHtml = 
        '<div class="hall-card" style="border:1px solid var(--color-border); border-radius:8px; padding:16px; background:var(--color-surface); cursor:pointer; position:relative; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.05);" onclick="if(typeof Alert !== \'undefined\') Alert.info(\'Xem chi tiết ' + hall.name + '\')">' +
          '<div style="position:absolute;top:0;left:0;width:4px;height:100%;background:' + color + '"></div>' +
          '<div style="padding-left:12px;">' +
            '<h3 style="margin:0 0 4px;font-size:16px;color:var(--color-text);">' + hall.name + '</h3>' +
            '<div style="color:' + color + ';font-weight:600;font-size:14px;">' + statusText + '</div>' +
            details +
          '</div>' +
        '</div>';
        
      html += cardHtml;
    });

    grid.innerHTML = html;
  }

  return {
    render: render
  };
})();
