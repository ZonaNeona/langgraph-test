-- Локальная копия объявлений Авито для аналитики (синк из API, не источник правды для правок на площадке).
-- Источник строк: GET https://api.avito.ru/core/v1/items (см. AvitoReadOnlyClient.get_items).
-- Детализация (опционально позже): GET /core/v1/accounts/{user_id}/items/{item_id}/

create table if not exists public.avito_items (
  id uuid primary key default gen_random_uuid(),
  avito_user_id bigint not null,
  item_id bigint not null,
  title text,
  status text,
  url text,
  category_id bigint,
  price numeric,
  raw jsonb not null default '{}'::jsonb,
  synced_at timestamptz not null default now(),
  unique (avito_user_id, item_id)
);

create index if not exists avito_items_user_status_idx
  on public.avito_items (avito_user_id, status);

create index if not exists avito_items_user_synced_idx
  on public.avito_items (avito_user_id, synced_at desc);

create index if not exists avito_items_raw_gin
  on public.avito_items using gin (raw);

comment on table public.avito_items is
  'Кэш объявлений из Avito API core v1 items (+ опционально детальный payload в raw).';

alter table public.avito_items enable row level security;

drop policy if exists "avito_items_rw_anon" on public.avito_items;
create policy "avito_items_rw_anon"
  on public.avito_items
  for all
  to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on table public.avito_items to anon, authenticated;
