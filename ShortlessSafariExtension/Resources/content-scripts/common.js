/*
 * Shortless - Common Utilities (Layer 3: Content Script Shared Module)
 * iOS Safari Web Extension variant.
 *
 * Attaches shared helpers to window.__shortless so platform-specific
 * content scripts can use them without bundling.
 *
 * Differences from browser extension common.js:
 *   - sendBlockCount() uses browser.runtime.sendNativeMessage (Safari native messaging)
 *   - isPlatformEnabled() queries native handler via sendNativeMessage (no chrome.storage)
 *   - interceptHistoryNav() uses popstate + URL polling (Safari isolated world
 *     cannot monkey-patch page-originated history.pushState/replaceState calls)
 */
(function () {
  'use strict';

  if (window.__shortless) return; // already initialised

  /**
   * Create a MutationObserver on document.body that fires a debounced callback
   * whenever the DOM subtree changes.
   *
   * @param {Function} callback - Invoked after mutations settle.
   * @param {number}   debounceMs - Debounce window in milliseconds (default 150).
   * @returns {MutationObserver}
   */
  function createObserver(callback, debounceMs) {
    if (debounceMs === undefined) debounceMs = 150;

    var timer = null;
    var observer = new MutationObserver(function () {
      if (timer) clearTimeout(timer);
      timer = setTimeout(function () {
        timer = null;
        callback();
      }, debounceMs);
    });

    // Observe as soon as body exists; if not yet available, wait for it.
    function attach() {
      if (document.body) {
        observer.observe(document.body, { childList: true, subtree: true });
      } else {
        document.addEventListener('DOMContentLoaded', function () {
          observer.observe(document.body, { childList: true, subtree: true });
        });
      }
    }
    attach();

    return observer;
  }

  /**
   * Query the DOM for elements matching any of the given selectors, hide them,
   * and mark them so they are not processed again.
   *
   * @param {string[]} selectors   - CSS selectors to match.
   * @param {string}   markerAttr  - Data attribute used to mark hidden elements.
   * @returns {number} Number of newly hidden elements.
   */
  function hideElements(selectors, markerAttr) {
    if (!markerAttr) markerAttr = 'data-shortless-hidden';

    var combined = selectors.join(', ');
    if (!combined) return 0;

    var elements;
    try {
      elements = document.querySelectorAll(combined);
    } catch (e) {
      // Bail out silently if a selector is unsupported in this browser.
      return 0;
    }

    var count = 0;
    for (var i = 0; i < elements.length; i++) {
      var el = elements[i];
      if (!el.hasAttribute(markerAttr)) {
        el.style.setProperty('display', 'none', 'important');
        el.setAttribute(markerAttr, 'true');
        count++;
      }
    }
    return count;
  }

  /**
   * If the current URL path starts with pathPrefix, navigate away via
   * location.replace (no back-button entry).
   *
   * @param {string} pathPrefix  - e.g. "/shorts/"
   * @param {string} redirectUrl - Full or relative URL to redirect to.
   * @returns {boolean} True if a redirect was initiated.
   */
  function checkUrlAndRedirect(pathPrefix, redirectUrl) {
    if (window.location.pathname.startsWith(pathPrefix)) {
      window.location.replace(redirectUrl);
      return true;
    }
    return false;
  }

  /**
   * Send a block-count increment message to the native app via Safari's
   * native messaging bridge.
   *
   * @param {number} count - Number of elements blocked in this batch.
   */
  function sendBlockCount(count) {
    if (count <= 0) return;
    try {
      browser.runtime.sendNativeMessage(
        "dev.pmartin1915.shortless.SafariExtension",
        { type: 'BLOCK_COUNT_INCREMENT', count: count }
      );
    } catch (e) {
      // Extension context may have been invalidated.
    }
  }

  /**
   * Detect SPA navigations using popstate and URL polling.
   *
   * Safari Web Extension content scripts run in an isolated world, so
   * monkey-patching history.pushState/replaceState does NOT intercept
   * calls made by the page's own JavaScript. Instead we use:
   *   1. popstate listener (catches back/forward navigation)
   *   2. URL polling at 500ms (catches pushState/replaceState navigations)
   *
   * @param {Function} callback - Receives window.location.href on each nav.
   */
  function interceptHistoryNav(callback) {
    // Strategy 1: popstate (always works for back/forward)
    window.addEventListener('popstate', function () {
      callback(window.location.href);
    });

    // Strategy 2: URL polling (catches pushState/replaceState from page JS)
    var lastUrl = window.location.href;
    setInterval(function () {
      var currentUrl = window.location.href;
      if (currentUrl !== lastUrl) {
        lastUrl = currentUrl;
        callback(currentUrl);
      }
    }, 500);
  }

  /**
   * Check whether a given platform is enabled in user settings.
   * Queries the native app handler via Safari's native messaging bridge.
   *
   * @param {string} platform - e.g. "youtube", "instagram", "snapchat"
   * @returns {Promise<boolean>} Resolves to true if enabled (default true).
   */
  function isPlatformEnabled(platform) {
    return new Promise(function (resolve) {
      try {
        browser.runtime.sendNativeMessage(
          "dev.pmartin1915.shortless.SafariExtension",
          { type: 'GET_PLATFORM_STATE', platform: platform }
        ).then(function (response) {
          resolve(response && response.enabled !== false);
        }).catch(function () {
          resolve(true);
        });
      } catch (e) {
        // Native messaging unavailable – assume enabled.
        resolve(true);
      }
    });
  }

  // Expose public API
  window.__shortless = {
    createObserver: createObserver,
    hideElements: hideElements,
    checkUrlAndRedirect: checkUrlAndRedirect,
    sendBlockCount: sendBlockCount,
    interceptHistoryNav: interceptHistoryNav,
    isPlatformEnabled: isPlatformEnabled
  };
})();
