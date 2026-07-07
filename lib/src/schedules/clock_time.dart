import 'package:meta/meta.dart';

/// Represents a specific time of day (HH:MM:SS.mmm).
///
/// Throws an [ArgumentError] if:
/// - [hour] is not between 0 and 23
/// - [minute] is not between 0 and 59
/// - [second] is not between 0 and 59
/// - [millisecond] is not between 0 and 999
@immutable
class ClockTime {
  /// Creates a time of day from its component parts.
  ClockTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.millisecond = 0,
  }) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(
        hour,
        'hour',
        'Hour must be between 0 and 23, inclusive',
      );
    }

    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59, inclusive',
      );
    }

    if (second < 0 || second > 59) {
      throw ArgumentError.value(
        second,
        'second',
        'Second must be between 0 and 59, inclusive',
      );
    }

    if (millisecond < 0 || millisecond > 999) {
      throw ArgumentError.value(
        millisecond,
        'millisecond',
        'Millisecond must be between 0 and 999, inclusive',
      );
    }
  }

  /// Creates a time of day from the time component of the given [dateTime].
  ClockTime.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second,
        millisecond = dateTime.millisecond;

  /// The hour of the day, between 0 and 23.
  final int hour;

  /// The minute of the hour, between 0 and 59.
  final int minute;

  /// The second of the minute, between 0 and 59.
  final int second;

  /// The millisecond of the second, between 0 and 999.
  final int millisecond;

  @override
  bool operator ==(Object other) {
    return other is ClockTime &&
        hour == other.hour &&
        minute == other.minute &&
        second == other.second &&
        millisecond == other.millisecond;
  }

  @override
  int get hashCode => Object.hash(hour, minute, second, millisecond);

  @override
  String toString() {
    String pad(int value, [int width = 2]) =>
        value.toString().padLeft(width, '0');

    return 'ClockTime('
        '${pad(hour)}:${pad(minute)}:${pad(second)}.${pad(millisecond, 3)}'
        ')';
  }
}

/// Conversions between [DateTime] and [ClockTime].
extension ClockTimeDateTimeExtensions on DateTime {
  /// Returns a new [ClockTime] representing the time of day for this date.
  ClockTime toClockTime() => ClockTime.fromDateTime(this);

  /// Returns a new [DateTime] with the same year, month, and day as this
  /// date, but with the given [clockTime].
  DateTime withClockTime(ClockTime clockTime) => DateTime(
        year,
        month,
        day,
        clockTime.hour,
        clockTime.minute,
        clockTime.second,
        clockTime.millisecond,
      );
}
