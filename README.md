# Schedules

[![pub package](https://img.shields.io/pub/v/schedules.svg)](https://pub.dev/packages/schedules)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A pure-Dart package for generating and managing recurring events.

## Features
- Determine if an event occurs on a specific day
- Generate a list of _n_ events
- Generate a list of events until _x_ date
- Schedule events at specific times of day with `TimeOfDay` class
- Math-based algorithms for better performance

**Schedule Types**
  - One-time: An event that occurs only once
  - Daily: An event that occurs every _n_ days
  - Weekly: An event that occurs on one or more weekdays every _n_ weeks
  - Monthly: An event that occurs on one or more days every _n_ months
  - MonthlyWeekday: An event that occurs on the _x_th_ weekday every _n_ months
  - Yearly: An event that occurs on a particular date every _n_ years

## Time Support

The schedules package supports scheduling events at specific times of day using the `TimeOfDay` class and timed schedule constructors.

### TimeOfDay Class

The `TimeOfDay` class represents a specific time of day with hour, minute, second, and millisecond precision:

```dart
// Create a TimeOfDay for 9:30 AM
final morningTime = TimeOfDay(hour: 9, minute: 30);

// Create a TimeOfDay for 2:15:30 PM with milliseconds
final afternoonTime = TimeOfDay(
  hour: 14, 
  minute: 15, 
  second: 30, 
  millisecond: 500,
);

// Create from an existing DateTime
final now = DateTime.now();
final currentTime = TimeOfDay.fromDateTime(now);

// Or use the `toTimeOfDay` extension
final currentTime = DateTime.now().toTimeOfDay();
```

**TimeOfDay Validation:**
- Hour: 0-23 (24-hour format)
- Minute: 0-59
- Second: 0-59 (default: 0)
- Millisecond: 0-999 (default: 0)

### Timed Schedules

All schedule types support timed scheduling using `.timed()` constructors. Timed schedules can have multiple times per day (excluding Singular, which only supports 0 or 1):

```dart
// Daily medication at 8 AM, 2 PM, and 8 PM
final medication = Daily.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  timesOfDay: [
    TimeOfDay(hour: 8, minute: 0),   // 8:00 AM
    TimeOfDay(hour: 14, minute: 0),  // 2:00 PM
    TimeOfDay(hour: 20, minute: 0),  // 8:00 PM
  ],
);

// Weekly team meetings on Monday and Wednesday at 10:30 AM
final meetings = Weekly.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  weekdays: [DateTime.monday, DateTime.wednesday],
  timesOfDay: [TimeOfDay(hour: 10, minute: 30)],
);

// Monthly board meeting on the 1st at 3:00 PM
final boardMeeting = Monthly.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  days: [1],
  timesOfDay: [TimeOfDay(hour: 15, minute: 0)],
);
```

### Time-Related API Methods

Timed schedules provide additional methods for time-specific operations:

```dart
final schedule = Daily.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
);

// Check if schedule is timed
print(schedule.isTimed); // true

// Check if schedule occurs at a specific time
print(schedule.occursAt(TimeOfDay(hour: 9, minute: 30))); // true
print(schedule.occursAt(TimeOfDay(hour: 10, minute: 0)));  // false

// Get timed occurrences (returns DateTime instances with specific times)
final occurrences = schedule.getNextNOccurrences(3).toList();
// Returns: [2023-01-01 09:30:00, 2023-01-02 09:30:00, 2023-01-03 09:30:00]
```

**Important Note about `occursAt` Behavior:**

- **Timed schedules**: `occursAt(TimeOfDay)` returns `true` only for the specific times configured in the schedule
- **UnTimed schedules**: `occursAt(TimeOfDay)` returns `true` for any time of day, as these represent "all-day" events

```dart
// UnTimed schedule (all-day event)
final allDayEvent = Daily(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
);

print(allDayEvent.isTimed); // false
print(allDayEvent.occursAt(TimeOfDay(hour: 8, minute: 0)));  // true
print(allDayEvent.occursAt(TimeOfDay(hour: 12, minute: 30))); // true
print(allDayEvent.occursAt(TimeOfDay(hour: 23, minute: 59))); // true

// Timed schedule (specific times)
final timedEvent = Daily.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
);

print(timedEvent.isTimed); // true
print(timedEvent.occursAt(TimeOfDay(hour: 8, minute: 0)));  // false
print(timedEvent.occursAt(TimeOfDay(hour: 9, minute: 0)));  // true
print(timedEvent.occursAt(TimeOfDay(hour: 12, minute: 30))); // false
```

### DateTime Extensions

The package provides helpful extensions for working with times:

```dart
final date = DateTime(2023, 6, 15);

// Convert DateTime to TimeOfDay
final timeOfDay = date.toTimeOfDay();

// Create DateTime with specific time
final specificTime = date.withTimeOfDay(TimeOfDay(hour: 14, minute: 30));
// Returns: 2023-06-15 14:30:00
```

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

// Daily medication at 8 AM, 2 PM, and 8 PM
final medication = Daily.timed(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  timesOfDay: [
    TimeOfDay(hour: 8, minute: 0),   // 8:00 AM
    TimeOfDay(hour: 14, minute: 0),  // 2:00 PM
    TimeOfDay(hour: 20, minute: 0),  // 8:00 PM
  ],
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

// Weekly team meetings on Monday and Wednesday at 10:30 AM
final meetings = Weekly.timed(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  weekdays: [DateTime.monday, DateTime.wednesday],
  timesOfDay: [TimeOfDay(hour: 10, minute: 30)],
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

// Monthly board meeting on the 1st at 3:00 PM
final boardMeeting = Monthly.timed(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  days: [1],
  timesOfDay: [TimeOfDay(hour: 15, minute: 0)],
);
```

#### MonthlyWeekday

Repeats every _n_ months on a specific weekday of a specific week:

```dart
// First Monday of every month,
// beginning on January 1, 2023
final firstMonday = MonthlyWeekday(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  weekday: DateTime.monday,
  weekOfMonth: 1, // First occurrence
);

// Last Friday of every other month
final lastFriday = MonthlyWeekday(
  startDate: DateTime(2023, 01, 01),
  frequency: 2,
  weekday: DateTime.friday,
  weekOfMonth: -1, // Last occurrence
);

// Third Thursday of every month
final thirdThursday = MonthlyWeekday(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  weekday: DateTime.thursday,
  weekOfMonth: 3,
);

// First Monday of every month at 9:00 AM
final firstMondayMeeting = MonthlyWeekday.timed(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  weekday: DateTime.monday,
  weekOfMonth: 1,
  timesOfDay: [TimeOfDay(hour: 9, minute: 0)],
);
```

**Parameters:**
- `weekday`: The day of the week (1=Monday, 7=Sunday)
- `weekOfMonth`: Which occurrence of the weekday (1-5, or -1 for last)
- `frequency`: How often in months (1=every month, 2=every other month, etc.)

**Week of Month Values:**
- `1` = First occurrence (e.g., first Monday)
- `2` = Second occurrence (e.g., second Friday)  
- `3` = Third occurrence (e.g., third Tuesday)
- `4` = Fourth occurrence (e.g., fourth Wednesday)
- `5` = Fifth occurrence (e.g., fifth Thursday) - only exists in some months
- `-1` = Last occurrence (e.g., last Friday) - finds the last occurrence, regardless of count

#### Yearly

Repeats every _n_ years on the specified date:

```dart
// Every 3 years on January 1st, 
// beginning on January 1, 2023
final yearly = Yearly(
  startDate: DateTime(2023, 01, 01),
  frequency: 3,
);

// Annual company meeting on January 1st at 2:00 PM
final annualMeeting = Yearly.timed(
  startDate: DateTime(2023, 01, 01),
  frequency: 1,
  timesOfDay: [TimeOfDay(hour: 14, minute: 0)],
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

**Timed Schedule Methods:**
- `isTimed` - Check if the schedule has specific times
- `occursAt(TimeOfDay timeOfDay)` - Check if the schedule occurs at a specific time of day
- For **Timed schedules**: Returns `true` only for configured times
- For **UnTimed schedules**: Returns `true` for any time (all-day events)

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

### Timed Medication Schedule
```dart
// Take medication 3 times daily at specific times
final timedMedication = Daily.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  timesOfDay: [
    TimeOfDay(hour: 8, minute: 0),   // 8:00 AM
    TimeOfDay(hour: 14, minute: 0),  // 2:00 PM
    TimeOfDay(hour: 20, minute: 0),  // 8:00 PM
  ],
);

// Check if it's time for medication
final now = DateTime.now();
if (timedMedication.occursOn(now) && 
    timedMedication.occursAt(now.toTimeOfDay())) {
  print('Time to take your medication!');
}

// Get next 6 medication times
final nextDoses = timedMedication.getNextNOccurrences(6).toList();
// Output: [2023-01-01 08:00:00, 2023-01-01 14:00:00, 2023-01-01 20:00:00,
//          2023-01-02 08:00:00, 2023-01-02 14:00:00, 2023-01-02 20:00:00]
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

### Board Meeting Schedule
```dart
// Board meetings on the first Monday of every month
final boardMeeting = MonthlyWeekday(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  weekday: DateTime.monday,
  weekOfMonth: 1, // First Monday
);

// Team retrospectives on the last Friday of every other month
final retrospective = MonthlyWeekday(
  startDate: DateTime(2023, 1, 1),
  frequency: 2, // Every 2 months
  weekday: DateTime.friday,
  weekOfMonth: -1, // Last Friday
);

// Check if today is a meeting day
final today = DateTime.now();
if (boardMeeting.occursOn(today)) {
  print('Board meeting today!');
}

// Get next 6 board meetings
final nextMeetings = boardMeeting.getNextNOccurrences(6).toList();
// Contains: [2023-01-02, 2023-02-06, 2023-03-06, 2023-04-03, 2023-05-01, 2023-06-05]

// Get retrospectives for the year
final yearRetrospectives = retrospective.getOccurrencesUntil(
  DateTime(2024, 1, 1),
  from: DateTime(2023, 1, 1),
).toList();
// Contains: [2023-01-27, 2023-03-31, 2023-05-26, 2023-07-28, 2023-09-29, 2023-11-24]
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

### All-Day vs Timed Events
```dart
// All-day event (birthday, holiday, deadline)
final birthday = Daily(
  startDate: DateTime(2023, 1, 1),
  frequency: 365, // Every year
);

// Check if it's time for birthday celebration
final now = DateTime.now();
if (birthday.occursOn(now)) {
  // This will be true for any time during the birthday
  if (birthday.occursAt(now.toTimeOfDay())) {
    print('Happy Birthday! 🎉');
  }
}

// Timed event (meeting, appointment)
final meeting = Daily.timed(
  startDate: DateTime(2023, 1, 1),
  frequency: 1,
  timesOfDay: [TimeOfDay(hour: 14, minute: 0)], // 2:00 PM
);

// Check if it's meeting time
if (meeting.occursOn(now) && meeting.occursAt(now.toTimeOfDay())) {
  print('Time for the meeting!');
} else if (meeting.occursOn(now)) {
  print('Meeting day, but not meeting time yet');
}
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
