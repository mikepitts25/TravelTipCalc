# Travel Tip Calculator App Store Launch Kit

Date: 2026-05-25
Locale: US English
Release assumption: first public App Store release of the current free, ad-supported Flutter app.

## Key Submission Decision

Do not mention Pro, in-app purchases, trip history, or export in this launch listing. The current app code supports the calculator, country guide, group splitting, location-based country selection, home-currency display, theme settings, and banner ads. Pro, trip history, and export are not present in `lib/` for this build.

## App Store Connect Fields

Put these in App Store Connect > Apps > Travel Tip Calculator > App Information and the iOS app version page.

### Name

```text
Travel Tip Calculator
```

21 / 30 characters.

### Subtitle

```text
Bill Splitter & Etiquette
```

25 / 30 characters.

ASO rationale: the app name already covers `Travel`, `Tip`, and `Calculator`. This subtitle adds high-intent terms for `bill splitter` and `etiquette` without wasting subtitle space on duplicate title words.

### Promotional Text

```text
Know what to tip before the bill arrives. Get country-aware tipping guidance, bill splitting, offline data, and local etiquette.
```

128 / 170 characters.

### Keywords

```text
gratuity,restaurant,taxi,hotel,vacation,currency,offline,customs,country,guide,bar,spa,abroad,dining
```

100 / 100 bytes.

ASO rationale: no spaces, no competitor names, no plurals, and no repeats from the app name, subtitle, company name, or Travel category. These terms target service-specific and travel-context searches while the title/subtitle provide the core phrases: `travel tip calculator`, `tip calculator`, `bill splitter`, and `tipping etiquette`.

### Description

```text
Travel Tip Calculator helps you know what to tip with confidence wherever you travel.

Get country-aware tip suggestions, bill splitting, and local tipping etiquette in one fast calculator. Whether you are at a restaurant, in a taxi, checking into a hotel, ordering delivery, visiting a spa, using valet, visiting a barber, sitting at a bar, or joining a tour, Travel Tip Calculator helps you understand what is customary before the bill arrives.

Features:
- Country-specific tipping guidance for 200+ countries
- Suggested tip ranges by service type
- Restaurant, taxi, hotel, delivery, bar, spa, valet, barber, tour guide, and more
- Fast bill and tip calculator
- Split totals between multiple people
- Group mode for itemized shared bills
- Smart rounding for cleaner totals
- Home-currency display for travel context
- Local tipping etiquette notes by country
- Works offline with bundled tipping data
- Saves your preferred tip choices by country and service
- Dark and light themes

Travel Tip Calculator is designed for travelers who want to be respectful, prepared, and quick at the moment of payment.
```

### What's New

For first public version, App Store Connect may not show this field. If it does, use:

```text
Initial App Store release with country-aware tip suggestions, bill splitting, service-specific tipping guidance, and offline tipping data for 200+ countries.
```

### Categories

```text
Primary: Travel
Secondary: Utilities
```

### Age Rating

Recommended answers should produce `4+`, assuming the app contains no user-generated content, mature content, gambling, unrestricted web access, medical content, or purchases in this release.

### Copyright

Use your legal developer name or company. Format:

```text
2026 Colibri Code
```

Replace `Colibri Code` if the Apple developer account uses a different legal owner.

## Screenshot Plan

Apple allows 1-10 screenshots per device size. For this universal iPhone/iPad app, prepare both:

- iPhone 6.9" screenshots, portrait, preferably `1320 x 2868` or another Apple-accepted 6.9" size.
- iPad 13" screenshots, portrait, `2048 x 2732` or `2064 x 2752`.

Use 6 screenshots per device. Capture real app screens from the App Store build or an equivalent release build, then add clean marketing captions above the device screenshot. Screenshots must show the app in use, not only title art.

ASO priority: the first three portrait screenshots are the most important because they may appear directly in App Store search results. Make those three readable at small size and focused on the highest-intent promise: travel tip calculator, country guidance, and bill splitting.

### Screenshot 1

