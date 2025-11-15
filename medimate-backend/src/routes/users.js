const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

/**
 * GET /api/users/:id/stats
 * Get user statistics
 */
router.get('/:id/stats', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    const stats = await db.getUserStats(id);

    res.json({
      success: true,
      userId: id,
      stats
    });

  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Failed to get user stats' });
  }
});

/**
 * GET /api/users/:id
 * Get user profile
 */
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    const user = await db.findUserById(id);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      success: true,
      user: {
        id: user.id,
        phone: user.phone,
        name: user.name,
        language: user.language,
        created_at: user.created_at
      }
    });

  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

module.exports = router;
