import 'package:intl/intl.dart';

//purpose: Class to get the current date, month, year and time
//author: Maurice
//Date: 16.05.2024

class Calendar {
  int getCurrentDay() {
    DateTime now = DateTime.now();
    return now.day;
  }

  String getCurrentMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMMM').format(now);
  }

  int getCurrentYear() {
    DateTime now = DateTime.now();
    return now.year;
  }

  String getCurrentTime() {
    DateTime now = DateTime.now();
    return DateFormat('HH:mm').format(now);
  }
}
