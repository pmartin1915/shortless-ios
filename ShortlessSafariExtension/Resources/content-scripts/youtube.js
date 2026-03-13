/*
 * Shortless - YouTube Content Script (Layer 3)
 * iOS Safari Web Extension variant.
 *
 * Depends on common.js being injected first (provides window.__shortless).
 * Handles:
 *   - Redirecting /shorts/{id} to /watch?v={id}
 *   - Hiding Shorts elements that survive CSS injection
 *   - Listening for YouTube SPA navigation events
 *   - Reporting block counts to the native app
 *
 * Differences from browser extension youtube.js:
 *   - No dispatchToggleState() / fetch guard communication (no MAIN world on iOS)
 *   - Uses visibilitychange listener instead of chrome.storage.onChanged for live toggle
 */
(function () {
  'use strict';

  var S = window.__shortless;
  if (!S) {
    console.warn('[Shortless] common.js not loaded – YouTube script aborting.');
    return;
  }

  // ---- Selectors (mirrors youtube-hide.css, plus dynamic overlay) -----------
  var SHORTS_SELECTORS = [
    'ytd-reel-shelf-renderer',
    'ytd-rich-shelf-renderer[is-shorts]',
    'ytd-guide-entry-renderer:has(a[href="/shorts"])',
    'ytd-mini-guide-entry-renderer:has(a[href="/shorts"])',
    'yt-tab-shape[tab-title="Shorts"]',
    'yt-tab-shape:has(a[href*="/shorts"])',
    '[overlay-style="SHORTS"]',
    'ytd-grid-video-renderer:has([overlay-style="SHORTS"])',
    'ytd-video-renderer:has([overlay-style="SHORTS"])'
  ];

  // ---- Helpers --------------------------------------------------------------

  function redirectShorts() {
    var path = window.location.pathname;
    if (path.startsWith('/shorts/')) {
      var videoId = path.split('/shorts/')[1];
      if (videoId) {
        videoId = videoId.split('/')[0].split('?')[0];
      }
      if (videoId) {
        window.location.replace('/watch?v=' + videoId);
        return true;
      }
    }
    return false;
  }

  function hideChipsByText() {
    var count = 0;
    var chips = document.querySelectorAll(
      'yt-chip-cloud-chip-renderer:not([data-shortless-hidden])'
    );
    for (var i = 0; i < chips.length; i++) {
      var chip = chips[i];
      var link = chip.querySelector('a[href*="/shorts"]');
      if (link) {
        chip.style.setProperty('display', 'none', 'important');
        chip.setAttribute('data-shortless-hidden', '');
        count++;
        continue;
      }
      var text = (chip.textContent || '').trim();
      if (text === 'Shorts') {
        chip.style.setProperty('display', 'none', 'important');
        chip.setAttribute('data-shortless-hidden', '');
        count++;
      }
    }
    return count;
  }

  function hideAndReport() {
    var count = S.hideElements(SHORTS_SELECTORS);
    count += hideChipsByText();
    S.sendBlockCount(count);
  }

  function onNavigate() {
    if (redirectShorts()) return;
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

  S.isPlatformEnabled('youtube').then(function (enabled) {
    if (!enabled) return;

    if (redirectShorts()) return;

    hideAndReport();

    // YouTube fires these custom events on SPA navigation
    document.addEventListener('yt-navigate-finish', onNavigate);
    document.addEventListener('yt-page-data-updated', onNavigate);

    // Observe DOM mutations for lazily-loaded Shorts content
    S.createObserver(hideAndReport);
  });

  // Re-check platform state when user returns to Safari (e.g. after toggling
  // in the Shortless app). Replaces chrome.storage.onChanged from browser ext.
  document.addEventListener('visibilitychange', function () {
    if (document.visibilityState === 'visible') {
      S.isPlatformEnabled('youtube').then(function (enabled) {
        if (enabled) {
          hideAndReport();
        } else {
          unhideAll();
        }
      });
    }
  });
})();
