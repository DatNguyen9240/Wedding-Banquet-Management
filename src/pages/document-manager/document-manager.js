/**
 * DocumentManagerPage — Workspace Tài Liệu (OnlyOffice)
 * ──────────────────────────────────────────────────────
 * Refactored từ manager.html → dùng component pattern của project.
 * Route: #/document-manager
 */
var DocumentManagerPage = (function () {

  // ── Config ────────────────────────────────────────────────────────────
  var API_BASE       = 'http://127.0.0.1:5000/api/documents';
  var HOST_IP        = '127.0.0.1';          // Backend Node.js local
  var ONLYOFFICE_API = 'http://127.0.0.1:82/web-apps/apps/api/documents/api.js';

  // ── State ─────────────────────────────────────────────────────────────
  var _container   = null;   // page-wrapper div từ Router
  var _currentFile = null;   // tên file đang mở
  var _docEditor   = null;   // DocsAPI instance

  // ── Helpers ───────────────────────────────────────────────────────────
  function _qs(sel) { return _container ? _container.querySelector(sel) : null; }

  // ── Đảm bảo ONLYOFFICE API đã load ───────────────────────────────────
  function _ensureOnlyOfficeApi() {
    return new Promise(function (resolve, reject) {
      if (window.DocsAPI) { resolve(); return; }
      var el = document.getElementById('__onlyoffice_api__');
      if (el) {
        // Đã inject, chờ load
        var t = 0;
        var iv = setInterval(function () {
          if (window.DocsAPI) { clearInterval(iv); resolve(); }
          else if (++t > 50) { clearInterval(iv); reject(new Error('OnlyOffice API timeout')); }
        }, 200);
        return;
      }
      var script = document.createElement('script');
      script.id  = '__onlyoffice_api__';
      script.src = ONLYOFFICE_API;
      script.onload  = function () { resolve(); };
      script.onerror = function () { reject(new Error('Không thể tải OnlyOffice API')); };
      document.head.appendChild(script);
    });
  }

  // ── Build layout ──────────────────────────────────────────────────────
  function _buildLayout() {
    _container.innerHTML = '';

    // Inject scoped CSS (1 lần)
    if (!document.getElementById('__docmgr_css__')) {
      var style = document.createElement('style');
      style.id  = '__docmgr_css__';
      style.textContent = [
        '/* Ghi đè padding của .app-content để document-manager full màn hình */',
        'body[data-page="document-manager"] .app-content { padding: 0 !important; }',
        '.docmgr-wrap{display:flex;height:calc(100vh - var(--navbar-height, 56px));overflow:hidden;background:var(--color-bg-base,#0f172a);}',
        '.docmgr-sidebar{width:300px;flex-shrink:0;display:flex;flex-direction:column;background:var(--color-surface,rgba(15,23,42,.95));border-right:1px solid var(--color-border,rgba(255,255,255,.08));box-shadow:4px 0 24px rgba(0,0,0,.2);z-index:10;}',
        '.docmgr-sidebar-hd{padding:1.25rem 1rem;border-bottom:1px solid var(--color-border,rgba(255,255,255,.08));background:rgba(0,0,0,.15);}',
        '.docmgr-brand{font-size:1.05rem;font-weight:700;background:linear-gradient(135deg,#a855f7,#3b82f6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;display:flex;align-items:center;gap:.5rem;margin-bottom:1rem;}',
        '.docmgr-list{flex:1;overflow-y:auto;padding:.75rem;}',
        '.docmgr-list::-webkit-scrollbar{width:5px;}',
        '.docmgr-list::-webkit-scrollbar-thumb{background:rgba(255,255,255,.1);border-radius:10px;}',
        '.docmgr-item{padding:.85rem 1rem;background:var(--color-surface-raised,rgba(255,255,255,.02));border:1px solid transparent;border-radius:12px;margin-bottom:.6rem;cursor:pointer;transition:all .18s ease;position:relative;overflow:hidden;}',
        '.docmgr-item:hover{background:rgba(255,255,255,.06);border-color:rgba(255,255,255,.1);transform:translateX(3px);}',
        '.docmgr-item.active{background:rgba(99,102,241,.15);border-color:rgba(99,102,241,.35);}',
        '.docmgr-item.active::before{content:"";position:absolute;left:0;top:0;bottom:0;width:4px;background:var(--color-primary,#4f46e5);border-radius:4px 0 0 4px;}',
        '.docmgr-item-title{font-weight:500;font-size:.9rem;display:flex;align-items:center;gap:.4rem;color:var(--color-text-primary,#e2e8f0);margin-bottom:.25rem;}',
        '.docmgr-item-meta{font-size:.75rem;color:var(--color-text-secondary,#94a3b8);display:flex;justify-content:space-between;margin-bottom:.3rem;}',
        '.docmgr-item-actions{display:flex;gap:.35rem;opacity:0;transition:opacity .18s ease;}',
        '.docmgr-item:hover .docmgr-item-actions{opacity:1;}',
        '.docmgr-download{display:flex;align-items:center;justify-content:center;width:28px;height:28px;border-radius:7px;background:rgba(99,102,241,.15);color:#818cf8;text-decoration:none;transition:all .18s ease;}',
        '.docmgr-download:hover{background:#4f46e5;color:#fff;}',
        '.docmgr-del{background:rgba(239,68,68,.15);color:#ef4444;border:none;width:28px;height:28px;border-radius:7px;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all .18s ease;padding:0;}',
        '.docmgr-del:hover{background:#ef4444;color:#fff;}',
        '.docmgr-workspace{flex:1;position:relative;display:flex;flex-direction:column;background:#f1f5f9;}',
        '.docmgr-empty{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;background:var(--color-bg-base,#0f172a);color:var(--color-text-secondary,#94a3b8);z-index:5;}',
        '.docmgr-empty-icon{width:90px;height:90px;background:rgba(99,102,241,.06);border-radius:50%;display:flex;align-items:center;justify-content:center;margin-bottom:1.25rem;}',
        '.docmgr-empty h2{color:var(--color-text-primary,#f8fafc);font-weight:500;margin-bottom:.4rem;font-size:1.3rem;}',
        '#docmgr-editor-area{flex:1;width:100%;height:100%;}',
        '.docmgr-onerror{display:flex;align-items:center;justify-content:center;height:100%;font-size:1rem;color:#ef4444;padding:2rem;text-align:center;}'
      ].join('');
      document.head.appendChild(style);
    }

    var html = [
      '<div class="docmgr-wrap">',

        // ── Sidebar ──
        '<aside class="docmgr-sidebar">',
          '<div class="docmgr-sidebar-hd">',
            '<div class="docmgr-brand">',
              '<span class="material-symbols-outlined">folder_open</span>',
          'Workspace Tài Liệu',
            '</div>',
          '</div>',
          '<div class="docmgr-list" id="docmgr-list">',
            '<div style="text-align:center;padding:2rem;color:#94a3b8">Đang tải dữ liệu...</div>',
          '</div>',
        '</aside>',

        // ── Workspace ──
        '<main class="docmgr-workspace">',
          '<div class="docmgr-empty" id="docmgr-empty">',
            '<div class="docmgr-empty-icon">',
              '<span class="material-symbols-outlined" style="font-size:40px;color:var(--color-primary,#4f46e5);">description</span>',
            '</div>',
            '<h2>Chưa chọn tài liệu</h2>',
            '<p>Chọn một tài liệu bên trái hoặc tạo mới để bắt đầu chỉnh sửa</p>',
          '</div>',
          '<div id="docmgr-editor-area"></div>',
        '</main>',

      '</div>',

      // (Đã xóa modal template raw html, chuyển sang dùng OnlyOffice)
    ].join('');

    _container.innerHTML = html;
    _bindEvents();
    _loadDocuments();
  }

  // ── Bind events ───────────────────────────────────────────────────────
  function _bindEvents() {
    // (Không còn nút Tạo tài liệu — tài liệu được xuất từ trang Hợp Đồng / Đặt Cọc)
  }


  // ── Load danh sách tài liệu ───────────────────────────────────────────
  function _loadDocuments() {
    fetch(API_BASE)
      .then(function (res) { return res.json(); })
      .then(function (json) {
        var list = _qs('#docmgr-list');
        if (!list) return;
        if (!json.data || json.data.length === 0) {
          list.innerHTML = '<div style="text-align:center;padding:2rem;color:#94a3b8;">Chưa có tài liệu nào</div>';
          return;
        }
        list.innerHTML = '';
        json.data.forEach(function (doc) {
          var dateStr = new Date(doc.updatedAt).toLocaleDateString('vi-VN');
          var div = document.createElement('div');
          div.className = 'docmgr-item' + (_currentFile === doc.fileName ? ' active' : '');
          div.innerHTML =
            '<div class="docmgr-item-title">' +
              '<span class="material-symbols-outlined" style="font-size:16px;color:#818cf8;">description</span>' +
              _escHtml(doc.fileName) +
            '</div>' +
            '<div class="docmgr-item-meta">' +
              '<span>' + _escHtml(doc.size || '') + '</span>' +
              '<span>' + dateStr + '</span>' +
            '</div>' +
            '<div class="docmgr-item-actions">' +
              '<a class="docmgr-download" href="http://' + HOST_IP + ':5000/uploads/' + encodeURIComponent(doc.fileName) + '" download="' + _escHtml(doc.fileName) + '" title="Tải xuống" onclick="event.stopPropagation()">' +
                '<span class="material-symbols-outlined" style="font-size:16px;">download</span>' +
              '</a>' +
              '<button class="docmgr-del" title="Xóa tài liệu">' +
                '<span class="material-symbols-outlined" style="font-size:16px;">delete</span>' +
              '</button>' +
            '</div>';

          div.addEventListener('click', function () { _openEditor(doc.fileName); });
          var delBtn = div.querySelector('.docmgr-del');
          if (delBtn) delBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            _deleteDocument(doc.fileName);
          });

          list.appendChild(div);
        });
      })
      .catch(function (err) {
        console.error('[DocumentManager]', err);
        var list = _qs('#docmgr-list');
        if (list) list.innerHTML = '<div style="text-align:center;padding:2rem;color:#ef4444;">Lỗi kết nối Server!</div>';
      });
  }

  // ── Xem tài liệu (iframe — file .doc là HTML) ─────────────────────────
  function _openEditor(fileName) {
    _currentFile = fileName;
    _loadDocuments(); // Re-render list để cập nhật class .active

    var empty = _qs('#docmgr-empty');
    if (empty) empty.style.display = 'none';

    var area = _qs('#docmgr-editor-area');
    if (!area) return;

    // Destroy OnlyOffice instance cũ nếu có
    if (_docEditor && typeof _docEditor.destroyEditor === 'function') {
      try { _docEditor.destroyEditor(); } catch (e) { /* ignore */ }
      _docEditor = null;
    }

    var fileUrl = 'http://' + HOST_IP + ':5000/uploads/' + encodeURIComponent(fileName);

    // File .doc của hệ thống là HTML-based → dùng iframe render trực tiếp
    // Không cần OnlyOffice, không cần Docker
    area.innerHTML =
      '<div style="display:flex;flex-direction:column;height:100%;">' +
        // Toolbar nhỏ phía trên
        '<div style="display:flex;align-items:center;justify-content:space-between;' +
                    'padding:.6rem 1rem;background:#1e293b;border-bottom:1px solid rgba(255,255,255,.08);">' +
          '<span style="color:#94a3b8;font-size:.82rem;font-family:monospace;">' +
            '<span class="material-symbols-outlined" style="font-size:14px;vertical-align:middle;">description</span> ' +
            fileName +
          '</span>' +
          '<div style="display:flex;gap:.5rem;">' +
            '<a href="' + fileUrl + '" download="' + fileName + '" ' +
               'style="display:flex;align-items:center;gap:.3rem;padding:.35rem .8rem;border-radius:6px;' +
                      'background:rgba(99,102,241,.2);color:#818cf8;text-decoration:none;font-size:.8rem;">' +
              '<span class="material-symbols-outlined" style="font-size:14px;">download</span> Tải về' +
            '</a>' +
            '<button id="docmgr-btn-edit-tpl" ' +
                    'style="display:flex;align-items:center;gap:.3rem;padding:.35rem .8rem;border-radius:6px;' +
                           'background:rgba(255,255,255,.06);color:#94a3b8;border:none;cursor:pointer;font-size:.8rem;">' +
              '<span class="material-symbols-outlined" style="font-size:14px;">edit</span> Chỉnh sửa template' +
            '</button>' +
          '</div>' +
        '</div>' +
        // Container cho Iframe (srcdoc sẽ được inject bằng fetch bên dưới)
        '<iframe id="docmgr-iframe" ' +
                'style="flex:1;width:100%;border:none;background:#fff;" ' +
                'sandbox="allow-same-origin">' +
        '</iframe>' +
      '</div>';

    // Fetch file content (HTML) và render vào iframe
    // Tránh việc browser tự động download file .doc
    fetch(fileUrl)
      .then(function(res) {
        if (!res.ok) throw new Error('Network response was not ok');
        return res.text();
      })
      .then(function(htmlText) {
        var iframe = _qs('#docmgr-iframe');
        if (iframe) iframe.srcdoc = htmlText;
      })
      .catch(function(err) {
        console.error('Error fetching document content:', err);
        var iframe = _qs('#docmgr-iframe');
        if (iframe) {
            iframe.outerHTML = '<div style="flex:1;display:flex;align-items:center;justify-content:center;color:#ef4444;">⚠️ Không thể hiển thị nội dung tài liệu.</div>';
        }
      });

    // Gắn sự kiện cho nút Chỉnh sửa Template
    var btnEditTpl = _qs('#docmgr-btn-edit-tpl');
    if (btnEditTpl) {
      btnEditTpl.addEventListener('click', function() {
        _openTemplateEditor(fileName);
      });
    }
  }

  // ── Chỉnh sửa Template ────────────────────────────────────────────────
  function _openTemplateEditor(fileName) {
    var type = fileName.includes('hop_dong') ? 'hop_dong' : (fileName.includes('dat_coc') ? 'dat_coc' : 'quyet_toan');
    var templateName = type + '.html';
    
    // Đóng giao diện xem tài liệu cũ
    var area = _qs('#docmgr-editor-area');
    if (!area) return;

    if (_docEditor && typeof _docEditor.destroyEditor === 'function') {
      try { _docEditor.destroyEditor(); } catch (e) { /* ignore */ }
      _docEditor = null;
    }

    area.innerHTML = '<div id="docmgr-oo-placeholder" style="width:100%;height:100%;"></div>';

    _ensureOnlyOfficeApi()
      .then(function () {
        // [QUAN TRỌNG] OnlyOffice chạy trong Docker. Nếu truyền 127.0.0.1 thì OnlyOffice sẽ tìm file trong chính container của nó (báo lỗi không tải được).
        // Cần dùng 'host.docker.internal' để Docker container có thể giao tiếp ngược ra Backend Node.js trên máy Host.
        var dockerHost = 'host.docker.internal'; 
        var fileUrl = 'http://' + dockerHost + ':5000/samples/' + templateName;
        // Callback URL trỏ tới server với isTemplate=1 để backend lưu đè vào thư mục samples
        var callbackUrl = 'http://' + dockerHost + ':5000/api/documents/callback?isTemplate=1&fileName=' + templateName;
        
        var config  = {
          document: {
            fileType: 'html',
            key: type + '_' + Date.now(),
            title: templateName,
            url: fileUrl,
            permissions: {
              edit: true,
              download: true,
              print: true,
              copy: true
            }
          },
          documentType: 'word',
          editorConfig: {
            mode: 'edit',
            callbackUrl: callbackUrl,
            lang: 'vi',
            user: {
              id: 'admin_' + Math.floor(Math.random() * 9999),
              name: _getCurrentUserName() + ' (Admin)'
            },
            customization: {
              compactHeader: false, // Mở full header để dễ edit template
              toolbarNoTabs: false,
              hideRightMenu: false
            }
          }
        };
        
        console.log('[OO Template Config]', JSON.stringify(config)); 
        var placeholder = _qs('#docmgr-oo-placeholder');
        if (placeholder) {
          _docEditor = new DocsAPI.DocEditor('docmgr-oo-placeholder', config);
          if (typeof Toast !== 'undefined') Toast.show({ message: 'Đang mở trình chỉnh sửa Template...', type: 'info' });
        }
      })
      .catch(function (err) {
        if (area) area.innerHTML = '<div class="docmgr-onerror">⚠️ Lỗi OnlyOffice: ' + err.message + '</div>';
      });
  }

  // ── Tạo tài liệu ──────────────────────────────────────────────────────
  function _createDocument() {
    var nameInput = _qs('#docmgr-filename');
    var tplInput  = _qs('#docmgr-tpl');
    if (!nameInput) return;

    var name = nameInput.value.trim();
    var templateType = tplInput ? tplInput.value : 'hop_dong';
    if (!name) {
      if (typeof Toast !== 'undefined') {
        Toast.show({ message: 'Vui lòng nhập tên tài liệu!', type: 'warning' });
      } else {
        alert('Vui lòng nhập tên tài liệu!');
      }
      return;
    }

    var btnConfirm = _qs('#docmgr-modal-confirm');
    if (btnConfirm) { btnConfirm.disabled = true; btnConfirm.textContent = 'Đang tạo...'; }

    fetch(API_BASE + '/create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ fileName: name, templateType: templateType })
    })
      .then(function (res) { return res.json(); })
      .then(function (json) {
        if (json.success) {
          _closeModal();
          _loadDocuments();
          _openEditor(json.fileName);
          if (typeof Toast !== 'undefined') {
            Toast.show({ message: 'Tạo tài liệu thành công!', type: 'success' });
          }
        } else {
          if (typeof Toast !== 'undefined') {
            Toast.show({ message: 'Lỗi: ' + (json.message || 'Không xác định'), type: 'error' });
          } else {
            alert('Lỗi: ' + json.message);
          }
        }
      })
      .catch(function () {
        if (typeof Toast !== 'undefined') {
          Toast.show({ message: 'Lỗi kết nối tới server!', type: 'error' });
        } else {
          alert('Lỗi kết nối tới server!');
        }
      })
      .finally(function () {
        if (btnConfirm) { btnConfirm.disabled = false; btnConfirm.textContent = 'Tạo ngay'; }
      });
  }

  // ── Xóa tài liệu ──────────────────────────────────────────────────────
  function _deleteDocument(fileName) {
    var msg = 'Bạn có chắc chắn muốn xóa file "' + fileName + '" không?';

    function _doDelete() {
      fetch(API_BASE + '/' + encodeURIComponent(fileName), { method: 'DELETE' })
        .then(function (res) { return res.json(); })
        .then(function (json) {
          if (json.success) {
            if (_currentFile === fileName) {
              _currentFile = null;
              if (_docEditor && typeof _docEditor.destroyEditor === 'function') {
                try { _docEditor.destroyEditor(); } catch (e) { /* ignore */ }
                _docEditor = null;
              }
              var area = _qs('#docmgr-editor-area');
              if (area) area.innerHTML = '';
              var empty = _qs('#docmgr-empty');
              if (empty) empty.style.display = '';
            }
            _loadDocuments();
            if (typeof Toast !== 'undefined') {
              Toast.show({ message: 'Đã xóa tài liệu!', type: 'success' });
            }
          } else {
            if (typeof Toast !== 'undefined') {
              Toast.show({ message: 'Lỗi: ' + (json.message || ''), type: 'error' });
            } else {
              alert('Lỗi: ' + json.message);
            }
          }
        })
        .catch(function () {
          if (typeof Toast !== 'undefined') {
            Toast.show({ message: 'Lỗi kết nối!', type: 'error' });
          } else {
            alert('Lỗi kết nối!');
          }
        });
    }

    // Dùng ConfirmModal nếu có, fallback confirm()
    if (typeof ConfirmModal !== 'undefined') {
      ConfirmModal.show({
        title: 'Xóa tài liệu',
        message: msg,
        confirmText: 'Xóa',
        danger: true,
        onConfirm: _doDelete
      });
    } else {
      if (confirm(msg)) _doDelete();
    }
  }

  // ── Utils ──────────────────────────────────────────────────────────────
  function _escHtml(str) {
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  function _getCurrentUserName() {
    try {
      var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
      return u.FullName || u.UserName || 'Nhân viên Wedding';
    } catch (e) {
      return 'Nhân viên Wedding';
    }
  }

  // ── Render (được Router gọi) ──────────────────────────────────────────
  function render(container) {
    _container   = container;
    _currentFile = null;
    _docEditor   = null;

    Router.fetchTemplate('src/pages/document-manager/document-manager.html')
      .then(function (html) {
        container.innerHTML = html;
        _buildLayout();
      })
      .catch(function () {
        _container = container;
        _buildLayout();
      });
  }

  // ── Public API ─────────────────────────────────────────────────────────
  return { render: render };
})();
