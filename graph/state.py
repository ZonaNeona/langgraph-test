from typing import TypedDict, List, Optional, Annotated

class AdState(TypedDict):
    # Новый главный вход — то, что пишет пользователь
    user_prompt: str
    
    # То, что будет генерироваться автоматически
    initial_title: Optional[str]
    initial_description: Optional[str]
    
    improved_title: Optional[str]
    improved_description: Optional[str]
    
    validation_errors: List[str]
    approved: bool
    final_approved: bool
    
    attempt_count: int
    
    # История (будет очень полезно потом)
    title_history: Annotated[List[str], lambda a, b: a + b]
    description_history: Annotated[List[str], lambda a, b: a + b]