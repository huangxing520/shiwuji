# ShiWuJi (拾物记)

Sponsored by [<img src="https://images.typeform.com/images/QKuaAssrFCq7/image/default-firstframe.png" width="40" alt="Bugsnag" valign="middle">](https://www.bugsnag.com)

[English](README.md) | [简体中文](README.zh-CN.md)

A Flutter-based home inventory management app that helps you record where items are stored, categorize them, and track warranty status — with AI photo recognition, e-commerce order batch import, and WebDAV cloud backup.

## Features

- **AI Photo Recognition**: Snap a photo and AI auto-fills the name, brand, and category. 18+ AI providers supported.
- **Item Management**: Record name, price, category, storage location, purchase date, warranty days, photo, brand, notes, and more.
- **Spatial Hierarchy**: Room → Cabinet → Slot → Item, a four-level structure for precise localization.
- **Warranty Tracking**: Auto-computes expiry; home page surfaces expiring-soon, expired, and in-warranty stats.
- **Categories**: 12 built-in categories (Digital, Appliance, Skincare, Kitchen, Clothing, Books, Storage, Toys, Sports, Stationery, Keys, Tools) with custom extension support.
- **Order Import**: One-tap import from e-commerce platforms to batch-generate item records.
- **Stat Cards**: Home page shows total item count, total asset value (with thousands separators), this week's additions, and this month's growth.
- **Inventory Filtering**: Filter by category / warranty status; sort by time / price / expiry date.
- **Storage Management**: Three-tier management of rooms, cabinets, and slots with real-time occupancy.
- **WebDAV Backup**: Connect any WebDAV service (Jianguoyun, Nextcloud, etc.) for database backup and restore.
- **Update Checker**: Pulls latest release info from GitHub Releases, prompts in-app, and opens the browser to download.
- **Local Notifications**: Reminders for warranty expiry.
- **Data Encryption**: Database encryption based on PBKDF2 + AES.
- **Multi-Platform**: Android / iOS / Windows / Linux / Web.

## Tech Stack

| Area            | Choice                                          |
| --------------- | ----------------------------------------------- |
| Framework       | Flutter / Dart                                  |
| State Management| Riverpod + riverpod\_annotation (codegen)       |
| Routing         | go\_router (StatefulShellRoute bottom nav)      |
| Networking      | dio (unified interceptors, error handling)      |
| Local Storage   | drift (type-safe SQLite ORM)                    |
| Cloud Backup    | webdav\_client                                  |
| Data Models     | freezed + json\_serializable                    |
| Notifications   | flutter\_local\_notifications                   |
| Encryption      | crypto (PBKDF2 + AES-256)                       |
| Images          | image\_picker + photo\_view                     |
| Version Info    | package\_info\_plus                             |
| Browser Launch  | url\_launcher                                   |

## Directory Structure

```
lib/
├── main.dart                     # App entry
├── app_router.dart               # Routing (5 tabs + detail/edit sub-routes)
├── constants/                    # Theme colors, font sizes, shadows, input styles
├── database/                     # drift database definitions
│   ├── database.dart             # DB instance, migration strategy, seed init
│   ├── seed_data.dart            # First-install seed data (3 rooms / 3 cabinets / 3 slots / 12 categories)
│   └── tables/                   # 8 table definitions (Items/Rooms/Cabinets/Slots/...)
├── daos/                         # Data access layer (one DAO per table)
├── models/                       # freezed data models + enums
│   └── enums/                    # ItemStatus / SortType / TabType / PendingCardType
├── providers/                    # Riverpod state providers
├── services/                     # Business services
│   ├── ai/                       # AI recognition service
│   │   ├── ai_provider.dart      # Abstract base class
│   │   ├── ai_provider_registry.dart  # Provider registry
│   │   ├── ai_provider_type.dart # Provider enum
│   │   ├── ai_models.dart        # AI response models
│   │   └── providers/            # 18+ AI provider implementations
│   ├── http_service.dart         # dio wrapper
│   ├── update_service.dart       # GitHub Releases version check
│   ├── webdav_service.dart       # WebDAV backup/restore
│   ├── encryption_service.dart   # PBKDF2 + AES encryption
│   ├── notification_service.dart # Local notifications
│   ├── photo_service.dart        # Camera / gallery picker
│   └── prompt_service.dart       # AI prompt management
├── screen/                       # Pages
│   ├── home/                     # Home (stat cards, pending, recent additions)
│   ├── inventory/                # Inventory (filter, sort, list)
│   ├── storage/                  # Storage management
│   ├── me/                       # Profile (backup, notifications, AI settings, update check)
│   ├── scan/                     # AI photo recognition
│   └── order_import/             # E-commerce order import
└── widgets/                      # Reusable UI components (20+)
```

## Getting Started

### Prerequisites

- Flutter 3.44+
- Dart 3.11+
- Android Studio / Xcode (mobile builds)
- CMake + Visual Studio Build Tools (Windows desktop builds)

### Install & Run

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Generate code (freezed / json_serializable / drift / riverpod)
dart run build_runner build

# 3. Run
flutter run
```

### Code Generation

Re-run after editing `models/`, `database/tables/`, or `providers/`:

```bash
dart run build_runner build

# Watch mode for development
dart run build_runner watch
```

## Testing

```bash
flutter test                                  # All tests
flutter test test/services/                   # Service-layer tests only
flutter test --coverage                       # Generate coverage report
```

## Release Builds

### Android

```bash
flutter build apk --split-per-abi             # Per-ABI APKs
flutter build appbundle                       # AAB (Play Store)
```

Signing config lives in `android/key.properties` (not committed), read by `android/app/build.gradle.kts`.

### Windows / Linux / Web

```bash
flutter build windows
flutter build linux
flutter build web --release
```

## License

This project is licensed under the [MIT License](LICENSE).
