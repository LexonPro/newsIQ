import sqlite3
import os
import time
from typing import Dict, Any, List, Optional

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "news_cache.db")


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Initializes the SQLite cache database schema."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS article_cache (
            url TEXT PRIMARY KEY,
            title TEXT,
            summary TEXT,
            priority INTEGER,
            image TEXT,
            source TEXT,
            category TEXT,
            tldr TEXT,
            eli5 TEXT,
            impact TEXT,
            created_at REAL
        )
    """)
    conn.commit()
    conn.close()


def get_cached_news(category: str, max_age_seconds: int = 3600) -> List[Dict[str, Any]]:
    """Retrieves fresh cached news articles for a given category."""
    conn = get_db_connection()
    cursor = conn.cursor()
    min_time = time.time() - max_age_seconds
    
    cursor.execute(
        "SELECT * FROM article_cache WHERE category = ? AND created_at > ? ORDER BY priority DESC",
        (category, min_time)
    )
    rows = cursor.fetchall()
    conn.close()
    
    return [dict(row) for row in rows]


def cache_articles(articles: List[Dict[str, Any]], category: str):
    """Caches newly fetched and AI-enriched articles."""
    conn = get_db_connection()
    cursor = conn.cursor()
    now = time.time()
    
    for article in articles:
        cursor.execute(
            """
            INSERT OR REPLACE INTO article_cache 
            (url, title, summary, priority, image, source, category, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                article.get("url"),
                article.get("title"),
                article.get("summary"),
                article.get("priority"),
                article.get("image"),
                article.get("source"),
                category,
                now
            )
        )
        
    conn.commit()
    conn.close()


def get_cached_quick_action(title: str, action_type: str) -> Optional[str]:
    """Retrieves cached TL;DR, ELI5, or Impact analysis by matching article title."""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if action_type not in ('tldr', 'eli5', 'impact'):
        conn.close()
        return None
        
    cursor.execute(f"SELECT {action_type} FROM article_cache WHERE title = ?", (title,))
    row = cursor.fetchone()
    conn.close()
    
    if row and row[action_type]:
        return row[action_type]
    return None


def update_cached_quick_action(title: str, action_type: str, text: str):
    """Saves generated TL;DR, ELI5, or Impact analysis by matching article title."""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if action_type not in ('tldr', 'eli5', 'impact'):
        conn.close()
        return
        
    cursor.execute(
        f"UPDATE article_cache SET {action_type} = ? WHERE title = ?",
        (text, title)
    )
    conn.commit()
    conn.close()


# Initialize the database immediately on module import
init_db()
