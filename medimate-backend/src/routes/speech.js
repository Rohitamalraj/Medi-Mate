/**
 * Speech Routes - Text-to-Speech and Speech-to-Text endpoints
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const { getTextToSpeechConfig, getVoiceSettings } = require('../services/speech');

/**
 * POST /api/speech/text-to-speech
 * Get TTS configuration for client-side synthesis
 */
router.post('/text-to-speech', verifyToken, async (req, res) => {
  try {
    const { text, language } = req.body;

    if (!text) {
      return res.status(400).json({ 
        error: 'Text is required' 
      });
    }

    // Get TTS configuration for frontend
    const config = getTextToSpeechConfig(text, language || 'en');

    res.json({
      success: true,
      config: config,
      implementation: 'client-side',
      instructions: {
        method: 'Use browser Web Speech API',
        example: 'const utterance = new SpeechSynthesisUtterance(text);'
      }
    });

  } catch (error) {
    console.error('TTS error:', error);
    res.status(500).json({ 
      error: 'Failed to generate speech configuration',
      message: error.message 
    });
  }
});

/**
 * GET /api/speech/voice-settings/:language
 * Get voice settings for a specific language
 */
router.get('/voice-settings/:language', verifyToken, async (req, res) => {
  try {
    const { language } = req.params;
    const settings = getVoiceSettings(language);

    res.json({
      success: true,
      language: language,
      settings: settings,
      supported: ['en', 'ta', 'hi']
    });

  } catch (error) {
    console.error('Voice settings error:', error);
    res.status(500).json({ 
      error: 'Failed to get voice settings',
      message: error.message 
    });
  }
});

/**
 * POST /api/speech/speech-to-text
 * Get STT configuration for client-side recognition
 */
router.post('/speech-to-text', verifyToken, async (req, res) => {
  try {
    const { language } = req.body;

    // Return configuration for client-side Web Speech API
    const config = {
      lang: language === 'ta' ? 'ta-IN' : language === 'hi' ? 'hi-IN' : 'en-US',
      continuous: false,
      interimResults: true,
      maxAlternatives: 1
    };

    res.json({
      success: true,
      config: config,
      implementation: 'client-side',
      instructions: {
        method: 'Use browser Web Speech Recognition API',
        example: 'const recognition = new webkitSpeechRecognition();'
      },
      supported_languages: {
        'en': 'en-US',
        'ta': 'ta-IN',
        'hi': 'hi-IN'
      }
    });

  } catch (error) {
    console.error('STT error:', error);
    res.status(500).json({ 
      error: 'Failed to generate speech recognition configuration',
      message: error.message 
    });
  }
});

/**
 * GET /api/speech/supported-languages
 * Get list of supported languages for speech
 */
router.get('/supported-languages', verifyToken, async (req, res) => {
  try {
    res.json({
      success: true,
      languages: [
        {
          code: 'en',
          name: 'English',
          locale: 'en-US',
          tts: true,
          stt: true
        },
        {
          code: 'ta',
          name: 'Tamil',
          locale: 'ta-IN',
          tts: true,
          stt: true
        },
        {
          code: 'hi',
          name: 'Hindi',
          locale: 'hi-IN',
          tts: true,
          stt: true
        }
      ]
    });

  } catch (error) {
    console.error('Supported languages error:', error);
    res.status(500).json({ 
      error: 'Failed to get supported languages',
      message: error.message 
    });
  }
});

module.exports = router;
