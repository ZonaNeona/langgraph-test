import os
from supabase import create_client, Client
from langchain_core.tools import tool

# Подключаемся к Supabase (ключи из .env)
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_KEY")
)

@tool
def search_knowledge_base(query: str) -> str:
    """Ищет релевантные инсайты и гипотезы из базы знаний по запросу пользователя."""
    # Пока простой текстовый поиск (работает даже без эмбеддингов)
    # Если у тебя есть эмбеддинги — потом заменим на векторный поиск
    response = supabase.table("insights") \
        .select("content, metadata") \
        .text_search("content", query) \
        .limit(5) \
        .execute()

    if not response.data:
        return "В базе знаний ничего не найдено по этому запросу."

    results = []
    for item in response.data:
        meta = item.get("metadata", {})
        results.append(f"Инсайт: {item['content']}\nМетаданные: {meta}")

    return "\n\n".join(results)