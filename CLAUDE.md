# Shortless iOS -- CLAUDE.md

## Project Overview

Shortless is a Safari content blocker and Screen Time integration app for iOS. It blocks YouTube Shorts and other short-form video content, helping users manage their screen time. Published on the App Store.

**Developer:** Perry Martin (pmartin1915)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.9 |
| Platform | iOS 16+ |
| Build | Xcode project via project.yml (XcodeGen) |
| Targets | Main app, ContentBlocker, SafariExtension, VPNExtension, ActivityMonitor, ShieldConfig, Widget |
| Local Package | ShortlessKit (shared logic) |
| Screen Time | FamilyControls + DeviceActivityMonitor + ManagedSettings |
| Tests | XCTest (ShortlessTests/) |

## Project Structure

```
shortless-ios/
  ShortlessApp/           # Main app UI and logic
  ShortlessContentBlocker/ # Safari content blocker rules
  ShortlessSafariExtension/ # Safari extension
  ShortlessVPNExtension/  # VPN-based blocking
  ShortlessActivityMonitor/ # Screen Time schedule enforcement
  ShortlessShieldConfig/  # Custom shield screen
  ShortlessWidget/        # Widget extension
  ShortlessKit/           # Shared Swift package
  ShortlessTests/         # Unit tests
  docs/                   # Documentation
  scripts/                # CI/CD and build scripts
  project.yml             # XcodeGen project definition
```

## Constraints

- Swift only -- no TypeScript, no npm
- No modifications to provisioning profiles or entitlements without Perry's approval
- No changes to App Store metadata or pricing
- Privacy-sensitive: handles Screen Time data via opaque tokens only

## State

- `ai/STATE.md` -- current context
