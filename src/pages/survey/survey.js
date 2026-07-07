/**
 * Module Khảo Sát Thông Tin Khách Hàng Sau Tiệc (Survey Page)
 * Route: #/survey | Module: HopDong
 * HTML Template: src/pages/survey/survey.html
 */
var SurveyPage = (function () {
  var gridApi = null;
  var surveysData = [];

  function render($container) {
    fetch('./src/pages/survey/survey.html')
      .then(function (res) { return res.text(); })
      .then(function (html) {
        $container.innerHTML = html;
        _injectHeaderActions();
        _initGrid();
        _bindEvents();
        _initStarRating();
      });
  }

  function _injectHeaderActions() {
    var globalActions = document.getElementById('global-page-actions');
    if (!globalActions) return;

    globalActions.innerHTML = '';
    if (typeof UIActionToolbar !== 'undefined') {
      globalActions.appendChild(UIActionToolbar.create({
        onAdd: _openPanel,
        onEdit: false, onDelete: false, onFilter: false, onPrint: false, onClose: false
      }));
    }
  }

  function _initGrid() {
    surveysData = [
      {
        hd_number: 'HĐ10426/001',
        customer_name: 'Nguyễn Minh Tuấn - Trần Thị Lan',
        phone: '0909.123.456',
        event_date: '15/04/2026',
        survey_date: '17/04/2026',
        kitchen_score: 5,
        service_score: 4,
        decor_score: 5,
        audio_score: 4,
        overall_rating: 'Rất hài lòng'
      },
      {
        hd_number: 'HĐ10425/003',
        customer_name: 'Phạm Hữu Khoa - Lê Ngọc Bích',
        phone: '0912.333.777',
        event_date: '10/04/2026',
        survey_date: '12/04/2026',
        kitchen_score: 3,
        service_score: 3,
        decor_score: 4,
        audio_score: 3,
        overall_rating: 'Bình thường'
      },
      {
        hd_number: 'HĐ10424/002',
        customer_name: 'Võ Thành Nam - Huỳnh Thị Mai',
        phone: '0987.555.222',
        event_date: '05/04/2026',
        survey_date: '06/04/2026',
        kitchen_score: 2,
        service_score: 2,
        decor_score: 3,
        audio_score: 3,
        overall_rating: 'Không hài lòng'
      }
    ];

    var container = document.getElementById('survey-grid-container');
    if (!container) return;

    function starsRenderer(params) {
      var score = parseInt(params.value) || 0;
      var stars = '';
      for (var i = 0; i < 5; i++) {
        stars += i < score ? '⭐' : '☆';
      }
      return '<span style="color:#f59e0b">' + stars + '</span>';
    }

    var gridOptions = {
      columnDefs: [
        { field: 'hd_number', headerName: 'Số HĐ', cellStyle: { fontWeight: '600' }, width: 140, minWidth: 120 },
        { 
          field: 'customer_name', 
          headerName: 'Khách Hàng', 
          minWidth: 220,
          cellRenderer: function(params) {
            var row = params.data;
            return '<div style="line-height: 1.3; padding: 4px 0;">' +
                   '<div class="fw-medium">' + row.customer_name + '</div>' +
                   '<div style="font-size:12px; color:var(--color-text-secondary)">' + row.phone + '</div>' +
                   '</div>';
          }
        },
        { field: 'event_date', headerName: 'Ngày Tổ Chức', width: 120, minWidth: 110 },
        { field: 'survey_date', headerName: 'Ngày Khảo Sát', width: 120, minWidth: 110 },
        { field: 'kitchen_score', headerName: 'Chất lượng Bếp', cellStyle: { textAlign: 'center' }, headerClass: 'text-center', cellRenderer: starsRenderer, width: 130 },
        { field: 'service_score', headerName: 'Phục vụ', cellStyle: { textAlign: 'center' }, headerClass: 'text-center', cellRenderer: starsRenderer, width: 110 },
        { field: 'decor_score', headerName: 'Trang trí', cellStyle: { textAlign: 'center' }, headerClass: 'text-center', cellRenderer: starsRenderer, width: 110 },
        { field: 'audio_score', headerName: 'Âm thanh / ÁS', cellStyle: { textAlign: 'center' }, headerClass: 'text-center', cellRenderer: starsRenderer, width: 130 },
        { 
          field: 'overall_rating', 
          headerName: 'Đánh giá Chung', 
          cellStyle: { textAlign: 'center' },
          headerClass: 'text-center',
          width: 140,
          cellRenderer: function(params) {
            var val = params.value;
            var badgeClass = 'warning';
            if (val === 'Rất hài lòng' || val === 'Hài lòng') badgeClass = 'success';
            if (val === 'Không hài lòng' || val === 'Rất không hài lòng') badgeClass = 'danger';
            return '<span class="status-badge ' + badgeClass + '">' + val + '</span>';
          }
        },
        {
          headerName: 'Thao Tác',
          sortable: false,
          filter: false,
          floatingFilter: false,
          cellStyle: { textAlign: 'right' },
          headerClass: 'text-end',
          width: 120,
          cellRenderer: function(params) {
            var row = params.data;
            var wrapper = document.createElement('div');
            wrapper.style.display = 'inline-flex';
            wrapper.style.gap = '4px';
            wrapper.style.justifyContent = 'flex-end';
            wrapper.style.width = '100%';

            wrapper.innerHTML = `
              <button class="icon-btn" onclick="SurveyPage.openEdit('${row.hd_number}')" title="Chỉnh sửa"><span class="material-symbols-outlined" style="font-size: 18px;">edit</span></button>
            `;
            return wrapper;
          }
        }
      ],
      rowData: surveysData
    };

    gridApi = AppGrid.create(container, gridOptions);
  }

  // ── Mở / Đóng Panel ──────────────────────────────────────────────────
  function _openPanel() {
    var overlay = document.getElementById('survey-form-overlay');
    var panel   = document.getElementById('survey-form-panel');
    if (overlay) overlay.classList.add('active');
    if (panel)   panel.style.right = '0';
  }

  function _closePanel() {
    var overlay = document.getElementById('survey-form-overlay');
    var panel   = document.getElementById('survey-form-panel');
    if (overlay) overlay.classList.remove('active');
    if (panel)   panel.style.right = '-840px';
  }

  function openEdit(hdNumber) {
    var s = surveysData.find(item => item.hd_number === hdNumber);
    if (s) {
      document.getElementById('survey-inp-hdnumber').value = s.hd_number;
      document.getElementById('survey-inp-customer').value = s.customer_name;
      document.getElementById('survey-inp-eventdate').value = s.event_date;
      document.getElementById('survey-inp-date').value = s.survey_date.split('/').reverse().join('-');
      // Populate scores to ratings...
      _setPanelRating('rating-kitchen', s.kitchen_score);
      _setPanelRating('rating-service', s.service_score);
      _setPanelRating('rating-decor', s.decor_score);
      _setPanelRating('rating-audio', s.audio_score);
      _openPanel();
    }
  }

  function _setPanelRating(id, score) {
    var group = document.getElementById(id);
    if (group) {
      group.setAttribute('data-rating', score);
      var btns = group.querySelectorAll('.survey-star-btn');
      _refreshStars(group, btns);
    }
  }

  // ── Star Rating Logic ─────────────────────────────────────────────────
  function _initStarRating() {
    var allStarGroups = document.querySelectorAll('[id^="rating-"]');

    allStarGroups.forEach(function (group) {
      var btns = group.querySelectorAll('.survey-star-btn');

      btns.forEach(function (btn) {
        btn.addEventListener('mouseenter', function () {
          var val = parseInt(btn.getAttribute('data-val'));
          btns.forEach(function (b, i) {
            b.textContent = (i < val) ? '★' : '☆';
            b.style.color = (i < val) ? '#f59e0b' : 'var(--color-border-strong)';
          });
        });

        btn.addEventListener('mouseleave', function () {
          _refreshStars(group, btns);
        });

        btn.addEventListener('click', function () {
          var val = parseInt(btn.getAttribute('data-val'));
          btns.forEach(function (b) { b.classList.remove('active'); });
          for (var i = 0; i < val; i++) { btns[i].classList.add('active'); }
          btns.forEach(function (b) { b.setAttribute('data-selected', ''); });
          group.setAttribute('data-rating', val);
          _refreshStars(group, btns);
        });
      });
    });
  }

  function _refreshStars(group, btns) {
    var selected = parseInt(group.getAttribute('data-rating')) || 0;
    btns.forEach(function (b, i) {
      if (i < selected) {
        b.textContent = '★';
        b.style.color = '#f59e0b';
      } else {
        b.textContent = '☆';
        b.style.color = 'var(--color-border-strong)';
      }
    });
  }

  // ── Bind Events ───────────────────────────────────────────────────────
  function _bindEvents() {
    var overlay      = document.getElementById('survey-form-overlay');
    var btnClose     = document.getElementById('btn-close-survey-form');
    var btnCancel    = document.getElementById('btn-cancel-survey-form');
    var btnSave      = document.getElementById('btn-save-survey');
    var searchInp    = document.getElementById('survey-search');
    var filterRating = document.getElementById('survey-filter-rating');

    if (btnClose)  btnClose.addEventListener('click', _closePanel);
    if (btnCancel) btnCancel.addEventListener('click', _closePanel);
    if (overlay)   overlay.addEventListener('click', _closePanel);

    // Save handler
    if (btnSave) {
      btnSave.addEventListener('click', function () {
        var hd = document.getElementById('survey-inp-hdnumber').value.trim();
        if (!hd) {
          UIToast.show('Vui lòng nhập Số hợp đồng!', 'warning');
          return;
        }
        _closePanel();
        UIToast.show('Đã lưu phiếu khảo sát ' + hd);
      });
    }

    // Search filter
    if (searchInp) {
      searchInp.addEventListener('input', function () {
        if (gridApi) {
          gridApi.setGridOption('quickFilterText', searchInp.value);
        }
      });
    }
    if (filterRating) {
      filterRating.addEventListener('change', function () {
        var val = filterRating.value;
        if (gridApi) {
          if (val === '5') {
            gridApi.setColumnFilterModel('overall_rating', { filterType: 'text', type: 'equals', filter: 'Rất hài lòng' });
          } else if (val === '4') {
            gridApi.setColumnFilterModel('overall_rating', { filterType: 'text', type: 'equals', filter: 'Hài lòng' });
          } else if (val === '3') {
            gridApi.setColumnFilterModel('overall_rating', { filterType: 'text', type: 'equals', filter: 'Bình thường' });
          } else if (val === '2') {
            gridApi.setColumnFilterModel('overall_rating', { filterType: 'text', type: 'equals', filter: 'Không hài lòng' });
          } else if (val === '1') {
            gridApi.setColumnFilterModel('overall_rating', { filterType: 'text', type: 'equals', filter: 'Rất không hài lòng' });
          } else {
            gridApi.setColumnFilterModel('overall_rating', null);
          }
          gridApi.onFilterChanged();
        }
      });
    }
  }

  return { 
    render: render,
    openEdit: openEdit
  };
})();
