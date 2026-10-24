-- Maher Quiz – Hardened Production Supabase Schema
-- Run in the Supabase dashboard: SQL Editor → New query → paste → Run.
-- Safe to re-run: objects are created with "if not exists" / "or replace".

-- Dates for the daily quiz follow IST timezone (change if needed)
create or replace function public.quiz_today()
returns date language sql stable as $$
  select (now() at time zone 'Asia/Kolkata')::date
$$;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create or replace function public.generate_member_code()
returns text language plpgsql volatile as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code text;
begin
  loop
    code := 'MHR-';
    for i in 1..6 loop
      code := code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.profiles where member_code = code);
  end loop;
  return code;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  member_code text unique not null,
  name text not null default '' check (char_length(trim(name)) <= 60),
  age_group text not null default 'General / Adult' check (char_length(age_group) <= 50),
  role text not null default 'student' check (role in ('student', 'admin')),
  total_score int not null default 0 check (total_score >= 0),       -- daily quizzes only (leaderboard)
  practice_xp int not null default 0 check (practice_xp >= 0),       -- practice / revision rounds
  quizzes_completed int not null default 0 check (quizzes_completed >= 0),
  streak int not null default 0 check (streak >= 0),
  best_streak int not null default 0 check (best_streak >= 0),
  last_quiz_date date,
  last_quiz_score int not null default 0 check (last_quiz_score between 0 and 5),
  stats_imported boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.daily_results (
  user_id uuid not null references public.profiles (id) on delete cascade,
  quiz_date date not null,
  score int not null check (score between 0 and 5),
  created_at timestamptz not null default now(),
  primary key (user_id, quiz_date)
);

create table if not exists public.bookmarks (
  user_id uuid not null references public.profiles (id) on delete cascade,
  question_id text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, question_id)
);

-- Performance indices for high-concurrency leaderboard queries
create index if not exists idx_profiles_leaderboard on public.profiles (role, total_score desc, created_at);
create index if not exists idx_daily_results_user_date on public.daily_results (user_id, quiz_date);

-- New auth user → profile row (name / age group come from sign-up metadata)
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, member_code, name, age_group)
  values (
    new.id,
    public.generate_member_code(),
    coalesce(substring(trim(new.raw_user_meta_data ->> 'name') from 1 for 60), ''),
    coalesce(substring(new.raw_user_meta_data ->> 'age_group' from 1 for 50), 'General / Adult')
  );
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Row-level security (Strictly hardened against data scraping)
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.daily_results enable row level security;
alter table public.bookmarks enable row level security;

-- P0 FIX: Users can ONLY read their own profile row.
-- Prevents scraping children's private accounts and data.
-- Public leaderboard is served ONLY via the secure get_leaderboard() RPC.
drop policy if exists "profiles readable by signed-in users" on public.profiles;
drop policy if exists "users read own profile" on public.profiles;
create policy "users read own profile"
  on public.profiles for select to authenticated
  using (id = auth.uid());

drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile"
  on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- Only name and age group are client-editable; scores/role go through RPCs
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (name, age_group) on public.profiles to authenticated;

drop policy if exists "users read own results" on public.daily_results;
create policy "users read own results"
  on public.daily_results for select to authenticated using (user_id = auth.uid());
revoke insert, update, delete on public.daily_results from anon, authenticated;

drop policy if exists "users manage own bookmarks" on public.bookmarks;
create policy "users manage own bookmarks"
  on public.bookmarks for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Score functions & Account management (RPCs)
-- ---------------------------------------------------------------------------

-- Records a daily quiz result. One per user per day.
create or replace function public.submit_daily_result(p_date date, p_score int)
returns public.profiles
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  today date := public.quiz_today();
  safe_score int := least(greatest(coalesce(p_score, 0), 0), 5);
  inserted int;
  prof public.profiles;
begin
  if uid is null then raise exception 'not signed in'; end if;
  if p_date is null or p_date < today - 1 or p_date > today then
    raise exception 'quiz date % outside allowed range', p_date;
  end if;

  insert into public.daily_results (user_id, quiz_date, score)
  values (uid, p_date, safe_score)
  on conflict do nothing;
  get diagnostics inserted = row_count;

  if inserted = 0 then
    select * into prof from public.profiles where id = uid;
    return prof; -- already submitted for that day: no change
  end if;

  update public.profiles p set
    streak = case
      when p.last_quiz_date is not null and p.last_quiz_date >= p_date then p.streak
      when p.last_quiz_date = p_date - 1 then p.streak + 1
      else 1 end,
    total_score = p.total_score + safe_score,
    quizzes_completed = p.quizzes_completed + 1,
    last_quiz_score = case
      when p.last_quiz_date is not null and p.last_quiz_date > p_date then p.last_quiz_score
      else safe_score end,
    last_quiz_date = greatest(coalesce(p.last_quiz_date, p_date), p_date)
  where p.id = uid
  returning * into prof;

  update public.profiles set best_streak = greatest(best_streak, streak)
  where id = uid returning * into prof;
  return prof;
