/*
 * Shortless - Instagram Content Script (Layer 3)
 * iOS Safari Web Extension variant.
 *
 * Depends on common.js being injected first (provides window.__shortless).
 * Handles:
 *   - Redirecting /reels/ and /reel/ URLs to the Instagram home page
 *   - Hiding Reels elements that survive CSS injection
 *   - Detecting SPA navigations via URL polling (Safari-adapted)
 *   - Collapsing parent list items around Reels nav links to avoid empty gaps
 *   - Reporting block counts to the native app
 */
(function () {
  'use strict';

  var S = window.__shortless;
  if (!S) {
    console.warn('[Shortless] common.js not loaded – Instagram script aborting.');
    return;
  }

  // ---- Selectors (mirrors instagram-hide.css, plus menu-item variant) -------
  var REELS_SELECTORS = [
    'a[href="/reels/"]',
    'a[href^="/reels/"]',
    '[data-testid="reels-tab"]',
    'article:has(a[href*="/reel/"])',
    'div[role="menuitem"]:has(a[href^="/reels/"])'
  ];

  // ---- Helpers --------------------------------------------------------------

  function redirectReels() {
    var path = window.location.pathname;
    if (path.startsWith('/reels/') || path.startsWith('/reel/')) {
      window.location.replace('https://www.instagram.com/');
      return true;
    }
    return false;
  }

  /**
   * After hiding Reels nav links, walk up to the nearest parent <li> or
   * [role="listitem"] and hide it too, so no empty gap remains in the nav.
   */
  function collapseParentListItems() {
    var navLinks = document.querySelectorAll(
      'a[href="/reels/"][data-shortless-hidden], a[href^="/reels/"][data-shortless-hidden]'
    );

    for (var i = 0; i < navLinks.length; i++) {
      var parent = navLinks[i].closest('li, [role="listitem"]');
      if (parent && !parent.hasAttribute('data-shortless-hidden')) {
        parent.style.setProperty('display', 'none', 'important');
        parent.setAttribute('data-shortless-hidden', 'true');
      }
    }
  }

  function hideAndReport() {
    var count = S.hideElements(REELS_SELECTORS);
    collapseParentListItems();
    S.sendBlockCount(count);
  }

  function onNavigate() {
    if (redirectReels()) return;
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

  S.isPlatformEnabled('instagram').then(function (enabled) {
    if (!enabled) return;

    if (redirectReels()) return;

    hideAndReport();

    // Instagram is a SPA — detect navigations via URL polling + popstate
    S.interceptHistoryNav(function () {
      onNavigate();
    });

    // Observe DOM mutations for lazily-loaded Reels content
    S.createObserver(hideAndReport);
  });

  // Re-check platform state when user returns to Safari
  document.addEventListener('visibilitychange', function () {
    if (document.visibilityState === 'visible') {
      S.isPlatformEnabled('instagram').then(function (enabled) {
        if (enabled) {
          hideAndReport();
        } else {
          unhideAll();
        }
      });
    }
  });
})();
