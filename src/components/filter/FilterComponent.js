/**
 * Filter Component
 * Thanh công cụ lọc dữ liệu
 */
var FilterComponent = (function () {
  /**
   * Tạo component bộ lọc đè lên UI (Overlay Panel gắn vào document.body để chống vỡ layout)
   */
  function create(filters, onSearch) {
    // 1. Tạo Panel thực sự và gắn thẳng vào body (Tránh bị cắt bởi thẻ cha có overflow: hidden hoặc transform)
    var wrapper = document.createElement('div');
    // Chỉnh lại bóng đổ (box-shadow) mỏng, mịn và sang trọng hơn (Layered shadow kiểu CUKCUK/Stripe)
    wrapper.style.cssText = 'position: fixed; left: -9999px; top: -9999px; z-index: 999999; background: var(--color-surface, #fff); border: 1px solid var(--color-border, #e2e8f0); border-radius: var(--radius-md, 12px); box-shadow: 0 4px 20px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04); padding: 24px; min-width: 450px; display: none; flex-direction: column; gap: 16px; transition: opacity 0.2s ease, transform 0.2s ease;';
    document.body.appendChild(wrapper);

    var inputs = {};

    filters.forEach(function(f) {
      var controlWrapper;
      var config = { id: f.id, label: f.label, placeholder: f.placeholder };
      
      if (f.type === 'select') {
         var opts = f.options ? f.options.map(function(o) { return { value: o.value !== undefined ? o.value : o, label: o.label || o }; }) : [];
         controlWrapper = UIInput.createSelect(config, opts);
      } else if (f.type === 'date') {
         controlWrapper = UIInput.createDate(config);
      } else if (f.type === 'number') {
         controlWrapper = UIInput.createNumber(config);
      } else {
         controlWrapper = UIInput.createText(config);
      }
      
      controlWrapper.className = '';
      
      controlWrapper.style.display = 'flex';
      controlWrapper.style.flexDirection = 'row';
      controlWrapper.style.alignItems = 'center';
      controlWrapper.style.justifyContent = 'space-between';
      controlWrapper.style.margin = '0';
      controlWrapper.style.gap = '16px';
      
      var lbl = controlWrapper.querySelector('label');
      if (lbl) {
         lbl.style.width = '140px';
         lbl.style.margin = '0';
         lbl.style.fontSize = '14px';
         lbl.style.fontWeight = '500';
         lbl.style.color = '#334155';
         lbl.style.flexShrink = '0';
         lbl.style.display = 'block';
         lbl.style.textAlign = 'left';
      }
      
      var inp = controlWrapper.querySelector('input, select');
      if (inp) {
         inp.style.flex = '1';
         inp.style.minWidth = '0';
         inp.style.padding = '8px 12px';
         inp.style.fontSize = '14px';
         inputs[f.id] = inp;
      }
      
      wrapper.appendChild(controlWrapper);
    });

    var actions = document.createElement('div');
    actions.style.cssText = 'display: flex; justify-content: flex-end; gap: 12px; margin-top: 12px; padding-top: 16px; border-top: 1px solid #f1f5f9;';

    var btnReset = document.createElement('button');
    btnReset.className = 'btn btn-light';
    btnReset.innerText = 'Xóa bộ lọc';
    btnReset.style.cssText = 'font-weight: 500; border: 1px solid #e2e8f0; border-radius: 6px; padding: 8px 16px;';
    btnReset.onclick = function() {
      for(var key in inputs) {
        inputs[key].value = '';
      }
      if (typeof onSearch === 'function') onSearch({});
    };

    var btnSearch = document.createElement('button');
    btnSearch.className = 'btn btn-primary d-flex align-items-center gap-2';
    btnSearch.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">search</span> Lọc dữ liệu';
    btnSearch.style.cssText = 'font-weight: 600; border-radius: 6px; padding: 8px 16px;';
    btnSearch.onclick = function() {
      if (typeof onSearch === 'function') {
        var values = {};
        for(var key in inputs) {
          values[key] = inputs[key].value;
        }
        onSearch(values);
        
        // Đóng popup sau khi Lọc
        if (dummyContainer.parentElement) {
            dummyContainer.parentElement.style.display = 'none';
        }
      }
    };

    actions.appendChild(btnReset);
    actions.appendChild(btnSearch);
    wrapper.appendChild(actions);
    
    // Mũi tên (Caret) nối lên trên
    var arrowBorder = document.createElement('div');
    arrowBorder.style.cssText = 'position: absolute; top: -9px; left: 30px; width: 0; height: 0; border-left: 9px solid transparent; border-right: 9px solid transparent; border-bottom: 9px solid var(--color-border, #e2e8f0); pointer-events: none;';
    
    var arrowBg = document.createElement('div');
    arrowBg.style.cssText = 'position: absolute; top: -8px; left: 31px; width: 0; height: 0; border-left: 8px solid transparent; border-right: 8px solid transparent; border-bottom: 8px solid var(--color-surface, #fff); pointer-events: none;';

    wrapper.appendChild(arrowBorder);
    wrapper.appendChild(arrowBg);

    // 2. Dummy Container trả về cho hệ thống cũ (DynamicFormEngine) để không làm vỡ code cũ
    var dummyContainer = document.createElement('div');
    dummyContainer.style.display = 'none';

    // Căn chỉnh vị trí
    function alignPopup() {
        var btns = document.querySelectorAll('button');
        var btnLoc = null;
        for(var i = 0; i < btns.length; i++) {
            if(btns[i].innerHTML.indexOf('filter_alt') !== -1 || btns[i].innerText === 'Lọc' || btns[i].getAttribute('data-tooltip') === 'Lọc / Tìm kiếm dữ liệu') {
                btnLoc = btns[i];
                break;
            }
        }
        
        if (btnLoc) {
            var btnRect = btnLoc.getBoundingClientRect();
            
            // Fixed position dựa trực tiếp vào tọa độ gốc Viewport (tuyệt đối không bị vỡ)
            wrapper.style.top = (btnRect.bottom + 10) + 'px';
            
            var centerBtnX = btnRect.left + (btnRect.width / 2);
            var panelLeft = centerBtnX - 40; 
            if (panelLeft < 10) panelLeft = 10;
            
            wrapper.style.left = panelLeft + 'px';
            
            // Căn mũi tên chĩa đúng tâm
            var arrowPos = centerBtnX - panelLeft;
            arrowBorder.style.left = (arrowPos - 9) + 'px';
            arrowBg.style.left = (arrowPos - 8) + 'px';
        }
    }

    // Theo dõi trạng thái của Container gốc để đồng bộ hiển thị
    setTimeout(function() {
        var parent = dummyContainer.parentElement; // Đây chính là #dynamic-filter-container
        if (parent) {
            // Tiêu diệt không gian của thẻ cha để không đẩy lưới xuống
            parent.style.marginBottom = '0';
            parent.style.padding = '0';
            parent.style.height = '0';
            
            var observer = new MutationObserver(function() {
                if (parent.style.display !== 'none') {
                    wrapper.style.display = 'flex';
                    alignPopup();
                    
                    // Focus vào ô đầu tiên
                    var firstInput = wrapper.querySelector('input');
                    if (firstInput) firstInput.focus();
                } else {
                    wrapper.style.display = 'none';
                }
            });
            observer.observe(parent, { attributes: true, attributeFilter: ['style'] });
        }
    }, 50);
    
    // Auto dóng lại khi Resize
    window.addEventListener('resize', function() {
        if (wrapper.style.display !== 'none') alignPopup();
    });

    // Click bên ngoài thì tự đóng Panel
    document.addEventListener('click', function(e) {
        if (wrapper.style.display !== 'none') {
            var isInsidePanel = wrapper.contains(e.target);
            var btnLoc = null;
            var btns = document.querySelectorAll('button');
            for(var i = 0; i < btns.length; i++) {
                if(btns[i].innerHTML.indexOf('filter_alt') !== -1 || btns[i].innerText === 'Lọc' || btns[i].getAttribute('data-tooltip') === 'Lọc / Tìm kiếm dữ liệu') {
                    btnLoc = btns[i]; break;
                }
            }
            var isClickOnButton = btnLoc && btnLoc.contains(e.target);
            
            if (!isInsidePanel && !isClickOnButton && dummyContainer.parentElement) {
                dummyContainer.parentElement.style.display = 'none'; // Ẩn cha đi thì Observer sẽ ẩn Panel
            }
        }
    });

    return dummyContainer; // Trả về thẻ rỗng để lừa DynamicFormEngine
  }

  return {
    create: create
  };
})();
