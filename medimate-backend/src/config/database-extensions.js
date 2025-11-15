/**
 * Database Extensions for New Features
 * Add these methods to your database class (Supabase or InMemory)
 */

// Emergency Contacts Methods
const emergencyContactsMethods = {
  async addEmergencyContact(data) {
    const { userId, name, phone, relationship, priority } = data;
    // Supabase implementation
    if (this.supabase) {
      const { data: contact, error } = await this.supabase
        .from('emergency_contacts')
        .insert([{ user_id: userId, name, phone, relationship, priority }])
        .select()
        .single();
      if (error) throw error;
      return contact;
    }
    // In-memory fallback
    const contact = { id: Date.now(), ...data, created_at: new Date() };
    this.emergencyContacts = this.emergencyContacts || [];
    this.emergencyContacts.push(contact);
    return contact;
  },

  async getEmergencyContacts(userId) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('emergency_contacts')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('priority', { ascending: true });
      if (error) throw error;
      return data;
    }
    this.emergencyContacts = this.emergencyContacts || [];
    return this.emergencyContacts.filter(c => c.userId === userId);
  },

  async deleteEmergencyContact(id) {
    if (this.supabase) {
      const { error } = await this.supabase
        .from('emergency_contacts')
        .delete()
        .eq('id', id);
      if (error) throw error;
      return { success: true };
    }
    this.emergencyContacts = this.emergencyContacts || [];
    this.emergencyContacts = this.emergencyContacts.filter(c => c.id !== id);
    return { success: true };
  },

  async createEmergencyAlert(data) {
    const { userId, alertType, location, message } = data;
    if (this.supabase) {
      const { data: alert, error } = await this.supabase
        .from('emergency_alerts')
        .insert([{ user_id: userId, alert_type: alertType, location, message }])
        .select()
        .single();
      if (error) throw error;
      return alert;
    }
    const alert = { id: Date.now(), ...data, triggered_at: new Date(), status: 'active' };
    this.emergencyAlerts = this.emergencyAlerts || [];
    this.emergencyAlerts.push(alert);
    return alert;
  },

  async getActiveEmergencyAlerts(userId) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('emergency_alerts')
        .select('*')
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('triggered_at', { ascending: false });
      if (error) throw error;
      return data;
    }
    this.emergencyAlerts = this.emergencyAlerts || [];
    return this.emergencyAlerts.filter(a => a.userId === userId && a.status === 'active');
  },

  async resolveEmergencyAlert(alertId) {
    if (this.supabase) {
      const { error } = await this.supabase
        .from('emergency_alerts')
        .update({ status: 'resolved', resolved_at: new Date().toISOString() })
        .eq('id', alertId);
      if (error) throw error;
      return { success: true };
    }
    this.emergencyAlerts = this.emergencyAlerts || [];
    const alert = this.emergencyAlerts.find(a => a.id === alertId);
    if (alert) {
      alert.status = 'resolved';
      alert.resolved_at = new Date();
    }
    return { success: true };
  }
};

// Health Vitals Methods
const healthVitalsMethods = {
  async addHealthVital(data) {
    const { userId, vitalType, value, unit, notes } = data;
    if (this.supabase) {
      const { data: vital, error } = await this.supabase
        .from('health_vitals')
        .insert([{ user_id: userId, vital_type: vitalType, value, unit, notes }])
        .select()
        .single();
      if (error) throw error;
      return vital;
    }
    const vital = { id: Date.now(), ...data, recorded_at: new Date() };
    this.healthVitals = this.healthVitals || [];
    this.healthVitals.push(vital);
    return vital;
  },

  async getAllVitals(userId, days = 30) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('health_vitals')
        .select('*')
        .eq('user_id', userId)
        .gte('recorded_at', cutoffDate.toISOString())
        .order('recorded_at', { ascending: false });
      if (error) throw error;
      return data;
    }
    this.healthVitals = this.healthVitals || [];
    return this.healthVitals.filter(v => 
      v.userId === userId && new Date(v.recorded_at) >= cutoffDate
    );
  },

  async getVitalsByType(userId, vitalType, days = 30) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('health_vitals')
        .select('*')
        .eq('user_id', userId)
        .eq('vital_type', vitalType)
        .gte('recorded_at', cutoffDate.toISOString())
        .order('recorded_at', { ascending: false });
      if (error) throw error;
      return data;
    }
    this.healthVitals = this.healthVitals || [];
    return this.healthVitals.filter(v => 
      v.userId === userId && v.vitalType === vitalType && new Date(v.recorded_at) >= cutoffDate
    );
  },

  async getRecentVitals(userId, days = 7) {
    return await this.getAllVitals(userId, days);
  },

  async getHealthTrends(userId, days = 30) {
    const vitals = await this.getAllVitals(userId, days);
    const trends = {};
    
    vitals.forEach(v => {
      if (!trends[v.vital_type || v.vitalType]) {
        trends[v.vital_type || v.vitalType] = [];
      }
      trends[v.vital_type || v.vitalType].push({
        value: v.value,
        date: v.recorded_at
      });
    });
    
    return trends;
  }
};

