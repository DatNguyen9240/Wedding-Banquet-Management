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
    var currentYear = config.year !== undefined ? config.year : today.getFullYear();
    var currentMonth = config.month !== undefined ? config.month : today.getMonth();

    var wrapper = document.createElement('div');
    wrapper.className = 'ui-calendar-wrapper';

    function render(year, month) {
      wrapper.innerHTML = '';

      // Header
      var header = document.createElement('div');
      header.className = 'calendar-header';
      var title = document.createElement('div');
      title.className = 'calendar-month';
      title.innerText = 'Tháng ' + (month + 1) + ' / ' + year;
      
      var controls = UIButton.createBar([
        { 
          icon: 'chevron_left', tooltip: 'Tháng trước', 
          onClick: function() {
            var m = month - 1;
            var y = year;
            if (m < 0) { m = 11; y--; }
            render(y, m);
          }
        },
        { 
          text: 'Hôm nay', 
          onClick: function() {
            render(today.getFullYear(), today.getMonth());
          }
        },
        { 
          icon: 'chevron_right', tooltip: 'Tháng sau', 
          onClick: function() {
            var m = month + 1;
            var y = year;
            if (m > 11) { m = 0; y++; }
            render(y, m);
          }
        }
      ]);

      header.appendChild(title);
      header.appendChild(controls);
      wrapper.appendChild(header);

      // Days Header
      var grid = document.createElement('div');
      grid.className = 'calendar-grid';

      ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].forEach(function(d) {
        var dDiv = document.createElement('div');
        dDiv.className = 'calendar-day-header';
        dDiv.innerText = d;
        grid.appendChild(dDiv);
      });

      // Date calculations
      var firstDay = new Date(year, month, 1).getDay();
      var daysInMonth = new Date(year, month + 1, 0).getDate();

      // 빈 ô trước ngày 1
      for (let i = 0; i < firstDay; i++) {
        var empty = document.createElement('div');
        grid.appendChild(empty);
      }

      // Các ngày
      for (let i = 1; i <= daysInMonth; i++) {
        var dayCell = document.createElement('div');
        dayCell.className = 'calendar-day';
        if (today.getFullYear() === year && today.getMonth() === month && today.getDate() === i) {
          dayCell.classList.add('today');
        }

        var dayNum = document.createElement('div');
        dayNum.className = 'calendar-day-number';
        dayNum.innerText = i;
        dayCell.appendChild(dayNum);

        // Thêm events
        var evtDiv = document.createElement('div');
        evtDiv.className = 'calendar-events';
        
        var isInitialMonth = (year === currentYear && month === currentMonth);
        var dayEvents = (isInitialMonth && config.events) ? config.events[i] : null;
        
        if (dayEvents) {
          dayEvents.forEach(function(ev) {
             var type = typeof ev === 'string' ? ev : (ev.type || 'primary');
             var labelTxt = typeof ev === 'string' ? 'Sự kiện' : (ev.label || 'Sự kiện');

             var label = document.createElement('div');
             label.className = 'calendar-event-label ' + type;
             label.innerText = labelTxt;
             label.title = labelTxt;

             var dot = document.createElement('div');
             dot.className = 'calendar-event-dot ' + type;

             evtDiv.appendChild(label);
             evtDiv.appendChild(dot);
          });
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
      }

      wrapper.appendChild(grid);
    }

    render(currentYear, currentMonth);
    return wrapper;
  }

  return {
    create: create
  };
})();
