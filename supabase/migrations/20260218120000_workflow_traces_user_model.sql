-- V2 Phase 1: трассировка прогона LangGraph + слой user_model (операционная модель взаимодействия).

create table if not exists public.strategist_workflow_runs (
  id uuid primary key default gen_random_uuid(),
  run_id text not null,
  section text,
  graph_path jsonb not null default '[]'::jsonb,
  tool_trace jsonb not null default '[]'::jsonb,
  reflection_summary jsonb,
  user_message_excerpt text,
  assistant_excerpt text,
  created_at timestamptz not null default now()
);

create index if not exists strategist_workflow_runs_run_id_idx
  on public.strategist_workflow_runs (run_id);

create index if not exists strategist_workflow_runs_created_at_idx
  on public.strategist_workflow_runs (created_at desc);

comment on table public.strategist_workflow_runs is
  'Наблюдаемость: путь по графу оркестрации, сжатые tool-вызовы, итог рефлексии.';

-- Один снимок на project_key (как project_state): стиль коммуникации, повторяющиеся интересы и т.д.
create table if not exists public.user_model (
  project_key text primary key default 'default',
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by_run_id text
);

comment on table public.user_model is
  'Операционная модель пользователя/фаундера (не психология): предпочтения и паттерны для контекста.';

insert into public.user_model (project_key, payload)
values ('default', '{}'::jsonb)
on conflict (project_key) do nothing;

alter table public.strategist_workflow_runs enable row level security;
alter table public.user_model enable row level security;

drop policy if exists "strategist_workflow_runs_rw_anon" on public.strategist_workflow_runs;
create policy "strategist_workflow_runs_rw_anon"
  on public.strategist_workflow_runs
  for all
  to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "user_model_rw_anon" on public.user_model;
create policy "user_model_rw_anon"
  on public.user_model
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on table public.strategist_workflow_runs to anon, authenticated;
grant select, insert, update, delete on table public.user_model to anon, authenticated;
