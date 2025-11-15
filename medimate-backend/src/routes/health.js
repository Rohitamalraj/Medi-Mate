/**
 * Health Vitals & Monitoring Routes
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const db = require('../config/database');

/**
 * POST /api/health/vitals
 * Add health vital reading
 */
router.post('/vitals', verifyToken, async (req, res) => {
  try {
    const { userId, vitalType, value, unit, notes } = req.body;

    if (!userId || !vitalType || !value) {
      return res.status(400).json({
        error: 'User ID, vital type, and value are required'
      });
    }

    const vital = await db.addHealthVital({
      userId,
      vitalType,
      value,
      unit: unit || getDefaultUnit(vitalType),
      notes
    });

    res.json({
      success: true,
      vital: vital,
      message: 'Health vital recorded successfully'
    });

  } catch (error) {
    console.error('Add health vital error:', error);
    res.status(500).json({
      error: 'Failed to add health vital',
      message: error.message
    });
  }
});

/**
 * GET /api/health/vitals/:userId
 * Get all vitals for a user
 */
router.get('/vitals/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { type, days } = req.query;

    let vitals;
    if (type) {
      vitals = await db.getVitalsByType(parseInt(userId), type, days ? parseInt(days) : 30);
    } else {
      vitals = await db.getAllVitals(parseInt(userId), days ? parseInt(days) : 30);
    }

    res.json({
      success: true,
      vitals: vitals || [],
      count: vitals ? vitals.length : 0
    });

  } catch (error) {
    console.error('Get vitals error:', error);
    res.status(500).json({
      error: 'Failed to get vitals',
      message: error.message
    });
  }
});

/**
 * GET /api/health/trends/:userId
 * Get health trends and analytics
 */
router.get('/trends/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { days } = req.query;
    const period = days ? parseInt(days) : 30;

    const trends = await db.getHealthTrends(parseInt(userId), period);

    res.json({
      success: true,
      period: `Last ${period} days`,
      trends: trends || {}
    });

  } catch (error) {
    console.error('Get health trends error:', error);
    res.status(500).json({
      error: 'Failed to get health trends',
      message: error.message
    });
  }
});

/**
 * POST /api/health/appointments
 * Add doctor appointment
 */
router.post('/appointments', verifyToken, async (req, res) => {
  try {
    const { userId, doctorName, specialty, appointmentDate, location, phone, notes } = req.body;

    if (!userId || !doctorName || !appointmentDate) {
      return res.status(400).json({
        error: 'User ID, doctor name, and appointment date are required'
      });
    }

    const appointment = await db.addAppointment({
      userId,
      doctorName,
      specialty,
      appointmentDate,
      location,
      phone,
      notes,
      status: 'scheduled'
    });

    res.json({
      success: true,
      appointment: appointment,
      message: 'Appointment scheduled successfully'
    });

  } catch (error) {
    console.error('Add appointment error:', error);
    res.status(500).json({
      error: 'Failed to add appointment',
      message: error.message
    });
  }
});

/**
 * GET /api/health/appointments/:userId
 * Get appointments for a user
 */
router.get('/appointments/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { upcoming } = req.query;

    let appointments;
    if (upcoming === 'true') {
      appointments = await db.getUpcomingAppointments(parseInt(userId));
    } else {
      appointments = await db.getAllAppointments(parseInt(userId));
    }

    res.json({
      success: true,
      appointments: appointments || [],
      count: appointments ? appointments.length : 0
    });

  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({
      error: 'Failed to get appointments',
      message: error.message
    });
  }
});

/**
 * PUT /api/health/appointments/:id
 * Update appointment
 */
router.put('/appointments/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const appointment = await db.updateAppointment(parseInt(id), updates);

    res.json({
      success: true,
      appointment: appointment,
      message: 'Appointment updated successfully'
    });

  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({
      error: 'Failed to update appointment',
      message: error.message
    });
  }
});

/**
 * DELETE /api/health/appointments/:id
 * Cancel appointment
 */
router.delete('/appointments/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    await db.deleteAppointment(parseInt(id));

    res.json({
      success: true,
      message: 'Appointment cancelled successfully'
    });

  } catch (error) {
    console.error('Delete appointment error:', error);
    res.status(500).json({
      error: 'Failed to cancel appointment',
      message: error.message
    });
  }
});

/**
 * Helper function to get default unit for vital type
 */
function getDefaultUnit(vitalType) {
  const units = {
    'blood_pressure': 'mmHg',
    'blood_sugar': 'mg/dL',
    'heart_rate': 'bpm',
    'weight': 'kg',
    'temperature': '°F',
    'oxygen_saturation': '%'
  };
  return units[vitalType] || '';
}

module.exports = router;
