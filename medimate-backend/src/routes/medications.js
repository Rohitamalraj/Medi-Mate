const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

/**
 * POST /api/medications
 * Add a new medication
 */
router.post('/', verifyToken, async (req, res) => {
  try {
    const { user_id, medicine_name, dosage, time, frequency } = req.body;

    // Validate input
    if (!user_id || !medicine_name || !time) {
      return res.status(400).json({ 
        error: 'user_id, medicine_name, and time are required' 
      });
    }

    // Create medication
    const medication = await db.createMedication(
      user_id,
      medicine_name,
      dosage,
      time,
      frequency
    );

    res.status(201).json({
      success: true,
      message: 'Medication added successfully',
      medication
    });

  } catch (error) {
    console.error('Add medication error:', error);
    res.status(500).json({ error: 'Failed to add medication' });
  }
});

/**
 * GET /api/medications/:userId
 * Get all medications for a user
 */
router.get('/:userId', verifyToken, async (req, res) => {
  try {
    const { userId } = req.params;

    const medications = await db.getMedicationsByUserId(userId);

    res.json({
      success: true,
      count: medications.length,
      medications
    });

  } catch (error) {
    console.error('Get medications error:', error);
    res.status(500).json({ error: 'Failed to get medications' });
  }
});

/**
 * PUT /api/medications/:id
 * Update a medication
 */
router.put('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const medication = await db.updateMedication(id, updates);

    if (!medication) {
      return res.status(404).json({ error: 'Medication not found' });
    }

    res.json({
      success: true,
      message: 'Medication updated successfully',
      medication
    });

  } catch (error) {
    console.error('Update medication error:', error);
    res.status(500).json({ error: 'Failed to update medication' });
  }
});

/**
 * DELETE /api/medications/:id
 * Delete a medication
 */
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    const success = await db.deleteMedication(id);

    if (!success) {
      return res.status(404).json({ error: 'Medication not found' });
    }

    res.json({
      success: true,
      message: 'Medication deleted successfully'
    });

  } catch (error) {
    console.error('Delete medication error:', error);
    res.status(500).json({ error: 'Failed to delete medication' });
  }
});

module.exports = router;
