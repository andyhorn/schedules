import 'package:schedules/schedules.dart';
import 'package:test/test.dart';

void main() {
  test('''running findNextNOccurrences with:
   schedule Type Weekly(
    endDate:DateTime (2024-09-21 00:00:00.000Z),
    frequency 1,
    startDate: DateTime (2024-05-20 00:00:00.000Z),
    weekdays: List (1 item)-> [0]:2
   ),
   n:33
   
   brings to infinite loop''', () {
    Schedule schedule = Weekly(
        endDate: DateTime.parse('2024-09-21 00:00:00.000Z'),
        startDate: DateTime.parse('2024-05-20 00:00:00.000Z'),
        frequency: 1,
        weekdays: [2]);
//last date found is 2024-09-17 then goes to infinite loop because all the other dates are after the end date
//so the function _isWithinBounds at line 32:
//if (endDate != null && date.isLaterDateThan(endDate!)) {
//      return false;
//    }
//always returns false

    
    List<DateTime> listDates = schedule.findNextNOccurrences( 33);
     
  });
}
