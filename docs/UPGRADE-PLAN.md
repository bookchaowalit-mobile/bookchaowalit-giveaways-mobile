# Upgrade Plan — Giveaways Mobile

## Current state

Score: 7.5/10 — fair secure draw with robust entrant de-duplication, phone-width text-scale and a11y guideline tests, fail-closed signing; no persistence/audit history, icon or E2E flow yet.

## Backlog

### P0
- None open. (Release signing now fails closed without `android/key.properties`.)

### P1
- Persist the entrant list and draw history so a draw can be audited later.
- Share/export winners.
- Replace the template launcher icon with a real app icon (the application ID `com.bookchaowalit.*` is already set).
- Add a Maestro smoke flow for the main journey.
- Add a CI job that builds a signed release bundle from repository secrets (keystore decoded at runtime, never committed).

### P2
- Tablet layout (NavigationRail).
- Localisation (Thai/English) for UI strings.

## Done in this pass (pass 3)

- Bug fix (accessibility): the winners/draw row overflowed by 244 px at 200% text size on a 360 px-wide phone; it is now a `Wrap`. Widget test runs at phone width.
- Bug fix: names pasted from web pages/spreadsheets with a zero-width space or BOM (`Bob​`) bypassed duplicate detection; those characters are stripped.
- Bug fix: the 80-character name limit counted UTF-16 code units (emoji counted twice); it now counts visible characters (`characters`, now a direct dependency).
- Accessibility: winner count and add message are live regions; winner positions are announced as "Winner N".
- Edge-case unit tests: invisible characters, emoji/Thai limits and whitespace duplicates, separator-only paste, CRLF paste, full permutation draw, empty list, uniformity of the second position. Widget tests: skipped-count message, draw disabled with no entrants, winner count lowering after remove + draw, a11y guidelines.

## Done in pass 2

- Release builds no longer sign with the debug key: `android/app/build.gradle.kts` reads the ignored `android/key.properties` and a Gradle guard fails any release assemble/bundle without it (pattern from `bookchaowalit-goal-tracker-mobile`). Root `.gitignore` also ignores `key.properties`, `*.jks`, `*.keystore`; README documents the setup. Not build-verified here (no Android SDK/Gradle in this environment).


## Done in pass 1

- Replaced the Expo/npm CI (which could never fail) with fail-closed Flutter CI: `dart format` check, `flutter analyze`, `flutter test`, debug APK on `main`.
- Implemented the core feature (collect giveaway entrants and draw fair, duplicate-free winners) with pure-Dart logic in `lib/logic/`.
- Replaced placeholder Explore/Profile tabs with an About screen describing features and privacy.
- Added unit tests for the logic and widget tests for the main journey.
- Removed unused `go_router` / `flutter_riverpod` dependencies; README now matches the code.
