/**
 * Loading Bar Component
 * Thanh loading chạy dưới navbar khi chuyển trang (page transition)
 */
var LoadingBar = (function () {
  var container = null;
  var bar = null;
  var progress = 0;
  var intervalId = null;
  var isAnimating = false;

  function init() {
    if (document.getElementById('page-loading-bar-container')) return;

    container = document.createElement('div');
    container.id = 'page-loading-bar-container';
    container.className = 'page-loading-bar-container';

    bar = document.createElement('div');
    bar.className = 'page-loading-bar';

    container.appendChild(bar);
    document.body.appendChild(container);
  }

  function start() {
    if (!container) init();
    
    // Clear any existing animation intervals
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }

    progress = 0;
    isAnimating = true;

    // Reset styles for a fresh start
    bar.style.transition = 'none';
    bar.style.width = '0%';
    bar.style.opacity = '1';
    bar.classList.remove('error');

    // Force layout reflow so the browser registers the 0% start
    bar.offsetWidth;

    // Start with a small jump
    progress = 10 + Math.random() * 10; // 10% - 20%
    bar.style.transition = 'width 0.4s cubic-bezier(0.1, 0.8, 0.1, 1), opacity 0.3s ease';
    bar.style.width = progress + '%';

    // Simulate progress increments
    intervalId = setInterval(function () {
      if (progress < 90) {
        var increment = 0;
        if (progress < 50) {
          increment = Math.random() * 10 + 2; // 2% - 12%
        } else if (progress < 80) {
          increment = Math.random() * 4 + 1; // 1% - 5%
        } else {
          increment = Math.random() * 1.5 + 0.5; // 0.5% - 2%
        }
        progress = Math.min(92, progress + increment);
        bar.style.width = progress + '%';
      }
    }, 200);
  }

  function set(val) {
    if (!container) init();
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
    progress = Math.max(0, Math.min(100, val));
    bar.style.transition = 'width 0.3s ease, opacity 0.3s ease';
    bar.style.width = progress + '%';
    bar.style.opacity = '1';
  }

  function done() {
    if (!isAnimating) return;
    isAnimating = false;

    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }

    progress = 100;
    bar.style.transition = 'width 0.2s ease, opacity 0.3s ease';
    bar.style.width = '100%';

    // Wait for the width animation to complete, then fade out
    setTimeout(function () {
      bar.style.opacity = '0';
      // After fading out, reset width to 0
      setTimeout(function () {
        if (!isAnimating) {
          bar.style.transition = 'none';
          bar.style.width = '0%';
        }
      }, 300);
    }, 200);
  }

  function fail() {
    if (!isAnimating) return;
    isAnimating = false;

    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }

    // Set error class
    bar.classList.add('error');
    bar.style.transition = 'width 0.2s ease, opacity 0.3s ease';
    bar.style.width = '100%';

    setTimeout(function () {
      bar.style.opacity = '0';
      setTimeout(function () {
        if (!isAnimating) {
          bar.style.transition = 'none';
          bar.style.width = '0%';
          bar.classList.remove('error');
        }
      }, 300);
    }, 600); // Leave it red a bit longer
  }

  return {
    start: start,
    set: set,
    done: done,
    fail: fail
  };
})();
