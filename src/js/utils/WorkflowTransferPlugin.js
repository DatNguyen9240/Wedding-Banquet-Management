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

    function _getSelectedRow() {
        try {
            var raw = sessionStorage.getItem('selectedRows_frmKhachThamQuan');
            var rows = raw ? JSON.parse(raw) : [];
            return rows.length === 1 ? rows[0] : null;
        } catch (e) { return null; }
    }

    function _injectVisitorButton() {
        var container = document.querySelector('#dynamic-btn-container');
        if (!container) return;
        if (container.querySelector('#btn-transfer-booking')) {
            _updateBtnState(); // Đảm bảo update state liên tục nếu button đã có
            return;
        }

        var btn = document.createElement('button');
        btn.id = 'btn-transfer-booking';
        btn.className = 'btn btn-tool d-flex align-items-center gap-1';
        btn.title = 'Tạo Cọc';
        btn.innerHTML = '<span class="material-symbols-outlined" style="font-size:18px;">monetization_on</span><span>Tạo Cọc</span>';
        
        btn.onclick = function () {
            var row = _getSelectedRow();
            if (!row) {
                if (window.Alert) Alert.warning('Chưa chọn dữ liệu', 'Vui lòng chọn 1 Khách tham quan để Tạo Cọc.');
                return;
            }
            
            var transferData = {
                Tenkh: row.Tenkh || row.Tenchure || row.Tencodau || '',
                Dienthoai: row.Dienthoai || row.DTchure || row.DTcodau || '',
                Ngaytochuc: row.Ngaydukien || row.Ngaytochuc || ''
            };
            
            sessionStorage.setItem('transfer_VisitorToBooking', JSON.stringify(transferData));
            
            window.location.hash = '#/booking';
            
            setTimeout(function () {
                var btnAdd = document.querySelector('button[title*="Thêm bản ghi mới"], button[title="Thêm"], .btn-primary:not(.btn-tool)');
                if (btnAdd) btnAdd.click();
            }, 800);
        };
        
        // Chèn vào đầu (hoặc sau nút Thêm)
        var toolbar = container.querySelector('.action-toolbar, [class*="toolbar"], .button-bar');
        if (toolbar) {
            toolbar.insertBefore(btn, toolbar.firstChild);
        } else {
            container.appendChild(btn);
        }
        _updateBtnState();
    }

    function _updateBtnState() {
        var btn = document.querySelector('#btn-transfer-booking');
        if (!btn) return;
        var row = _getSelectedRow();
        if (row) {
            btn.disabled = false;
            btn.style.opacity = '1';
            btn.style.cursor = 'pointer';
            btn.style.color = '#fff';
            btn.style.backgroundColor = 'var(--color-primary)';
            btn.style.borderColor = 'var(--color-primary)';
            btn.classList.add('pulse-effect'); // Thêm class nháy cho đẹp (nếu có)
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

    function _handleAutoFill() {
        var transferStr = sessionStorage.getItem('transfer_VisitorToBooking');
        if (!transferStr) return;
        
        var modalContent = document.querySelector('.modal-content');
        if (!modalContent) return; // Phải có modal đang mở
        
        // Đảm bảo là modal THÊM MỚI (không fill nhầm lúc Sửa)
        var modalTitle = modalContent.querySelector('.modal-title');
        if (!modalTitle || modalTitle.innerText.indexOf('Thêm') === -1) return;

        try {
            var data = JSON.parse(transferStr);
            sessionStorage.removeItem('transfer_VisitorToBooking');
            
            setTimeout(function () {
                var inpTenKh = modalContent.querySelector('input[name="Tenkh"], input[name="Tenchure"], input[name="Tencodau"]');
                var inpSDT = modalContent.querySelector('input[name="Dienthoai"], input[name="DTchure"], input[name="DTcodau"]');
                var inpNgay = modalContent.querySelector('input[name="Ngaytochuc"], input[name="Ngaydukien"]');
                
                var filled = false;
                if (inpTenKh && data.Tenkh && !inpTenKh.value) { 
                    inpTenKh.value = data.Tenkh; 
                    inpTenKh.style.backgroundColor = '#f0fdf4'; 
                    inpTenKh.style.borderColor = '#10b981';
                    filled = true; 
                }
                if (inpSDT && data.Dienthoai && !inpSDT.value) { 
                    inpSDT.value = data.Dienthoai; 
                    inpSDT.style.backgroundColor = '#f0fdf4'; 
                    inpSDT.style.borderColor = '#10b981';
                    filled = true; 
                }
                if (inpNgay && data.Ngaytochuc && !inpNgay.value) { 
                    inpNgay.value = data.Ngaytochuc; 
                    inpNgay.style.backgroundColor = '#f0fdf4'; 
                    inpNgay.style.borderColor = '#10b981';
                    inpNgay.dispatchEvent(new Event('change', { bubbles: true })); 
                    filled = true; 
                }
                
                if (filled && window.UIToast) {
                    UIToast.show('Đã tự động điền thông tin từ Khách Tham Quan!', 'success');
                }
            }, 300);
            
        } catch (e) { console.error('WorkflowTransferPlugin error:', e); }
    }

    function init() {
        if (_observer) _observer.disconnect();
        
        document.addEventListener('rowSelectionToggled', function () {
            if (_getPath() === '/visitor') {
                setTimeout(_updateBtnState, 50);
            }
        });
        
        _observer = new MutationObserver(function () {
            var path = _getPath();
            if (path === '/visitor') {
                _injectVisitorButton();
            } else if (path === '/booking') {
                _handleAutoFill();
            }
        });
        
        _observer.observe(document.body, { childList: true, subtree: true });
    }

    return { init: init };
})();
