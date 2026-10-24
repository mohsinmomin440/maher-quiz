# Maher Quiz: UI/UX & Logic Review

> **Current progress on every point is tracked in [`PROJECT_STATUS.md`](PROJECT_STATUS.md).**

Reviewed on 2026-10-17 by reading every file in `lib/`, plus `assets/data/questions_bank.json` and `tools/`.
`flutter analyze` and `flutter test` were **not** run (Flutter is not on this machine's PATH), so the analyzer could add more lint-level findings.

Priority legend: **P0** = broken, a security hole, or a crash. **P1** = wrong behaviour users will notice. **P2** = polish and maintainability.

---

## 1. Summary

The app looks good. It has a consistent emerald/gold theme, a clean bento home screen, a podium leaderboard, badges and answer review. The biggest problems are not visual:

1. **Everything is local.** Accounts, scores and the leaderboard live in `SharedPreferences` on a single device, so the leaderboard only ranks people who registered *on that same phone*, and nothing survives an uninstall.
2. **Scoring can be gamed easily.** Unlimited practice and bookmark rounds add to the leaderboard score, the daily quiz can be retaken after peeking at the answers, and double-tapping "Finish" scores the quiz twice.
3. **The password reset is not verified.** Anyone can reset any account's password, including the admin's.
4. **The question bank is inflated.** Only **827 of 1440** questions are unique: ten questions are each repeated ~60 times.
5. **Edit Profile silently reset every registered user's age group** to "General / Adult" (age-group lists didn't match). Now fixed.

---

## 2. Critical bugs (P0)

### 2.1 Password reset never checks the code
- `AuthService.resetPassword` (`lib/services/auth_service.dart:274`) ignores `otp` and calls `resetPasswordDirect`.
- `ForgotPasswordScreen` moves to step 2 even when the account doesn't exist, and prints the "secure code" on screen (`forgot_password_screen.dart:56-65`). The code is the constant `7860` (`auth_service.dart:268`).
- **Impact:** anyone holding the phone can take over any account, including `admin@maher.app`.
- **Fix:** while there is no backend, store a random 4–6 digit code with an expiry and compare it in `resetPassword`. Never display it in the UI. The real fix is server-side OTP (Firebase Auth / Supabase), see §8.

### 2.2 Hard-coded admin credentials
- `admin@maher.app` / `Admin@786` is seeded on every device (`auth_service.dart:49`), and the salt is a constant in source.
- **Fix:** remove the seeded admin from release builds. Assign admins server-side, or behind a build flag.

### 2.3 Double scoring on "Finish Quiz"
- `_nextQuestion()` (`quiz_screen.dart:135`) has no in-progress guard. A double tap on the last question calls `recordQuizCompletion` twice, which doubles `totalScore` and `quizzesCompleted`.
- **Fix:** add `bool _isFinishing`, return early if it's set, and disable the button while saving.

### 2.4 The daily quiz can be retaken after seeing the answers
- Leaving mid-quiz ("Leave Quiz?") saves nothing. Pressing *Start Daily Quiz* again then serves the **same 5 questions** (date-seeded), and the user already knows the answers.
- **Fix:** mark the daily quiz as *started* (`dailyStartedDate`) when it opens. On exit, either record the partial score or lock the quiz for the day, and say so honestly in the exit dialog.

### 2.5 Practice and bookmark rounds inflate the leaderboard
- `recordQuizCompletion(isDaily: false)` still adds `score` to `totalScore` (`auth_service.dart:286+`). Practice is unlimited, and the Saved revision quiz reuses questions the user has already seen.
- **Impact:** the "All-time" leaderboard and the *Noor-e-Ilm* and *Champion* badges measure grinding, not knowledge.
- **Fix:** keep `dailyScore` (which feeds the leaderboard) separate from `practiceXp`. Count only daily quizzes toward ranks.

