import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';

  Future<void> initialize({String language = 'en-US'}) async {
    if (_isInitialized && _currentLanguage == language) return;

    _currentLanguage = language;
    
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(0.8); // Slower for seniors
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    // Set voice preferences based on language
    if (Platform.isAndroid) {
      await _flutterTts.setVoice({
        'name': _getPreferredVoice(language),
        'locale': language,
      });
    }

    _isInitialized = true;
  }

  String _getPreferredVoice(String language) {
    switch (language) {
      case 'ta-IN':
        return 'ta-in-x-tag-network'; // Tamil voice
      case 'hi-IN':
        return 'hi-in-x-hie-network'; // Hindi voice
      default:
        return 'en-us-x-tpf-network'; // English voice
    }
  }

  /// Speak text using local TTS
  Future<void> speak(String text, {String? language}) async {
    if (language != null && language != _currentLanguage) {
      await initialize(language: language);
    }

    await _flutterTts.speak(text);
  }

  /// Speak text using Google Cloud TTS (higher quality)
  Future<void> speakWithCloudTTS(String text, {String? language}) async {
    try {
      final lang = language ?? _currentLanguage;
      final audioBytes = await ApiService().synthesizeSpeech(text, lang);
      
      if (audioBytes.isNotEmpty) {
        // Save audio to temporary file and play
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(audioBytes);
        
        await _audioPlayer.setFilePath(audioFile.path);
        await _audioPlayer.play();
        
        // Clean up after playing
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            audioFile.deleteSync();
          }
        });
      } else {
        // Fallback to local TTS
        await speak(text, language: language);
      }
    } catch (e) {
      print('Cloud TTS error: $e');
      // Fallback to local TTS
      await speak(text, language: language);
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    await _flutterTts.stop();
    await _audioPlayer.stop();
  }

  /// Pause current speech
  Future<void> pause() async {
    await _flutterTts.pause();
    await _audioPlayer.pause();
  }

  /// Resume paused speech
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  /// Set speech rate (0.5 to 2.0)
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return languages?.cast<String>() ?? [];
  }

  /// Get available voices for current language
  Future<List<Map<String, String>>> getAvailableVoices() async {
    final voices = await _flutterTts.getVoices;
    return voices?.cast<Map<String, String>>() ?? [];
  }

  /// Speak reminder text with appropriate formatting
  Future<void> speakReminder(String medicine, String dose, String time, {String? language}) async {
    final reminderText = _formatReminderText(medicine, dose, time, language ?? _currentLanguage);
    await speakWithCloudTTS(reminderText, language: language);
  }

  /// Speak confirmation text
  Future<void> speakConfirmation(String medicine, String dose, String time, String frequency, {String? language}) async {
    final confirmationText = _formatConfirmationText(medicine, dose, time, frequency, language ?? _currentLanguage);
    await speakWithCloudTTS(confirmationText, language: language);
  }

  /// Speak news item with appropriate pacing
  Future<void> speakNews(String newsText, {String? language}) async {
    // Add pauses for better comprehension
    final formattedText = newsText.replaceAll('.', '... ').replaceAll(',', ', ');
    await speakWithCloudTTS(formattedText, language: language);
  }

  String _formatReminderText(String medicine, String dose, String time, String language) {
    final timeFormatted = _formatTime12Hour(time);
    
    switch (language) {
      case 'ta-IN':
        return 'நேரம் ஆயிற்று. $medicine $dose எடுத்துக் கொள்ளுங்கள். நேரம் $timeFormatted.';
      case 'hi-IN':
        return 'समय हो गया है। $medicine की $dose लें। समय है $timeFormatted।';
      default:
        return 'It\'s time to take your medicine. Please take $dose of $medicine. The time is $timeFormatted.';
    }
  }

  String _formatConfirmationText(String medicine, String dose, String time, String frequency, String language) {
    final timeFormatted = _formatTime12Hour(time);
    
    switch (language) {
      case 'ta-IN':
        return '$medicine $dose $timeFormatted $frequency - இந்த நினைவூட்டலை சேர்க்கவா? ஆம் என்றால் உறுதிப்படுத்து என்று சொல்லுங்கள்.';
      case 'hi-IN':
        return '$medicine $dose $timeFormatted $frequency - यह रिमाइंडर जोड़ें? हां के लिए कन्फर्म कहें।';
      default:
        return 'Add reminder for $medicine, $dose at $timeFormatted, $frequency. Say confirm to add this reminder.';
    }
  }

  String _formatTime12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
    _audioPlayer.dispose();
  }
}