// Caregivers Methods
const caregiversMethods = {
  async inviteCaregiver(data) {
    const { patientId, caregiverPhone, caregiverName, relationship, accessLevel, inviteCode } = data;
    if (this.supabase) {
      const { data: caregiver, error } = await this.supabase
        .from('caregivers')
        .insert([{
          patient_id: patientId,
          caregiver_phone: caregiverPhone,
          caregiver_name: caregiverName,
          relationship,
          access_level: accessLevel,
          invite_code: inviteCode,
          status: 'pending'
        }])
        .select()
        .single();
      if (error) throw error;
      return caregiver;
    }
    const caregiver = { id: Date.now(), ...data, created_at: new Date(), status: 'pending' };
    this.caregivers = this.caregivers || [];
    this.caregivers.push(caregiver);
    return caregiver;
  },

  async acceptCaregiverInvite(inviteCode, caregiverPhone) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('caregivers')
        .update({ status: 'accepted', accepted_at: new Date().toISOString() })
        .eq('invite_code', inviteCode)
        .eq('caregiver_phone', caregiverPhone)
        .select()
        .single();
      if (error) return null;
      return data;
    }
    this.caregivers = this.caregivers || [];
    const caregiver = this.caregivers.find(c => 
      c.inviteCode === inviteCode && c.caregiverPhone === caregiverPhone
    );
    if (caregiver) {
      caregiver.status = 'accepted';
      caregiver.accepted_at = new Date();
      return caregiver;
    }
    return null;
  },

  async getPatientCaregivers(patientId) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('caregivers')
        .select('*')
        .eq('patient_id', patientId)
        .eq('status', 'accepted');
      if (error) throw error;
      return data;
    }
    this.caregivers = this.caregivers || [];
    return this.caregivers.filter(c => c.patientId === patientId && c.status === 'accepted');
  },

  async getCaregiverPatients(caregiverPhone) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('caregivers')
        .select('*, users(*)')
        .eq('caregiver_phone', caregiverPhone)
        .eq('status', 'accepted');
      if (error) throw error;
      return data;
    }
    this.caregivers = this.caregivers || [];
    const caregiverRecords = this.caregivers.filter(c => 
      c.caregiverPhone === caregiverPhone && c.status === 'accepted'
    );
    return caregiverRecords.map(c => ({
      ...c,
      patient: this.users.find(u => u.id === c.patientId)
    }));
  },

  async removeCaregiver(id) {
    if (this.supabase) {
      const { error } = await this.supabase
        .from('caregivers')
        .delete()
        .eq('id', id);
      if (error) throw error;
      return { success: true };
    }
    this.caregivers = this.caregivers || [];
    this.caregivers = this.caregivers.filter(c => c.id !== id);
    return { success: true };
  }
};

