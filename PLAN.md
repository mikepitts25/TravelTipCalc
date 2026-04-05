# TravelTipCalc - Implementation Plan

## Context

Build a multi-platform travel tip calculator that suggests tip amounts based on the user's location and local tipping customs. The app differentiates from competitors (Ultimate Tip Calculator, Tip N Split, Gratuity, Tip Check) by being **offline-first**, having **non-intrusive ads**, **remembering user preferences per country**, and offering a **modern/fast UI**. Monetization through AdMob banner ads (free tier) and a one-time $4.99 Pro upgrade (ad-free + trip history export).

---

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | **Flutter 3.x (Dart)** | Single codebase for iOS/Android/Web, ~250ms cold start, native rendering |
| State Mgmt | **Riverpod** | Modern, testable, better than Provider for medium apps |
| Local DB | **SQLite (sqflite)** | Bundled tip data + user prefs + transaction history, zero network needed |
| Ads | **Google AdMob** | Banner ads only (bottom of screen), never during input |
| Purchases | **in_app_purchase** | One-time $4.99 Pro unlock |
| Location | **geolocator + geocoding** | Detect country/city from GPS |
| i18n | **intl** | Currency formatting, number localization |

---

## Feature Roadmap

### MVP (v1.0) - Target: 6-8 weeks
- [x] Tip calculator (bill amount -> suggested tip + total)
- [x] Location detection (auto-detect country via GPS)
- [x] Manual country/city picker (search + browse)
- [x] Bundled tipping database (200+ countries, 6 service categories)
- [x] Service type selector (restaurant, taxi, hotel, barber, tour guide, delivery)
- [x] Bill splitting (equal split, 2-20 people)
- [x] Smart rounding (round tip or total to nearest whole number)
- [x] Cultural etiquette tips per country (text blurbs)
- [x] Dark mode + light mode (system default + manual toggle)
- [x] Remember last tip % per country/service combo
- [x] AdMob banner ads (bottom, non-intrusive)
- [x] Pro IAP ($4.99 one-time, removes ads)
- [x] Settings screen (default tip %, preferred currency, theme)

### v1.1 - Post-launch (2-3 weeks after)
- [ ] Transaction history (save past tips with date/location/amount)
- [ ] Trip history export (CSV/PDF) - Pro feature
- [ ] Spending analytics (charts by country/category) - Pro feature
- [ ] Offline currency conversion (bundled rates, optional online refresh)
- [ ] Home screen widget (quick tip from last-used settings)
- [ ] Flashlight toggle (for reading bills in dark restaurants)

### v2.0 - Growth phase
- [ ] Receipt OCR scanning (camera -> auto-fill bill amount) - Pro feature
- [ ] Web version (Flutter web)
- [ ] Travel phrase packs (basic phrases in local language) - IAP
- [ ] Tip of the Day widget
- [ ] Cloud sync (optional, for multi-device users)

---

## Project Structure

```
travel_tip_calc/
├── android/                    # Android native config
├── ios/                        # iOS native config
├── lib/
│   ├── main.dart               # App entry point, theme, routing
│   ├── app.dart                # MaterialApp config, AdMob init
│   │
│   ├── config/
│   │   ├── theme.dart          # Light/dark theme definitions
│   │   ├── constants.dart      # App-wide constants
│   │   └── ad_config.dart      # AdMob unit IDs, ad placement config
│   │
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart       # SQLite init, migrations
│   │   │   └── tipping_data.dart       # Pre-seeded tipping data (200+ countries)
│   │   ├── models/
│   │   │   ├── country.dart            # Country model (name, code, region, currency)
│   │   │   ├── tipping_rule.dart       # TippingRule model (country, service, min%, max%, note)
│   │   │   ├── transaction.dart        # Transaction model (for history)
│   │   │   └── user_preferences.dart   # UserPreferences model
│   │   └── repositories/
│   │       ├── tipping_repository.dart # Query tip rules by country/service
│   │       ├── transaction_repository.dart
│   │       └── preferences_repository.dart
│   │
│   ├── providers/
│   │   ├── tip_calculator_provider.dart  # Core calculation logic + state
│   │   ├── location_provider.dart        # GPS location -> country resolution
│   │   ├── preferences_provider.dart     # User settings state
│   │   ├── purchase_provider.dart        # IAP state (free vs pro)
│   │   └── ad_provider.dart              # Ad loading/display state
│   │
│   ├── screens/
│   │   ├── calculator/
│   │   │   ├── calculator_screen.dart    # Main screen - bill input + tip result
│   │   │   └── widgets/
│   │   │       ├── bill_input.dart       # Bill amount entry (numpad)
│   │   │       ├── tip_result_card.dart  # Animated tip/total display
│   │   │       ├── service_selector.dart # Service type chips
│   │   │       ├── split_control.dart    # People count +/- stepper
│   │   │       └── country_badge.dart    # Current country indicator
│   │   ├── country_picker/
│   │   │   ├── country_picker_screen.dart # Search + browse countries
│   │   │   └── widgets/
│   │   │       └── country_tile.dart
│   │   ├── country_detail/
│   │   │   └── country_detail_screen.dart # Tipping guide + etiquette for a country
│   │   ├── history/
│   │   │   └── history_screen.dart        # Transaction list (v1.1)
│   │   ├── settings/
│   │   │   └── settings_screen.dart       # Preferences, theme, pro upgrade
│   │   └── pro/
│   │       └── pro_upgrade_screen.dart    # Pro purchase pitch
│   │
│   ├── services/
│   │   ├── location_service.dart   # Geolocator wrapper
│   │   ├── purchase_service.dart   # IAP wrapper (StoreKit/Play Billing)
│   │   └── ad_service.dart         # AdMob lifecycle management
│   │
│   └── utils/
│       ├── currency_formatter.dart # Format amounts per locale
│       ├── tip_calculator.dart     # Pure calculation functions (testable)
│       └── rounding.dart           # Smart rounding helpers
│
├── assets/
│   └── data/
│       └── tipping_data.json       # Seed data: 200+ countries, service rules
│
├── test/
│   ├── unit/
│   │   ├── tip_calculator_test.dart
│   │   ├── rounding_test.dart
│   │   └── tipping_repository_test.dart
│   ├── widget/
│   │   ├── calculator_screen_test.dart
│   │   └── bill_input_test.dart
│   └── integration/
│       └── full_flow_test.dart
│
├── pubspec.yaml
└── README.md
```

