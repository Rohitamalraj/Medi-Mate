import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (skip database init on web since SQLite is not supported)
  if (!kIsWeb) {
    await DatabaseService.instance.database;
    await NotificationService.instance.init();
  }
  
  // Request permissions (skip on web as they're handled differently)
  if (!kIsWeb) {
    await Permission.microphone.request();
    await Permission.notification.request();
  }
  
  runApp(const SeniorMedicineApp());
}

class SeniorMedicineApp extends StatelessWidget {
  const SeniorMedicineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          // Large fonts for seniors
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 22),
          bodyMedium: TextStyle(fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(200, 80), // Large buttons for seniors
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.all(20),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
