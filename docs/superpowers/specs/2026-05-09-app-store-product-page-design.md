# App Store Product Page Design

Date: 2026-05-09
Locale: US English
App: Travel Tip Calculator

## Goal

Set up the App Store product page metadata for a travel-focused tip calculator that helps users know what to tip with confidence when they are abroad. The product page should be App Store SEO friendly, accurate to the current app direction, and ready to paste into App Store Connect.

## Positioning

Use the "Travel Confidence" direction:

Travel Tip Calculator is for travelers who want to quickly understand what is customary, calculate the right amount, split the bill, and avoid awkward payment moments while traveling.

Primary hook:

Know what to tip anywhere.

Supporting proof points:

- Country-specific tipping guidance for 200+ countries
- Service-specific tip ranges and etiquette notes
- Fast bill, tip, and split calculations
- Offline bundled tipping data
- Optional Pro upgrade with ad removal, trip history, and export tools

## App Store Metadata

### App Name

Travel Tip Calculator

Character count: 21 / 30

Rationale: The name directly targets high-intent searches while staying clear and readable. It avoids the previous compressed brand name and makes the core utility immediately obvious.

### Subtitle

Global Tipping Guide

Character count: 20 / 30

Rationale: The subtitle differentiates the app from generic tip calculators by emphasizing travel and country-aware guidance. It also avoids repeating "tip" in the exact same form as the app name too many times while still reinforcing the search theme.

### Promotional Text

Know what to tip before the bill arrives. Get country-aware tipping guidance, fast bill splitting, offline access, and Pro trip history.

Character count: 136 / 170

Rationale: The promotional text leads with the confidence hook, then quickly lists the main user benefits. It is suitable for time-sensitive updates because Apple allows promotional text to be updated without submitting a new app version.

### Keywords

bill,splitter,restaurant,taxi,hotel,vacation,gratuity,etiquette,country,currency,offline,customs

Character count: 96 / 100

Rationale: The keyword list avoids repeating words already covered by the app name and subtitle, especially "travel", "tip", "calculator", "global", and "guide". It targets bill splitting, hospitality use cases, gratuity terminology, etiquette, country context, currency, offline use, and travel customs.

### Description

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

## In-App Purchase Metadata

### Display Name

Travel Tip Calculator Pro

Character count: 25 / 35

### Description

No ads, trip history, and export tools.

Character count: 39 / 55

## Screenshot Story

Recommended screenshot order:

1. Know What To Tip Anywhere
2. Smart Tips By Country
3. Split Every Bill Fast
4. Local Etiquette For 200+ Countries
5. Offline Tipping Data
6. Pro: Save And Export Trips

Rationale: The first screenshot should sell the emotional promise, not just the calculator UI. The sequence then supports that promise with country intelligence, utility, etiquette, offline reliability, and Pro value.

## Categories

Primary category: Travel

Secondary category: Utilities

Rationale: Travel is the strongest market fit because the product's differentiated value is knowing local tipping customs abroad. Utilities is appropriate as the secondary category because the app is still a calculator and bill-splitting tool.

## Accuracy Notes

- Do not promise PDF export in the App Store listing unless PDF export is implemented before submission.
- The current copy uses "export" without specifying file format, which is safer because CSV export is visible in the app code.
- If ads and in-app purchases are not fully configured before submission, remove or soften the Pro and ad-removal claims before submitting.
- "Offline" refers to bundled tipping data. Currency exchange refresh depends on network access and should not be presented as fully offline.

## App Store Connect Checklist

- App name: Travel Tip Calculator
- Subtitle: Global Tipping Guide
- Promotional text: paste from this spec
- Keywords: paste from this spec
- Description: paste from this spec
- Primary category: Travel
- Secondary category: Utilities
- In-app purchase display name: Travel Tip Calculator Pro
- In-app purchase description: No ads, trip history, and export tools.
- Screenshot captions: use the recommended order above

## Source Context

This spec is based on the current repository context:

- `README.md`: offline-first travel tip calculator for 200+ countries
- `assets/data/tipping_data.json`: 203 country entries
- `lib/screens/calculator/calculator_screen.dart`: country-aware calculator, service selection, bill splitting, trip save flow
- `lib/screens/country_detail/country_detail_screen.dart`: tipping etiquette and service rules
- `lib/screens/history/history_screen.dart`: Pro trip history and CSV export UI
- `lib/services/exchange_rate_service.dart`: network-backed exchange rate refresh with local cache

Apple field limit references checked on 2026-05-09:

- App name and subtitle: 30 characters each
- Keywords: 100 characters
- Promotional text: 170 characters
- Description: 4000 characters
