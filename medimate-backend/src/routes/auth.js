const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { generateToken } = require('../middleware/auth');

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', async (req, res) => {
  try {
    const { phone, name, language } = req.body;

    // Validate input
    if (!phone || !name) {
      return res.status(400).json({ 
        error: 'Phone and name are required' 
      });
    }

    // Check if user already exists
    const existingUser = await db.findUserByPhone(phone);
    if (existingUser) {
      return res.status(400).json({ 
        error: 'User already exists with this phone number' 
      });
    }

    // Create user
    const user = await db.createUser(phone, name, language);

    // Generate token
    const token = generateToken(user.id, user.phone);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        language: user.language
      },
      token
    });

  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

/**
 * POST /api/auth/login
 * Login user
 */
router.post('/login', async (req, res) => {
  try {
    const { phone } = req.body;

    // Validate input
    if (!phone) {
      return res.status(400).json({ 
        error: 'Phone number is required' 
      });
    }

    // Find user
    const user = await db.findUserByPhone(phone);
    if (!user) {
      return res.status(404).json({ 
        error: 'User not found. Please register first.' 
      });
    }

    // Generate token
    const token = generateToken(user.id, user.phone);

    res.json({
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        language: user.language
      },
      token
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Failed to login' });
  }
});

module.exports = router;
