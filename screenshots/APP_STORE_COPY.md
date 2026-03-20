# App Store Copy — Shortless v2.1

## Subtitle (max 30 chars)
Short-Form Video Feed Blocker

## Keywords (max 100 chars)
shorts,reels,tiktok,screen time,digital wellbeing,doom scrolling,focus,short form video,detox

## Description

Stop doom-scrolling. Start living.

Short-form video feeds are engineered to keep you scrolling. YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight use algorithmic loops that exploit dopamine-driven reward cycles — averaging over 90 minutes of unplanned screen time per day.

Shortless gives you back the choice.

Unlike generic content blockers, Shortless targets only short-form video feeds. You keep full access to YouTube videos, Instagram photos, Snapchat messages, and everything else — we just remove the addictive infinite scroll.

CHOOSE WHAT TO BLOCK
Independent toggles for YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight. Block one, block all, or anything in between.

TIKTOK DNS FILTER
The only content blocker with system-wide TikTok blocking. Our on-device DNS filter blocks TikTok across all apps — not just Safari. No data ever leaves your device.

TRACK YOUR PROGRESS
See how much time you've reclaimed with our Time Reclaimed dashboard. View daily, weekly, and monthly blocking trends with interactive charts. Build a scroll-free streak and watch it grow.

SET YOUR GOALS
During onboarding, tell us how much time you spend on short-form video. We'll calculate the impact and help you set a personal reduction goal — from 25% to full detox.

HOME SCREEN WIDGETS
Glanceable progress right on your home screen and lock screen. See your streak, daily blocks, and time reclaimed at a glance.

THREE LAYERS OF PROTECTION
• Content Blocker — Blocks short-form URLs and hides UI elements before they load
• Web Extension — Catches dynamically loaded content in single-page apps
• DNS Filter — System-wide TikTok blocking via local VPN (no remote servers)

PRIVACY FIRST
Shortless collects zero personal data. No analytics, no tracking, no accounts. Everything runs on your device. Our DNS filter uses a local VPN tunnel — your traffic never touches our servers because we don't have any.

OPEN SOURCE
Every line of code is open source under the MIT license. Inspect it yourself at github.com/pmartin1915/shortless-ios.

CROSS-PLATFORM
Also available as a browser extension for Chrome and Firefox. Block short-form video everywhere you browse.

---

## App Review Notes

Dear App Review Team,

We are resubmitting Shortless after a 4.3(a) rejection of v1.0. This is a fundamentally re-architected app — not a minor update. Here is what makes Shortless unique:

1. UNIQUE SCOPE — Shortless is the only app that exclusively targets short-form video feeds across four platforms (YouTube Shorts, Instagram Reels, TikTok, Snapchat Spotlight) while preserving full access to the rest of each platform.

2. SYSTEM-WIDE DNS BLOCKING — We use NEPacketTunnelProvider to block TikTok at the DNS level across all apps, not just Safari. This is a local, on-device VPN that synthesizes NXDOMAIN responses for TikTok domains. No traffic is sent to any remote server. No other content blocker offers this.

3. DIGITAL WELLBEING DASHBOARD — The "Time Reclaimed" screen uses SwiftUI Charts to visualize blocking activity over 7-day and 30-day periods, with total blocks, daily averages, and active day counts. This transforms Shortless from a blocker into a wellness tool.

4. PERSONALIZED ONBOARDING — A 5-page onboarding flow asks users about their short-form video usage, calculates personalized impact ("That's X hours/week, Y days/year"), and lets them set a reduction goal (25%–100%). This creates user investment and positions the app as a behavioral change tool.

5. WIDGETKIT INTEGRATION — Small, medium, and Lock Screen widgets show streak days, daily blocks, and Time Reclaimed. Very few content blockers offer widgets.

6. CROSS-PLATFORM + OPEN SOURCE — Shortless is also available as a Chrome Web Store and Firefox Add-ons extension. The entire codebase is open source under MIT (github.com/pmartin1915/shortless-ios).

No demo account is needed. Simply enable the Safari extensions in Settings > Safari > Extensions.

We appreciate your review and are confident this version provides significant, unique value to users.

---

## Demo Video Script (1-2 min)

**[0:00-0:10] Opening**
Show Shortless icon and app launch. Text overlay: "Shortless — Block the Scroll. Keep the Content."

**[0:10-0:30] Onboarding Flow**
Walk through the 5-page onboarding:
- Welcome page with app branding
- "How much time do you spend?" survey (select "1-2 hours")
- Impact page shows "10.5 hours/week, 23 days/year"
- Goal page (select "Block it all")
- Safari setup instructions

**[0:30-0:50] Dashboard Tour**
Show the main dashboard:
- All 4 platform toggles enabled
- VPN card showing "Active" status
- Wellbeing section with Time Reclaimed card
- Tap into Stats View — show the charts and stats grid

**[0:50-1:10] VPN Activation**
- Toggle TikTok DNS Block ON
- Show the VPN explanation dialog
- Accept → show iOS VPN icon in status bar
- Open TikTok → show it fails to load (DNS blocked)
- Text overlay: "System-wide blocking — works in all apps, not just Safari"

**[1:10-1:25] Widgets**
- Show home screen with small and medium widgets
- Show lock screen with circular widget
- Text overlay: "Glanceable progress on your home and lock screen"

**[1:25-1:40] Safari Demo**
- Open YouTube in Safari → Shorts tab is hidden
- Open Instagram in Safari → Reels tab is hidden
- Text overlay: "Removes the feed, not the platform"

**[1:40-1:50] Privacy & Open Source**
- Show Settings > Privacy Policy
- Show GitHub link
- Text overlay: "Zero data collection. 100% open source."

**[1:50-2:00] Closing**
Text overlay: "Shortless — Take back your time."
Show App Store download badge.

NOTE: You'll need to record this on a physical iPhone or iPad running a TestFlight build. Screen record using the built-in iOS screen recorder (Settings > Control Center > Screen Recording).
