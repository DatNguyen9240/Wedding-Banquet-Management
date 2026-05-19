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

  function renderLegend() {
    var container = document.getElementById('calendar-legend-container');
    if (!container) return;
    
    CalendarService.getLegend().then(function(config) {
      if (!config || config.length === 0) {
        return; // Không có dữ liệu từ API thì không render
      }
      var html = '';
      config.forEach(function(item) {
        // API returns properties capitalized (Label, Color, Type, Icon) or lowercase depending on C# serializer
        var type = item.Type || item.type;
        var color = item.Color || item.color;
        var label = item.Label || item.label;
        var icon = item.Icon || item.icon;

        if (type === 'dot') {
          var bgMap = { 'success': 'rgba(16, 185, 129, 0.08)', 'danger': 'rgba(239, 68, 68, 0.08)' };
          var borderMap = { 'success': 'rgba(16, 185, 129, 0.2)', 'danger': 'rgba(239, 68, 68, 0.2)' };
          var bgColor = bgMap[color] || 'var(--color-bg-subtle)';
          var borderColor = borderMap[color] || 'var(--color-border)';

          html += '<div class="d-flex align-items-center gap-1 gap-sm-2 px-2 px-sm-3" style="height: 26px; background: ' + bgColor + '; border-radius: 20px; border: 1px solid ' + borderColor + '; color: var(--color-' + color + ');">' +
                  '<div style="width: 6px; height: 6px; border-radius: 50%; background: var(--color-' + color + '); box-shadow: 0 0 0 2px ' + borderColor + ';"></div>' +
                  label +
                  '</div>';
        } else {
          html += '<div class="d-flex align-items-center gap-1 gap-sm-2 px-2 px-sm-3" style="height: 26px; background: var(--color-bg-subtle); border-radius: 20px; border: 1px solid var(--color-border); color: var(--color-' + color + ');">' +
                  '<span class="material-symbols-outlined" style="font-size: 14px; margin-right: -2px;">' + icon + '</span>' +
                  label +
                  '</div>';
        }
      });
      container.innerHTML = html;
    });
  }

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/calendar/calendar.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        renderLegend();
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
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Ngày Tổ Chức</label>
              <input type="text" class="ui-input w-100" name="Ngaytochuc" id="modal-ngaytochuc" placeholder="Chọn ngày..." required>
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Loại Tiệc</label>
              <select class="ui-input w-100" name="Loaihinhtiecid" id="modal-sel-loaitiec" required>
                <option value="">-- Đang tải... --</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Ca Tiệc</label>
              <select class="ui-input w-100" name="Thoigianid" id="modal-sel-catiec" required>
                <option value="">-- Đang tải ca tiệc... --</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Sảnh Chính</label>
              <select class="ui-input w-100" name="Sanhtiecid" id="modal-sel-sanh" required>
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
              <input type="number" class="ui-input w-100" name="SobanManchinhthuc" value="0" min="0" onfocus="this.select()">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Số Bàn Chay</label>
              <input type="number" class="ui-input w-100" name="SobanChaychinhthuc" value="0" min="0" onfocus="this.select()">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tổng Tiền (Dự kiến)</label>
              <input type="number" class="ui-input w-100" name="Tongtienhopdong" value="0" min="0" onfocus="this.select()">
            </div>
            <div class="col-md-3">
              <label class="form-label" style="font-size: 13px; font-weight: 600;">Tiền Đặt Cọc</label>
              <input type="number" class="ui-input w-100" name="Sotiencoccho" value="0" min="0" onfocus="this.select()">
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

  // Khởi tạo Flatpickr cho ô Chọn Ngày (nếu thư viện đã load)
  if (typeof flatpickr !== 'undefined') {
    flatpickr("#modal-ngaytochuc", {
      dateFormat: "Y-m-d", 
      altInput: true,
      altFormat: "d/m/Y",
      allowInput: true,
      minDate: "today", // Chỉ cho phép chọn từ hôm nay trở đi
      disableMobile: true, // Ép buộc dùng giao diện đẹp của Flatpickr trên mọi thiết bị (kể cả máy tính có màn hình cảm ứng)
      locale: "vn"
    });
  }

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

    // Tải danh sách Loại Hình Tiệc từ SystemDataService
    SystemDataService.getBanquetTypes().then(function (records) {
      var selLoaiTiec = document.getElementById('modal-sel-loaitiec');
      if (selLoaiTiec && records.length > 0) {
        selLoaiTiec.innerHTML = '<option value="">-- Chọn Loại Tiệc --</option>';
        records.forEach(function (t) {
          selLoaiTiec.innerHTML += '<option value="' + t.Loaihinhtiecid + '">' + t.Tenloaihinhtiec + '</option>';
        });
      } else if (selLoaiTiec) {
        selLoaiTiec.innerHTML = '<option value="">-- Không có dữ liệu --</option>';
      }
    }).catch(function (e) {
      var selLoaiTiec = document.getElementById('modal-sel-loaitiec');
      if (selLoaiTiec) selLoaiTiec.innerHTML = '<option value="">-- Lỗi tải loại tiệc --</option>';
    });
  }
};

