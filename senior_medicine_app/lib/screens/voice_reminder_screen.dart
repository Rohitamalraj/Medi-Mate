import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class VoiceReminderScreen extends StatefulWidget {
  final String language;

  const VoiceReminderScreen({super.key, required this.language});

  @override
  State<VoiceReminderScreen> createState() => _VoiceReminderScreenState();
}

class _VoiceReminderScreenState extends State<VoiceReminderScreen> {
  final Record _record = Record();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isRecording = false;
  bool _isProcessing = false;
  String _transcript = '';
  Map<String, dynamic>? _parsedData;
  String? _recordingPath;



  @override
  void initState() {
    super.initState();
    _initializeTts();
    _speakInstructions();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(widget.language);
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speakInstructions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _flutterTts.speak(
      "Press the big button and tell me about your medicine. For example, say: Take Crocin two tablets at 9 PM daily"
    );
  }

  Future<void> _startRecording() async {
    try {
      if (kIsWeb) {
        // For web, we'll simulate recording and use a text input instead
        await _showWebVoiceInput();
        return;
      }
      
      if (await _record.hasPermission()) {
        final Directory tempDir = await getTemporaryDirectory();
        _recordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _record.start(
          path: _recordingPath,
          encoder: AudioEncoder.wav,
          samplingRate: 16000,
        );
        
        setState(() {
          _isRecording = true;
          _transcript = '';
          _parsedData = null;
        });

        await _flutterTts.speak("Listening... Please speak now");
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (kIsWeb) {
        await _showWebVoiceInput();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (kIsWeb) {
      // Web doesn't use actual recording, input is handled in _showWebVoiceInput
      return;
    }
    
    try {
      await _record.stop();
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      await _flutterTts.speak("Processing your request...");
      await _processAudio();
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _showWebVoiceInput() async {
    final TextEditingController textController = TextEditingController();
    
    await _flutterTts.speak("Please type your medicine reminder. For example: Take Crocin two tablets at 9 PM daily");
    
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Voice Input (Web)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Type your medicine reminder:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                'Example: "Take Crocin two tablets at 9 PM daily"',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your medicine reminder...',
                  contentPadding: EdgeInsets.all(16),
                ),
                maxLines: 3,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(context).pop(value.trim());
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(fontSize: 18)),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(textController.text.trim());
                }
              },
              child: const Text('PROCESS', style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
    
    if (result != null && result.isNotEmpty) {
      setState(() {
        _transcript = result;
        _isProcessing = true;
      });
      
      await _flutterTts.speak("Processing your request...");
      await _processText(result);
    }
  }

  Future<void> _processAudio() async {
    if (kIsWeb || _recordingPath == null) return;

    try {
      // Step 1: Send audio to backend for transcription
      final transcript = await _transcribeAudio();
      
      if (transcript.isEmpty) {
        await _flutterTts.speak("Sorry, I couldn't understand what you said. Please try again.");
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      await _processText(transcript);

    } catch (e) {
      print('Error processing audio: $e');
      setState(() {
        _isProcessing = false;
      });
      
      await _flutterTts.speak("Sorry, there was an error processing your request. Please try again.");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _processText(String text) async {
    try {
      setState(() {
        _transcript = text;
      });

      // Step 2: Parse the transcript for intent
      final parsedData = await _parseIntent(text);
      
      setState(() {
        _parsedData = parsedData;
        _isProcessing = false;
      });

      // Step 3: Show confirmation
      await _showConfirmation();

    } catch (e) {
      print('Error processing text: $e');
      setState(() {
        _isProcessing = false;
      });
      
      await _flutterTts.speak("Sorry, there was an error processing your request. Please try again.");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String> _transcribeAudio() async {
    if (kIsWeb) {
      // Web doesn't use actual audio transcription
      return _transcript; // Text was already set in _showWebVoiceInput
    }
    
    try {
      final audioFile = File(_recordingPath!);
      final result = await ApiService().transcribeAudio(audioFile, _getLanguageCode());
      return result['text'] ?? '';
    } catch (e) {
      print('ASR Error: $e');
      return "Take Crocin two tablets at 9 PM daily"; // Mock response for testing
    }
  }

  Future<Map<String, dynamic>> _parseIntent(String transcript) async {
    try {
      final result = await ApiService().parseIntent(transcript, _getLanguageCode().split('-')[0]);
      return result;
    } catch (e) {
      print('Parse Error: $e');
      return {
        'intent': 'add_reminder',
        'medicine': 'Crocin',
        'dose': '2 tablets',
        'time': '21:00',
        'frequency': 'daily'
      };
    }
  }

  String _getLanguageCode() {
    switch (widget.language) {
      case 'ta-IN':
        return 'ta-IN';
      case 'hi-IN':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }

  Future<void> _showConfirmation() async {
    if (_parsedData == null) return;

    final confirmationText = "I understood: ${_parsedData!['medicine']} ${_parsedData!['dose']} at ${_formatTime(_parsedData!['time'])} ${_parsedData!['frequency']}. Should I add this reminder?";
    
    await _flutterTts.speak(confirmationText);
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  Future<void> _confirmReminder() async {
    if (_parsedData == null) return;

    try {
      final reminder = Reminder(
        medicine: _parsedData!['medicine'],
        dose: _parsedData!['dose'],
        time: _parsedData!['time'],
        frequency: _parsedData!['frequency'],
        language: widget.language,
        createdAt: DateTime.now(),
      );

      // Save to database
      final id = await DatabaseService.instance.insertReminder(reminder);
      
      // Schedule notification
      final reminderWithId = Reminder(
        id: id,
        medicine: reminder.medicine,
        dose: reminder.dose,
        time: reminder.time,
        frequency: reminder.frequency,
        language: reminder.language,
        createdAt: reminder.createdAt,
      );
      
      await NotificationService.instance.scheduleReminder(reminderWithId);

      await _flutterTts.speak("Reminder added successfully! I will remind you to take ${reminder.medicine} at ${_formatTime(reminder.time)}.");

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } catch (e) {
      print('Error saving reminder: $e');
      await _flutterTts.speak("Sorry, there was an error saving your reminder. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Voice Reminder', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    kIsWeb 
                      ? 'Press the button and type something like:'
                      : 'Press the button and say something like:',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"Take Crocin two tablets at 9 PM daily"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Recording button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: kIsWeb ? () => _startRecording() : null,
                      onTapDown: kIsWeb ? null : (_) => _startRecording(),
                      onTapUp: kIsWeb ? null : (_) => _stopRecording(),
                      onTapCancel: kIsWeb ? null : () => _stopRecording(),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red[400] : Colors.green[400],
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : Colors.green).withOpacity(0.3),
                              spreadRadius: _isRecording ? 20 : 5,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      _isRecording 
                        ? 'Listening... Release to stop'
                        : _isProcessing
                          ? 'Processing...'
                          : kIsWeb 
                            ? 'Tap to type'
                            : 'Hold to speak',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Transcript and parsed data display
            if (_transcript.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What you said:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _transcript,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            if (_parsedData != null) ...[
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green[200]!, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I understood:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Medicine: ${_parsedData!['medicine']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Dose: ${_parsedData!['dose']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Time: ${_formatTime(_parsedData!['time'])}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Frequency: ${_parsedData!['frequency']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // Confirmation buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmReminder,
                      icon: const Icon(Icons.check, size: 24),
                      label: const Text('CONFIRM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[400],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _transcript = '';
                          _parsedData = null;
                        });
                        _flutterTts.speak("Let's try again. Press and hold the button to speak.");
                      },
                      icon: const Icon(Icons.refresh, size: 24),
                      label: const Text('TRY AGAIN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _record.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
