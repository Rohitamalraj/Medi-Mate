import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  /// Convert 24-hour time format to 12-hour display format
  static String formatTime12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Convert TimeOfDay to 24-hour string format
  static String timeOfDayTo24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Parse 24-hour time string to TimeOfDay
  static TimeOfDay timeStringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Get language code for API calls
  static String getLanguageCode(String displayLanguage) {
    switch (displayLanguage) {
      case 'ta-IN':
        return 'ta-IN';
      case 'hi-IN':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }

  /// Get short language code (for backend)
  static String getShortLanguageCode(String fullLanguageCode) {
    return fullLanguageCode.split('-')[0];
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  /// Calculate next reminder time based on frequency
  static DateTime getNextReminderTime(String time24, String frequency) {
    final now = DateTime.now();
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    DateTime nextReminder = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow (or next occurrence)
    if (nextReminder.isBefore(now)) {
      switch (frequency.toLowerCase()) {
        case 'daily':
          nextReminder = nextReminder.add(const Duration(days: 1));
          break;
        case 'weekly':
          nextReminder = nextReminder.add(const Duration(days: 7));
          break;
        case 'once':
          nextReminder = nextReminder.add(const Duration(days: 1));
          break;
        default:
          nextReminder = nextReminder.add(const Duration(days: 1));
      }
    }

    return nextReminder;
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Validate medicine name
  static String? validateMedicineName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter medicine name';
    }
    if (value.trim().length < 2) {
      return 'Medicine name too short';
    }
    return null;
  }

  /// Validate dose
  static String? validateDose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter dose amount';
    }
    if (value.trim().length < 2) {
      return 'Dose description too short';
    }
    return null;
  }

  /// Get reminder text for TTS
  static String getReminderText(String medicine, String dose, String time, String language) {
    final timeFormatted = formatTime12Hour(time);
    
    switch (language) {
      case 'ta-IN':
        return '$timeFormatted - $medicine $dose எடுத்துக் கொள்ளுங்கள்';
      case 'hi-IN':
        return '$timeFormatted - $medicine की $dose लें';
      default:
        return 'Time to take $dose of $medicine at $timeFormatted';
    }
  }

  /// Get confirmation text for TTS
  static String getConfirmationText(String medicine, String dose, String time, String frequency, String language) {
    final timeFormatted = formatTime12Hour(time);
    
    switch (language) {
      case 'ta-IN':
        return '$medicine $dose $timeFormatted $frequency - இந்த நினைவூட்டலை சேர்க்கவா?';
      case 'hi-IN':
        return '$medicine $dose $timeFormatted $frequency - यह रिमाइंडर जोड़ें?';
      default:
        return 'Add reminder: $medicine $dose at $timeFormatted $frequency. Confirm?';
    }
  }

  /// Check if time is in the past
  static bool isTimeInPast(String time24) {
    final now = DateTime.now();
    final timeParts = time24.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
    return reminderTime.isBefore(now);
  }

  /// Get time until next reminder
  static String getTimeUntilReminder(String time24, String frequency) {
    final nextTime = getNextReminderTime(time24, frequency);
    final now = DateTime.now();
    final difference = nextTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Soon';
    }
  }
}
