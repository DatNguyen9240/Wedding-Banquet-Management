/**
 * Màn hình Xem Lịch Tiệc Trong Tháng (Calendar)
 * HTML Template: src/pages/calendar/calendar.html
 */
var CalendarPage = (function () {
  var $container;
  var uiCalendarInstance;
  var currentYear = new Date().getFullYear();
  var currentMonth = new Date().getMonth();

  function _loadEvents() {
    if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CALENDAR || !API_CONFIG.ENDPOINTS.CALENDAR.LIST) {
      console.warn('Chưa cấu hình API_CONFIG.ENDPOINTS.CALENDAR.LIST.');
      return; 
    }

    var payloadString = encodeURIComponent(JSON.stringify({ Thang: currentMonth + 1, Nam: currentYear }));
    var endpoint = API_CONFIG.ENDPOINTS.CALENDAR.LIST + '?q=' + payloadString;

    ApiClient.get(endpoint)
      .then(function(res) {
        var data = res.records || res.data || res || [];
        var eventsData = _formatDataForCalendar(data);
        if (uiCalendarInstance) {
          uiCalendarInstance.updateEvents(eventsData);
        }
      })
      .catch(function(err) {
        console.error('Lỗi khi tải lịch:', err);
      });
  }

  function _formatDataForCalendar(data) {
    var eventsData = {};
    
    // data là mảng các record từ DB
    data.forEach(function(row) {
       if (!row.NgayToChuc) return;
       var d = new Date(row.NgayToChuc);
       var day = d.getDate();
       
       if (!eventsData[day]) eventsData[day] = [];
       
       // LoaiPhieu = 1 -> Xanh (Mới cọc), 2 -> Đỏ (Đã HĐ)
       var type = row.LoaiPhieu === 1 ? 'success' : 'primary';
       
       // Sảnh chính thì ghi số bàn, sảnh phụ ghi X
       var suffix = row.LaSanhChinh === 1 ? row.SoBan : 'X';
       var label = row.TenSanh + ' (' + suffix + ')';

       eventsData[day].push({
         type: type,
         label: label,
         rawData: row
       });
    });

    return eventsData;
  }

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/calendar/calendar.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        var calendarContainer = $container.querySelector('#calendar-component-container');
        if (calendarContainer) {
          uiCalendarInstance = UICalendar.create({
            year: currentYear,
            month: currentMonth,
            events: {}, // Dữ liệu sẽ load từ API
            onChangeMonth: function(y, m) {
              currentYear = y;
              currentMonth = m;
              _loadEvents(); // Load lại data khi đổi tháng
            },
            onSelect: function(dateStr, evts) {
              var displayDate = dateStr.split('-').reverse().join('/');
              if (evts && evts.length > 0) {
                 var evtsBySanh = {};
                 evts.forEach(function(e) {
                    var sanh = e.rawData.TenSanh || 'Chưa chọn sảnh';
                    if (!evtsBySanh[sanh]) evtsBySanh[sanh] = [];
                    evtsBySanh[sanh].push(e);
                 });
                 
                 var contentStr = '<div class="calendar-modal-content d-flex flex-column gap-4" style="padding: 8px;">';
                 
                 Object.keys(evtsBySanh).forEach(function(sanh) {
                    contentStr += `
                      <div class="sanh-group">
                        <div class="d-flex align-items-center gap-2 mb-3">
                          <span class="material-symbols-outlined" style="color: var(--color-primary); font-size: 22px;">storefront</span>
                          <h6 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--color-text); text-transform: uppercase; letter-spacing: 0.5px;">SẢNH: ${sanh}</h6>
                        </div>
                        <div class="row g-3">
                    `;
                    
                    evtsBySanh[sanh].forEach(function(e, idx) {
                        var rd = e.rawData;
                        var typeName = rd.LoaiPhieu === 1 ? 'Mới Cọc' : 'Đã Ký HĐ';
                        var statusColor = rd.LoaiPhieu === 1 ? 'var(--color-success)' : 'var(--color-danger)';
                        var bgSoft = rd.LoaiPhieu === 1 ? 'rgba(16, 185, 129, 0.08)' : 'rgba(220, 38, 38, 0.08)';
                        var btnClass = rd.LoaiPhieu === 1 ? 'btn-outline-success' : 'btn-outline-danger';
                        var hashRoute = rd.LoaiPhieu === 1 ? '#/booking' : '#/contract';
                        
                        contentStr += `
                          <div class="col-12 col-md-6 col-lg-4">
                            <div class="card h-100 position-relative" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); transition: all 0.3s ease; background: var(--color-surface); overflow: hidden;">
                              <!-- Accent Top Bar -->
                              <div style="height: 4px; width: 100%; background: ${statusColor};"></div>
                              
                              <div class="card-body p-3 d-flex flex-column gap-3">
                                <div class="d-flex justify-content-between align-items-start">
                                  <div>
                                    <div style="font-weight: 700; font-size: 15px; color: var(--color-text); margin-bottom: 4px;">
                                      ${rd.TenKhachHang}
                                    </div>
                                    <span style="display: inline-flex; padding: 4px 10px; border-radius: 6px; background: ${bgSoft}; color: ${statusColor}; font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">
                                      ${typeName}
                                    </span>
                                  </div>
                                  <div style="background: ${statusColor}; color: white; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">
                                    ${idx + 1}
                                  </div>
                                </div>
                                
                                <div style="font-size: 13px; color: var(--color-text-secondary); display: flex; flex-direction: column; gap: 8px; flex-grow: 1;">
                                  <div class="d-flex align-items-center gap-2">
                                    <span class="material-symbols-outlined" style="font-size: 16px; opacity: 0.7;">table_restaurant</span>
                                    <span>${rd.LaSanhChinh === 1 ? rd.SoBan + ' Bàn (Sảnh Chính)' : 'Sảnh Phụ / Ghép'}</span>
                                  </div>
                                  <div class="d-flex align-items-center gap-2">
                                    <span class="material-symbols-outlined" style="font-size: 16px; opacity: 0.7;">receipt_long</span>
                                    <span>Mã: <strong>${rd.MaChungTu}</strong></span>
                                  </div>
                                </div>
                                
                                <button class="btn ${btnClass} w-100 d-flex justify-content-center align-items-center gap-2" style="padding: 6px 12px; font-weight: 600; font-size: 13px; border-radius: var(--radius-sm);" onclick="window.location.hash = '${hashRoute}?id=${rd.MaChungTu}'; document.querySelector('.btn-close-modal').click();">
                                  <span class="material-symbols-outlined" style="font-size: 18px;">arrow_forward</span>
                                  Chi Tiết
                                </button>
                              </div>
                            </div>
                          </div>
                        `;
                    });
                    
                    contentStr += `
                        </div>
                      </div>
                    `;
                 });
                 
                 contentStr += '</div>';

                 UIModal.show({
                    title: 'Chi Tiết Lịch Tiệc - ' + displayDate,
                    width: '1000px', // Thu bé lại cho gọn gàng
                    content: contentStr
                 });
              } else {
                 UIToast.show('Ngày ' + displayDate + ' chưa có tiệc.');
              }
            }
          });
          calendarContainer.appendChild(uiCalendarInstance);
          
          _loadEvents(); // Gọi API ngay lần đầu render
        }
      });
  }

  return { render: render };
})();

