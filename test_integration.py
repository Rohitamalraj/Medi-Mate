#!/usr/bin/env python3
"""
Integration test script for the Senior Medicine App
Tests the complete flow from voice input to reminder creation
"""

import requests
import json
import time
import io
import os
from pathlib import Path

# Test configuration
BACKEND_URL = "http://localhost:8000"
TEST_AUDIO_FILE = "test_audio.wav"

def create_mock_audio_file():
    """Create a mock WAV file for testing"""
    # Simple WAV header + minimal audio data
    wav_header = b'RIFF\x24\x00\x00\x00WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00\x40\x1f\x00\x00\x80\x3e\x00\x00\x02\x00\x10\x00data\x00\x00\x00\x00'
    
    with open(TEST_AUDIO_FILE, 'wb') as f:
        f.write(wav_header)
    
    return TEST_AUDIO_FILE

def test_backend_health():
    """Test if backend is running"""
    print("🏥 Testing backend health...")
    try:
        response = requests.get(f"{BACKEND_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend is healthy")
            return True
        else:
            print(f"❌ Backend health check failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to backend. Is it running on port 8000?")
        return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        return False

def test_voice_to_reminder_flow():
    """Test the complete voice-to-reminder flow"""
    print("\n🎤 Testing complete voice-to-reminder flow...")
    
    # Step 1: Create mock audio file
    print("1. Creating mock audio file...")
    audio_file = create_mock_audio_file()
    
    # Step 2: Test ASR (Speech-to-Text)
    print("2. Testing speech-to-text...")
    try:
        with open(audio_file, 'rb') as f:
            files = {'file': (audio_file, f, 'audio/wav')}
            data = {'lang': 'en-US'}
            
            response = requests.post(f"{BACKEND_URL}/asr", files=files, data=data)
            
            if response.status_code == 200:
                asr_result = response.json()
                transcript = asr_result.get('text', '')
                print(f"✅ ASR successful: '{transcript}'")
                print(f"   Source: {asr_result.get('source', 'unknown')}")
            else:
                print(f"❌ ASR failed: {response.status_code}")
                return False
    except Exception as e:
        print(f"❌ ASR error: {e}")
        return False
    
    # Step 3: Test Intent Parsing
    print("3. Testing intent parsing...")
    try:
        data = {
            'text': transcript,
            'language': 'en'
        }
        
        response = requests.post(f"{BACKEND_URL}/parse", data=data)
        
        if response.status_code == 200:
            parse_result = response.json()
            print("✅ Intent parsing successful:")
            print(f"   Medicine: {parse_result.get('medicine', 'N/A')}")
            print(f"   Dose: {parse_result.get('dose', 'N/A')}")
            print(f"   Time: {parse_result.get('time', 'N/A')}")
            print(f"   Frequency: {parse_result.get('frequency', 'N/A')}")
            print(f"   Source: {parse_result.get('source', 'unknown')}")
        else:
            print(f"❌ Intent parsing failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Intent parsing error: {e}")
        return False
    
    # Step 4: Test TTS (Text-to-Speech)
    print("4. Testing text-to-speech...")
    try:
        confirmation_text = f"Reminder added: {parse_result['medicine']} {parse_result['dose']} at {parse_result['time']} {parse_result['frequency']}"
        
        data = {
            'text': confirmation_text,
            'lang': 'en-US'
        }
        
        response = requests.post(f"{BACKEND_URL}/tts", data=data)
        
        if response.status_code == 200:
            print(f"✅ TTS successful: {len(response.content)} bytes of audio")
        else:
            print(f"❌ TTS failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ TTS error: {e}")
        return False
    
    # Cleanup
    if os.path.exists(audio_file):
        os.remove(audio_file)
    
    print("✅ Complete voice-to-reminder flow successful!")
    return True

def test_news_summarization():
    """Test news summarization feature"""
    print("\n📰 Testing news summarization...")
    
    test_articles = [
        "Local weather update: Sunny skies expected today with temperatures reaching 28 degrees Celsius.",
        "Health advisory: Doctors recommend staying hydrated and avoiding direct sunlight during peak hours.",
        "Community news: New senior-friendly walking path opened in the city park with rest benches every 100 meters."
    ]
    
    try:
        data = {
            'articles': json.dumps(test_articles),
            'language': 'en'
        }
        
        response = requests.post(f"{BACKEND_URL}/summarize", data=data)
        
        if response.status_code == 200:
            result = response.json()
            simplified_news = result.get('simplified_news', [])
            print("✅ News summarization successful:")
            for i, news in enumerate(simplified_news, 1):
                print(f"   {i}. {news}")
            print(f"   Source: {result.get('source', 'unknown')}")
            return True
        else:
            print(f"❌ News summarization failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ News summarization error: {e}")
        return False

def test_multilingual_support():
    """Test multilingual support"""
    print("\n🌐 Testing multilingual support...")
    
    test_cases = [
        {'lang': 'en-US', 'text': 'Take medicine two tablets at night'},
        {'lang': 'ta-IN', 'text': 'மருந்து இரண்டு மாத்திரைகள் இரவில் எடுத்துக் கொள்ளுங்கள்'},
        {'lang': 'hi-IN', 'text': 'रात में दो गोलियां दवा लें'}
    ]
    
    for test_case in test_cases:
        try:
            # Test parsing in different languages
            data = {
                'text': test_case['text'],
                'language': test_case['lang'].split('-')[0]
            }
            
            response = requests.post(f"{BACKEND_URL}/parse", data=data)
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ {test_case['lang']}: {result.get('medicine', 'N/A')} - {result.get('dose', 'N/A')}")
            else:
                print(f"❌ {test_case['lang']}: Failed")
        except Exception as e:
            print(f"❌ {test_case['lang']}: Error - {e}")

def performance_test():
    """Test API performance"""
    print("\n⚡ Testing API performance...")
    
    # Test parse endpoint performance
    start_time = time.time()
    for i in range(5):
        try:
            data = {'text': 'Take Crocin two tablets at 9 PM daily', 'language': 'en'}
            response = requests.post(f"{BACKEND_URL}/parse", data=data, timeout=10)
            if response.status_code != 200:
                print(f"❌ Request {i+1} failed")
        except Exception as e:
            print(f"❌ Request {i+1} error: {e}")
    
    end_time = time.time()
    avg_time = (end_time - start_time) / 5
    print(f"✅ Average response time: {avg_time:.2f} seconds")
    
    if avg_time < 2.0:
        print("✅ Performance is good (< 2 seconds)")
    else:
        print("⚠️  Performance is slow (> 2 seconds)")

def main():
    """Run all integration tests"""
    print("🧪 Senior Medicine App Integration Tests")
    print("=" * 60)
    
    # Test backend health first
    if not test_backend_health():
        print("\n❌ Backend is not running. Please start it first:")
        print("   cd backend")
        print("   python run_backend.py")
        return
    
    # Run all tests
    tests = [
        test_voice_to_reminder_flow,
        test_news_summarization,
        test_multilingual_support,
        performance_test
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            print(f"❌ Test failed with exception: {e}")
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 TEST SUMMARY")
    print("=" * 60)
    print(f"Passed: {passed}/{total} tests")
    
    if passed == total:
        print("🎉 All tests passed! The backend is working correctly.")
    else:
        print(f"⚠️  {total - passed} test(s) failed. Check the output above.")
    
    print("\n💡 Next steps:")
    print("1. If tests passed: Continue with Flutter app testing")
    print("2. If tests failed: Check backend configuration and Google Cloud setup")
    print("3. For production: Set up actual Google Cloud APIs")

if __name__ == "__main__":
    main()
