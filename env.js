/**
 * ============================================================
 *  WEDDING BANQUET MANAGEMENT — CẤU HÌNH HỆ THỐNG
 *  File này là nơi định nghĩa toàn bộ cấu hình API của hệ thống
 * ============================================================
 */

// 1. Tham số môi trường (Environment Variables)
const ENV_VARS = {
    API_BASE: 'https://qlt.bms79.com', // Domain backend thực tế (SQL Server API Gateway)

    // Cấu hình máy chạy Node.js Backend (server.js - Port 8081)
    // LƯU Ý: Nếu chạy Node.js Backend trên máy cá nhân (Local) và Docker OnlyOffice trên máy khác,
    // bạn PHẢI đổi BACKEND_HOST thành IP LAN hoặc IP Public của máy bạn (không dùng localhost/127.0.0.1)
    // để Docker OnlyOffice có thể kết nối ngược lại tải file và lưu callback.
    BACKEND_HOST: '103.190.38.46',

    // Cấu hình máy chạy Docker OnlyOffice (Document Server - Port 8082)
    ONLYOFFICE_HOST: '103.190.38.46',

    // Khi frontend chạy trên HTTPS (Vercel, production), dùng HTTPS proxy qua nginx
    // Nginx cần có location /docserver/ { proxy_pass http://127.0.0.1:8081; }
    // Xem file: backend-app/nginx-docserver.conf
    get DOCSERVER_BASE() {
        var isHttps = typeof window !== 'undefined' && window.location && window.location.protocol === 'https:';
        if (isHttps) {
            // Production: proxy qua nginx (/docserver/ → localhost:8081)
            return 'https://qlt.bms79.com/docserver';
        }
        // Local dev: gọi thẳng HTTP
        return 'http://' + this.BACKEND_HOST + ':8081';
    }
};

// 2. Cấu hình API chi tiết
window.API_CONFIG = {
    BASE_URL: ENV_VARS.API_BASE,

    ENDPOINTS: {
        ROUTER: '/api/API_Gateway_Router',
        AUTH: {
            LOGIN: '/api/login',
            LOGOUT: '/logout',
            USER_INFO: '/api/API_UserInfo',
        },

        DOCUMENT_MANAGER: {
            NODE_IP: ENV_VARS.BACKEND_HOST,
            BASE_API: ENV_VARS.DOCSERVER_BASE + '/api/documents',
            ONLYOFFICE_API: 'http://' + ENV_VARS.ONLYOFFICE_HOST + ':8082/web-apps/apps/api/documents/api.js',
            UPLOADS_URL: ENV_VARS.DOCSERVER_BASE + '/uploads/',
            SAMPLES_URL: ENV_VARS.DOCSERVER_BASE + '/samples/'
        },

        PERMISSIONS: {
            SYNC: '/api/API_DongBoQuyenTruyCap',
            GET_MENU_BY_GROUP: '/api/API_LayMenuTheoNhomQuyen',
            GET_ALL_MENUS_FOR_GROUP: '/api/API_LayQuyenNhomDayDu',
            SAVE_GROUP_PERMISSIONS: '/api/API_LuuQuyenCuaNhom',
            GET_GROUP_LIST: '/api/API_LayDanhSachNhom',
            GET_VERSION: '/api/API_LayPhienBanQuyen',
            GET_MY_PERMISSIONS: '/api/API_LayQuyenCuaToi',
        },

        BOOKING: {
            LIST: '/api/API_DanhSachPhieuCoc',
            SAVE: '/api/API_LuuPhieuCoc',
            CANCEL: '/api/API_HuyPhieuCoc',
            DELETE: '/api/API_XoaPhieuCoc',
        },
        CUSTOMER: {
            SEARCH: '/api/API_DanhSachKhachHang',
            SAVE: '/api/API_LuuKhachHang',
        },
        SYSTEM: {
            HALLS: '/api/API_DanhSachSanh',
            SHIFTS: '/api/API_DanhSachCaLam',
            BANQUET_TYPES: '/api/API_DanhSachLoaiHinhTiec',
            SETUP_VALUE: '/api/API_LayGiaTriSetup',
            GET_UI_DICTIONARY: '/api/API_LayCacTruongGiaoDien',
            GET_FIELDS_LIST: '/api/API_DanhSachTruongGiaoDien',
            SAVE_FIELD: '/api/API_LuuTruongGiaoDien',
            DELETE_FIELD: '/api/API_XoaTruongGiaoDien'
        },
        CONTRACT: {
            LIST: '/api/API_DanhSachHopDong',
            SAVE: '/api/API_LuuHopDong',
        },
        FOODS: {
            LIST: '/api/API_DanhSachThucDon',
        },
        CALENDAR: {
            LIST: '/api/API_DanhSachLich',
            SAVE: '/api/API_LuuLich',
            LEGEND: '/api/API_LayChuThichLich'
        },
        REPORTS: {
            SALES_STATS: '/api/API_Report_SalesStats',
            REVENUE: '/api/API_Report_Revenue',
            COST: '/api/API_Report_Cost',
        },
        VISITOR: {
            LIST: '/api/API_DanhSachKhachDen',
            SAVE: '/api/API_LuuKhachDen',
        },
        STAFF: {
            LIST: '/api/API_DanhSachNhanVien',
            SAVE: '/api/API_LuuNhanVien',
        },
        CHECKOUT: {
            LIST: '/api/API_DanhSachQuyetToan',
            SAVE: '/api/API_LuuQuyenToan',
            CONTRACT_LIST: '/api/API_DanhSachHopDong',
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
