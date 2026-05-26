/**
 * Router — Hash-based SPA routing cho Quản lý Tiệc Cưới
 * ─────────────────────────────────────────────────────
 * Kiến trúc: Mảng ROUTES cấu hình → Dynamic script loading → pageFn.render()
 * Template do Page Module tự fetch (Router cung cấp cache layer)
 * Tham khảo: Medstand Router v9
 */
var Router = (function () {

  // ── Route definitions ──────────────────────────────────────────────────
  var ROUTES = [
    { path: '/dashboard', template: 'src/pages/dashboard/dashboard.html', script: 'src/pages/dashboard/dashboard.js', perm: 'tongquan', title: 'Tổng quan', pageFn: 'DashboardPage' },
    { path: '/components-demo', template: 'src/pages/components-demo/components-demo.html', script: 'src/pages/components-demo/components-demo.js', perm: 'uidemo', title: 'Bản test Component', pageFn: 'ComponentsDemoPage' },
    { path: '/appearance', template: 'src/pages/appearance/appearance.html', script: 'src/pages/appearance/appearance.js', perm: '', title: 'Cấu hình Giao diện', pageFn: 'AppearancePage' }
  ];

  function addDynamicRoutes(menus) {
    if (!menus || !Array.isArray(menus)) return;

    var currentHash = window.location.hash.replace('#', '').split('?')[0] || '/dashboard';
    var needsReload = false;

    menus.forEach(function (m) {
      // url có thể nằm ở URLPara hoặc urlPara
      var rawUrl = m.URLPara || m.urlPara || '';
      if (!rawUrl || rawUrl.trim() === '') return;

      // Chỉnh sửa: Loại bỏ dấu '#' và '/' thừa nếu người dùng lỡ nhập vào DB (vd: '#/customers' -> 'customers')
      var url = rawUrl.trim().replace(/^#\/?/, '').replace(/^\//, '');
      if (url === '') return;

      var path = '/' + url;

      // Bỏ qua nếu đã tồn tại
      if (ROUTES.find(function (r) { return r.path === path; })) return;

      var route = {
        path: path,
        perm: m.FormName || m.formName,
        title: m.MenuName || m.VN || m.label || ''
      };

      var formKey = m.FormKey || m.formKey;
      var formName = m.FormName || m.formName || '';

      var existingConfig = null;
      
      // 1. Tìm config dựa vào FormKey hoặc FormName
      if (window.APP_MODULES) {
        if (formKey && window.APP_MODULES[formKey]) {
          existingConfig = window.APP_MODULES[formKey];
        } else if (formName) {
          var targetName = formName.toLowerCase();
          for (var k in window.APP_MODULES) {
            if (window.APP_MODULES[k].FormName && window.APP_MODULES[k].FormName.toLowerCase() === targetName) {
              existingConfig = window.APP_MODULES[k];
              formKey = k;
              break;
            }
          }
        }
        
        // 2. Fallback: tự suy luận từ urlPara (vd: form-builder -> FORM_BUILDER)
        if (!existingConfig) {
          var deducedKey = url.trim().replace(/-/g, '_').toUpperCase();
          if (window.APP_MODULES[deducedKey]) {
            existingConfig = window.APP_MODULES[deducedKey];
            formKey = deducedKey;
          }
        }
      }

      // Quyết định dùng DynamicFormEngine:
      // - Nếu tìm thấy config trong APP_MODULES
      // - HOẶC nếu FormName bắt đầu bằng chữ "frm"
      if (existingConfig || formName.toLowerCase().indexOf('frm') === 0) {
        // Dùng DynamicFormEngine
        route.script = 'src/js/core/DynamicFormEngine.js';
        route.pageFn = 'DynamicFormEngine';
        route.config = existingConfig || { FormName: formName, PageTitle: route.title };
      } else {
        // Convention: template và script nằm trong thư mục trùng tên URLPara
        var folder = url.trim();
        route.template = 'src/pages/' + folder + '/' + folder + '.html';
        route.script = 'src/pages/' + folder + '/' + folder + '.js';

        // Convert urlPara to PascalCase (vd: hall-status -> HallStatusPage)
        var camel = folder.split('-').map(function (s) {
          return s.charAt(0).toUpperCase() + s.slice(1);
        }).join('');
        route.pageFn = camel + 'Page';
      }

      ROUTES.push(route);
      _routeMap[path] = route; // Update Map

      if (path === currentHash) {
        needsReload = true;
      }
    });

    if (needsReload) {
      if (!_currentRoute || _currentRoute.path !== currentHash) {
        // Delay slightly to allow Navbar to finish rendering before we trigger routing
        setTimeout(function() {
          _handleRoute();
        }, 50);
      }
    }
  }

  // ── State ──────────────────────────────────────────────────────────────
  var _currentRoute = null;
  var _loadedScripts = {};
  var _templateCache = {};
  var _appVersion = '2.12'; // Bump để làm mới cache html/script động
  var _navId = 0; // Token chặn race-condition

  // ── Template cache (dùng chung cho cả Router lẫn Page modules) ─────────
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

  // ── Preload templates phổ biến (tải trước nền) ─────────────────────────
  function _preloadTemplates() {
    var priority = ['/dashboard', '/visitor', '/booking'];
    priority.forEach(function (p) {
      var r = _findRoute(p);
      if (r && r.template) fetchTemplate(r.template).catch(function () { });
    });
  }

  // ── Dynamic Script Loading ─────────────────────────────────────────────
  function _loadScript(src) {
    return new Promise(function (resolve, reject) {
      if (_loadedScripts[src]) { resolve(); return; }
      var el = document.createElement('script');
      el.src = src + '?v=' + _appVersion;
      el.onload = function () { _loadedScripts[src] = true; resolve(); };
      el.onerror = function () { reject(new Error('Script load failed: ' + src)); };
      document.body.appendChild(el);
    });
  }

  // ── Route matching (dùng Map nội bộ cho O(1) lookup) ───────────────────
  var _routeMap = {};
  ROUTES.forEach(function (r) { _routeMap[r.path] = r; });

  function _findRoute(path) {
    return _routeMap[path] || null;
  }

  // ── Page Transition ────────────────────────────────────────────────────
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

  // ── Trang lỗi ──────────────────────────────────────────────────────────
  function _render404($el, path) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:50vh;text-align:center;padding:48px 24px;">' +
      '<span class="material-symbols-outlined" style="font-size:72px;color:var(--color-border-strong);margin-bottom:16px;">search_off</span>' +
      '<h2 style="font-size:2rem;font-weight:700;margin:0 0 8px;">404</h2>' +
      '<p style="color:var(--color-text-secondary);margin:0 0 24px;">Trang <code style="background: rgba(148, 163, 184, 0.1);padding:2px 8px;border-radius:4px;">' + path + '</code> không tồn tại</p>' +
      '<a href="#/dashboard" class="btn btn-primary" style="text-decoration:none;">Về trang chủ</a>' +
      '</div>';
  }

  function _renderAccessDenied($el) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:50vh;text-align:center;padding:48px 24px;">' +
      '<span class="material-symbols-outlined" style="font-size:72px;color:var(--color-danger);margin-bottom:16px;">lock</span>' +
      '<p style="color:var(--color-danger);font-size:1.1rem;font-weight:500;">Bạn không có quyền xem trang này</p>' +
      '</div>';
  }

  function _renderPlaceholder($el, title) {
    $el.innerHTML =
      '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:40vh;text-align:center;padding:48px;">' +
      '<span class="material-symbols-outlined" style="font-size:64px;color:var(--color-border-strong);opacity:0.4;margin-bottom:16px;">construction</span>' +
      '<h3 style="margin:0 0 8px;font-weight:600;">' + title + '</h3>' +
      '<p style="color:var(--color-text-secondary);margin:0;">Trang này đang được phát triển...</p>' +
      '</div>';
  }

  function _renderError($el, message) {
    $el.innerHTML =
      '<div class="card"><div class="card-body" style="color:var(--color-danger);">' +
      '<span class="material-symbols-outlined" style="vertical-align:middle;margin-right:8px;">error</span>' + message +
      '</div></div>';
  }

  // ── Cập nhật navigation UI ─────────────────────────────────────────────
  function _updateNavActive(hash) {
    // Sidebar nav
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
    // Navbar (nếu đang dùng layout ngang)
    document.querySelectorAll('.main-nav .nav-link, .sub-menu-item').forEach(function (el) {
      el.classList.remove('active');
      if (el.getAttribute('href') === '#' + hash) el.classList.add('active');
    });
  }

  // ── Main Route Handler ─────────────────────────────────────────────────
  function _handleRoute() {
    _navId++;
    var currentNav = _navId;

    var rawHash = window.location.hash.replace('#', '') || '/dashboard';
    var hashParts = rawHash.split('?');
    var pathOnly = hashParts[0];
    var route = _findRoute(pathOnly);

    // Kéo quyền động nếu máy khác vừa cập nhật (Đảm bảo Realtime)
    _syncPermissionsIfNeeded().then(function () {
      if (currentNav !== _navId) return;

      var $content = document.getElementById('app-content');
      var $pageTitle = document.getElementById('page-title');

      // Scroll to top
      window.scrollTo({ top: 0, behavior: 'instant' });

      // Cập nhật nav UI
      _updateNavActive(pathOnly);

      // 404
      if (!route) {
        if ($pageTitle) $pageTitle.innerText = '404 — Không tìm thấy';
        document.title = '404 | Quản lý Tiệc Cưới';
        _render404($content, rawHash);
        return;
      }

      // Kiểm tra quyền
      var targetPerm = route.perm || route.module;
      if (targetPerm && !Permission.canView(targetPerm)) {
        if ($pageTitle) $pageTitle.innerText = 'Từ chối truy cập';
        _renderAccessDenied($content);
        return;
      }

      // Cập nhật title
      if ($pageTitle) $pageTitle.innerText = route.title;
      document.title = route.title + ' | Quản lý Tiệc Cưới';
      document.body.setAttribute('data-page', pathOnly.replace('/', ''));

      // ── Trường hợp 1: Có script → load script → pageFn.render() ──
      // (Page module tự fetch template bên trong render nếu cần)
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
              // Xóa sạch nội dung cũ, cấp wrapper mới để các hàm fetch async không ghi đè lên trang khác
              $content.innerHTML = '';
              var wrapper = document.createElement('div');
              wrapper.className = 'page-wrapper';
              $content.appendChild(wrapper);
              mod.render(wrapper, route.config || null);
            } else {
              _renderError($content, 'Không tìm thấy module: ' + route.pageFn);
            }
            _fadeIn($content);
            _currentRoute = route;
          })
          .catch(function (err) {
            if (err.message === 'ABORTED') return; // Bỏ qua nếu là thao tác hủy do click liên tục
            console.error('[Router]', err);
            _renderError($content, 'Lỗi tải module: ' + err.message);
            _fadeIn($content);
          });
        return;
      }

      // ── Trường hợp 2: Chỉ có template (dashboard, trang tĩnh) ──
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
          })
          .catch(function (err) {
            if (err.message === 'ABORTED') return;
            console.error('[Router]', err);
            _renderError($content, 'Lỗi tải template: ' + err.message);
            _fadeIn($content);
          });
        return;
      }

      // ── Trường hợp 3: Trang chưa code ──
      _renderPlaceholder($content, route.title);
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
          console.error('[Router] Lỗi tải quyền mới:', e);
        });
      }
    }).catch(function (e) {
      console.error('[Router] Lỗi kiểm tra version quyền:', e);
      return Promise.resolve();
    });
  }

  // ── Init ───────────────────────────────────────────────────────────────
  function init() {
    window.addEventListener('hashchange', _handleRoute);

    // BẢO MẬT: Kiểm tra Version Quyền 1 lần duy nhất lúc F5 tải lại màn hình
    if (typeof ApiClient !== 'undefined' && typeof API_CONFIG !== 'undefined' && API_CONFIG.ENDPOINTS.PERMISSIONS.GET_VERSION) {
      ApiClient.get(API_CONFIG.ENDPOINTS.PERMISSIONS.GET_VERSION, { silent: true }).then(function (res) {
        var localVer = localStorage.getItem('pmql_permission_ver');
        var records = res.list || res.records || [];
        var svVersion = records.length > 0 ? records[0].version : (res.version || '');

        if (svVersion && svVersion !== localVer) {
          // Vân tay bị lệch -> Tải quyền mới
          var userJson = localStorage.getItem('pmql_user');
          var userObj = userJson ? JSON.parse(userJson) : {};
          ApiClient.post(API_CONFIG.ENDPOINTS.PERMISSIONS.GET_MY_PERMISSIONS, { Username: userObj.UserName }, { silent: true }).then(function (permRes) {
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
            _finishInit();
          }).catch(_finishInit);
        } else {
          _finishInit();
        }
      }).catch(_finishInit);
    } else {
      _finishInit();
    }
  }

  function _finishInit() {
    if (!window.location.hash) {
      window.location.hash = '#/dashboard';
    } else {
      _handleRoute();
    }
    setTimeout(_preloadTemplates, 500);
  }

  // ── Public API ─────────────────────────────────────────────────────────
  return {
    init: init,
    ROUTES: ROUTES,
    addDynamicRoutes: addDynamicRoutes,
    fetchTemplate: fetchTemplate   // Cho page modules dùng chung cache layer
  };
})();
