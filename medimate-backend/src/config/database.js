const { Pool } = require('pg');
require('dotenv').config();

// Try to use Supabase first, fallback to in-memory
let db;
try {
  const supabaseDB = require('./supabase');
  if (supabaseDB.isConnected) {
    console.log('✅ Using Supabase database');
    db = supabaseDB;
    module.exports = db;
  } else {
    throw new Error('Supabase not configured');
  }
} catch (error) {
  console.log('⚠️  Supabase not available, using in-memory database');
}

// In-memory database for MVP (fallback)
class InMemoryDB {
  constructor() {
    this.users = [];
    this.medications = [];
    this.conversations = [];
    this.reminders = [];
    this.userIdCounter = 1;
    this.medicationIdCounter = 1;
    this.conversationIdCounter = 1;
    this.reminderIdCounter = 1;
  }

  // User operations
  async createUser(phone, name, language) {
    const user = {
      id: this.userIdCounter++,
      phone,
      name,
      language: language || 'en',
      created_at: new Date()
    };
    this.users.push(user);
    return user;
  }

  async findUserByPhone(phone) {
    return this.users.find(u => u.phone === phone);
  }

  async findUserById(id) {
    return this.users.find(u => u.id === parseInt(id));
  }

  // Medication operations
  async createMedication(userId, medicineName, dosage, time, frequency) {
    const medication = {
      id: this.medicationIdCounter++,
      user_id: parseInt(userId),
      medicine_name: medicineName,
      dosage,
      time,
      frequency: frequency || 'daily',
      active: true,
      created_at: new Date()
    };
    this.medications.push(medication);
    return medication;
  }

  async getMedicationsByUserId(userId) {
    return this.medications.filter(m => m.user_id === parseInt(userId) && m.active);
  }

  async updateMedication(id, updates) {
    const index = this.medications.findIndex(m => m.id === parseInt(id));
    if (index !== -1) {
      this.medications[index] = { ...this.medications[index], ...updates };
      return this.medications[index];
    }
    return null;
  }

  async deleteMedication(id) {
    const index = this.medications.findIndex(m => m.id === parseInt(id));
    if (index !== -1) {
      this.medications[index].active = false;
      return true;
    }
    return false;
  }

  // Conversation operations
  async createConversation(userId, message, response) {
    const conversation = {
      id: this.conversationIdCounter++,
      user_id: parseInt(userId),
      message,
      response,
      timestamp: new Date()
    };
    this.conversations.push(conversation);
    return conversation;
  }

  async getConversationHistory(userId, limit = 5) {
    return this.conversations
      .filter(c => c.user_id === parseInt(userId))
      .slice(-limit);
  }

  // Reminder operations
  async createReminder(medicationId, scheduledTime) {
    const reminder = {
      id: this.reminderIdCounter++,
      medication_id: parseInt(medicationId),
      scheduled_time: scheduledTime,
      delivered: false,
      delivered_at: null
    };
    this.reminders.push(reminder);
    return reminder;
  }

  async getPendingReminders(userId) {
    const userMedications = await this.getMedicationsByUserId(userId);
    const medicationIds = userMedications.map(m => m.id);
    return this.reminders.filter(r => 
      medicationIds.includes(r.medication_id) && !r.delivered
    );
  }

  async markReminderDelivered(id) {
    const index = this.reminders.findIndex(r => r.id === parseInt(id));
    if (index !== -1) {
      this.reminders[index].delivered = true;
      this.reminders[index].delivered_at = new Date();
      return true;
    }
    return false;
  }

  // Stats
  async getUserStats(userId) {
    const medications = await this.getMedicationsByUserId(userId);
    const conversations = this.conversations.filter(c => c.user_id === parseInt(userId));
    const pendingReminders = await this.getPendingReminders(userId);
    
    return {
      total_medications: medications.length,
      total_conversations: conversations.length,
      pending_reminders: pendingReminders.length,
      adherence_rate: 95 // Mock value
    };
  }
}

// Create singleton instance (only if not using Supabase)
if (!db) {
  db = new InMemoryDB();
  console.log('✅ Using in-memory database');
}

module.exports = db;
