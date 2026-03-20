# App Store Copy — Shortless v2.1

## Subtitle (max 30 chars)
Short-Form Video Feed Blocker

## Keywords (max 100 chars)
shorts,reels,tiktok,screen time,digital wellbeing,doom scrolling,focus,short form video,detox

## Description

Stop doom-scrolling. Start living.

Short-form video feeds are designed to keep you watching. Without realizing it, YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight can consume hours of time you could spend on things that matter to you.

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

Shortless is a digital wellbeing tool — not a generic content blocker. We built it because we were personally struggling with short-form video consumption and couldn't find an app that addressed the problem holistically. Here is what makes Shortless unique:

1. WELLBEING-FIRST DESIGN — Shortless is not about blocking content; it's about helping users reclaim their time. The app opens with a personalized onboarding flow that asks how much time users spend on short-form video, calculates the real-world impact (hours/week, days/year), and helps them set a personal reduction goal. The "Time Reclaimed" dashboard (SwiftUI Charts) visualizes progress over 7 and 30 days, and a scroll-free streak counter reinforces positive behavior.

2. SYSTEM-WIDE DNS BLOCKING (NEPacketTunnelProvider) — Shortless is the only short-form video blocker that uses an on-device DNS filter to block TikTok system-wide — across all apps, not just Safari. The local VPN synthesizes NXDOMAIN responses for TikTok domains. No traffic is sent to any remote server. We are not aware of any other content blocker that offers this capability.

3. SURGICAL SCOPE — Unlike general-purpose content blockers, Shortless exclusively targets short-form video feeds on four platforms (YouTube Shorts, Instagram Reels, TikTok, Snapchat Spotlight). Users keep full access to YouTube videos, Instagram photos, Snapchat messages, and everything else. We remove the addictive feed, not the platform.

4. THREE-LAYER ARCHITECTURE — Safari Content Blocker (declarative rules), Safari Web Extension (MutationObserver for SPA navigation), and NEPacketTunnelProvider DNS filter. Each layer addresses a different technical challenge. This is a deeply considered architecture, not a template.

5. WIDGETKIT + HOME SCREEN INTEGRATION — Small, medium, and Lock Screen widgets show streak days, daily blocks, and Time Reclaimed. The app includes step-by-step widget setup guidance and an "Open Settings" button to help users enable Safari extensions.

6. OPEN SOURCE + CROSS-PLATFORM — Every line of code is MIT-licensed at github.com/pmartin1915/shortless-ios. Also available as Chrome and Firefox extensions at github.com/pmartin1915/shortless. We built this to help people, not to monetize data.

HOW TO TEST:
- Open Settings > Safari > Extensions > Enable both Shortless extensions
- Return to Shortless and toggle platforms on/off
- Open YouTube in Safari to verify Shorts tab is hidden
- Toggle the TikTok DNS Filter and try opening TikTok in any app
- No demo account needed

Thank you for reviewing Shortless. We built this for ourselves first, and we believe it provides genuine, unique value.

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
