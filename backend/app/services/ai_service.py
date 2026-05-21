import google.generativeai as genai

from app.utils.config import GEMINI_API_KEY

genai.configure(api_key=GEMINI_API_KEY)

model = genai.GenerativeModel("gemini-1.5-flash")


def summarize_news(text):

    prompt = f"""
    Summarize this news article in 2 short lines.
    Keep it simple and factual.

    Article:
    {text}
    """

    response = model.generate_content(prompt)

    return response.text