/**
 * AppModules.js
 * Chứa toàn bộ cấu hình (Configuration) cho các màn hình (Modules) trong hệ thống.
 * Tách rời khỏi router.js để router chỉ làm đúng nhiệm vụ điều hướng.
 */

window.APP_MODULES = {
    // ----------------------------------------------------------------------
    // 1. MODULE: KHÁCH HÀNG (CUSTOMERS)
    // ----------------------------------------------------------------------
    CUSTOMERS: {
        FormName: 'frmCustomer',
        
        // --- API Mappings ---
        ApiDictionary: window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.SYSTEM ? window.API_CONFIG.ENDPOINTS.SYSTEM.GET_UI_DICTIONARY : null,
        ApiSearch: window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.CUSTOMER ? window.API_CONFIG.ENDPOINTS.CUSTOMER.SEARCH : null,
        ApiSave: window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.CUSTOMER ? window.API_CONFIG.ENDPOINTS.CUSTOMER.SAVE : null,
        
        // --- i18n & Labels ---
        PageTitle: 'Hồ Sơ Khách Hàng',
        PageSubtitle: 'Quản lý danh bạ và lịch sử giao dịch của khách đặt tiệc',
        TitleAdd: '➕ Thêm Khách Hàng Mới',
        TitleEdit: '✏️ Sửa Khách Hàng',
        ToastAdd: 'Đã thêm mới thành công!',
        ToastEdit: 'Đã cập nhật thành công!',
        BtnSaveAdd: 'Thêm mới',
        BtnSaveEdit: 'Lưu thay đổi',
        WarnSelectEdit: 'Vui lòng chọn dữ liệu cần sửa',
        WarnSelectDelete: 'Vui lòng chọn dữ liệu cần xóa',
        ConfirmDelete: 'Bạn có chắc muốn xóa <b>{0}</b>?',
        InfoDeleteDev: 'Chức năng xóa đang phát triển',
        
        // --- Table Keys ---
        PrimaryKey: 'Makh',
        RowNameField: 'TenKhach',

        SearchPlaceholder: 'Nhập mã KH, tên, số điện thoại...',
        FilterKeywordLabel: 'Từ khóa',
        TextLoading: 'Đang tải dữ liệu...',
        TextLoadingError: 'Lỗi tải giao diện: ',
        BtnCancel: 'Hủy bỏ',
        BtnSaveSaving: 'Đang lưu...',
        AlertTitleWarning: 'Cảnh báo',
        AlertTitleConfirm: 'Xác nhận xóa',
        AlertTitleInfo: 'Thông báo',
        AlertTitleError: 'Lỗi',
        AlertApiMissing: 'Chưa cấu hình API lưu dữ liệu!',
        AlertSaveFailed: 'Lưu thất bại',
        AlertNetworkError: 'Lỗi kết nối máy chủ',
        WarnMissingInfo: 'Thiếu thông tin',
        WarnMissingInput: 'Vui lòng nhập đầy đủ: {0}',
        TextDeleteFallback: 'dòng này',
        MenuCopyCell: 'Sao chép Ô này (Cell)',
        MenuCopyRow: 'Sao chép Hàng này (Row)',
        ToastCopyCell: 'Đã sao chép ô!',
        ToastCopyRow: 'Đã sao chép cả hàng!',
        ModalWidth: '600px'
    },

    // ----------------------------------------------------------------------
    // 2. MODULE: NHÂN VIÊN PHỤC VỤ (STAFF)
    // ----------------------------------------------------------------------
    STAFF: {
        FormName: 'frmStaff',
        
        // --- API Mappings ---
        ApiDictionary: window.API_CONFIG && window.API_CONFIG.ENDPOINTS && window.API_CONFIG.ENDPOINTS.SYSTEM ? window.API_CONFIG.ENDPOINTS.SYSTEM.GET_UI_DICTIONARY : null,
        ApiSearch: null, // Bổ sung API Danh sách nhân viên sau
        ApiSave: null,   // Bổ sung API Lưu nhân viên sau
        
        // --- i18n & Labels ---
        PageTitle: 'Nhân viên Phục vụ Tiệc',
        PageSubtitle: 'Quản lý hồ sơ nhân viên thời vụ và fulltime',
        TitleAdd: '➕ Thêm Nhân Viên',
        TitleEdit: '✏️ Sửa Hồ Sơ',
        ToastAdd: 'Đã thêm nhân viên thành công!',
        ToastEdit: 'Đã cập nhật hồ sơ thành công!',
        BtnSaveAdd: 'Thêm mới',
        BtnSaveEdit: 'Lưu thay đổi',
        WarnSelectEdit: 'Vui lòng chọn nhân viên cần sửa',
        WarnSelectDelete: 'Vui lòng chọn nhân viên cần xóa',
        ConfirmDelete: 'Bạn có chắc muốn xóa hồ sơ nhân viên <b>{0}</b>?',
        InfoDeleteDev: 'Chức năng xóa đang phát triển',
        
        // --- Table Keys ---
        PrimaryKey: 'NHANVIENID', 
        RowNameField: 'TENNHANVIEN', 

        SearchPlaceholder: 'Nhập mã NV, tên, số điện thoại...',
        FilterKeywordLabel: 'Tìm kiếm',
        TextLoading: 'Đang tải dữ liệu nhân viên...',
        TextLoadingError: 'Lỗi tải giao diện: ',
        BtnCancel: 'Hủy bỏ',
        BtnSaveSaving: 'Đang lưu...',
        AlertTitleWarning: 'Cảnh báo',
        AlertTitleConfirm: 'Xác nhận xóa',
        AlertTitleInfo: 'Thông báo',
        AlertTitleError: 'Lỗi',
        AlertApiMissing: 'Chưa cấu hình API lưu nhân viên!',
        AlertSaveFailed: 'Lưu thất bại',
        AlertNetworkError: 'Lỗi kết nối máy chủ',
        WarnMissingInfo: 'Thiếu thông tin',
        WarnMissingInput: 'Vui lòng nhập đầy đủ: {0}',
        TextDeleteFallback: 'nhân viên này',
        MenuCopyCell: 'Sao chép Ô này (Cell)',
        MenuCopyRow: 'Sao chép Hàng này (Row)',
        ToastCopyCell: 'Đã sao chép ô!',
        ToastCopyRow: 'Đã sao chép cả hàng!',
        ModalWidth: '600px'
    }

    // ----------------------------------------------------------------------
    // 3. MODULE: HỢP ĐỒNG (CONTRACTS) - Ví dụ cho tương lai
    // ----------------------------------------------------------------------
    /*
    CONTRACTS: {
        FormName: 'frmContract',
        ApiDictionary: window.API_CONFIG.ENDPOINTS.SYSTEM.GET_UI_DICTIONARY,
        ApiSearch: window.API_CONFIG.ENDPOINTS.CONTRACT.LIST,
        // ...
    }
    */
};

// Đóng băng config
Object.freeze(window.APP_MODULES);
