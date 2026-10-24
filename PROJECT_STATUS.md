# Maher Quiz: Project Status

Checklist of every point from [`UI_UX_LOGIC_REVIEW.md`](UI_UX_LOGIC_REVIEW.md) (numbers like **2.3** refer to that file).
Last updated: **2026-10-17**. Tick `[x]` items as you finish or verify them.

> ⚠️ **Nothing below has been compiled or run yet.** The Flutter SDK on the development machine (`C:\src\flutter`, Dart 3.7) is older than the project needs (`sdk: ^3.13.4`). Until `flutter analyze` and a real run pass, "done" means *written*, not *working*.

---

## 0. Verify everything first (highest priority)

- [ ] Install Flutter 3.13+ (ships Dart ≥ 3.13) and run `flutter pub get`
- [ ] `flutter analyze` with no errors (fix whatever it reports)
- [ ] `flutter run` in **offline mode** and test steps 1–4 (test lists below)
- [ ] `python tools/verify_bank.py` passes (needs Python; the same checks already passed in Node)
- [ ] Set up Supabase (`SUPABASE_SETUP.md`) and test **online mode** (checklist in that file)
- [ ] Write unit tests: daily/practice scoring, streak, daily lock, login/register, admin reset, badges (`SharedPreferences.setMockInitialValues`)

---

## 1. Critical bugs (§2), all written

- [x] **2.1** Fake reset code removed. Offline: "ask your admin". Online: emailed 6-digit code
- [x] **2.2** Built-in admin must change `Admin@786` on first login, and is only seeded when no admin exists
- [x] **2.3** Double-tap on "Finish" no longer scores twice
- [x] **2.4** Daily quiz locked once opened. Leaving or closing the app submits the score so far
- [x] **2.5** Practice/revision earn *Practice XP* only; the leaderboard counts daily quizzes only
- [x] **2.6** One shared age-group list (`lib/models/age_groups.dart`), so Edit Profile no longer resets the class
- [x] **2.7** Deleted/suspended user is sent to Login instead of crashing
- [x] **2.8** Random unique member IDs (`MHR-7KQ2XP`)

**Test:** finish button double-tap · leave the daily quiz after 2 answers, which shows "done" and can't restart · close the app mid-quiz and reopen · admin first login is forced to change password

---

## 2. Logic issues (§3)

- [x] **3.1** Daily quiz always uses all levels (Practice chips no longer affect it)
- [ ] **3.2** Daily quiz should match the student's age group *(not done)*
- [x] **3.3** Admin password reset works for students with a phone number
- [x] **3.4** Old plain-text passwords upgraded to hashes at login
- [x] **3.5** Login with email or 10-digit mobile (offline mode)
- [x] **3.6** "Remember me" works (unchecked means logged out on next app start)
- [x] **3.7** Register shows the real reason for failure
- [x] **3.8** Streak shows 0 once a day is missed (`effectiveStreak`)
- [ ] **3.9** Clock-change trick: blocked in **online mode only** (server date). Offline mode still trusts the phone clock
- [~] **3.10** Bookmarks, seen questions, Jumu'ah badge and language are per account ✅. The sound setting is still device-wide (intended)
- [~] **3.11** Badge rules match their descriptions ✅. **Unlock date is not saved** ❌
- [x] **3.12** Saved-question quiz: shuffled, max 10 questions
- [x] **3.13** Admins hidden from the leaderboard
- [x] **3.14** Passwords never trimmed; leading/trailing spaces rejected
- [ ] **3.15** Remove the unused `onLanguageChanged` callback threaded through every screen *(not done)*
- [x] **3.16** Admin reset uses a random temporary password and forces a change

---

## 3. Question bank (§4)

- [x] Duplicates removed: 1440 → **827 unique** (backup of the original was kept outside the project)
- [x] `generate_1440_question_bank.py` de-duplicates before writing
- [x] `verify_bank.py` checks uniqueness and the same answer index in all languages (no more `== 1440`)
- [ ] Correct answer is the **longest option in 44%** of questions, so wrong options need rewriting (target < 35%)
- [ ] **148** questions have Gujarati text in the English field, so they need translating
- [ ] **Difficulty labels are fake** (generator assigns easy/medium/hard in rotation), so they need real review
- [ ] Age bands unbalanced (8–11 = 56%), so more 4–7 and 12–14 questions are needed
- [ ] Remove or archive the 4 old generator scripts (`generate_massive_bank.py`, `compile_expanded_bank.py`, `create_large_question_bank.py`, `generate_questions_from_pdf.py`)

