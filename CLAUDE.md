# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Maher Quiz is a Flutter app: a daily Islamic knowledge quiz (Deeniyat syllabus, ages 1–14) with questions stored in Gujarati, Hindi and English. Targets Android, iOS, web and Windows. It runs in one of two modes:

- **Local mode** (default): no backend. All state, including user accounts, lives on the device in `shared_preferences`.
- **Online mode**: built with `--dart-define-from-file=supabase.json` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`; see `SUPABASE_SETUP.md`). `CloudService.isEnabled` is true only after `Supabase.initialize` succeeds in `main.dart`. Supabase Auth (email + password) and the `profiles` table are the source of truth. The signed-in user is *mirrored* into the local users DB (`AuthService.cacheCloudUser`), so every screen and service keeps reading the local session as in local mode. The schema, row-level security and score functions are in `supabase/schema.sql`. Clients can change scores only through the RPCs `submit_daily_result` / `add_practice_xp` / `import_local_stats`, and read rankings through `get_leaderboard`.

## Commands

```bash
flutter pub get
flutter run                          # pick a device; -d chrome / -d windows also work
flutter run --dart-define-from-file=supabase.json   # online mode (copy supabase.example.json first)
flutter analyze                      # lints: package:flutter_lints (platform dirs excluded)
flutter test                         # all tests
flutter test test/widget_test.dart   # single file
flutter test --plain-name "App smoke test"   # single test by name
flutter build web                    # output goes to build/web
python tools/verify_bank.py          # validate assets/data/questions_bank.json (run from repo root)
```

- `share_app.bat` serves `build/web` on port 8080 (`tools/serve_web.py`) and opens a public Cloudflare tunnel (`tools/cloudflared.exe`). Run `flutter build web` first.
- CI (`.github/workflows/build_ios.yml`) builds an **unsigned** iOS IPA on push to main/master or on manual trigger, and uploads it as an artifact.

## Architecture

- **Entry/flow:** `main.dart` → `SplashScreen` → `HomeScreen` when `AuthService.getCurrentUser()` returns a user, otherwise `LoginScreen`. Navigation is plain `Navigator`/`MaterialPageRoute`; there is no state-management library or router. Every screen takes an `onLanguageChanged` callback. It is currently a no-op, because the UI is fixed to English (`AppLocalization.currentLang = 'en'`).
- **Services (`lib/services/`)** are classes with only static methods, and each one persists to `SharedPreferences` under keys prefixed `maher_`. Screens call them directly. Per-user data (bookmarks, seen questions, Jumu'ah badge, question language, daily progress) must use `AuthService.userScopedKey(prefs, baseKey)`, which appends the session user's ID. Only the sound setting is device-wide.
  - `AuthService` is a local "user database". It stores the user map and the password-hash map as JSON strings (SHA-256 with a static salt). A user's password hash is stored under their DB key **and** their email/phone aliases, so use `_setPasswordForUser` whenever you write one. `ensureSeeded()` runs before every auth call and seeds `admin@maher.app` only when no admin exists. That account is flagged `mustChangePassword`, and so is any account after an admin reset. Home then shows `ChangePasswordSheet.show(..., forced: true)`. In local mode there is no self-service reset (no backend to deliver codes): Forgot Password points the user to an admin. In online mode it emails a 6-digit recovery code (`verifyOTP` with `OtpType.recovery`), and the Admin console only shows a pointer to the Supabase dashboard. "Remember me" off sets `maher_session_temporary`, which `clearTemporarySession()` in Splash honours.
  - **Scoring:** `recordQuizCompletion(isDaily: true)` adds to `totalScore` (the leaderboard counts it) and updates `streak`/`bestStreak`, and accepts only one result per day. Practice and revision rounds add only to `practiceXp`. The daily quiz is locked once opened (`markDailyStarted`), the running score is saved per answer (`saveDailyProgress`), and an abandoned attempt is submitted on the next Home load (`finalizeAbandonedDaily`). Display streaks through `UserModel.effectiveStreak` (0 once a day is missed), never the raw `streak`.
  - `QuizService` loads `assets/data/questions_bank.json` once (parsed with `compute`) and caches it. Daily quiz: 5 questions from all levels, picked with a date-seeded `Random` (the same for every user each day), resets at local midnight. Practice: 5 random questions of the chosen level, skipping IDs already seen. `QuestionModel.shuffled()` applies **one** option permutation to gu/hi/en, so `correct` is the same index in every language. That is what lets the quiz switch language mid-question. Options are re-shuffled on every fetch, so never rely on a stored option index.
  - `LeaderboardService` ranks locally registered students (admins excluded). `BadgeService`, `BookmarkService` and `SoundService` are small helpers built on prefs.
  - `CloudService` (online mode only): these `AuthService` methods branch to it when `CloudService.isEnabled`: `register` (returns an error code or null), `login` (returns `AuthResult`), `logout`, `changePassword`, `updateProfile` and `recordQuizCompletion`. Results that fail offline are queued under the user-scoped key `maher_cloud_pending` and flushed by `CloudService.syncOnHomeLoad()` (called from Home's `_loadUser`). Any new per-user prefs key must also be added to `AuthService._userScopedBaseKeys`, so the legacy-account import migrates it. Never touch `Supabase.instance` without checking `CloudService.isEnabled`/`hasSession` first, because it isn't initialized in local mode.
- **Age groups:** use `lib/models/age_groups.dart` (`AgeGroups.all`, `normalize()` for legacy values). Never hard-code the labels in screens.
- **Admin:** a user with `role == 'admin'` gets `screens/admin/admin_dashboard_screen.dart` (from Profile), which lists, deletes and promotes users and sets temporary passwords.
- **UI utils:** `MaherTheme` holds the emerald/gold palette and `ThemeData` (Outfit plus the bundled Noto Gujarati/Devanagari/Arabic fonts as `scriptFontFallback`, declared in `pubspec.yaml`). `AppLocalization.tr(key)` holds the string tables; `tr()` always prefers `en`, so new UI strings only need an `en` entry. `MaherIcons.get(...)` builds the custom icon widgets. The SVG assets in `assets/icons/` come from `tools/generate_svg_icons.js`.

## Question bank

- `assets/data/questions_bank.json` (827 unique questions) is generated. Each entry has `id`, `category` (bilingual "Gujarati / English" label), `age_group`, `difficulty` (`easy`|`medium`|`hard`), and `gu`/`hi`/`en` objects with `question`, `options[4]`, `correct` (index) and `explanation`. Options must be parallel across languages, with the same `correct` index.
- Several Python scripts in `tools/` write this file directly: `generate_1440_question_bank.py` (the current one, which now de-duplicates), `generate_massive_bank.py`, `compile_expanded_bank.py`, `create_large_question_bank.py` and `generate_questions_from_pdf.py`. Each one overwrites the file, so running the wrong one replaces the current bank, and re-running renumbers IDs, which orphans users' bookmarks. `verify_bank.py` requires unique IDs and question texts, 4 distinct options, the same answer index across languages and no emoji, and warns about the longest-option ratio and untranslated English text.
- `tools/generate_app_icons.py` and `tools/update_logo.py` regenerate the platform launcher icons from the logo image (requires Pillow).
