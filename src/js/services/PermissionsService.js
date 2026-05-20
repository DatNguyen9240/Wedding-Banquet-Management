/**
 * PermissionsService
 * Quản lý toàn bộ API call liên quan đến Phân Quyền Người Dùng.
 */
var PermissionsService = (function () {

  function _ep(key) {
    return (window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.PERMISSIONS)
      ? window.API_CONFIG.ENDPOINTS.PERMISSIONS[key]
      : null;
  }

  function _currentGroupId() {
    var u = JSON.parse(localStorage.getItem('pmql_user') || '{}');
    return u.Group || u.GroupUser || u.GroupID || u.group || u.NhomQuyen || 'Admin';
  }

  /**
   * Lấy danh sách nhóm quyền
   * @returns {Promise<Array>}
   */
  function getGroups() {
    return new Promise(function (resolve, reject) {
      var endpoint = _ep('GET_GROUP_LIST') || '/api/API_SY_LayDanhSachNhom';
      ApiClient.get(endpoint)
        .then(function (res) {
          if (res && res.code === 0 && res.records) {
            resolve(res.records);
          } else {
            resolve([]);
          }
        })
        .catch(function (err) {
          console.error('[PermissionsService] Lỗi getGroups:', err);
          reject(err);
        });
    });
  }

  /**
   * Lấy danh sách menu theo nhóm quyền
   * @param {string} groupId - ID nhóm cần lấy quyền
   * @returns {Promise<Array>}
   */
  function getMenusByGroup(groupId) {
    return new Promise(function (resolve, reject) {
      var endpoint = _ep('GET_MENU_BY_GROUP') || '/api/API_WA_LayMenuTheoNhomQuyen';
      ApiClient.post(endpoint, {
        NhomNguoiDangThaoTac: _currentGroupId(),
        UserGroupID: groupId
      })
        .then(function (res) {
          var records = (res && res.records) ? res.records : (res && res.data ? res.data : []);
          resolve(records);
        })
        .catch(function (err) {
          console.error('[PermissionsService] Lỗi getMenusByGroup:', err);
          reject(err);
        });
    });
  }

  /**
   * Lưu quyền cho một menu thuộc nhóm
   * @param {Object} payload
   * @returns {Promise}
   */
  function savePermission(payload) {
    return new Promise(function (resolve, reject) {
      var endpoint = _ep('SAVE_GROUP_PERMISSIONS') || '/api/API_WA_LuuQuyenCuaNhom';
      ApiClient.post(endpoint, payload)
        .then(resolve)
        .catch(function (err) {
          console.error('[PermissionsService] Lỗi savePermission:', err);
          reject(err);
        });
    });
  }

  /**
   * Đồng bộ quyền truy cập toàn hệ thống
   * @returns {Promise}
   */
  function sync() {
    return new Promise(function (resolve, reject) {
      var endpoint = _ep('SYNC') || '/api/API_WA_DongBoQuyenTruyCap';
      ApiClient.post(endpoint, { NhomNguoiDangThaoTac: _currentGroupId() })
        .then(resolve)
        .catch(function (err) {
          console.error('[PermissionsService] Lỗi sync:', err);
          reject(err);
        });
    });
  }

  return {
    getGroups: getGroups,
    getMenusByGroup: getMenusByGroup,
    savePermission: savePermission,
    sync: sync
  };
})();
