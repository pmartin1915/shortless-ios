# CI/CD Setup — Deploy to App Store from GitHub Actions

This guide sets up automated App Store deployment. Once configured, you push code from any machine (Windows, Mac, anything) and GitHub Actions handles building, signing, and uploading to App Store Connect.

## Overview

You need to create 5 GitHub Secrets:

| Secret | What it is |
|--------|-----------|
| `APPLE_CERTIFICATE_P12` | Your signing certificate (base64) |
| `APPLE_CERTIFICATE_PASSWORD` | Password you set when creating the .p12 |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY` | Contents of the .p8 file |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |

---

## Step 1: Register App IDs (Apple Developer Portal)

Go to https://developer.apple.com/account/resources/identifiers/list

### 1a. Register the App Group

1. Click the dropdown next to "Identifiers" → select **App Groups** → click **+**
2. Description: `Shortless Shared`
3. Identifier: `group.dev.pmartin1915.shortless`
4. Continue → Register

### 1b. Register App IDs

Click **+** three times to register these App IDs:

**Main App:**
- Type: App IDs → App
- Description: `Shortless`
- Bundle ID (Explicit): `dev.pmartin1915.shortless`
- Capabilities: check **App Groups**
- Continue → Register

**Content Blocker Extension:**
- Description: `Shortless Content Blocker`
- Bundle ID: `dev.pmartin1915.shortless.ContentBlocker`
- Capabilities: check **App Groups**

**Safari Web Extension:**
- Description: `Shortless Safari Extension`
- Bundle ID: `dev.pmartin1915.shortless.SafariExtension`
- Capabilities: check **App Groups**

### 1c. Configure App Groups on each App ID

For each of the 3 App IDs you just created:
1. Click on the App ID
2. Scroll to App Groups → click **Configure**
3. Check `group.dev.pmartin1915.shortless`
4. Save

---

## Step 2: Create Distribution Certificate

### 2a. Upload the CSR

The CSR file was already generated at: `C:\tmp\apple-signing\distribution.csr`

1. Go to https://developer.apple.com/account/resources/certificates/list
2. Click **+**
3. Select **Apple Distribution** → Continue
4. Upload `C:\tmp\apple-signing\distribution.csr`
5. Continue → **Download** the `.cer` file

### 2b. Convert to .p12

Save the downloaded `.cer` file somewhere (e.g., `C:\tmp\apple-signing\distribution.cer`), then run:

```bash
bash scripts/convert-cert.sh "C:/tmp/apple-signing/distribution.cer"
```

This will:
- Ask you for a password (remember it!)
- Print the base64-encoded certificate
- Tell you what to paste into GitHub Secrets

**Save these two values:**
- `APPLE_CERTIFICATE_PASSWORD` — the password you entered
- `APPLE_CERTIFICATE_P12` — the base64 string

---

## Step 3: Create App Store Connect API Key

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click **Generate API Key** (or **+** if you already have keys)
3. Name: `GitHub Actions`
4. Access: **App Manager**
5. Click **Generate**
6. **Download the .p8 file** (you can only download it ONCE!)
7. Note the **Key ID** shown in the table
8. Note the **Issuer ID** shown at the top of the page

**Save these three values:**
- `APP_STORE_CONNECT_API_KEY_ID` — the Key ID
- `APP_STORE_CONNECT_API_ISSUER_ID` — the Issuer ID
- `APP_STORE_CONNECT_API_KEY` — open the .p8 file in a text editor and copy ALL contents

---

## Step 4: Find Your Team ID

1. Go to https://developer.apple.com/account#MembershipDetailsCard
2. Your **Team ID** is shown (10-character alphanumeric string)

**Save:** `APPLE_TEAM_ID`

---

## Step 5: Create App Record in App Store Connect

1. Go to https://appstoreconnect.apple.com/apps
2. Click **+** → **New App**
3. Platform: **iOS**
4. Name: `Shortless`
5. Primary Language: English (U.S.)
6. Bundle ID: select `dev.pmartin1915.shortless`
7. SKU: `shortless-ios-v1`
8. Click **Create**

---

## Step 6: Add GitHub Secrets

1. Go to https://github.com/pmartin1915/shortless-ios/settings/secrets/actions
2. Click **New repository secret** for each:

| Name | Value |
|------|-------|
| `APPLE_CERTIFICATE_P12` | The base64 string from Step 2b |
| `APPLE_CERTIFICATE_PASSWORD` | The password from Step 2b |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from Step 3 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from Step 3 |
| `APP_STORE_CONNECT_API_KEY` | Full contents of the .p8 file from Step 3 |
| `APPLE_TEAM_ID` | Team ID from Step 4 |

---

## Step 7: Deploy!

### Option A: Manual deploy (recommended first time)
1. Go to https://github.com/pmartin1915/shortless-ios/actions
2. Click **Deploy to App Store** in the left sidebar
3. Click **Run workflow** → **Run workflow**
4. Watch it build, archive, and upload

### Option B: Tag-based deploy
```bash
git tag v1.0.0
git push origin v1.0.0
```
This triggers the deploy workflow automatically.

### After upload
1. Go to App Store Connect → TestFlight
2. Your build will appear (may take 5-10 minutes for processing)
3. Add yourself as a tester
4. Install via TestFlight on your iPhone
5. When ready → submit for App Store review

---

## Troubleshooting

- **"No signing certificate"**: Check that APPLE_CERTIFICATE_P12 is correct base64 and the password matches
- **"No provisioning profile"**: The `-allowProvisioningUpdates` flag should auto-create profiles. If it fails, you may need to create them manually on the Developer Portal
- **"App ID not found"**: Ensure all 3 App IDs are registered (Step 1b)
- **"API key invalid"**: Double-check Key ID and Issuer ID. The .p8 contents should start with `-----BEGIN PRIVATE KEY-----`
