-- Рефлексия после прогона Стратега + черновики гипотез (MVP belief layer).

create table if not exists public.strategist_reflections (
  id uuid primary key default gen_random_uuid(),
  run_id text not null,
  section text,
  user_message text,
  assistant_excerpt text,
  payload jsonb not null,
  reflection_model text,
  created_at timestamptz not null default now()
);

create index if not exists strategist_reflections_run_id_idx
  on public.strategist_reflections (run_id);

create index if not exists strategist_reflections_created_at_idx
  on public.strategist_reflections (created_at desc);

comment on table public.strategist_reflections is
  'Пост-анализ прогона: противоречия, открытые вопросы, кандидаты в гипотезы (JSON).';

create table if not exists public.strategist_hypotheses (
  id uuid primary key default gen_random_uuid(),
  statement text not null,
  confidence numeric(5, 4) not null default 0.5000,
  status text not null default 'draft',
  topic text not null default 'avito',
  evidence_count int not null default 0,
  contradictions_count int not null default 0,
  last_verified_at timestamptz,
  source_run_id text,
  rationale text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint strategist_hypotheses_status_check
    check (status in ('draft', 'likely', 'disputed', 'archived')),
  constraint strategist_hypotheses_confidence_check
    check (confidence >= 0 and confidence <= 1)
);

create index if not exists strategist_hypotheses_topic_status_idx
  on public.strategist_hypotheses (topic, status);

create index if not exists strategist_hypotheses_source_run_idx
  on public.strategist_hypotheses (source_run_id);

comment on table public.strategist_hypotheses is
  'Гипотезы и устойчивые выводы; evidence/contradictions пополняются отдельными пайплайнами.';
