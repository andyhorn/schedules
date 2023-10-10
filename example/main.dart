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

  // Get the next 5 dates for your event
  final dates = findNextNOccurrences(schedule, 5);
  print(dates);
}

List<DateTime> findNextNOccurrences(Schedule schedule, int n) {
  final dates = <DateTime>[];
  var currentDate = DateTime.now();

  while (dates.length < n) {
    // Here is the magic: Check if our Schedule occurs on the given date
    // using the "occursOn" method.
    //
    // If the current date fits the Schedule's pattern, add it to our list.
    if (schedule.occursOn(currentDate)) {
      dates.add(currentDate);
    }

    currentDate = currentDate.add(const Duration(days: 1));
  }

  return dates;
}
