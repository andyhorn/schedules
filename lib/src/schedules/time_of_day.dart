/// Represents a specific time of day (HH:MM:SS.mmm).
///
/// Throws an [ArgumentError] if:
/// - [hour] is not between 0 and 23
/// - [minute] is not between 0 and 59
/// - [second] is not between 0 and 59
/// - [millisecond] is not between 0 and 999
class TimeOfDay {
  final int hour;
  final int minute;
  final int second;
  final int millisecond;

  TimeOfDay({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.millisecond = 0,
  }) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(
        hour,
        'hour',
        'Hour must be between 0 and 23',
      );
    }

    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59',
      );
    }

    if (second < 0 || second > 59) {
      throw ArgumentError.value(
        second,
        'second',
        'Second must be between 0 and 59',
      );
    }

    if (millisecond < 0 || millisecond > 999) {
      throw ArgumentError.value(
        millisecond,
        'millisecond',
        'Millisecond must be between 0 and 999',
      );
    }
  }

  TimeOfDay.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second,
        millisecond = dateTime.millisecond;

  @override
  bool operator ==(Object other) {
    return other is TimeOfDay &&
        hour == other.hour &&
        minute == other.minute &&
        second == other.second &&
        millisecond == other.millisecond;
  }

  @override
  int get hashCode =>
      hour.hashCode ^ minute.hashCode ^ second.hashCode ^ millisecond.hashCode;
}
