import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/reminder.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (kIsWeb) {
      // For web, we'll use SharedPreferences instead of SQLite
      throw UnimplementedError('SQLite not supported on web, using SharedPreferences');
    }
    
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine TEXT NOT NULL,
        dose TEXT NOT NULL,
        time TEXT NOT NULL,
        frequency TEXT NOT NULL,
        language TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<int> insertReminder(Reminder reminder) async {
    if (kIsWeb) {
      return await _insertReminderWeb(reminder);
    }
    
    final db = await instance.database;
    return await db.insert('reminders', reminder.toMap());
  }

  Future<List<Reminder>> getAllReminders() async {
    if (kIsWeb) {
      return await _getAllRemindersWeb();
    }
    
    final db = await instance.database;
    final result = await db.query(
      'reminders',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'time ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getTodayReminders() async {
    if (kIsWeb) {
      final allReminders = await _getAllRemindersWeb();
      return allReminders.where((r) => 
        r.frequency == 'daily' || r.frequency == 'once').toList();
    }
    
    final db = await instance.database;
    final result = await db.query(
      'reminders',
      where: 'is_active = ? AND (frequency = ? OR frequency = ?)',
      whereArgs: [1, 'daily', 'once'],
      orderBy: 'time ASC',
    );
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> updateReminder(Reminder reminder) async {
    if (kIsWeb) {
      return await _updateReminderWeb(reminder);
    }
    
    final db = await instance.database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    if (kIsWeb) {
      return await _deleteReminderWeb(id);
    }
    
    final db = await instance.database;
    return await db.update(
      'reminders',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Web-specific implementations using SharedPreferences
  Future<int> _insertReminderWeb(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await _getAllRemindersWeb();
    
    // Generate a new ID
    final newId = DateTime.now().millisecondsSinceEpoch;
    final reminderWithId = Reminder(
      id: newId,
      medicine: reminder.medicine,
      dose: reminder.dose,
      time: reminder.time,
      frequency: reminder.frequency,
      language: reminder.language,
      createdAt: reminder.createdAt,
      isActive: reminder.isActive,
    );
    
    reminders.add(reminderWithId);
    await _saveRemindersWeb(reminders);
    return newId;
  }

  Future<List<Reminder>> _getAllRemindersWeb() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderStrings = prefs.getStringList('reminders') ?? [];
    
    return reminderStrings
        .map((str) => Reminder.fromMap(json.decode(str)))
        .where((reminder) => reminder.isActive)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  Future<void> _saveRemindersWeb(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final reminderStrings = reminders
        .map((reminder) => json.encode(reminder.toMap()))
        .toList();
    
    await prefs.setStringList('reminders', reminderStrings);
  }

  Future<int> _updateReminderWeb(Reminder reminder) async {
    final reminders = await _getAllRemindersWeb();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    
    if (index != -1) {
      reminders[index] = reminder;
      await _saveRemindersWeb(reminders);
      return 1;
    }
    return 0;
  }

  Future<int> _deleteReminderWeb(int id) async {
    final reminders = await _getAllRemindersWeb();
    final index = reminders.indexWhere((r) => r.id == id);
    
    if (index != -1) {
      reminders[index] = Reminder(
        id: reminders[index].id,
        medicine: reminders[index].medicine,
        dose: reminders[index].dose,
        time: reminders[index].time,
        frequency: reminders[index].frequency,
        language: reminders[index].language,
        createdAt: reminders[index].createdAt,
        isActive: false,
      );
      await _saveRemindersWeb(reminders);
      return 1;
    }
    return 0;
  }

  Future close() async {
    if (!kIsWeb && _database != null) {
      await _database!.close();
    }
  }
}
