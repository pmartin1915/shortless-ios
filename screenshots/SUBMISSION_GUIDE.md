# App Store Submission Guide — Shortless v2.1.0 Build 10

## Prerequisites

- Build 10 is uploaded to App Store Connect
- Build 10 is on TestFlight
- Screenshots updated with teal palette (mockups.html)

---

## Step 1: Generate Screenshots

1. Open `mockups.html` in Chrome
2. Right-click each phone frame > "Save image as..." (or use Ctrl+Shift+I > device toolbar for exact sizing)
3. Each screenshot needs to be **1290 x 2796 px** (6.7" iPhone display)
4. Save as `01-dashboard.png` through `06-settings.png`

**Alternative:** Take real screenshots from TestFlight on your iPhone, then frame them.

---

## Step 2: App Store Connect

Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) > My Apps > Shortless

### 2a. Delete v2.0.0 Draft

1. If you see a v2.0.0 version in "Prepare for Submission" state, click it
2. Scroll down and click "Remove version" (or delete it from the version list)
3. This won't affect your uploaded builds

### 2b. Create Version 2.1.0

1. Click the "+" button next to "iOS App" in the left sidebar
2. Enter version number: `2.1.0`
3. Click "Create"

### 2c. Select Build

1. In the Build section, click "Select a build"
2. Choose **Build 10** (version 2.1.0)

### 2d. Upload Screenshots

1. Under "App Screenshots", select **iPhone 6.7" Display**
2. Upload all 6 screenshots in order:
   - 01 — Dashboard (main screen with toggles)
   - 02 — Stats View (Time Reclaimed charts)
   - 03 — Onboarding Welcome
   - 04 — Onboarding Impact
   - 05 — Widget Preview
   - 06 — Settings

---

## Step 3: Paste Metadata

### What's New (paste this)

```
Initial release. Block YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight while keeping full access to each platform. Includes system-wide TikTok DNS blocking, Time Reclaimed dashboard, scroll-free streak tracking, and Home Screen widgets.
```

### Subtitle (29/30 chars)

```
Short-Form Video Feed Blocker
```

### Keywords (93/100 chars)

```
shorts,reels,tiktok,screen time,digital wellbeing,doom scrolling,focus,short form video,detox
```

### Description

```
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
```

### URLs

| Field | Value |
| --- | --- |
| Support URL | `https://github.com/pmartin1915/shortless-ios/issues` |
| Marketing URL | `https://github.com/pmartin1915/shortless-ios` |
| Privacy Policy URL | `https://github.com/pmartin1915/shortless-ios/blob/master/PRIVACY_POLICY.md` |

### Other Fields

| Field | Value |
| --- | --- |
| Primary Category | Productivity |
| Secondary Category | Utilities |
| Age Rating | 4+ |
| Copyright | 2026 Perry Martin |

---

## Step 4: App Review Notes (paste this entire block)

```
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
```

---

## Step 5: App Privacy

1. Go to the App Privacy section
2. Confirm: **Data Not Collected**
3. If prompted to update, re-confirm no data types are collected

---

## Step 6: Submit

1. Click **"Add for Review"**
2. Answer compliance questions:
   - **Export compliance (encryption):** No — select "None of the algorithms mentioned above"
   - **Third-party content:** No
   - **Advertising Identifier (IDFA):** No
3. Click **"Submit to App Review"**

---

## After Submission

- Status should change to "Waiting for Review"
- Typical review time: 24-48 hours
- If rejected under 4.3(a) again: respond in Resolution Center citing the 6 differentiators above
- Monitor at appstoreconnect.apple.com or via the App Store Connect app on your phone