// Appointments Methods
const appointmentsMethods = {
  async addAppointment(data) {
    const { userId, doctorName, specialty, appointmentDate, location, phone, notes } = data;
    if (this.supabase) {
      const { data: appointment, error } = await this.supabase
        .from('appointments')
        .insert([{
          user_id: userId,
          doctor_name: doctorName,
          specialty,
          appointment_date: appointmentDate,
          location,
          phone,
          notes,
          status: 'scheduled'
        }])
        .select()
        .single();
      if (error) throw error;
      return appointment;
    }
    const appointment = { id: Date.now(), ...data, created_at: new Date(), status: 'scheduled' };
    this.appointments = this.appointments || [];
    this.appointments.push(appointment);
    return appointment;
  },

  async getAllAppointments(userId) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('appointments')
        .select('*')
        .eq('user_id', userId)
        .order('appointment_date', { ascending: true });
      if (error) throw error;
      return data;
    }
    this.appointments = this.appointments || [];
    return this.appointments.filter(a => a.userId === userId);
  },

  async getUpcomingAppointments(userId) {
    const now = new Date().toISOString();
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('appointments')
        .select('*')
        .eq('user_id', userId)
        .gte('appointment_date', now)
        .eq('status', 'scheduled')
        .order('appointment_date', { ascending: true });
      if (error) throw error;
      return data;
    }
    this.appointments = this.appointments || [];
    return this.appointments.filter(a => 
      a.userId === userId && new Date(a.appointmentDate) >= new Date() && a.status === 'scheduled'
    );
  },

  async updateAppointment(id, updates) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('appointments')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
      if (error) throw error;
      return data;
    }
    this.appointments = this.appointments || [];
    const appointment = this.appointments.find(a => a.id === id);
    if (appointment) {
      Object.assign(appointment, updates);
      return appointment;
    }
    return null;
  },

  async deleteAppointment(id) {
    if (this.supabase) {
      const { error } = await this.supabase
        .from('appointments')
        .delete()
        .eq('id', id);
      if (error) throw error;
      return { success: true };
    }
    this.appointments = this.appointments || [];
    this.appointments = this.appointments.filter(a => a.id !== id);
    return { success: true };
  }
};

// Notification Tokens Methods
const notificationTokensMethods = {
  async createNotificationToken(data) {
    const { userId, token, deviceType } = data;
    if (this.supabase) {
      const { data: tokenRecord, error } = await this.supabase
        .from('notification_tokens')
        .insert([{ user_id: userId, token, device_type: deviceType, is_active: true }])
        .select()
        .single();
      if (error) throw error;
      return tokenRecord;
    }
    const tokenRecord = { id: Date.now(), ...data, created_at: new Date(), is_active: true };
    this.notificationTokens = this.notificationTokens || [];
    this.notificationTokens.push(tokenRecord);
    return tokenRecord;
  },

  async findNotificationToken(token) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('notification_tokens')
        .select('*')
        .eq('token', token)
        .single();
      if (error) return null;
      return data;
    }
    this.notificationTokens = this.notificationTokens || [];
    return this.notificationTokens.find(t => t.token === token);
  },

  async getUserNotificationTokens(userId) {
    if (this.supabase) {
      const { data, error } = await this.supabase
        .from('notification_tokens')
        .select('*')
        .eq('user_id', userId)
        .eq('is_active', true);
      if (error) throw error;
      return data;
    }
    this.notificationTokens = this.notificationTokens || [];
    return this.notificationTokens.filter(t => t.userId === userId && t.is_active);
  },

  async updateNotificationToken(token, updates) {
    if (this.supabase) {
      const { error } = await this.supabase
        .from('notification_tokens')
        .update(updates)
        .eq('token', token);
      if (error) throw error;
      return { success: true };
    }
    this.notificationTokens = this.notificationTokens || [];
    const tokenRecord = this.notificationTokens.find(t => t.token === token);
    if (tokenRecord) {
      Object.assign(tokenRecord, updates);
    }
    return { success: true };
  },

  async deactivateNotificationToken(token) {
    return await this.updateNotificationToken(token, { is_active: false });
  }
};

// Medication Adherence Methods
const medicationAdherenceMethods = {
  async getMedicationAdherence(userId, days = 30) {
    // This is a simplified version - you can enhance it based on your needs
    const medications = await this.getUserMedications(userId);
    
    // Mock adherence data for now
    return {
      rate: 85, // 85% adherence
      taken: 25,
      missed: 5,
      total: 30
    };
  },

  async getUserMedications(userId) {
    // This method should already exist in your database
    return await this.getMedicationsByUserId(userId);
  }
};

// Export all methods
module.exports = {
  ...emergencyContactsMethods,
  ...healthVitalsMethods,
  ...caregiversMethods,
  ...appointmentsMethods,
  ...notificationTokensMethods,
  ...medicationAdherenceMethods
};
