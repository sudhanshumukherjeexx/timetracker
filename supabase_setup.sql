-- CHRONOS / timetracker — run in Supabase SQL Editor after creating a project.
-- 1) Authentication → Providers: enable Email (magic link) and Google.
--    Use YOUR Google Cloud OAuth client (not the default): Supabase → Google provider → Client ID + Secret.
--    In Google Cloud Console → OAuth consent screen: set App name to "TYME" (and logo). That text is what
--    users see on the Google sign-in page instead of a raw *.supabase.co hostname.
--    Authorized redirect URI (Google Cloud): https://<project-ref>.supabase.co/auth/v1/callback
-- 2) Authentication → URL configuration: add your site URL and redirect URLs
--    (e.g. https://yourname.github.io/timetracker/ and http://localhost:port/...).

create table if not exists public.user_timers (
  user_id uuid primary key references auth.users (id) on delete cascade,
  events jsonb not null default '[]'::jsonb,
  settings jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.user_timers enable row level security;

create policy "user_timers_select_own"
  on public.user_timers for select
  using (auth.uid() = user_id);

create policy "user_timers_insert_own"
  on public.user_timers for insert
  with check (auth.uid() = user_id);

create policy "user_timers_update_own"
  on public.user_timers for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "user_timers_delete_own"
  on public.user_timers for delete
  using (auth.uid() = user_id);

grant select, insert, update, delete on table public.user_timers to authenticated;
