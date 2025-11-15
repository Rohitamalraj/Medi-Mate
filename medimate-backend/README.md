# MediMate Backend API

AI-powered backend for MediMate - A companion app for seniors in India.

## Features

✅ User authentication (JWT)  
✅ Medication management  
✅ AI chat with Google Gemini (Tamil, Hindi, English)  
✅ Medication reminders  
✅ Health advice  
✅ In-memory database (no PostgreSQL needed for MVP)

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment (Optional)
Copy `.env.example` to `.env` and add your Gemini API key:
```bash
GEMINI_API_KEY=your-api-key-here
```

**Note:** The app works without Gemini API key (uses mock responses).

### 3. Start Server
```bash
npm start
```

Server will run on: http://localhost:3000

### 4. Test API
```bash
npm test
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Medications
- `POST /api/medications` - Add medication
- `GET /api/medications/:userId` - Get user medications
- `PUT /api/medications/:id` - Update medication
- `DELETE /api/medications/:id` - Delete medication

### Chat
- `POST /api/chat` - Chat with AI
- `POST /api/chat/health-advice` - Get health advice
- `GET /api/chat/history/:userId` - Get chat history

### Reminders
- `GET /api/reminders/pending/:userId` - Get pending reminders
- `POST /api/reminders/:id/confirm` - Confirm medication taken

### Users
- `GET /api/users/:id` - Get user profile
- `GET /api/users/:id/stats` - Get user statistics

### Health Check
- `GET /api/health` - Check if API is running

## Example Requests

### Register User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9876543210",
    "name": "Lakshmi",
    "language": "ta"
  }'
```

### Add Medication
```bash
curl -X POST http://localhost:3000/api/medications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "user_id": 1,
    "medicine_name": "Blood Pressure Medicine",
    "dosage": "1 tablet",
    "time": "08:00",
    "frequency": "daily"
  }'
```

### Chat with AI
```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "userId": 1,
    "message": "Hello, how are you?",
    "language": "en"
  }'
```

## Project Structure

```
medimate-backend/
├── src/
│   ├── config/
│   │   └── database.js          # In-memory database
│   ├── middleware/
│   │   └── auth.js              # JWT authentication
│   ├── routes/
│   │   ├── auth.js              # Auth endpoints
│   │   ├── medications.js       # Medication endpoints
│   │   ├── chat.js              # Chat endpoints
│   │   ├── reminders.js         # Reminder endpoints
│   │   └── users.js             # User endpoints
│   ├── services/
│   │   └── gemini.js            # Google Gemini integration
│   └── server.js                # Main server file
├── test/
│   └── api-test.js              # API tests
├── .env.example                 # Environment variables template
├── .gitignore
├── package.json
└── README.md
```

## Technologies

- **Node.js** - Runtime
- **Express** - Web framework
- **Google Gemini** - AI chat
- **JWT** - Authentication
- **In-memory DB** - No database setup needed

## Development

### Start in development mode
```bash
npm run dev
```

### Run tests
```bash
npm test
```

## Deployment

### Deploy to Render
1. Push code to GitHub
2. Create new Web Service on Render
3. Connect repository
4. Set environment variables
5. Deploy

### Environment Variables for Production
```
PORT=3000
NODE_ENV=production
JWT_SECRET=your-secret-key
GEMINI_API_KEY=your-gemini-key
```

## Notes

- **No Database Required:** Uses in-memory storage for MVP
- **Mock AI Responses:** Works without Gemini API key
- **CORS Enabled:** Can be accessed from any frontend
- **JWT Auth:** Secure token-based authentication

## Support

For issues or questions, check the documentation or create an issue.

---

**Version:** 1.0.0  
**License:** ISC