Caption:

```text
Travel Tip Calculator
```

Screen to capture: Calculator screen with a recognizable travel country selected, bill entered, and tip/total visible.

Suggested demo state: France, restaurant, bill 86.40, suggested tip visible.

### Screenshot 2

Caption:

```text
Tips By Country
```

Screen to capture: Calculator screen or country picker showing country selection and service-specific guidance.

Suggested demo state: Japan or Italy with an etiquette note that makes the country-specific value obvious.

### Screenshot 3

Caption:

```text
Bill Splitter For Groups
```

Screen to capture: Solo calculator with split control, or group mode if it looks more impressive.

Suggested demo state: 4 people, rounded total, clear per-person amount.

### Screenshot 4

Caption:

```text
Tipping Etiquette Abroad
```

Screen to capture: Country detail screen with `Tipping Etiquette` and service rules visible.

Suggested demo state: United States, France, Japan, or another country with helpful notes.

### Screenshot 5

Caption:

```text
Guide For 200+ Countries
```

Screen to capture: Country picker with search and a visible list of countries/regions.

Suggested demo state: Search cleared, list showing multiple countries and flags.

### Screenshot 6

Caption:

```text
Restaurant, Taxi, Hotel & More
```

Screen to capture: Calculator screen in dark mode with a restaurant bill scenario and banner ad either hidden by crop/framing or clearly not obstructing the app.

Suggested demo state: Spain, restaurant, bill 124.00, split 2.

## Screenshot Production Notes

- Use dark mode for most screenshots because this app is optimized for restaurant use and the UI looks distinctive.
- Keep captions short, high contrast, and consistent. Avoid paragraphs.
- Use the first three screenshots as search-result ads: each should still make sense when tiny.
- Build or run the screenshot capture build with `--dart-define=HIDE_ADS_FOR_SCREENSHOTS=true` so the banner slot is hidden while taking App Store screenshots.
- Do not show personal data, real locations, real ad creatives, or TestFlight chrome.
- If using simulator screenshots, set a clean status bar and consistent time.
- Do not show unavailable features such as Pro, export, PDF, subscriptions, or trip history.
- Since the iOS target supports iPad, upload iPad screenshots too unless you intentionally remove iPad support in a new build.

## ASO Rules And Growth Plan

Use these rules for launch and future updates:

- Keep the app name literal. `Travel Tip Calculator` is stronger for search than a branded name because it contains the highest-intent query.
- Do not repeat title, subtitle, category, or company words in the keyword field. Repetition wastes the 100-byte keyword limit.
- Do not use competitor app names, protected brand names, irrelevant categories, or hidden feature claims. They can hurt review and attract the wrong users.
- Promotional text is for conversion, not ranking. Do not stuff keywords there.
- The description should read naturally for humans and web search. It should repeat the core phrase only where it sounds normal.
- The first three screenshots should be treated like search-result creative, not just product-page art.
- After launch, watch App Analytics weekly: App Store search impressions, product page views, conversion rate, downloads, crashes, ratings, and review text.
- Ask for ratings only after successful use, such as after several completed calculations or country lookups. Do not ask on first launch.
- Add localizations after the US listing is live. Best first targets for this app: Spanish, French, German, Italian, Japanese, and British English. Localized app metadata can help users search in their own language and region.

### ASO Test Backlog

Run one test at a time so results are interpretable:

1. Screenshot test: current dark-mode set vs. brighter travel-colored set.
2. Screenshot test: `Travel Tip Calculator` first screenshot vs. `Know What To Tip Abroad`.
3. Subtitle test in the next version: `Bill Splitter & Etiquette` vs. `Tip Guide & Bill Splitter`.
4. Keyword test in the next version: service terms (`restaurant,taxi,hotel,bar,spa`) vs. travel terms (`abroad,vacation,country,customs,currency`).
5. Once there is enough traffic, try Apple Product Page Optimization for screenshots or app icon treatments.

## App Review Notes

Put this in the App Review Information > Notes field:

