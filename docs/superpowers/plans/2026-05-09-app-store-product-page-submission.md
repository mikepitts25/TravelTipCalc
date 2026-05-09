# App Store Product Page Submission Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare and submit the US English App Store Connect product page for Travel Tip Calculator using the approved metadata spec.

**Architecture:** This is a submission workflow, not an app-code implementation. The approved copy lives in `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`; this plan turns it into a checklist for App Store Connect fields, screenshot captions, IAP metadata, and claim verification before submission.

**Tech Stack:** App Store Connect, Flutter iOS app metadata, repository documentation.

---

## File Structure

- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`
  - Source of truth for approved App Store metadata and copy.
- Read: `README.md`
  - Confirms app positioning and feature set.
- Read: `assets/data/tipping_data.json`
  - Confirms country count claim.
- Read: `lib/screens/history/history_screen.dart`
  - Confirms trip history and CSV export UI.
- Read: `lib/services/ad_service.dart`
  - Confirms ad service release configuration state.
- Read: `lib/services/purchase_service.dart`
  - Confirms purchase service release configuration state.

## Task 1: Verify Launch Claims Before Pasting Metadata

**Files:**
- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`
- Read: `assets/data/tipping_data.json`
- Read: `lib/screens/history/history_screen.dart`
- Read: `lib/services/ad_service.dart`
- Read: `lib/services/purchase_service.dart`

- [ ] **Step 1: Confirm the country count claim**

Run:

```bash
node - <<'NODE'
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('assets/data/tipping_data.json', 'utf8'));
console.log(data.countries.length);
NODE
```

Expected: prints `203`, which supports the `200+ countries` wording.

- [ ] **Step 2: Confirm export wording**

Run:

```bash
rg -n "exportCsv|Export CSV|PDF|export" lib/screens/history lib/providers/history_provider.dart lib/screens/pro/pro_upgrade_screen.dart
```

Expected: CSV export is present. If PDF export is not fully implemented and exposed, keep App Store wording as `export` and do not promise `PDF`.

- [ ] **Step 3: Confirm ad and purchase readiness**

Run:

```bash
sed -n '1,120p' lib/services/ad_service.dart
sed -n '1,120p' lib/services/purchase_service.dart
sed -n '1,120p' lib/config/ad_config.dart
```

Expected before submission: AdMob and in-app purchase services should be configured for production. If they remain stubbed, remove or soften claims about ads, Pro, and purchases in the App Store listing before submitting.

## Task 2: Enter Core App Store Metadata

**Files:**
- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`

- [ ] **Step 1: Open App Store Connect**

Go to App Store Connect, select the app, then open the US English product page metadata fields for the target app version.

- [ ] **Step 2: Enter app name**

Paste:

```text
Travel Tip Calculator
```

Expected: App Store Connect accepts the value because it is 21 characters and under the 30-character limit.

- [ ] **Step 3: Enter subtitle**

Paste:

```text
Global Tipping Guide
```

Expected: App Store Connect accepts the value because it is 20 characters and under the 30-character limit.

- [ ] **Step 4: Enter promotional text**

Paste:

```text
Know what to tip before the bill arrives. Get country-aware tipping guidance, fast bill splitting, offline access, and Pro trip history.
```

Expected: App Store Connect accepts the value because it is 136 characters and under the 170-character limit.

- [ ] **Step 5: Enter keywords**

Paste:

```text
bill,splitter,restaurant,taxi,hotel,vacation,gratuity,etiquette,country,currency,offline,customs
```

Expected: App Store Connect accepts the value because it is 96 characters and under the 100-character limit.

- [ ] **Step 6: Enter description**

Paste:

```text
Travel Tip Calculator helps you know what to tip with confidence wherever you travel.

Get country-aware tip suggestions, bill splitting, and local tipping etiquette in one fast calculator. Whether you are at a restaurant, in a taxi, checking into a hotel, ordering delivery, visiting a spa, or joining a tour, Travel Tip Calculator helps you understand what is customary before the bill arrives.

Features:
- Country-specific tipping guidance for 200+ countries
- Suggested tip ranges by service type
- Restaurant, taxi, hotel, delivery, bar, spa, valet, tour guide, and more
- Fast bill and tip calculator
- Split totals between multiple people
- Smart rounding for cleaner totals
- Local currency support
- Tipping etiquette notes for each country
- Works offline with bundled tipping data
- Saves your preferred tip choices by country and service

