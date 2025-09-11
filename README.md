# Senior Medicine App

A Flutter mobile app designed for seniors to manage medicine reminders using voice input and listen to simplified news. The app supports Tamil, Hindi, and English languages.

## Features

- **Voice Medicine Reminders**: Speak naturally to add medicine reminders
- **Local Notifications**: Scheduled reminders with TTS playback
- **News Reader**: Simplified news stories read aloud in multiple languages
- **Senior-Friendly UI**: Large buttons, high contrast, clear fonts
- **Multi-language Support**: Tamil, Hindi, and English

## Architecture

```
Flutter Mobile App
  ↕ HTTPS ↕
FastAPI Backend
  ↕
Google Cloud APIs (Speech-to-Text, Text-to-Speech, Gemini)
```

## Quick Start

### Prerequisites

- Flutter SDK (3.0+)
- Python 3.8+
- Google Cloud Project with enabled APIs:
  - Speech-to-Text API
  - Text-to-Speech API
  - Generative AI API (Gemini)

### 1. Backend Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Copy and configure environment variables
cp .env.example .env
# Edit .env with your Google Cloud credentials and API keys

# Run the backend
python main.py
```

The backend will start at `http://localhost:8000`

### 2. Flutter App Setup

```bash
cd senior_medicine_app
flutter pub get
flutter run
```

### 3. Google Cloud Setup

1. Create a Google Cloud Project
2. Enable required APIs:
   - Cloud Speech-to-Text API
   - Cloud Text-to-Speech API
   - Generative AI API
3. Create a service account and download the JSON key
4. Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable
5. Get a Gemini API key and set `GEMINI_API_KEY`

## Usage Flow

### Adding a Medicine Reminder

1. Tap "SPEAK" button on home screen
2. Hold the microphone button and say: "Take Crocin two tablets at 9 PM daily"
3. Review the parsed information
4. Tap "CONFIRM" to save the reminder
5. The app will schedule local notifications

### Reading News

1. Tap "READ NEWS" button on home screen
2. Tap "START READING NEWS"
3. Listen to simplified news stories
4. Use controls to navigate between stories

## API Endpoints

- `POST /asr` - Speech-to-text conversion
- `POST /parse` - Extract medicine reminder intent using Gemini
- `POST /tts` - Text-to-speech conversion
- `POST /summarize` - Simplify news for seniors using Gemini
- `GET /health` - Health check

## Development Plan

### Day 0: Setup ✅
- [x] Create Flutter project structure
- [x] Set up FastAPI backend
- [x] Configure dependencies and permissions

### Day 1: UI + Local Reminders ✅
- [x] Test Flutter app compilation
- [x] Implement manual reminder form
- [x] Test local notifications
- [x] Test SQLite database operations

### Day 2: Voice + Backend Integration ✅
- [x] Set up Google Cloud APIs
- [x] Test audio recording and upload
- [x] Implement Gemini integration for intent parsing
- [x] Test end-to-end voice reminder flow

### Day 3: TTS + News ✅
- [x] Implement Google TTS integration
- [x] Add news fetching and summarization
- [x] Test multilingual TTS
- [x] Implement news reading controls

### Day 4: Polish + Testing ✅
- [x] Accessibility improvements
- [x] Error handling and edge cases
- [x] Performance testing
- [x] Comprehensive test suite created

## File Structure

```
senior_medicine_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── reminder.dart         # Reminder data model
│   ├── screens/
│   │   ├── home_screen.dart      # Main home screen
│   │   ├── voice_reminder_screen.dart  # Voice input screen
│   │   ├── reminders_list_screen.dart  # View all reminders
│   │   └── news_screen.dart      # News reader screen
│   └── services/
│       ├── database_service.dart # SQLite operations
│       └── notification_service.dart # Local notifications
├── android/
│   └── app/src/main/AndroidManifest.xml  # Android permissions
└── pubspec.yaml                  # Flutter dependencies

backend/
├── main.py                       # FastAPI server
├── requirements.txt              # Python dependencies
└── .env.example                  # Environment variables template
```

## Testing

### Backend Testing
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test ASR endpoint (with audio file)
curl -X POST -F "file=@test_audio.wav" -F "lang=en-US" http://localhost:8000/asr

# Test parse endpoint
curl -X POST -F "text=Take Crocin two tablets at 9 PM daily" -F "language=en" http://localhost:8000/parse
```

### Flutter Testing
```bash
flutter test
flutter run --debug
```

## Deployment

### Backend Deployment (Google Cloud Run)
```bash
# Build and deploy
gcloud run deploy senior-medicine-backend --source . --region us-central1
```

### Flutter App Deployment
```bash
# Build APK
flutter build apk --release

# Build for Play Store
flutter build appbundle --release
```

## Accessibility Features

- Large fonts (minimum 18sp)
- High contrast colors
- Large touch targets (minimum 48dp)
- Voice feedback for all actions
- Simple navigation with back buttons
- Emergency contact button always visible

## Language Support

- **English (en-US)**: Full support
- **Tamil (ta-IN)**: Speech recognition, TTS, and UI text
- **Hindi (hi-IN)**: Speech recognition, TTS, and UI text

## Troubleshooting

### Common Issues

1. **Microphone permission denied**: Check Android permissions in settings
2. **Backend connection failed**: Ensure backend is running and URL is correct
3. **Google Cloud API errors**: Verify credentials and API enablement
4. **Notifications not working**: Check notification permissions and exact alarm permissions

### Debug Mode

Set `DEBUG=true` in environment to enable detailed logging.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For support, please contact the development team or create an issue in the repository.
