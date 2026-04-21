/**
 * Màn hình Xem Lịch Tiệc Trong Tháng (Calendar)
 * Xử lý luồng IV.12 trong REQUIREMENT.md
 */
var CalendarPage = (function () {
  var $container;

  function render(containerElement) {
    $container = containerElement;

    var html = `
      <div class="page-title-bar">
        <span>Lịch Tổ Chức Tiệc Tiệc Trong Tháng</span>
      </div>

      <div class="card mb-4" style="animation: slideUp 0.3s ease forwards;">
        <div style="padding: 16px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px;">
          <div style="display:flex; align-items:center; gap: 8px;">
             <button class="btn btn-secondary" style="padding: 6px 12px;"><span class="material-symbols-outlined">chevron_left</span></button>
             <span style="font-weight:bold; font-size: 18px; margin: 0 16px;">Tháng 11 / 2026</span>
             <button class="btn btn-secondary" style="padding: 6px 12px;"><span class="material-symbols-outlined">chevron_right</span></button>
          </div>
          <div style="display:flex; gap: 16px; font-size:13px; color:var(--color-text-secondary); flex-wrap:wrap;">
             <div style="display:flex; align-items:center; gap:4px;"><span style="display:inline-block; width:12px; height:12px; background:var(--color-success); border-radius:3px;"></span> Mới Cọc (Chưa Ký HĐ)</div>
             <div style="display:flex; align-items:center; gap:4px;"><span style="display:inline-block; width:12px; height:12px; background:var(--color-danger); border-radius:3px;"></span> Đã ký Hợp Đồng</div>
             <div style="display:flex; align-items:center; gap:4px;"><span style="display:inline-block; width:12px; height:12px; border:1px solid #ccc; font-weight:bold; text-align:center; line-height:12px;">X</span> Sảnh Phụ / Ghép</div>
          </div>
        </div>
      </div>

      <div class="card" style="animation: slideUp 0.4s ease forwards;">
        <div style="padding: 24px; overflow-x: auto;">
           <!-- Grid Header -->
           <div style="display: grid; grid-template-columns: repeat(7, minmax(120px, 1fr)); gap: 12px; margin-bottom: 12px; min-width:800px;">
              ${['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ Nhật'].map(d => `<div style="text-align:center; font-weight:bold; color:var(--color-text-secondary); padding:8px; background:#F8FAFC; border-radius:6px;">${d}</div>`).join('')}
           </div>
           
           <!-- Grid Body (Mock November 2026 starting on Sunday = 6 blanks initially if week starts Mon. Nov 1 is Sunday -> 6 blanks) -->
           <div style="display: grid; grid-template-columns: repeat(7, minmax(120px, 1fr)); grid-auto-rows: minmax(110px, auto); gap: 12px; min-width:800px;">
              <!-- Empty start days -->
              ${[...Array(6)].map(() => `<div style="border: 1px dashed var(--color-border); border-radius: 8px; opacity: 0.5; background:#FAFAFA;"></div>`).join('')}

              <!-- Days 1 to 30 -->
              ${[...Array(30)].map((_, i) => {
                 var day = i + 1;
                 var eventsHtml = '';
                 
                 if (day === 10) {
                    eventsHtml = '<div style="background:rgba(16,185,129,0.1); color:var(--color-success); border:1px solid var(--color-success); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600; cursor:pointer;" onclick="UIToast.show(`Chi tiết cọc: Vũ Khắc Tiệp 50 Bàn`)">Đại sảnh (50)</div>';
                 }
                 if (day === 15) {
                    eventsHtml = '<div style="background:rgba(239,68,68,0.1); color:var(--color-danger); border:1px solid var(--color-danger); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600; cursor:pointer;" onclick="UIToast.show(`Chi tiết HĐ: Trương Tuấn Anh 30 Bàn`)">Sảnh Kim Cương (30)</div>';
                 }
                 if (day === 22) {
                    eventsHtml = `
                      <div style="background:rgba(239,68,68,0.1); color:var(--color-danger); border:1px solid var(--color-danger); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600; margin-bottom:4px; cursor:pointer;">Sảnh Ngọc Trai (45)</div>
                      <div style="background:rgba(16,185,129,0.1); color:var(--color-success); border:1px dashed var(--color-success); border-radius:4px; padding:4px 6px; font-size:11px; font-weight:600; cursor:pointer;">Sảnh B (X)</div>
                    `;
                 }

                 return `
                    <div style="border: 1px solid var(--color-border); border-radius: 8px; padding: 8px; min-height: 100px; display:flex; flex-direction:column; gap:4px; background: #fff; transition: all 0.2s; cursor:pointer; position:relative;" class="calendar-day-hover">
                       <style>.calendar-day-hover:hover { border-color: var(--color-primary) !important; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); z-index:1; transform:translateY(-2px); }</style>
                       <div style="text-align:right; font-weight:600; color: ${eventsHtml !== '' ? 'var(--color-primary)' : 'var(--color-text)'}; padding-bottom:4px; border-bottom:1px solid var(--color-border); margin-bottom:4px;">${day}</div>
                       <div style="flex:1;">${eventsHtml}</div>
                    </div>
                 `;
              }).join('')}
           </div>
        </div>
      </div>
    `;

    $container.innerHTML = html;
  }

  return { render: render };
})();
