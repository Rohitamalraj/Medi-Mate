const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Supabase configuration
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;

let supabase = null;

// Initialize Supabase client
if (supabaseUrl && supabaseKey) {
  supabase = createClient(supabaseUrl, supabaseKey);
  console.log('✅ Supabase connected');
} else {
  console.warn('⚠️  Supabase not configured. Using in-memory database.');
}

// Database operations using Supabase
class SupabaseDB {
  constructor() {
    this.supabase = supabase;
    this.isConnected = !!supabase;
  }

  // User operations
  async createUser(phone, name, language) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('users')
      .insert([{ phone, name, language: language || 'en' }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async findUserByPhone(phone) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('users')
      .select('*')
      .eq('phone', phone)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    return data;
  }

  async findUserById(id) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  // Medication operations
  async createMedication(userId, medicineName, dosage, time, frequency) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('medications')
      .insert([{
        user_id: userId,
        medicine_name: medicineName,
        dosage,
        time,
        frequency: frequency || 'daily',
        active: true
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getMedicationsByUserId(userId) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('medications')
      .select('*')
      .eq('user_id', userId)
      .eq('active', true)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  async updateMedication(id, updates) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('medications')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteMedication(id) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('medications')
      .update({ active: false })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return true;
  }

  // Conversation operations
  async createConversation(userId, message, response) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('conversations')
      .insert([{ user_id: userId, message, response }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getConversationHistory(userId, limit = 5) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('conversations')
      .select('*')
      .eq('user_id', userId)
      .order('timestamp', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return (data || []).reverse();
  }

  // Reminder operations
  async createReminder(medicationId, scheduledTime) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('reminders')
      .insert([{
        medication_id: medicationId,
        scheduled_time: scheduledTime,
        delivered: false
      }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async getPendingReminders(userId) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    // Get user's medications
    const medications = await this.getMedicationsByUserId(userId);
    const medicationIds = medications.map(m => m.id);

    if (medicationIds.length === 0) return [];

    const { data, error } = await this.supabase
      .from('reminders')
      .select('*')
      .in('medication_id', medicationIds)
      .eq('delivered', false);

    if (error) throw error;
    return data || [];
  }

  async markReminderDelivered(id) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const { data, error } = await this.supabase
      .from('reminders')
      .update({ delivered: true, delivered_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return true;
  }

  // Stats
  async getUserStats(userId) {
    if (!this.isConnected) throw new Error('Supabase not connected');
    
    const medications = await this.getMedicationsByUserId(userId);
    
    const { data: conversations } = await this.supabase
      .from('conversations')
      .select('id', { count: 'exact' })
      .eq('user_id', userId);

    const pendingReminders = await this.getPendingReminders(userId);

    return {
      total_medications: medications.length,
      total_conversations: conversations?.length || 0,
      pending_reminders: pendingReminders.length,
      adherence_rate: 95 // Mock value
    };
  }
}

module.exports = new SupabaseDB();
