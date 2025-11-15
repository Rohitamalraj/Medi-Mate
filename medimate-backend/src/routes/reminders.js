const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

/**
 * GET /api/reminders/pending/:userId
 * Get pending reminders for a user
 */
router.get('/pending/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    const pendingReminders = await db.getPendingReminders(userId);

    res.json({
      success: true,
      count: pendingReminders.length,
      reminders: pendingReminders
    });

  } catch (error) {
    console.error('Get pending reminders error:', error);
    res.status(500).json({ error: 'Failed to get pending reminders' });
  }
});

/**
 * POST /api/reminders/:id/confirm
 * Confirm medication taken
 */
router.post('/:id/confirm', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    const success = await db.markReminderDelivered(id);

    if (!success) {
      return res.status(404).json({ error: 'Reminder not found' });
    }

    res.json({
      success: true,
      message: 'Medication confirmed as taken'
    });

  } catch (error) {
    console.error('Confirm reminder error:', error);
    res.status(500).json({ error: 'Failed to confirm reminder' });
  }
});

module.exports = router;
