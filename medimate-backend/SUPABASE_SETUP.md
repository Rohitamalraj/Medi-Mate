# Supabase Setup Guide for MediMate

## 🚀 Quick Setup (5 minutes)

### Step 1: Create Supabase Account

1. Go to https://supabase.com
2. Click **"Start your project"**
3. Sign up with GitHub or email
4. Create a new organization (free)

### Step 2: Create New Project

1. Click **"New Project"**
2. Fill in details:
   - **Name:** medimate-backend
   - **Database Password:** (generate strong password)
   - **Region:** Choose closest to you
   - **Plan:** Free tier (perfect for MVP)
3. Click **"Create new project"**
4. Wait 2-3 minutes for setup

### Step 3: Get API Credentials

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon public** key (starts with `eyJ...`)

### Step 4: Create Database Tables

1. Go to **SQL Editor** in Supabase dashboard
2. Click **"New Query"**
3. Copy and paste the contents of `supabase-schema.sql`
4. Click **"Run"**
5. You should see: "Success. No rows returned"

### Step 5: Configure Backend

1. Copy `.env.local` to `.env`:
   ```bash
   cp .env.local .env
   ```

2. Edit `.env` and add your Supabase credentials:
   ```env
   GEMINI_API_KEY=AIzaSyCN5nSMutwEDYlP_LNgLShn89k9yt2R1yc
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   JWT_SECRET=medimate-super-secret-key-2025
   PORT=3000
   NODE_ENV=development
   ```

### Step 6: Restart Server

```bash
# Stop current server (Ctrl+C)
npm start
```

You should see:
```
✅ Supabase connected
✅ Using Supabase database
🚀 MediMate Backend Server
✅ Server running on port 3000
```

### Step 7: Test

```bash
npm test
```

All tests should pass with Supabase!

---

## 📊 Verify Database

### Check Tables in Supabase

1. Go to **Table Editor** in Supabase dashboard
2. You should see 4 tables:
   - `users`
   - `medications`
   - `conversations`
   - `reminders`

### View Data

After running tests, check the tables:
- **users** table should have 1 user
- **medications** table should have medication entries
- **conversations** table should have chat history

---

## 🔐 Security (Optional)

### Enable Row Level Security

Already enabled in schema! But you can customize:

1. Go to **Authentication** → **Policies**
2. Adjust policies per table
3. Add user-specific access rules

### API Keys

- **anon key:** Safe to use in frontend (public)
- **service_role key:** Keep secret (backend only)

---

## 💾 Database Features

### Automatic Backups
- Supabase automatically backs up your database
- Free tier: Daily backups for 7 days

### Real-time Subscriptions (Optional)
```javascript
// Listen to medication changes
const subscription = supabase
  .from('medications')
  .on('INSERT', payload => {
    console.log('New medication added:', payload.new);
  })
  .subscribe();
```

### Database Functions (Optional)
Create custom SQL functions in SQL Editor

---

## 📈 Monitoring

### View Database Usage

1. Go to **Settings** → **Usage**
2. Monitor:
   - Database size
   - API requests
   - Bandwidth

### Free Tier Limits
- **Database:** 500 MB
- **API Requests:** Unlimited
- **Bandwidth:** 5 GB
- **Storage:** 1 GB

Perfect for MVP and testing!

---

## 🐛 Troubleshooting

### Error: "Supabase not connected"
- Check if `SUPABASE_URL` and `SUPABASE_ANON_KEY` are in `.env`
- Verify credentials are correct
- Restart server

### Error: "relation does not exist"
- Run `supabase-schema.sql` in SQL Editor
- Check if tables were created in Table Editor

### Error: "Invalid API key"
- Copy anon key again from Settings → API
- Make sure no extra spaces in `.env`

### Fallback to In-Memory
If Supabase fails, backend automatically uses in-memory database:
```
⚠️  Supabase not available, using in-memory database
✅ Using in-memory database
```

---

## 🚀 Advantages of Supabase

✅ **Free tier** - Perfect for MVP  
✅ **No server management** - Fully managed  
✅ **Automatic backups** - Data safety  
✅ **Real-time** - WebSocket support  
✅ **PostgreSQL** - Full SQL power  
✅ **Dashboard** - Easy data viewing  
✅ **Auth built-in** - User management  
✅ **Storage** - File uploads  

---

## 📚 Resources

- **Supabase Docs:** https://supabase.com/docs
- **Dashboard:** https://supabase.com/dashboard
- **SQL Reference:** https://supabase.com/docs/guides/database
- **API Reference:** https://supabase.com/docs/reference/javascript

---

## ✅ Checklist

- [ ] Supabase account created
- [ ] New project created
- [ ] Database tables created (run SQL schema)
- [ ] API credentials copied
- [ ] `.env` file configured
- [ ] Server restarted
- [ ] Tests passing
- [ ] Data visible in Supabase dashboard

---

## 🎉 You're Done!

Your backend now uses Supabase for persistent data storage!

**Before:** In-memory (data lost on restart)  
**After:** Supabase (data persists forever)

Test it:
1. Add a medication
2. Restart server
3. Medication is still there! ✅

---

**Need Help?** Check Supabase docs or the troubleshooting section above.
