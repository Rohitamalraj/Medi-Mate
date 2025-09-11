import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ManualReminderScreen extends StatefulWidget {
  const ManualReminderScreen({super.key});

  @override
  State<ManualReminderScreen> createState() => _ManualReminderScreenState();
}

class _ManualReminderScreenState extends State<ManualReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineController = TextEditingController();
  final _doseController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFrequency = 'daily';
  bool _isLoading = false;

  final List<String> _frequencies = ['once', 'daily', 'weekly'];
  final List<String> _commonMedicines = [
    'Crocin', 'Paracetamol', 'Aspirin', 'Vitamin D', 'Calcium', 'Iron'
  ];
  final List<String> _commonDoses = [
    '1 tablet', '2 tablets', '1 spoon', '2 spoons', '5ml', '10ml'
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _speakInstructions();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> _speakInstructions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _flutterTts.speak(
      "Fill in the form to add a medicine reminder. Tap any field to hear instructions."
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    await _flutterTts.speak("Select the time for your medicine reminder");
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: const TextStyle(fontSize: 24),
              bodyLarge: const TextStyle(fontSize: 20),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      
      final timeString = _selectedTime.format(context);
      await _flutterTts.speak("Time selected: $timeString");
    }
  }

  String _formatTime24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      await _flutterTts.speak("Please fill in all required fields");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = Reminder(
        medicine: _medicineController.text.trim(),
        dose: _doseController.text.trim(),
        time: _formatTime24Hour(_selectedTime),
        frequency: _selectedFrequency,
        language: 'en-US',
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

      await _flutterTts.speak(
        "Reminder saved successfully! I will remind you to take ${reminder.dose} of ${reminder.medicine} at ${_selectedTime.format(context)} ${reminder.frequency}."
      );

      // Navigate back after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      });

    } catch (e) {
      print('Error saving reminder: $e');
      await _flutterTts.speak("Sorry, there was an error saving your reminder. Please try again.");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Reminder Manually', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Icon(Icons.edit, color: Colors.blue, size: 32),
                    const SizedBox(height: 10),
                    Text(
                      'Fill in the form below to add a medicine reminder',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Medicine Name Field
              Text(
                'Medicine Name *',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicineController,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'e.g., Crocin, Paracetamol',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down, size: 32),
                    onSelected: (value) {
                      _medicineController.text = value;
                      _flutterTts.speak("Selected $value");
                    },
                    itemBuilder: (context) => _commonMedicines
                        .map((medicine) => PopupMenuItem(
                              value: medicine,
                              child: Text(medicine, style: const TextStyle(fontSize: 18)),
                            ))
                        .toList(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
                onTap: () => _flutterTts.speak("Enter the name of your medicine"),
              ),

              const SizedBox(height: 24),

              // Dose Field
              Text(
                'Dose *',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doseController,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'e.g., 2 tablets, 1 spoon',
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down, size: 32),
                    onSelected: (value) {
                      _doseController.text = value;
                      _flutterTts.speak("Selected $value");
                    },
                    itemBuilder: (context) => _commonDoses
                        .map((dose) => PopupMenuItem(
                              value: dose,
                              child: Text(dose, style: const TextStyle(fontSize: 18)),
                            ))
                        .toList(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dose amount';
                  }
                  return null;
                },
                onTap: () => _flutterTts.speak("Enter how much medicine to take"),
              ),

              const SizedBox(height: 24),

              // Time Selection
              Text(
                'Time *',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 32, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Frequency Selection
              Text(
                'Frequency *',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: _frequencies.map((frequency) {
                    final isSelected = _selectedFrequency == frequency;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFrequency = frequency;
                          });
                          _flutterTts.speak("Selected $frequency");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[400] : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            frequency.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveReminder,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, size: 32),
                  label: Text(_isLoading ? 'SAVING...' : 'SAVE REMINDER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 80),
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Test Notification Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _flutterTts.speak("Testing notification in 5 seconds");
                    
                    // Create a test reminder for 5 seconds from now
                    final testTime = DateTime.now().add(const Duration(seconds: 5));
                    final testReminder = Reminder(
                      id: 999, // Test ID
                      medicine: "Test Medicine",
                      dose: "1 tablet",
                      time: "${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}",
                      frequency: "once",
                      language: "en-US",
                      createdAt: DateTime.now(),
                    );
                    
                    await NotificationService.instance.scheduleReminder(testReminder);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification scheduled for 5 seconds'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_active, size: 24),
                  label: const Text('TEST NOTIFICATION'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    side: BorderSide(color: Colors.blue[400]!, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _doseController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
