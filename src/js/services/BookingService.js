/**
 * BookingService
 * Quản lý toàn bộ API call liên quan đến Biên nhận Cọc chỗ (Booking).
 */
var BookingService = (function () {

  /**
   * Lấy danh sách biên nhận cọc
   * @param {Object} filterParams - { Keyword, TuNgay, DenNgay }
   * @returns {Promise<Array>}
   */
  function getList(filterParams) {
    return new Promise(function (resolve, reject) {
      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.BOOKING || !API_CONFIG.ENDPOINTS.BOOKING.LIST) {
        console.warn('[BookingService] Thiếu cấu hình API BOOKING.LIST');
        return resolve([]);
      }
      var payloadString = encodeURIComponent(JSON.stringify(filterParams || {}));
      var endpoint = API_CONFIG.ENDPOINTS.BOOKING.LIST + '?q=' + payloadString;

      ApiClient.get(endpoint)
        .then(function (res) {
          var data = [];
          if (res && res.records)      data = res.records;
          else if (res && res.data)    data = res.data;
          else if (Array.isArray(res)) data = res;
          resolve(data);
        })
        .catch(function (err) {
          console.error('[BookingService] Lỗi getList:', err);
          reject(err);
        });
    });
  }

  /**
   * Hủy phiếu cọc
   * @param {Object} payload - { DocumentID, Lydohuy }
   * @returns {Promise}
   */
  function cancel(payload) {
    return new Promise(function (resolve, reject) {
      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.BOOKING || !API_CONFIG.ENDPOINTS.BOOKING.CANCEL) {
        return reject('Chưa cấu hình API BOOKING.CANCEL');
      }
      ApiClient.post(API_CONFIG.ENDPOINTS.BOOKING.CANCEL, payload)
        .then(resolve)
        .catch(function (err) {
          console.error('[BookingService] Lỗi cancel:', err);
          reject(err);
        });
    });
  }

  /**
   * Tìm kiếm khách hàng theo từ khóa
   * @param {string} keyword
   * @returns {Promise<Array>}
   */
  function searchCustomer(keyword) {
    return new Promise(function (resolve, reject) {
      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.CUSTOMER || !API_CONFIG.ENDPOINTS.CUSTOMER.SEARCH) {
        return resolve([]);
      }
      ApiClient.get(API_CONFIG.ENDPOINTS.CUSTOMER.SEARCH + '?Keyword=' + encodeURIComponent(keyword))
        .then(function (res) {
          var list = (res && res.records) ? res.records : (Array.isArray(res) ? res : []);
          resolve(list);
        })
        .catch(function (err) {
          console.error('[BookingService] Lỗi searchCustomer:', err);
          reject(err);
        });
    });
  }

  /**
   * Lưu biên nhận cọc (thêm mới hoặc cập nhật)
   * @param {Object} payload
   * @returns {Promise}
   */
  function save(payload) {
    return new Promise(function (resolve, reject) {
      if (typeof API_CONFIG === 'undefined' || !API_CONFIG.ENDPOINTS.BOOKING || !API_CONFIG.ENDPOINTS.BOOKING.SAVE) {
        return reject('Thiếu cấu hình API BOOKING.SAVE');
      }
      ApiClient.post(API_CONFIG.ENDPOINTS.BOOKING.SAVE, payload)
        .then(resolve)
        .catch(function (err) {
          console.error('[BookingService] Lỗi save:', err);
          reject(err);
        });
    });
  }

  return {
    getList: getList,
    cancel: cancel,
    searchCustomer: searchCustomer,
    save: save
  };
})();
