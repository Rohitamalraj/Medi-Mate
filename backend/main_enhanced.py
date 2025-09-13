from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import json
import tempfile
import os
from datetime import datetime
import logging
import requests
import feedparser
from typing import Dict, Any, List
import re

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="MediMate Backend API", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration - Replace with your actual API keys
GOOGLE_CLOUD_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT_ID", "your_project_id")
NEWS_API_KEY = os.getenv("NEWS_API_KEY", "your_news_api_key_here")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "your_gemini_api_key_here")

# Google Cloud imports - will fall back to mock if not available
try:
    from google.cloud import speech_v1p1beta1 as speech
    from google.cloud import texttospeech
    import google.generativeai as genai
    GOOGLE_CLOUD_AVAILABLE = True
    if GEMINI_API_KEY and GEMINI_API_KEY != "your_gemini_api_key_here":
        genai.configure(api_key=GEMINI_API_KEY)
except ImportError:
    GOOGLE_CLOUD_AVAILABLE = False
    print("Google Cloud libraries not installed. Using mock responses.")

@app.get("/")
async def root():
    return {
        "message": "MediMate Backend API", 
        "status": "running",
        "google_cloud_available": GOOGLE_CLOUD_AVAILABLE,
        "timestamp": datetime.now().isoformat()
    }

@app.post("/asr")
async def speech_to_text(file: UploadFile = File(...), lang: str = Form("en-US")):
    """
    Convert audio file to text using Google Speech-to-Text API
    Expected audio format: WAV, 16kHz, mono, LINEAR16
    """
    try:
        # Read the uploaded audio file
        audio_bytes = await file.read()
        
        if GOOGLE_CLOUD_AVAILABLE and os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
            # Use actual Google Speech-to-Text API
            client = speech.SpeechClient()
            audio = speech.RecognitionAudio(content=audio_bytes)
            
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                sample_rate_hertz=16000,
                language_code=lang,
                enable_automatic_punctuation=True,
                use_enhanced=True,
                model="medical_conversation" if "medical" in lang.lower() else "latest_long",
            )
            
            response = client.recognize(config=config, audio=audio)
            
            if response.results:
                transcript = response.results[0].alternatives[0].transcript
                confidence = response.results[0].alternatives[0].confidence
                return {"text": transcript, "confidence": confidence}
            else:
                return {"text": "", "confidence": 0.0}
        
        else:
            # Mock response for development/testing
            logger.info("Using mock ASR response")
            return {
                "text": "Take Crocin two tablets at 9 PM daily",
                "confidence": 0.95
            }
            
    except Exception as e:
        logger.error(f"ASR Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Speech recognition failed: {str(e)}")

@app.post("/parse")
async def parse_intent(text: str = Form(...), language: str = Form("en")):
    """
    Extract structured medication reminder data from natural language text using Gemini
    """
    try:
        # Gemini prompt template for intent extraction
        prompt = f"""You are an AI assistant that extracts medicine reminder information. 
Return ONLY a valid JSON object with these exact fields: intent, medicine, dose, time, repeat.

Rules:
- intent: always "add_reminder"
- medicine: name of the medicine/drug
- dose: amount and unit (e.g., "2 tablets", "1 spoon", "5ml")
- time: 24-hour format (e.g., "09:00", "21:30")
- repeat: "daily", "weekly", or "once"
- If any field is unclear, make a reasonable assumption
- If time is not specified, use "09:00" as default

Examples:
Input: "Take Crocin two tablets at 9pm daily"
Output: {{"intent":"add_reminder","medicine":"Crocin","dose":"2 tablets","time":"21:00","repeat":"daily"}}

Input: "Paracetamol one tablet tomorrow morning"
Output: {{"intent":"add_reminder","medicine":"Paracetamol","dose":"1 tablet","time":"09:00","repeat":"once"}}

Now extract from: "{text}"
"""

        if GOOGLE_CLOUD_AVAILABLE and GEMINI_API_KEY != "your_gemini_api_key_here":
            # Use actual Gemini API
            model = genai.GenerativeModel('gemini-pro')
            response = model.generate_content(prompt)
            
            # Parse the JSON response
            response_text = response.text.strip()
            # Clean up the response to ensure it's valid JSON
            if response_text.startswith('```json'):
                response_text = response_text[7:-3]
            elif response_text.startswith('```'):
                response_text = response_text[3:-3]
            
            try:
                parsed_data = json.loads(response_text)
                return parsed_data
            except json.JSONDecodeError:
                # Fallback parsing if Gemini returns malformed JSON
                return _fallback_parse(text)
        
        else:
            # Mock response for development
            logger.info("Using mock intent parsing")
            return _fallback_parse(text)
            
    except Exception as e:
        logger.error(f"Intent parsing error: {str(e)}")
        return _fallback_parse(text)

