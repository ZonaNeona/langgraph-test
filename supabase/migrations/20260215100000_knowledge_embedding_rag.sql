-- RAG: векторные эмбеддинги для knowledge_base (pgvector).
-- После применения: задайте OPENROUTER_API_KEY и EMBEDDING_MODEL (по умолчанию openai/text-embedding-3-small, 1536 измерений).
-- Старые строки: python scripts/backfill_knowledge_embeddings.py

create extension if not exists vector;

alter table public.knowledge_base
  add column if not exists embedding vector(1536);

-- Косинусное расстояние (чем меньше — тем ближе)
create index if not exists knowledge_base_embedding_hnsw
  on public.knowledge_base
  using hnsw (embedding vector_cosine_ops);

-- SECURITY DEFINER: RPC с anon-ключом обходит RLS на чтение при необходимости (ограничьте права в проде при желании).
create or replace function public.match_knowledge_base(
  query_embedding vector(1536),
  match_count int default 10
)
returns table (
  id text,
  topic text,
  subtopic text,
  insight text,
  source_url text,
  distance double precision
)
language sql
stable
security definer
set search_path = public
as $$
  select
    kb.id::text,
    kb.topic,
    kb.subtopic,
    kb.insight,
    coalesce(kb.source_url, '') as source_url,
    (kb.embedding <=> query_embedding) as distance
  from public.knowledge_base kb
  where kb.embedding is not null
  order by kb.embedding <=> query_embedding
  limit greatest(1, least(match_count, 50));
$$;

grant execute on function public.match_knowledge_base(vector(1536), integer) to anon, authenticated, service_role;

comment on column public.knowledge_base.embedding is 'OpenRouter/OpenAI embedding; dimension 1536 for text-embedding-3-small';
