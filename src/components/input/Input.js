/**
 * Input Component
 * Sinh ra các ô nhập liệu (Text, Number, Date...) kèm Label bằng DOM Node chuẩn.
 * An toàn XSS, tiện lợi khi build Form hoàn toàn bằng JavaScript.
 */
var UIInput = (function () {

  /**
   * Sinh cấu trúc Label + DOM Input
   */
  function _createBaseWrapper(config, inputType) {
    var wrapper = document.createElement('div');
    wrapper.className = 'form-group ' + (config.className || '');

    if (config.label) {
      var lbl = document.createElement('label');
      lbl.innerText = config.label;
      if (config.required) {
        var req = document.createElement('span');
        req.innerText = ' *';
        req.style.color = 'var(--color-danger)';
        lbl.appendChild(req);
      }
      wrapper.appendChild(lbl);
    }

    var input = document.createElement('input');
    if (config.isMoney) {
      input.type = 'text';
      input.setAttribute('inputmode', 'numeric');
    } else {
      input.type = inputType;
    }
    input.className = 'ui-input';
    if (config.id) input.id = config.id;
    if (config.name) input.name = config.name;

    var finalPlaceholder = config.placeholder;
    if (!finalPlaceholder && config.label && inputType !== 'checkbox' && inputType !== 'radio' && inputType !== 'date') {
      finalPlaceholder = 'Nhập ' + config.label.toLowerCase() + '...';
    }
    if (finalPlaceholder) input.placeholder = finalPlaceholder;

    if (config.value !== undefined) input.value = config.value;
    if (config.disabled) input.disabled = true;
    if (config.readonly) input.readOnly = true;

    wrapper.appendChild(input);

    if (config.isMoney) {
      var wordEl = document.createElement('div');
      wordEl.className = 'money-words-text';
      wordEl.style.cssText = 'font-size: 11px; color: var(--color-success); margin-top: 4px; min-height: 16px; font-style: italic;';
      wrapper.appendChild(wordEl);
      setupMoneyInput(input, wordEl);
    }

    return { wrapper: wrapper, input: input };
  }

  /**
   * Ô nhập Text thông thường
   */
  function createText(config) {
    return _createBaseWrapper(config, 'text').wrapper;
  }

  /**
   * Ô nhập Số
   */
  function createNumber(config) {
    var obj = _createBaseWrapper(config, 'number');
    if (config.min !== undefined) obj.input.min = config.min;
    if (config.max !== undefined) obj.input.max = config.max;
    if (config.step !== undefined) obj.input.step = config.step;
    return obj.wrapper;
  }

  /**
   * Ô nhập Tiền tệ (tự động format + đọc số thành chữ)
   */
  function createMoney(config) {
    var conf = Object.assign({}, config, { isMoney: true });
    return _createBaseWrapper(conf, 'text').wrapper;
  }

  /**
   * Ô chọn Giờ
   */
  function createTime(config) {
    var initialVal = config.value || ''; // Expected standard format: HH:mm (e.g. 15:32)
    
    // Parse the initial HH:mm value for display hh:mm A
    var displayVal = '';
    if (initialVal) {
      var parts = initialVal.split(':');
      if (parts.length >= 2) {
        var h = parseInt(parts[0], 10);
        var m = parts[1].substring(0, 2);
        var period = h >= 12 ? 'PM' : 'AM';
        var displayH = h % 12;
        if (displayH === 0) displayH = 12;
        var displayHStr = String(displayH).padStart(2, '0');
        displayVal = displayHStr + ':' + m + ' ' + period;
      }
    }

    var obj = _createBaseWrapper(config, 'text');
    var visibleInput = obj.input;
    
    // Remove name from visible text input to avoid duplicate submission
    visibleInput.removeAttribute('name');
    var elementId = config.id || config.name;
    if (elementId) visibleInput.id = elementId + '_visible';
    visibleInput.readOnly = true;
    visibleInput.style.cursor = 'pointer';
    visibleInput.placeholder = config.placeholder || 'Chọn giờ...';
    visibleInput.value = displayVal;

    // Create the hidden input for form data collection in HH:mm format
    var hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    if (config.name) hiddenInput.name = config.name;
    if (elementId) hiddenInput.id = elementId;
    hiddenInput.value = initialVal;
    obj.wrapper.appendChild(hiddenInput);

    // Sync from hidden input value back to visible input value
    hiddenInput.addEventListener('change', function () {
      var val = hiddenInput.value;
      if (val) {
        var parts = val.split(':');
        if (parts.length >= 2) {
          var h = parseInt(parts[0], 10);
          var m = parts[1].substring(0, 2);
          var period = h >= 12 ? 'PM' : 'AM';
          var displayH = h % 12;
          if (displayH === 0) displayH = 12;
          var displayHStr = String(displayH).padStart(2, '0');
          visibleInput.value = displayHStr + ':' + m + ' ' + period;
        } else {
          visibleInput.value = val;
        }
      } else {
        visibleInput.value = '';
      }
    });

    // Remove the native input direct placement to wrap it nicely
    if (visibleInput.parentNode) {
      visibleInput.parentNode.removeChild(visibleInput);
    }

    // Input Group wrapper
    var inputContainer = document.createElement('div');
    inputContainer.style.position = 'relative';
    inputContainer.style.display = 'flex';
    inputContainer.style.alignItems = 'center';
    inputContainer.appendChild(visibleInput);

    // Icon (schedule = clock icon in Material Symbols)
    var icon = document.createElement('span');
    icon.className = 'material-symbols-outlined';
    icon.innerText = 'schedule';
    icon.style.position = 'absolute';
    icon.style.right = '12px';
    icon.style.color = 'var(--color-text-secondary)';
    icon.style.pointerEvents = 'none';
    icon.style.fontSize = '20px';
    inputContainer.appendChild(icon);

    obj.wrapper.appendChild(inputContainer);

    var popup = null;
    var _scrollTargets = [];
    var _scrollHandler = null;

    function isElementClipped(el) {
      var rect = el.getBoundingClientRect();
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        return true;
      }
      var node = el.parentElement;
      while (node && node !== document.documentElement) {
        var style = window.getComputedStyle(node);
        var ov = style.overflow + style.overflowY + style.overflowX;
        if (/auto|scroll/.test(ov)) {
          var parentRect = node.getBoundingClientRect();
          if (rect.bottom < parentRect.top || rect.top > parentRect.bottom) {
            return true;
          }
        }
        node = node.parentElement;
      }
      return false;
    }

    function updatePosition() {
      if (!popup) return;
      var rect = visibleInput.getBoundingClientRect();
      var windowWidth = window.innerWidth;
      var windowHeight = window.innerHeight;
      var popupWidth = 240;
      var popupHeight = 270;

      if (isElementClipped(visibleInput)) {
        closePopup();
        return;
      }

      var topPos = rect.bottom + 4;
      if (rect.bottom + popupHeight > windowHeight && rect.top - popupHeight > 0) {
        topPos = rect.top - popupHeight - 4;
      }

      var leftPos = rect.left;
      if (rect.left + popupWidth > windowWidth) {
        leftPos = rect.right - popupWidth;
      }
      leftPos = Math.max(10, leftPos);

      popup.style.top = topPos + 'px';
      popup.style.left = leftPos + 'px';
    }

    function attachScrollListeners() {
      if (_scrollHandler) return;
      _scrollHandler = function () {
        updatePosition();
      };
      _scrollTargets = (UIControls.utils && typeof UIControls.utils.getScrollableAncestors === 'function')
        ? UIControls.utils.getScrollableAncestors(inputContainer)
        : [window];
      _scrollTargets.forEach(function (target) {
        target.addEventListener('scroll', _scrollHandler, { passive: true, capture: false });
      });
      window.addEventListener('resize', _scrollHandler, { passive: true });
    }

    function detachScrollListeners() {
      if (!_scrollHandler) return;
      _scrollTargets.forEach(function (target) {
        target.removeEventListener('scroll', _scrollHandler, { capture: false });
      });
      window.removeEventListener('resize', _scrollHandler);
      _scrollHandler = null;
      _scrollTargets = [];
    }

    function openPopup() {
      if (popup) return;
      popup = document.createElement('div');
      popup.className = 'custom-timepicker-popup';

      var isMobile = (window.innerWidth <= 576);

      if (isMobile) {
        var backdrop = document.createElement('div');
        backdrop.id = 'timepicker-mobile-backdrop';
        backdrop.style.position = 'fixed';
        backdrop.style.inset = '0';
        backdrop.style.background = 'rgba(0, 0, 0, 0.4)';
        backdrop.style.zIndex = '99999998';
        backdrop.addEventListener('click', closePopup);
        document.body.appendChild(backdrop);
        
        popup.style.position = 'fixed';
        popup.style.zIndex = '99999999';
      } else {
        popup.style.position = 'fixed';
        popup.style.zIndex = '99999999';
      }

      // Populate columns: Hour (01-12), Minute (00-59), Period (AM/PM)
      var val = hiddenInput.value || '';
      var activeH = '08', activeM = '00', activeP = 'AM';
      if (val) {
        var parts = val.split(':');
        if (parts.length >= 2) {
          var h = parseInt(parts[0], 10);
          activeM = parts[1].substring(0, 2);
          activeP = h >= 12 ? 'PM' : 'AM';
          var displayH = h % 12;
          if (displayH === 0) displayH = 12;
          activeH = String(displayH).padStart(2, '0');
        }
      }

      var columnsWrap = document.createElement('div');
      columnsWrap.className = 'timepicker-columns';

      // 1. Hour Column (01-12)
      var hrCol = document.createElement('div');
      hrCol.className = 'timepicker-column hours-col';
      for (var i = 1; i <= 12; i++) {
        var itemVal = String(i).padStart(2, '0');
        var item = document.createElement('div');
        item.className = 'timepicker-item' + (itemVal === activeH ? ' active' : '');
        item.innerText = itemVal;
        item.setAttribute('data-value', itemVal);
        item.onclick = function () {
          hrCol.querySelectorAll('.timepicker-item').forEach(function (el) { el.classList.remove('active'); });
          this.classList.add('active');
          scrollToActive(hrCol);
          updateTimeValue();
        };
        hrCol.appendChild(item);
      }

      // 2. Minute Column (00-59)
      var minCol = document.createElement('div');
      minCol.className = 'timepicker-column minutes-col';
      for (var i = 0; i <= 59; i++) {
        var itemVal = String(i).padStart(2, '0');
        var item = document.createElement('div');
        item.className = 'timepicker-item' + (itemVal === activeM ? ' active' : '');
        item.innerText = itemVal;
        item.setAttribute('data-value', itemVal);
        item.onclick = function () {
          minCol.querySelectorAll('.timepicker-item').forEach(function (el) { el.classList.remove('active'); });
          this.classList.add('active');
          scrollToActive(minCol);
          updateTimeValue();
        };
        minCol.appendChild(item);
      }

      // 3. Period Column (AM/PM)
      var pCol = document.createElement('div');
      pCol.className = 'timepicker-column period-col';
      ['AM', 'PM'].forEach(function (itemVal) {
        var item = document.createElement('div');
        item.className = 'timepicker-item' + (itemVal === activeP ? ' active' : '');
        item.innerText = itemVal;
        item.setAttribute('data-value', itemVal);
        item.onclick = function () {
          pCol.querySelectorAll('.timepicker-item').forEach(function (el) { el.classList.remove('active'); });
          this.classList.add('active');
          scrollToActive(pCol);
          updateTimeValue();
        };
        pCol.appendChild(item);
      });

      columnsWrap.appendChild(hrCol);
      columnsWrap.appendChild(minCol);
      columnsWrap.appendChild(pCol);
      popup.appendChild(columnsWrap);

      // Scroll to active items in columns
      setTimeout(function () {
        scrollToActive(hrCol);
        scrollToActive(minCol);
        scrollToActive(pCol);
      }, 0);

      function scrollToActive(columnEl) {
        var activeItem = columnEl.querySelector('.timepicker-item.active');
        if (activeItem) {
          columnEl.scrollTop = activeItem.offsetTop - (columnEl.clientHeight / 2) + (activeItem.clientHeight / 2);
        }
      }

      function updateTimeValue() {
        var hEl = hrCol.querySelector('.timepicker-item.active');
        var mEl = minCol.querySelector('.timepicker-item.active');
        var pEl = pCol.querySelector('.timepicker-item.active');
        if (!hEl || !mEl || !pEl) return;

        var hStr = hEl.getAttribute('data-value');
        var mStr = mEl.getAttribute('data-value');
        var pStr = pEl.getAttribute('data-value');

        var hVal = parseInt(hStr, 10);
        if (pStr === 'PM' && hVal < 12) hVal += 12;
        if (pStr === 'AM' && hVal === 12) hVal = 0;
        
        var standardVal = String(hVal).padStart(2, '0') + ':' + mStr;
        hiddenInput.value = standardVal;
        visibleInput.value = hStr + ':' + mStr + ' ' + pStr;
        hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
        hiddenInput.dispatchEvent(new Event('input', { bubbles: true }));
      }

      // Footer
      var footer = document.createElement('div');
      footer.className = 'timepicker-footer';

      var btnClear = document.createElement('button');
      btnClear.className = 'btn-timepicker-clear';
      btnClear.innerText = 'Xóa';
      btnClear.onclick = function () {
        hiddenInput.value = '';
        visibleInput.value = '';
        hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
        hiddenInput.dispatchEvent(new Event('input', { bubbles: true }));
        closePopup();
      };

      var btnDone = document.createElement('button');
      btnDone.className = 'btn-timepicker-done';
      btnDone.innerText = 'Xong';
      btnDone.onclick = function () {
        updateTimeValue();
        closePopup();
      };

      footer.appendChild(btnClear);
      footer.appendChild(btnDone);
      popup.appendChild(footer);

      document.body.appendChild(popup);

      if (!isMobile) {
        updatePosition();
        attachScrollListeners();
      }

      setTimeout(function () {
        document.addEventListener('click', outsideClickListener);
      }, 0);
    }

    function closePopup() {
      if (!popup) return;
      document.removeEventListener('click', outsideClickListener);
      detachScrollListeners();
      var backdrop = document.getElementById('timepicker-mobile-backdrop');
      if (backdrop && backdrop.parentNode) {
        backdrop.parentNode.removeChild(backdrop);
      }
      if (popup.parentNode) {
        popup.parentNode.removeChild(popup);
      }
      popup = null;
    }

    function outsideClickListener(e) {
      if (!document.body.contains(e.target)) return;
      if (popup && !popup.contains(e.target) && e.target !== visibleInput) {
        closePopup();
      }
    }

    visibleInput.addEventListener('click', function (e) {
      e.stopPropagation();
      if (popup) {
        closePopup();
      } else {
        openPopup();
      }
    });

    return obj.wrapper;
  }

  /**
   * Ô chọn Ngày
   */
  function createDate(config) {
    if (config.value) {
      var rawVal = String(config.value).trim();
      if (rawVal.indexOf('T') !== -1) {
        config.value = rawVal.split('T')[0];
      } else if (rawVal.indexOf('/') !== -1) {
        var parts = rawVal.split(' ')[0].split('/');
        if (parts.length === 3) {
          if (parts[0].length === 4) { // YYYY/MM/DD
            config.value = parts[0] + '-' + parts[1] + '-' + parts[2];
          } else { // DD/MM/YYYY
            config.value = parts[2] + '-' + parts[1] + '-' + parts[0];
          }
        }
      } else if (rawVal.indexOf(' ') !== -1) {
        config.value = rawVal.split(' ')[0];
      }
    }

    var obj = _createBaseWrapper(config, 'text');
    obj.wrapper.classList.add('date-input-wrapper');
    var visibleInput = obj.input;

    // Remove name to prevent duplicate submission of the text representation
    visibleInput.removeAttribute('name');
    var elementId = config.id || config.name;
    if (elementId) visibleInput.id = elementId + '_visible';
    if (config.name) visibleInput.dataset.fieldName = config.name;
    visibleInput.readOnly = true;
    visibleInput.style.cursor = 'pointer';
    visibleInput.placeholder = config.placeholder || 'Chọn ngày...';

    var isDisabled = config.disabled || config.isReadOnlyAdd || config.isReadOnlyEdit || config.isLock || config.readonly;
    if (isDisabled) {
      visibleInput.disabled = true;
      obj.wrapper.classList.add('ui-input-disabled');
    }

    // Format display value
    var initialDate = config.value || '';
    if (initialDate) {
      var p = initialDate.split('-');
      if (p.length === 3) {
        visibleInput.value = p[2] + '/' + p[1] + '/' + p[0];
      }
    }

    // Create the actual hidden input for form value collection
    var hiddenInput = document.createElement('input');
    hiddenInput.type = 'hidden';
    if (config.name) hiddenInput.name = config.name;
    if (elementId) hiddenInput.id = elementId;
    hiddenInput.value = initialDate;
    obj.wrapper.appendChild(hiddenInput);

    // Sync from hidden input value back to visible input value
    hiddenInput.addEventListener('change', function () {
      var val = hiddenInput.value;
      if (val) {
        var p = val.split('-');
        if (p.length === 3) {
          visibleInput.value = p[2] + '/' + p[1] + '/' + p[0];
        } else {
          visibleInput.value = val;
        }
      } else {
        visibleInput.value = '';
      }
    });

    // Remove the native input direct placement to wrap it nicely
    if (visibleInput.parentNode) {
      visibleInput.parentNode.removeChild(visibleInput);
    }

    // Input Group wrapper
    var inputContainer = document.createElement('div');
    inputContainer.style.position = 'relative';
    inputContainer.style.display = 'flex';
    inputContainer.style.alignItems = 'center';
    inputContainer.appendChild(visibleInput);

    // Icon
    var icon = document.createElement('span');
    icon.className = 'material-symbols-outlined';
    icon.innerText = 'calendar_today';
    icon.style.position = 'absolute';
    icon.style.right = '12px';
    icon.style.color = 'var(--color-text-secondary)';
    icon.style.pointerEvents = 'none';
    icon.style.fontSize = '20px';
    inputContainer.appendChild(icon);

    obj.wrapper.appendChild(inputContainer);

    // Custom calendar popup picker
    var popup = null;
    var calendarInstance = null;
    var _scrollTargets = [];
    var _scrollHandler = null;

    function isElementClipped(el) {
      var rect = el.getBoundingClientRect();
      if (rect.bottom < 0 || rect.top > window.innerHeight) {
        return true;
      }
      var node = el.parentElement;
      while (node && node !== document.documentElement) {
        var style = window.getComputedStyle(node);
        var ov = style.overflow + style.overflowY + style.overflowX;
        if (/auto|scroll/.test(ov)) {
          var parentRect = node.getBoundingClientRect();
          if (rect.bottom < parentRect.top || rect.top > parentRect.bottom) {
            return true;
          }
        }
        node = node.parentElement;
      }
      return false;
    }

    function updatePosition() {
      if (!popup) return;
      var rect = visibleInput.getBoundingClientRect();
      var windowWidth = window.innerWidth;
      var windowHeight = window.innerHeight;
      var popupWidth = 340;
      var popupHeight = 380;

      // Close if the input is scrolled out of view/container bounds
      if (isElementClipped(visibleInput)) {
        closePopup();
        return;
      }

      // Calculate vertical position (flip if not enough space below)
      var topPos = rect.bottom + 4;
      if (rect.bottom + popupHeight > windowHeight && rect.top - popupHeight > 0) {
        topPos = rect.top - popupHeight - 4;
      }

      // Calculate horizontal position
      var leftPos = rect.left;
      if (rect.left + popupWidth > windowWidth) {
        leftPos = rect.right - popupWidth;
      }
      leftPos = Math.max(10, leftPos);

      popup.style.top = topPos + 'px';
      popup.style.left = leftPos + 'px';
    }

    function attachScrollListeners() {
      if (_scrollHandler) return;
      _scrollHandler = function () {
        updatePosition();
      };
      _scrollTargets = (UIControls.utils && typeof UIControls.utils.getScrollableAncestors === 'function')
        ? UIControls.utils.getScrollableAncestors(inputContainer)
        : [window];
      _scrollTargets.forEach(function (target) {
        target.addEventListener('scroll', _scrollHandler, { passive: true, capture: false });
      });
      window.addEventListener('resize', _scrollHandler, { passive: true });
    }

    function detachScrollListeners() {
      if (!_scrollHandler) return;
      _scrollTargets.forEach(function (target) {
        target.removeEventListener('scroll', _scrollHandler, { capture: false });
      });
      window.removeEventListener('resize', _scrollHandler);
      _scrollHandler = null;
      _scrollTargets = [];
    }

    function openPopup() {
      // Đóng bất kỳ popup Calendar nào khác đang mở trên màn hình
      if (typeof window.closeActiveDatepickerPopup === 'function' && window.closeActiveDatepickerPopup !== closePopup) {
        window.closeActiveDatepickerPopup();
      }
      window.closeActiveDatepickerPopup = closePopup;

      // Xóa các popup DOM datepicker mồ côi nếu còn sót lại
      document.querySelectorAll('.custom-datepicker-popup').forEach(function (el) {
        if (el && el.parentNode) el.parentNode.removeChild(el);
      });

      if (popup) return;
      popup = document.createElement('div');
      popup.className = 'custom-datepicker-popup';

      var isMobile = (window.innerWidth <= 576);

      if (isMobile) {
        // Add a dim backdrop for mobile focus
        var backdrop = document.createElement('div');
        backdrop.id = 'datepicker-mobile-backdrop';
        backdrop.style.position = 'fixed';
        backdrop.style.inset = '0';
        backdrop.style.background = 'rgba(0, 0, 0, 0.4)';
        backdrop.style.zIndex = '99999998';
        backdrop.addEventListener('click', closePopup);
        document.body.appendChild(backdrop);
        
        popup.style.position = 'fixed';
        popup.style.zIndex = '99999999';
      } else {
        // Desktop/Tablet layout: Position relative to input using fixed (non-clipped)
        popup.style.position = 'fixed';
        popup.style.zIndex = '99999999';
      }

      if (typeof UICalendar !== 'undefined') {
        calendarInstance = UICalendar.create({
          selectedDate: hiddenInput.value || null,
          onSelect: function (dateStr) {
            hiddenInput.value = dateStr;
            var p = dateStr.split('-');
            if (p.length === 3) {
              visibleInput.value = p[2] + '/' + p[1] + '/' + p[0];
            }
            // Phát event trên cả input hiển thị để các trigger bên ngoài form
            // bắt được thay đổi, đồng thời vẫn giữ input ẩn cho serializer.
            visibleInput.dispatchEvent(new Event('change', { bubbles: true }));
            visibleInput.dispatchEvent(new Event('input', { bubbles: true }));
            hiddenInput.dispatchEvent(new Event('change', { bubbles: true }));
            hiddenInput.dispatchEvent(new Event('input', { bubbles: true }));
            closePopup();
          }
        });
        popup.appendChild(calendarInstance);
      } else {
        popup.innerText = 'UICalendar not loaded';
      }

      document.body.appendChild(popup);

      if (!isMobile) {
        updatePosition();
        attachScrollListeners();
      }

      if (calendarInstance && calendarInstance.setSelectedDate) {
        calendarInstance.setSelectedDate(hiddenInput.value || null);
      }

      setTimeout(function () {
        document.addEventListener('click', outsideClickListener);
      }, 0);
    }

    function closePopup() {
      if (window.closeActiveDatepickerPopup === closePopup) {
        window.closeActiveDatepickerPopup = null;
      }
      if (!popup) return;
      document.removeEventListener('click', outsideClickListener);
      detachScrollListeners();
      var backdrop = document.getElementById('datepicker-mobile-backdrop');
      if (backdrop && backdrop.parentNode) {
        backdrop.parentNode.removeChild(backdrop);
      }
      if (popup.parentNode) {
        popup.parentNode.removeChild(popup);
      }
      popup = null;
      calendarInstance = null;
    }

    function outsideClickListener(e) {
      if (!document.body.contains(e.target)) return;
      if (popup && !popup.contains(e.target) && e.target !== visibleInput) {
        closePopup();
      }
    }

    visibleInput.addEventListener('click', function (e) {
      e.stopPropagation();
      if (visibleInput.disabled || hiddenInput.disabled || visibleInput.hasAttribute('disabled') || visibleInput.classList.contains('ui-input-disabled') || (visibleInput.closest && visibleInput.closest('.ui-input-disabled'))) return;
      if (popup) {
        closePopup();
      } else {
        openPopup();
      }
    });

    return obj.wrapper;
  }

  /**
   * Ô Switch (Công tắc bật/tắt cho boolean)
   */
  function createSwitch(config) {
    var obj = _createBaseWrapper(config, 'checkbox');
    obj.wrapper.classList.remove('form-group');
    obj.wrapper.classList.add('modern-checkbox-wrapper');
    obj.input.className = 'modern-checkbox';
    obj.input.style.cursor = 'pointer';

    // Checkbox uses checked instead of value
    if (config.value === '1' || config.value === 1 || config.value === true || String(config.value).toLowerCase() === 'true') {
      obj.input.checked = true;
    }

    // Thêm giá trị thực vào dataset để tự động serialize thành 1/0
    obj.input.value = obj.input.checked ? 1 : 0;
    obj.input.onchange = function () {
      this.value = this.checked ? 1 : 0;
    };

    // Đảo ngược thứ tự input và label cho đẹp
    var label = obj.wrapper.querySelector('label');
    if (label) {
      // Xóa class cũ
      label.className = '';
      label.style.cursor = 'pointer';
      // Đảo ngược thứ tự: input trước, label sau
      obj.wrapper.insertBefore(obj.input, label);
    }

    return obj.wrapper;
  }

  /**
   * Ô nhập Mật Khẩu (có nút mắt ẩn/hiện)
   */
  function createPassword(config) {
    var obj = _createBaseWrapper(config, 'password');
    var input = obj.input;

    // Wrapper cho input + nút mắt
    var inputWrap = document.createElement('div');
    inputWrap.style.position = 'relative';
    inputWrap.style.display = 'flex';
    inputWrap.style.alignItems = 'center';

    // Thay thế input bằng inputWrap TRƯỚC (input vẫn còn là child của wrapper)
    obj.wrapper.replaceChild(inputWrap, input);

    // Rồi mới chuyển input vào inputWrap
    input.style.paddingRight = '40px';
    inputWrap.appendChild(input);

    // Nút mắt
    var eyeBtn = document.createElement('button');
    eyeBtn.type = 'button';
    eyeBtn.tabIndex = -1;
    eyeBtn.className = 'password-eye-btn';
    eyeBtn.style.cssText = 'position:absolute; right:8px; top:50%; transform:translateY(-50%); background:none; border:none; cursor:pointer; padding:4px; display:flex; align-items:center; justify-content:center; color:var(--color-text-secondary); border-radius:4px; transition: color 0.2s;';
    eyeBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:20px;">visibility_off</span>';
    eyeBtn.title = 'Hiện mật khẩu';

    var isVisible = false;
    eyeBtn.addEventListener('click', function () {
      isVisible = !isVisible;
      input.type = isVisible ? 'text' : 'password';
      eyeBtn.querySelector('.material-symbols-outlined').textContent = isVisible ? 'visibility' : 'visibility_off';
      eyeBtn.title = isVisible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu';
      input.focus();
    });

    // Hover effect
    eyeBtn.addEventListener('mouseenter', function () { this.style.color = 'var(--color-text)'; });
    eyeBtn.addEventListener('mouseleave', function () { this.style.color = 'var(--color-text-secondary)'; });

    inputWrap.appendChild(eyeBtn);

    return obj.wrapper;
  }

  /**
   * Ô Select (Combobox thả xuống)
   */
  function createSelect(config, options) {
    var wrapper = document.createElement('div');
    wrapper.className = 'form-group ' + (config.className || '');

    if (config.label) {
      var lbl = document.createElement('label');
      lbl.innerText = config.label;
      if (config.required) {
        var req = document.createElement('span');
        req.innerText = ' *';
        req.style.color = 'var(--color-danger)';
        lbl.appendChild(req);
      }
      wrapper.appendChild(lbl);
    }

    var select = document.createElement('select');
    select.className = 'ui-input'; // Xài chung style với thẻ input
    if (config.id) select.id = config.id;
    if (config.name) select.name = config.name;
    if (config.disabled) select.disabled = true;

    var defaultOpt = document.createElement('option');
    defaultOpt.value = '';
    defaultOpt.innerText = '-- Vui lòng chọn --';
    select.appendChild(defaultOpt);

    (options || []).forEach(function (opt) {
      var o = document.createElement('option');
      o.value = opt.value;
      o.innerText = opt.label;
      if (config.value == opt.value) o.selected = true;
      select.appendChild(o);
    });

    wrapper.appendChild(select);
    return wrapper;
  }

  /**
   * Sinh HTML chuỗi cho Bộ chọn số lượng (Quantity Selector)
   * Dùng cho các Grid/Table sử dụng innerHTML thay vì DOM Nodes.
   */
  function createQuantityHTML(config) {
    var value = config.value || 1;
    var onDecrease = config.onDecrease || '';
    var onIncrease = config.onIncrease || '';
    var onChange = config.onChange || '';
    var stopPropagation = config.stopPropagation ? 'event.stopPropagation(); ' : '';

    var h = config.height || 32;
    var w = config.width || 96;
    var btnW = config.btnWidth || 30;
    var inpW = w - (btnW * 2);

    return `
      <div class="d-flex align-items-center justify-content-center mx-auto" style="width: ${w}px; border: 1px solid var(--color-border); border-radius: 6px; overflow: hidden; background: var(--color-surface); box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
        <button class="btn btn-light d-flex align-items-center justify-content-center p-0" style="width: ${btnW}px; height: ${h}px; border: none; border-radius: 0; background: #f8f9fa; color: #475569;" onclick="${stopPropagation}${onDecrease}" title="Giảm">
          <span class="material-symbols-outlined" style="font-size: 16px;">remove</span>
        </button>
        <input type="text" class="form-control text-center p-0 border-0" style="width: ${inpW}px; height: ${h}px; font-weight: 600; font-size: 13px; background: transparent; box-shadow: none;" value="${value}" onchange="${stopPropagation}${onChange}" title="Nhập số lượng">
        <button class="btn btn-light d-flex align-items-center justify-content-center p-0" style="width: ${btnW}px; height: ${h}px; border: none; border-radius: 0; background: #f8f9fa; color: #475569;" onclick="${stopPropagation}${onIncrease}" title="Tăng">
          <span class="material-symbols-outlined" style="font-size: 16px;">add</span>
        </button>
      </div>
    `;
  }

  /**
   * Hàm đọc số thành chữ tiếng Việt
   */
  function docSoTienVN(n) {
    if (!n || n === 0) return 'Không đồng';
    var dvDoc = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ', 'triệu tỷ', 'tỷ tỷ'];
    var soDoc = ['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín'];
    function docNhom(so) {
      var tram = Math.floor(so / 100);
      var chuc = Math.floor((so % 100) / 10);
      var dv = so % 10;
      var kq = '';
      if (tram > 0) kq += soDoc[tram] + ' trăm ';
      if (chuc === 1) kq += 'mười ';
      else if (chuc > 1) kq += soDoc[chuc] + ' mươi ';
      if (dv === 1 && chuc > 1) kq += 'mốt ';
      else if (dv === 5 && chuc > 0) kq += 'lăm ';
      else if (dv > 0) kq += soDoc[dv] + ' ';
      return kq.trim();
    }
    var str = Math.round(n).toString();
    var groups = [];
    while (str.length > 0) {
      groups.unshift(str.slice(-3));
      str = str.slice(0, -3);
    }
    var result = '';
    groups.forEach(function (g, i) {
      var val = parseInt(g, 10);
      if (val > 0) {
        result += docNhom(val) + ' ' + dvDoc[groups.length - 1 - i] + ' ';
      }
    });
    return result.trim() + ' đồng';
  }

  /**
   * Cài đặt tự động format số tiền + hiển thị text cho một ô input có sẵn
   */
  function setupMoneyInput(inputEl, textEl) {
    if (!inputEl) return;

    function refresh() {
      var raw = parseInt(inputEl.value.replace(/\D/g, ''), 10) || 0;
      inputEl.value = raw === 0 ? '' : raw.toLocaleString('vi-VN');
      if (textEl) textEl.innerText = raw === 0 ? '' : docSoTienVN(raw);
    }

    inputEl.addEventListener('input', function () {
      var pos = this.selectionStart;
      var oldLen = this.value.length;
      var raw = parseInt(this.value.replace(/\D/g, ''), 10) || 0;

      this.value = raw === 0 ? '' : raw.toLocaleString('vi-VN');

      var diff = this.value.length - oldLen;
      if (pos !== null) {
        this.setSelectionRange(pos + diff, pos + diff);
      }

      if (textEl) textEl.innerText = raw === 0 ? '' : docSoTienVN(raw);
    });

    inputEl.addEventListener('change', function () {
      refresh();
    });

    inputEl.addEventListener('blur', function () {
      refresh();
    });

    refresh();
  }

  return {
    createText: createText,
    createNumber: createNumber,
    createMoney: createMoney,
    createDate: createDate,
    createTime: createTime,
    createPassword: createPassword,
    createSwitch: createSwitch,
    createSelect: createSelect,
    createQuantityHTML: createQuantityHTML,
    docSoTienVN: docSoTienVN,
    setupMoneyInput: setupMoneyInput
  };
})();
