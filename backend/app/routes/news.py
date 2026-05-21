from fastapi import APIRouter
import requests

from app.utils.config import NEWS_API_KEY
from app.services.ai_service import summarize_news

router = APIRouter()


@router.get("/news")
def get_news():

    url = f"https://newsapi.org/v2/top-headlines?country=us&apiKey={NEWS_API_KEY}"

    response = requests.get(url)

    data = response.json()

    articles = data.get("articles", [])

    news_list = []

    for article in articles[:5]:

        title = article.get("title")
        description = article.get("description")

        full_text = f"{title}. {description}"

        ai_summary = summarize_news(full_text)

        news_list.append({
            "title": title,
            "summary": ai_summary,
            "image": article.get("urlToImage"),
            "source": article.get("source", {}).get("name"),
            "url": article.get("url")
        })

    return news_list