### 2.6 Edit Profile overwrites the age group ✅ fixed
- Register offered `Age 4-7 / 8-10 / 11-14 (Deeniyat Class n)` and Edit Profile offered `Age 1 to 5 / 6 to 10 / 11 to 14`. Both lists include `General / Adult`.
- For any registered user, `_selectedAgeGroup` fell back to `'General / Adult'`, so saving Edit Profile silently changed the student's class to "General / Adult". (An earlier version of this review said this crashed. It doesn't, because the fallback is in the list.)
- **Fixed:** `lib/models/age_groups.dart` is now the single source. Its bands match the question data (4–7 / 8–11 / 12–14), and `AgeGroups.normalize()` maps old stored values by "Class N".

### 2.7 Crash when the stored session is invalid
- `HomeScreen` uses `_user!` (`home_screen.dart:319`). If `getCurrentUser()` returns `null` (account deleted or suspended by the admin, or a corrupt prefs entry), the app crashes.
- **Fix:** when the user is `null`, redirect to `LoginScreen`.

### 2.8 User IDs collide
- `MHR-${hashCode % 9000 + 1000}` (`auth_service.dart:126`) allows only 9000 IDs. Collisions become likely after about 100 users (birthday problem). `getAllUsers` de-duplicates by ID (`:361`), so one colliding user vanishes from the leaderboard, and `getCurrentUser` matches by ID first (`:69`), so a session can resolve to **the wrong account**.
- **Fix:** use a UUID, or a counter checked for uniqueness.

---

## 3. Logic issues (P1)

| # | Where | Problem | Suggested fix |
|---|---|---|---|
| 3.1 | `home_screen.dart:83` | The daily quiz uses `_selectedDifficulty`, which is set by the chips on the **Practice** tab. Changing the practice level silently changes the daily quiz, and users can pick "easy" for the daily challenge. | The daily quiz should always use `'all'`, or a fixed difficulty mix (e.g. 2 easy, 2 medium, 1 hard). |
| 3.2 | `quiz_service.dart` | The daily quiz ignores the user's age group, so a 5-year-old gets 12–14-year-old questions. | Filter by the user's age band (once the bands are unified, see 2.6). |
| 3.3 | `auth_service.dart:445` | `adminResetPassword` writes `passwords[email]`, but users who have a phone are looked up by `passwords[phone]` first. **The reset silently fails** for them, and the old password keeps working. | Find the user's real key, as `changePassword` does, and update every alias. |
| 3.4 | `auth_service.dart:188` | Login also accepts **plain-text** stored passwords ("legacy"). | Migrate legacy passwords once and remove the fallback. |
| 3.5 | `login_screen.dart:230` | The login validator requires `@` and `.`, so **phone login is impossible**, even though the service and error text support it. Register accepts email only, and Forgot Password requires `@`. | Decide whether login uses email or phone, and validate consistently on all three screens. |
| 3.6 | `login_screen.dart:25` | The "Remember me" checkbox does nothing; the session is always saved. | Wire it up (skip saving `maher_current_user` when unchecked), or remove it. |
| 3.7 | `register_screen.dart:87` | Every registration failure shows "This email is already registered". | Return a result type with a reason, as `ProfileUpdateResult` does. |
| 3.8 | Streak display | `streak` only changes when a quiz is completed. A user who misses 3 days still sees the old streak on Home and on the leaderboard. | Compute the *effective* streak when reading: if `lastQuizDate < yesterday`, the streak is 0. |
| 3.9 | Daily lock | The lock relies on the device clock and local midnight. Changing the date gives a fresh daily quiz. | This is acceptable offline. Fix it with server time once there is a backend. |
| 3.10 | Global prefs keys | `maher_bookmarked_questions`, `maher_seen_question_ids`, `maher_badge_jumuah_unlocked` and `maher_sound_enabled` are **shared by every account on the device**, so student B sees student A's bookmarks and Jumu'ah badge. | Add the user ID to the key: `maher_bookmarks_<userId>`. |
| 3.11 | `badge_service.dart` | The *Champion* badge's rule (`lastQuizScore >= 5 && quizzesCompleted >= 5`) does not match its description ("100+ points"). The *Noor-e-Ilm* badge says "answered 50 questions correctly", but it uses `totalScore`, which practice farming inflates. | Make each rule match its text, and store the unlock date (`unlockedDate` is never set). |
| 3.12 | `saved_questions_screen.dart:60` | The revision quiz passes the questions **without** `.shuffled()` (option positions are memorised) and has no size cap (50 bookmarks = a 50-question quiz). | Shuffle them, cap the round at 10, and don't add to the score (2.5). |
| 3.13 | `leaderboard_service.dart` | The admin account (`MHR-ADMIN-01`) is ranked with the students. | Filter out `role == 'admin'`. |
| 3.14 | `change_password_sheet.dart` / `auth_service.changePassword` | The new password is `trim()`-ed before hashing, but login hashes the raw input, so a password with a leading or trailing space can never log in. | Never trim passwords. Reject leading and trailing spaces in the validator instead. |
| 3.15 | `app_localization.dart:476` | `tr()` always prefers `'en'`, so `currentLang` has no effect. The `onLanguageChanged` callback is threaded through every screen and does nothing. | Either remove the dead plumbing or build a real language switch (see 5.1). |
| 3.16 | `admin_dashboard_screen.dart` | After an admin reset, the new password is shown in a SnackBar, and the default is `123456`. | Generate a random temporary password, and force the user to change it on next login. |

