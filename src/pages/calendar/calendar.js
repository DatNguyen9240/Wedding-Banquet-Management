/**
 * Màn hình Xem Lịch Tiệc Trong Tháng (Calendar)
 * HTML Template: src/pages/calendar.html
 */
var CalendarPage = (function () {
  var $container;

  function render(containerElement) {
    $container = containerElement;

    fetch('./src/pages/calendar/calendar.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderWeekdayHeader();
        _renderCalendarGrid();
      });
  }

  function _renderWeekdayHeader() {
    var header = $container.querySelector('#calendar-weekday-header');
    ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ Nhật'].forEach(function(d) {
      var div = document.createElement('div');
      div.className = 'text-center fw-bold';
      div.style.cssText = 'color:var(--color-text-secondary); padding:8px; background: var(--color-background); border-radius:6px;';
      div.textContent = d;
      header.appendChild(div);
    });
  }

  function _renderCalendarGrid() {
    var body = $container.querySelector('#calendar-grid-body');
    body.innerHTML = '';

    // Empty start days (Nov 2026 starts on Sunday → 6 blanks if Mon-start)
    for (var b = 0; b < 6; b++) {
      var blank = document.createElement('div');
      blank.style.cssText = 'border:1px dashed var(--color-border); border-radius:8px; opacity:0.5; background: var(--color-surface);';
      body.appendChild(blank);
    }

    // Days 1 to 30
    for (var i = 1; i <= 30; i++) {
      var cell = document.createElement('div');
      cell.className = 'calendar-day-hover';
      cell.style.cssText = 'border:1px solid var(--color-border); border-radius:8px; padding:8px; min-height:100px; display:flex; flex-direction:column; gap:4px; background: var(--color-surface); transition:all 0.2s; cursor:pointer;';

      var eventsHtml = '';
      if (i === 10) eventsHtml = '<div style="background:rgba(16,185,129,0.1); color:var(--color-success); border:1px solid var(--color-success); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600;">Đại sảnh (50)</div>';
      if (i === 15) eventsHtml = '<div style="background:rgba(239,68,68,0.1); color:var(--color-danger); border:1px solid var(--color-danger); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600;">Sảnh Kim Cương (30)</div>';
      if (i === 22) eventsHtml = '<div style="background:rgba(239,68,68,0.1); color:var(--color-danger); border:1px solid var(--color-danger); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600; margin-bottom:4px;">Sảnh Ngọc Trai (45)</div><div style="background:rgba(16,185,129,0.1); color:var(--color-success); border:1px dashed var(--color-success); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600;">Sảnh B (X)</div>';

      cell.innerHTML = '<div style="text-align:right; font-weight:600; color:' + (eventsHtml ? 'var(--color-primary)' : 'var(--color-text)') + '; padding-bottom:4px; border-bottom:1px solid var(--color-border); margin-bottom:4px;">' + i + '</div><div style="flex:1;">' + eventsHtml + '</div>';
      body.appendChild(cell);
    }

    // Inject hover style
    if (!document.getElementById('calendar-hover-style')) {
      var style = document.createElement('style');
      style.id = 'calendar-hover-style';
      style.textContent = '.calendar-day-hover:hover { border-color: var(--color-primary) !important; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); z-index:1; transform:translateY(-2px); }';
      document.head.appendChild(style);
    }
  }

  return { render: render };
})();
