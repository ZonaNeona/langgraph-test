-- Явные права на таблицы Стратега: без GRANT anon получает «permission denied»,
-- с GRANT но без политик RLS — «42501 violates row-level security».
-- Политики см. 20260217100000_strategist_tables_rls.sql

grant select, insert, update, delete on table public.strategist_reflections to anon, authenticated;
grant select, insert, update, delete on table public.strategist_hypotheses to anon, authenticated;
grant select, insert, update, delete on table public.project_state to anon, authenticated;
grant select, insert, update, delete on table public.strategic_memory to anon, authenticated;
