from fastapi import APIRouter
import requests

from app.utils.config import NEWS_API_KEY

router = APIRouter()


@router.get("/news/{category}")
def get_news(category: str):

    url = f"https://newsapi.org/v2/top-headlines?country=us&category={category}&apiKey={NEWS_API_KEY}"

    response = requests.get(url)

    data = response.json()

    articles = data.get("articles", [])

    news_list = []

    priority = 100

    for article in articles[:10]:

        news_list.append({

            "title": article.get("title"),

            "summary": article.get("description"),

            "priority": priority,

            "image": article.get("urlToImage"),

            "source": article.get("source", {}).get("name"),

            "url": article.get("url")
        })

        priority -= 10

    return news_list