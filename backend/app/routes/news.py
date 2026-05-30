from fastapi import APIRouter
import requests
import asyncio
import anyio
from pydantic import BaseModel
from typing import List

from app.utils.config import NEWS_API_KEY
from app.services.ai_service import (
    summarize_news,
    get_priority_score,
    generate_tldr,
    generate_eli5,
    generate_impact,
    chat_about_article,
)
from app.database.cache import (
    get_cached_news,
    cache_articles,
    get_cached_quick_action,
    update_cached_quick_action,
)

router = APIRouter()


class ChatMessage(BaseModel):
    role: str  # 'user' or 'model'
    content: str


class ChatRequest(BaseModel):
    title: str
    summary: str
    history: List[ChatMessage]
    message: str


class QuickActionRequest(BaseModel):
    title: str
    content: str


async def enrich_article(article, use_ai: bool, default_priority: int):
    title = article.get("title") or ""
    description = article.get("description") or ""
    
    if use_ai and (title or description):
        text_to_analyze = f"Title: {title}\nDescription: {description}"
        try:
            # Execute Gemini client operations in parallel worker threads to prevent blocking FastAPI
            summary_task = anyio.to_thread.run_sync(summarize_news, text_to_analyze)
            score_task = anyio.to_thread.run_sync(get_priority_score, text_to_analyze)
            
            summary, score = await asyncio.gather(summary_task, score_task)
            summary = summary.strip() if summary else (description or "No summary available.")
            try:
                score = int(score)
            except:
                score = default_priority
        except Exception as e:
            # Resilient fallback on any Gemini/network failure
            summary = description or "No summary available."
            score = default_priority
    else:
        summary = description or "No summary available."
        score = default_priority
        
    return {
        "title": title,
        "summary": summary,
        "priority": score,
        "image": article.get("urlToImage"),
        "source": article.get("source", {}).get("name"),
        "url": article.get("url")
    }


@router.get("/news/{category}")
async def get_news(category: str):
    # 1. Query local SQLite cache first for fresh articles (max age 1 hour)
    try:
        cached_articles = get_cached_news(category, max_age_seconds=3600)
        if cached_articles and len(cached_articles) >= 5:
            # Successfully loaded fresh cache, return instantly!
            return cached_articles
    except Exception as e:
        # Fall through on database read failures to guarantee uptime
        pass

    # 2. Fetch fresh news from NewsAPI on cache miss
    url = f"https://newsapi.org/v2/top-headlines?country=us&category={category}&apiKey={NEWS_API_KEY}"
    response = requests.get(url)
    data = response.json()
    articles = data.get("articles", [])

    tasks = []
    priority = 100

    for i, article in enumerate(articles[:10]):
        # Run Gemini AI enrichment only on top 5 articles to stay within rate limits and keep it ultra-fast
        use_ai = i < 5
        tasks.append(enrich_article(article, use_ai, priority))
        priority -= 10

    news_list = await asyncio.gather(*tasks)

    # Bubbles high-priority/breaking news to the top of the feed
    news_list.sort(key=lambda x: x.get("priority", 0), reverse=True)

    # 3. Store in local SQLite database cache for sub-millisecond future queries
    try:
        cache_articles(news_list, category)
    except Exception as e:
        pass

    return news_list


@router.get("/search/{query}")
async def search_news(query: str):

    url = f"https://newsapi.org/v2/everything?q={query}&apiKey={NEWS_API_KEY}"

    response = requests.get(url)

    data = response.json()

    articles = data.get("articles", [])

    tasks = []

    for i, article in enumerate(articles[:10]):
        use_ai = i < 5
        tasks.append(enrich_article(article, use_ai, 50))

    news_list = await asyncio.gather(*tasks)

    news_list.sort(key=lambda x: x.get("priority", 0), reverse=True)

    return news_list


@router.post("/news/chat")
async def chat_with_article_endpoint(request: ChatRequest):
    history_list = [{"role": msg.role, "content": msg.content} for msg in request.history]
    response = await anyio.to_thread.run_sync(
        chat_about_article,
        request.title,
        request.summary,
        history_list,
        request.message
    )
    return {"response": response}


@router.post("/news/tldr")
async def tldr_endpoint(request: QuickActionRequest):
    # 1. Query SQLite cache by article title first
    try:
        cached = get_cached_quick_action(request.title, "tldr")
        if cached:
            return {"response": cached}
    except Exception as e:
        pass

    # 2. Generate new TL;DR if cache misses
    response = await anyio.to_thread.run_sync(
        generate_tldr,
        request.title,
        request.content
    )

    # 3. Save response in the cache
    try:
        update_cached_quick_action(request.title, "tldr", response)
    except Exception as e:
        pass

    return {"response": response}


@router.post("/news/eli5")
async def eli5_endpoint(request: QuickActionRequest):
    # 1. Query SQLite cache by article title first
    try:
        cached = get_cached_quick_action(request.title, "eli5")
        if cached:
            return {"response": cached}
    except Exception as e:
        pass

    # 2. Generate new ELI5 if cache misses
    response = await anyio.to_thread.run_sync(
        generate_eli5,
        request.title,
        request.content
    )

    # 3. Save response in the cache
    try:
        update_cached_quick_action(request.title, "eli5", response)
    except Exception as e:
        pass

    return {"response": response}


@router.post("/news/impact")
async def impact_endpoint(request: QuickActionRequest):
    # 1. Query SQLite cache by article title first
    try:
        cached = get_cached_quick_action(request.title, "impact")
        if cached:
            return {"response": cached}
    except Exception as e:
        pass

    # 2. Generate new Impact analysis if cache misses
    response = await anyio.to_thread.run_sync(
        generate_impact,
        request.title,
        request.content
    )

    # 3. Save response in the cache
    try:
        update_cached_quick_action(request.title, "impact", response)
    except Exception as e:
        pass

    return {"response": response}