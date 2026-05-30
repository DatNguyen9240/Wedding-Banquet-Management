/**
 * WorkflowTransferPlugin
 * ─────────────────────────────────────────────────────────────────────
 * Plugin dùng để chuyển dữ liệu từ các màn hình này sang màn hình khác.
 * Ví dụ: Khách tham quan -> Biên nhận cọc (Auto-fill)
 */
var WorkflowTransferPlugin = (function () {

    var _observer = null;

    function _getPath() {
        return window.location.hash.replace('#', '').split('?')[0] || '/dashboard';
    }

    function _getSelectedRow(formName) {
        try {
            var raw = sessionStorage.getItem('selectedRows_' + formName);
            var rows = raw ? JSON.parse(raw) : [];
            return rows.length === 1 ? rows[0] : null;
        } catch (e) { return null; }
    }

    // --- LUỒNG 1: KHÁCH THAM QUAN -> TẠO CỌC ---
    function _injectVisitorButton() {
        var container = document.querySelector('#dynamic-btn-container');
        if (!container) return;
        if (container.querySelector('#btn-transfer-booking')) {
            _updateBtnState('btn-transfer-booking', 'frmKhachThamQuan'); 
            return;
        }

        var btn = document.createElement('button');
        btn.id = 'btn-transfer-booking';
        btn.className = 'btn btn-tool d-flex align-items-center gap-1';
        btn.title = 'Tạo Cọc';
        btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">monetization_on</span><span>Tạo Cọc</span>';
        
        btn.onclick = function () {
            var row = _getSelectedRow('frmKhachThamQuan');
            if (!row) return window.Alert && Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Khách tham quan để Tạo Cọc.');
            
            var transferData = {
                Tenkh: row.Tenkh || row.Tenchure || row.Tencodau || '',
                Dienthoai: row.Dienthoai || row.DTchure || row.DTcodau || '',
                Ngaytochuc: row.Ngaydukien || row.Ngaytochuc || ''
            };
            sessionStorage.setItem('transfer_VisitorToBooking', JSON.stringify(transferData));
            window.location.hash = '#/booking';
            _autoClickAdd();
        };
        
        var toolbar = container.querySelector('.action-toolbar, [class*="toolbar"], .button-bar');
        if (toolbar) toolbar.insertBefore(btn, toolbar.firstChild);
        else container.appendChild(btn);
        
        _updateBtnState('btn-transfer-booking', 'frmKhachThamQuan');
    }

    // --- LUỒNG 2: BIÊN NHẬN CỌC -> HỢP ĐỒNG ---
    function _injectBookingButton() {
        var container = document.querySelector('#dynamic-btn-container');
        if (!container) return;
        if (container.querySelector('#btn-transfer-contract')) {
            _updateBtnState('btn-transfer-contract', 'frmDatCoc');
            return;
        }

        var btn = document.createElement('button');
        btn.id = 'btn-transfer-contract';
        btn.className = 'btn btn-tool d-flex align-items-center gap-1';
        btn.title = 'Tạo Hợp Đồng';
        btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">description</span><span>Lên Hợp Đồng</span>';
        
        btn.onclick = function () {
            var row = _getSelectedRow('frmDatCoc');
            if (!row) return window.Alert && Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Biên nhận cọc để Lên Hợp Đồng.');
            
            var transferData = {
                Tenkh: row.Tenkh || row.Tenchure || row.Tencodau || '',
                Ngaytochuc: row.Ngaytochuc || row.Ngaydukien || '',
                SanhTiec: row.Tensanh || row.SanhTiec || '',
                TongTienCoc: row.TienCoc || row.Sotien || ''
            };
            sessionStorage.setItem('transfer_BookingToContract', JSON.stringify(transferData));
            window.location.hash = '#/contract';
            _autoClickAdd();
        };
        
        var toolbar = container.querySelector('.action-toolbar, [class*="toolbar"], .button-bar');
        if (toolbar) toolbar.insertBefore(btn, toolbar.firstChild);
        else container.appendChild(btn);
        
        _updateBtnState('btn-transfer-contract', 'frmDatCoc');
    }

    // --- LUỒNG 3: HỢP ĐỒNG -> QUYẾT TOÁN ---
    function _injectContractButton() {
        var container = document.querySelector('#dynamic-btn-container');
        if (!container) return;
        if (container.querySelector('#btn-transfer-checkout')) {
            _updateBtnState('btn-transfer-checkout', 'frmHopDong');
            return;
        }

        var btn = document.createElement('button');
        btn.id = 'btn-transfer-checkout';
        btn.className = 'btn btn-tool d-flex align-items-center gap-1';
        btn.title = 'Làm Quyết Toán';
        btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">receipt_long</span><span>Quyết Toán</span>';
        
        btn.onclick = function () {
            var row = _getSelectedRow('frmHopDong');
            if (!row) return window.Alert && Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Hợp đồng để Quyết toán.');
            
            var transferData = {
                Sohopdong: row.Sohopdong || row.AutoID || '',
                Tenkh: row.Tenkh || row.Tenchure || row.Tencodau || '',
                Ngaytochuc: row.Ngaytochuc || ''
            };
            sessionStorage.setItem('transfer_ContractToCheckout', JSON.stringify(transferData));
            window.location.hash = '#/checkout';
            _autoClickAdd();
        };
        
        var toolbar = container.querySelector('.action-toolbar, [class*="toolbar"], .button-bar');
        if (toolbar) toolbar.insertBefore(btn, toolbar.firstChild);
        else container.appendChild(btn);
        
        _updateBtnState('btn-transfer-checkout', 'frmHopDong');
    }

    function _autoClickAdd() {
        setTimeout(function () {
            var btnAdd = document.querySelector('button[title*="Thêm bản ghi mới"], button[title="Thêm"], .btn-primary:not(.btn-tool)');
            if (btnAdd) btnAdd.click();
        }, 800);
    }

    function _updateBtnState(btnId, formName) {
        var btn = document.querySelector('#' + btnId);
        if (!btn) return;
        var row = _getSelectedRow(formName);
        if (row) {
            btn.disabled = false;
            btn.style.opacity = '1';
            btn.style.cursor = 'pointer';
            btn.style.color = '#fff';
            btn.style.backgroundColor = 'var(--color-primary)';
            btn.style.borderColor = 'var(--color-primary)';
            btn.classList.add('pulse-effect');
        } else {
            btn.disabled = true;
            btn.style.opacity = '0.5';
            btn.style.cursor = 'not-allowed';
            btn.style.color = '';
            btn.style.backgroundColor = '';
            btn.style.borderColor = '';
            btn.classList.remove('pulse-effect');
        }
    }

    // --- XỬ LÝ AUTO-FILL KHI MỞ FORM THÊM MỚI ---
    function _handleAutoFill() {
        var modalContent = document.querySelector('.modal-content');
        if (!modalContent) return;
        var modalTitle = modalContent.querySelector('.modal-title');
        if (!modalTitle || modalTitle.innerText.indexOf('Thêm') === -1) return;

        // 1. Fill từ Khách Tham Quan -> Biên nhận Cọc
        var dataV2B = sessionStorage.getItem('transfer_VisitorToBooking');
        if (dataV2B) {
            _fillData(JSON.parse(dataV2B), 'Khách Tham Quan');
            sessionStorage.removeItem('transfer_VisitorToBooking');
            return;
        }

        // 2. Fill từ Biên nhận Cọc -> Hợp Đồng
        var dataB2C = sessionStorage.getItem('transfer_BookingToContract');
        if (dataB2C) {
            _fillData(JSON.parse(dataB2C), 'Biên Nhận Cọc');
            sessionStorage.removeItem('transfer_BookingToContract');
            return;
        }

        // 3. Fill từ Hợp Đồng -> Quyết Toán
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

            // Hàm helper để gán value và style
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
            tryFill('input[name="Ngaytochuc"], input[name="Ngaydukien"]', data.Ngaytochuc);
            tryFill('input[name="SanhTiec"], select[name="Tensanh"]', data.SanhTiec);
            tryFill('input[name="Sohopdong"]', data.Sohopdong);
            // Có thể thêm field khác (TongTienCoc...) tùy cấu hình DB
            
            if (filled && window.UIToast) {
                UIToast.show('Đã tự động điền thông tin từ ' + sourceName + '!', 'success');
            }
        }, 300);
    }

    function init() {
        if (_observer) _observer.disconnect();
        
        document.addEventListener('rowSelectionToggled', function () {
            var path = _getPath();
            if (path === '/visitor') setTimeout(function(){ _updateBtnState('btn-transfer-booking', 'frmKhachThamQuan'); }, 50);
            else if (path === '/booking') setTimeout(function(){ _updateBtnState('btn-transfer-contract', 'frmDatCoc'); }, 50);
            else if (path === '/contract') setTimeout(function(){ _updateBtnState('btn-transfer-checkout', 'frmHopDong'); }, 50);
        });
        
        _observer = new MutationObserver(function () {
            var path = _getPath();
            if (path === '/visitor') {
                _injectVisitorButton();
            } else if (path === '/booking') {
                _injectBookingButton();
                _handleAutoFill();
            } else if (path === '/contract') {
                _injectContractButton();
                _handleAutoFill();
            } else if (path === '/checkout') {
                _handleAutoFill();
            }
        });
        
        _observer.observe(document.body, { childList: true, subtree: true });
    }

    return { init: init };
})();
