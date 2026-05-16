-- Снимки префлайта Аналитика (метрики по списку объявлений до основного ответа Стратега).

create table if not exists public.analyst_snapshots (
  id uuid primary key default gen_random_uuid(),
  run_id text not null,
  section text,
  item_ids jsonb not null default '[]'::jsonb,
  snapshot jsonb,
  interpretation text,
  error text,
  created_at timestamptz not null default now()
);

create index if not exists analyst_snapshots_run_id_idx
  on public.analyst_snapshots (run_id);

create index if not exists analyst_snapshots_created_at_idx
  on public.analyst_snapshots (created_at desc);

comment on table public.analyst_snapshots is
  'Префлайт / POST /analyst: сырые чанки stats + опционально interpretation; связь с прогоном Стратега по run_id.';

alter table public.analyst_snapshots enable row level security;

drop policy if exists "analyst_snapshots_rw_anon" on public.analyst_snapshots;
create policy "analyst_snapshots_rw_anon"
  on public.analyst_snapshots
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on table public.analyst_snapshots to anon, authenticated;
