/**
 * Màn hình Cài đặt Giao diện
 */
var AppearancePage = (function () {

  function render($container) {
    var currentMode = (typeof Navbar !== 'undefined' && Navbar.getLayout) ? Navbar.getLayout() : 'horizontal';
    var currentFont = localStorage.getItem('pmql_font_family') || 'Plus Jakarta Sans';

    var html = `
      <div class="page-title-bar">
        <span>Cài đặt Giao diện & Hiển thị</span>
      </div>
      
      <div class="card" style="animation: slideUp 0.3s ease forwards;">
        <div style="padding: 24px;">
          <h2 style="font-size: var(--font-size-xl); font-weight: 600; margin-bottom: 8px;">Tùy chỉnh bố cục hệ thống</h2>
          <p style="color: var(--color-text-secondary); margin-bottom: 32px; font-size: 15px;">Chọn phương thức hiển thị menu phù hợp với thói quen sử dụng của bạn.</p>
          
          <div style="display: flex; gap: 20px; flex-wrap: wrap;">
            <!-- Tùy chọn Giao diện ngang (Navbar) -->
            <div class="layout-option ${currentMode === 'horizontal' ? 'active' : ''}" 
                 onclick="AppearancePage.changeLayout('horizontal', this)" 
                 id="opt-layout-horizontal"
                 style="flex: 1; min-width: 260px; max-width: 320px; border: 2px solid ${currentMode === 'horizontal' ? 'var(--color-primary)' : 'var(--color-border)'}; border-radius: 12px; padding: 20px; cursor: pointer; text-align: center; transition: all 0.2s; background: ${currentMode === 'horizontal' ? 'rgba(79,70,229,0.05)' : '#fff'}; position: relative; overflow: hidden;">
               
               ${currentMode === 'horizontal' ? '<div class="check-circle-wrapper" style="position: absolute; top: 10px; right: 10px; color: var(--color-primary);"><span class="material-symbols-outlined" style="font-size: 20px;">check_circle</span></div>' : ''}
               
               <span class="material-symbols-outlined" style="font-size: 40px; color: ${currentMode === 'horizontal' ? 'var(--color-primary)' : 'var(--color-text-secondary)'}; margin-bottom: 12px;">view_agenda</span>
               <h3 style="margin-bottom: 6px; font-size: 15px; font-weight: 600; color: var(--color-text);">Giao diện Ngang (Navbar)</h3>
               <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0; line-height: 1.5;">Menu ngang gọn gàng trên cùng.</p>
            </div>

            <!-- Tùy chọn Giao diện dọc (Sidebar) -->
            <div class="layout-option ${currentMode === 'vertical' ? 'active' : ''}" 
                 onclick="AppearancePage.changeLayout('vertical', this)" 
                 id="opt-layout-vertical"
                 style="flex: 1; min-width: 260px; max-width: 320px; border: 2px solid ${currentMode === 'vertical' ? 'var(--color-primary)' : 'var(--color-border)'}; border-radius: 12px; padding: 20px; cursor: pointer; text-align: center; transition: all 0.2s; background: ${currentMode === 'vertical' ? 'rgba(79,70,229,0.05)' : '#fff'}; position: relative; overflow: hidden;">
               
               ${currentMode === 'vertical' ? '<div class="check-circle-wrapper" style="position: absolute; top: 10px; right: 10px; color: var(--color-primary);"><span class="material-symbols-outlined" style="font-size: 20px;">check_circle</span></div>' : ''}
               
               <span class="material-symbols-outlined" style="font-size: 40px; color: ${currentMode === 'vertical' ? 'var(--color-primary)' : 'var(--color-text-secondary)'}; margin-bottom: 12px;">view_sidebar</span>
               <h3 style="margin-bottom: 6px; font-size: 15px; font-weight: 600; color: var(--color-text);">Giao diện Dọc (Sidebar)</h3>
               <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0; line-height: 1.5;">Thanh công cụ dọc bên trái quen thuộc.</p>
            </div>
          </div>

          <hr style="margin: 40px 0; border: none; border-top: 1px solid var(--color-border-strong);">

          <h2 style="font-size: var(--font-size-xl); font-weight: 600; margin-bottom: 8px;">Phông chữ hệ thống</h2>
          <p style="color: var(--color-text-secondary); margin-bottom: 32px; font-size: 15px;">Đổi phông chữ để trải nghiệm của bạn thoải mái hơn khi sử dụng ứng dụng.</p>

          <div style="display: flex; gap: 16px; flex-wrap: wrap;" id="font-options-container">
            ${_buildFontOptionHTML('Plus Jakarta Sans', 'Sang trọng, sắc nét', 'Plus Jakarta Sans', currentFont)}
            ${_buildFontOptionHTML('Inter', 'Hiện đại, dễ đọc', 'Inter', currentFont)}
            ${_buildFontOptionHTML('Roboto', 'Tiêu chuẩn cổ điển', 'Roboto', currentFont)}
            ${_buildFontOptionHTML('Nunito', 'Bo tròn, thân thiện', 'Nunito', currentFont)}
          </div>

        </div>
      </div>
    `;

    $container.innerHTML = html;
  }

  function _buildFontOptionHTML(fontName, desc, fontFamily, currentFont) {
    var isActive = currentFont === fontFamily;
    return `
      <div class="font-option ${isActive ? 'active' : ''}" 
           onclick="AppearancePage.changeFont('${fontFamily}', this)" 
           style="flex: 1; min-width: 200px; border: 2px solid ${isActive ? 'var(--color-primary)' : 'var(--color-border)'}; border-radius: 12px; padding: 16px; cursor: pointer; transition: all 0.2s; background: ${isActive ? 'rgba(79,70,229,0.05)' : '#fff'}; position: relative;">
         
         ${isActive ? '<div class="font-check-wrapper" style="position: absolute; top: 10px; right: 10px; color: var(--color-primary);"><span class="material-symbols-outlined" style="font-size: 18px;">check_circle</span></div>' : ''}
         
         <h3 style="margin: 0 0 4px 0; font-size: 16px; font-weight: 600; color: var(--color-text); font-family: '${fontFamily}', sans-serif;">Aa Bb Cc</h3>
         <div style="font-size: 14px; font-weight: 600; color: var(--color-text); margin-bottom: 4px;">${fontName} ${fontFamily === 'Plus Jakarta Sans' ? '(Mặc định)' : ''}</div>
         <p style="font-size: 12px; color: var(--color-text-secondary); margin: 0;">${desc}</p>
      </div>
    `;
  }

  function changeLayout(mode, el) {
    if (typeof Navbar === 'undefined' || typeof Navbar.setLayout === 'undefined') return;
    var currentMode = Navbar.getLayout();
    if (currentMode === mode) return; // No change

    Navbar.setLayout(mode);

    // Bắt buộc đẩy app-content ra ngoài thẻ app trực tiếp TRƯỚC KHI VẼ LẠI NAVBAR, nếu không sẽ bị xóa DOM
    Navbar.moveContentToApp();

    Navbar.render('navbar-container');

    if (mode === 'vertical') {
      Navbar.moveContentToVerticalMain();
    }

    // Update UI options directly
    setTimeout(function () {
      var allOptions = document.querySelectorAll('.layout-option');
      allOptions.forEach(function (opt) {
        opt.style.borderColor = 'var(--color-border)';
        opt.style.background = '#fff';

        var icon = opt.querySelector('span.material-symbols-outlined');
        if (icon) icon.style.color = 'var(--color-text-secondary)';

        var checkMark = opt.querySelector('.check-circle-wrapper');
        if (checkMark) checkMark.remove();
      });

      if (el) {
        el.style.borderColor = 'var(--color-primary)';
        el.style.background = 'rgba(79,70,229,0.05)';
        var icon = el.querySelector('span.material-symbols-outlined');
        if (icon) icon.style.color = 'var(--color-primary)';

        var checkWrap = document.createElement('div');
        checkWrap.className = 'check-circle-wrapper';
        checkWrap.style = 'position: absolute; top: 10px; right: 10px; color: var(--color-primary);';
        checkWrap.innerHTML = '<span class="material-symbols-outlined" style="font-size: 20px;">check_circle</span>';
        el.appendChild(checkWrap);
      }

      UIToast.show('Đã chuyển đổi giao diện thành công');
    }, 50);
  }

  function changeFont(fontFamily, el) {
    var currentFont = localStorage.getItem('pmql_font_family') || 'Plus Jakarta Sans';
    if (currentFont === fontFamily) return; // No change

    // Save to local storage
    localStorage.setItem('pmql_font_family', fontFamily);

    // Apply via CSS variable dynamically
    document.documentElement.style.setProperty('--font-family', '"' + fontFamily + '", sans-serif');

    // Update UI directly
    var allOptions = document.querySelectorAll('.font-option');
    allOptions.forEach(function (opt) {
      opt.style.borderColor = 'var(--color-border)';
      opt.style.background = '#fff';

      var checkMark = opt.querySelector('.font-check-wrapper');
      if (checkMark) checkMark.remove();
    });

    if (el) {
      el.style.borderColor = 'var(--color-primary)';
      el.style.background = 'rgba(79,70,229,0.05)';

      var checkWrap = document.createElement('div');
      checkWrap.className = 'font-check-wrapper';
      checkWrap.style = 'position: absolute; top: 10px; right: 10px; color: var(--color-primary);';
      checkWrap.innerHTML = '<span class="material-symbols-outlined" style="font-size: 18px;">check_circle</span>';
      el.appendChild(checkWrap);
    }

    UIToast.show('Đã đổi phông chữ sang ' + fontFamily);
  }

  return {
    render: render,
    changeLayout: changeLayout,
    changeFont: changeFont
  };
})();
