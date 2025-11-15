/**
 * Emergency SOS Routes
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const { triggerEmergency, getEmergencyStatus } = require('../services/emergency');
const db = require('../config/database');

/**
 * POST /api/emergency/trigger
 * Trigger emergency SOS alert
 */
router.post('/trigger', verifyToken, async (req, res) => {
  try {
    const { userId, location, message } = req.body;

    if (!userId) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    const result = await triggerEmergency(userId, location, message, db);

    res.json({
      success: true,
      ...result
    });

  } catch (error) {
    console.error('Emergency trigger error:', error);
    res.status(500).json({
      error: 'Failed to trigger emergency alert',
      message: error.message
    });
  }
});

/**
 * GET /api/emergency/status/:userId
 * Get emergency status and active alerts
 */
router.get('/status/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    const status = await getEmergencyStatus(parseInt(userId), db);

    res.json({
      success: true,
      ...status
    });

  } catch (error) {
    console.error('Get emergency status error:', error);
    res.status(500).json({
      error: 'Failed to get emergency status',
      message: error.message
    });
  }
});

/**
 * POST /api/emergency/contacts
 * Add emergency contact
 */
router.post('/contacts', verifyToken, async (req, res) => {
  try {
    const { userId, name, phone, relationship, priority } = req.body;

    if (!userId || !name || !phone) {
      return res.status(400).json({
        error: 'User ID, name, and phone are required'
      });
    }

    const contact = await db.addEmergencyContact({
      userId,
      name,
      phone,
      relationship,
      priority: priority || 1
    });

    res.json({
      success: true,
      contact: contact,
      message: 'Emergency contact added successfully'
    });

  } catch (error) {
    console.error('Add emergency contact error:', error);
    res.status(500).json({
      error: 'Failed to add emergency contact',
      message: error.message
    });
  }
});

/**
 * GET /api/emergency/contacts/:userId
 * Get all emergency contacts for a user
 */
router.get('/contacts/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    const contacts = await db.getEmergencyContacts(parseInt(userId));

    res.json({
      success: true,
      contacts: contacts || [],
      count: contacts ? contacts.length : 0
    });

  } catch (error) {
    console.error('Get emergency contacts error:', error);
    res.status(500).json({
      error: 'Failed to get emergency contacts',
      message: error.message
    });
  }
});

/**
 * DELETE /api/emergency/contacts/:id
 * Delete emergency contact
 */
router.delete('/contacts/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    await db.deleteEmergencyContact(parseInt(id));

    res.json({
      success: true,
      message: 'Emergency contact deleted successfully'
    });

  } catch (error) {
    console.error('Delete emergency contact error:', error);
    res.status(500).json({
      error: 'Failed to delete emergency contact',
      message: error.message
    });
  }
});

/**
 * POST /api/emergency/resolve/:alertId
 * Resolve/cancel emergency alert
 */
router.post('/resolve/:alertId', verifyToken, async (req, res) => {
  try {
    const { alertId } = req.params;

    await db.resolveEmergencyAlert(parseInt(alertId));

    res.json({
      success: true,
      message: 'Emergency alert resolved'
    });

  } catch (error) {
    console.error('Resolve emergency alert error:', error);
    res.status(500).json({
      error: 'Failed to resolve emergency alert',
      message: error.message
    });
  }
});

module.exports = router;
