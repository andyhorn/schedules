# Schedules

[![pub package](https://img.shields.io/pub/v/schedules.svg)](https://pub.dev/packages/schedules)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A pure-Dart package for generating and managing recurring events.

## Features

- One-time, daily, weekly, monthly, and yearly recurring events with customizable frequencies and days-of-the-month (monthly) or weekdays (weekly)
- Determine if an event occurs on a specific day or generate lists of occurrences
- Math-based algorithms for better performance

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  schedules: ^1.1.0
```

Or install directly:

```bash
dart pub add schedules
```

## Usage

Import the package:

```dart
import 'package:schedules/schedules.dart';
```

### Schedule Types

#### Singular (one-time event)

An event that occurs only once:

```dart
final singular = Singular(
  date: DateTime(2023, 01, 01),
);
```

#### Daily

Repeats every _n_ days:

```dart
// Every other day, beginning on January 1, 2023
final daily = Daily(
  startDate: DateTime(2023, 01, 01),
  frequency: 2,
);
```

#### Weekly

Repeats every _n_ weeks on the specified weekdays:

```dart
// Every other week on Monday and Thursday, 
// beginning on January 1, 2023
final weekly = Weekly(
  startDate: DateTime(2023, 01, 01),
  frequency: 2,
  weekdays: [DateTime.monday, DateTime.thursday],
);
```

#### Monthly

Repeats every _n_ months on the specified days:

```dart
// Every month on the 1st and 15th,
// beginning on January 1, 2023
final monthly = Monthly(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  days: [1, 15],
);
```

#### Yearly

Repeats every _n_ years on the specified date:

```dart
// Every 3 years on January 1st, 
// beginning on January 1, 2023
final yearly = Yearly(
  startDate: DateTime(2023, 01, 01),
  frequency: 3,
);
```

### End Dates

All schedule types (except Singular) support an optional end date:

```dart
// A schedule that runs every Sunday for 3 months
final projectSchedule = Weekly(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  weekdays: [DateTime.sunday],
  endDate: DateTime(2023, 3, 31),
);

// This will only return occurrences within the date range
final occurrences = projectSchedule.getOccurrencesUntil(
  DateTime(2023, 4, 1),
).toList();

// Contains: [2023-01-01, 2023-01-08, 2023-01-15, 2023-01-22, 2023-01-29, 
//           2023-02-05, 2023-02-12, 2023-02-19, 2023-02-26, 2023-03-05, 
//           2023-03-12, 2023-03-19, 2023-03-26]
```

### Excluding Dates

Skip specific dates when generating occurrences:

```dart
final workSchedule = Weekly(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  weekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
);

// Exclude holidays and vacation days
final excludedDates = [
  DateTime(2023, 1, 2), // New Year's Day (observed)
  DateTime(2023, 1, 16), // MLK Day
];

// Get work days for the next 2 weeks, excluding holidays
final workDays = workSchedule.getNextNOccurrences(
  6, 
  exclude: excludedDates,
).toList();

// Contains: [2023-01-04 (Wed), 2023-01-06 (Fri), 2023-01-09 (Mon), 
//           2023-01-11 (Wed), 2023-01-13 (Fri)]
```

### Date Ranges

Get all occurrences within a specific date range:

```dart
final billSchedule = Monthly(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  days: [1, 15], // 1st and 15th of each month
);

// Get bill due dates for Q1 2023
final q1Bills = billSchedule.getOccurrencesUntil(
  DateTime(2023, 4, 1),
  from: DateTime(2023, 1, 1),
).toList();

// Contains: [2023-01-01, 2023-01-15, 2023-02-01, 2023-02-15, 2023-03-01, 2023-03-15]

// Get bill dates for just February
final febBills = billSchedule.getOccurrencesUntil(
  DateTime(2023, 3, 1),
  from: DateTime(2023, 2, 1),
).toList();

// Contains: [2023-02-01, 2023-02-15]
```

## API

All schedule types provide these methods:

- `occursOn(DateTime date)` - Check if the schedule occurs on a specific date
- `getNextNOccurrences(int n, {DateTime? from, Iterable<DateTime>? exclude})` - Get the next N occurrences
- `getOccurrencesUntil(DateTime end, {DateTime? from, Iterable<DateTime>? exclude})` - Get all occurrences until a specific date

## Concrete Examples

### Payday Schedule
```dart
// Bi-weekly paydays on Fridays, starting January 6, 2023
final payday = Weekly(
  startDate: DateTime(2023, 1, 6), // First Friday
  frequency: 2, // Every 2 weeks
  weekdays: [DateTime.friday],
);

// Check if today is payday
final today = DateTime.now();
if (payday.occursOn(today)) {
  print('It\'s payday!');
}

// Get paydays for the next 3 months
final nextPaydays = payday.getOccurrencesUntil(
  DateTime(2023, 4, 1),
  from: DateTime(2023, 1, 1),
).toList();

// Contains: [2023-01-06, 2023-01-20, 2023-02-03, 2023-02-17, 2023-03-03, 2023-03-17]
```

### Medication Reminder
```dart
// Take medication daily
final medication = Daily(
  startDate: DateTime(2023, 1, 1),
  frequency: 1, // Daily
);

// Check if it's medication day
final today = DateTime.now();
if (medication.occursOn(today)) {
  print('Take your medication today');
}

// Get next 3 medication days
final nextDoses = medication.getNextNOccurrences(3);
// Output: [2023-01-01, 2023-01-02, 2023-01-03]
```

### Bill Due Dates
```dart
// Rent due on the 1st, utilities on the 15th
final rent = Monthly(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  days: [1],
);

final utilities = Monthly(
  startDate: DateTime(2023, 1, 15),
  frequency: 1,
  days: [15],
);

// Check if any bills are due today
final today = DateTime.now();

// Get bill due dates for Q1 2023
final q1Bills = [
  ...rent.getOccurrencesUntil(DateTime(2023, 4, 1), from: DateTime(2023, 1, 1)),
  ...utilities.getOccurrencesUntil(DateTime(2023, 4, 1), from: DateTime(2023, 1, 1)),
].toList()..sort();

// Contains: [2023-01-01 (rent), 2023-01-15 (utilities), 2023-02-01 (rent), 
//           2023-02-15 (utilities), 2023-03-01 (rent), 2023-03-15 (utilities)]
```

### Work Schedule with Holidays
```dart
// Work Monday-Friday
final workDays = Weekly(
  startDate: DateTime(2023, 1, 2), // First Monday
  frequency: 1,
  weekdays: [
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  ],
);

// Define holidays
final holidays = [
  DateTime(2023, 1, 2), // New Year's Day (observed)
  DateTime(2023, 1, 16), // MLK Day
];

// Check if today is a work day (excluding holidays)
final today = DateTime.now();
final isWorkDay = workDays.occursOn(today) && !holidays.any(today.isSameDateAs);

if (isWorkDay) {
  print('Today is a work day');
} else {
  print('Today is not a work day');
}

// Get work days for first 2 weeks of January, excluding holidays
final workDaysJan = workDays.getOccurrencesUntil(
  DateTime(2023, 1, 15),
  from: DateTime(2023, 1, 1),
  exclude: holidays,
).toList();

// Contains: [2023-01-03 (Tue), 2023-01-04 (Wed), 2023-01-05 (Thu), 2023-01-06 (Fri),
//           2023-01-09 (Mon), 2023-01-10 (Tue), 2023-01-11 (Wed), 2023-01-12 (Thu)]
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
