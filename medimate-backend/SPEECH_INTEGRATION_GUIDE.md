# 🎤 Speech Features Integration Guide

## 🎯 Overview

MediMate now includes **Text-to-Speech (TTS)** and **Speech-to-Text (STT)** features using the browser's built-in Web Speech API. This is perfect for seniors who prefer voice interaction!

---

## 🚀 Features Added

### 1. Text-to-Speech (TTS)
- ✅ Convert AI responses to speech
- ✅ Multi-language support (Tamil, Hindi, English)
- ✅ Adjustable speed for seniors (slower rate)
- ✅ Natural-sounding voices

### 2. Speech-to-Text (STT)
- ✅ Voice input for messages
- ✅ Multi-language recognition
- ✅ Real-time transcription
- ✅ Hands-free interaction

---

## 📡 New API Endpoints

### 1. Get TTS Configuration
```
POST /api/speech/text-to-speech
```

**Request:**
```json
{
  "text": "Hello, how are you?",
  "language": "en"
}
```

**Response:**
```json
{
  "success": true,
  "config": {
    "text": "Hello, how are you?",
    "lang": "en-US",
    "rate": 0.9,
    "pitch": 1.0,
    "volume": 1.0
  }
}
```

### 2. Get STT Configuration
```
POST /api/speech/speech-to-text
```

**Request:**
```json
{
  "language": "ta"
}
```

**Response:**
```json
{
  "success": true,
  "config": {
    "lang": "ta-IN",
    "continuous": false,
    "interimResults": true,
    "maxAlternatives": 1
  }
}
```

### 3. Get Voice Settings
```
GET /api/speech/voice-settings/:language
```

**Response:**
```json
{
  "success": true,
  "language": "ta",
  "settings": {
    "lang": "ta-IN",
    "voiceName": "Google தமிழ்",
    "rate": 0.85,
    "pitch": 1.0
  }
}
```

### 4. Get Supported Languages
```
GET /api/speech/supported-languages
```

**Response:**
```json
{
  "success": true,
  "languages": [
    {
      "code": "en",
      "name": "English",
      "locale": "en-US",
      "tts": true,
      "stt": true
    },
    {
      "code": "ta",
      "name": "Tamil",
      "locale": "ta-IN",
      "tts": true,
      "stt": true
    },
    {
      "code": "hi",
      "name": "Hindi",
      "locale": "hi-IN",
      "tts": true,
      "stt": true
    }
  ]
}
```

---

## 💻 Frontend Integration (React Native)

### Install Dependencies
```bash
npm install expo-speech @react-native-voice/voice
```

### 1. Text-to-Speech Implementation

```javascript
import * as Speech from 'expo-speech';
import axios from 'axios';

// Function to speak text
async function speakText(text, language = 'en') {
  try {
    // Get TTS config from backend
    const response = await axios.post(
      'http://localhost:3000/api/speech/text-to-speech',
      { text, language },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    
    const config = response.data.config;
    
    // Speak using Expo Speech
    await Speech.speak(text, {
      language: config.lang,
      rate: config.rate,
      pitch: config.pitch,
      volume: config.volume
    });
    
    console.log('Speaking:', text);
  } catch (error) {
    console.error('TTS Error:', error);
  }
}

// Example: Speak AI response
async function handleChatResponse(aiResponse, language) {
  // Display response
  setMessages([...messages, { text: aiResponse, sender: 'ai' }]);
  
  // Speak response
  await speakText(aiResponse, language);
}
```

### 2. Speech-to-Text Implementation

```javascript
import Voice from '@react-native-voice/voice';
import axios from 'axios';

// Initialize Voice Recognition
async function initializeVoiceRecognition(language = 'en') {
  try {
    // Get STT config from backend
    const response = await axios.post(
      'http://localhost:3000/api/speech/speech-to-text',
      { language },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    
    const config = response.data.config;
    
    // Set up Voice listeners
    Voice.onSpeechStart = () => console.log('Speech started');
    Voice.onSpeechEnd = () => console.log('Speech ended');
    Voice.onSpeechResults = (event) => {
      const transcript = event.value[0];
      handleVoiceInput(transcript);
    };
    
    return config;
  } catch (error) {
    console.error('STT Init Error:', error);
  }
}

// Start listening
async function startListening(language = 'en') {
  try {
    const config = await initializeVoiceRecognition(language);
    await Voice.start(config.lang);
    setIsListening(true);
  } catch (error) {
    console.error('Start listening error:', error);
  }
}

// Stop listening
async function stopListening() {
  try {
    await Voice.stop();
    setIsListening(false);
  } catch (error) {
    console.error('Stop listening error:', error);
  }
}

// Handle voice input
function handleVoiceInput(transcript) {
  console.log('Transcript:', transcript);
  setMessageText(transcript);
  // Optionally send message automatically
  sendMessage(transcript);
}
```

### 3. Complete Chat Component Example

