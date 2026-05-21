from google import genai
from app.utils.config import GEMINI_API_KEY

client = genai.Client(api_key=GEMINI_API_KEY)


def summarize_news(text):

    prompt = f"""
    Summarize this news article in 2 short lines.
    Keep it simple and factual.

    Article:
    {text}
    """

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )

    return response.text


def get_priority_score(text):

    prompt = f"""
    Give an importance score from 1 to 100
    for this news article.

    Rules:
    - Global breaking news → high score
    - AI, economy, politics → higher
    - Entertainment/gossip → lower

    ONLY return a number.

    Article:
    {text}
    """

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )

    try:
        score = int(response.text.strip())
    except:
        score = 50

    return score