```text
No account or login is required.

The app is a travel tip calculator with bundled tipping guidance for 200+ countries. Location permission is optional and is used only to suggest the current country; users can manually choose a country if they deny permission.

The app uses banner ads on the calculator screen. Ads are not required to use the calculator.
```

## Privacy And Support

Apple requires a Privacy Policy URL and Support URL. Publish simple pages on your website before submission.

### Support Page Copy

```text
Travel Tip Calculator Support

For help, feedback, or bug reports, contact:
support@YOURDOMAIN.com

When reporting an issue, include your device model, iOS version, app version, and a short description of what happened.
```

### Privacy Policy Draft

This is a practical draft, not legal advice. Replace the email/domain and align it with the exact AdMob privacy disclosures you select in App Store Connect.

```text
Privacy Policy for Travel Tip Calculator

Effective date: May 25, 2026

Travel Tip Calculator helps travelers calculate tips and understand local tipping customs.

Information the app uses

Location: If you grant location permission, the app uses your device location to determine the country you are in and suggest relevant tipping guidance. You can deny location access and choose a country manually. The app does not require an account.

Preferences: The app stores preferences such as selected country, theme, home currency, and recent tip choices on your device.

Ads: The app displays banner ads using Google AdMob. AdMob may collect device identifiers, usage data, diagnostics, and other information according to Google's policies in order to provide, measure, and improve ads.

Offline data

Tipping guidance is bundled with the app and can be used offline. Some supporting features, such as ad loading or exchange-rate refreshes, may require an internet connection.

Contact

For privacy questions, contact support@YOURDOMAIN.com.
```

### Likely App Privacy Areas To Review

Answer App Store Connect privacy questions based on the actual production build and Google AdMob configuration. Review at least:

- Location, because the app requests location permission for country detection.
- Identifiers, usage data, diagnostics, and advertising data, because the app integrates Google Mobile Ads.
- Whether any data is used for tracking, depending on your AdMob settings and ATT behavior.
- Contact information only if your support flow collects email outside the app.

## Submission Checklist

1. Confirm the App Store build is not using Google test ad units. Production iOS ad unit should be passed with `ADMOB_IOS_BANNER_AD_UNIT_ID`.
2. Do not submit a production build with `HIDE_ADS_FOR_SCREENSHOTS=true`; that flag is only for screenshot capture.
3. Confirm the App Store build number is higher than the TestFlight build you intend to submit.
4. Confirm the app icon exists in App Store Connect and matches `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`.
5. Publish the privacy policy and support pages.
6. Fill App Privacy in App Store Connect.
7. Enter App Information: name, subtitle, category, age rating, copyright, privacy URL.
8. Open the iOS version page and paste promotional text, description, keywords, support URL, and optional marketing URL.
9. Upload iPhone 6.9" screenshots.
10. Upload iPad 13" screenshots.
11. Select the exact TestFlight build in the Build section.
12. Set release mode. Recommended for first launch: manual release after approval.
13. Fill App Review contact info and notes.
14. Add for Review.
15. Open Draft Submissions and click Submit for Review.

## Source Notes

Current implementation checked:

- `assets/data/tipping_data.json`: 203 countries.
- `lib/screens/calculator/calculator_screen.dart`: calculator, country-aware rules, service selector, split, group mode.
- `lib/screens/country_picker/country_picker_screen.dart`: country search/list.
- `lib/screens/country_detail/country_detail_screen.dart`: etiquette and service rules.
- `lib/widgets/ad_banner_slot.dart` and `lib/config/ad_config.dart`: banner ads.
- `lib/services/location_service.dart`: optional location-based country detection.
- `ios/Runner.xcodeproj/project.pbxproj`: universal iPhone/iPad target.

Apple references checked on 2026-05-25:

- App Store Connect platform metadata limits: https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- Upload previews and screenshots: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- Submit an app: https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app
- App privacy: https://developer.apple.com/help/app-store-connect/reference/app-information/app-privacy/
- App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
