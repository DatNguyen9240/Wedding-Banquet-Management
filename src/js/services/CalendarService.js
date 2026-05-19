/**
 * Lớp Dịch vụ Quản lý Dữ liệu Lịch (Calendar Service)
 * Đảm nhiệm việc fetch dữ liệu API, quản lý In-memory Cache, và format dữ liệu
 */
var CalendarService = (function () {
  var _calendarCache = {};
  var _isFetching = false;

  // Lắng nghe sự kiện toàn cục để tự động quét dọn Cache
  if (typeof EventBus !== 'undefined') {
    EventBus.on('BANQUET_MUTATED', function () {
      console.log('🔄 [CalendarService] Phát hiện có thay đổi Dữ liệu Tiệc, tự động quét sạch Lịch đệm.');
      invalidateCache();
    });
  }

  var _legendCache = null;

  function getLegend() {
    return new Promise(function(resolve, reject) {
      if (_legendCache) {
        return resolve(_legendCache);
      }
      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CALENDAR || !API_CONFIG.ENDPOINTS.CALENDAR.LEGEND) {
        return reject('Missing API_CONFIG.ENDPOINTS.CALENDAR.LEGEND');
      }
      ApiClient.get(API_CONFIG.ENDPOINTS.CALENDAR.LEGEND)
        .then(function(res) {
          var records = (res && res.records) ? res.records : (Array.isArray(res) ? res : []);
          _legendCache = records;
          resolve(records);
        })
        .catch(function(err) {
          console.warn('[CalendarService] Lỗi lấy Legend', err);
          resolve([]); // Trả về mảng rỗng nếu API lỗi để không bị crash FE
        });
    });
  }

  function invalidateCache() {
    console.log('🧹 [CalendarService] Đã xóa toàn bộ cache lịch.');
    _calendarCache = {};
  }

  // Chuyển logic format từ page vào service luôn để tái sử dụng
  function formatData(data) {
    var eventsData = {};
    data.forEach(function (row) {
      var ngay = row.NgayToChuc || row.ngayToChuc || row.Ngaytochuc || row.ngaytochuc;
      if (!ngay) return;
      var d = new Date(ngay);
      var day = d.getDate();

      if (!eventsData[day]) eventsData[day] = [];

      var loaiPhieu = row.LoaiPhieu !== undefined ? row.LoaiPhieu : row.loaiPhieu;
      var laSanhChinh = row.LaSanhChinh !== undefined ? row.LaSanhChinh : row.laSanhChinh;
      var tenSanh = row.TenSanh || row.tenSanh || '';
      var soBan = row.SoBan || row.soBan || 0;

      // LoaiPhieu = 1 -> Xanh (Mới cọc), 2 -> Đỏ (Đã HĐ)
      var type = loaiPhieu === 1 ? 'success' : 'primary';

      // Sảnh chính thì ghi số bàn, sảnh phụ ghi X
      var suffix = laSanhChinh === 1 ? soBan : 'X';
      var label = tenSanh + ' (' + suffix + ')';

      eventsData[day].push({
        type: type,
        label: label,
        rawData: row
      });
    });
    return eventsData;
  }

  var _pendingResolvers = [];

  function fetchEvents(year, month, forceRefresh) {
    forceRefresh = forceRefresh || false;
    var cacheKey = year + '-' + (month + 1).toString().padStart(2, '0');

    return new Promise(function (resolve, reject) {
      if (!forceRefresh && _calendarCache[cacheKey]) {
        console.log('⚡ [CalendarService] Cache Hit cho tháng:', cacheKey);
        return resolve(_calendarCache[cacheKey]);
      }

      // Nếu đang fetch cùng tháng đó rồi, xếp vào queue chờ
      if (_isFetching) {
        _pendingResolvers.push({ resolve: resolve, reject: reject, cacheKey: cacheKey });
        return;
      }

      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CALENDAR || !API_CONFIG.ENDPOINTS.CALENDAR.LIST) {
        console.warn('Chưa cấu hình API_CONFIG.ENDPOINTS.CALENDAR.LIST.');
        return reject('Missing API_CONFIG');
      }

      console.log('🌐 [CalendarService] Fetching dữ liệu lịch cho tháng:', cacheKey);
      _isFetching = true;

      var payloadString = encodeURIComponent(JSON.stringify({ Thang: month + 1, Nam: year }));
      var endpoint = API_CONFIG.ENDPOINTS.CALENDAR.LIST + '?q=' + payloadString;

      ApiClient.get(endpoint)
        .then(function (res) {
          var data = res.records || res.data || res || [];
          var eventsData = formatData(data);
          _calendarCache[cacheKey] = eventsData;
          resolve(eventsData);
          // Flush pending resolvers
          _pendingResolvers.forEach(function(p) {
            var cached = _calendarCache[p.cacheKey];
            if (cached) p.resolve(cached); else p.reject('No data');
          });
          _pendingResolvers = [];
        })
        .catch(function (err) {
          console.error('[CalendarService] Lỗi khi tải lịch:', err);
          reject(err);
          _pendingResolvers.forEach(function(p) { p.reject(err); });
          _pendingResolvers = [];
        })
        .finally(function () {
          _isFetching = false;
        });
    });
  }

  return {
    fetchEvents: fetchEvents,
    getLegend: getLegend,
    invalidateCache: invalidateCache
  };
})();
