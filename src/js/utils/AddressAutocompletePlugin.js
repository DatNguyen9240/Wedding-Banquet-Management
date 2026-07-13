/**
 * AddressAutocompletePlugin.js
 * ─────────────────────────────────────────────────────────────────────
 * Tự động gợi ý địa chỉ khi nhập liệu vào trường Địa chỉ (diachi, address...).
 * Hỗ trợ các nguồn dữ liệu:
 * 1. Google Maps JS SDK (nếu đã được nạp và khởi tạo SDK).
 * 2. Goong Maps API (nếu được khai báo GOONG_API_KEY trong env.js).
 * 3. Photon API (OpenStreetMap) - Môi trường chạy mặc định hoàn toàn MIỄN PHÍ.
 * 
 * Khắc phục triệt để lỗi bị cắt (clipping) do modal có overflow-y: auto
 * bằng cách chèn dropdown trực tiếp vào body và định vị động.
 */
var AddressAutocompletePlugin = (function () {
  'use strict';

  // Định nghĩa các tham số cấu hình API mặc định
  var CONFIG = {
    photonUrl: 'https://photon.komoot.io/api/',
    // Phạm vi Việt Nam (Bounding box: minLon, minLat, maxLon, maxLat) để Photon tìm chính xác hơn
    vietnamBbox: '102.1,8.1,109.5,23.4',
    
    get goongKey() {
      var key = window.API_CONFIG && window.API_CONFIG.GOONG_API_KEY;
      return (key && key.trim()) ? key.trim() : null;
    },
    get googleKey() {
      var key = window.API_CONFIG && window.API_CONFIG.GOOGLE_MAPS_API_KEY;
      return (key && key.trim()) ? key.trim() : null;
    }
  };

  // Tìm ô nhập địa chỉ bằng cách so khớp tương đối tên trường
  function _findAddressInput(container) {
    if (!container) {
      console.warn('[AddressAutocomplete] _findAddressInput: Container bị rỗng.');
      return null;
    }
    var inputs = container.querySelectorAll('input, textarea');
    console.log('[AddressAutocomplete] Đang tìm kiếm ô Địa chỉ trong số ' + inputs.length + ' phần tử nhập liệu...');
    for (var i = 0; i < inputs.length; i++) {
      var name = inputs[i].getAttribute('name');
      if (name) {
        var lowerName = name.toLowerCase();
        // Khớp bất kỳ tên trường nào chứa 'diachi' hoặc 'address' (Ví dụ: Diachi, BenBDiaChi, HDDiaChi, address...)
        if (lowerName.indexOf('diachi') >= 0 || lowerName.indexOf('address') >= 0) {
          // Bỏ qua các trường ẩn hoặc checkbox
          var type = inputs[i].getAttribute('type') || '';
          if (type !== 'hidden' && type !== 'checkbox' && type !== 'radio') {
            console.log('[AddressAutocomplete] Đã khớp trường Địa chỉ:', name, inputs[i]);
            return inputs[i];
          }
        }
      }
    }
    console.warn('[AddressAutocomplete] Không tìm thấy phần tử nào khớp với tên "diachi" hoặc "address".');
    return null;
  }

  // Tìm phần tử tổ tiên gần nhất đang có thanh cuộn dọc (để lắng nghe sự kiện cuộn)
  function _getScrollParent(node) {
    if (!node || node === document.body || node === document.documentElement) {
      return window;
    }
    var overflowY = window.getComputedStyle(node).overflowY;
    var isScrollable = overflowY === 'auto' || overflowY === 'scroll';
    if (isScrollable && node.scrollHeight > node.clientHeight) {
      return node;
    }
    return _getScrollParent(node.parentNode);
  }

  // Khởi tạo tính năng gợi ý trên phần tử input cụ thể
  function _setupAutocomplete(input) {
    if (input._hasAddressAutocomplete) {
      console.log('[AddressAutocomplete] Ô nhập địa chỉ này đã được cấu hình autocomplete trước đó.');
      return;
    }
    input._hasAddressAutocomplete = true;
    input.setAttribute('autocomplete', 'off'); // Tắt tự động điền mặc định của trình duyệt để tránh chồng lấn
    console.log('[AddressAutocomplete] Đang thiết lập autocomplete cho ô nhập liệu...');

    // 1. Nếu trình duyệt đã nạp Google Maps Places SDK thành công, ưu tiên dùng tính năng của Google
    if (window.google && window.google.maps && window.google.maps.places) {
      try {
        var autocomplete = new google.maps.places.Autocomplete(input, {
          componentRestrictions: { country: 'vn' },
          fields: ['address_components', 'formatted_address', 'geometry', 'name']
        });
        autocomplete.addListener('place_changed', function () {
          var place = autocomplete.getPlace();
          input.value = place.formatted_address || place.name || input.value;
          // Đồng bộ giá trị vào Form Engine
          input.dispatchEvent(new Event('change', { bubbles: true }));
          input.dispatchEvent(new Event('input', { bubbles: true }));
        });
        console.log('[AddressAutocompletePlugin] Đã liên kết Google Maps Autocomplete thành công.');
        return;
      } catch (e) {
        console.warn('[AddressAutocompletePlugin] Lỗi khi nạp Google Maps Autocomplete, chuyển sang chế độ dự phòng:', e);
      }
    }

    // 2. Chế độ Custom UI Dropdown (dành cho Goong Maps hoặc Photon API)
    var dropdown = document.createElement('div');
    dropdown.className = 'address-autocomplete-dropdown';
    
    // Định dạng giao diện dropdown (CSS được inject một lần duy nhất qua _injectStyles)
    dropdown.style.cssText = `
      position: fixed;
      z-index: 999999;
      background: var(--color-surface, #ffffff);
      border: 1px solid var(--color-border, #cbd5e1);
      border-radius: var(--radius-md, 8px);
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
      max-height: 250px;
      overflow-y: auto;
      display: none;
      box-sizing: border-box;
    `;

    _injectStyles();
    document.body.appendChild(dropdown);

    var debounceTimer;
    var activeIndex = -1;
    var currentItems = [];
    var scrollParent = _getScrollParent(input);
    console.log('[AddressAutocomplete] Phần tử cha nhận cuộn dọc:', scrollParent);

    // Tính toán lại vị trí tuyệt đối của input để gắn dropdown đúng chỗ
    function repositionDropdown() {
      if (dropdown.style.display !== 'block') return;
      var rect = input.getBoundingClientRect();
      
      // Định vị dropdown ngay dưới ô nhập liệu
      dropdown.style.width = rect.width + 'px';
      dropdown.style.left = rect.left + 'px';
      dropdown.style.top = rect.bottom + 'px';
    }

    function showDropdown() {
      if (currentItems.length > 0) {
        dropdown.style.display = 'block';
        repositionDropdown();
        console.log('[AddressAutocomplete] Hiển thị dropdown gợi ý với ' + currentItems.length + ' bản ghi.');
      } else {
        hideDropdown();
      }
    }

    function hideDropdown() {
      dropdown.style.display = 'none';
      dropdown.innerHTML = '';
      activeIndex = -1;
      currentItems = [];
    }

    // Xử lý phím tắt điều hướng trong dropdown gợi ý
    input.addEventListener('keydown', function (e) {
      var items = dropdown.querySelectorAll('.address-item');
      if (!items || items.length === 0) return;

      if (e.key === 'ArrowDown') {
        e.preventDefault();
        activeIndex = (activeIndex + 1) % items.length;
        _highlightItem(items, activeIndex);
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        activeIndex = (activeIndex - 1 + items.length) % items.length;
        _highlightItem(items, activeIndex);
      } else if (e.key === 'Enter') {
        if (activeIndex >= 0 && activeIndex < items.length) {
          e.preventDefault();
          items[activeIndex].click();
        }
      } else if (e.key === 'Escape') {
        e.preventDefault();
        hideDropdown();
      }
    });

    var isSelecting = false;

    // Bắt sự kiện gõ phím để truy vấn API gợi ý
    input.addEventListener('input', function () {
      if (isSelecting) return;
      clearTimeout(debounceTimer);
      var query = input.value.trim();
      console.log('[AddressAutocomplete] Người dùng nhập: "' + query + '"');
      if (query.length < 2) {
        console.log('[AddressAutocomplete] Độ dài từ khóa nhỏ hơn 2, ẩn dropdown.');
        hideDropdown();
        return;
      }

      debounceTimer = setTimeout(function () {
        console.log('[AddressAutocomplete] Đang tìm gợi ý cho: "' + query + '"');
        _searchAddress(query, function (results) {
          currentItems = results;
          _renderDropdown(dropdown, results, function (selectedAddress) {
            console.log('[AddressAutocomplete] Người dùng chọn địa chỉ:', selectedAddress);
            isSelecting = true;
            input.value = selectedAddress;
            // Đồng bộ dữ liệu sang cho DynamicFormEngine nhận biết sự thay đổi
            input.dispatchEvent(new Event('change', { bubbles: true }));
            input.dispatchEvent(new Event('input', { bubbles: true }));
            hideDropdown();
            isSelecting = false;
          });
          showDropdown();
        });
      }, 300); // Trì hoãn 300ms giảm tải request API
    });

    // Ẩn dropdown khi bấm chuột ra ngoài ô nhập liệu
    document.addEventListener('mousedown', function (e) {
      if (e.target !== input && e.target !== dropdown && !dropdown.contains(e.target)) {
        hideDropdown();
      }
    });

    // Ẩn dropdown khi người dùng cuộn form hoặc phóng to thu nhỏ cửa sổ
    if (scrollParent) {
      scrollParent.addEventListener('scroll', hideDropdown, { passive: true });
    }
    window.addEventListener('resize', hideDropdown, { passive: true });

    // Dọn dẹp sự kiện cũ để tránh rò rỉ bộ nhớ (nếu input bị hủy bỏ)
    input.addEventListener('destroy', function () {
      console.log('[AddressAutocomplete] Hủy bỏ lắng nghe sự kiện cuộn và xóa dropdown khỏi DOM.');
      if (dropdown.parentNode) dropdown.parentNode.removeChild(dropdown);
      if (scrollParent) scrollParent.removeEventListener('scroll', hideDropdown);
      window.removeEventListener('resize', hideDropdown);
    });
  }

  // Highlight phần tử đang chọn bằng phím mũi tên
  function _highlightItem(items, index) {
    items.forEach(function (item, idx) {
      if (idx === index) {
        item.classList.add('active');
        item.scrollIntoView({ block: 'nearest' });
      } else {
        item.classList.remove('active');
      }
    });
  }

  // Thực hiện tìm kiếm thông qua API tương ứng
  function _searchAddress(query, callback) {
    // 1. Ưu tiên Goong Maps nếu có cấu hình API Key
    if (CONFIG.goongKey) {
      console.log('[AddressAutocomplete] Sử dụng API gợi ý của Goong Maps...');
      var url = 'https://rsapi.goong.io/Place/AutoComplete?api_key=' + CONFIG.goongKey + '&input=' + encodeURIComponent(query);
      fetch(url)
        .then(function (res) { return res.json(); })
        .then(function (data) {
          var results = [];
          if (data && data.predictions) {
            results = data.predictions.map(function (p) {
              var main = (p.structured_formatting && p.structured_formatting.main_text) || '';
              var sec = (p.structured_formatting && p.structured_formatting.secondary_text) || '';
              return {
                primary: main || p.description,
                secondary: sec,
                full: p.description
              };
            });
          }
          console.log('[AddressAutocomplete] Goong API trả về:', results);
          callback(results);
        })
        .catch(function (err) {
          console.warn('[AddressAutocompletePlugin] Lỗi API Goong, dùng nguồn dự phòng:', err);
          _fallbackSearch(query, callback);
        });
      return;
    }

    // 2. Chạy mặc định bằng Photon API (OpenStreetMap)
    _fallbackSearch(query, callback);
  }

  // Làm sạch địa chỉ tiếng Việt: Loại bỏ mã bưu chính, tên quốc gia (Vietnam), các tổ/khu phố thừa
  function _cleanVietnameseAddress(displayName) {
    if (!displayName) return '';
    var parts = displayName.split(',');
    var cleanParts = [];
    
    for (var i = 0; i < parts.length; i++) {
      var part = parts[i].trim();
      var lower = part.toLowerCase();
      
      // 1. Loại bỏ quốc gia Việt Nam/Vietnam
      if (lower === 'vietnam' || lower === 'việt nam') {
        continue;
      }
      // 2. Loại bỏ mã bưu chính (5-6 chữ số)
      if (/^\d{5,6}$/.test(part)) {
        continue;
      }
      // 3. Loại bỏ các cấp đơn vị nhỏ lẻ thừa (Khu phố, Tổ, Tổ dân phố)
      if (lower.indexOf('khu phố') === 0 || lower.indexOf('tổ dân phố') === 0 || lower.indexOf('tổ ') === 0) {
        continue;
      }
      
      // Viết tắt TP.HCM và Hà Nội cho ngắn gọn chuẩn mực
      if (part === 'Ho Chi Minh City' || part === 'Thành phố Hồ Chí Minh') {
        part = 'TP.HCM';
      } else if (part === 'Hanoi' || part === 'Thành phố Hà Nội' || part === 'Hà Nội') {
        part = 'Hà Nội';
      }
      
      cleanParts.push(part);
    }
    
    return cleanParts.join(', ');
  }

  // Chuẩn hóa/lọc truy vấn tiếng Việt trước khi gửi lên API
  function _cleanQuery(q) {
    if (!q) return '';
    var cleaned = q.trim().replace(/\s+/g, ' ');
    // Loại bỏ chữ cái đơn lẻ ở cuối câu nếu có khoảng trắng đứng trước (ví dụ: "tăng phú A" -> "tăng phú")
    cleaned = cleaned.replace(/\s+[a-zA-Z]$/, '');
    return cleaned;
  }

  // Hàm dự phòng (mặc định) gọi Nominatim API để tìm kiếm địa chỉ chính xác
  function _fallbackSearch(query, callback) {
    var cleanedQuery = _cleanQuery(query);
    console.log('[AddressAutocomplete] Sử dụng API gợi ý của Nominatim. Query gốc: "' + query + '", Sạch: "' + cleanedQuery + '"');
    
    // Tách số nhà/số hẻm ở đầu câu truy vấn (Ví dụ: "55", "80/1", "123B")
    var userNumMatch = cleanedQuery.match(/^(\d+[\/\w\-]*)\s+(.*)$/);
    var userNum = userNumMatch ? userNumMatch[1] : '';

    var url = 'https://nominatim.openstreetmap.org/search?q=' + encodeURIComponent(cleanedQuery) + '&format=json&limit=8&countrycodes=vn&addressdetails=1&lat=10.8494&lon=106.7729';
    
    fetch(url)
      .then(function (res) { return res.json(); })
      .then(function (data) {
        var results = [];
        if (data && data.length > 0) {
          results = data.map(function (item) {
            var display = item.display_name;
            
            // Nếu người dùng có gõ số nhà ở đầu và Nominatim tìm thấy tên đường cụ thể
            if (userNum && item.address && item.address.road) {
              var road = item.address.road;
              var addrParts = [];
              addrParts.push(userNum + ' ' + road);
              
              if (item.address.suburb) addrParts.push(item.address.suburb);
              if (item.address.city_district) addrParts.push(item.address.city_district);
              if (item.address.county) addrParts.push(item.address.county);
              if (item.address.city) addrParts.push(item.address.city);
              if (item.address.state) addrParts.push(item.address.state);
              
              display = addrParts.join(', ');
            }

            // Làm sạch địa chỉ bằng bộ lọc tiếng Việt rút gọn
            var cleanedAddress = _cleanVietnameseAddress(display);
            var parts = cleanedAddress.split(',');
            var primary = (parts[0] || '').trim();
            
            // Nếu phần tử đầu quá ngắn, gộp thêm cấp thứ hai
            if (parts.length > 1 && primary.length < 5) {
              primary = primary + ', ' + (parts[1] || '').trim();
              parts.splice(0, 2);
            } else {
              parts.splice(0, 1);
            }
            var secondary = parts.map(function(p) { return p.trim(); }).join(', ');
            return {
              primary: primary,
              secondary: secondary,
              full: cleanedAddress
            };
          });

          // Loại bỏ địa chỉ trùng lặp sau khi rút gọn
          var seen = {};
          results = results.filter(function (item) {
            if (seen[item.full]) return false;
            seen[item.full] = true;
            return true;
          });
        }
        
        // Nếu không có kết quả từ Nominatim (ví dụ do gõ từ dở dang như "tăng phú A"), chuyển sang Photon để tìm kiếm mờ
        if (results.length === 0) {
          console.log('[AddressAutocomplete] Nominatim không có kết quả, chuyển sang gọi Photon...');
          _photonFallbackSearch(query, callback);
        } else {
          console.log('[AddressAutocomplete] Nominatim API trả về:', results);
          callback(results.slice(0, 6));
        }
      })
      .catch(function (err) {
        console.warn('[AddressAutocomplete] Lỗi kết nối Nominatim, chuyển sang gọi Photon:', err);
        _photonFallbackSearch(query, callback);
      });
  }

  // Hàm dự phòng cuối cùng gọi Photon API
  function _photonFallbackSearch(query, callback) {
    var cleanedQuery = _cleanQuery(query);
    console.log('[AddressAutocomplete] Sử dụng API dự phòng Photon. Query sạch: "' + cleanedQuery + '"');
    
    var userNumMatch = cleanedQuery.match(/^(\d+[\/\w\-]*)\s+(.*)$/);
    var userNum = userNumMatch ? userNumMatch[1] : '';

    var url = CONFIG.photonUrl + '?q=' + encodeURIComponent(cleanedQuery) + '&limit=8&countrycode=vn&lat=10.8494&lon=106.7729';
    fetch(url)
      .then(function (res) { return res.json(); })
      .then(function (data) {
        var results = [];
        if (data && data.features) {
          results = data.features.map(function (f) {
            var p = f.properties;
            var road = p.street || p.name || '';
            var primary = road;
            
            // Nếu có số nhà gõ tay và tìm được tên đường từ Photon
            if (userNum && road) {
              primary = userNum + ' ' + road;
            }

            var secondaryParts = [];
            if (p.street && p.street !== road) secondaryParts.push(p.street);
            if (p.district) secondaryParts.push(p.district);
            if (p.city) secondaryParts.push(p.city);
            if (p.state || p.county) secondaryParts.push(p.state || p.county);
            if (p.country) secondaryParts.push(p.country);

            var secondary = secondaryParts.join(', ');
            var fullAddressParts = [];
            if (primary) fullAddressParts.push(primary);
            if (secondary) fullAddressParts.push(secondary);
            var fullAddress = fullAddressParts.join(', ');

            // Làm sạch địa chỉ cuối cùng
            var cleanedAddress = _cleanVietnameseAddress(fullAddress);
            var finalParts = cleanedAddress.split(',');
            var finalPrimary = (finalParts[0] || '').trim();
            finalParts.splice(0, 1);
            var finalSecondary = finalParts.map(function(p) { return p.trim(); }).join(', ');

            return {
              primary: finalPrimary,
              secondary: finalSecondary,
              full: cleanedAddress
            };
          });

          // Loại bỏ trùng lặp
          var seen = {};
          results = results.filter(function (item) {
            if (seen[item.full]) return false;
            seen[item.full] = true;
            return true;
          });
        }
        console.log('[AddressAutocomplete] Photon API trả về:', results);
        callback(results.slice(0, 6));
      })
      .catch(function (err) {
        console.error('[AddressAutocompletePlugin] Lỗi tìm kiếm Photon:', err);
        callback([]);
      });
  }

  // Kết xuất dropdown gợi ý
  function _renderDropdown(dropdown, items, onSelect) {
    dropdown.innerHTML = '';
    if (items.length === 0) {
      var emptyItem = document.createElement('div');
      emptyItem.style.cssText = 'padding: 10px 14px; font-size: 13px; color: var(--color-text-secondary, #64748b); font-style: italic;';
      emptyItem.innerText = 'Không tìm thấy địa chỉ gợi ý';
      dropdown.appendChild(emptyItem);
      return;
    }

    items.forEach(function (addressObj, idx) {
      var item = document.createElement('div');
      item.className = 'address-item';
      item.style.cssText = `
        padding: 8px 14px;
        font-size: 13px;
        color: var(--color-text, #1e293b);
        cursor: pointer;
        transition: all 0.2s ease;
        border-bottom: 1px solid var(--color-border-subtle, #f1f5f9);
        display: flex;
        align-items: center;
        gap: 12px;
        border-left: 3px solid transparent;
      `;
      if (idx === items.length - 1) {
        item.style.borderBottom = 'none';
      }

      var icon = document.createElement('span');
      icon.className = 'material-symbols-outlined address-icon';
      icon.style.cssText = 'font-size: 20px; color: var(--color-text-muted, #94a3b8); transition: transform 0.2s, color 0.2s;';
      icon.innerText = 'location_on';

      var details = document.createElement('div');
      details.className = 'address-details';
      details.style.cssText = 'display: flex; flex-direction: column; gap: 2px; overflow: hidden;';

      var primarySpan = document.createElement('span');
      primarySpan.className = 'address-primary';
      primarySpan.innerText = addressObj.primary;
      primarySpan.style.cssText = 'font-weight: 600; color: var(--color-text, #1e293b); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;';

      var secondarySpan = document.createElement('span');
      secondarySpan.className = 'address-secondary';
      secondarySpan.innerText = addressObj.secondary;
      secondarySpan.style.cssText = 'font-size: 11px; color: var(--color-text-secondary, #64748b); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;';

      details.appendChild(primarySpan);
      if (addressObj.secondary) {
        details.appendChild(secondarySpan);
      }

      item.appendChild(icon);
      item.appendChild(details);

      // hover hoặc chọn phần tử
      item.addEventListener('mouseenter', function () {
        var siblings = dropdown.querySelectorAll('.address-item');
        siblings.forEach(function (sib) { sib.classList.remove('active'); });
        item.classList.add('active');
      });

      item.addEventListener('click', function () {
        onSelect(addressObj.full);
      });

      dropdown.appendChild(item);
    });
  }

  // Tự động nhúng CSS vào trang khi plugin được nạp lần đầu
  function _injectStyles() {
    var styleId = 'address-autocomplete-styles';
    if (document.getElementById(styleId)) return;
    
    var style = document.createElement('style');
    style.id = styleId;
    style.innerHTML = `
      .address-item.active {
        background-color: var(--color-primary-light, rgba(79, 70, 229, 0.06)) !important;
        border-left: 3px solid var(--color-primary, #4f46e5) !important;
      }
      .address-item.active .address-icon {
        color: var(--color-primary, #4f46e5) !important;
        transform: scale(1.1);
      }
      .address-autocomplete-dropdown::-webkit-scrollbar {
        width: 6px;
      }
      .address-autocomplete-dropdown::-webkit-scrollbar-track {
        background: transparent;
      }
      .address-autocomplete-dropdown::-webkit-scrollbar-thumb {
        background: rgba(0, 0, 0, 0.15);
        border-radius: 3px;
      }
      .address-autocomplete-dropdown::-webkit-scrollbar-thumb:hover {
        background: rgba(0, 0, 0, 0.25);
      }
      body.dark-theme .address-autocomplete-dropdown {
        background: var(--color-surface, #1e293b) !important;
        border-color: var(--color-border, #475569) !important;
      }
      body.dark-theme .address-autocomplete-dropdown::-webkit-scrollbar-thumb {
        background: rgba(255, 255, 255, 0.15);
      }
      body.dark-theme .address-item {
        color: var(--color-text, #f8fafc) !important;
        border-bottom-color: var(--color-border-subtle, #334155) !important;
      }
      body.dark-theme .address-primary {
        color: var(--color-text, #f8fafc) !important;
      }
      body.dark-theme .address-secondary {
        color: var(--color-text-secondary, #94a3b8) !important;
      }
    `;
    document.head.appendChild(style);
  }

  // Hàm khởi tạo lắng nghe sự kiện tải Modal của Form Engine
  function onInitModal(formName, isEdit, modalEl, targetRow, MODULE_CONFIG) {
    // modalEl là container lớp bọc ngoài modal
    console.log('[AddressAutocomplete] onInitModal được gọi. FormName: ' + formName);
    var container = modalEl.querySelector('.ui-modal-body') || modalEl.querySelector('.modal-body') || modalEl;
    
    // Đảm bảo DOM được hiển thị hoàn tất trước khi quét tìm input
    setTimeout(function () {
      var input = _findAddressInput(container);
      if (input) {
        _setupAutocomplete(input);
      }
    }, 150);
  }

  // Đăng ký tự động plugin vào hệ thống Form Plugins
  window.FormPlugins = window.FormPlugins || [];
  var exists = window.FormPlugins.some(function (p) {
    return p.name === 'AddressAutocompletePlugin';
  });
  if (!exists) {
    window.FormPlugins.push({
      name: 'AddressAutocompletePlugin',
      onInitModal: onInitModal
    });
  }

  return {
    onInitModal: onInitModal
  };
})();
