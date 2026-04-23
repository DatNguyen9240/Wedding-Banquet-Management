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
            SYNC: '/api/API_WA_DongBoQuyenTruyCap',
            GET_MENU_BY_GROUP: '/api/API_WA_LayMenuTheoNhomQuyen',
            SAVE_GROUP_PERMISSIONS: '/api/API_WA_LuuQuyenCuaNhom',
            GET_GROUP_LIST: '/api/API_SY_LayDanhSachNhom',
        },

        // D\u1ef1 ki\u1ebfn s\u1ebd c\u00f3 c\u00e1c module n\u00e0y trong t\u01b0\u01a1ng lai
        BOOKING: {
            LIST: '/api/API_Booking_List',
            CREATE: '/api/API_Booking_Create',
        },
        CONTRACT: {
            LIST: '/api/API_Contract_List',
        },
        REPORTS: {
            REVENUE: '/api/API_Report_Revenue',
            COST: '/api/API_Report_Cost',
        }
    }
};

// Đảm bảo biến có thể truy cập trực tiếp bằng tên trong tất cả các scope
var API_CONFIG = window.API_CONFIG;

// Đóng băng config đ\u1ec3 tr\u00e1nh b\u1ecb thay \u0111\u1ed5i trong runtime
Object.freeze(window.API_CONFIG);
Object.freeze(window.API_CONFIG.ENDPOINTS);
