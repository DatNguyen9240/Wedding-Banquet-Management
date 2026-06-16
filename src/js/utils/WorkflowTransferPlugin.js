/**
 * WorkflowTransferPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin dùng để chuyển dữ liệu từ các màn hình này sang màn hình khác.
 * Ví dụ: Khách tham quan -> Biên nhận cọc (Auto-fill)
 */
var WorkflowTransferPlugin = (function () {

    function _autoClickAdd() {
        setTimeout(function () {
            var buttons = Array.from(document.querySelectorAll('button'));
            var btnAdd = buttons.find(function (b) {
                var text = (b.innerText || '').trim();
                var tooltip = b.getAttribute('data-tooltip') || b.title || '';
                return text === 'Thêm' || tooltip.includes('Thêm');
            });
            if (btnAdd) {
                btnAdd.click();
            } else {
                var fallbackBtn = document.querySelector('button[title*="Thêm bản ghi mới"], button[title="Thêm"], .btn-primary:not(.btn-tool)');
                if (fallbackBtn) fallbackBtn.click();
            }
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
            getTransferData: function (row) {
                var data = Object.assign({}, row);
                delete data.Id; delete data.AutoID; delete data.Sohopdong; delete data.SoHopDong;
                return data;
            }
        },
        'frmBiennhancoccho': {
            id: 'btn-transfer-contract',
            text: 'Tạo HĐ',
            icon: 'assignment',
            targetHash: '#/contract',
            storageKey: 'transfer_BookingToContract',
            getTransferData: function (row) {
                var data = Object.assign({}, row);
                data.Sobiennhan = row.DocumentID || row.SoBN || row.Id;
                delete data.Id; delete data.AutoID; delete data.Sohopdong; delete data.SoHopDong;
                return data;
            }
        },
        /*
        'frmHopDong': {
            id: 'btn-transfer-checkout',
            text: 'Quyết Toán',
            icon: 'receipt_long',
            targetHash: '#/checkout',
            storageKey: 'transfer_ContractToCheckout',
            getTransferData: function (row) {
                var data = Object.assign({}, row);
                delete data.Id; delete data.AutoID;
                return data;
            }
        }
        */
    };

    function getExtraButtons(formName, getSelectedRows) {
        var config = FORM_CONFIG[formName];
        if (!config) return [];

        return [{
            id: config.id,
            text: config.text,
            icon: config.icon,
            type: 'tool',
            onClick: function () {
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
        var modalTitle = modalContent.querySelector('.modal-header h3, .modal-title, h3');
        if (!modalTitle || modalTitle.innerText.indexOf('Thêm') === -1) return;

        var dataV2B = sessionStorage.getItem('transfer_VisitorToBooking');
        if (dataV2B) {
            _fillData(JSON.parse(dataV2B), 'Khách Tham Quan');
            sessionStorage.removeItem('transfer_VisitorToBooking');
            return;
        }

        var dataB2C = sessionStorage.getItem('transfer_BookingToContract');
        if (dataB2C) {
            _fillData(JSON.parse(dataB2C), 'Biên Nhận Đặt Cọc');
            sessionStorage.removeItem('transfer_BookingToContract');
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

            // Tìm tất cả phần tử nhập liệu trong form
            var formElements = Array.from(modalContent.querySelectorAll('input, select, textarea'));
            if (formElements.length === 0) return;

            // Chuyển toàn bộ các keys của data sang chữ thường để so khớp không phân biệt hoa thường
            var lowerData = {};
            Object.keys(data).forEach(function (k) {
                lowerData[k.toLowerCase()] = data[k];
            });

            formElements.forEach(function (el) {
                var elName = el.name || el.getAttribute('name');
                if (!elName) return;

                var lowerName = elName.toLowerCase();
                if (lowerData[lowerName] !== undefined && lowerData[lowerName] !== null && String(lowerData[lowerName]).trim() !== '') {
                    var val = lowerData[lowerName];

                    // Nếu phần tử là input date, định dạng lại thành YYYY-MM-DD
                    if (el.type === 'date' && val) {
                        var rawVal = String(val).trim();
                        if (rawVal.indexOf('T') !== -1) {
                            val = rawVal.split('T')[0];
                        } else if (rawVal.indexOf('/') !== -1) {
                            var parts = rawVal.split(' ')[0].split('/');
                            if (parts.length === 3) {
                                if (parts[0].length === 4) { // YYYY/MM/DD
                                    val = parts[0] + '-' + parts[1] + '-' + parts[2];
                                } else { // DD/MM/YYYY
                                    val = parts[2] + '-' + parts[1] + '-' + parts[0];
                                }
                            }
                        } else if (rawVal.indexOf('-') !== -1) {
                            var parts = rawVal.split(' ')[0].split('-');
                            if (parts.length === 3) {
                                if (parts[0].length === 4) { // YYYY-MM-DD
                                    val = parts[0] + '-' + parts[1] + '-' + parts[2];
                                } else { // DD-MM-YYYY
                                    val = parts[2] + '-' + parts[1] + '-' + parts[0];
                                }
                            }
                        }
                    }

                    // Điền giá trị
                    el.value = val;
                    el.style.setProperty('background-color', 'rgba(16, 185, 129, 0.1)', 'important');
                    el.style.setProperty('border-color', '#10b981', 'important');

                    // Nếu là input custom (hidden input đồng bộ với các control hiển thị khác như Datepicker, ComboBox)
                    if (el.type === 'hidden') {
                        var formGroup = el.closest('.form-group');
                        if (formGroup) {
                            var visibleInputs = formGroup.querySelectorAll('input:not([type="hidden"]), select, textarea');
                            visibleInputs.forEach(function (visibleEl) {
                                visibleEl.style.setProperty('background-color', 'rgba(16, 185, 129, 0.1)', 'important');
                                visibleEl.style.setProperty('border-color', '#10b981', 'important');
                            });
                        }
                    }

                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    if (typeof el.fetchDataForValue === 'function') {
                        el.fetchDataForValue();
                    }
                    filled = true;
                }
            });

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
