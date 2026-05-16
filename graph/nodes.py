import os
import json
from datetime import datetime
from langchain_openai import ChatOpenAI
from graph.state import AdState
from graph.tools import search_knowledge_base   # ← новый импорт

llm = ChatOpenAI(
    model="openai/gpt-4o-mini",
    api_key=os.getenv("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# НОВЫЙ ПЕРВЫЙ УЗЕЛ — из промпта рождаем черновик
def generate_initial_ad(state: AdState):
    # Сначала LLM вызывает Tool и получает знания из Supabase
    knowledge = search_knowledge_base.invoke(state["user_prompt"])

    prompt = f"""Ты — лучший копирайтер Авито по неоновым вывескам.

Пользовательский запрос: {state["user_prompt"]}

Вот релевантные инсайты и гипотезы из нашей базы знаний:
{knowledge}

Используй эти инсайты, чтобы сделать **реально продающее** объявление:
- Заголовок: 25–45 символов, обязательно "неон" / "неоновая"
- Описание: 120–220 символов, естественный язык, по делу

Ответь **только** JSON:
{{
  "title": "тут заголовок",
  "description": "тут описание"
}}"""

    result = llm.invoke(prompt)
    
    try:
        data = json.loads(result.content.strip())
        title = data["title"].strip()
        desc = data["description"].strip()
        
        return {
            "initial_title": title,
            "initial_description": desc,
            "improved_title": title,
            "improved_description": desc,
            "title_history": [title],
            "description_history": [desc]
        }
    except:
        return {
            "initial_title": "Неоновая вывеска",
            "initial_description": "Красивая неоновая вывеска",
            "improved_title": "Неоновая вывеска",
            "improved_description": "Красивая неоновая вывеска",
            "title_history": ["Неоновая вывеска"],
            "description_history": ["Красивая неоновая вывеска"]
        }

def improve_title(state: AdState):
    prompt = f"""Улучши заголовок. Жёсткие правила:
- 20–50 символов
- обязательно "неон" / "неоновая"
- без капса и спама

Текущий заголовок: {state["improved_title"]}

Ответь ТОЛЬКО одним заголовком:"""

    result = llm.invoke(prompt)
    improved = result.content.strip()
    return {
        "improved_title": improved,
        "attempt_count": state.get("attempt_count", 0) + 1,
        "title_history": [improved]
    }

def improve_description(state: AdState):
    prompt = f"""Улучши описание. Делай спокойно, по делу.

Текущее описание: {state["improved_description"]}

Ответь ТОЛЬКО улучшенным описанием (100–250 символов, упомяни "неон"):"""

    result = llm.invoke(prompt)
    improved = result.content.strip()
    return {
        "improved_description": improved,
        "description_history": [improved]
    }

def validate_title(state: AdState):
    title = state.get("improved_title") or ""
    errors = []

    if len(title) < 20: errors.append("Слишком короткий")
    if len(title) > 50: errors.append("Слишком длинный")
    if "неон" not in title.lower(): errors.append("Нет слова 'неон'")
    if title.isupper(): errors.append("Капс запрещен")

    approved = len(errors) == 0

    return {
        "validation_errors": errors,
        "approved": approved
    }

def human_review(state: AdState):
    print("\n" + "="*60)
    print("🤖 ГОТОВОЕ ОБЪЯВЛЕНИЕ")
    print("="*60)
    print(f"Заголовок: {state.get('improved_title')}")
    print(f"\nОписание:\n{state.get('improved_description')}")
    print(f"\nПопыток улучшения: {state.get('attempt_count')}")
    print("="*60)

    while True:
        answer = input("\nНравится? (y — сохранить / n — переделать): ").strip().lower()
        if answer in ["y", "yes", "да"]:
            return {"final_approved": True}
        elif answer in ["n", "no", "нет"]:
            return {"final_approved": False, "approved": False}
        else:
            print("Просто y или n")

def save_ad(state: AdState):
    ad_data = {
        "timestamp": datetime.now().isoformat(),
        "user_prompt": state["user_prompt"],
        "final_title": state["improved_title"],
        "final_description": state["improved_description"],
        "attempts": state["attempt_count"]
    }

    filename = "generated_ads.json"
    if os.path.exists(filename):
        with open(filename, "r", encoding="utf-8") as f:
            data = json.load(f)
    else:
        data = []
    data.append(ad_data)

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ Сохранено в {filename}!")
    return {"saved": True}