class Reminder {
  final int? id;
  final String medicine;
  final String dose;
  final String time; // 24-hour format HH:mm
  final String timezone; // Asia/Kolkata, etc.
  final String repeat; // daily, weekly, once (changed from frequency)
  final String language;
  final String? ttsAudioUrl; // URL to TTS audio file
  final DateTime createdAt;
  final bool isActive;

  Reminder({
    this.id,
    required this.medicine,
    required this.dose,
    required this.time,
    this.timezone = 'Asia/Kolkata',
    required this.repeat, // Updated field name
    required this.language,
    this.ttsAudioUrl,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine': medicine,
      'dose': dose,
      'time': time,
      'timezone': timezone,
      'repeat': repeat, // Updated field name
      'language': language,
      'tts_audio_url': ttsAudioUrl,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      medicine: map['medicine'],
      dose: map['dose'],
      time: map['time'],
      timezone: map['timezone'] ?? 'Asia/Kolkata',
      repeat: map['repeat'] ?? map['frequency'] ?? 'daily', // Handle both old and new field names
      language: map['language'],
      ttsAudioUrl: map['tts_audio_url'],
      createdAt: DateTime.parse(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  String get displayTime {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  String get reminderText {
    return "Time to take $dose of $medicine";
  }
}
