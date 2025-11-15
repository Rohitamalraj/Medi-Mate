-- New Features Database Schema
-- Emergency SOS, Health Vitals, Caregivers, Appointments, Notifications

-- Emergency Contacts Table
CREATE TABLE IF NOT EXISTS emergency_contacts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relationship VARCHAR(50),
  priority INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Emergency Alerts Table
CREATE TABLE IF NOT EXISTS emergency_alerts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  alert_type VARCHAR(50) DEFAULT 'manual',
  location TEXT,
  message TEXT,
  status VARCHAR(20) DEFAULT 'active',
  triggered_at TIMESTAMP DEFAULT NOW(),
  resolved_at TIMESTAMP
);

-- Health Vitals Table
CREATE TABLE IF NOT EXISTS health_vitals (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  vital_type VARCHAR(50) NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  unit VARCHAR(20),
  recorded_at TIMESTAMP DEFAULT NOW(),
  notes TEXT
);

-- Caregivers Table
CREATE TABLE IF NOT EXISTS caregivers (
  id SERIAL PRIMARY KEY,
  patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  caregiver_phone VARCHAR(20) NOT NULL,
  caregiver_name VARCHAR(100) NOT NULL,
  relationship VARCHAR(50),
  access_level VARCHAR(20) DEFAULT 'view',
  status VARCHAR(20) DEFAULT 'pending',
  invite_code VARCHAR(50) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  accepted_at TIMESTAMP
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  doctor_name VARCHAR(100) NOT NULL,
  specialty VARCHAR(100),
  appointment_date TIMESTAMP NOT NULL,
  location TEXT,
  phone VARCHAR(20),
  notes TEXT,
  status VARCHAR(20) DEFAULT 'scheduled',
  reminder_sent BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Push Notification Tokens Table
CREATE TABLE IF NOT EXISTS notification_tokens (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  device_type VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  last_used TIMESTAMP DEFAULT NOW()
);

-- Medication Adherence Log
CREATE TABLE IF NOT EXISTS medication_logs (
  id SERIAL PRIMARY KEY,
  medication_id INTEGER REFERENCES medications(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  scheduled_time TIMESTAMP NOT NULL,
  taken_at TIMESTAMP,
  status VARCHAR(20) DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_emergency_contacts_user ON emergency_contacts(user_id);
CREATE INDEX IF NOT EXISTS idx_emergency_alerts_user ON emergency_alerts(user_id);
CREATE INDEX IF NOT EXISTS idx_health_vitals_user ON health_vitals(user_id);
CREATE INDEX IF NOT EXISTS idx_health_vitals_type ON health_vitals(vital_type);
CREATE INDEX IF NOT EXISTS idx_caregivers_patient ON caregivers(patient_id);
CREATE INDEX IF NOT EXISTS idx_caregivers_phone ON caregivers(caregiver_phone);
CREATE INDEX IF NOT EXISTS idx_appointments_user ON appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_notification_tokens_user ON notification_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_medication_logs_med ON medication_logs(medication_id);
CREATE INDEX IF NOT EXISTS idx_medication_logs_user ON medication_logs(user_id);

-- Enable Row Level Security
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_vitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE caregivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_logs ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all for now)
CREATE POLICY "Allow all operations on emergency_contacts" ON emergency_contacts FOR ALL USING (true);
CREATE POLICY "Allow all operations on emergency_alerts" ON emergency_alerts FOR ALL USING (true);
CREATE POLICY "Allow all operations on health_vitals" ON health_vitals FOR ALL USING (true);
CREATE POLICY "Allow all operations on caregivers" ON caregivers FOR ALL USING (true);
CREATE POLICY "Allow all operations on appointments" ON appointments FOR ALL USING (true);
CREATE POLICY "Allow all operations on notification_tokens" ON notification_tokens FOR ALL USING (true);
CREATE POLICY "Allow all operations on medication_logs" ON medication_logs FOR ALL USING (true);
