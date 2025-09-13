import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_reminder_screen.dart';
import 'reminders_list_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedLanguage = 'en-US';
  String _selectedLanguageDisplay = 'English';

  final Map<String, String> _languages = {
    'en-US': 'English',
    'ta-IN': 'தமிழ்',
    'hi-IN': 'हिंदी',
  };

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _welcomeMessage();
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
          'Emergency Contact',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Call emergency services?', style: TextStyle(fontSize: 20)),
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
            onPressed: () {
              Navigator.pop(context);
              _speak("Calling emergency services");
              // TODO: Implement actual emergency calling
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CALL', style: TextStyle(fontSize: 18, color: Colors.white)),
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
                    // 1. Speak Reminder - Primary Action (80-100px height)
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ElevatedButton(
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
                    ),

                    // 2. Read News - Secondary Action
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening news reader. I will read today's health news to you.");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsScreen(language: _selectedLanguage),
                            ),
                          );
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
                            Icon(Icons.newspaper, size: 48),
                            SizedBox(width: 16),
                            Text(
                              '📰 Read News',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. My Reminders - List Action
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          _speak("Opening your reminders list.");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RemindersListScreen(),
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
                            Icon(Icons.list_alt, size: 48),
                            SizedBox(width: 16),
                            Text(
                              '⏰ My Reminders',
                              style: TextStyle(
                                fontSize: 28,
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

                  // Emergency contact button
                  GestureDetector(
                    onTap: () {
                      _speak("Emergency contact");
                      _showEmergencyDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emergency, size: 32, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Emergency',
                            style: TextStyle(
                              fontSize: 16,
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
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}