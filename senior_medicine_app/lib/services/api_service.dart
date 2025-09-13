import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, dynamic>> transcribeAudio(File audioFile, String language) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/asr'));
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));
      request.fields['lang'] = language;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('ASR failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for testing when backend is not available
      return {
        'text': 'Take Crocin two tablets at 9 PM daily',
        'language': language,
        'mock': true
      };
    }
  }

  Future<Map<String, dynamic>> parseIntent(String text, String language) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/parse'),
        body: {
          'text': text,
          'language': language,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Parse failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data for testing when backend is not available
      return {
        'intent': 'add_reminder',
        'medicine': _extractMedicine(text),
        'dose': _extractDose(text),
        'time': _extractTime(text),
        'frequency': _extractFrequency(text),
        'mock': true
      };
    }
  }

  Future<List<int>> synthesizeSpeech(String text, String language) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/tts'),
        body: {
          'text': text,
          'lang': language,
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('TTS failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty bytes for testing when backend is not available
      return [];
    }
  }

  Future<List<String>> summarizeNews(List<String> articles, String language) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/summarize'),
        body: {
          'articles': json.encode(articles),
          'language': language,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return List<String>.from(data['simplified_news']);
      } else {
        throw Exception('Summarization failed: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock simplified news for testing
      return articles.map((article) => 'Simplified: ${article.substring(0, 50)}...').toList();
    }
  }

  Future<bool> checkHealth() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper methods for mock parsing
  String _extractMedicine(String text) {
    final medicines = ['crocin', 'paracetamol', 'aspirin', 'vitamin', 'calcium'];
    for (var medicine in medicines) {
      if (text.toLowerCase().contains(medicine)) {
        return medicine.substring(0, 1).toUpperCase() + medicine.substring(1);
      }
    }
    return 'Medicine';
  }

  String _extractDose(String text) {
    final dosePattern = RegExp(r'(\d+)\s*(tablet|spoon|drop|ml|mg)', caseSensitive: false);
    final match = dosePattern.firstMatch(text);
    if (match != null) {
      final number = match.group(1);
      final unit = match.group(2)!.toLowerCase();
      return number == '1' ? '$number $unit' : '$number ${unit}s';
    }
    return '1 tablet';
  }

  String _extractTime(String text) {
    final timePatterns = [
      RegExp(r'(\d{1,2})\s*pm', caseSensitive: false),
      RegExp(r'(\d{1,2})\s*am', caseSensitive: false),
      RegExp(r'(\d{1,2}):(\d{2})'),
    ];

    for (var pattern in timePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        if (text.toLowerCase().contains('pm')) {
          int hour = int.parse(match.group(1)!);
          if (hour != 12) hour += 12;
          return '${hour.toString().padLeft(2, '0')}:00';
        } else if (text.toLowerCase().contains('am')) {
          int hour = int.parse(match.group(1)!);
          if (hour == 12) hour = 0;
          return '${hour.toString().padLeft(2, '0')}:00';
        }
      }
    }
    return '09:00'; // Default to 9 AM
  }

  String _extractFrequency(String text) {
    if (text.toLowerCase().contains('daily') || text.toLowerCase().contains('every day')) {
      return 'daily';
    } else if (text.toLowerCase().contains('weekly') || text.toLowerCase().contains('every week')) {
      return 'weekly';
    } else if (text.toLowerCase().contains('once')) {
      return 'once';
    }
    return 'daily'; // Default
  }

  // New methods for MVP features
  Future<Map<String, dynamic>> classifyIntent(String text) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/classify-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Intent classification failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback intent classification
      final textLower = text.toLowerCase();
      if (textLower.contains('emergency') || 
          textLower.contains('help') || 
          textLower.contains('urgent') ||
          textLower.contains('call doctor') ||
          textLower.contains('pain') ||
          textLower.contains('can\'t breathe')) {
        return {'intent': 'emergency'};
      } else if (textLower.contains('reminder') || 
                 textLower.contains('medicine') ||
                 textLower.contains('tablet')) {
        return {'intent': 'reminder'};
      } else if (textLower.contains('news') || textLower.contains('read')) {
        return {'intent': 'news'};
      }
      return {'intent': 'other'};
    }
  }

  Future<Map<String, dynamic>> classifyHealthStatus(String text) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/classify-health'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health classification failed: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback health classification
      final textLower = text.toLowerCase();
      
      final goodKeywords = ['good', 'great', 'fine', 'excellent', 'wonderful', 'healthy', 'better', 'energetic'];
      final badKeywords = ['bad', 'terrible', 'sick', 'unwell', 'pain', 'hurt', 'tired', 'weak', 'dizzy'];
      
      if (goodKeywords.any((keyword) => textLower.contains(keyword))) {
        return {'status': 'good'};
      } else if (badKeywords.any((keyword) => textLower.contains(keyword))) {
        return {'status': 'not well'};
      }
      return {'status': 'neutral'};
    }
  }
}