---

## 4. UI / UX (§5)

**Language & fonts**
- [x] **5.1** Question language switch (ગુજરાતી / हिन्दी / English) in the quiz, remembered per student
- [ ] **5.1** Move remaining hard-coded texts into `AppLocalization` *(many still hard-coded)*
- [x] **5.2** Bundled Noto Gujarati / Devanagari / Arabic fonts (offline)

**Quiz flow (5.3)**
- [x] Inline correct/wrong banner (shows the right letter)
- [x] Progress bar fills as questions are answered
- [x] Honest exit dialog for the daily quiz
- [x] "Save wrong answers to revise later"
- [x] "Copy result to share" (clipboard)
- [ ] Tap-to-answer (one tap) for ages 4–7
- [ ] Optional per-question timer for ages 12–14
- [ ] Confetti/animation for 5/5
- [ ] Real share button (`share_plus` package) instead of copy

**Home (5.4)**
- [x] Pencil on avatar opens Profile
- [ ] Streak chip opens a streak info sheet (current and best streak)
- [ ] After the daily quiz: "Review today's answers" + "Keep practising →"
- [ ] Better countdown wording ("Today's quiz closes in …")
- [ ] Stat tiles: best streak, accuracy %, rank

**Navigation (5.5)**
- [x] Screen-reader labels + long-press tooltips on tabs
- [ ] Visible labels on all tabs (Practice and Saved icons look alike)
- [ ] Consider merging the Practice tab into Home
- [ ] Hide the admin console in a kids-only build

**Leaderboard (5.6)**
- [ ] Offline mode: label it "On this device"
- [ ] "Today" ties broken by completion time

**Profile (5.7)**
- [ ] Remove the hard-coded `+91` prefix
- [ ] Preset avatars for kids (instead of photo upload)

**Accessibility (5.8)**
- [x] Darker muted text colour (`#64748B`, passes WCAG AA)
- [x] Text under 12px enlarged (17 places)
- [x] Answer options announced by screen readers
- [ ] Test at large system text size (1.3×–2×) and fix overflows
- [ ] Dark theme

---

## 5. Performance (§6)

- [x] Countdown no longer rebuilds the whole Home screen every second
- [x] Decoded profile photos cached
- [x] Question file parsed in the background (`compute`)
- [ ] Store profile photos as files (not base64 inside the users JSON)
- [ ] Leaderboard list → `ListView.builder`

---

## 6. Code quality (§7)

- [ ] Split very large screens (`home_screen.dart`, `profile_screen.dart`, `quiz_screen.dart`) into widgets
- [ ] Add state management for the current user (Provider / Riverpod)
- [ ] Use enums for `role`, `status`, `difficulty`, error codes
- [ ] Log swallowed errors (`catch (_) {}`) in debug builds
- [ ] Remove dead code: `onLanguageChanged`, badge `titleGu`/`descGu` filled with English
- [ ] Unit tests (see section 0)
- [ ] Move `Maher_Quiz.ipa` and `tools/cloudflared.exe` out of the project / into `.gitignore`

---

## 7. Online backend (§8), written, not tested

- [x] Supabase schema, security rules, score functions: `supabase/schema.sql`
- [x] Email + password login, emailed reset code, offline result queue, global leaderboard, bookmark sync, one-time import of old accounts
- [x] Setup guide: `SUPABASE_SETUP.md`
- [ ] Create the Supabase project and run `schema.sql`
- [ ] Add `{{ .Token }}` to the Reset Password email template
- [ ] Set up custom SMTP (built-in email is limited to a few per hour)
- [ ] Fill in `supabase.json` and test with `flutter run --dart-define-from-file=supabase.json`
- [ ] Add `SUPABASE_URL` / `SUPABASE_ANON_KEY` secrets to the CI workflow
- [ ] Server-side grading (currently the phone grades, so a modified app could send 5/5)
- [ ] Daily "opened = locked" rule across devices (currently per phone)
- [ ] Sync profile photo and phone number
- [ ] Online user management inside the app (currently via the Supabase dashboard)

---

## Change log

| Date | What |
|---|---|
| 2026-10-17 | Review written; steps 1–5 implemented (not yet compiled or tested) |
