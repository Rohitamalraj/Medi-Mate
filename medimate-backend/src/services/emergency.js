/**
 * Emergency SOS Service
 */

const twilio = require('twilio');

// Twilio configuration (optional - will work without it)
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const TWILIO_PHONE = process.env.TWILIO_PHONE_NUMBER;

let twilioClient = null;
if (TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN) {
  twilioClient = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);
}

/**
 * Send emergency SMS alerts
 */
async function sendEmergencySMS(contacts, userInfo, location) {
  if (!twilioClient) {
    console.log('⚠️  Twilio not configured - SMS alerts disabled');
    return { success: false, message: 'SMS service not configured' };
  }

  const message = `🆘 EMERGENCY ALERT!\n\n${userInfo.name} needs help!\n\nPhone: ${userInfo.phone}\nLocation: ${location || 'Not available'}\n\nPlease check on them immediately!`;

  const results = [];
  
  for (const contact of contacts) {
    try {
      const result = await twilioClient.messages.create({
        body: message,
        from: TWILIO_PHONE,
        to: contact.phone
      });
      
      results.push({
        contact: contact.name,
        phone: contact.phone,
        status: 'sent',
        sid: result.sid
      });
      
      console.log(`✅ SMS sent to ${contact.name} (${contact.phone})`);
    } catch (error) {
      results.push({
        contact: contact.name,
        phone: contact.phone,
        status: 'failed',
        error: error.message
      });
      
      console.error(`❌ Failed to send SMS to ${contact.name}:`, error.message);
    }
  }

  return {
    success: true,
    results: results,
    sent: results.filter(r => r.status === 'sent').length,
    failed: results.filter(r => r.status === 'failed').length
  };
}

/**
 * Trigger emergency alert
 */
async function triggerEmergency(userId, location, message, db) {
  try {
    // Get user info
    const user = await db.findUserById(userId);
    if (!user) {
      throw new Error('User not found');
    }

    // Get emergency contacts
    const contacts = await db.getEmergencyContacts(userId);
    if (!contacts || contacts.length === 0) {
      return {
        success: false,
        message: 'No emergency contacts configured'
      };
    }

    // Create emergency alert record
    const alert = await db.createEmergencyAlert({
      userId,
      alertType: 'manual',
      location,
      message: message || 'Emergency help needed!'
    });

    // Send SMS alerts
    const smsResult = await sendEmergencySMS(contacts, user, location);

    return {
      success: true,
      alert: alert,
      contactsNotified: contacts.length,
      smsResults: smsResult,
      message: 'Emergency alert sent successfully'
    };

  } catch (error) {
    console.error('Emergency trigger error:', error);
    throw error;
  }
}

/**
 * Get emergency status
 */
async function getEmergencyStatus(userId, db) {
  try {
    const activeAlerts = await db.getActiveEmergencyAlerts(userId);
    const contacts = await db.getEmergencyContacts(userId);

    return {
      hasActiveAlerts: activeAlerts && activeAlerts.length > 0,
      activeAlerts: activeAlerts || [],
      emergencyContacts: contacts || [],
      contactCount: contacts ? contacts.length : 0
    };
  } catch (error) {
    console.error('Get emergency status error:', error);
    throw error;
  }
}

module.exports = {
  sendEmergencySMS,
  triggerEmergency,
  getEmergencyStatus
};
