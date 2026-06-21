from pydantic import BaseModel, Field


# ───── Чат із AI-асистентом ─────

class ChatMessage(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatRequest(BaseModel):
    messages: list[ChatMessage]
    # Опційний профіль/контекст користувача для асистента.
    user_id: str | None = None


class ChatResponse(BaseModel):
    reply: str


# ───── Калорії по фото ─────

class FoodItem(BaseModel):
    name: str = Field(description="Назва страви або інгредієнта")
    calories: float = Field(description="Калорії, ккал")
    protein: float = Field(description="Білки, г")
    fat: float = Field(description="Жири, г")
    carbs: float = Field(description="Вуглеводи, г")


class FoodAnalysis(BaseModel):
    items: list[FoodItem]
    total_calories: float
    total_protein: float
    total_fat: float
    total_carbs: float
    notes: str | None = None


# ───── Профіль користувача ─────

class Profile(BaseModel):
    goal: str | None = Field(default=None, description="Ціль: схуднення / марафон / підтримка форми тощо")
    experience_level: str | None = Field(default=None, description="beginner | intermediate | advanced")
    weight_kg: float | None = None
    height_cm: float | None = None
    age: int | None = None
    weekly_target_runs: int | None = Field(default=None, description="Цільова кількість пробіжок на тиждень")
    notes: str | None = None


# ───── Синхронізація тренувань ─────

class WorkoutSync(BaseModel):
    id: str
    activity_type: str
    start_date: str
    end_date: str
    distance_meters: float
    steps: int
    active_calories: float
    average_heart_rate: float
    max_heart_rate: float
