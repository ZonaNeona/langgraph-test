-- Расширение knowledge_base для трассировки и уровней доверия.
-- Выполните в Supabase SQL Editor или через CLI миграций.

alter table public.knowledge_base
  add column if not exists source_tier text default 'community';

alter table public.knowledge_base
  add column if not exists verification_status text default 'candidate';

alter table public.knowledge_base
  add column if not exists observed_at timestamptz default now();

alter table public.knowledge_base
  add column if not exists run_id text;

comment on column public.knowledge_base.source_tier is
  'official | expert | community | unofficial';

comment on column public.knowledge_base.verification_status is
  'draft | candidate | verified';
