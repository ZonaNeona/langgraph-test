from dotenv import load_dotenv
load_dotenv()

from graph.graph import graph

print("🚀 Avito Neon Ad Generator (с памятью!)")
print("Пиши промпт, например:")
print("   Создай объявление для бара")
print("   Неоновая вывеска для кофейни")
print("   Сделай вывеску в квартиру\n")
print("Напиши 'exit' чтобы выйти\n")

# Каждый запуск будет использовать свой thread_id (можно потом делать разные сессии)
thread_id = "session_1"   # можешь менять вручную, чтобы тестировать память

while True:
    user_prompt = input("\nТвой запрос: ").strip()
    if user_prompt.lower() == "exit":
        break
    if not user_prompt:
        continue

    initial_state = {
        "user_prompt": user_prompt,
        "initial_title": None,
        "initial_description": None,
        "improved_title": None,
        "improved_description": None,
        "validation_errors": [],
        "approved": False,
        "final_approved": False,
        "attempt_count": 0,
        "title_history": [],
        "description_history": [],
        "saved": False
    }

    config = {"configurable": {"thread_id": thread_id}}

    print("\nГенерируем объявление...")
    result = graph.invoke(initial_state, config=config)

    print("\n🎉 ГОТОВО! (состояние сохранено в checkpoints.db)")