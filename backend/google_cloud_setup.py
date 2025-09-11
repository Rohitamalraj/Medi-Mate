#!/usr/bin/env python3
"""
Google Cloud setup script for Senior Medicine App
This script helps set up and test Google Cloud APIs
"""

import os
import json
from google.cloud import speech_v1p1beta1 as speech
from google.cloud import texttospeech
import google.generativeai as genai

def test_speech_to_text():
    """Test Google Speech-to-Text API"""
    print("Testing Google Speech-to-Text API...")
    try:
        client = speech.SpeechClient()
        
        # Test with a simple audio configuration
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
        )
        
        print("✅ Speech-to-Text client initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Speech-to-Text setup failed: {e}")
        return False

def test_text_to_speech():
    """Test Google Text-to-Speech API"""
    print("Testing Google Text-to-Speech API...")
    try:
        client = texttospeech.TextToSpeechClient()
        
        # Test synthesis
        synthesis_input = texttospeech.SynthesisInput(text="Hello, this is a test.")
        voice = texttospeech.VoiceSelectionParams(
            language_code="en-US",
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
        
        print("✅ Text-to-Speech client initialized successfully")
        print(f"✅ Generated {len(response.audio_content)} bytes of audio")
        return True
    except Exception as e:
        print(f"❌ Text-to-Speech setup failed: {e}")
        return False

def test_gemini_api():
    """Test Gemini API"""
    print("Testing Gemini API...")
    try:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            print("❌ GEMINI_API_KEY environment variable not set")
            return False
        
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-pro')
        
        # Test with a simple prompt
        response = model.generate_content("Hello, this is a test. Respond with 'API working'.")
        
        print("✅ Gemini API initialized successfully")
        print(f"✅ Test response: {response.text}")
        return True
    except Exception as e:
        print(f"❌ Gemini API setup failed: {e}")
        return False

def check_environment():
    """Check environment variables and credentials"""
    print("Checking environment setup...")
    
    # Check Google Cloud credentials
    creds_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if creds_path and os.path.exists(creds_path):
        print(f"✅ Google Cloud credentials found: {creds_path}")
    else:
        print("❌ GOOGLE_APPLICATION_CREDENTIALS not set or file not found")
        print("   Set it with: export GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account-key.json")
    
    # Check Gemini API key
    gemini_key = os.getenv("GEMINI_API_KEY")
    if gemini_key:
        print("✅ GEMINI_API_KEY is set")
    else:
        print("❌ GEMINI_API_KEY environment variable not set")
        print("   Set it with: export GEMINI_API_KEY=your-api-key")
    
    # Check Google Cloud project
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    if project_id:
        print(f"✅ Google Cloud project: {project_id}")
    else:
        print("⚠️  GOOGLE_CLOUD_PROJECT not set (optional)")

def setup_instructions():
    """Print setup instructions"""
    print("\n" + "="*60)
    print("GOOGLE CLOUD SETUP INSTRUCTIONS")
    print("="*60)
    print("""
1. Create a Google Cloud Project:
   - Go to https://console.cloud.google.com/
   - Create a new project or select existing one
   - Note your project ID

2. Enable Required APIs:
   - Cloud Speech-to-Text API
   - Cloud Text-to-Speech API
   - Generative AI API

3. Create Service Account:
   - Go to IAM & Admin > Service Accounts
   - Create a new service account
   - Download the JSON key file
   - Set GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json

4. Get Gemini API Key:
   - Go to https://makersuite.google.com/app/apikey
   - Create an API key
   - Set GEMINI_API_KEY=your-api-key

5. Install Dependencies:
   pip install google-cloud-speech google-cloud-texttospeech google-generativeai

6. Test Setup:
   python google_cloud_setup.py
""")

def main():
    """Main setup and test function"""
    print("🚀 Google Cloud Setup for Senior Medicine App")
    print("="*50)
    
    check_environment()
    print()
    
    # Test APIs
    speech_ok = test_speech_to_text()
    tts_ok = test_text_to_speech()
    gemini_ok = test_gemini_api()
    
    print("\n" + "="*50)
    print("SETUP SUMMARY")
    print("="*50)
    print(f"Speech-to-Text: {'✅ Ready' if speech_ok else '❌ Not Ready'}")
    print(f"Text-to-Speech: {'✅ Ready' if tts_ok else '❌ Not Ready'}")
    print(f"Gemini API: {'✅ Ready' if gemini_ok else '❌ Not Ready'}")
    
    if all([speech_ok, tts_ok, gemini_ok]):
        print("\n🎉 All APIs are ready! You can now run the backend with full functionality.")
    else:
        print("\n⚠️  Some APIs are not ready. The backend will use mock responses.")
        setup_instructions()

if __name__ == "__main__":
    main()
