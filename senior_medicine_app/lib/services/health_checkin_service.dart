import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class HealthCheckin {
  final int? id;
  final DateTime date;
  final String status; // 'good', 'not well', 'neutral'
  final String? notes;
  final DateTime createdAt;

  HealthCheckin({
    this.id,
    required this.date,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HealthCheckin.fromMap(Map<String, dynamic> map) {
    return HealthCheckin(
      id: map['id'],
      date: DateTime.parse(map['date']),
      status: map['status'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class HealthCheckinService {
  static final HealthCheckinService _instance = HealthCheckinService._internal();
  factory HealthCheckinService() => _instance;
  HealthCheckinService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  Future<void> initialize() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setVolume(1.0);
  }

  // Daily morning check-in
  Future<void> performDailyCheckin(BuildContext context) async {
    final userName = "there"; // Get from user preferences
    final greeting = _getTimeBasedGreeting();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => HealthCheckinDialog(
        greeting: "$greeting, $userName!",
        onComplete: (checkin) => _saveCheckin(checkin),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  // Analyze health status from voice input
  Future<String> analyzeHealthStatus(String spokenText) async {
    try {
      // Use Gemini API for health status classification
      final result = await ApiService().classifyHealthStatus(spokenText);
      return result['status'] ?? 'neutral';
    } catch (e) {
      // Fallback keyword analysis
      return _fallbackHealthAnalysis(spokenText.toLowerCase());
    }
  }

  String _fallbackHealthAnalysis(String text) {
    // Positive keywords
    final goodKeywords = [
      'good', 'great', 'fine', 'excellent', 'wonderful', 'healthy',
      'better', 'energetic', 'happy', 'well'
    ];
    
    // Negative keywords
    final badKeywords = [
      'bad', 'terrible', 'sick', 'unwell', 'pain', 'hurt', 'tired',
      'weak', 'dizzy', 'nausea', 'headache', 'fever', 'cold'
    ];
    
    if (goodKeywords.any((keyword) => text.contains(keyword))) {
      return 'good';
    } else if (badKeywords.any((keyword) => text.contains(keyword))) {
      return 'not well';
    }
    
    return 'neutral';
  }

  // Save health check-in to database
  Future<void> _saveCheckin(HealthCheckin checkin) async {
    // TODO: Implement database save
    print('Health check-in saved: ${checkin.status} on ${checkin.date}');
  }

  // Get weekly health status for caregiver
  Future<List<HealthCheckin>> getWeeklyCheckins() async {
    // TODO: Implement database query
    // Mock data for now
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return HealthCheckin(
        id: index,
        date: date,
        status: ['good', 'neutral', 'not well'][index % 3],
        createdAt: date,
      );
    });
  }
}

class HealthCheckinDialog extends StatefulWidget {
  final String greeting;
  final Function(HealthCheckin) onComplete;

  const HealthCheckinDialog({
    super.key,
    required this.greeting,
    required this.onComplete,
  });

  @override
  State<HealthCheckinDialog> createState() => _HealthCheckinDialogState();
}

class _HealthCheckinDialogState extends State<HealthCheckinDialog> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  String _transcript = '';
  String _analyzedStatus = '';

  @override
  void initState() {
    super.initState();
    _initializeAndAsk();
  }

  Future<void> _initializeAndAsk() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.7);
    
    await Future.delayed(const Duration(milliseconds: 500));
    await _flutterTts.speak("${widget.greeting} How are you feeling today?");
  }

  Future<void> _startListening() async {
    if (!_speechToText.isAvailable) return;

    setState(() {
      _isListening = true;
      _transcript = '';
    });

    await _speechToText.listen(
      onResult: (result) async {
        setState(() {
          _transcript = result.recognizedWords;
        });

        if (result.finalResult) {
          await _analyzeResponse();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  Future<void> _analyzeResponse() async {
    setState(() {
      _isListening = false;
    });

    if (_transcript.isNotEmpty) {
      final status = await HealthCheckinService().analyzeHealthStatus(_transcript);
      
      setState(() {
        _analyzedStatus = status;
      });

      // Provide feedback
      String feedback;
      switch (status) {
        case 'good':
          feedback = "That's wonderful! I'm glad you're feeling good today.";
          break;
        case 'not well':
          feedback = "I'm sorry you're not feeling well. Please take care and consider calling your doctor if needed.";
          break;
        default:
          feedback = "Thank you for sharing. I hope your day gets better.";
      }

      await _flutterTts.speak(feedback);
    }
  }

  void _completeCheckin() {
    final checkin = HealthCheckin(
      date: DateTime.now(),
      status: _analyzedStatus.isNotEmpty ? _analyzedStatus : 'neutral',
      notes: _transcript,
      createdAt: DateTime.now(),
    );

    widget.onComplete(checkin);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '❤️ Daily Health Check',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.greeting,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            
            // Voice input button
            GestureDetector(
              onTap: _startListening,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red[400] : Colors.blue[400],
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.3),
                      spreadRadius: _isListening ? 15 : 5,
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _isListening ? 'Listening...' : 'Tap to speak',
              style: const TextStyle(fontSize: 16),
            ),
            
            if (_transcript.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You said: "$_transcript"',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            
            if (_analyzedStatus.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(_analyzedStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getStatusIcon(_analyzedStatus), color: _getStatusColor(_analyzedStatus)),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${_analyzedStatus.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(_analyzedStatus),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('SKIP', style: TextStyle(fontSize: 18)),
        ),
        if (_analyzedStatus.isNotEmpty)
          ElevatedButton(
            onPressed: _completeCheckin,
            child: const Text('SAVE', style: TextStyle(fontSize: 18)),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'good':
        return Colors.green;
      case 'not well':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'good':
        return Icons.sentiment_very_satisfied;
      case 'not well':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}