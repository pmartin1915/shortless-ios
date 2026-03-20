# Privacy Policy — Shortless for iOS

**Last updated:** March 20, 2026

## Overview

Shortless is a digital wellbeing app for iOS that helps you block short-form video feeds (YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight). It uses a Safari Content Blocker, Safari Web Extension, an optional DNS filter via local VPN, and Home Screen widgets. Shortless is designed with privacy as a core principle: the app collects no personal data whatsoever.

## Data Collection

Shortless does **not** collect, store, or transmit any personal data. Specifically:

- No analytics or telemetry
- No tracking of any kind
- No cookies
- No user accounts or sign-up
- No browsing history is accessed or recorded
- No data is sent to any server operated by Shortless
- The optional DNS filter forwards non-blocked DNS queries to public resolvers (Cloudflare 1.1.1.1 or Google 8.8.8.8) but does not log, store, or inspect them

## How Blocking Works

All content blocking happens entirely on your device. The app uses three mechanisms, all of which operate locally:

1. **Safari Content Blocker** — Apple's native content blocking API uses declarative rules to block or hide short-form content before it renders. These rules are generated on-device from your preferences.
2. **Safari Web Extension** — Content scripts monitor web pages for dynamically loaded short-form content (common in single-page apps like YouTube and Instagram) and hide it in real time.
3. **DNS Filter (optional)** — Uses Apple's `NEPacketTunnelProvider` API to create a local, on-device VPN that filters DNS queries. When enabled, DNS queries for TikTok-related domains are answered locally with "domain not found" (NXDOMAIN). Queries for all other domains are forwarded unchanged to public DNS resolvers (Cloudflare 1.1.1.1 or Google 8.8.8.8). **No network traffic is inspected, logged, stored, or transmitted to any server operated by Shortless.** The VPN tunnel operates entirely on your device and does not route your traffic through any external server.

None of these mechanisms send personal data off your device.

## Data Stored Locally

Shortless stores a small amount of data on your device using App Groups (shared between the app and its extensions):

- **Platform preferences** — Which platforms you have enabled or disabled (on/off toggles)
- **Block counter** — A daily count of blocked content items, stored by date for the Time Reclaimed dashboard
- **VPN toggle state** — Whether the optional DNS filter is enabled or disabled
- **Onboarding responses** — Your answers to the usage survey (estimated daily short-form video time) and reduction goal. These are used to personalize your Time Reclaimed calculations
- **Streak data** — The date you started your current scroll-free streak

All of this data is stored locally on your device using Apple's standard UserDefaults. **None of this data ever leaves your device.** No data is synced to any server, cloud service, or third party.

## Home Screen Widgets

Shortless offers optional Home Screen and Lock Screen widgets that display your streak, block count, and Time Reclaimed statistics. These widgets read data from the same on-device App Group storage described above. No network requests are made by the widgets.

## Third-Party Services

Shortless does not integrate with, send data to, or receive data from any third-party services, APIs, or servers. The only external network communication is DNS query forwarding to public resolvers (1.1.1.1 and 8.8.8.8) when the optional DNS filter is active, and these queries are standard DNS resolution — not modified, logged, or analyzed by Shortless.

## Open Source

Shortless is open source under the MIT license. The complete source code, including all filter rules and the DNS blocking implementation, is available for public inspection:

https://github.com/pmartin1915/shortless-ios

## Children's Privacy

Shortless does not collect any data from any user, including children under 13.

## Changes to This Policy

If this privacy policy is updated, the changes will be reflected in this repository with an updated date.

## Contact

For questions or concerns about this privacy policy, please open an issue on the GitHub repository:

https://github.com/pmartin1915/shortless-ios
