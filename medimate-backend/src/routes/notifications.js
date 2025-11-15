/**
 * Push Notifications Routes
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const { registerDevice, sendPushNotification, unregisterDevice } = require('../services/notifications');
const db = require('../config/database');

/**
 * POST /api/notifications/register
 * Register device for push notifications
 */
router.post('/register', verifyToken, async (req, res) => {
  try {
    const { userId, token, deviceType } = req.body;

    if (!userId || !token) {
      return res.status(400).json({
        error: 'User ID and device token are required'
      });
    }

    const tokenRecord = await registerDevice(userId, token, deviceType, db);

    res.json({
      success: true,
      tokenRecord: tokenRecord,
      message: 'Device registered for notifications'
    });

  } catch (error) {
    console.error('Register device error:', error);
    res.status(500).json({
      error: 'Failed to register device',
      message: error.message
    });
  }
});

/**
 * POST /api/notifications/send
 * Send push notification (for testing)
 */
router.post('/send', verifyToken, async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!userId || !title || !body) {
      return res.status(400).json({
        error: 'User ID, title, and body are required'
      });
    }

    const notification = { title, body, data };
    const result = await sendPushNotification(userId, notification, db);

    res.json({
      success: true,
      ...result
    });

  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      error: 'Failed to send notification',
      message: error.message
    });
  }
});

/**
 * DELETE /api/notifications/unregister
 * Unregister device from notifications
 */
router.delete('/unregister', verifyToken, async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        error: 'Device token is required'
      });
    }

    const result = await unregisterDevice(token, db);

    res.json({
      success: true,
      ...result
    });

  } catch (error) {
    console.error('Unregister device error:', error);
    res.status(500).json({
      error: 'Failed to unregister device',
      message: error.message
    });
  }
});

/**
 * GET /api/notifications/devices/:userId
 * Get all registered devices for a user
 */
router.get('/devices/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    const devices = await db.getUserNotificationTokens(parseInt(userId));

    res.json({
      success: true,
      devices: devices || [],
      count: devices ? devices.length : 0
    });

  } catch (error) {
    console.error('Get devices error:', error);
    res.status(500).json({
      error: 'Failed to get devices',
      message: error.message
    });
  }
});

module.exports = router;
