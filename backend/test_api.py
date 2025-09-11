#!/usr/bin/env python3
"""
Test script for the Senior Medicine App Backend API
"""

import requests
import json
import time
import io

# Backend URL
BASE_URL = "http://localhost:8000"

def test_health_endpoint():
    """Test the health check endpoint"""
    print("Testing /health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
        return response.status_code == 200
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend. Make sure it's running on port 8000")
        return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_parse_endpoint():
    """Test the intent parsing endpoint"""
    print("\nTesting /parse endpoint...")
    
    test_cases = [
        {
            "text": "Take Crocin two tablets at 9 PM daily",
            "language": "en"
        },
        {
            "text": "Take paracetamol one tablet at 8 AM once",
            "language": "en"
        },
        {
            "text": "Take vitamin D 1000mg at 7 PM daily",
            "language": "en"
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        try:
            response = requests.post(
                f"{BASE_URL}/parse",
                data=test_case
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Test case {i} passed")
                print(f"Input: {test_case['text']}")
                print(f"Parsed: {json.dumps(result, indent=2)}")
                
                # Validate required fields
                required_fields = ['intent', 'medicine', 'dose', 'time', 'frequency']
                missing_fields = [field for field in required_fields if field not in result]
                
                if missing_fields:
                    print(f"⚠️  Missing fields: {missing_fields}")
                else:
                    print("✅ All required fields present")
            else:
                print(f"❌ Test case {i} failed: {response.status_code}")
                print(f"Response: {response.text}")
                
        except Exception as e:
            print(f"❌ Test case {i} error: {e}")
        
        print("-" * 50)

def test_asr_endpoint():
    """Test the ASR endpoint with mock audio"""
    print("\nTesting /asr endpoint...")
    
    # Create a mock audio file (empty WAV file)
    mock_audio = b"RIFF\x24\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x40\x1f\x00\x00\x80\x3e\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00"
    
    try:
        files = {'file': ('test_audio.wav', io.BytesIO(mock_audio), 'audio/wav')}
        data = {'lang': 'en-US'}
        
        response = requests.post(
            f"{BASE_URL}/asr",
            files=files,
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ ASR endpoint test passed")
            print(f"Mock transcription: {result.get('text', 'No text returned')}")
        else:
            print(f"❌ ASR endpoint test failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ ASR endpoint error: {e}")

def test_tts_endpoint():
    """Test the TTS endpoint"""
    print("\nTesting /tts endpoint...")
    
    try:
        data = {
            'text': 'This is a test of the text to speech system',
            'lang': 'en-US'
        }
        
        response = requests.post(
            f"{BASE_URL}/tts",
            data=data
        )
        
        if response.status_code == 200:
            print("✅ TTS endpoint test passed")
            print(f"Response content type: {response.headers.get('content-type')}")
            print(f"Response size: {len(response.content)} bytes")
        else:
            print(f"❌ TTS endpoint test failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ TTS endpoint error: {e}")

def test_summarize_endpoint():
    """Test the news summarization endpoint"""
    print("\nTesting /summarize endpoint...")
    
    test_articles = [
        "Local weather update: Sunny skies expected today with temperatures reaching 28 degrees.",
        "Health reminder: Doctors recommend drinking plenty of water during hot weather.",
        "Community news: New park opens in the city center with walking paths for seniors."
    ]
    
    try:
        data = {
            'articles': json.dumps(test_articles),
            'language': 'en'
        }
        
        response = requests.post(
            f"{BASE_URL}/summarize",
            data=data
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Summarize endpoint test passed")
            print("Simplified news:")
            for i, news in enumerate(result.get('simplified_news', []), 1):
                print(f"  {i}. {news}")
        else:
            print(f"❌ Summarize endpoint test failed: {response.status_code}")
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Summarize endpoint error: {e}")

def main():
    """Run all tests"""
    print("🧪 Senior Medicine App Backend API Tests")
    print("=" * 60)
    
    # Test if backend is running
    if not test_health_endpoint():
        print("\n❌ Backend is not running. Please start it with: python main.py")
        return
    
    # Run all endpoint tests
    test_parse_endpoint()
    test_asr_endpoint()
    test_tts_endpoint()
    test_summarize_endpoint()
    
    print("\n🏁 All tests completed!")
    print("\nTo start the backend server, run:")
    print("  cd backend")
    print("  python main.py")

if __name__ == "__main__":
    main()
