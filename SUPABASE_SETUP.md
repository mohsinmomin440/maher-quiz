# Supabase setup (online accounts and global leaderboard)

Maher Quiz works fully offline by default. When you build it with a Supabase URL and public key, it switches to **online mode**:

- Students register and log in with **email + password** (Supabase Auth).
- "Forgot password" emails a **6-digit code**, so there are no fake codes and admins no longer need to reset passwords.
- Daily scores, streaks and practice XP are stored on the server. The server applies the rules (one daily result per day, a score of 0–5, its own date in `Asia/Kolkata`), so changing the phone's clock or tapping twice can't add points.
- The **leaderboard is global** (top 100 students across all devices).
- Bookmarks sync across devices.
- The first time a student signs in on a device that has their old offline account (same email), their old score, streak, practice XP and bookmarks are **imported once**.

Kept on the device only: profile photo, mobile number, sound setting, question language.

---

## 1. Create the project (≈ 5 min)

1. Sign up at <https://supabase.com> and click **New project**.
2. Pick a name (e.g. `maher-quiz`), set a database password (store it safely; the app never needs it), and choose the region **South Asia (Mumbai)**.
3. Wait for the project to finish starting.

## 2. Create the database

1. Open **SQL Editor → New query**.
2. Paste the whole of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
3. Check **Table Editor**: you should see `profiles`, `daily_results` and `bookmarks`.

The script is safe to run again after updates.

## 3. Auth settings

**Authentication → Providers → Email**: keep it enabled.

- **Confirm email**: *on* (recommended) means students must click a link in an email before their first login. The app explains this after registration. Turn it off if your students can't easily check email.
- Minimum password length: 6 (the app requires at least 6).

**Authentication → Email Templates → Reset Password**: the app asks for a code, not a link, so the template **must include `{{ .Token }}`**. For example:

```html
<h2>Maher Quiz password reset</h2>
<p>Your code is: <strong>{{ .Token }}</strong></p>
<p>Enter it in the app to choose a new password. If you didn't ask for this, ignore this email.</p>
```

**Important for real use: email sending limits.** Supabase's built-in email service only sends a few emails per hour and is meant for testing. Before giving the app to a class, set up your own SMTP under **Project Settings → Authentication → SMTP Settings** (for example Brevo, Resend, Amazon SES, or a Gmail/Workspace app password).

## 4. Connect the app

In **Project Settings → API**, copy:

- **Project URL**, e.g. `https://abcdxyz.supabase.co`
- **anon public** key (a long `eyJ…` string)

> The *anon* key is designed to be inside the app; the security rules in `schema.sql` protect the data. **Never** use the `service_role` key in the app.

Copy `supabase.example.json` to `supabase.json` (it is git-ignored) and fill in both values, then run or build with:

```bash
flutter run --dart-define-from-file=supabase.json
flutter build apk --dart-define-from-file=supabase.json
flutter build web --dart-define-from-file=supabase.json
```

Without these flags the app stays in offline mode. For CI (e.g. `.github/workflows/build_ios.yml`), store the two values as repository secrets and pass them with `--dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}`.

## 5. Admins and managing students

The in-app Admin console only manages offline accounts. In online mode, use the dashboard:

- **Make someone an admin** (SQL Editor):
  ```sql
  update public.profiles set role = 'admin'
  where id = (select id from auth.users where email = 'teacher@example.com');
  ```
  Admins don't appear on the leaderboard.
- **Remove a student:** Authentication → Users → ⋯ → Delete user. Their profile, results and bookmarks are deleted too.
- **Password problems:** students use *Forgot password* themselves. In an emergency, use Authentication → Users → ⋯ → Send password recovery.
- **Reset everyone's scores** (for example for a fresh, fair leaderboard after import):
  ```sql
  update public.profiles set total_score = 0, streak = 0, best_streak = 0,
    practice_xp = 0, quizzes_completed = 0, last_quiz_date = null, last_quiz_score = 0;
  delete from public.daily_results;
  ```

## 6. Test checklist

1. Register a new student. Confirm the email (if enabled), then log in.
2. Play the daily quiz. In the Table Editor, `daily_results` has one row and `profiles.total_score` went up.
3. Play the daily quiz again from a second phone with the same account. It is accepted locally, but the server ignores the second result for that day.
4. Turn on airplane mode, play a practice round, turn it back off and reopen Home. `practice_xp` updates (the result was queued).
5. Use Forgot password: you receive a 6-digit code, can set a new password, and can log in with it.
6. On a phone that has an old offline account, log in online with the same email. The old score and bookmarks appear once.

## Known limitations

- Scores are checked for range and frequency on the server, but the quiz is still graded on the phone, so a modified app could submit 5/5. Moving grading to the server (questions served by a function) is the next step if this matters.
- The "daily quiz locked once opened" rule is stored per device. Opening the quiz on phone A and then finishing it on phone B is still possible (only one result per day counts).
- Changing the login email isn't supported in the app (Edit Profile shows a message). Change it in the dashboard if needed.
