import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DateUtil {
  static String getFormattedTimeString(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime({
    required BuildContext context,
    required String time,
    bool showYear = false,
  }) {
    final sentAt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();
    if (now.day == sentAt.day &&
        now.month == sentAt.month &&
        now.year == sentAt.year) {
      return TimeOfDay.fromDateTime(sentAt).format(context);
    }
    return showYear
        ? '${sentAt.day} ${_monthString(sentAt.month)} ${sentAt.year}'
        : '${sentAt.day} ${_monthString(sentAt.month)}';
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

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    if (i == -1) return 'Last seen not available';
    final time = DateTime.fromMillisecondsSinceEpoch(i);
    final now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at $formattedTime';
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }
    final month = _monthString(time.month);
    return 'Last seen on ${time.day} $month at $formattedTime';
  }

  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final sentAt = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final now = DateTime.now();
    final formattedTime = TimeOfDay.fromDateTime(sentAt).format(context);
    if (now.day == sentAt.day &&
        now.month == sentAt.month &&
        now.year == sentAt.year) {
      return formattedTime;
    }
    return now.year != sentAt.year
        ? '$formattedTime - ${sentAt.day} ${_monthString(sentAt.month)} ${sentAt.year}'
        : '$formattedTime - ${sentAt.day} ${_monthString(sentAt.month)}';
  }
}
