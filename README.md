# TravelTipCalc

A modern, offline-first travel tip calculator built with Flutter. Suggests tip amounts based on your location and local tipping customs for 200+ countries.

## Key Features

- **Auto-detect location** - GPS determines your country, suggests the right tip percentage
- **200+ countries** - Tipping rules for restaurant, taxi, hotel, barber, tour guide, delivery, and more
- **Bill splitting** - Split evenly among 2-20 people
- **Smart rounding** - Round tip or total to nearest whole number
- **Cultural etiquette** - Learn tipping customs and cultural notes per country
- **Remembers your preferences** - Last tip % saved per country and service type
- **Dark mode** - Default dark theme, perfect for restaurants
- **100% offline** - Works without internet, all data bundled locally
- **Non-intrusive ads** - Banner only, never full-screen interruptions

## Monetization

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Full calculator + banner ads |

Paid upgrades and trip history are deferred. The current release focus is the free calculator experience with non-intrusive banner ads.

## Tech Stack

- **Framework**: Flutter (Dart) - iOS, Android, Web from single codebase
- **State Management**: Riverpod
- **Database**: SQLite (sqflite) - bundled tipping data, no cloud required
- **Ads**: Google AdMob (banner only)
- **Location**: geolocator + geocoding

## Getting Started

```bash
# Prerequisites: Flutter SDK 3.x installed
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # MaterialApp, theme, routing
├── config/                    # Theme, constants, ad config
├── data/
│   ├── database/              # SQLite setup, seed data
│   ├── models/                # Country, TippingRule
│   └── repositories/          # Data access layer
├── providers/                 # Riverpod state providers
├── screens/
│   ├── calculator/            # Main calculator screen + widgets
│   ├── country_picker/        # Browse/search countries
│   ├── country_detail/        # Etiquette guide per country
│   └── settings/              # User preferences
├── services/                  # Location and ad services
└── utils/                     # Calculator math, formatting, rounding
```

See [PLAN.md](PLAN.md) for the full implementation plan.