window.submitCreateBanquet = function(btn) {
  var form = document.getElementById('form-create-banquet');
  if (!form.checkValidity()) {
    form.reportValidity();
    return;
  }
  
  var btnOriginalText = btn.innerHTML;
  btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Đang lưu...';
  btn.disabled = true;

  var formData = new FormData(form);
  
  // Format payload for API_Contract_Save
  var payload = {
    Tenchure: formData.get('Tenchure'),
    Tencodau: formData.get('Tencodau'),
    Dienthoai: formData.get('Dienthoai'),
    Ngaytochuc: formData.get('Ngaytochuc'),
    Loaitiecid: formData.get('Loaihinhtiecid'), // Map name
    Thoigianid: formData.get('Thoigianid'),
    SobanManchinhthuc: parseInt(formData.get('SobanManchinhthuc')) || 0,
    SobanChaychinhthuc: parseInt(formData.get('SobanChaychinhthuc')) || 0,
    Tongtienhopdong: parseFloat(formData.get('Tongtienhopdong')) || 0,
    Sotiencoccho: parseFloat(formData.get('Sotiencoccho')) || 0,
    UserCreate: 'Admin'
  };

  // Convert Sanhtiecid to JsonSanhTiec
  var sanhId = formData.get('Sanhtiecid');
  if (sanhId) {
    payload.JsonSanhTiec = JSON.stringify([{
      Sanhtiecid: sanhId,
      IsSanhchinh: 1
    }]);
  }

  // Calculate TongSoBan
  payload.TongSoBan = payload.SobanManchinhthuc + payload.SobanChaychinhthuc;
  payload.Tongtiencoc = payload.Sotiencoccho;

  if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CALENDAR || !API_CONFIG.ENDPOINTS.CALENDAR.SAVE) {
    UIToast.show('Chưa cấu hình API Lưu', 'danger');
    btn.innerHTML = btnOriginalText;
    btn.disabled = false;
    return;
  }

  ApiClient.post(API_CONFIG.ENDPOINTS.CALENDAR.SAVE, payload)
    .then(function(res) {
      if (res && res.Success === 1) {
        document.querySelector('.btn-close-modal').click();
        UIToast.show(res.Message || 'Đã lập hợp đồng tiệc thành công!', 'success');
        
        if (typeof EventBus !== 'undefined') {
          EventBus.emit('BANQUET_MUTATED', { type: 'create' });
        }
      } else {
        UIToast.show(res.Message || 'Lỗi lưu hợp đồng', 'danger');
      }
    })
    .catch(function(err) {
      console.error(err);
      UIToast.show('Có lỗi xảy ra khi lưu!', 'danger');
    })
    .finally(function() {
      btn.innerHTML = btnOriginalText;
      btn.disabled = false;
    });
};

