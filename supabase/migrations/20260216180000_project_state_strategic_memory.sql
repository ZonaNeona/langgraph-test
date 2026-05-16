-- Сжатое состояние проекта + стратегические решения (не чат-лог).

create table if not exists public.project_state (
  project_key text primary key default 'default',
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by_run_id text
);

comment on table public.project_state is
  'Evolving снимок фокуса/проблем/направления; обновляется рефлексией, не руками в чате.';

insert into public.project_state (project_key, payload)
values (
  'default',
  jsonb_build_object(
    'current_focus', jsonb_build_array(),
    'current_stage', '',
    'main_problems', jsonb_build_array(),
    'architecture_direction', jsonb_build_array(),
    'recent_changes', jsonb_build_array(),
    'notes', ''
  )
)
on conflict (project_key) do nothing;

create table if not exists public.strategic_memory (
  id uuid primary key default gen_random_uuid(),
  decision text not null,
  reason text,
  project_key text not null default 'default',
  source_run_id text,
  confidence numeric(5, 4),
  status text not null default 'active',
  created_at timestamptz not null default now(),
  constraint strategic_memory_status_check check (status in ('active', 'superseded', 'archived'))
);

create index if not exists strategic_memory_project_created_idx
  on public.strategic_memory (project_key, created_at desc);

comment on table public.strategic_memory is
  'Принятые решения и уроки (почему так, от чего отказались); пополняется из рефлексии.';
