/**
 * Màn hình Xem Lịch Tiệc Trong Tháng (Calendar)
 * HTML Template: src/pages/calendar/calendar.html
 */
var CalendarPage = (function () {
  var $container;
  var uiCalendarInstance;
  var currentYear = new Date().getFullYear();
  var currentMonth = new Date().getMonth();

  function invalidateCache() {
    CalendarService.invalidateCache();
  }

  function _loadEvents(forceRefresh = false) {
    CalendarService.fetchEvents(currentYear, currentMonth, forceRefresh)
      .then(function(eventsData) {
        if (uiCalendarInstance) {
          uiCalendarInstance.updateEvents(eventsData);
        }
      })
      .catch(function(err) {
        console.error('Lỗi khi tải lịch từ Service:', err);
      });
  }

  // Tự động làm mới UI trang Lịch nếu nghe thấy có người sửa/tạo Tiệc mới
  if (typeof EventBus !== 'undefined') {
    EventBus.on('BANQUET_MUTATED', function() {
      console.log('🔄 [CalendarPage] Cập nhật lại giao diện ngay lập tức.');
      _loadEvents(true); // Buộc tải lại lịch từ API (lúc này service đã tự xóa cache)
    });
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

  return { render: render  };
})();

// Hàm Mở Modal Tạo Tiệc Mới (Thay thế cho Mock cũ)
window.showCreateBanquetModal = function() {
  var contentHtml = `
    <form id="form-create-banquet">
      <div class="row g-4 p-2">
        <!-- Khách Hàng -->
        <div class="col-12">
          <h6 class="fw-bold mb-3" style="color: var(--color-primary); border-bottom: 2px solid var(--color-border); padding-bottom: 8px;">1. Thông tin Khách hàng</h6>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tên Chú Rể</label>
              <input type="text" class="ui-input w-100" name="Tenchure" placeholder="Nhập tên chú rể" required>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tên Cô Dâu</label>
              <input type="text" class="ui-input w-100" name="Tencodau" placeholder="Nhập tên cô dâu" required>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Số Điện Thoại</label>
              <input type="text" class="ui-input w-100" name="Dienthoai" placeholder="Nhập SĐT liên hệ" required>
            </div>
          </div>
        </div>
        
        <!-- Thời gian & Không gian -->
        <div class="col-12">
          <h6 class="fw-bold mb-3" style="color: var(--color-primary); border-bottom: 2px solid var(--color-border); padding-bottom: 8px;">2. Thời gian & Địa điểm</h6>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Ngày Tổ Chức</label>
              <input type="date" class="ui-input w-100" name="Ngaytochuc" required>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Ca Tiệc</label>
              <select class="ui-input w-100" name="Thoigianid" id="modal-sel-catiec">
                <option value="">-- Đang tải ca tiệc... --</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Sảnh Chính</label>
              <select class="ui-input w-100" name="Sanhtiecid" id="modal-sel-sanh">
                <option value="">-- Đang tải sảnh... --</option>
              </select>
            </div>
          </div>
        </div>
        
        <!-- Số lượng & Thanh toán -->
        <div class="col-12">
          <h6 class="fw-bold mb-3" style="color: var(--color-primary); border-bottom: 2px solid var(--color-border); padding-bottom: 8px;">3. Quy mô & Tiền cọc</h6>
          <div class="row g-3">
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Số Bàn Mặn</label>
              <input type="number" class="ui-input w-100" name="SobanManchinhthuc" value="0" min="0">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Số Bàn Chay</label>
              <input type="number" class="ui-input w-100" name="SobanChaychinhthuc" value="0" min="0">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tổng Tiền (Dự kiến)</label>
              <input type="number" class="ui-input w-100" name="Tongtienhopdong" value="0" min="0">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tiền Đặt Cọc</label>
              <input type="number" class="ui-input w-100" name="Tongtiencoc" value="0" min="0">
            </div>
          </div>
        </div>
      </div>
      
      <div class="d-flex justify-content-end gap-2 mt-4 pt-3" style="border-top: 1px solid var(--color-border);">
        <button type="button" class="btn btn-outline" onclick="document.querySelector('.btn-close-modal').click()">Hủy Bỏ</button>
        <button type="button" class="btn btn-primary d-flex align-items-center gap-2" onclick="window.submitCreateBanquet(this)">
          <span class="material-symbols-outlined" style="font-size: 20px;">save</span>
          Lưu Hợp Đồng Tiệc
        </button>
      </div>
    </form>
  `;

  UIModal.show({
    title: 'Lập Hợp Đồng Tiệc Mới',
    width: '900px',
    content: contentHtml
  });

  // Tải danh sách Sảnh từ SystemDataService
  if (typeof SystemDataService !== 'undefined') {
    SystemDataService.getHalls().then(function (records) {
      var selSanh = document.getElementById('modal-sel-sanh');
      if (selSanh && records.length > 0) {
        selSanh.innerHTML = '<option value="">-- Chọn Sảnh --</option>';
        records.forEach(function (h) {
          selSanh.innerHTML += '<option value="' + h.Sanhtiecid + '">' + h.Tensanhtiec + ' (Max: ' + (h.Succhua || 0) + ' bàn)</option>';
        });
      } else if (selSanh) {
        selSanh.innerHTML = '<option value="">-- Không có dữ liệu sảnh --</option>';
      }
    }).catch(function (e) {
      console.warn('Lỗi tải sảnh:', e);
      var selSanh = document.getElementById('modal-sel-sanh');
      if (selSanh) selSanh.innerHTML = '<option value="">-- Lỗi tải sảnh --</option>';
    });

    // Tải danh sách Ca Tiệc từ SystemDataService
    SystemDataService.getShifts().then(function (records) {
      var selCaTiec = document.getElementById('modal-sel-catiec');
      if (selCaTiec && records.length > 0) {
        selCaTiec.innerHTML = '<option value="">-- Chọn Ca Tiệc --</option>';
        records.forEach(function (c) {
          selCaTiec.innerHTML += '<option value="' + c.Thoigianid + '">' + (c.Thoigianid.includes('SANG') ? 'Buổi Sáng' : c.Thoigianid.includes('CHIEU') ? 'Buổi Chiều' : 'Cả Ngày') + ' (' + c.Thoigian + ')</option>';
        });
      } else if (selCaTiec) {
        selCaTiec.innerHTML = '<option value="">-- Không có dữ liệu ca tiệc --</option>';
      }
    }).catch(function (e) {
      console.warn('Lỗi tải ca tiệc:', e);
      var selCaTiec = document.getElementById('modal-sel-catiec');
      if (selCaTiec) selCaTiec.innerHTML = '<option value="">-- Lỗi tải ca tiệc --</option>';
    });
  }
};

window.submitCreateBanquet = function(btn) {
  var form = document.getElementById('form-create-banquet');
  if (!form.checkValidity()) {
    form.reportValidity();
    return;
  }
  
  // Tạm thời hiển thị Toast và phát sự kiện EventBus giả lập (Chờ ghép nối API thật)
  var btnOriginalText = btn.innerHTML;
  btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Đang lưu...';
  btn.disabled = true;

  setTimeout(function() {
    document.querySelector('.btn-close-modal').click();
    UIToast.show('Đã lập hợp đồng tiệc thành công!', 'success');
    
    // GỌI EVENT BUS ĐỂ ĐỒNG BỘ LẠI TOÀN BỘ LỊCH
    if (typeof EventBus !== 'undefined') {
      EventBus.emit('BANQUET_MUTATED', { type: 'create' });
    }
  }, 600);
};
