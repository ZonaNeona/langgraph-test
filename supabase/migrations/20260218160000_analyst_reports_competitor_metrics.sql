-- Этап 1: структурированные отчёты Аналитика (JSON + краткий текст).
-- Этап 2: снимки выдачи / страницы поиска (сырьё + опционально summary).
-- Этап 3: последние метрики по объявлению в кэше avito_items.

create table if not exists public.analyst_reports (
  id uuid primary key default gen_random_uuid(),
  run_id text,
  section text,
  item_ids jsonb not null default '[]'::jsonb,
  period jsonb not null default '{}'::jsonb,
  snapshot jsonb,
  structured_report jsonb not null default '{}'::jsonb,
  narrative text,
  model text,
  created_at timestamptz not null default now()
);

create index if not exists analyst_reports_created_idx
  on public.analyst_reports (created_at desc);

create index if not exists analyst_reports_run_id_idx
  on public.analyst_reports (run_id);

comment on table public.analyst_reports is
  'Структурированный отчёт Аналитика по набору объявлений (метрики + LLM-разбор).';

create table if not exists public.competitor_snapshots (
  id uuid primary key default gen_random_uuid(),
  search_url text not null,
  source text not null default 'tavily_extract',
  raw_excerpt text,
  payload jsonb not null default '{}'::jsonb,
  summary text,
  model text,
  created_at timestamptz not null default now()
);

create index if not exists competitor_snapshots_created_idx
  on public.competitor_snapshots (created_at desc);

comment on table public.competitor_snapshots is
  'Снимок страницы выдачи (URL) через Tavily extract + опционально краткое резюме LLM.';

alter table public.avito_items
  add column if not exists last_stats jsonb;

alter table public.avito_items
  add column if not exists last_stats_at timestamptz;

comment on column public.avito_items.last_stats is
  'Последний ответ shallow stats API для пары (user, item); обновляется скриптом sync_avito_item_stats.';

alter table public.analyst_reports enable row level security;
alter table public.competitor_snapshots enable row level security;

drop policy if exists "analyst_reports_rw_anon" on public.analyst_reports;
create policy "analyst_reports_rw_anon"
  on public.analyst_reports for all to anon, authenticated using (true) with check (true);

drop policy if exists "competitor_snapshots_rw_anon" on public.competitor_snapshots;
create policy "competitor_snapshots_rw_anon"
  on public.competitor_snapshots for all to anon, authenticated using (true) with check (true);

grant select, insert, update, delete on table public.analyst_reports to anon, authenticated;
grant select, insert, update, delete on table public.competitor_snapshots to anon, authenticated;
