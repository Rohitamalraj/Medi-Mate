import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'api_service.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _emergencyNumber = "tel:102"; // India emergency number

  // Configurable emergency contacts
  List<String> emergencyContacts = [
    "tel:102", // Emergency services
    "tel:+919876543210", // Family/caregiver (replace with actual)
  ];

  Future<void> initialize() async {
    await _initializeSpeech();
    await _initializeTts();
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize(
      onError: (errorNotification) => print('Speech error: $errorNotification'),
      onStatus: (status) => print('Speech status: $status'),
    );
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
  }

  // Voice hotword detection for emergency
  Future<void> startEmergencyListening() async {
    if (!_speechToText.isAvailable || _isListening) return;

    _isListening = true;
    await _speechToText.listen(
      onResult: (result) async {
        final spokenWords = result.recognizedWords.toLowerCase();
        await _checkForEmergency(spokenWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      localeId: 'en_US',
      onSoundLevelChange: null,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopEmergencyListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  // Check if spoken text contains emergency keywords
  Future<void> _checkForEmergency(String spokenText) async {
    try {
      // Use Gemini API to detect emergency intent
      final result = await ApiService().classifyIntent(spokenText);
      
      if (result['intent'] == 'emergency') {
        await _triggerEmergency();
      }
    } catch (e) {
      // Fallback keyword detection
      final emergencyKeywords = [
        'emergency', 'help', 'urgent', 'call doctor', 'pain', 'chest pain',
        'can\'t breathe', 'dizzy', 'fell down', 'accident'
      ];
      
      if (emergencyKeywords.any((keyword) => spokenText.contains(keyword))) {
        await _triggerEmergency();
      }
    }
  }

  // Trigger emergency protocol
  Future<void> _triggerEmergency() async {
    await _flutterTts.speak("Emergency detected! Calling for help now.");
    
    // Try to call emergency contact
    for (String contact in emergencyContacts) {
      final success = await _makeEmergencyCall(contact);
      if (success) break;
    }
  }

  // Make emergency call
  Future<bool> _makeEmergencyCall(String phoneNumber) async {
    try {
      // Request phone permission
      final permissionStatus = await Permission.phone.request();
      if (permissionStatus != PermissionStatus.granted) {
        await _flutterTts.speak("Please allow phone permissions to make emergency calls");
        return false;
      }

      final Uri phoneUri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return true;
      } else {
        print('Could not launch $phoneNumber');
        return false;
      }
    } catch (e) {
      print('Error making emergency call: $e');
      return false;
    }
  }

  // Manual emergency button press
  Future<void> manualEmergencyCall(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '🆘 Emergency Call',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you having an emergency?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will call emergency services immediately.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
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
              await _triggerEmergency();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'CALL NOW',
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Update emergency contacts
  void setEmergencyContacts(List<String> contacts) {
    emergencyContacts = contacts;
  }

  // Get current status
  bool get isListening => _isListening;
}