/**
 * Lớp Dịch vụ Quản lý Dữ liệu Lịch (Calendar Service)
 * Đảm nhiệm việc fetch dữ liệu API, quản lý In-memory Cache, và format dữ liệu
 */
var CalendarService = (function() {
  var _calendarCache = {};
  var _isFetching = false;

  // Lắng nghe sự kiện toàn cục để tự động quét dọn Cache
  if (typeof EventBus !== 'undefined') {
    EventBus.on('BANQUET_MUTATED', function() {
      console.log('🔄 [CalendarService] Phát hiện có thay đổi Dữ liệu Tiệc, tự động quét sạch Lịch đệm.');
      invalidateCache();
    });
  }

  function invalidateCache() {
    console.log('🧹 [CalendarService] Đã xóa toàn bộ cache lịch.');
    _calendarCache = {};
  }

  // Chuyển logic format từ page vào service luôn để tái sử dụng
  function formatData(data) {
    var eventsData = {};
    data.forEach(function(row) {
       if (!row.NgayToChuc) return;
       var d = new Date(row.NgayToChuc);
       var day = d.getDate();
       
       if (!eventsData[day]) eventsData[day] = [];
       
       // LoaiPhieu = 1 -> Xanh (Mới cọc), 2 -> Đỏ (Đã HĐ)
       var type = row.LoaiPhieu === 1 ? 'success' : 'primary';
       
       // Sảnh chính thì ghi số bàn, sảnh phụ ghi X
       var suffix = row.LaSanhChinh === 1 ? row.SoBan : 'X';
       var label = row.TenSanh + ' (' + suffix + ')';

       eventsData[day].push({
         type: type,
         label: label,
         rawData: row
       });
    });
    return eventsData;
  }

  function fetchEvents(year, month, forceRefresh) {
    forceRefresh = forceRefresh || false;
    var cacheKey = year + '-' + (month + 1).toString().padStart(2, '0');

    return new Promise(function(resolve, reject) {
      if (!forceRefresh && _calendarCache[cacheKey]) {
        console.log('⚡ [CalendarService] Cache Hit cho tháng:', cacheKey);
        return resolve(_calendarCache[cacheKey]);
      }

      if (_isFetching) return;

      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CALENDAR || !API_CONFIG.ENDPOINTS.CALENDAR.LIST) {
        console.warn('Chưa cấu hình API_CONFIG.ENDPOINTS.CALENDAR.LIST.');
        return reject('Missing API_CONFIG'); 
      }

      console.log('🌐 [CalendarService] Fetching dữ liệu lịch cho tháng:', cacheKey);
      _isFetching = true;

      var payloadString = encodeURIComponent(JSON.stringify({ Thang: month + 1, Nam: year }));
      var endpoint = API_CONFIG.ENDPOINTS.CALENDAR.LIST + '?q=' + payloadString;

      ApiClient.get(endpoint)
        .then(function(res) {
          var data = res.records || res.data || res || [];
          var eventsData = formatData(data);
          _calendarCache[cacheKey] = eventsData;
          resolve(eventsData);
        })
        .catch(function(err) {
          console.error('[CalendarService] Lỗi khi tải lịch:', err);
          reject(err);
        })
        .finally(function() {
          _isFetching = false;
        });
    });
  }

  return {
    fetchEvents: fetchEvents,
    invalidateCache: invalidateCache
  };
})();
