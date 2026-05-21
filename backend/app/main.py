from fastapi import FastAPI
from app.routes.news import router as news_router

app = FastAPI()

app.include_router(news_router)

@app.get("/")
def home():
    return {"message": "AI News Backend Running"}