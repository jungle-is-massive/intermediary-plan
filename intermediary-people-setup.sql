-- ═══════════════════════════════════════════════════════════════
-- INTERMEDIARY PEOPLE TABLE
-- Stores contacts associated with intermediary organisations
-- Used by: https://jungle-is-massive.github.io/intermediary-plan/
-- And: Jungle Intermediary Contacts Chrome extension
-- ═══════════════════════════════════════════════════════════════

create table if not exists intermediary_people (
  id uuid primary key default gen_random_uuid(),
  org_id text not null,              -- References hardcoded org IDs: aar, ingenuity, creativebrief, etc.
  name text not null,
  title text,
  role text,                          -- e.g. "Decision maker", "Longlist builder", "Sector specialist"
  warmth text default 'neutral',      -- warm | neutral | cold
  influence text default 'medium',    -- high | medium | low
  notes text,
  linkedin_url text,
  email text,
  phone text,
  source text,                        -- 'page' | 'chrome-extension' | 'import' | 'manual'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists intermediary_people_org_idx on intermediary_people(org_id);
create index if not exists intermediary_people_created_idx on intermediary_people(created_at desc);

-- Enable RLS with open anon policy (matches existing tables)
alter table intermediary_people enable row level security;

drop policy if exists "anon all access" on intermediary_people;
create policy "anon all access" on intermediary_people
  for all to anon
  using (true)
  with check (true);

-- Auto-update updated_at timestamp
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists intermediary_people_updated_at on intermediary_people;
create trigger intermediary_people_updated_at
  before update on intermediary_people
  for each row execute function set_updated_at();
