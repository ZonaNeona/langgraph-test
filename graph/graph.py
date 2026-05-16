from langgraph.graph import StateGraph, END
from graph.state import AdState
from graph.nodes import (
    generate_initial_ad,
    improve_title,
    improve_description,
    validate_title,
    human_review,
    save_ad
)

builder = StateGraph(AdState)

builder.add_node("generate_initial_ad", generate_initial_ad)
builder.add_node("improve_title", improve_title)
builder.add_node("improve_description", improve_description)
builder.add_node("validate_title", validate_title)
builder.add_node("human_review", human_review)
builder.add_node("save_ad", save_ad)

builder.set_entry_point("generate_initial_ad")

builder.add_edge("generate_initial_ad", "improve_title")
builder.add_edge("improve_title", "improve_description")
builder.add_edge("improve_description", "validate_title")

def validation_router(state: AdState):
    if not state.get("approved", False):
        return "improve_title"
    return "human_review"

builder.add_conditional_edges("validate_title", validation_router)

def human_router(state: AdState):
    if state.get("final_approved", False):
        return "save_ad"
    return "improve_title"

builder.add_conditional_edges("human_review", human_router)
builder.add_edge("save_ad", END)

graph = builder.compile()