Travel Tip Calculator is designed for travelers who want to be respectful, prepared, and quick at the moment of payment.

Upgrade to Pro to remove ads, save trip history, and export past calculations for your records.
```

Expected: App Store Connect accepts the value because it is under the 4000-character limit.

## Task 3: Enter IAP Metadata

**Files:**
- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`
- Read: `lib/config/constants.dart`

- [ ] **Step 1: Confirm product ID and price**

Run:

```bash
sed -n '1,80p' lib/config/constants.dart
```

Expected: product ID is `travel_tip_calc_pro` and Pro price is `$4.99`, unless the release plan has changed.

- [ ] **Step 2: Enter IAP display name**

Paste:

```text
Travel Tip Calculator Pro
```

Expected: App Store Connect accepts the value because it is 25 characters and under the 35-character limit.

- [ ] **Step 3: Enter IAP description**

Paste:

```text
No ads, trip history, and export tools.
```

Expected: App Store Connect accepts the value because it is 39 characters and under the 55-character limit.

## Task 4: Prepare Screenshot Captions

**Files:**
- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`

- [ ] **Step 1: Use the approved screenshot order**

Use these captions in order:

```text
Know What To Tip Anywhere
Smart Tips By Country
Split Every Bill Fast
Local Etiquette For 200+ Countries
Offline Tipping Data
Pro: Save And Export Trips
```

Expected: The screenshot story starts with the travel-confidence hook, then shows country intelligence, calculator utility, etiquette, offline data, and Pro value.

- [ ] **Step 2: Match screenshots to claims**

Verify each screenshot visibly supports its caption:

```text
Know What To Tip Anywhere -> calculator with selected country visible
Smart Tips By Country -> country-specific suggestion or country picker
Split Every Bill Fast -> split controls or group mode
Local Etiquette For 200+ Countries -> country detail etiquette screen
Offline Tipping Data -> country guide or saved bundled data concept
Pro: Save And Export Trips -> trip history or export UI
```

Expected: No screenshot caption promises a feature that is absent from the screenshot.

## Task 5: Set Categories And Final Review

**Files:**
- Read: `docs/superpowers/specs/2026-05-09-app-store-product-page-design.md`

- [ ] **Step 1: Set categories**

Set:

```text
Primary category: Travel
Secondary category: Utilities
```

Expected: Product category matches the app's differentiated travel use case while still recognizing the calculator utility.

- [ ] **Step 2: Final metadata length check**

Run:

```bash
node - <<'NODE'
const fields = {
  appName: 'Travel Tip Calculator',
  subtitle: 'Global Tipping Guide',
  promo: 'Know what to tip before the bill arrives. Get country-aware tipping guidance, fast bill splitting, offline access, and Pro trip history.',
  keywords: 'bill,splitter,restaurant,taxi,hotel,vacation,gratuity,etiquette,country,currency,offline,customs',
  iapName: 'Travel Tip Calculator Pro',
  iapDesc: 'No ads, trip history, and export tools.',
};
for (const [key, value] of Object.entries(fields)) {
  console.log(`${key}: ${value.length}`);
}
NODE
```

Expected:

```text
appName: 21
subtitle: 20
promo: 136
keywords: 96
iapName: 25
iapDesc: 39
```

- [ ] **Step 3: Submit only after release configuration is aligned**

Before final App Review submission, confirm:

```text
AdMob is configured if the listing promises ad removal.
In-app purchases are configured if the listing promises Pro.
Trip history is enabled if the listing promises trip history.
Export is enabled if the listing promises export tools.
PDF is not mentioned unless PDF export is implemented.
Offline wording is limited to bundled tipping data.
```

Expected: The product page copy matches the submitted build.

## Self-Review

Spec coverage:

- App name, subtitle, promotional text, keywords, description, IAP metadata, screenshot captions, categories, and launch-safety notes are all covered by tasks.

Placeholder scan:

- No placeholder markers or unspecified implementation steps are present.

Type and field consistency:

- Metadata values match the approved spec exactly.
- Character counts match the approved spec.
- Export wording avoids promising PDF.
