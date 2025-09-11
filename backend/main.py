from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse, Response
from fastapi.middleware.cors import CORSMiddleware
import requests
import os
import json
import tempfile
from typing import List

# Google Cloud imports - will fall back to mock if not available
try:
    from google.cloud import speech_v1p1beta1 as speech
    from google.cloud import texttospeech
    import google.generativeai as genai
    GOOGLE_CLOUD_AVAILABLE = True
except ImportError:
    GOOGLE_CLOUD_AVAILABLE = False
    print("Google Cloud libraries not installed. Using mock responses.")

app = FastAPI(title="Senior Medicine App Backend", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration - Set these environment variables
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "your-gemini-api-key")
GOOGLE_APPLICATION_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

@app.get("/")
async def root():
    return {"message": "Senior Medicine App Backend API", "status": "running"}

@app.post("/asr")
async def speech_to_text(file: UploadFile = File(...), lang: str = Form("en-US")):
    """
    Convert audio file to text using Google Speech-to-Text API
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
                alternative_language_codes=["en-US", "ta-IN", "hi-IN"],
                enable_automatic_punctuation=True,
            )
            
            response = client.recognize(config=config, audio=audio)
            
            if response.results:
                transcript = response.results[0].alternatives[0].transcript
                return {"text": transcript, "language": lang, "source": "google_cloud"}
            else:
                return {"text": "", "language": lang, "source": "google_cloud"}
        else:
            # Use mock responses for testing
            mock_responses = {
                "en-US": "Take Crocin two tablets at 9 PM daily",
                "ta-IN": "க்ரோசின் இரண்டு மாத்திரைகள் இரவு 9 மணிக்கு தினமும்",
                "hi-IN": "रोज रात 9 बजे क्रोसिन की दो गोलियां लें"
            }
            
            # Simulate processing delay
            import time
            time.sleep(1)
            
            transcript = mock_responses.get(lang, mock_responses["en-US"])
            return {"text": transcript, "language": lang, "source": "mock"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"ASR Error: {str(e)}")

@app.post("/parse")
async def parse_intent(text: str = Form(...), language: str = Form("en")):
    """
    Parse medicine reminder intent from text using Gemini
    """
    try:
        # Create the prompt for intent extraction
        prompt = f"""You are a JSON extractor for medicine reminders. Extract the following fields from the user's text and return ONLY valid JSON:

Fields to extract:
- intent: "add_reminder" (always this value)
- medicine: name of the medicine
- dose: dosage amount (e.g., "2 tablets", "1 spoon")
- time: time in 24-hour format (e.g., "21:00" for 9 PM)
- frequency: "daily", "weekly", or "once"

User text: "{text}"