---

## Data Model

### `countries` table
| Column | Type | Example |
|--------|------|---------|
| id | TEXT (ISO 3166-1 alpha-2) | "US" |
| name | TEXT | "United States" |
| region | TEXT | "North America" |
| currency_code | TEXT | "USD" |
| currency_symbol | TEXT | "$" |
| service_included | BOOL | false |
| etiquette_note | TEXT | "Tipping is expected and a major part of service workers' income..." |

### `tipping_rules` table
| Column | Type | Example |
|--------|------|---------|
| id | INTEGER (PK) | 1 |
| country_id | TEXT (FK) | "US" |
| service_type | TEXT | "restaurant" |
| min_percent | REAL | 15.0 |
| max_percent | REAL | 20.0 |
| suggested_percent | REAL | 18.0 |
| note | TEXT | "15% for adequate service, 20%+ for excellent" |

**Service types**: restaurant, taxi, hotel_bellhop, hotel_housekeeping, barber, tour_guide, delivery, bar, spa, valet

### `transactions` table (v1.1)
| Column | Type |
|--------|------|
| id | INTEGER (PK) |
| date | TEXT (ISO 8601) |
| country_id | TEXT (FK) |
| service_type | TEXT |
| bill_amount | REAL |
| tip_percent | REAL |
| tip_amount | REAL |
| total_amount | REAL |
| split_count | INTEGER |
| currency_code | TEXT |
| note | TEXT |

### `user_preferences` table
| Column | Type |
|--------|------|
| key | TEXT (PK) |
| value | TEXT |

Keys: `theme`, `default_tip_percent`, `last_country`, `is_pro`, `last_tip_{countryId}_{serviceType}`

---

## Screen Flow / Navigation

```
App Launch
    │
    ▼
Calculator Screen (home)  ←──── Main tab
    ├── Country Badge (tap) ───→ Country Picker Screen
    │                                 └── Country Detail Screen (etiquette guide)
    ├── Service Type Chips
    ├── Bill Amount Input (numpad)
    ├── Tip Result Card (animated)
    ├── Split Control
    └── [Banner Ad - bottom, free tier only]

Bottom Navigation (3 tabs):
    ├── Calculator (home)
    ├── Explore (country browser + tipping guide)
    └── Settings
         ├── Theme toggle
         ├── Default tip %
         ├── Pro upgrade button
         └── About / Rate app
```

---

## Monetization Integration Points

### Free Tier
- **Banner ad**: Persistent bottom banner on Calculator screen (below results, never overlapping input)
- **Banner ad**: Bottom of Country Picker screen
- **No ads** on: Settings, Country Detail (keep educational content clean)
- **No interstitials ever** (key differentiator - competitors get destroyed in reviews for this)

### Pro Tier ($4.99 one-time)
- All ads removed
- Transaction history (save/view past tips)
- Export history as CSV or PDF
- Badge/icon indicating Pro status
- Implemented via `in_app_purchase` package (StoreKit on iOS, Play Billing on Android)

### Future Monetization (v2+)
- Travel phrase packs: $0.99 each (Japanese, Spanish, French, etc.)
- Premium themes: $1.99 theme pack
- Receipt OCR: Could be Pro-only or separate $1.99 IAP

---

