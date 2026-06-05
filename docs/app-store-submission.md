# App Store Submission — weighttracker.io

**Bundle ID:** com.erikolsen.WeightTracker  
**Version:** 1.0 (build 1)  
**Deployment target:** iOS 17.0  
**Devices:** iPhone only (TARGETED_DEVICE_FAMILY = 1)

---

## 1. Register Bundle ID & Create App Record

### 1a. Register the Bundle ID (one-time)

1. Go to [developer.apple.com/account/resources/identifiers/list](https://developer.apple.com/account/resources/identifiers/list)
2. Click **+** → choose **App IDs** → **App** → Continue
3. Fill in:
   - Description: `WeightTracker`
   - Bundle ID: **Explicit** → `com.erikolsen.WeightTracker`
   - Capabilities: enable **HealthKit** if you plan to read health data; otherwise leave defaults
4. Continue → Register

### 1b. Create the App in App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. My Apps → **+** → New App
   - Platform: iOS
   - Name: **weighttracker.io**
   - Primary language: English
   - Bundle ID: `com.erikolsen.WeightTracker` *(select from dropdown — it appears after step 1a)*
   - SKU: `weighttracker-io-1` (or anything unique to you)
3. Save — this creates the listing shell

---

## 2. App Metadata

Fill in the following under the App Store listing:

| Field | Value |
|---|---|
| Name | weighttracker.io |
| Subtitle | Track weight & BMI goals |
| Category | Health & Fitness |
| Secondary category | (optional) |
| Support URL | `https://eoolsen.github.io/weighttracker/privacy-policy/` |
| Privacy Policy URL | `https://eoolsen.github.io/weighttracker/privacy-policy/` |

Copy the description and keywords from [app-store-description.md](app-store-description.md).

---

## 3. Screenshots

See [screenshots-workflow.md](screenshots-workflow.md) for the full process.

Required size:
- **6.9" display** — 1320×2868 px — mandatory
- Simulator to use: **iPhone 16 Pro Max** or **iPhone 17 Pro Max**
- ⚠️ iPhone 16 Pro (6.3") screenshots at 1206×2622 will be rejected — wrong slot

At least 1 screenshot; up to 10.

---

## 4. Xcode — Archive & Upload

1. Open `WeightTracker.xcodeproj`
2. Set the scheme destination to **Any iOS Device (arm64)**
3. Confirm version/build: **Product → Scheme → Edit Scheme** or target General tab
4. **Product → Archive** — wait for the build to complete
5. Xcode Organizer opens automatically
6. Select the archive → **Distribute App**
7. Choose **App Store Connect** → **Upload**
8. Leave all checkboxes at their defaults (symbols, bitcode) → Next → Upload
9. Wait ~5 min for processing, then the build appears in App Store Connect under TestFlight/Builds

---

## 5. Pre-submission Checklist

- [ ] App icon present and correct (1024×1024 PNG, no alpha) — `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- [ ] Privacy manifest present — `PrivacyInfo.xcprivacy` (already configured)
- [ ] No crash on first launch with zero entries
- [ ] No crash when height is not yet set (BMI shows "Enter height in Settings" gracefully)
- [ ] Goal Progress shows "Set a goal weight" message when no goal is set
- [ ] Delete entries works correctly
- [ ] Settings saves height and goal correctly
- [ ] App name on home screen reads correctly (check Display Name in target General tab)
- [ ] Deployment target is iOS 17.0 — confirm SwiftData and Charts are available

---

## 6. Export Compliance

When prompted during submission:
- "Does your app use encryption beyond what is in the OS?" → **No**
- This exempts you from EAR documentation

---

## 7. Submit for Review

1. In App Store Connect, go to the app → **+ Version or Platform** → 1.0
2. Select the uploaded build
3. Fill in **"What's New in This Version"**: `Initial release.`
4. Complete all required metadata fields
5. Click **Add for Review** → **Submit to App Review**

**Expected review time:** 1–2 business days. Apple may ask for a demo account if login is required — this app has no login, so none needed.

---

## 8. Privacy Policy (minimum viable)

You need a hosted URL. Minimum content for a data-on-device-only app:

> weighttracker.io does not collect, transmit, or share any personal data. All information you enter (weight entries, height, goal weight) is stored locally on your device using Apple's SwiftData framework and never leaves your device.

Host it on GitHub Pages, Notion, or any public URL.
