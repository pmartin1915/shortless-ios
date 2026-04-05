# Shortless iOS — Xcode Project Setup

The Xcode project is generated automatically from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). No manual project creation needed.

## Prerequisites

- macOS with Xcode 16+
- Apple Developer account ($99/yr)
- Physical iPhone or iPad (Content Blockers require a real device)
- iOS deployment target: 16.0

## Quick Start (Recommended)

```bash
# 1. Install XcodeGen (one-time)
brew install xcodegen

# 2. Clone the repo
git clone https://github.com/pmartin1915/shortless-ios.git
cd shortless-ios

# 3. Generate the Xcode project
xcodegen generate

# 4. Open in Xcode
open Shortless.xcodeproj
```

Then:
1. Select your Team in each target's Signing & Capabilities
2. Select a physical device
3. Build and run (Cmd+R)
4. On the device: Settings → Safari → Extensions → Enable both Shortless extensions

## CI/CD

GitHub Actions automatically builds and tests on every push to `master`/`main`. See `.github/workflows/build.yml`.

The CI workflow:
1. Installs XcodeGen on a macOS runner
2. Generates the Xcode project from `project.yml`
3. Builds all targets (app + both extensions)
4. Runs ShortlessKit unit tests on simulator

## Project Structure

The `project.yml` defines 4 targets:

| Target | Type | Bundle ID |
|--------|------|-----------|
| Shortless | iOS App | `dev.pmartin1915.shortless` |
| ShortlessContentBlocker | App Extension | `dev.pmartin1915.shortless.ContentBlocker` |
| ShortlessSafariExtension | App Extension | `dev.pmartin1915.shortless.SafariExtension` |
| ShortlessTests | Unit Tests | `dev.pmartin1915.shortless.Tests` |

All targets share App Group `group.dev.pmartin1915.shortless` for IPC (entitlements files are pre-configured).

## What XcodeGen Handles For You

- Creates the `.xcodeproj` with all 4 targets
- Links `ShortlessKit` as a local Swift Package dependency
- Embeds both extensions in the main app
- Sets up Info.plist with correct `NSExtension` entries
- References entitlements files for App Groups
- Configures the build scheme with test targets
- Sets iOS 16.0 deployment target

## Testing on Device

1. Select a physical device (not simulator — Content Blockers require real devices)
2. Build and run (Cmd+R)
3. On the device, go to Settings → Safari → Extensions → Enable both Shortless extensions
4. Open Safari and test:
   - Visit `youtube.com` → Shorts elements should be hidden
   - Visit `tiktok.com` → Should be blocked
   - Visit `instagram.com/reels/` → Should redirect to homepage
   - Visit `snapchat.com/spotlight` → Should redirect to homepage

## Provisioning Profiles

If Xcode shows signing errors:

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Ensure your App ID includes the App Groups capability
3. Create/regenerate provisioning profiles for all three bundle IDs:
   - `dev.pmartin1915.shortless`
   - `dev.pmartin1915.shortless.ContentBlocker`
   - `dev.pmartin1915.shortless.SafariExtension`

## App Store Submission

### Step 1: Create App Record in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. My Apps → + → New App
3. Settings:
   - Platform: iOS
   - Name: `Shortless`
   - Primary Language: English (U.S.)
   - Bundle ID: `dev.pmartin1915.shortless`
   - SKU: `shortless-ios-v1`
4. Create

### Step 2: App Store Metadata

- **Subtitle** (30 chars): `Block Shorts, Reels & More`
- **Category**: Productivity (primary), Utilities (secondary)
- **Description**: Adapt from browser extension CWS listing
- **Keywords** (100 chars): `content blocker,shorts,reels,spotlight,youtube,instagram,snapchat,focus,productivity,screen time`
- **Privacy URL**: `https://github.com/pmartin1915/shortless/blob/master/packages/extension/PRIVACY_POLICY.md`
- **Support URL**: `https://github.com/pmartin1915/shortless-ios/issues`

### Step 3: Privacy Nutrition Label

- Data types collected: **None**
- Data linked to you: **None**
- Data used to track you: **None**
- Select: **"Data Not Collected"**

### Step 4: Archive and Upload

1. In Xcode: Product → Archive
2. When archive completes, Organizer window opens
3. Select the archive → Distribute App → App Store Connect
4. Choose "Upload" (not "Export")
5. Follow prompts (automatic signing recommended)

### Step 5: TestFlight (Recommended)

1. After upload, the build appears in App Store Connect → TestFlight
2. Add internal testers (your Apple ID)
3. Install via TestFlight app on device
4. Test all platforms before submitting for review

### Step 6: Submit for Review

1. App Store Connect → App Store tab
2. Select your build
3. Fill in review notes: "This app provides Safari Content Blocker and Web Extension to hide short-form video content (YouTube Shorts, Instagram Reels, Snapchat Spotlight) and block TikTok. Enable extensions in Settings → Safari → Extensions."
4. Submit for Review

### Common Build Errors

- **"App Group not configured"**: Entitlements files are pre-configured. If regenerating the project, ensure `project.yml` references the `.entitlements` files correctly.
- **"No matching provisioning profiles"**: In Signing & Capabilities, enable "Automatically manage signing" for all targets
- **Content Blocker not working in Simulator**: This is expected — Content Blockers require a physical device
- **"Missing Info.plist key"**: Run `xcodegen generate` to regenerate — Info.plist entries are defined in `project.yml`

## Manual Setup (Alternative)

If you prefer not to use XcodeGen, you can create the project manually:

1. Xcode → File → New → Project → iOS → App (SwiftUI, Swift, iOS 16.0)
2. Product Name: `Shortless`, Org ID: `dev.pmartin1915`
3. Replace generated files with `ShortlessApp/` contents
4. File → Add Package Dependencies → Add Local → select `ShortlessKit/`
5. File → New → Target → Content Blocker Extension → `ShortlessContentBlocker`
6. Replace generated handler with `ShortlessContentBlocker/ContentBlockerRequestHandler.swift`
7. Delete generated `blockerList.json`
8. File → New → Target → Safari Web Extension → `ShortlessSafariExtension`
9. Replace generated files with `ShortlessSafariExtension/` contents
10. Add App Groups capability (`group.dev.pmartin1915.shortless`) to all 3 targets
11. Add `ShortlessKit` as dependency to all targets
