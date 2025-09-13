import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'voice_reminder_screen.dart';
import 'reminders_list_screen.dart';
import 'news_screen.dart';
import 'manual_reminder_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _selectedLanguage = 'en-US';

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setSpeechRate(0.8); // Slower speech for seniors
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    _flutterTts.setLanguage(languageCode);
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main content area with 3 giant cards
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

            // Main action buttons
            const SizedBox(height: 20),
            
            // Speak button - primary action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _speak("Opening voice reminder");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoiceReminderScreen(language: _selectedLanguage),
                    ),
                  );
                },
                icon: const Icon(Icons.mic, size: 40),
                label: const Text('SPEAK\nAdd Medicine Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Read News button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _speak("Opening news reader");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsScreen(language: _selectedLanguage),
                    ),
                  );
                },
                icon: const Icon(Icons.newspaper, size: 40),
                label: const Text('READ NEWS\nListen to Today\'s News'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // View Reminders button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _speak("Opening reminders list");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RemindersListScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt, size: 40),
                label: const Text('MY REMINDERS\nView All Reminders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Manual Add Reminder button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _speak("Opening manual reminder form");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManualReminderScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 32),
                label: const Text('ADD MANUALLY\nType Medicine Details'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  side: BorderSide(color: Colors.purple[400]!, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Help text
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap any button to hear instructions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
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