---

## 4. Question bank (content quality)

Measured from `assets/data/questions_bank.json`:

| Check | Result |
|---|---|
| Total questions | 1440 (480 easy / 480 medium / 480 hard) |
| **Unique question texts (gu)** | **827**. Ten questions appear 59–60 times each (e.g. *"ઇસ્લામ મુજબ જમતી વખતે કયા હાથે ખાવું સુન્નત છે?"* → q_842, q_852, q_862, …). 624 rows are padding. |
| **Correct answer is the longest option** | **898 / 1440 (62%)**, so students can guess by length. |
| `en.question == gu.question` | 148 questions have Gujarati text in the English field (untranslated). |
| Age bands | 4–7: 307, **8–11: 816**, 12–14: 317 (unbalanced) |
| Correct-index distribution | Perfectly even (360 each). Good. |

**Recommendations**
- Remove the duplicates and *fill the gaps with real questions*. The filler is there only to satisfy the `== 1440` assertion in `tools/verify_bank.py`. Change that assertion to check uniqueness instead of an exact count.
- Add checks to `verify_bank.py`: unique question text, "correct option is the longest" ratio < 35%, `en != gu`.
- Keep one canonical generator script and delete or archive the other four. They all overwrite the same file.
- With duplicates in the pool, a daily or practice round can show **the same question twice**. Even after the clean-up, de-duplicate by text when picking questions.

---

## 5. UI / UX suggestions

### 5.1 Language
- Questions are always Gujarati (`q.gu`, `quiz_screen.dart:98`), while the whole UI is English. Hindi and English translations exist in the data but are never shown.
- **Suggestion:** add a question-language toggle (ગુ / हि / EN) on the quiz screen or in Profile. Score against the language actually shown, because each language's options are shuffled separately.
- Several strings are hard-coded English or Gujarati and bypass `AppLocalization` ("MashaAllah! Correct Answer!", "Leave Quiz?", "Correct Answer:", "MISSION ACCOMPLISHED", "5 QUESTIONS", "Close Preview", the Gujarati-only error at `forgot_password_screen.dart`, etc.). Move them into the string table.

### 5.2 Fonts and Gujarati rendering
- The theme uses `GoogleFonts.outfit()` (`maher_theme.dart:117`). Outfit has **no Gujarati or Devanagari glyphs**, so all question text falls back to whatever system font the device has (inconsistent; on some devices letters get clipped). Google Fonts also downloads at runtime, so the first launch offline looks different.
- **Suggestion:** bundle `Noto Sans Gujarati` (+ `Noto Sans Devanagari`, plus an Arabic font for `السَّلَامُ عَلَيْكُمْ`) as assets, and set them as `fontFamilyFallback`.