end $$;

-- P0 FIX: Practice / revision XP (never increments quizzes_completed; max 10 XP per call)
create or replace function public.add_practice_xp(p_score int)
returns public.profiles
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  safe_xp int := least(greatest(coalesce(p_score, 0), 0), 10);
  prof public.profiles;
begin
  if uid is null then raise exception 'not signed in'; end if;
  update public.profiles set
    practice_xp = practice_xp + safe_xp
  where id = uid returning * into prof;
  return prof;
end $$;

-- P0 FIX: Strict bounds on local stat imports (score cannot exceed quizzes * 5; max 200 quizzes)
create or replace function public.import_local_stats(
  p_total_score int, p_practice_xp int, p_quizzes int,
  p_streak int, p_best_streak int, p_last_quiz_date date, p_last_quiz_score int)
returns public.profiles
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
  prof public.profiles;
  safe_quizzes int := least(greatest(coalesce(p_quizzes, 0), 0), 200);
  safe_score int := least(greatest(coalesce(p_total_score, 0), 0), safe_quizzes * 5);
  safe_xp int := least(greatest(coalesce(p_practice_xp, 0), 0), 500);
  safe_streak int := least(greatest(coalesce(p_streak, 0), 0), 365);
  safe_best_streak int := least(greatest(coalesce(p_best_streak, 0), 0), 365);
begin
  if uid is null then raise exception 'not signed in'; end if;
  select * into prof from public.profiles where id = uid;
  if prof.stats_imported then return prof; end if;

  update public.profiles p set
    total_score = p.total_score + safe_score,
    practice_xp = p.practice_xp + safe_xp,
    quizzes_completed = p.quizzes_completed + safe_quizzes,
    streak = case when p.last_quiz_date is null then safe_streak else p.streak end,
    best_streak = greatest(p.best_streak, safe_best_streak),
    last_quiz_date = case when p.last_quiz_date is null
      and p_last_quiz_date <= public.quiz_today() then p_last_quiz_date else p.last_quiz_date end,
    last_quiz_score = case when p.last_quiz_date is null
      then least(greatest(coalesce(p_last_quiz_score, 0), 0), 5) else p.last_quiz_score end,
    stats_imported = true
  where p.id = uid returning * into prof;
  return prof;
end $$;

-- P0 FIX: Mandatory In-App Account Deletion (Apple App Store & Google Play Store Compliance)
create or replace function public.delete_my_account()
returns boolean
language plpgsql security definer set search_path = public as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then raise exception 'not signed in'; end if;
  -- Cascades to profiles, bookmarks, and daily_results
  delete from auth.users where id = uid;
  return true;
end $$;

-- Leaderboard: students only, top 100 with accurate user ranking
create or replace function public.get_leaderboard(p_filter text default 'allTime')
returns table (
  member_code text, name text, age_group text, total_score int,
  streak int, best_streak int, last_quiz_date date, last_quiz_score int,
  today_score int, is_me boolean)
language sql stable security definer set search_path = public as $$
  with base as (
    select p.*,
      case when p.last_quiz_date >= public.quiz_today() - 1 then p.streak else 0 end as live_streak,
      d.score as today
    from public.profiles p
    left join public.daily_results d
      on d.user_id = p.id and d.quiz_date = public.quiz_today()
    where p.role = 'student' and p.name <> ''
  )
  select member_code, name, age_group, total_score, streak, best_streak,
         last_quiz_date, last_quiz_score, today, id = auth.uid()
  from base
  order by
    case when p_filter = 'today' then (today is not null)::int end desc nulls last,
    case when p_filter = 'today' then coalesce(today, 0) end desc nulls last,
    case when p_filter = 'streak' then live_streak end desc nulls last,
    total_score desc,
    live_streak desc,
    created_at
  limit 100
$$;

revoke all on function public.submit_daily_result(date, int) from public, anon;
revoke all on function public.add_practice_xp(int) from public, anon;
revoke all on function public.import_local_stats(int, int, int, int, int, date, int) from public, anon;
revoke all on function public.get_leaderboard(text) from public, anon;
revoke all on function public.delete_my_account() from public, anon;

grant execute on function public.submit_daily_result(date, int) to authenticated;
grant execute on function public.add_practice_xp(int) to authenticated;
grant execute on function public.import_local_stats(int, int, int, int, int, date, int) to authenticated;
grant execute on function public.get_leaderboard(text) to authenticated;
grant execute on function public.delete_my_account() to authenticated;

revoke all on function public.generate_member_code() from public, anon, authenticated;
revoke all on function public.handle_new_user() from public, anon, authenticated;
