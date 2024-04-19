import 'package:flutter/material.dart';

class DateUtil {
  static String getFormattedTimeString(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final sentAt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();
    if (now.day == sentAt.day &&
        now.month == sentAt.month &&
        now.year == sentAt.year) {
      return TimeOfDay.fromDateTime(sentAt).format(context);
    }
    return '${sentAt.day} ${_monthString(sentAt.month)}';
  }

  static String _monthString(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return 'N/A';
    }
  }
}