Return only JSON format like this example:
{{"intent":"add_reminder","medicine":"Crocin","dose":"2 tablets","time":"21:00","frequency":"daily"}}"""

        if GOOGLE_CLOUD_AVAILABLE and GEMINI_API_KEY and GEMINI_API_KEY != "your-gemini-api-key":
            try:
                # Use actual Gemini API
                genai.configure(api_key=GEMINI_API_KEY)
                model = genai.GenerativeModel('gemini-pro')
                
                response = model.generate_content(prompt)
                
                # Parse the JSON response
                try:
                    result = json.loads(response.text.strip())
                    result["source"] = "gemini"
                    return result
                except json.JSONDecodeError:
                    # Fall back to pattern matching if JSON parsing fails
                    pass
            except Exception as e:
                print(f"Gemini API error: {e}")
                # Fall back to mock response
        
        # Use pattern matching for mock/fallback
        import re
        
        mock_result = {
            "intent": "add_reminder",
            "medicine": "Crocin",
            "dose": "2 tablets", 
            "time": "21:00",
            "frequency": "daily",
            "source": "mock"
        }
        
        # Try to extract medicine name from text
        medicine_patterns = [
            r'(crocin|paracetamol|aspirin|ibuprofen|vitamin|calcium|iron|multivitamin)',
            r'take\s+(\w+)',
            r'(\w+)\s+tablet',
        ]
        
        for pattern in medicine_patterns:
            match = re.search(pattern, text.lower())
            if match:
                mock_result["medicine"] = match.group(1).title()
                break
        
        # Try to extract dose
        dose_match = re.search(r'(\d+)\s*(tablet|spoon|drop|ml|mg|capsule)', text.lower())
        if dose_match:
            number = dose_match.group(1)
            unit = dose_match.group(2)
            mock_result["dose"] = f"{number} {unit}s" if number != "1" else f"{number} {unit}"
        
        # Try to extract time
        time_patterns = [
            r'(\d{1,2})\s*pm',
            r'(\d{1,2})\s*am',
            r'(\d{1,2}):(\d{2})',
        ]
        
        for pattern in time_patterns:
            match = re.search(pattern, text.lower())
            if match:
                if 'pm' in text.lower():
                    hour = int(match.group(1))
                    if hour != 12:
                        hour += 12
                    mock_result["time"] = f"{hour:02d}:00"
                elif 'am' in text.lower():
                    hour = int(match.group(1))
                    if hour == 12:
                        hour = 0
                    mock_result["time"] = f"{hour:02d}:00"
                break
        
        # Try to extract frequency
        if any(word in text.lower() for word in ['daily', 'every day', 'each day']):
            mock_result["frequency"] = "daily"
        elif any(word in text.lower() for word in ['weekly', 'every week', 'once a week']):
            mock_result["frequency"] = "weekly"
        elif 'once' in text.lower():
            mock_result["frequency"] = "once"
        
        return mock_result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Parse Error: {str(e)}")

@app.post("/tts")
async def text_to_speech(text: str = Form(...), lang: str = Form("en-US")):
    """
    Convert text to speech using Google Text-to-Speech API
    """
    try:
        if GOOGLE_CLOUD_AVAILABLE and os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
            # Use actual Google Text-to-Speech API
            client = texttospeech.TextToSpeechClient()
            
            synthesis_input = texttospeech.SynthesisInput(text=text)
            
            voice = texttospeech.VoiceSelectionParams(
                language_code=lang,
                ssml_gender=texttospeech.SsmlVoiceGender.FEMALE
            )
            
            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.MP3
            )
            
            response = client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config
            )
            
            return Response(
                content=response.audio_content,
                media_type="audio/mpeg",
                headers={"Content-Disposition": "attachment; filename=speech.mp3"}
            )
        else:
            # Return mock audio data for testing
            mock_audio = b"Mock TTS audio data - Google Cloud TTS not available"
            return Response(
                content=mock_audio,
                media_type="audio/mpeg",
                headers={"Content-Disposition": "attachment; filename=speech.mp3"}
            )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"TTS Error: {str(e)}")

@app.post("/summarize")
async def summarize_news(articles: str = Form(...), language: str = Form("en")):
    """
    Summarize news articles for seniors using Gemini
    """
    try:
        articles_list = json.loads(articles)
        
        # Create prompt for news summarization
        language_instructions = {
            "en": "Use simple English words and short sentences.",
            "ta": "Use simple Tamil words and short sentences. Write in Tamil script.",
            "hi": "Use simple Hindi words and short sentences. Write in Devanagari script."
        }
        
        instruction = language_instructions.get(language, language_instructions["en"])
        
        prompt = f"""You are a friendly news summarizer for older adults. {instruction}
        
For each news article, create a simple 2-sentence summary that is easy to understand.

News articles:
{json.dumps(articles_list, indent=2)}

Return a JSON array of simplified news summaries."""

        if GOOGLE_CLOUD_AVAILABLE and GEMINI_API_KEY and GEMINI_API_KEY != "your-gemini-api-key":
            try:
                # Use actual Gemini API
                genai.configure(api_key=GEMINI_API_KEY)
                model = genai.GenerativeModel('gemini-pro')
                
                response = model.generate_content(prompt)
                
                try:
                    result = json.loads(response.text.strip())
                    result["source"] = "gemini"
                    return result
                except json.JSONDecodeError:
                    # Fall back to mock if JSON parsing fails
                    pass
            except Exception as e:
                print(f"Gemini API error in summarize: {e}")
                # Fall back to mock response
        
        # Use mock simplified news
        simplified_news = []
        for article in articles_list:
            if language == "ta":
                simplified_news.append(f"செய்தி: {article[:50]}... இது முக்கியமான தகவல்.")
            elif language == "hi":
                simplified_news.append(f"समाचार: {article[:50]}... यह महत्वपूर्ण जानकारी है।")
            else:
                simplified_news.append(f"News: {article[:100]}...")
        
        return {"simplified_news": simplified_news, "source": "mock"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summarization Error: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Senior Medicine App Backend",
        "endpoints": ["/asr", "/parse", "/tts", "/summarize"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
