/*
 * Shortless - Snapchat Content Script (Layer 3)
 * iOS Safari Web Extension variant.
 *
 * Depends on common.js being injected first (provides window.__shortless).
 * Handles:
 *   - Redirecting /spotlight URLs to the Snapchat home page
 *   - Hiding Spotlight elements that survive CSS injection
 *   - Detecting SPA navigations via URL polling (Safari-adapted)
 *   - Reporting block counts to the native app
 */
(function () {
  'use strict';

  var S = window.__shortless;
  if (!S) {
    console.warn('[Shortless] common.js not loaded – Snapchat script aborting.');
    return;
  }

  // ---- Selectors (mirrors snapchat-hide.css) --------------------------------
  var SPOTLIGHT_SELECTORS = [
    'a[href^="/spotlight"]',
    '[data-testid="spotlight-tab"]'
  ];

  // ---- Helpers --------------------------------------------------------------

  function redirectSpotlight() {
    var path = window.location.pathname;
    if (path.startsWith('/spotlight')) {
      window.location.replace('https://www.snapchat.com/');
      return true;
    }
    return false;
  }

  function hideAndReport() {
    var count = S.hideElements(SPOTLIGHT_SELECTORS);
    S.sendBlockCount(count);
  }

  function onNavigate() {
    if (redirectSpotlight()) return;
    hideAndReport();
  }

  /**
   * Restore visibility of elements previously hidden by Shortless.
   */
  function unhideAll() {
    var hidden = document.querySelectorAll('[data-shortless-hidden]');
    for (var i = 0; i < hidden.length; i++) {
      hidden[i].style.removeProperty('display');
      hidden[i].removeAttribute('data-shortless-hidden');
    }
  }

  // ---- Initialisation -------------------------------------------------------

  S.isPlatformEnabled('snapchat').then(function (enabled) {
    if (!enabled) return;

    if (redirectSpotlight()) return;

    hideAndReport();

    // Snapchat is a SPA — detect navigations via URL polling + popstate
    S.interceptHistoryNav(function () {
      onNavigate();
    });

    // Observe DOM mutations for lazily-loaded Spotlight content
    S.createObserver(hideAndReport);
  });

  // Re-check platform state when user returns to Safari
  document.addEventListener('visibilitychange', function () {
    if (document.visibilityState === 'visible') {
      S.isPlatformEnabled('snapchat').then(function (enabled) {
        if (enabled) {
          hideAndReport();
        } else {
          unhideAll();
        }
      });
    }
  });
})();
