/* ═══════════════════════════════════════════
   SCREEN CAPTURE COMPONENT (Canvas-based)
   ═══════════════════════════════════════════ */
var ScreenCapture = (function () {

  var overlayCanvas = null;
  var ctx = null;
  var startX = 0, startY = 0;
  var isDrawing = false;
  var currentRect = null;
  var currentCallback = null;
  var ww = 0, wh = 0;

  function initOverlay() {
    if (overlayCanvas) return;
    
    ww = window.innerWidth;
    wh = window.innerHeight;

    overlayCanvas = document.createElement('canvas');
    overlayCanvas.className = 'screen-capture-canvas';
    overlayCanvas.width = ww;
    overlayCanvas.height = wh;
    
    ctx = overlayCanvas.getContext('2d');
    
    document.body.appendChild(overlayCanvas);
    
    drawMask(0, 0, 0, 0); // Vẽ màn đen khởi tạo
    
    overlayCanvas.addEventListener('mousedown', onMouseDown);
    overlayCanvas.addEventListener('mousemove', onMouseMove);
    overlayCanvas.addEventListener('mouseup', onMouseUp);
    document.addEventListener('keydown', onKeyDown);
  }

  function destroyOverlay() {
    if (overlayCanvas) {
      overlayCanvas.removeEventListener('mousedown', onMouseDown);
      overlayCanvas.removeEventListener('mousemove', onMouseMove);
      overlayCanvas.removeEventListener('mouseup', onMouseUp);
      if (overlayCanvas.parentNode) {
        document.body.removeChild(overlayCanvas);
      }
      overlayCanvas = null;
      ctx = null;
    }
    document.removeEventListener('keydown', onKeyDown);
  }

  function onKeyDown(e) {
    if (e.key === 'Escape') {
      destroyOverlay();
    }
  }

  function drawMask(x, y, w, h) {
    if (!ctx) return;
    ctx.clearRect(0, 0, ww, wh);
    ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
    ctx.fillRect(0, 0, ww, wh);

    if (w > 0 && h > 0) {
      ctx.clearRect(x, y, w, h);
      ctx.strokeStyle = '#4F46E5';
      ctx.lineWidth = 2;
      ctx.setLineDash([5, 5]);
      ctx.strokeRect(x, y, w, h);
    }
    
    // Vẽ helper text
    if (!isDrawing && w === 0) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
      var txtWidth = 300;
      ctx.fillRect(ww/2 - txtWidth/2, 20, txtWidth, 60);
      ctx.fillStyle = '#ffffff';
      ctx.font = '14px Arial';
      ctx.textAlign = 'center';
      ctx.fillText('Nhấn và kéo chuột để chọn vùng', ww/2, 45);
      ctx.font = '12px Arial';
      ctx.fillText('Nhấn ESC để thoát', ww/2, 65);
    }
  }

  function onMouseDown(e) {
    isDrawing = true;
    startX = e.clientX;
    startY = e.clientY;
    drawMask(startX, startY, 0, 0);
  }

  var rafId = null;
  function onMouseMove(e) {
    if (!isDrawing) return;
    var currentX = e.clientX;
    var currentY = e.clientY;

    if (rafId) cancelAnimationFrame(rafId);
    rafId = requestAnimationFrame(function() {
      var left = Math.min(startX, currentX);
      var top = Math.min(startY, currentY);
      var width = Math.abs(currentX - startX);
      var height = Math.abs(currentY - startY);
      drawMask(left, top, width, height);
    });
  }

  function onMouseUp(e) {
    if (!isDrawing) return;
    isDrawing = false;

    var endX = e.clientX;
    var endY = e.clientY;

    var left = Math.min(startX, endX);
    var top = Math.min(startY, endY);
    var width = Math.abs(endX - startX);
    var height = Math.abs(endY - startY);

    if (width > 20 && height > 20) {
      currentRect = { left: left, top: top, width: width, height: height };
      captureAndAction();
    } else {
      // Nếu kéo vùng quá nhỏ hoặc chỉ click nhấp nhả thì tự động hủy luôn để tránh bị "dính"
      destroyOverlay(); 
    }
  }

  function captureAndAction() {
    if (typeof html2canvas === 'undefined') {
      if (typeof UIToast !== 'undefined') UIToast.show('Thư viện html2canvas chưa được load (Kiểm tra mạng)!', 'error');
      destroyOverlay();
      return;
    }

    // Xóa ngay overlay để chụp cho chuẩn
    destroyOverlay();
    
    if (typeof UIToast !== 'undefined') UIToast.show('Đang xử lý ảnh...', 'info');

    // Chống treo (Dính): Nếu html2canvas chạy quá 5s mà không xong, tự động giải phóng
    var isDone = false;
    var timeoutId = setTimeout(function() {
      if (!isDone) {
        console.error('html2canvas bị treo (timeout)');
        if (typeof UIToast !== 'undefined') UIToast.show('Xử lý ảnh quá lâu, đã tự động hủy!', 'error');
        isDone = true;
      }
    }, 5000);

    try {
      html2canvas(document.body, {
        x: currentRect.left + window.scrollX,
        y: currentRect.top + window.scrollY,
        width: currentRect.width,
        height: currentRect.height,
        useCORS: true,
        scale: 1, // Tốc độ nhanh nhất
        logging: false,
        backgroundColor: null
      }).then(function(canvas) {
        if (isDone) return; // Nếu đã bị timeout thì bỏ qua
        isDone = true;
        clearTimeout(timeoutId);

        if (currentCallback) {
          currentCallback(canvas);
          return;
        }

        function fallbackDownload() {
          try {
            var imgData = canvas.toDataURL('image/png');
            var a = document.createElement('a');
            a.href = imgData;
            a.download = 'screenshot_' + new Date().getTime() + '.png';
            a.click();
            if (typeof UIToast !== 'undefined') UIToast.show('Đã tự động tải ảnh về máy!', 'success');
          } catch (e) {
            console.error('Lỗi khi xuất ảnh (Tainted Canvas):', e);
            if (typeof UIToast !== 'undefined') UIToast.show('Lỗi bảo mật trình duyệt, không thể xuất ảnh!', 'error');
          }
        }

        try {
          canvas.toBlob(function(blob) {
            try {
              if (!blob) {
                fallbackDownload();
                return;
              }
              if (navigator.clipboard && window.ClipboardItem) {
                navigator.clipboard.write([new ClipboardItem({ 'image/png': blob })]).then(function() {
                  if (typeof UIToast !== 'undefined') UIToast.show('Đã copy ảnh vào bộ nhớ tạm!', 'success');
                }).catch(function(err) {
                  console.warn('Lỗi copy clipboard:', err);
                  fallbackDownload();
                });
              } else {
                fallbackDownload();
              }
            } catch(errInner) {
              fallbackDownload();
            }
          });
        } catch (errOuter) {
          fallbackDownload();
        }

      }).catch(function(err) {
        if (isDone) return;
        isDone = true;
        clearTimeout(timeoutId);
        console.error('Lỗi chụp màn hình (Async):', err);
        if (typeof UIToast !== 'undefined') UIToast.show('Lỗi hệ thống khi chụp!', 'error');
      });
    } catch(err) {
      if (isDone) return;
      isDone = true;
      clearTimeout(timeoutId);
      console.error('Lỗi chụp màn hình (Sync):', err);
      if (typeof UIToast !== 'undefined') UIToast.show('Lỗi hệ thống khi chụp!', 'error');
    }
  }

  function start(onCaptureCallback) {
    currentCallback = onCaptureCallback || null;
    initOverlay();
  }

  return {
    start: start
  };
})();
