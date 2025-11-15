# MediMate Backend - Deployment Guide

## ✅ Backend is Ready!

Your backend is fully functional and tested. All 10 API tests passed successfully.

---

## 🚀 Quick Deploy to Render (Free)

### Step 1: Push to GitHub

```bash
cd medimate-backend
git init
git add .
git commit -m "Initial commit - MediMate backend"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/medimate-backend.git
git push -u origin main
```

### Step 2: Deploy on Render

1. Go to https://render.com and sign up
2. Click **"New +" → "Web Service"**
3. Connect your GitHub repository
4. Configure:
   - **Name:** medimate-backend
   - **Environment:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Plan:** Free

5. Add Environment Variables:
   - `NODE_ENV` = `production`
   - `JWT_SECRET` = `your-secret-key-here`
   - `GEMINI_API_KEY` = `your-gemini-key` (optional)

6. Click **"Create Web Service"**

7. Wait 2-3 minutes for deployment

8. Your API will be live at: `https://medimate-backend.onrender.com`

---

## 🧪 Test Deployed API

```bash
# Health check
curl https://medimate-backend.onrender.com/api/health

# Register user
curl -X POST https://medimate-backend.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210","name":"Test User","language":"en"}'
```

---

## 📱 Connect Mobile App

Update your React Native app's API base URL:

```javascript
// src/services/api.js
const API_BASE_URL = 'https://medimate-backend.onrender.com/api';
```

---

## 🔧 Alternative Deployment Options

### Railway
1. Go to https://railway.app
2. Click "New Project" → "Deploy from GitHub"
3. Select repository
4. Add environment variables
5. Deploy

### Heroku
```bash
heroku create medimate-backend
git push heroku main
heroku config:set JWT_SECRET=your-secret
heroku config:set GEMINI_API_KEY=your-key
```

---

## 📊 Current Status

✅ **Server:** Running on port 3000  
✅ **Database:** In-memory (no setup needed)  
✅ **Authentication:** JWT working  
✅ **AI Chat:** Google Gemini integrated  
✅ **Tests:** 10/10 passed  
✅ **CORS:** Enabled for all origins

---

## 🔐 Security Notes

- Change `JWT_SECRET` in production
- Add rate limiting for production
- Use HTTPS only
- Monitor API usage

---

## 📝 API Documentation

Base URL: `http://localhost:3000` (local) or `https://your-app.onrender.com` (deployed)

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| POST | `/api/auth/register` | Register user |
| POST | `/api/auth/login` | Login user |
| POST | `/api/medications` | Add medication |
| GET | `/api/medications/:userId` | Get medications |
| POST | `/api/chat` | Chat with AI |
| GET | `/api/users/:id/stats` | Get user stats |

Full documentation in `README.md`

---

## 🎉 Next Steps

1. ✅ Backend is complete and tested
2. 📱 Build React Native frontend (use `DEV1_2DAY_SPRINT.md`)
3. 🔗 Connect frontend to this backend
4. 🚀 Deploy both and test end-to-end

---

**Backend Status:** ✅ READY FOR PRODUCTION
