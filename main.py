from dotenv import load_dotenv
load_dotenv()

from graph.graph import graph

print("🚀 Avito Neon Ad Generator")
print("Пиши промпт, например:")
print("   Создай объявление для бара")
print("   Неоновая вывеска для кофейни")
print("   Сделай вывеску в квартиру\n")
print("Напиши 'exit' чтобы выйти\n")

while True:
    user_prompt = input("Твой запрос: ").strip()
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

    print("\nГенерируем объявление...")
    result = graph.invoke(initial_state)

    print("\n🎉 ГОТОВО!")