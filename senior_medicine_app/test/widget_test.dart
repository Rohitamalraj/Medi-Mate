import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_medicine_app/main.dart';

void main() {
  group('Senior Medicine App Widget Tests', () {
    testWidgets('Home screen displays main buttons', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const SeniorMedicineApp());

      // Verify that the main buttons are present
      expect(find.text('SPEAK'), findsOneWidget);
      expect(find.text('READ NEWS'), findsOneWidget);
      expect(find.text('MY REMINDERS'), findsOneWidget);
      expect(find.text('ADD MANUALLY'), findsOneWidget);
    });

    testWidgets('Navigation to manual reminder screen works', (WidgetTester tester) async {
      await tester.pumpWidget(const SeniorMedicineApp());

      // Tap the manual add button
      await tester.tap(find.text('ADD MANUALLY'));
      await tester.pumpAndSettle();

      // Verify we're on the manual reminder screen
      expect(find.text('Add Reminder Manually'), findsOneWidget);
      expect(find.text('Medicine Name *'), findsOneWidget);
      expect(find.text('Dose *'), findsOneWidget);
    });

    testWidgets('Manual reminder form validation works', (WidgetTester tester) async {
      await tester.pumpWidget(const SeniorMedicineApp());

      // Navigate to manual reminder screen
      await tester.tap(find.text('ADD MANUALLY'));
      await tester.pumpAndSettle();

      // Try to save without filling required fields
      await tester.tap(find.text('SAVE REMINDER'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter medicine name'), findsOneWidget);
      expect(find.text('Please enter dose amount'), findsOneWidget);
    });

    testWidgets('Reminder list shows empty state initially', (WidgetTester tester) async {
      await tester.pumpWidget(const SeniorMedicineApp());

      // Navigate to reminders list
      await tester.tap(find.text('MY REMINDERS'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No Reminders Yet'), findsOneWidget);
      expect(find.text('ADD REMINDER'), findsOneWidget);
    });
  });

  group('Database Service Tests', () {
    // Note: These would require proper database mocking in a real test environment
    test('Reminder model serialization works', () {
      final reminder = Reminder(
        medicine: 'Test Medicine',
        dose: '1 tablet',
        time: '09:00',
        frequency: 'daily',
        language: 'en-US',
        createdAt: DateTime.now(),
      );

      final map = reminder.toMap();
      expect(map['medicine'], 'Test Medicine');
      expect(map['dose'], '1 tablet');
      expect(map['time'], '09:00');
      expect(map['frequency'], 'daily');

      final reminderFromMap = Reminder.fromMap(map);
      expect(reminderFromMap.medicine, reminder.medicine);
      expect(reminderFromMap.dose, reminder.dose);
    });

    test('Time display format works correctly', () {
      final reminder = Reminder(
        medicine: 'Test',
        dose: '1 tablet',
        time: '21:30',
        frequency: 'daily',
        language: 'en-US',
        createdAt: DateTime.now(),
      );

      expect(reminder.displayTime, '9:30 PM');
    });
  });
}
