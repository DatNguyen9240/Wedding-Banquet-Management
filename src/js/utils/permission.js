/**
 * Permission Utility
 * Quản lý phân quyền hiển thị UI
 */
var Permission = (function () {
  function _get(module) {
    var perms = JSON.parse(localStorage.getItem('app_permissions') || '{}');
    // Mặc định cho phép tất cả ở môi trường phát triển ban đầu
    if (Object.keys(perms).length === 0) {
      return { xem: true, them: true, sua: true, xoa: true };
    }
    return perms[module] || { xem: false, them: false, sua: false, xoa: false };
  }

  return {
    canView:   function (module) { return _get(module).xem; },
    canAdd:    function (module) { return _get(module).them; },
    canEdit:   function (module) { return _get(module).sua; },
    canDelete: function (module) { return _get(module).xoa; }
  };
})();
