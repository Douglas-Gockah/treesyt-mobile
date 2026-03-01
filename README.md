# TreeSyt Mobile

Flutter mobile app for field data collection.
Field agents use this app to fill in deployed forms **offline** — responses are
saved locally and synced to the server when a connection is available.

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | ≥ 3.22 |
| Dart | ≥ 3.3 |
| Android Studio / Xcode | For device emulators |

---

## First-time setup

```bash
# 1. Create the Flutter scaffold (run once — do NOT override existing files)
flutter create --project-name treesyt_mobile --org com.treesyt .

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device / emulator
flutter run
```

> **Why `flutter create` first?**
> This repo contains only the `lib/` source files and `pubspec.yaml`.
> `flutter create` generates the platform-specific folders
> (`android/`, `ios/`, `web/`) that are `.gitignore`d from this repo.

---

## Project layout

```
mobile/
├── pubspec.yaml
└── lib/
    ├── main.dart                      # App entry point
    ├── app_theme.dart                 # Colour constants + ThemeData
    ├── models/
    │   ├── models.dart                # Form, Question, SurveyResponse types
    │   └── mock_data.dart             # Seeded mock forms (8 forms)
    ├── services/
    │   └── storage_service.dart       # Hive offline storage
    ├── screens/
    │   ├── home_screen.dart           # Home (module list)
    │   ├── forms_screen.dart          # Forms tabs (Forms list | Google forms)
    │   └── survey_screen.dart         # Survey questions + Save
    └── widgets/
        └── question_renderer.dart     # All 18 question type renderers
```

---

## Screen flow

```
HomeScreen
  └── tap "Forms" module
        └── FormsScreen  (DefaultTabController)
              ├── Tab 1: Forms list  →  tap a row  →  SurveyScreen
              └── Tab 2: Google forms  (empty state placeholder)
```

---

## Question types implemented

| Type | UI widget |
|---|---|
| `short-text` | Single-line TextField |
| `long-text` | Multi-line TextField (4 rows) |
| `number` | Numeric keyboard TextField |
| `decimal` | Decimal keyboard TextField |
| `multiple-choice` | DropdownButton |
| `checkbox` | CheckboxListTile (multi-select) |
| `yes-no` | Radio button pair |
| `date` | DatePicker dialog |
| `datetime` | DatePicker + TimePicker dialog |
| `time` | TimePicker dialog |
| `month` | ChoiceChip grid |
| `day-of-week` | Circle chip row |
| `auto-id` | Read-only generated ID field |
| `image` | Placeholder (TODO: image_picker) |
| `audio` | Placeholder (TODO: record package) |
| `location` | Placeholder (TODO: geolocator) |
| `barcode` | Outlined scan button (TODO: mobile_scanner) |
| `farmer-name` | Autocomplete with mock farmer list |

---

## Offline storage

Responses are saved to a **Hive** box (`survey_responses`) immediately on
"Save survey".  Each response carries a `synced: false` flag.

When backend sync is implemented, call:

```dart
await StorageService.instance.markSynced(responseId);
```

after a successful API upload.

---

## Connecting to the web app's API

Replace `kMockForms` in `lib/models/mock_data.dart` with a fetch from the
Next.js backend (e.g. `GET /api/forms?status=live`).  The `FormModel` and
`Question` types mirror the web app's TypeScript types exactly.

---

## TODO (next phases)

- [ ] Real camera capture via `image_picker`
- [ ] Audio recording via `record`
- [ ] GPS location via `geolocator`
- [ ] Barcode / QR scanning via `mobile_scanner`
- [ ] Farmer lookup via API search
- [ ] Background sync when network returns
- [ ] Saved responses list screen
- [ ] Google Forms tab (embed WebView)
