# Privacy Policy — Shortless for iOS

**Last updated:** March 15, 2026

## Overview

Shortless is an iOS app with Safari Content Blocker, Safari Web Extension, and an optional DNS filter that blocks short-form video content (YouTube Shorts, Instagram Reels, TikTok, and Snapchat Spotlight). It is designed with privacy as a core principle: the app collects no personal data whatsoever.

## Data Collection

Shortless does **not** collect, store, or transmit any personal data. Specifically:

- No analytics or telemetry
- No tracking of any kind
- No cookies
- No user accounts or sign-up
- No external network requests are made by the app or its extensions (the optional DNS filter forwards non-blocked DNS queries to Cloudflare 1.1.1.1 or Google 8.8.8.8, but does not log or store them)
- No browsing history is accessed or recorded

## How Blocking Works

All content blocking happens entirely on your device. The app uses three mechanisms, all of which operate locally:

1. **Safari Content Blocker** — Apple's native content blocking API uses declarative rules to block or hide short-form content before it renders. These rules are generated on-device from your preferences.
2. **Safari Web Extension** — Content scripts monitor web pages for dynamically loaded short-form content (common in single-page apps like YouTube and Instagram) and hide it in real time.
3. **DNS Filter (optional)** — A local VPN that blocks TikTok by intercepting DNS queries on your device. When enabled, DNS queries for TikTok-related domains are answered locally with "domain not found" (NXDOMAIN). DNS queries for all other domains are forwarded to public DNS resolvers (Cloudflare 1.1.1.1 or Google 8.8.8.8). No DNS queries, browsing history, or network traffic is logged, stored, or transmitted to any server operated by Shortless.

None of these mechanisms send personal data off your device.

## Data Stored Locally

Shortless stores a small amount of data on your device using App Groups (shared between the app and its extensions):

- **Platform preferences** — Which platforms you have enabled or disabled (simple on/off toggles). This data never leaves your device.
- **Block counter** — A daily count of blocked content items. This counter never leaves your device.
- **VPN toggle state** — Whether the optional DNS filter is enabled or disabled. This preference never leaves your device.

No other data is stored. No data is synced to any server.

## Third-Party Services

Shortless does not integrate with, send data to, or receive data from any third-party services, APIs, or servers.

## Open Source

Shortless is open source. The complete source code, including all filter rules, is available for inspection:

https://github.com/pmartin1915/shortless-ios

## Children's Privacy

Shortless does not collect any data from any user, including children under 13.

## Changes to This Policy

If this privacy policy is updated, the changes will be reflected in this repository with an updated date.

## Contact

For questions or concerns about this privacy policy, please open an issue on the GitHub repository:

https://github.com/pmartin1915/shortless-ios