### 5.3 Quiz flow
- **Feedback:** a correct answer shows a green SnackBar plus a coloured option. A wrong answer only gets a haptic. Show the same kind of inline banner for both ("Correct!" / "The answer is B"), and drop the SnackBar, which stacks when answering quickly.
- **Two taps per question** (select, then Submit). For kids aged 4–7, consider *tap = submit*, or at least make the selected state much more obvious.
- **No timer.** That's fine for kids. An optional per-question timer for the 12–14 band would add challenge.
- **Results screen:** add confetti or an animation for 5/5, "Share score" (WhatsApp is the main channel for this audience), and "Practice your wrong answers", which would bookmark the questions answered wrong.
- **Exit dialog:** after fixing 2.4, explain the consequence ("Leaving will submit your current score for today").
- The progress bar shows `(index + 1) / total` *before* the question is answered, so it reads 20% on question 1. Use `answered / total`, or segmented dots (● ● ○ ○ ○) that turn green or red per answer.

### 5.4 Home
- The pencil badge on the welcome-card avatar opens **Saved** (`_onTabTapped(3)`, `home_screen.dart:761`). It should open Profile/Edit (index 4).
- The streak chip in the app bar opens the **Leaderboard**. Users expect it to explain the streak (a small sheet: "Play daily to keep your 🔥 streak; best streak: N").
- After the daily quiz is completed, the card is a dead end. Add "Review today's answers" and "Keep practising →".
- The countdown label says "Time remaining" before completion. Phrase it as "Today's quiz closes in 05:12:30", or hide it; it adds pressure without meaning.
- The stats tiles show *Score* and *Quizzes*. More motivating: *Best streak*, *Accuracy %*, *Rank #*.

### 5.5 Navigation
- The bottom bar shows a label only for the selected tab, so the other four are unlabelled icons, and the Practice (Quran book) and Saved icons are hard to tell apart. Show labels on every tab, or at least add `Semantics`/`Tooltip`.
- Five tabs, with Practice as a whole tab for one card. Consider merging Practice into Home (a "Practice" section under the daily card) to free a slot.
- The admin console is reachable only from deep inside Profile. That's fine, but it should be hidden behind a real role check (it is), and **not** appear at all in a kids' build.

### 5.6 Leaderboard
- It ranks only users registered on this device (see §8). Until there's a backend, label it "On this device", or hide it. Otherwise one student always sees themselves as #1.
- "Today" ranks by `lastQuizScore`, but every user who played today and scored 5/5 ties. Break ties by completion time.

### 5.7 Profile / Edit
- The phone number is shown with a hard-coded `+91` prefix. Store it in E.164 format, or drop the prefix.
- The avatar is stored as a base64 JPEG inside the users JSON (see 6.1). Also offer a set of preset avatars (the code already handles an `avatar_` prefix in `edit_profile_screen.dart`), which suits kids better than uploading photos.

