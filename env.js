/**
 * ============================================================
 *  WEDDING BANQUET MANAGEMENT — CẤU HÌNH HỆ THỐNG
 *  File này là nơi định nghĩa toàn bộ cấu hình API của hệ thống
 * ============================================================
 */

// 1. Tham số môi trường (Environment Variables)
const ENV_VARS = {
    API_BASE: 'https://qlt.bms79.com', // Domain backend thực tế
};

// 2. Cấu hình API chi tiết
window.API_CONFIG = {
    BASE_URL: ENV_VARS.API_BASE,

    ENDPOINTS: {
        AUTH: {
            LOGIN: '/api/login',
            LOGOUT: '/logout',
            USER_INFO: '/api/API_UserInfo',
        },

        PERMISSIONS: {
            SYNC: '/api/API_DongBoQuyenTruyCap',
            GET_MENU_BY_GROUP: '/api/API_LayMenuTheoNhomQuyen',
            GET_ALL_MENUS_FOR_GROUP: '/api/API_LayQuyenNhomDayDu',
            SAVE_GROUP_PERMISSIONS: '/api/API_LuuQuyenCuaNhom',
            GET_GROUP_LIST: '/api/API_LayDanhSachNhom',
        },

        BOOKING: {
            LIST: '/api/API_DanhSachPhieuCoc',
            SAVE: '/api/API_LuuPhieuCoc',
            CANCEL: '/api/API_HuyPhieuCoc',
        },
        CUSTOMER: {
            SEARCH: '/api/API_TimKiemKhachHang',
            SAVE: '/api/API_LuuKhachHang',
        },
        SYSTEM: {
            HALLS: '/api/API_DanhSachSanh',
            SHIFTS: '/api/API_DanhSachCaLam',
            BANQUET_TYPES: '/api/API_DanhSachLoaiHinhTiec',
            SETUP_VALUE: '/api/API_LayGiaTriSetup',
            GET_UI_DICTIONARY: '/api/API_LayCacTruongGiaoDien'
        },
        CONTRACT: {
            LIST: '/api/API_DanhSachHopDong',
        },
        FOODS: {
            LIST: '/api/API_DanhSachThucDon',
        },
        CALENDAR: {
            LIST: '/api/API_DanhSachLich',
            SAVE: '/api/API_LuuPhieuCoc',
            LEGEND: '/api/API_LayChuThichLich'
        },
        VISITOR: {
            LIST: '/api/API_DanhSachKhachDen',
            SAVE: '/api/API_LuuKhachDen',
        },
        REPORTS: {
            REVENUE: '/api/API_Report_Revenue',
            COST: '/api/API_Report_Cost',
        },
        MENUS: {
            GET_ALL: '/api/API_LayDanhSachMenuTatCa',
            SAVE: '/api/API_LuuMenu',
            DELETE: '/api/API_XoaMenu',
            UPDATE_ORDER: '/api/API_LuuThuTuMenu',
        }
    }
};

// Đảm bảo biến có thể truy cập trực tiếp bằng tên trong tất cả các scope
var API_CONFIG = window.API_CONFIG;

// Đóng băng config trong runtime
Object.freeze(window.API_CONFIG);
Object.freeze(window.API_CONFIG.ENDPOINTS);
