/**
 * Family/Caregiver Dashboard Routes
 */

const express = require('express');
const router = express.Router();
const { verifyToken } = require('../middleware/auth');
const db = require('../config/database');
const crypto = require('crypto');

/**
 * POST /api/caregivers/invite
 * Invite a caregiver/family member
 */
router.post('/invite', verifyToken, async (req, res) => {
  try {
    const { patientId, caregiverPhone, caregiverName, relationship, accessLevel } = req.body;

    if (!patientId || !caregiverPhone || !caregiverName) {
      return res.status(400).json({
        error: 'Patient ID, caregiver phone, and name are required'
      });
    }

    // Generate unique invite code
    const inviteCode = crypto.randomBytes(6).toString('hex').toUpperCase();

    const caregiver = await db.inviteCaregiver({
      patientId,
      caregiverPhone,
      caregiverName,
      relationship: relationship || 'Family',
      accessLevel: accessLevel || 'view',
      inviteCode,
      status: 'pending'
    });

    res.json({
      success: true,
      caregiver: caregiver,
      inviteCode: inviteCode,
      message: `Invitation sent to ${caregiverName}. Share code: ${inviteCode}`
    });

  } catch (error) {
    console.error('Invite caregiver error:', error);
    res.status(500).json({
      error: 'Failed to invite caregiver',
      message: error.message
    });
  }
});

/**
 * POST /api/caregivers/accept-invite
 * Accept caregiver invitation
 */
router.post('/accept-invite', verifyToken, async (req, res) => {
  try {
    const { inviteCode, caregiverPhone } = req.body;

    if (!inviteCode || !caregiverPhone) {
      return res.status(400).json({
        error: 'Invite code and phone number are required'
      });
    }

    const caregiver = await db.acceptCaregiverInvite(inviteCode, caregiverPhone);

    if (!caregiver) {
      return res.status(404).json({
        error: 'Invalid invite code or phone number'
      });
    }

    res.json({
      success: true,
      caregiver: caregiver,
      message: 'Invitation accepted successfully'
    });

  } catch (error) {
    console.error('Accept invite error:', error);
    res.status(500).json({
      error: 'Failed to accept invitation',
      message: error.message
    });
  }
});

/**
 * GET /api/caregivers/patients/:caregiverPhone
 * Get all patients for a caregiver
 */
router.get('/patients/:caregiverPhone', verifyToken, async (req, res) => {
  try {
    const { caregiverPhone } = req.params;

    const patients = await db.getCaregiverPatients(caregiverPhone);

    res.json({
      success: true,
      patients: patients || [],
      count: patients ? patients.length : 0
    });

  } catch (error) {
    console.error('Get caregiver patients error:', error);
    res.status(500).json({
      error: 'Failed to get patients',
      message: error.message
    });
  }
});

/**
 * GET /api/caregivers/:patientId
 * Get all caregivers for a patient
 */
router.get('/:patientId', verifyToken, async (req, res) => {
  try {
    const { patientId } = req.params;

    const caregivers = await db.getPatientCaregivers(parseInt(patientId));

    res.json({
      success: true,
      caregivers: caregivers || [],
      count: caregivers ? caregivers.length : 0
    });

  } catch (error) {
    console.error('Get patient caregivers error:', error);
    res.status(500).json({
      error: 'Failed to get caregivers',
      message: error.message
    });
  }
});

/**
 * GET /api/caregivers/patient-status/:patientId
 * Get patient health status for caregiver dashboard
 */
router.get('/patient-status/:patientId', verifyToken, async (req, res) => {
  try {
    const { patientId } = req.params;
    const userId = parseInt(patientId);

    // Get patient info
    const patient = await db.findUserById(userId);
    
    // Get medications
    const medications = await db.getUserMedications(userId);
    
    // Get recent vitals
    const vitals = await db.getRecentVitals(userId, 7); // Last 7 days
    
    // Get upcoming appointments
    const appointments = await db.getUpcomingAppointments(userId);
    
    // Get medication adherence
    const adherence = await db.getMedicationAdherence(userId, 30); // Last 30 days

    res.json({
      success: true,
      patient: {
        id: patient.id,
        name: patient.name,
        phone: patient.phone,
        language: patient.language
      },
      medications: {
        total: medications ? medications.length : 0,
        active: medications ? medications.filter(m => m.active).length : 0,
        list: medications || []
      },
      vitals: vitals || [],
      appointments: appointments || [],
      adherence: adherence || { rate: 0, taken: 0, missed: 0 }
    });

  } catch (error) {
    console.error('Get patient status error:', error);
    res.status(500).json({
      error: 'Failed to get patient status',
      message: error.message
    });
  }
});

/**
 * DELETE /api/caregivers/:id
 * Remove caregiver access
 */
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;

    await db.removeCaregiver(parseInt(id));

    res.json({
      success: true,
      message: 'Caregiver access removed'
    });

  } catch (error) {
    console.error('Remove caregiver error:', error);
    res.status(500).json({
      error: 'Failed to remove caregiver',
      message: error.message
    });
  }
});

module.exports = router;