def _fallback_parse(text: str) -> Dict[str, Any]:
    """Fallback parsing logic when AI is not available"""
    text_lower = text.lower()
    
    # Extract medicine name (first word that looks like a medicine)
    medicine_patterns = ['crocin', 'paracetamol', 'aspirin', 'vitamin', 'calcium', 'iron']
    medicine = "Medicine"
    for pattern in medicine_patterns:
        if pattern in text_lower:
            medicine = pattern.capitalize()
            break
    
    # Extract dose
    dose_match = re.search(r'(\d+)\s*(tablet|spoon|ml|mg|drop)', text_lower)
    dose = f"{dose_match.group(1)} {dose_match.group(2)}s" if dose_match else "1 tablet"
    
    # Extract time
    time_match = re.search(r'(\d{1,2})\s*(am|pm)', text_lower)
    if time_match:
        hour = int(time_match.group(1))
        period = time_match.group(2)
        if period == 'pm' and hour != 12:
            hour += 12
        elif period == 'am' and hour == 12:
            hour = 0
        time = f"{hour:02d}:00"
    else:
        time = "09:00"
    
    # Extract frequency
    repeat = "daily"
    if any(word in text_lower for word in ['once', 'tomorrow', 'today']):
        repeat = "once"
    elif any(word in text_lower for word in ['weekly', 'week']):
        repeat = "weekly"
    
    return {
        "intent": "add_reminder",
        "medicine": medicine,
        "dose": dose,
        "time": time,
        "repeat": repeat
    }

@app.post("/tts")
async def text_to_speech(text: str = Form(...), lang: str = Form("en-US")):
    """
    Convert text to speech using Google Text-to-Speech API
    Returns MP3 audio file
    """
    try:
        if GOOGLE_CLOUD_AVAILABLE and os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
            # Use actual Google TTS API
            client = texttospeech.TextToSpeechClient()
            
            synthesis_input = texttospeech.SynthesisInput(text=text)
            
            # Select voice based on language
            if lang.startswith('ta'):
                voice = texttospeech.VoiceSelectionParams(
                    language_code="ta-IN",
                    name="ta-IN-Standard-A",
                    ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
                )
            elif lang.startswith('hi'):
                voice = texttospeech.VoiceSelectionParams(
                    language_code="hi-IN",
                    name="hi-IN-Standard-A",
                    ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
                )
            else:
                voice = texttospeech.VoiceSelectionParams(
                    language_code="en-US",
                    name="en-US-Standard-A",
                    ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
                )
            
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3,
                speaking_rate=0.8,
                pitch=0.0
            )
            
            response = client.synthesize_speech(
                input=synthesis_input, voice=voice, audio_config=audio_config
            )
            
            # Save to temporary file and return
            with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as tmp_file:
                tmp_file.write(response.audio_content)
                return FileResponse(
                    tmp_file.name, 
                    media_type='audio/mpeg',
                    filename='tts_audio.mp3'
                )
        
        else:
            # Return a mock response indicating TTS is not available
            return JSONResponse({
                "message": "TTS not available in mock mode. Use device TTS instead.",
                "text": text,
                "language": lang
            })
            
    except Exception as e:
        logger.error(f"TTS Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Text-to-speech failed: {str(e)}")

