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


def generate_tldr(title: str, text: str) -> str:
    prompt = f"""
    Create a 'TL;DR' bulleted summary of this article.
    Rules:
    - Return exactly 3 highly informative bullet points.
    - Focus on the main impact and key facts.
    - Do not write any introduction or conclusion.

    Title: {title}
    Article content/description:
    {text}
    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    return response.text.strip()


def generate_eli5(title: str, text: str) -> str:
    prompt = f"""
    Explain this article using the 'Explain Like I'm 5' (ELI5) methodology.
    Rules:
    - Keep it simple, clear, and easy to understand for a child.
    - Avoid industry jargon, or explain it with simple analogies.
    - Keep it under 4 sentences.

    Title: {title}
    Article content/description:
    {text}
    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    return response.text.strip()


def generate_impact(title: str, text: str) -> str:
    prompt = f"""
    Analyze the immediate impact of this news event.
    Rules:
    - List 2 positive impacts/pros and 2 negative impacts/cons.
    - Format as:
      📈 Pros:
      - [Pro 1]
      - [Pro 2]
      📉 Cons:
      - [Con 1]
      - [Con 2]
    - Be brief and factual.

    Title: {title}
    Article content/description:
    {text}
    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    return response.text.strip()


def chat_about_article(title: str, summary: str, history: list, new_message: str) -> str:
    system_instruction = f"""
    You are newsIQ Assistant, an advanced AI news expert. The user is reading a news article:
    Title: {title}
    Summary: {summary}

    Your goal is to answer their questions about this news event objectively and concisely.
    Rules:
    - Ground your answers in the article facts.
    - Keep answers under 3 sentences.
    - Be highly helpful and professional.
    """
    
    formatted_chat = ""
    for msg in history:
        role = "User" if msg.get("role") == "user" else "AI"
        formatted_chat += f"{role}: {msg.get('content')}\n"
        
    prompt = f"""
    {system_instruction}

    Conversation History:
    {formatted_chat}

    User: {new_message}
    AI:
    """
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt
    )
    return response.text.strip()