/**
 * Calendar Component
 * Sinh Lịch Tiệc cơ bản bằng JS. Không dùng thư viện nặng.
 */
var UICalendar = (function () {

  /**
   * Khởi tạo Lịch
   * @param {Object} config - { year, month, events (danh sách chấm đỏ/xanh) }
   */
  function create(config) {
    config = config || {};
    var today = new Date();
    var currentYear = (config.year !== undefined && !isNaN(config.year)) ? Number(config.year) : today.getFullYear();
    var currentMonth = (config.month !== undefined && !isNaN(config.month)) ? Number(config.month) : today.getMonth();

    var wrapper = document.createElement('div');
    wrapper.className = 'ui-calendar-wrapper';

    function render(year, month) {
      wrapper.innerHTML = '';

      // Header
      var header = document.createElement('div');
      header.className = 'calendar-header';
      
      var titleContainer = document.createElement('div');
      titleContainer.className = 'calendar-month-picker';

      var titleText = document.createElement('span');
      titleText.innerText = 'Tháng ' + (month + 1) + ', ' + year;
      titleContainer.appendChild(titleText);

      var icon = document.createElement('span');
      icon.className = 'material-symbols-outlined';
      icon.innerText = 'expand_more';
      icon.style.fontSize = '24px';
      icon.style.color = 'var(--color-text-secondary)';
      titleContainer.appendChild(icon);

      titleContainer.onclick = function() {
        if (document.getElementById('custom-month-picker-overlay')) return;
        
        var overlay = document.createElement('div');
        overlay.id = 'custom-month-picker-overlay';
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.width = '100%';
        overlay.style.height = '100%';
        overlay.style.zIndex = '9999';
        
        var dropdown = document.createElement('div');
        dropdown.className = 'calendar-dropdown-picker';
        var rect = titleContainer.getBoundingClientRect();
        dropdown.style.top = (rect.bottom + 8) + 'px';
        dropdown.style.left = rect.left + 'px';
        dropdown.onclick = function(ev) { ev.stopPropagation(); };
        
        var yearHeader = document.createElement('div');
        yearHeader.className = 'calendar-dropdown-header';
        
        var btnPrevYear = document.createElement('button');
        btnPrevYear.className = 'btn btn-outline d-flex align-items-center justify-content-center p-0 rounded-circle';
        btnPrevYear.style.width = '32px'; btnPrevYear.style.height = '32px';
        btnPrevYear.innerHTML = '<span class="material-symbols-outlined" style="font-size: 18px;">chevron_left</span>';
        
        var yearLabel = document.createElement('div');
        yearLabel.className = 'calendar-dropdown-year-label';
        yearLabel.innerText = year;
        
        var btnNextYear = document.createElement('button');
        btnNextYear.className = 'btn btn-outline d-flex align-items-center justify-content-center p-0 rounded-circle';
        btnNextYear.style.width = '32px'; btnNextYear.style.height = '32px';
        btnNextYear.innerHTML = '<span class="material-symbols-outlined" style="font-size: 18px;">chevron_right</span>';
        
        var tempYear = year;
        
        btnPrevYear.onclick = function() { tempYear--; yearLabel.innerText = tempYear; renderMonths(); };
        btnNextYear.onclick = function() { tempYear++; yearLabel.innerText = tempYear; renderMonths(); };
        
        yearHeader.appendChild(btnPrevYear);
        yearHeader.appendChild(yearLabel);
        yearHeader.appendChild(btnNextYear);
        dropdown.appendChild(yearHeader);
        
        var monthsGrid = document.createElement('div');
        monthsGrid.className = 'calendar-dropdown-months-grid';
        
        function renderMonths() {
          monthsGrid.innerHTML = '';
          var monthNames = ['Thg 1', 'Thg 2', 'Thg 3', 'Thg 4', 'Thg 5', 'Thg 6', 'Thg 7', 'Thg 8', 'Thg 9', 'Thg 10', 'Thg 11', 'Thg 12'];
          for (let m = 0; m < 12; m++) {
            var mBtn = document.createElement('button');
            mBtn.className = 'calendar-dropdown-month-btn' + (tempYear === year && m === month ? ' active' : '');
            mBtn.innerText = monthNames[m];
            
            mBtn.onclick = function() {
              document.body.removeChild(overlay);
              currentYear = tempYear;
              currentMonth = m;
              if (typeof config.onChangeMonth === 'function') config.onChangeMonth(currentYear, currentMonth);
              else render(currentYear, currentMonth);
            };
            monthsGrid.appendChild(mBtn);
          }
        }
        
        renderMonths();
        dropdown.appendChild(monthsGrid);
        overlay.appendChild(dropdown);
        overlay.onclick = function() { document.body.removeChild(overlay); };
        document.body.appendChild(overlay);
      };

      header.appendChild(titleContainer);
      
      var controls = document.createElement('div');
      controls.className = 'd-flex align-items-center gap-2';
      
      var btnPrev = document.createElement('button');
      btnPrev.className = 'btn btn-outline d-flex align-items-center justify-content-center p-0 rounded-circle';
      btnPrev.style.width = '36px';
      btnPrev.style.height = '36px';
      btnPrev.title = 'Tháng trước';
      btnPrev.innerHTML = '<span class="material-symbols-outlined fs-5">chevron_left</span>';
      btnPrev.onclick = function() {
        var m = month - 1;
        var y = year;
        if (m < 0) { m = 11; y--; }
        currentYear = y; currentMonth = m;
        if (typeof config.onChangeMonth === 'function') config.onChangeMonth(y, m);
        else render(y, m);
      };

      var btnToday = document.createElement('button');
      btnToday.className = 'btn btn-outline px-3 py-1 fw-bold rounded-pill';
      btnToday.innerText = 'Hôm nay';
      btnToday.onclick = function() {
        var y = today.getFullYear();
        var m = today.getMonth();
        currentYear = y; currentMonth = m;
        if (typeof config.onChangeMonth === 'function') config.onChangeMonth(y, m);
        else render(y, m);
      };

      var btnNext = document.createElement('button');
      btnNext.className = 'btn btn-outline d-flex align-items-center justify-content-center p-0 rounded-circle';
      btnNext.style.width = '36px';
      btnNext.style.height = '36px';
      btnNext.title = 'Tháng sau';
      btnNext.innerHTML = '<span class="material-symbols-outlined fs-5">chevron_right</span>';
      btnNext.onclick = function() {
        var m = month + 1;
        var y = year;
        if (m > 11) { m = 0; y++; }
        currentYear = y; currentMonth = m;
        if (typeof config.onChangeMonth === 'function') config.onChangeMonth(y, m);
        else render(y, m);
      };

      controls.appendChild(btnPrev);
      controls.appendChild(btnToday);
      controls.appendChild(btnNext);

      header.appendChild(controls);
      wrapper.appendChild(header);

      // Days Header
      var grid = document.createElement('div');
      grid.className = 'calendar-grid';

      ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].forEach(function(d) {
        var dDiv = document.createElement('div');
        dDiv.className = 'calendar-day-header';
        dDiv.innerText = d;
        grid.appendChild(dDiv);
      });

      // Date calculations
      var jsFirstDay = new Date(year, month, 1).getDay();
      var firstDay = jsFirstDay === 0 ? 6 : jsFirstDay - 1;
      var daysInMonth = new Date(year, month + 1, 0).getDate();
      var daysInPrevMonth = new Date(year, month, 0).getDate();
      
      var cellIndex = 0;

      // ô trước ngày 1 (ngày tháng trước)
      for (let i = 0; i < firstDay; i++) {
        var empty = document.createElement('div');
        empty.className = 'calendar-day empty-day animate-pop';
        empty.style.animationDelay = (cellIndex * 0.015) + 's';
        
        var dNum = document.createElement('div');
        dNum.className = 'calendar-day-number';
        var prevDateNum = daysInPrevMonth - firstDay + i + 1;
        dNum.innerHTML = '<span>' + prevDateNum + '</span>';
        empty.appendChild(dNum);
        
        empty.onclick = (function(d) {
          return function() {
            var prevM = month - 1;
            var prevY = year;
            if (prevM < 0) { prevM = 11; prevY--; }
            if (typeof config.onSelect === 'function') {
              var dateStr = prevY + '-' + (prevM + 1).toString().padStart(2, '0') + '-' + d.toString().padStart(2, '0');
              config.onSelect(dateStr, null);
            }
          };
        })(prevDateNum);

        grid.appendChild(empty);
        cellIndex++;
      }

      // Các ngày trong tháng
      for (let i = 1; i <= daysInMonth; i++) {
        var dayCell = document.createElement('div');
        dayCell.className = 'calendar-day animate-pop';
        dayCell.style.animationDelay = (cellIndex * 0.015) + 's';
        
        if (today.getFullYear() === year && today.getMonth() === month && today.getDate() === i) {
          dayCell.classList.add('today');
        }

        var dayNum = document.createElement('div');
        dayNum.className = 'calendar-day-number';
        dayNum.innerHTML = '<span>' + i + '</span>';
        dayCell.appendChild(dayNum);

        // Thêm events
        var evtDiv = document.createElement('div');
        evtDiv.className = 'calendar-events';
        
        var dayEvents = config.events ? config.events[i] : null;
        
        if (dayEvents && dayEvents.length > 0) {
           var cocCount = 0;
           var hdCount = 0;
           
           dayEvents.forEach(function(e) {
              if (e.rawData) {
                 var lp = e.rawData.LoaiPhieu !== undefined ? e.rawData.LoaiPhieu : e.rawData.loaiPhieu;
                 if (lp === 1) cocCount++;
                 else hdCount++;
              }
           });

           // Render Desktop Summary Labels với chấm tròn chỉ thị
           if (cocCount > 0) {
              var cocLabel = document.createElement('div');
              cocLabel.className = 'calendar-event-label success';
              cocLabel.title = 'Có ' + cocCount + ' Biên nhận cọc chỗ';
              cocLabel.innerHTML = '<span class="dot"></span><span>' + cocCount + ' Cọc Chỗ</span>';
              evtDiv.appendChild(cocLabel);
           }
           if (hdCount > 0) {
              var hdLabel = document.createElement('div');
              hdLabel.className = 'calendar-event-label primary';
              hdLabel.title = 'Có ' + hdCount + ' Hợp đồng';
              hdLabel.innerHTML = '<span class="dot"></span><span>' + hdCount + ' Hợp Đồng</span>';
              evtDiv.appendChild(hdLabel);
           }

           // Render Mobile Dots
           if (cocCount > 0) {
              var dotCoc = document.createElement('div');
              dotCoc.className = 'calendar-event-dot success';
              dayCell.appendChild(dotCoc);
           }
           if (hdCount > 0) {
              var dotHd = document.createElement('div');
              dotHd.className = 'calendar-event-dot primary';
              dayCell.appendChild(dotHd);
           }
        }
        dayCell.appendChild(evtDiv);

        dayCell.onclick = (function(d, evts) {
          return function() {
            if (typeof config.onSelect === 'function') {
              var dateStr = year + '-' + (month + 1).toString().padStart(2, '0') + '-' + d.toString().padStart(2, '0');
              config.onSelect(dateStr, evts);
            }
          };
        })(i, dayEvents);

        grid.appendChild(dayCell);
        cellIndex++;
      }

      // ô sau ngày cuối cùng (ngày tháng sau)
      var totalCells = firstDay + daysInMonth;
      var remainingCells = totalCells % 7 === 0 ? 0 : 7 - (totalCells % 7);
      for (let i = 0; i < remainingCells; i++) {
        var emptyEnd = document.createElement('div');
        emptyEnd.className = 'calendar-day empty-day animate-pop';
        emptyEnd.style.animationDelay = (cellIndex * 0.015) + 's';
        
        var dNumEnd = document.createElement('div');
        dNumEnd.className = 'calendar-day-number';
        var nextDateNum = i + 1;
        dNumEnd.innerHTML = '<span>' + nextDateNum + '</span>';
        emptyEnd.appendChild(dNumEnd);
        
        emptyEnd.onclick = (function(d) {
          return function() {
            var nextM = month + 1;
            var nextY = year;
            if (nextM > 11) { nextM = 0; nextY++; }
            if (typeof config.onSelect === 'function') {
              var dateStr = nextY + '-' + (nextM + 1).toString().padStart(2, '0') + '-' + d.toString().padStart(2, '0');
              config.onSelect(dateStr, null);
            }
          };
        })(nextDateNum);

        grid.appendChild(emptyEnd);
        cellIndex++;
      }

      wrapper.appendChild(grid);
    }

    render(currentYear, currentMonth);
    
    wrapper.updateEvents = function(newEvents) {
      config.events = newEvents;
      render(currentYear, currentMonth);
    };
    
    return wrapper;
  }

  return {
    create: create
  };
})();
