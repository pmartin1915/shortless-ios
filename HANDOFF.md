# HANDOFF — Shortless iOS (2026-03-24)

## Where We Are

| Platform | Version | Store | Status |
|----------|---------|-------|--------|
| Chrome extension | 1.1.1 | Chrome Web Store | Under review |
| Firefox extension | 1.1.1 | Firefox Add-ons (AMO) | Under review |
| iOS app | 2.1.0 | App Store | Under review |
| iOS v3.0.0 | 3.0.0 | Not submitted | Code complete, awaiting portal setup |

**Branch:** `master` — clean, pushed at `1a98a99`.

## What This Session Did

### Screen Time Integration (v3.0.0)

Built the full Apple Screen Time API integration for scheduled native app blocking:

1. **Family Controls entitlement** — submitted and approved for all 3 bundle IDs (main app, ActivityMonitor, ShieldConfig) in a single session
2. **2 new extension targets:**
   - `ShortlessActivityMonitor` — DeviceActivityMonitor that enforces schedules with day-of-week filtering
   - `ShortlessShieldConfig` — custom branded shield screen (teal #3ABAB4, dark background)
3. **ScheduleRule model** — Codable, start/end time, active days (Sun-Sat), enabled flag
4. **ScheduleManager** — DeviceActivityCenter wrapper, throws on failure
5. **AppBlockerView rewrite** — "Always On" vs "Scheduled" mode, time picker, day-of-week pills (Tu/Th), auth error alert
6. **SharedConstants.swift** — single source of truth for ManagedSettingsStore.Name and DeviceActivityName
7. **SettingsStore** — schedule/appBlocker/blockingMode persistence, public UserDefaults keys, Combine observer for cross-process sync, startOfDay streak math
8. **CI/CD** — deploy.yml handles 7 provisioning profiles, ExportOptions with 7 bundle ID mappings
9. **Privacy policy** — Screen Time / opaque token disclosure added
10. **17 new unit tests** — ScheduleRule (10) + SettingsStore schedule (7)

### Audit Results (3 rounds, Claude + Gemini 3 Pro Preview)

| Round | Tool | Findings | Status |
|-------|------|----------|--------|
| 1 | Claude auditor | 9 issues (1C, 2H, 3M, 3L) | All fixed |
| 2 | Gemini codereview + secaudit | 3 new (all M) | All fixed |
| 3 | Gemini codereview + secaudit | 2 new (both L) | All fixed |

Final state: **0 open findings**. Security audit clean. OWASP assessment: all categories secure.

### Browser Extension (Phase C)

Unit tests for background.js and youtube-fetch-guard.js — 49 Vitest assertions. Committed at `5447a05` in `C:\Shortless`.

## What Perry Needs to Do (Manual Portal Steps)

**Walkthrough doc:** `C:\shortless-ios\docs\v3-portal-walkthrough.md` (also `.docx`, `.html`)

### Apple Developer Portal
1. Enable **Family Controls** capability on 3 App IDs (main app, ActivityMonitor, ShieldConfig)
2. Configure **App Groups** on the 2 new App IDs → select `group.dev.pmartin1915.shortless`
3. **Regenerate** main app provisioning profile ("Shortless AppStore")
4. **Create** 2 new profiles: "Shortless ActivityMonitor AppStore", "Shortless ShieldConfig AppStore"
5. Download all 3 `.mobileprovision` files

### GitHub Secrets
6. Base64-encode each profile: `base64 -w 0 < file.mobileprovision | clip`
7. Update `PROVISIONING_PROFILE_APP` secret (regenerated profile)
8. Create `PROVISIONING_PROFILE_ACTIVITY_MONITOR` secret
9. Create `PROVISIONING_PROFILE_SHIELD_CONFIG` secret

### Deploy
10. Tag: `git tag v3.0.0 && git push origin v3.0.0` (triggers deploy workflow)
11. Submit in App Store Connect with App Review notes (in walkthrough doc)

## What's Already Done (Full History)

- 3-layer defense: DNR (L1) + CSS injection (L2) + MutationObserver (L3)
- L1.5: MAIN world fetch guard for YouTube Shorts POST bodies
- Per-platform toggles (YouTube, Instagram, TikTok, Snapchat)
- Firefox MV3 port: `setBadgeTextColor` guard, `cloneInto` for cross-world events
- Playwright tests: 5 offline specs (43 assertions) + 5 network specs (9 assertions)
- Vitest unit tests: 49 assertions (background.js + fetch guard)
- Shared source architecture: `packages/shared/` → build copies to Chrome + Firefox
- iOS v2.1.0: Safari Content Blocker + Web Extension + VPN Extension + Widget
- iOS v3.0.0: Screen Time integration (FamilyControls + ManagedSettings + DeviceActivity)
- Family Controls (Individual) entitlement approved for all 3 bundle IDs
- 3 full audit rounds (Claude + Gemini 3 Pro) — 0 open findings

## What's Next After Portal Setup

### Immediate
- **Deploy v3.0.0** — tag + push triggers CI/CD
- **Await v2.1.0 review** — if approved, submit v3.0.0 as update
- **Await browser extension reviews** — CWS v1.1.1, AMO v1.1.1

### If App Store Rejects
- **4.3(a):** See `memory/handoff-4.3a-resubmission.md` for prior rejection context
- **5.4 (VPN):** App Review notes explain local-only DNS filtering. Precedent: AdGuard Pro, 1Blocker
- **FamilyControls:** Individual authorization, not parental controls. Prepare demo video if requested.

### Medium-Term Roadmap
- **v3.0 Screen Time API** — entitlement approved, code complete, awaiting portal setup
- **VPN deprecation evaluation** — once Screen Time is shipping, consider removing VPN to reduce App Store risk
- **Pro features** — scheduler enhancements (custom recurring rules), passcode lock
- **Xcode SDK deadline** — April 28, 2026: all iOS apps must use iOS 26 SDK

## Key Files

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen config — 8 targets (v3.0.0 build 12) |
| `Shortless.entitlements` | Main app: Family Controls + VPN + App Groups |
| `ShortlessActivityMonitor/` | DeviceActivity schedule enforcement |
| `ShortlessShieldConfig/` | Custom branded shield screen |
| `ShortlessKit/Sources/ShortlessKit/SharedConstants.swift` | Shared store names + activity names |
| `ShortlessKit/Sources/ShortlessKit/Storage/SettingsStore.swift` | All state + public UserDefaults keys |
| `ShortlessKit/Sources/ShortlessKit/Models/ScheduleRule.swift` | Schedule model (Codable) |
| `ShortlessApp/Views/AppBlockerView.swift` | Screen Time UI (picker + schedule + toggle) |
| `ShortlessApp/Views/ScheduleManager.swift` | DeviceActivityCenter wrapper |
| `.github/workflows/deploy.yml` | 7 provisioning profiles, App Store upload |
| `docs/v3-portal-walkthrough.md` | Perry's manual portal steps |

## Commands

```bash
# No CLI build on Windows — all builds via GitHub Actions (macos-14 runner)
git tag v3.0.0 && git push origin v3.0.0   # Trigger deploy
```

## Constraints

- **No Mac available** — all builds via GitHub Actions CI/CD
- No new permissions beyond FamilyControls, VPN, and App Groups
- No data collection, no telemetry, no remote code
- Screen Time uses opaque tokens — cannot read app names
- VPN + FamilyControls combination requires careful App Review notes
- Extensions have strict memory limits (~6MB ShieldConfig, ~15MB ActivityMonitor)
