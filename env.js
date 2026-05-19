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

        BOOKING: {
            LIST: '/api/API_Booking_List',
            SAVE: '/api/API_Booking_Save',
            CANCEL: '/api/API_Booking_Cancel',
        },
        CUSTOMER: {
            SEARCH: '/api/API_Customer_Search',
        },
        SYSTEM: {
            HALLS: '/api/API_Hall_List',
            SHIFTS: '/api/API_Shift_List',
        },
        CONTRACT: {
            LIST: '/api/API_Contract_List',
        },
        CALENDAR: {
            LIST: '/api/API_Calendar_List',
        },
        VISITOR: {
            LIST: '/api/API_Visitor_List',
            SAVE: '/api/API_Visitor_Save',
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
