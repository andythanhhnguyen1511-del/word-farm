-- =====================================================================
-- Word Farm — Supabase setup
-- Run this once in your Supabase project: SQL Editor → New query → paste → Run.
-- It creates one table for the children's data and a private bucket for
-- the kids' own photos. Row Level Security makes sure every parent account
-- can only read and change its own children.
-- =====================================================================

-- One row per child. "state" holds that child's word lists, progress and garden.
create table if not exists public.children (
  owner      uuid        not null default auth.uid() references auth.users(id) on delete cascade,
  id         text        not null,
  name       text        not null,
  avatar     text        not null default '🐰',
  state      jsonb       not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted    boolean     not null default false,   -- kept so other devices learn about deletions
  primary key (owner, id)
);

alter table public.children enable row level security;

-- Newer Supabase projects no longer open new tables to the app automatically.
-- Signed-in parents need these rights; Row Level Security below still limits them to their own rows.
-- (No rights for "anon": people who are not signed in cannot touch this table at all.)
grant select, insert, update, delete on table public.children to authenticated;

drop policy if exists "children: read own"   on public.children;
drop policy if exists "children: insert own" on public.children;
drop policy if exists "children: update own" on public.children;
drop policy if exists "children: delete own" on public.children;

create policy "children: read own"   on public.children for select using (auth.uid() = owner);
create policy "children: insert own" on public.children for insert with check (auth.uid() = owner);
create policy "children: update own" on public.children for update using (auth.uid() = owner) with check (auth.uid() = owner);
create policy "children: delete own" on public.children for delete using (auth.uid() = owner);

-- Private bucket for photos the kids upload for a word. Files are stored as <user id>/<word id>.jpg
insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

drop policy if exists "photos: read own"   on storage.objects;
drop policy if exists "photos: insert own" on storage.objects;
drop policy if exists "photos: update own" on storage.objects;
drop policy if exists "photos: delete own" on storage.objects;

create policy "photos: read own" on storage.objects for select
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: insert own" on storage.objects for insert
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: update own" on storage.objects for update
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "photos: delete own" on storage.objects for delete
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
