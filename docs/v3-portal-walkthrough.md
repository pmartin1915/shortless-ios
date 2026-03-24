---
title: "Shortless v3.0 — Apple Developer Portal Walkthrough"
subtitle: "Manual steps required before Claude can build the Screen Time integration"
date: "2026-03-24"
geometry: margin=1in
fontsize: 11pt
---

# Overview

You've already submitted and had approved the Family Controls (Individual) entitlement for three bundle IDs. This document walks you through the remaining Apple Developer portal and GitHub steps that require your browser/credentials. Once complete, Claude can implement all the code.

**What you registered (entitlement requests):**

| Bundle ID | Purpose |
|-----------|---------|
| `dev.pmartin1915.shortless` | Main app (needs Family Controls to call `AuthorizationCenter`) |
| `dev.pmartin1915.shortless.ActivityMonitor` | DeviceActivity extension (enforces schedules) |
| `dev.pmartin1915.shortless.ShieldConfig` | Shield configuration (custom block screen UI) |

---

# Step 1: Enable Family Controls on App IDs

Go to: **Certificates, Identifiers & Profiles → Identifiers**

## 1a. Main App (`dev.pmartin1915.shortless`)

1. Click on `dev.pmartin1915.shortless`
2. Scroll to **Capabilities**
3. Check **Family Controls**
4. Click **Save**

> You already have App Groups enabled. Leave that checked.

## 1b. Activity Monitor (`dev.pmartin1915.shortless.ActivityMonitor`)

You registered this App ID earlier today. Now enable capabilities:

1. Click on `dev.pmartin1915.shortless.ActivityMonitor`
2. Enable **Family Controls**
3. Enable **App Groups** → Configure → select `group.dev.pmartin1915.shortless`
4. Click **Save**

## 1c. Shield Config (`dev.pmartin1915.shortless.ShieldConfig`)

Same as above:

1. Click on `dev.pmartin1915.shortless.ShieldConfig`
2. Enable **Family Controls**
3. Enable **App Groups** → Configure → select `group.dev.pmartin1915.shortless`
4. Click **Save**

---

# Step 2: Regenerate Main App Provisioning Profile

The main app's provisioning profile needs to include the new Family Controls entitlement.

Go to: **Certificates, Identifiers & Profiles → Profiles**

1. Find **"Shortless AppStore"**
2. Click on it → **Edit**
3. Verify it shows the updated capabilities (Family Controls should now appear)
4. Click **Generate**
5. **Download** the new `.mobileprovision` file
6. Save it somewhere accessible (e.g., `C:\tmp\apple-signing\`)

---

# Step 3: Create Provisioning Profiles for New Targets

## 3a. Activity Monitor Profile

1. Click **+** (top left) to create a new profile
2. Select **App Store Connect** (under Distribution)
3. Click **Continue**
4. Select App ID: `dev.pmartin1915.shortless.ActivityMonitor`
5. Click **Continue**
6. Select certificate: **Apple Distribution: Perry Martin**
7. Click **Continue**
8. Profile Name: **Shortless ActivityMonitor AppStore**
9. Click **Generate**
10. **Download** the `.mobileprovision` file

## 3b. Shield Config Profile

1. Click **+** again
2. Select **App Store Connect**
3. Select App ID: `dev.pmartin1915.shortless.ShieldConfig`
4. Select certificate: **Apple Distribution: Perry Martin**
5. Profile Name: **Shortless ShieldConfig AppStore**
6. Click **Generate**
7. **Download** the `.mobileprovision` file

---

# Step 4: Upload Profiles to GitHub Secrets

You need to base64-encode each profile and add/update GitHub secrets.

Open a terminal and run these commands for each downloaded `.mobileprovision` file:

```bash
# On Windows (Git Bash or WSL):
base64 -w 0 < "path/to/Shortless_AppStore.mobileprovision" | clip
# Paste into GitHub secret

base64 -w 0 < "path/to/Shortless_ActivityMonitor_AppStore.mobileprovision" | clip
base64 -w 0 < "path/to/Shortless_ShieldConfig_AppStore.mobileprovision" | clip
```

Go to: **GitHub → pmartin1915/shortless-ios → Settings → Secrets and variables → Actions**

| Secret Name | Action |
|-------------|--------|
| `PROVISIONING_PROFILE_APP` | **Update** with the regenerated main app profile |
| `PROVISIONING_PROFILE_ACTIVITY_MONITOR` | **Create new** with Activity Monitor profile |
| `PROVISIONING_PROFILE_SHIELD_CONFIG` | **Create new** with Shield Config profile |

---

# Step 5: Verify

After completing all steps, confirm the following:

- [ ] Family Controls enabled on all 3 App IDs
- [ ] App Groups configured on both new App IDs (`group.dev.pmartin1915.shortless`)
- [ ] Main app provisioning profile regenerated and uploaded to GitHub
- [ ] Activity Monitor provisioning profile created and uploaded to GitHub
- [ ] Shield Config provisioning profile created and uploaded to GitHub
- [ ] 3 new GitHub secrets exist: `PROVISIONING_PROFILE_APP` (updated), `PROVISIONING_PROFILE_ACTIVITY_MONITOR`, `PROVISIONING_PROFILE_SHIELD_CONFIG`

---

# What Happens Next

**All code is already written and pushed** (commit `1a98a99`, 2026-03-24). Once you complete the portal steps above:

1. Tag the release: `git tag v3.0.0 && git push origin v3.0.0`
2. This triggers the deploy workflow (or use manual workflow_dispatch)
3. CI archives with 7 provisioning profiles and uploads to App Store Connect
4. Submit for review in App Store Connect with App Review notes (see below)

**App Review notes to include:**
> Shortless uses two distinct Apple APIs for digital wellness:
> 1. **Local VPN (NEPacketTunnelProvider):** DNS-only split tunnel that blocks TikTok domains on-device. No traffic leaves the device. No data is logged, stored, or transmitted.
> 2. **Screen Time (FamilyControls):** Lets users block native apps on a self-defined schedule using Apple's standard FamilyActivityPicker. Uses opaque tokens only — the app cannot read app names or usage data.
> Both features serve the same goal: helping users reduce short-form video consumption.

**Total new GitHub secrets needed:** 2 new + 1 updated = 3 actions
**Total provisioning profiles after v3.0:** 7 (app, CB, Safari ext, VPN ext, widget, activity monitor, shield config)
