import 'package:schedules/src/extensions.dart';

sealed class Schedule {
  const Schedule({
    required this.startDate,
    this.endDate,
  });

  final DateTime startDate;
  final DateTime? endDate;

  bool occursOn(DateTime date);

  bool _isWithinBounds(DateTime date) {
    if (date.isEarlierDateThan(startDate)) {
      return false;
    }

    if (endDate != null && date.isLaterDateThan(endDate!)) {
      return false;
    }

    return true;
  }
}

class Singular extends Schedule {
  const Singular({
    required super.startDate,
  });

  @override
  bool occursOn(DateTime date) => startDate.isSameDateAs(date);
}

class Daily extends Schedule {
  const Daily({
    required super.startDate,
    super.endDate,
    required this.frequency,
  });

  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date)) {
      return false;
    }

    final difference = startDate.difference(date).inDays;
    return difference % frequency == 0;
  }
}

class Weekly extends Schedule {
  const Weekly({
    required super.startDate,
    super.endDate,
    required this.frequency,
    required this.weekdays,
  });

  final int frequency;
  final List<int> weekdays;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date) || !weekdays.contains(date.weekday)) {
      return false;
    }

    final difference = startDate.difference(date).inDays.abs();
    final numWeeks = difference ~/ 7;
    return numWeeks % frequency == 0;
  }
}

class Monthly extends Schedule {
  const Monthly({
    required super.startDate,
    super.endDate,
    required this.days,
    required this.frequency,
  });

  final List<int> days;
  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date) || !days.contains(date.day)) {
      return false;
    }

    final difference = startDate.getMonthsApartFrom(date);
    return difference % frequency == 0;
  }
}

class Yearly extends Schedule {
  const Yearly({
    required super.startDate,
    super.endDate,
    required this.frequency,
  });

  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date)) {
      return false;
    }

    if (date.day != startDate.day || date.month != startDate.month) {
      return false;
    }

    return (startDate.year - date.year).abs() % frequency == 0;
  }
}
