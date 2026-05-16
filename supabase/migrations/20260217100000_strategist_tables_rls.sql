-- Политики RLS для таблиц Стратега (backend с anon/authenticated ключом из .env).
-- Без политик при включённом RLS INSERT падает: 42501 new row violates row-level security policy.

alter table public.strategist_reflections enable row level security;
alter table public.strategist_hypotheses enable row level security;
alter table public.project_state enable row level security;
alter table public.strategic_memory enable row level security;

-- strategist_reflections
drop policy if exists "strategist_reflections_rw_anon" on public.strategist_reflections;
create policy "strategist_reflections_rw_anon"
  on public.strategist_reflections
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- strategist_hypotheses
drop policy if exists "strategist_hypotheses_rw_anon" on public.strategist_hypotheses;
create policy "strategist_hypotheses_rw_anon"
  on public.strategist_hypotheses
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- project_state (upsert = insert + update)
drop policy if exists "project_state_rw_anon" on public.project_state;
create policy "project_state_rw_anon"
  on public.project_state
  for all
  to anon, authenticated
  using (true)
  with check (true);

-- strategic_memory
drop policy if exists "strategic_memory_rw_anon" on public.strategic_memory;
create policy "strategic_memory_rw_anon"
  on public.strategic_memory
  for all
  to anon, authenticated
  using (true)
  with check (true);

comment on policy "strategist_reflections_rw_anon" on public.strategist_reflections is
  'MVP: полный доступ с anon-ключом. В проде заменить на service_role только с бэкенда или узкие политики.';
