import 'package:schedules/schedules.dart';

void main() {
  // Create a schedule for your event
  // e.g. Payday every 2 weeks on Friday, beginning on the first Friday
  // after January 1, 2023
  final schedule = Weekly(
    startDate: DateTime(2023, 01, 01),
    frequency: 2,
    weekdays: [DateTime.friday],
  );

  print(schedule.occursOn(DateTime(2023, 01, 06))); // Friday the 6th

  // Get the next 5 dates for your event
  final dates = schedule.getNextNOccurrences(5);
  print(dates);
}