### 5.8 Accessibility
- `textMuted` `#94A3B8` on white has a contrast of ≈ 2.6:1 (fails WCAG AA's 4.5:1), and it's used for labels and timers. Darken it to around `#64748B`.
- Many font sizes are 9–11.5 px ("DEENIYAT" 9, "5 QUESTIONS" 10, nav labels 12). For young readers, use a minimum of 12 and 14+ for content.
- Option tiles are `InkWell`s with no semantics, so screen readers don't announce "Option A, selected". Use `Semantics(button: true, selected: …)`, or a `RadioListTile`-style widget.
- Check layouts at system text scale 1.3 to 2.0. Many `Row`s with fixed text will overflow.
- There's no dark theme. It's optional, but cheap to add because colours are already centralised in `MaherTheme`.

---

## 6. Performance (P2)

1. **The base64 avatar is decoded every second.** `HomeScreen` calls `setState` every second for the countdown (`home_screen.dart:48`), which rebuilds the whole `IndexedStack`, so `UserAvatar` runs `base64Decode`, creating a new `Image.memory` for the app bar, the hero card and the Profile tab every second. **Fix:** move the countdown into its own small `StatefulWidget` (or a `ValueListenableBuilder`), and cache the decoded bytes, or store the avatar as a file path.
2. **Large blobs in SharedPreferences.** Avatars (≈ 50–100 KB each) live inside `maher_registered_users`, which is decoded and re-encoded on *every* auth call (`ensureSeeded()` runs before each one). Store images as files (`path_provider`) and keep only the path.
3. The leaderboard renders all rows inside `SingleChildScrollView` + `Column`. Use `ListView.builder` once the list can grow.
4. `QuizService.loadQuestions()` parses ~2.7 MB of JSON on the UI isolate. Use `compute()` / `Isolate.run`.

---

## 7. Code quality / maintainability (P2)

- **Screen files are very large** (`home_screen.dart` 1367 lines, `profile_screen.dart` 1189 lines). Extract widgets: `DailyQuizCard`, `PracticeArenaCard`, `StatsGrid`, `OptionTile`, `ResultSummary`.
- **No state management.** User state is passed manually through constructors, `GlobalKey`s and `onUserUpdated` callbacks. A single `ChangeNotifier` / `Riverpod` provider for the current user would remove most of this plumbing and the manual `_loadUser()` refreshes.
- **Stringly-typed values:** `role`, `status`, `difficulty`, `ageGroup` and error codes are raw strings. Use enums.
- **Swallowed errors:** many `catch (_) {}` blocks hide failures (e.g. `loadQuestions` returns `[]` and the user just sees an empty quiz). At least log them in debug builds.
- **Dead code:** the `onLanguageChanged` callback is threaded everywhere, the badge model has `titleGu`/`descGu` filled with English, `unlockedDate` is never set, and the OTP is stored but never read.
- **Tests:** there is only a smoke test. High-value unit tests: `QuizService.getDailyQuestions` (deterministic, 5 unique questions), streak rules in `recordQuizCompletion`, `AuthService` register/login/reset flows, and badge rules. `SharedPreferences.setMockInitialValues` makes these easy.
- **Repo hygiene:** `Maher_Quiz.ipa` (7.5 MB) and `tools/cloudflared.exe` sit in the project root and should be in `.gitignore` or release assets. `.agents/` contains unrelated design skills.

---

## 8. Architecture recommendation: add a backend

Most P0/P1 issues (fake OTP, seeded admin, device-only leaderboard, clock tampering, data loss on uninstall, shared-device bookmarks) come from storing **everything in SharedPreferences**. A small backend fixes them together:

- **Firebase** (Auth with phone OTP, Firestore, Storage for avatars) or **Supabase** (Auth, Postgres, Storage).
- Server-side: the daily question set (one document per date), score submission (validated, idempotent per user per day), and the leaderboard as a query.
- Keep `questions_bank.json` bundled for offline practice, and sync daily results when the user is online.

---

## 9. Suggested order of work

1. ✅ **Quick fixes (done 2026-10-17, not yet compiled; see note):** 2.3 double-finish guard, 2.6 unified age groups, 2.7 null-user redirect, 3.1 daily uses `'all'`, 5.4 pencil → Profile, 3.13 hide admin from ranks, 3.10 per-user prefs keys (bookmarks, seen questions, Jumu'ah badge; the sound setting stays device-wide), 3.12 shuffle and cap (10) the saved-question revision.
   > The Flutter SDK at `C:\src\flutter` is Dart 3.7, but `pubspec.yaml` needs `^3.13.4`, so these changes have not been analyzed or run yet.
2. ✅ **Fair scoring (done 2026-10-17, not yet compiled):**
   - 2.4: the daily quiz is locked once opened (`dailyStartedDate`). Leaving submits the score so far, and if the app is closed mid-quiz the saved progress is submitted on the next Home load (`AuthService.finalizeAbandonedDaily`). Only one daily result per day is accepted.
   - 2.5: practice and revision rounds now earn `practiceXp` (shown on the Practice tab). `totalScore`, and so the leaderboard, counts daily quizzes only. *Scores earned before this change still include practice points.*
   - 3.8: `UserModel.effectiveStreak` drops to 0 once a day is missed. Home, Profile, Leaderboard and Admin all use it.
   - 3.11: Noor-e-Ilm = 50 correct answers (daily + practice). Champion = 100 daily points (description updated). Mustaqeem uses the new `bestStreak`, so it isn't lost when a streak breaks. `unlockedDate` is still not tracked.
3. ✅ **Auth hardening (done 2026-10-17; parsed with the old Dart 3.7 analyzer, no syntax or cross-file reference errors, but not compiled):**
   - 2.1: the fake OTP flow was removed. Without a backend no code can be delivered, so *Forgot password* now explains that a teacher or admin resets it from the Admin console (`sendOtp`, `resetPassword` and `resetPasswordDirect` are deleted).
   - 2.2: the seeded admin stays, so a new install can be managed, but it has `mustChangePassword` and gets a non-dismissible change-password sheet on first login (existing installs still on `Admin@786` are flagged too). It is only seeded when the device has **no** admin, so renaming it no longer brings back the default one.
   - 2.8: member IDs are random (`MHR-7KQ2XP`, secure RNG, checked for uniqueness). Existing IDs are unchanged.
   - 3.3 / 3.16: an admin reset writes the hash under the user's real key and every alias (it now also works for phone users), proposes a random temporary password, no longer echoes it in a SnackBar, and forces a change at next login.
   - 3.4: a plain-text legacy password is accepted once at login and immediately replaced by its hash. `changePassword` compares hashes only.
   - 3.5: login accepts an email **or** a 10-digit mobile number (a `+91` prefix is tolerated).
   - 3.6: "Remember me" works. Unchecked means the session ends on the next app start (`clearTemporarySession` in Splash).
   - 3.14: passwords are never trimmed. The Register and Change Password validators reject leading and trailing spaces instead.
   - *Still open:* 3.7 (register always says "already registered"). Registration is still email-only.
4. ✅ **Content and UX (done 2026-10-17; old analyzer shows no syntax errors, not compiled):**
   - **Bank:** 1440 → **827 unique questions** (still 276/276/275 by difficulty and balanced A–D). The first copy keeps its original ID, so bookmarks of kept questions still work, but bookmarks of removed copies disappear. `generate_1440_question_bank.py` now de-duplicates before writing. `verify_bank.py` checks for unique IDs and questions and the same answer index across languages, instead of `== 1440`, and warns about the longest-option ratio (now 44%) and untranslated English text (148). *Content still needed:* difficulty is assigned round-robin (`idx % 3`) by the generator, not by actual difficulty, and the 8–11 age band holds 56% of the questions.
   - **Fonts:** Noto Sans Gujarati, Noto Sans Devanagari and Noto Naskh Arabic (Regular/Bold, OFL) are bundled in `assets/fonts/` as `fontFamilyFallback`, so they work offline.
   - **Question language:** a ગુજરાતી / हिन्दी / English menu in the quiz app bar, remembered per user and also used by the Saved list. `QuestionModel.shuffled()` uses one permutation for all languages, so switching mid-question keeps the selection and scoring valid.
   - **Quiz UX:** an inline correct/wrong banner (names the right letter) replaces the stacking SnackBar. The progress bar fills as questions are answered. The results screen has "Save wrong answers to revise later" and "Copy result to share" (clipboard; no new package). It renders in the chosen language.
   - **Accessibility:** `textMuted` → `#64748B` (≈4.8:1). Text below 12px raised by 1–2px (17 places). Option tiles and bottom-nav tabs have semantics labels, selected state and tap actions. Nav tabs have tooltips.
   - **Performance:** the countdown is its own widget (Home no longer rebuilds every second, and it reloads at midnight). Decoded avatars are cached. The question bank is parsed with `compute()`.
   - *Not done:* tap-to-submit for young children, a per-question timer for 12–14, streak info sheet, confetti, dark theme, leaderboard `ListView.builder`, and text-scale overflow testing.
5. ✅ **Backend migration (done 2026-10-17 as an optional "online mode"; not compiled, and not tested against a live Supabase project):** Supabase with email + password. `supabase/schema.sql` sets up the profiles, daily results and bookmarks tables, row-level security, and score RPCs that use server dates (one daily result per day, scores capped). `lib/services/cloud_service.dart` adds sign-in/sign-up, emailed 6-digit reset codes, an offline result queue, the global leaderboard (top 100), bookmark sync, and a one-time import of the old on-device account by matching email. Setup steps are in `SUPABASE_SETUP.md`. Without `--dart-define-from-file=supabase.json` the app behaves exactly as before.
   - *Still open:* grading happens on the phone (a modified app could submit 5/5), the daily "opened = locked" rule is per device, avatars and phone numbers aren't synced, and the in-app admin console doesn't manage online accounts.
