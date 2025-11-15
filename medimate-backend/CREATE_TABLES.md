# 🚀 Create Supabase Tables - Quick Guide

## ✅ Your Credentials Are Configured!

Your `.env` file is ready with:
- ✅ Supabase URL
- ✅ Supabase API Key
- ✅ Gemini API Key

## 📝 Next Step: Create Database Tables

### Option 1: Use Supabase Dashboard (Recommended - 2 minutes)

1. **Open Supabase Dashboard:**
   - Go to: https://fajhwhldyibewvukwcdf.supabase.co

2. **Open SQL Editor:**
   - Click **"SQL Editor"** in the left sidebar
   - Click **"New Query"**

3. **Copy and Paste This SQL:**

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  phone VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Medications table
CREATE TABLE IF NOT EXISTS medications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  medicine_name VARCHAR(100) NOT NULL,
  dosage VARCHAR(50),
  time TIME NOT NULL,
  frequency VARCHAR(20) DEFAULT 'daily',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Conversations table
CREATE TABLE IF NOT EXISTS conversations (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  response TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reminders table
CREATE TABLE IF NOT EXISTS reminders (
  id BIGSERIAL PRIMARY KEY,
  medication_id BIGINT REFERENCES medications(id) ON DELETE CASCADE,
  scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
  delivered BOOLEAN DEFAULT false,
  delivered_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_medications_user_id ON medications(user_id);
CREATE INDEX IF NOT EXISTS idx_medications_active ON medications(active);
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_medication_id ON reminders(medication_id);
CREATE INDEX IF NOT EXISTS idx_reminders_delivered ON reminders(delivered);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Create policies (allow all for now)
CREATE POLICY "Allow all operations on users" ON users FOR ALL USING (true);
CREATE POLICY "Allow all operations on medications" ON medications FOR ALL USING (true);
CREATE POLICY "Allow all operations on conversations" ON conversations FOR ALL USING (true);
CREATE POLICY "Allow all operations on reminders" ON reminders FOR ALL USING (true);
```

4. **Click "Run" (or press Ctrl+Enter)**

5. **Verify Success:**
   - You should see: "Success. No rows returned"
   - Click **"Table Editor"** in left sidebar
   - You should see 4 tables: users, medications, conversations, reminders

---

### Option 2: Quick Copy-Paste

The SQL is also in the file: `supabase-schema.sql`

Just copy that entire file and paste it in Supabase SQL Editor.

---

## ✅ After Creating Tables

Run this command to verify:

```bash
node setup-supabase.js
```

You should see:
```
✅ Supabase connection successful!
✅ Tables are ready!
✅ users: 0 records
✅ medications: 0 records
✅ conversations: 0 records
✅ reminders: 0 records
```

---

## 🚀 Then Start the Server

```bash
npm start
```

You should see:
```
✅ Supabase connected
✅ Using Supabase database
🚀 MediMate Backend Server
✅ Server running on port 3000
```

---

## 🧪 Test Everything

```bash
npm test
```

All 10 tests should pass, and data will be saved to Supabase!

---

## 📊 View Your Data

After running tests:
1. Go to Supabase Dashboard
2. Click **"Table Editor"**
3. Click on **"users"** table
4. You should see the test user!

---

## ❓ Need Help?

If you see any errors:
1. Make sure you're logged into Supabase
2. Make sure you selected the correct project
3. Make sure the SQL ran without errors
4. Check the `.env` file has correct credentials

---

**Ready? Let's create those tables!** 🚀