## Key Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0       # State management
  sqflite: ^2.3.0                 # Local SQLite database
  path: ^1.9.0                    # DB path resolution
  geolocator: ^12.0.0             # GPS location
  geocoding: ^3.0.0               # Reverse geocode -> country
  google_mobile_ads: ^5.0.0       # AdMob banner ads
  in_app_purchase: ^3.2.0         # Pro IAP
  intl: ^0.19.0                   # Currency/number formatting
  shared_preferences: ^2.2.0      # Simple key-value prefs
  go_router: ^14.0.0              # Declarative routing
  flutter_animate: ^4.5.0         # Smooth animations
  google_fonts: ^6.2.0            # Modern typography

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0                # Mocking for tests
  flutter_lints: ^4.0.0           # Lint rules
```

---

## UI/UX Design Principles

1. **One-screen experience**: Calculator is the entire app for 90% of use cases
2. **Big, tappable numpad**: Custom numpad for bill entry (not system keyboard)
3. **Animated result**: Tip amount animates as you type (real-time calculation)
4. **Country auto-detected**: Shows flag + country name badge, one tap to change
5. **Dark by default**: Restaurants are dark - dark mode should be the default
6. **Color palette**: Deep navy/charcoal with accent gold/amber for tip amounts
7. **Haptic feedback**: Light haptics on numpad taps and tip result changes
8. **Sub-second**: Everything happens instantly - no loading spinners, no network waits

---

## Tipping Data Coverage

The bundled `tipping_data.json` will cover 200+ countries with data for up to 10 service categories each. Key regions:

| Region | Countries | Typical Range |
|--------|-----------|---------------|
| North America | US, CA, MX | 15-20% (US/CA), 10-15% (MX) |
| Western Europe | UK, FR, DE, ES, IT, NL, etc. | 0-10% (often included) |
| Eastern Europe | PL, CZ, HU, RO, etc. | 5-10% |
| East Asia | JP, KR, CN, TW | 0% (not expected/offensive) |
| Southeast Asia | TH, VN, ID, PH, MY, SG | 0-15% (varies) |
| Middle East | AE, SA, QA, JO, EG | 10-20% |
| South America | BR, AR, CO, PE, CL | 10-15% |
| Africa | ZA, KE, TZ, MA, NG | 10-15% |
| Oceania | AU, NZ | 0-10% (not expected) |

Each country entry includes:
- Flag emoji, name, ISO code, region
- Currency code + symbol
- Whether service charge is typically included
- Cultural etiquette note (2-3 sentences)
- Per-service-type: min%, max%, suggested%, specific note

---

## Testing Strategy

### Unit Tests
- `tip_calculator_test.dart`: Pure math - bill * percent, splitting, rounding edge cases
- `rounding_test.dart`: Smart rounding (round up to nearest $1, $5, etc.)
- `tipping_repository_test.dart`: Query rules by country + service type

### Widget Tests
- Calculator screen: Enter bill -> verify tip display updates
- Country picker: Search + select -> verify calculator updates
- Service selector: Tap different services -> verify tip changes

### Integration Tests
- Full flow: Launch -> auto-detect location -> enter bill -> see tip -> change country -> see updated tip
- Pro upgrade flow: Tap upgrade -> mock purchase -> verify ads disappear

### Manual Testing Checklist
- Test on iOS simulator + Android emulator
- Test location permissions (granted, denied, disabled)
- Test offline mode (airplane mode)
- Test dark/light theme switching
- Verify ad placement doesn't overlap content
- Test IAP in sandbox environment

---

## App Store Considerations

### iOS (App Store)
- Privacy nutrition labels: Location (when in use), no tracking
- App Review: Ensure AdMob complies with Apple guidelines
- IAP: Must use Apple's in-app purchase (no external payment links)
- Screenshots: iPhone 6.7", iPhone 6.5", iPad 12.9"

### Android (Google Play)
- Target API level 34+
- Data safety section: Location data collected for functionality
- Play Billing Library v6+ required
- Screenshots: Phone + 7" tablet + 10" tablet

### Both
- App name: "TravelTipCalc - Tip Calculator"
- Category: Travel / Finance
- Keywords: tip calculator, tipping guide, travel tips, bill splitter, gratuity
- Age rating: 4+ / Everyone

---

## Implementation Order

1. **Flutter project scaffold** - `flutter create`, package setup, folder structure
2. **Tipping database** - Create JSON seed data, SQLite schema, repository layer
3. **Core calculator logic** - Pure Dart tip math functions + unit tests
4. **Calculator UI** - Main screen with numpad, tip display, service selector
5. **Country picker** - Search/browse countries, detail screen with etiquette
6. **Location detection** - GPS -> country auto-detection
7. **Preferences** - Remember tip % per country, theme, settings screen
8. **AdMob integration** - Banner ads on calculator + country picker
9. **Pro IAP** - Purchase flow, ad removal logic
10. **Polish** - Animations, haptics, dark mode refinement, app icons
11. **Testing** - Unit + widget + integration tests
12. **App store prep** - Screenshots, descriptions, privacy policies, submission
