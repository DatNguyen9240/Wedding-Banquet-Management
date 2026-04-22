/**
 * Màn hình Cài đặt Giao diện
 * HTML Template: src/pages/appearance.html
 */
var AppearancePage = (function () {

  function render($container) {
    fetch('./src/pages/appearance/appearance.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _renderLayoutOptions();
        _renderFontOptions();
      });
  }

  function _renderLayoutOptions() {
    var container = document.getElementById('layout-options-container');
    if (!container) return;
    var currentMode = (typeof Navbar !== 'undefined' && Navbar.getLayout) ? Navbar.getLayout() : 'horizontal';

    container.innerHTML = _buildLayoutCard('horizontal', 'view_agenda', 'Giao diện Ngang (Navbar)', 'Menu ngang gọn gàng trên cùng.', currentMode)
      + _buildLayoutCard('vertical', 'view_sidebar', 'Giao diện Dọc (Sidebar)', 'Thanh công cụ dọc bên trái quen thuộc.', currentMode);
  }

  function _buildLayoutCard(mode, icon, title, desc, currentMode) {
    var isActive = currentMode === mode;
    return '<div class="layout-option" onclick="AppearancePage.changeLayout(\'' + mode + '\', this)" style="flex:1; min-width:260px; max-width:320px; border:2px solid ' + (isActive ? 'var(--color-primary)' : 'var(--color-border)') + '; border-radius:12px; padding:20px; cursor:pointer; text-align:center; transition:all 0.2s; background:' + (isActive ? 'rgba(79,70,229,0.05)' : '#fff') + '; position:relative; overflow:hidden;">'
      + (isActive ? '<div style="position:absolute; top:10px; right:10px; color:var(--color-primary);"><span class="material-symbols-outlined" style="font-size:20px;">check_circle</span></div>' : '')
      + '<span class="material-symbols-outlined" style="font-size:40px; color:' + (isActive ? 'var(--color-primary)' : 'var(--color-text-secondary)') + '; margin-bottom:12px;">' + icon + '</span>'
      + '<h3 style="margin-bottom:6px; font-size:15px; font-weight:600;">' + title + '</h3>'
      + '<p style="font-size:13px; color:var(--color-text-secondary); margin:0; line-height:1.5;">' + desc + '</p></div>';
  }

  function _renderFontOptions() {
    var container = document.getElementById('font-options-container');
    if (!container) return;
    var currentFont = localStorage.getItem('pmql_font_family') || 'Plus Jakarta Sans';

    container.innerHTML = _buildFontCard('Plus Jakarta Sans', 'Sang trọng, sắc nét', currentFont, true)
      + _buildFontCard('Inter', 'Hiện đại, dễ đọc', currentFont, false)
      + _buildFontCard('Roboto', 'Tiêu chuẩn cổ điển', currentFont, false)
      + _buildFontCard('Nunito', 'Bo tròn, thân thiện', currentFont, false);
  }

  function _buildFontCard(fontName, desc, currentFont, isDefault) {
    var isActive = currentFont === fontName;
    return '<div class="font-option" onclick="AppearancePage.changeFont(\'' + fontName + '\', this)" style="flex:1; min-width:200px; border:2px solid ' + (isActive ? 'var(--color-primary)' : 'var(--color-border)') + '; border-radius:12px; padding:16px; cursor:pointer; transition:all 0.2s; background:' + (isActive ? 'rgba(79,70,229,0.05)' : '#fff') + '; position:relative;">'
      + (isActive ? '<div class="font-check-wrapper" style="position:absolute; top:10px; right:10px; color:var(--color-primary);"><span class="material-symbols-outlined" style="font-size:18px;">check_circle</span></div>' : '')
      + '<h3 style="margin:0 0 4px 0; font-size:16px; font-weight:600; font-family:\'' + fontName + '\', sans-serif;">Aa Bb Cc</h3>'
      + '<div style="font-size:14px; font-weight:600; margin-bottom:4px;">' + fontName + (isDefault ? ' (Mặc định)' : '') + '</div>'
      + '<p style="font-size:12px; color:var(--color-text-secondary); margin:0;">' + desc + '</p></div>';
  }

  function changeLayout(mode, el) {
    if (typeof Navbar === 'undefined' || typeof Navbar.setLayout === 'undefined') return;
    var currentMode = Navbar.getLayout();
    if (currentMode === mode) return;
    Navbar.setLayout(mode);
    Navbar.moveContentToApp();
    Navbar.render('navbar-container');
    if (mode === 'vertical') Navbar.moveContentToVerticalMain();

    setTimeout(function () {
      var allOptions = document.querySelectorAll('.layout-option');
      allOptions.forEach(function (opt) {
        opt.style.borderColor = 'var(--color-border)';
        opt.style.background = '#fff';
        var icon = opt.querySelector('span.material-symbols-outlined');
        if (icon) icon.style.color = 'var(--color-text-secondary)';
        var checkMark = opt.querySelector('div[style*="position:absolute"]');
        if (checkMark) checkMark.remove();
      });
      if (el) {
        el.style.borderColor = 'var(--color-primary)';
        el.style.background = 'rgba(79,70,229,0.05)';
        var icon = el.querySelector('span.material-symbols-outlined');
        if (icon) icon.style.color = 'var(--color-primary)';
        var checkWrap = document.createElement('div');
        checkWrap.style = 'position:absolute; top:10px; right:10px; color:var(--color-primary);';
        checkWrap.innerHTML = '<span class="material-symbols-outlined" style="font-size:20px;">check_circle</span>';
        el.appendChild(checkWrap);
      }
      UIToast.show('Đã chuyển đổi giao diện thành công');
    }, 50);
  }

  function changeFont(fontFamily, el) {
    var currentFont = localStorage.getItem('pmql_font_family') || 'Plus Jakarta Sans';
    if (currentFont === fontFamily) return;
    localStorage.setItem('pmql_font_family', fontFamily);
    document.documentElement.style.setProperty('--font-family', '"' + fontFamily + '", sans-serif');

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
      checkWrap.style = 'position:absolute; top:10px; right:10px; color:var(--color-primary);';
      checkWrap.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">check_circle</span>';
      el.appendChild(checkWrap);
    }
    UIToast.show('Đã đổi phông chữ sang ' + fontFamily);
  }

  return { render: render, changeLayout: changeLayout, changeFont: changeFont };
})();
