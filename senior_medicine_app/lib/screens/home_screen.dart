import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_reminder_screen.dart';
import 'caregiver_screen.dart';
import '../services/emergency_service.dart';
import '../services/health_checkin_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final EmergencyService _emergencyService = EmergencyService();
  final HealthCheckinService _healthService = HealthCheckinService();
  String _selectedLanguage = 'en-US';
  String _selectedLanguageDisplay = 'English';
  bool _emergencyListening = false;

  final Map<String, String> _languages = {
    'en-US': 'English',
    'ta-IN': 'தமிழ்',
    'hi-IN': 'हिंदी',
  };

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeEmergencyService();
    _welcomeMessage();
  }

  Future<void> _initializeEmergencyService() async {
    await _emergencyService.initialize();
    await _emergencyService.startEmergencyListening();
    setState(() {
      _emergencyListening = true;
    });
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setSpeechRate(0.7); // Slower speech for seniors
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _welcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak("Welcome to MediMate. Choose an action by tapping the big buttons.");
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
      _selectedLanguageDisplay = _languages[languageCode] ?? 'English';
    });
    _initializeTts();
    _speak("Language changed to ${_languages[languageCode]}");
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Emergency SOS',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Emergency detected! Call emergency services now?', 
                 style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            SizedBox(height: 16),
            Text('Emergency: 102', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _speak("Calling emergency services now");
              await _emergencyService.manualEmergencyCall(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CALL NOW', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MediMate',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area with 3 giant cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 1. Speak Reminder - Primary Action (80-100px height) with Emergency SOS
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Stack(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _speak("Opening voice reminder. Press and hold the big button to speak.");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VoiceReminderScreen(language: _selectedLanguage),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic, size: 48),
                                SizedBox(width: 16),
                                Text(
                                  '🎙 Speak Reminder',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Emergency SOS indicator
                          if (_emergencyListening)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.hearing, size: 16, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'SOS Active',
                                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 2. Daily Health Check-in - New MVP Feature
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () async {
                          _speak("Starting your daily health check-in. How are you feeling today?");
                          await _healthService.performDailyCheckin(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, size: 48),
                            SizedBox(width: 16),
                            Text(
                              '❤️ Health Check-in',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Caregiver Connect - New MVP Feature  
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening caregiver dashboard. View your health status and reminders.");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CaregiverScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.family_restroom, size: 48),
                            SizedBox(width: 16),
                            Text(
                              '👨‍👩‍👧 Caregiver Connect',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom persistent area with language toggle and emergency
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language toggle
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Choose Language',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              ..._languages.entries.map((entry) => 
                                ListTile(
                                  title: Text(
                                    entry.value,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  trailing: _selectedLanguage == entry.key 
                                    ? const Icon(Icons.check, color: Colors.green, size: 32)
                                    : null,
                                  onTap: () {
                                    _changeLanguage(entry.key);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 24, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            _selectedLanguageDisplay,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Emergency SOS button with enhanced design
                  GestureDetector(
                    onTap: () {
                      _speak("Emergency SOS activated");
                      _showEmergencyDialog();
                    },
                    onLongPress: () async {
                      // Instant emergency call on long press
                      _speak("Emergency! Calling now!");
                      await _emergencyService.manualEmergencyCall(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sos, size: 32, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'SOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _speak("Quick access to your medicine reminders");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VoiceReminderScreen(language: _selectedLanguage),
            ),
          );
        },
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.medication, size: 28),
        label: const Text(
          'Quick Reminder',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}