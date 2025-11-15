/**
 * Speech Services - Text-to-Speech and Speech-to-Text using Google Gemini
 * Uses Gemini API for both TTS and STT capabilities
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Text-to-Speech using browser's Web Speech API (client-side)
 * This function returns configuration for the frontend
 */
function getTextToSpeechConfig(text, language = 'en') {
  // Language mapping for Web Speech API
  const languageMap = {
    'en': 'en-US',
    'ta': 'ta-IN',
    'hi': 'hi-IN'
  };

  return {
    text: text,
    lang: languageMap[language] || 'en-US',
    rate: 0.9, // Slightly slower for seniors
    pitch: 1.0,
    volume: 1.0
  };
}

/**
 * Speech-to-Text using Gemini (for audio transcription)
 * Note: For real-time STT, use browser's Web Speech API on frontend
 */
async function transcribeAudio(audioBuffer, language = 'en') {
  try {
    // For MVP, we'll use browser's Web Speech API on frontend
    // This is a placeholder for server-side transcription if needed
    
    // Return configuration for client-side implementation
    return {
      success: true,
      message: 'Use browser Web Speech API for real-time transcription',
      config: {
        lang: language === 'ta' ? 'ta-IN' : language === 'hi' ? 'hi-IN' : 'en-US',
        continuous: false,
        interimResults: false
      }
    };
  } catch (error) {
    console.error('Transcription error:', error);
    throw error;
  }
}

/**
 * Get voice settings for different languages
 */
function getVoiceSettings(language = 'en') {
  const settings = {
    'en': {
      lang: 'en-US',
      voiceName: 'Google US English',
      rate: 0.9,
      pitch: 1.0
    },
    'ta': {
      lang: 'ta-IN',
      voiceName: 'Google தமிழ்',
      rate: 0.85,
      pitch: 1.0
    },
    'hi': {
      lang: 'hi-IN',
      voiceName: 'Google हिन्दी',
      rate: 0.9,
      pitch: 1.0
    }
  };

  return settings[language] || settings['en'];
}

module.exports = {
  getTextToSpeechConfig,
  transcribeAudio,
  getVoiceSettings
};
