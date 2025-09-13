import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class RemindersListScreen extends StatefulWidget {
  const RemindersListScreen({super.key});

  @override
  State<RemindersListScreen> createState() => _RemindersListScreenState();
}

class _RemindersListScreenState extends State<RemindersListScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadReminders();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await DatabaseService.instance.getAllReminders();
      setState(() {
        _reminders = reminders;
        _isLoading = false;
      });

      if (reminders.isEmpty) {
        await _flutterTts.speak("You have no reminders set up yet. Go back to add your first reminder.");
      } else {
        await _flutterTts.speak("You have ${reminders.length} reminders. Tap on any reminder to hear it or delete it.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading reminders: $e');
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    try {
      await DatabaseService.instance.deleteReminder(reminder.id!);
      await NotificationService.instance.cancelReminder(reminder.id!);
      
      await _flutterTts.speak("Reminder for ${reminder.medicine} has been deleted.");
      
      _loadReminders(); // Reload the list
    } catch (e) {
      print('Error deleting reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting reminder: $e')),
      );
    }
  }

  Future<void> _speakReminder(Reminder reminder) async {
    final text = "Reminder: Take ${reminder.dose} of ${reminder.medicine} at ${reminder.displayTime}, ${reminder.repeat}";
    await _flutterTts.speak(text);
  }

  void _showDeleteConfirmation(Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Reminder?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete the reminder for ${reminder.medicine}?',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReminder(reminder);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'DELETE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Reminders', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.blue[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(strokeWidth: 6),
            )
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No Reminders Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Go back to the home screen and tap "SPEAK" to add your first medicine reminder.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add, size: 24),
              label: const Text('ADD REMINDER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 60),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue[200]!, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap any reminder to hear it. Tap delete to remove it.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reminders list
          Expanded(
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _speakReminder(reminder),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Medicine icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.medication,
                              color: Colors.green[600],
                              size: 32,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Reminder details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.medicine,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reminder.dose,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${reminder.displayTime} • ${reminder.repeat}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Delete button
                          IconButton(
                            onPressed: () => _showDeleteConfirmation(reminder),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
