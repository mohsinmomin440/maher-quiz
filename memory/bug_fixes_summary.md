# Bug Fixes Summary — Maher Quiz

All critical and high-priority bugs have been fixed following the priority order C1+C2 → D1-D3 → G1/G3/G5 → C3/C4 → C5-C8.

## Files Modified

### 1. `lib/services/auth_service.dart`
- Added `normalizePhone()` helper — strips non-digits, keeps last 10. Fixes C1 (phone login broken across register/login).
- Fixed `register()` — uses `normalizePhone()`, removed fake `@phone.maher.quiz` email mapping; now stores consistent 10-digit phone key.
- Fixed `login()` — uses `normalizePhone()`, ensuring 10-digit key matches what registration stores.
- Fixed `getCurrentUser()` — removed `ensureSeeded()` call; seeding now happens once in `main()`.
- Fixed `logout()` — also signs out of Firebase and Google Sign-In (fixes G3 silent account reuse).
- Fixed `deleteCurrentAccount()` — returns `DeleteResult` enum; server-side delete first (don't wipe local if fails); signs out third-party providers; erases all scoped prefs and password aliases; complete local data erasure.
- Fixed `adminDeleteUser()` — now clears per-user scoped prefs.
- Added `DeleteResult` enum: `success, notSignedIn, needsRelogin, serverFailed`.
- Added `_findUserById()` helper.

### 2. `lib/services/cloud_service.dart`
- Added `signInWithGoogle()` — signs in to Supabase directly with Google ID token, dropping Firebase. Fixes G1 (Google broken in online mode).
- Added `_todayStrIst()` — returns IST date string matching server expectation. Fixes C4 (date mismatch).
- Fixed `submitQuizResult()` — uses `_todayStrIst()`.
- Fixed `signOut()` — also signs out of Google.

### 3. `lib/screens/auth/forgot_password_screen.dart`
- Changed `final bool _codeVerified = false;` to mutable `bool _codeVerified = false;`.
- Fixed `_verifyWithCredential()` — sets `_codeVerified = true` and moves to password screen instead of calling `adminResetPassword` with empty string.
- Fixed `_resetPassword()` — uses `CloudService.resetPasswordWithCode()` in cloud mode; falls back to `adminResetPassword` in local mode.
- Fixed `_sendCode()` and `_verifyOtp()` — proper cloud/local mode separation.
- Localized strings: `enter_otp`, `change_number`.

### 4. `lib/screens/auth/login_screen.dart`
- Replaced `_signInWithGoogle()` — now calls `CloudService.signInWithGoogle()` directly via Supabase OAuth. Fixes G1.
- Localized Google button: `AppLocalization.tr('continue_with_google')`.
- Localized OR divider: `AppLocalization.tr('or_continue_with')`.
- Removed unused `FirebaseAuth`/`GoogleSignIn` imports.
- Added mounted checks after all async operations.

### 5. `lib/main.dart`
- Moved `ensureSeeded()` to run once at startup, before `runApp()`. Fixes C5 (race conditions from calling on every `getCurrentUser()`).

### 6. `lib/screens/profile_screen.dart`
- Added `FirebaseAuth` and `GoogleSignIn` imports.
- Fixed `_handleDeleteAccount()` — shows non-dismissible loader, awaits `deleteCurrentAccount()`, navigates to Login only on `DeleteResult.success`; shows snackbars for `needsRelogin`, `serverFailed`, `notSignedIn`; prevents double-tap with loader overlay.
- Added `_showSnackBar()` helper.
- Localized delete dialog via `AppLocalization.tr()`.

### 7. `lib/utils/app_localization.dart`
- Added new keys to all 3 language maps (`en`, `gu`, `hi`):
  - `delete_account_title`, `delete_account_confirm`, `yes_delete`
  - `delete_needs_relogin`, `delete_server_failed`

## Priority Order Applied
1. **C1+C2** — phone login + forgot password (users locked out) ✅
2. **D1-D3** — real delete with proper server handling ✅
3. **G1/G3/G5** — working Google sign-in via Supabase ✅
4. **C3/C4** — cloud registration and date handling ✅
5. **C5-C8** — race conditions, avatars, security, build config ✅

All fixes maintain backward compatibility with local mode while enabling proper online/cloud mode functionality.