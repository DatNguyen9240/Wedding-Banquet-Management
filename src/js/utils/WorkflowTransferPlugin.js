/**
 * WorkflowTransferPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin dùng để chuyển dữ liệu từ các màn hình này sang màn hình khác.
 * Ví dụ: Khách tham quan -> Biên nhận cọc (Auto-fill)
 */
var WorkflowTransferPlugin = (function () {

    function _autoClickAdd() {
        setTimeout(function () {
            var btnAdd = document.querySelector('button[title*="Thêm bản ghi mới"], button[title="Thêm"], .btn-primary:not(.btn-tool)');
            if (btnAdd) btnAdd.click();
        }, 800);
    }

    // --- CẤU HÌNH CÁC NÚT TRANSFER ---
    var FORM_CONFIG = {
        'frmKhachThamQuan': {
            id: 'btn-transfer-booking',
            text: 'Tạo Cọc',
            icon: 'monetization_on',
            targetHash: '#/booking',
            storageKey: 'transfer_VisitorToBooking',
            getTransferData: function(row) {
                return {
                    Tenkh: row.TenKhachHang || row.Tenkh || row.Tenchure || row.Tencodau || '',
                    Dienthoai: row.DienThoai || row.Dienthoai || row.DTchure || row.DTcodau || '',
                    Ngaytochuc: row._Ngaytochuc || row.NgayToChucGoc || row.NgayDuKien || row.Ngaytochuc || ''
                };
            }
        },
        'frmHopDong': {
            id: 'btn-transfer-checkout',
            text: 'Quyết Toán',
            icon: 'receipt_long',
            targetHash: '#/checkout',
            storageKey: 'transfer_ContractToCheckout',
            getTransferData: function(row) {
                return {
                    Sohopdong: row.Sohopdong || row.AutoID || '',
                    Tenkh: row.Tenkh || row.Tenchure || row.Tencodau || '',
                    Ngaytochuc: row._Ngaytochuc || row.Ngaytochuc || ''
                };
            }
        }
    };

    function getExtraButtons(formName, getSelectedRows) {
        var config = FORM_CONFIG[formName];
        if (!config) return [];

        return [{
            id: config.id,
            text: config.text,
            icon: config.icon,
            type: 'tool',
            onClick: function() {
                var selectedRows = getSelectedRows();
                if (!selectedRows || selectedRows.length !== 1) {
                    if (window.Alert) Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 dòng duy nhất để ' + config.text + '.');
                    else alert('Vui lòng chọn 1 dòng!');
                    return;
                }
                
                var transferData = config.getTransferData(selectedRows[0]);
                sessionStorage.setItem(config.storageKey, JSON.stringify(transferData));
                window.location.hash = config.targetHash;
                _autoClickAdd();
            }
        }];
    }

    // --- XỬ LÝ AUTO-FILL KHI MỞ FORM THÊM MỚI ---
    var _observer = null;

    function _handleAutoFill() {
        var modalContent = document.querySelector('.modal-content');
        if (!modalContent) return;
        var modalTitle = modalContent.querySelector('.modal-title');
        if (!modalTitle || modalTitle.innerText.indexOf('Thêm') === -1) return;

        var dataV2B = sessionStorage.getItem('transfer_VisitorToBooking');
        if (dataV2B) {
            _fillData(JSON.parse(dataV2B), 'Khách Tham Quan');
            sessionStorage.removeItem('transfer_VisitorToBooking');
            return;
        }

        var dataC2C = sessionStorage.getItem('transfer_ContractToCheckout');
        if (dataC2C) {
            _fillData(JSON.parse(dataC2C), 'Hợp Đồng Tiệc');
            sessionStorage.removeItem('transfer_ContractToCheckout');
            return;
        }
    }

    function _fillData(data, sourceName) {
        setTimeout(function () {
            var modalContent = document.querySelector('.modal-content');
            if (!modalContent) return;
            var filled = false;

            var tryFill = function(selectors, value) {
                if (!value) return;
                var el = modalContent.querySelector(selectors);
                if (el && !el.value) {
                    el.value = value;
                    el.style.backgroundColor = '#f0fdf4';
                    el.style.borderColor = '#10b981';
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    filled = true;
                }
            };

            tryFill('input[name="Tenkh"], input[name="Tenchure"], input[name="Tencodau"]', data.Tenkh);
            tryFill('input[name="Dienthoai"], input[name="DTchure"], input[name="DTcodau"]', data.Dienthoai);
            tryFill('input[name="_Ngaytochuc"], input[name="Ngaytochuc"], input[name="Ngaydukien"]', data.Ngaytochuc);
            tryFill('input[name="SanhTiec"], select[name="Tensanh"]', data.SanhTiec);
            tryFill('input[name="Sohopdong"]', data.Sohopdong);
            
            if (filled && window.Toast) {
                Toast.success('Đã tự động điền thông tin từ ' + sourceName + '!');
            }
        }, 300);
    }

    function init() {
        if (_observer) _observer.disconnect();
        
        // Chỉ observe để auto-fill (chờ modal xuất hiện)
        _observer = new MutationObserver(function () {
            _handleAutoFill();
        });
        
        _observer.observe(document.body, { childList: true, subtree: true });
    }

    // Đăng ký Plugin vào hệ thống
    window.FormActionPlugins = window.FormActionPlugins || [];
    window.FormActionPlugins.push({ getExtraButtons: getExtraButtons });

    // Tự khởi động MutationObserver khi load (giống DocumentExportPlugin)
    init();

    return { getExtraButtons: getExtraButtons };
})();