```javascript
import React, { useState, useEffect } from 'react';
import { View, TouchableOpacity, Text } from 'react-native';
import * as Speech from 'expo-speech';
import Voice from '@react-native-voice/voice';
import axios from 'axios';

export default function ChatScreen() {
  const [messages, setMessages] = useState([]);
  const [isListening, setIsListening] = useState(false);
  const [language, setLanguage] = useState('en');
  const token = 'your-auth-token';
  const userId = 1;

  useEffect(() => {
    initializeVoiceRecognition(language);
    
    return () => {
      Voice.destroy().then(Voice.removeAllListeners);
    };
  }, [language]);

  // Send message and get AI response
  async function sendMessage(text) {
    try {
      // Send to chat API
      const response = await axios.post(
        'http://localhost:3000/api/chat',
        { userId, message: text, language },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      
      const aiResponse = response.data.response;
      
      // Add to messages
      setMessages([
        ...messages,
        { text, sender: 'user' },
        { text: aiResponse, sender: 'ai' }
      ]);
      
      // Speak AI response
      await speakText(aiResponse, language);
      
    } catch (error) {
      console.error('Send message error:', error);
    }
  }

  // Voice button handler
  async function handleVoiceButton() {
    if (isListening) {
      await stopListening();
    } else {
      await startListening(language);
    }
  }

  return (
    <View style={{ flex: 1 }}>
      {/* Messages display */}
      {/* ... */}
      
      {/* Voice button */}
      <TouchableOpacity 
        onPress={handleVoiceButton}
        style={{
          width: 80,
          height: 80,
          borderRadius: 40,
          backgroundColor: isListening ? '#ff4444' : '#4CAF50',
          justifyContent: 'center',
          alignItems: 'center'
        }}
      >
        <Text style={{ fontSize: 40 }}>
          {isListening ? '🔴' : '🎤'}
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

---

## 🌐 Web Integration (React)

### For Web Apps (using browser APIs)

```javascript
// Text-to-Speech (Web)
function speakText(text, language = 'en') {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.lang = language === 'ta' ? 'ta-IN' : 
                   language === 'hi' ? 'hi-IN' : 'en-US';
  utterance.rate = 0.9; // Slower for seniors
  utterance.pitch = 1.0;
  
  window.speechSynthesis.speak(utterance);
}

// Speech-to-Text (Web)
function startListening(language = 'en', onResult) {
  const recognition = new (window.SpeechRecognition || 
                           window.webkitSpeechRecognition)();
  
  recognition.lang = language === 'ta' ? 'ta-IN' : 
                     language === 'hi' ? 'hi-IN' : 'en-US';
  recognition.continuous = false;
  recognition.interimResults = true;
  
  recognition.onresult = (event) => {
    const transcript = event.results[0][0].transcript;
    onResult(transcript);
  };
  
  recognition.start();
  return recognition;
}
```

---

## 🎨 UI Components

### Voice Button Component

```javascript
import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';

export function VoiceButton({ isListening, onPress }) {
  return (
    <TouchableOpacity 
      onPress={onPress}
      style={[
        styles.button,
        { backgroundColor: isListening ? '#ff4444' : '#4CAF50' }
      ]}
    >
      <Text style={styles.icon}>
        {isListening ? '🔴' : '🎤'}
      </Text>
      <Text style={styles.text}>
        {isListening ? 'Listening...' : 'Tap to Speak'}
      </Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  icon: {
    fontSize: 48,
  },
  text: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    marginTop: 8,
  }
});
```

---

## 🔧 Configuration

### Language Settings

| Language | Code | TTS Locale | STT Locale | Rate |
|----------|------|------------|------------|------|
| English | `en` | `en-US` | `en-US` | 0.9 |
| Tamil | `ta` | `ta-IN` | `ta-IN` | 0.85 |
| Hindi | `hi` | `hi-IN` | `hi-IN` | 0.9 |

### Recommended Settings for Seniors

```javascript
const seniorFriendlySettings = {
  tts: {
    rate: 0.85,        // Slower speech
    pitch: 1.0,        // Normal pitch
    volume: 1.0        // Full volume
  },
  stt: {
    continuous: false,  // One phrase at a time
    interimResults: true, // Show partial results
    maxAlternatives: 1  // Best match only
  }
};
```

---

## 🧪 Testing

### Test TTS Endpoint
```bash
curl -X POST http://localhost:3000/api/speech/text-to-speech \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"text":"வணக்கம்","language":"ta"}'
```

### Test STT Endpoint
```bash
curl -X POST http://localhost:3000/api/speech/speech-to-text \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"language":"hi"}'
```

### Test Supported Languages
```bash
curl http://localhost:3000/api/speech/supported-languages \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## ✅ Benefits for Seniors

1. **Hands-Free Operation** - No typing needed
2. **Natural Interaction** - Speak naturally in their language
3. **Audio Feedback** - Hear responses clearly
4. **Accessibility** - Works for users with vision impairments
5. **Multi-Language** - Tamil, Hindi, English support

---

## 📝 Best Practices

### 1. Always Provide Visual Feedback
```javascript
// Show listening indicator
<View style={{ flexDirection: 'row', alignItems: 'center' }}>
  {isListening && <Text>🎤 Listening...</Text>}
  {isSpeaking && <Text>🔊 Speaking...</Text>}
</View>
```

### 2. Handle Errors Gracefully
```javascript
try {
  await speakText(text, language);
} catch (error) {
  // Fallback: Show text if speech fails
  Alert.alert('Speech Error', 'Please read the message on screen');
}
```

### 3. Allow Manual Override
```javascript
// Always show text + provide voice option
<View>
  <Text>{message}</Text>
  <TouchableOpacity onPress={() => speakText(message)}>
    <Text>🔊 Repeat</Text>
  </TouchableOpacity>
</View>
```

---

## 🎉 Summary

**New Endpoints:** 4  
**Languages Supported:** 3 (English, Tamil, Hindi)  
**Features:** TTS + STT  
**Implementation:** Client-side (browser/React Native)  
**Status:** ✅ Ready to use!

---

**Next Steps:**
1. Integrate into React Native app
2. Test with actual seniors
3. Adjust speech rate based on feedback
4. Add voice commands for common actions

🎤 **Voice-first interaction is now ready!** 🔊
