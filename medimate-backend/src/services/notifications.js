/**
 * Push Notifications Service
 */

/**
 * Register device for push notifications
 */
async function registerDevice(userId, token, deviceType, db) {
  try {
    // Check if token already exists
    const existing = await db.findNotificationToken(token);
    
    if (existing) {
      // Update last used timestamp
      await db.updateNotificationToken(token, { lastUsed: new Date() });
      return existing;
    }

    // Create new token record
    const tokenRecord = await db.createNotificationToken({
      userId,
      token,
      deviceType: deviceType || 'unknown',
      isActive: true
    });

    return tokenRecord;

  } catch (error) {
    console.error('Register device error:', error);
    throw error;
  }
}

/**
 * Send push notification
 * Note: This is a placeholder. Actual implementation depends on:
 * - Expo Push Notifications (for React Native)
 * - Firebase Cloud Messaging (FCM)
 * - Apple Push Notification Service (APNS)
 */
async function sendPushNotification(userId, notification, db) {
  try {
    // Get user's device tokens
    const tokens = await db.getUserNotificationTokens(userId);
    
    if (!tokens || tokens.length === 0) {
      console.log('No device tokens found for user:', userId);
      return { success: false, message: 'No devices registered' };
    }

    // Prepare notification payload
    const payload = {
      title: notification.title || 'MediMate',
      body: notification.body,
      data: notification.data || {},
      sound: notification.sound || 'default',
      priority: notification.priority || 'high'
    };

    console.log(`📱 Sending notification to ${tokens.length} device(s):`, payload);

    // TODO: Implement actual push notification sending
    // For Expo: Use expo-server-sdk
    // For FCM: Use firebase-admin
    
    // Mock response for now
    return {
      success: true,
      sent: tokens.length,
      payload: payload,
      message: 'Notification queued for delivery'
    };

  } catch (error) {
    console.error('Send push notification error:', error);
    throw error;
  }
}

/**
 * Send medication reminder notification
 */
async function sendMedicationReminder(medication, user, db) {
  const notification = {
    title: '💊 Medication Reminder',
    body: `Time to take ${medication.medicine_name} - ${medication.dosage}`,
    data: {
      type: 'medication_reminder',
      medicationId: medication.id,
      userId: user.id
    },
    sound: 'default',
    priority: 'high'
  };

  return await sendPushNotification(user.id, notification, db);
}

/**
 * Send appointment reminder notification
 */
async function sendAppointmentReminder(appointment, user, db) {
  const notification = {
    title: '👨‍⚕️ Appointment Reminder',
    body: `Appointment with Dr. ${appointment.doctor_name} at ${new Date(appointment.appointment_date).toLocaleString()}`,
    data: {
      type: 'appointment_reminder',
      appointmentId: appointment.id,
      userId: user.id
    },
    sound: 'default',
    priority: 'high'
  };

  return await sendPushNotification(user.id, notification, db);
}

/**
 * Send emergency alert notification to caregivers
 */
async function sendEmergencyNotification(patient, caregivers, location, db) {
  const results = [];

  for (const caregiver of caregivers) {
    // Assuming caregiver has a user account
    const notification = {
      title: '🆘 EMERGENCY ALERT',
      body: `${patient.name} needs help! Location: ${location || 'Unknown'}`,
      data: {
        type: 'emergency_alert',
        patientId: patient.id,
        patientName: patient.name,
        location: location
      },
      sound: 'emergency',
      priority: 'max'
    };

    try {
      const result = await sendPushNotification(caregiver.id, notification, db);
      results.push({ caregiver: caregiver.name, ...result });
    } catch (error) {
      results.push({ caregiver: caregiver.name, success: false, error: error.message });
    }
  }

  return results;
}

/**
 * Unregister device
 */
async function unregisterDevice(token, db) {
  try {
    await db.deactivateNotificationToken(token);
    return { success: true, message: 'Device unregistered' };
  } catch (error) {
    console.error('Unregister device error:', error);
    throw error;
  }
}

module.exports = {
  registerDevice,
  sendPushNotification,
  sendMedicationReminder,
  sendAppointmentReminder,
  sendEmergencyNotification,
  unregisterDevice
};