@app.get("/news")
async def get_news(lang: str = "en"):
    """
    Fetch and summarize health news for the specified language
    """
    try:
        # Fetch news from RSS or News API
        news_data = await _fetch_health_news()
        
        if not news_data:
            # Fallback news data
            news_data = {
                "title": "Health News Today",
                "articles": [
                    {
                        "title": "Stay Hydrated: Drink 8 Glasses of Water Daily",
                        "content": "Drinking enough water is essential for good health. Doctors recommend 8 glasses per day."
                    }
                ]
            }
        
        # Summarize using Gemini if available
        if GOOGLE_CLOUD_AVAILABLE and GEMINI_API_KEY != "your_gemini_api_key_here":
            summary = await _summarize_news_with_gemini(news_data, lang)
        else:
            summary = _create_simple_summary(news_data, lang)
        
        return {
            "title": news_data["title"],
            "summary": summary,
            "language": lang,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"News fetch error: {str(e)}")
        return {
            "title": "Health News",
            "summary": "Stay healthy by taking medicines on time, drinking water, and eating good food.",
            "language": lang,
            "timestamp": datetime.now().isoformat()
        }

async def _fetch_health_news():
    """Fetch health news from RSS feeds or News API"""
    try:
        if NEWS_API_KEY and NEWS_API_KEY != "your_news_api_key_here":
            # Use News API
            url = f"https://newsapi.org/v2/top-headlines?category=health&country=in&apiKey={NEWS_API_KEY}"
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                return {
                    "title": "Health News Today",
                    "articles": data.get("articles", [])[:3]  # Get first 3 articles
                }
        
        # Fallback to RSS feed
        feed = feedparser.parse("https://feeds.feedburner.com/ndtvnews-health")
        if feed.entries:
            return {
                "title": "Health News Today",
                "articles": [
                    {"title": entry.title, "content": entry.summary}
                    for entry in feed.entries[:3]
                ]
            }
        
        return None
        
    except Exception as e:
        logger.error(f"News fetch error: {str(e)}")
        return None

async def _summarize_news_with_gemini(news_data: Dict, lang: str) -> str:
    """Summarize news using Gemini AI"""
    try:
        articles_text = "\n\n".join([
            f"Title: {article['title']}\nContent: {article.get('content', article.get('description', ''))}"
            for article in news_data["articles"]
        ])
        
        if lang == "ta":
            prompt = f"""Summarize this health news in simple Tamil (தமிழ்) using very short sentences. 
Maximum 3 sentences. Use simple words that elderly people can understand.

News: {articles_text}

Provide summary in Tamil:"""
        elif lang == "hi":
            prompt = f"""Summarize this health news in simple Hindi (हिंदी) using very short sentences. 
Maximum 3 sentences. Use simple words that elderly people can understand.

News: {articles_text}

Provide summary in Hindi:"""
        else:
            prompt = f"""Summarize this health news in simple English using very short sentences. 
Maximum 3 sentences. Use simple words that elderly people can understand.

News: {articles_text}

Provide summary:"""
        
        model = genai.GenerativeModel('gemini-pro')
        response = model.generate_content(prompt)
        return response.text.strip()
        
    except Exception as e:
        logger.error(f"Gemini summarization error: {str(e)}")
        return _create_simple_summary(news_data, lang)

def _create_simple_summary(news_data: Dict, lang: str) -> str:
    """Create a simple fallback summary"""
    if lang == "ta":
        return "இன்றைய சுகாதார செய்திகள்: உடல் நலம் காக்க மருந்துகளை சரியான நேரத்தில் எடுத்துக் கொள்ளுங்கள். தண்ணீர் அதிகம் குடியுங்கள். நல்ல உணவு சாப்பிடுங்கள்."
    elif lang == "hi":
        return "आज की स्वास्थ्य खबरें: स्वस्थ रहने के लिए दवाइयां समय पर लें। खूब पानी पिएं। अच्छा खाना खाएं।"
    else:
        return "Today's health news: Stay healthy by taking medicines on time. Drink plenty of water. Eat good food."

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "services": {
            "google_cloud": GOOGLE_CLOUD_AVAILABLE,
            "news_api": NEWS_API_KEY != "your_news_api_key_here",
            "gemini_api": GEMINI_API_KEY != "your_gemini_api_key_here"
        }
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)