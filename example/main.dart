import 'package:schedules/schedules.dart';

void main() {
  // Basic usage examples

  // 1. One-time event
  final birthday = Singular(date: DateTime(2024, 6, 15));
  print(
    'Birthday occurs on June 15, 2024: ${birthday.occursOn(DateTime(2024, 6, 15))}',
  );

  // 2. Daily workout every other day
  final workout = Daily(
    startDate: DateTime(2024, 1, 1),
    frequency: 2, // Every 2 days
  );
  print('Next 5 workout days:');
  for (final date in workout.getNextNOccurrences(5)) {
    print('  - ${date.toString().split(' ')[0]}');
  }

  // 3. Weekly team meetings
  final meetings = Weekly(
    startDate: DateTime(2024, 1, 1),
    frequency: 1,
    weekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
  );
  print('\nNext 6 meetings:');
  for (final date in meetings.getNextNOccurrences(6)) {
    print('  - ${date.toString().split(' ')[0]}');
  }

  // 4. Monthly rent payment
  final rent = Monthly(
    startDate: DateTime(2024, 1, 1),
    frequency: 1,
    days: [1], // 1st of each month
  );
  print('\nNext 6 rent due dates:');
  for (final date in rent.getNextNOccurrences(6)) {
    print('  - ${date.toString().split(' ')[0]}');
  }

  // 5. Bi-weekly payroll
  final payroll = Weekly(
    startDate: DateTime(2024, 1, 5), // First Friday
    frequency: 2, // Every 2 weeks
    weekdays: [DateTime.friday],
  );
  print('\nQ1 2024 payroll dates:');
  final q1Payroll = payroll.getOccurrencesUntil(
    DateTime(2024, 4, 1),
    from: DateTime(2024, 1, 1),
  );
  for (final date in q1Payroll) {
    print('  - ${date.toString().split(' ')[0]}');
  }

  // 6. Work schedule with holidays
  final workDays = Weekly(
    startDate: DateTime(2024, 1, 1),
    frequency: 1,
    weekdays: [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ],
  );

  final holidays = [
    DateTime(2024, 1, 1), // New Year's Day
    DateTime(2024, 1, 15), // MLK Day
  ];

  print('\nWork days in January (excluding holidays):');
  final janWorkDays = workDays.getOccurrencesUntil(
    DateTime(2024, 2, 1),
    from: DateTime(2024, 1, 1),
    exclude: holidays,
  );
  for (final date in janWorkDays) {
    print('  - ${date.toString().split(' ')[0]}');
  }

  // 7. Check if today is a work day
  final today = DateTime.now();
  print(
    '\nToday (${today.toString().split(' ')[0]}) is a work day: ${workDays.occursOn(today)}',
  );

  // 8. Get next occurrence
  final nextWorkDay = workDays.getNextNOccurrences(1, from: today).first;
  print('Next work day: ${nextWorkDay.toString().split(' ')[0]}');
}
