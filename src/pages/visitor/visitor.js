/**
 * Module Giao diện Khách Tham Quan (Visitor Page)
 * HTML Template: src/pages/visitor.html
 */
var VisitorPage = (function () {
  
  function render($container) {
    fetch('./src/pages/visitor/visitor.html')
      .then(function(res) { return res.text(); })
      .then(function(html) {
        $container.innerHTML = html;
        _bindEvents();
      });
  }

  function _bindEvents() {
    var overlay = document.getElementById('visitor-form-overlay');
    var panel = document.getElementById('visitor-form-panel');
    var btnAdd = document.getElementById('btn-add-visitor');
    var btnClose = document.getElementById('btn-close-form');
    var btnCancel = document.getElementById('btn-cancel-form');
    var btnsEdit = document.querySelectorAll('.btn-edit-visitor');

    function openPanel() {
      overlay.classList.add('active');
      panel.style.right = '0';
    }

    function closePanel() {
      overlay.classList.remove('active');
      panel.style.right = '-800px';
    }

    if(btnAdd) btnAdd.addEventListener('click', openPanel);
    if(btnClose) btnClose.addEventListener('click', closePanel);
    if(btnCancel) btnCancel.addEventListener('click', closePanel);
    if(overlay) overlay.addEventListener('click', closePanel);

    btnsEdit.forEach(function(btn) {
      btn.addEventListener('click', openPanel);
    });

    // Auto sum tables
    var inpMan = document.getElementById('inp-ban-man');
    var inpChay = document.getElementById('inp-ban-chay');
    var inpTong = document.getElementById('inp-tong-ban');

    function calcTotal() {
      var m = Math.max(0, parseInt(inpMan.value) || 0);
      var c = Math.max(0, parseInt(inpChay.value) || 0);
      if (inpMan.value !== '' && parseInt(inpMan.value) < 0) inpMan.value = 0;
      if (inpChay.value !== '' && parseInt(inpChay.value) < 0) inpChay.value = 0;
      inpTong.value = m + c;
    }

    if(inpMan) inpMan.addEventListener('input', calcTotal);
    if(inpChay) inpChay.addEventListener('input', calcTotal);
  }

  return { render: render };
})();
