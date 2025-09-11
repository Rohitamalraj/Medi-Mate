class AppConstants {
  // API Configuration
  static const String backendUrl = 'http://localhost:8000';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // UI Constants
  static const double largeFontSize = 22.0;
  static const double mediumFontSize = 20.0;
  static const double smallFontSize = 18.0;
  static const double buttonHeight = 80.0;
  static const double buttonPadding = 20.0;
  static const double screenPadding = 24.0;
  
  // Audio Recording
  static const int sampleRate = 16000;
  static const Duration maxRecordingDuration = Duration(seconds: 30);
  
  // Notification Settings
  static const String notificationChannelId = 'medicine_reminders';
  static const String notificationChannelName = 'Medicine Reminders';
  static const String notificationChannelDescription = 'Notifications for medicine reminders';
  
  // Language Codes
  static const Map<String, String> languageCodes = {
    'English': 'en-US',
    'Tamil': 'ta-IN',
    'Hindi': 'hi-IN',
  };
  
  // Common Medicines
  static const List<String> commonMedicines = [
    'Crocin',
    'Paracetamol',
    'Aspirin',
    'Ibuprofen',
    'Vitamin D',
    'Vitamin C',
    'Calcium',
    'Iron',
    'Multivitamin',
    'Fish Oil',
  ];
  
  // Common Doses
  static const List<String> commonDoses = [
    '1 tablet',
    '2 tablets',
    '1/2 tablet',
    '1 capsule',
    '2 capsules',
    '1 spoon',
    '2 spoons',
    '5ml',
    '10ml',
    '15ml',
  ];
  
  // Frequencies
  static const List<String> frequencies = [
    'once',
    'daily',
    'twice daily',
    'weekly',
  ];
  
  // TTS Settings
  static const double speechRate = 0.8;
  static const double speechVolume = 1.0;
  static const double speechPitch = 1.0;
  
  // Colors (for consistency)
  static const int primaryBlue = 0xFF2196F3;
  static const int primaryGreen = 0xFF4CAF50;
  static const int primaryOrange = 0xFFFF9800;
  static const int primaryRed = 0xFFF44336;
  static const int primaryPurple = 0xFF9C27B0;
}
