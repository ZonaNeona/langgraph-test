-- Долгоживущие артефакты Стратега: планы, чек-листы, матрицы заголовков (не atomic knowledge_base).

create table if not exists public.strategist_plans (
  id uuid primary key default gen_random_uuid(),
  section text not null default 'strategist',
  title text not null,
  body text not null,
  kind text not null default 'plan',
  source_run_id text,
  created_at timestamptz not null default now(),
  constraint strategist_plans_kind_check check (
    kind in ('plan', 'checklist', 'headlines', 'playbook', 'other')
  )
);

create index if not exists strategist_plans_section_created_idx
  on public.strategist_plans (section, created_at desc);

comment on table public.strategist_plans is
  'Сохранённые планы и списки из ответов Стратега (tool save_plan); не дословный чат-лог.';

alter table public.strategist_plans enable row level security;

drop policy if exists "strategist_plans_rw_anon" on public.strategist_plans;
create policy "strategist_plans_rw_anon"
  on public.strategist_plans
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on table public.strategist_plans to anon, authenticated;
