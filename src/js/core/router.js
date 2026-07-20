/**
 * Router â€” Hash-based SPA routing cho Quáº£n lÃ½ Tiá»‡c CÆ°á»›i
 * â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
 * Kiáº¿n trÃºc: Máº£ng ROUTES cáº¥u hÃ¬nh â†’ Dynamic script loading â†’ pageFn.render()
 * Template do Page Module tá»± fetch (Router cung cáº¥p cache layer)
 * Tham kháº£o: Medstand Router v9
 */
var Router = (function () {

  function _asBool(value) {
    return value === 1 || value === '1' || value === true || value === 'true';
  }

  // â”€â”€ Route definitions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  var ROUTES = [
    { path: '/dashboard', template: 'src/pages/dashboard/dashboard.html', script: 'src/pages/dashboard/dashboard.js', perm: 'tongquan', title: 'Tá»•ng quan', pageFn: 'DashboardPage', hideHeader: true },
    { path: '/components-demo', template: 'src/pages/components-demo/components-demo.html', script: 'src/pages/components-demo/components-demo.js', perm: 'uidemo', title: 'Báº£n test Component', pageFn: 'ComponentsDemoPage' },
    { path: '/appearance', template: 'src/pages/appearance/appearance.html', script: 'src/pages/appearance/appearance.js', perm: '', title: 'Cáº¥u hÃ¬nh Giao diá»‡n', pageFn: 'AppearancePage' },
    { path: '/document-manager', template: 'src/pages/document-manager/document-manager.html', script: 'src/pages/document-manager/document-manager.js', perm: '', title: 'Workspace TÃ i Liá»‡u', pageFn: 'DocumentManagerPage', hideHeader: true },

    { path: '/categories', template: 'src/pages/categories/categories.html', script: 'src/pages/categories/categories.js', perm: '', title: '', pageFn: 'CategoriesPage' },
    { path: '/inventory', template: 'src/pages/inventory/inventory.html', script: 'src/pages/inventory/inventory.js', perm: '', title: 'Kho & Äá»‹nh lÆ°á»£ng', pageFn: 'InventoryPage' },
    { path: '/cash-flow', template: 'src/pages/cash-flow/cash-flow.html', script: 'src/pages/cash-flow/cash-flow.js', perm: '', title: 'Káº¿ toÃ¡n & Quá»¹ tiá»n máº·t', pageFn: 'CashFlowPage' },
    { path: '/calendar', template: 'src/pages/calendar/calendar.html', script: 'src/pages/calendar/calendar.js', perm: '', title: '', pageFn: 'CalendarPage' },
    { path: '/menus', template: 'src/pages/menus/menus.html', script: 'src/pages/menus/menus.js', perm: '', title: '', pageFn: 'MenusPage' },
    { path: '/report-revenue', template: 'src/pages/report-revenue/report-revenue.html', script: 'src/pages/report-revenue/report-revenue.js', perm: '', title: '', pageFn: 'ReportRevenuePage' },
    { path: '/report-cost', template: 'src/pages/report-cost/report-cost.html', script: 'src/pages/report-cost/report-cost.js', perm: '', title: '', pageFn: 'ReportCostPage' },
    { path: '/report-other', template: 'src/pages/report-other/report-other.html', script: 'src/pages/report-other/report-other.js', perm: '', title: '', pageFn: 'ReportOtherPage' },
    { path: '/survey', template: 'src/pages/survey/survey.html', script: 'src/pages/survey/survey.js', perm: '', title: '', pageFn: 'SurveyPage' },
    { path: '/hall-status', template: 'src/pages/hall-status/hall-status.html', script: 'src/pages/hall-status/hall-status.js', perm: '', title: '', pageFn: 'HallStatusPage' },
    { path: '/settings', template: 'src/pages/settings/settings.html', script: 'src/pages/settings/settings.js', perm: '', title: '', pageFn: 'SettingsPage' },
    { path: '/permissions', template: 'src/pages/permissions/permissions.html', script: 'src/pages/permissions/permissions.js', perm: '', title: '', pageFn: 'PermissionsPage' }
  ];


  function addDynamicRoutes(menus) {
    if (!menus || !Array.isArray(menus)) return;

    var currentHash = window.location.hash.replace('#', '').split('?')[0] || '/dashboard';
    var needsReload = false;

    menus.forEach(function (m) {
      // url cÃ³ thá»ƒ náº±m á»Ÿ URLPara hoáº·c urlPara
      var rawUrl = m.URLPara || m.urlPara || '';
      if (!rawUrl || rawUrl.trim() === '') return;

      // Chá»‰nh sá»­a: Loáº¡i bá» dáº¥u '#' vÃ  '/' thá»«a náº¿u ngÆ°á»i dÃ¹ng lá»¡ nháº­p vÃ o DB (vd: '#/customers' -> 'customers')
      var url = rawUrl.trim().replace(/^#\/?/, '').replace(/^\//, '');
      if (url === '') return;

      var path = '/' + url;

      var existingRoute = ROUTES.find(function (r) { return r.path === path; });

      if (existingRoute) {
        // Cáº­p nháº­t thÃ´ng tin tá»« database náº¿u route custom Ä‘Ã£ Ä‘Æ°á»£c Ä‘á»‹nh nghÄ©a cá»©ng
        existingRoute.perm = m.FormName || m.formName || existingRoute.perm;
        existingRoute.title = m.MenuName || m.VN || m.label || existingRoute.title || '';
        existingRoute.subTitle = m.SubTitle || m.subTitle || existingRoute.subTitle || '';
        if (m.HideHeader || m.hideHeader) existingRoute.hideHeader = true;

        _routeMap[path] = existingRoute;
        if (path === currentHash) needsReload = true;
        return;
      }

      var route = {
        path: path,
        perm: m.FormName || m.formName,
        title: m.MenuName || m.VN || m.label || '',
        subTitle: m.SubTitle || m.subTitle || '',
        hideHeader: m.HideHeader || m.hideHeader || false
      };

      var formKey = m.FormKey || m.formKey || '';
      var formName = m.TableName || m.tableName || '';
      if (!formKey || !formName) {
        console.warn('[Router] Bỏ qua menu động chưa cấu hình SY_FrmLstTbl:', m.MenuID || m.id || rawUrl);
        return;
      }

      // Dynamic routes are configured only by the menu and SY_FrmLstTbl metadata.
      route.script = 'src/js/core/DynamicFormEngine.js';
      route.pageFn = 'DynamicFormEngine';
      route.config = {
        FormID: formKey,
        FormName: formName,
        PrimaryKey: m.PrimaryKey || m.primaryKey || '',
        IsPaged: false,
        HideAddBtn: !_asBool(m.IsAdd || m.isAdd),
        HideEditBtn: !_asBool(m.IsUpdate || m.isUpdate),
        HideDeleteBtn: !_asBool(m.IsDelete || m.isDelete),
        HidePrintBtn: false,
        UserCanAdd: _asBool(m.IsAdd || m.isAdd),
        UserCanEdit: _asBool(m.IsUpdate || m.isUpdate),
        UserCanDelete: _asBool(m.IsDelete || m.isDelete),
        PageTitle: route.title,
        PageSubtitle: route.subTitle
      };

      ROUTES.push(route);
      _routeMap[path] = route; // Update Map

      if (path === currentHash) {
        needsReload = true;
      }
    });

    if (needsReload) {
      if (!_currentRoute || _currentRoute.path !== currentHash) {
        // Delay slightly to allow Navbar to finish rendering before we trigger routing
        setTimeout(function () {
          _handleRoute();
        }, 50);
      }
    }
  }

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  var _currentRoute = null;
  var _loadedScripts = {};
  var _templateCache = {};
  var _appVersion = '2.13'; // Bump Ä‘á»ƒ lÃ m má»›i cache html/script Ä‘á»™ng
  var _navId = 0; // Token cháº·n race-condition

  // â”€â”€ Template cache (dÃ¹ng chung cho cáº£ Router láº«n Page modules) â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function fetchTemplate(url) {
    if (_templateCache[url]) return Promise.resolve(_templateCache[url]);
    return fetch(url + '?v=' + _appVersion)
      .then(function (res) {
        if (!res.ok) throw new Error('Template not found: ' + url);
        return res.text();
      })
      .then(function (html) {
        _templateCache[url] = html;
        return html;
      });
  }

  // â”€â”€ Preload templates phá»• biáº¿n (táº£i trÆ°á»›c ná»n) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _preloadTemplates() {
    var priority = ['/dashboard', '/visitor', '/booking'];
    priority.forEach(function (p) {
      var r = _findRoute(p);
      if (r && r.template) fetchTemplate(r.template).catch(function () { });
    });
  }

  // â”€â”€ Dynamic Script Loading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _loadScript(src) {
    return new Promise(function (resolve, reject) {
      if (_loadedScripts[src]) { resolve(); return; }
      var el = document.createElement('script');
      // ThÃªm cache-buster Ä‘á»ƒ Ä‘áº£m báº£o luÃ´n táº£i file JS má»›i nháº¥t
      el.src = src + '?v=' + Date.now();
      el.onload = function () { _loadedScripts[src] = true; resolve(); };
      el.onerror = function () { reject(new Error('Script load failed: ' + src)); };
      document.body.appendChild(el);
    });
  }

  // â”€â”€ Route matching (dÃ¹ng Map ná»™i bá»™ cho O(1) lookup) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  var _routeMap = {};
  ROUTES.forEach(function (r) { _routeMap[r.path] = r; });

  function _findRoute(path) {
    return _routeMap[path] || null;
  }

  // â”€â”€ Page Transition â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _fadeOut($el) {
    return new Promise(function (resolve) {
      $el.style.opacity = '0';
      $el.style.transition = 'opacity 120ms ease';
      setTimeout(resolve, 120);
    });
  }

  function _fadeIn($el) {
    $el.style.opacity = '1';
    $el.style.transition = 'opacity 180ms ease';
  }

  // â”€â”€ Trang lá»—i â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _render404($el, path) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:50vh;text-align:center;padding:48px 24px;">' +
      '<span class="material-symbols-outlined" style="font-size:72px;color:var(--color-border-strong);margin-bottom:16px;">search_off</span>' +
      '<h2 style="font-size:2rem;font-weight:700;margin:0 0 8px;">404</h2>' +
      '<p style="color:var(--color-text-secondary);margin:0 0 24px;">Trang <code style="background: rgba(148, 163, 184, 0.1);padding:2px 8px;border-radius:4px;">' + path + '</code> khÃ´ng tá»“n táº¡i</p>' +
      '<a href="javascript:void(0)" onclick="window.location.href = window.location.pathname + \'#/dashboard\'" class="btn btn-primary" style="text-decoration:none;">Vá» trang chá»§</a>' +
      '</div>';
  }

  function _renderAccessDenied($el) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:50vh;text-align:center;padding:48px 24px;">' +
      '<span class="material-symbols-outlined" style="font-size:72px;color:var(--color-danger);margin-bottom:16px;">lock</span>' +
      '<p style="color:var(--color-danger);font-size:1.1rem;font-weight:500;">Báº¡n khÃ´ng cÃ³ quyá»n xem trang nÃ y</p>' +
      '</div>';
  }

  function _renderPlaceholder($el, title) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:40vh;text-align:center;padding:48px;">' +
      '<span class="material-symbols-outlined" style="font-size:64px;color:var(--color-border-strong);opacity:0.4;margin-bottom:16px;">construction</span>' +
      '<h3 style="margin:0 0 8px;font-weight:600;">' + title + '</h3>' +
      '<p style="color:var(--color-text-secondary);margin:0;">Trang nÃ y Ä‘ang Ä‘Æ°á»£c phÃ¡t triá»ƒn...</p>' +
      '</div>';
  }

  function _renderError($el, message) {
    $el.innerHTML =
      '<div class="card"><div class="card-body" style="color:var(--color-danger);">' +
      '<span class="material-symbols-outlined" style="vertical-align:middle;margin-right:8px;">error</span>' + message +
      '</div></div>';
  }

  // â”€â”€ Cáº­p nháº­t navigation UI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _updateNavActive(hash) {
    // Sidebar nav
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
    // Navbar (náº¿u Ä‘ang dÃ¹ng layout ngang)
    document.querySelectorAll('.main-nav .nav-link, .sub-menu-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
  }

  // â”€â”€ Main Route Handler â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function _handleRoute() {
    _navId++;
    var currentNav = _navId;

    var rawHash = window.location.hash.replace('#', '') || '/dashboard';
    var hashParts = rawHash.split('?');
    var pathOnly = hashParts[0];

    // Náº¿u Ä‘Æ°á»ng dáº«n lÃ  gá»‘c '/' hoáº·c rá»—ng '', tá»± Ä‘á»™ng chuyá»ƒn hÆ°á»›ng vá» '/dashboard'
    if (pathOnly === '/' || pathOnly === '') {
      window.location.hash = '#/dashboard';
      return;
    }

    var route = _findRoute(pathOnly);

    if (typeof LoadingBar !== 'undefined') {
      LoadingBar.start();
    }

    // KÃ©o quyá»n Ä‘á»™ng náº¿u mÃ¡y khÃ¡c vá»«a cáº­p nháº­t (Äáº£m báº£o Realtime)
    _syncPermissionsIfNeeded().then(function () {
      if (currentNav !== _navId) return;

      var $content = document.getElementById('app-content');
      var $pageTitle = document.getElementById('page-title');

      // Scroll to top
      window.scrollTo({ top: 0, behavior: 'instant' });

      // Cáº­p nháº­t nav UI
      _updateNavActive(pathOnly);

      // 404
      if (!route) {
        if ($pageTitle) $pageTitle.innerText = '404 â€” KhÃ´ng tÃ¬m tháº¥y';
        document.title = '404 | Quáº£n lÃ½ Tiá»‡c CÆ°á»›i';
        _render404($content, rawHash);
        if (typeof LoadingBar !== 'undefined') {
          LoadingBar.fail();
        }
        return;
      }

      // Kiá»ƒm tra quyá»n
      var targetPerm = route.perm || route.module;
      if (targetPerm && !Permission.canView(targetPerm)) {
        if ($pageTitle) $pageTitle.innerText = 'Tá»« chá»‘i truy cáº­p';
        _renderAccessDenied($content);
        if (typeof LoadingBar !== 'undefined') {
          LoadingBar.fail();
        }
        return;
      }

      // Cáº­p nháº­t title
      if ($pageTitle) $pageTitle.innerText = route.title;
      document.title = route.title + ' | Quáº£n lÃ½ Tiá»‡c CÆ°á»›i';
      document.body.setAttribute('data-page', pathOnly.replace('/', ''));

      // â”€â”€ TrÆ°á»ng há»£p 1: CÃ³ script â†’ load script â†’ pageFn.render() â”€â”€
      // (Page module tá»± fetch template bÃªn trong render náº¿u cáº§n)
      if (route.pageFn) {
        _fadeOut($content)
          .then(function () {
            if (currentNav !== _navId) throw new Error('ABORTED');
            if (route.script) {
              return _loadScript(route.script);
            }
            return Promise.resolve();
          })
          .then(function () {
            if (currentNav !== _navId) throw new Error('ABORTED');
            var mod = window[route.pageFn];
            if (mod && typeof mod.render === 'function') {
              // XÃ³a sáº¡ch ná»™i dung cÅ©
              $content.innerHTML = '';

              // 1. Dá»±ng Global Header (Láº¥y Title/Subtitle tá»« Router/Menu)
              if (!route.hideHeader) {
                var headerHtml =
                  '<div class="page-title-bar" id="global-header">' +
                  '<div class="page-title-info" style="display: flex; align-items: center; justify-content: flex-start; gap: 12px; flex-direction: row; flex-shrink: 0;">' +
                  '<button class="btn-back-header" onclick="history.back()" title="Quay láº¡i">' +
                  '<span class="material-symbols-outlined">arrow_back</span>' +
                  '</button>' +
                  '<div style="min-width: 0;">' +
                  '<h1 class="page-title-heading" style="margin: 0;">' + (route.title || 'Quáº£n lÃ½ Dá»¯ liá»‡u') + '</h1>' +
                  (route.subTitle ? '<span class="page-title-sub" style="margin-top: 2px;">' + route.subTitle + '</span>' : '') +
                  '</div>' +
                  '</div>' +
                  '<div class="page-title-actions" id="global-page-actions"></div>' +
                  '</div>';
                $content.insertAdjacentHTML('beforeend', headerHtml);
              }

              // 2. Dá»±ng wrapper
              var wrapper = document.createElement('div');
              wrapper.className = 'page-wrapper';
              $content.appendChild(wrapper);

              // 3. Render trang vÃ o wrapper
              mod.render(wrapper, route.config || null);
              if (typeof LoadingBar !== 'undefined') {
                LoadingBar.done();
              }
            } else {
              _renderError($content, 'KhÃ´ng tÃ¬m tháº¥y module: ' + route.pageFn);
              if (typeof LoadingBar !== 'undefined') {
                LoadingBar.fail();
              }
            }
            _fadeIn($content);
            _currentRoute = route;
          })
          .catch(function (err) {
            if (err.message === 'ABORTED') return; // Bá» qua náº¿u lÃ  thao tÃ¡c há»§y do click liÃªn tá»¥c
            console.error('[Router]', err);
            _renderError($content, 'Lá»—i táº£i module: ' + err.message);
            _fadeIn($content);
            if (typeof LoadingBar !== 'undefined') {
              LoadingBar.fail();
            }
          });
        return;
      }

      // â”€â”€ TrÆ°á»ng há»£p 2: Chá»‰ cÃ³ template (dashboard, trang tÄ©nh) â”€â”€
      if (route.template) {
        _fadeOut($content)
          .then(function () {
            if (currentNav !== _navId) throw new Error('ABORTED');
            return fetchTemplate(route.template);
          })
          .then(function (html) {
            if (currentNav !== _navId) throw new Error('ABORTED');
            $content.innerHTML = html;
            _fadeIn($content);
            _currentRoute = route;
            if (typeof LoadingBar !== 'undefined') {
              LoadingBar.done();
            }
          })
          .catch(function (err) {
            if (err.message === 'ABORTED') return;
            console.error('[Router]', err);
            _renderError($content, 'Lá»—i táº£i template: ' + err.message);
            _fadeIn($content);
            if (typeof LoadingBar !== 'undefined') {
              LoadingBar.fail();
            }
          });
        return;
      }

      // â”€â”€ TrÆ°á»ng há»£p 3: Trang chÆ°a code â”€â”€
      _renderPlaceholder($content, route.title);
      if (typeof LoadingBar !== 'undefined') {
        LoadingBar.done();
      }
    }); // End of _syncPermissionsIfNeeded
  }

  function _syncPermissionsIfNeeded() {
    if (typeof ApiClient === 'undefined' || typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.PERMISSIONS.GET_VERSION) {
      return Promise.resolve();
    }
    return ApiClient.get(API_CONFIG.ENDPOINTS.PERMISSIONS.GET_VERSION, { silent: true }).then(function (res) {
      var localVer = localStorage.getItem('pmql_permission_ver');
      var records = res.list || res.records || [];
      var svVersion = records.length > 0 ? records[0].version : (res.version || '');

      if (svVersion && svVersion !== localVer) {
        var userJson = localStorage.getItem('pmql_user');
        var userObj = userJson ? JSON.parse(userJson) : {};
        return ApiClient.post(API_CONFIG.ENDPOINTS.PERMISSIONS.GET_MY_PERMISSIONS, { Username: userObj.UserName }, { silent: true }).then(function (permRes) {
          var permMap = {};
          var permList = permRes.list || permRes.records || [];
          if (permList.length > 0) { localStorage.setItem('debug_perm_row', JSON.stringify(permList[0])); }
          function _isTrue(v) { return v === 1 || v === '1' || v === true || v === 'true' || String(v).toLowerCase() === 'true'; }
          permList.forEach(function (p) {
            var fname = p.FormName || p.formName || p.formname || p.FORMNAME;
            if (fname) {
              permMap[fname] = {
                CanView: _isTrue(p.CanView) || _isTrue(p.canView) || _isTrue(p.canview) || _isTrue(p.CANVIEW),
                CanAdd: _isTrue(p.CanAdd) || _isTrue(p.canAdd) || _isTrue(p.canadd) || _isTrue(p.CANADD),
                CanEdit: _isTrue(p.CanEdit) || _isTrue(p.canEdit) || _isTrue(p.canedit) || _isTrue(p.CANEDIT),
                CanDelete: _isTrue(p.CanDelete) || _isTrue(p.canDelete) || _isTrue(p.candelete) || _isTrue(p.CANDELETE)
              };
            }
          });
          localStorage.setItem('pmql_permissions', JSON.stringify(permMap));
          localStorage.setItem('pmql_permission_ver', svVersion);
        }).catch(function (e) {
          console.error('[Router] Lá»—i táº£i quyá»n má»›i:', e);
        });
      }
    }).catch(function (e) {
      console.error('[Router] Lá»—i kiá»ƒm tra version quyá»n:', e);
      return Promise.resolve();
    });
  }

  // â”€â”€ Init â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  function init() {
    window.addEventListener('hashchange', _handleRoute);

    // Báº¢O Máº¬T: Kiá»ƒm tra Version Quyá»n 1 láº§n duy nháº¥t lÃºc F5 táº£i láº¡i mÃ n hÃ¬nh
    _syncPermissionsIfNeeded().then(function () {
      _finishInit();
    }).catch(function (e) {
      console.error(e);
      _finishInit();
    });
  }

  function _finishInit() {
    if (!window.location.hash) {
      window.location.hash = '#/dashboard';
    } else {
      _handleRoute();
    }
    setTimeout(_preloadTemplates, 500);
  }

  // â”€â”€ Public API â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  return {
    init: init,
    ROUTES: ROUTES,
    addDynamicRoutes: addDynamicRoutes,
    fetchTemplate: fetchTemplate   // Cho page modules dÃ¹ng chung cache layer
  };
})();
