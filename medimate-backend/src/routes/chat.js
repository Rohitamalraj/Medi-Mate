const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { chatWithGemini, getHealthAdvice } = require('../services/gemini');
const { verifyToken } = require('../middleware/auth');

/**
 * POST /api/chat
 * Chat with AI
 */
router.post('/', verifyToken, async (req, res) => {
  try {
    const { userId, message, language } = req.body;

    // Validate input
    if (!userId || !message) {
      return res.status(400).json({ 
        error: 'userId and message are required' 
      });
    }

    // Get conversation history
    const conversationHistory = await db.getConversationHistory(userId);

    // Get AI response
    const aiResponse = await chatWithGemini(
      message,
      language || 'en',
      conversationHistory
    );

    // Save conversation
    await db.createConversation(userId, message, aiResponse);

    res.json({
      success: true,
      message: message,
      response: aiResponse,
      language: language || 'en'
    });

  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ 
      error: 'Failed to process chat request',
      details: error.message 
    });
  }
});

/**
 * POST /api/chat/health-advice
 * Get health advice
 */
router.post('/health-advice', verifyToken, async (req, res) => {
  try {
    const { symptom, language } = req.body;

    if (!symptom) {
      return res.status(400).json({ error: 'Symptom is required' });
    }

    const advice = await getHealthAdvice(symptom, language || 'en');

    res.json({
      success: true,
      symptom,
      advice,
      language: language || 'en'
    });

  } catch (error) {
    console.error('Health advice error:', error);
    res.status(500).json({ error: 'Failed to get health advice' });
  }
});

/**
 * GET /api/chat/history/:userId
 * Get conversation history
 */
router.get('/history/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 10;

    const history = await db.getConversationHistory(userId, limit);

    res.json({
      success: true,
      count: history.length,
      history
    });

  } catch (error) {
    console.error('Get history error:', error);
    res.status(500).json({ error: 'Failed to get conversation history' });
  }
});

module.exports = router;
