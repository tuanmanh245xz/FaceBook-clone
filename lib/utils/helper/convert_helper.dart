

import 'package:intl/intl.dart';

class ConvertHelper {
  static String covertDateTimeToStringShow(DateTime dateTime){
    Duration timeAgo = DateTime.now().toLocal().difference(dateTime.toLocal());
    int inMinute = timeAgo.inMinutes;
    int day = inMinute ~/ (60 * 24);
    int hour = (inMinute - day * 24 * 60) ~/ 60;
    int minute = inMinute - day * 24 * 60 - hour * 60;
    if (day > 6){
      String strTime = "";
      strTime += "Ngày " + dateTime.day.toString();
      strTime += " tháng " + dateTime.month.toString();
      if (dateTime.year != DateTime.now().year){
        strTime += " năm " + dateTime.year.toString();
      }
      strTime += " lúc " + (dateTime.hour < 10 ? "0" + dateTime.hour.toString() : dateTime.hour.toString()) + ":" + (dateTime.minute < 10 ? "0" + dateTime.minute.toString() : dateTime.minute.toString());
      return strTime;
    } else {
      if (day != 0){
        return day.toString() + " ngày";
      } else if (hour != 0){
        return hour.toString() + " giờ";
      } else if (minute >= 1){
        return minute.toString() + " phút";
      } else {
        return "Vừa xong";
      }
    }
  }

  static String convertDateTimeToStringComment(DateTime dateTime){
    Duration timeAgo = DateTime.now().toLocal().difference(dateTime.toLocal());
    int inMinute = timeAgo.inMinutes;
    int day = inMinute ~/ (60 * 24);
    int hour = (inMinute - day * 24 * 60) ~/ 60;
    int minute = inMinute - day * 24 * 60 - hour * 60;
    if (day > 0){
      return day.toString() + " ngày";
    } else if (hour > 0){
      return hour.toString() + " giờ";
    } else if (minute > 1){
      return minute.toString() + " phút";
    } else {
      return "Vừa xong";
    }
  }

  static String convertDateTimeToStringChat(DateTime dateTime){
    Duration timeAgo = DateTime.now().toLocal().difference(dateTime.toLocal());
    int inMinute = timeAgo.inMinutes;
    int day = inMinute ~/ (60 * 24);
    int hour = (inMinute - day * 24 * 60) ~/ 60;
    int minute = inMinute - day * 24 * 60 - hour * 60;
    if (day <= 6 && day >=1){
      switch(dateTime.weekday){
        case 0:
          return "Th 2";
        case 1:
          return "Th 3";
        case 2:
          return "Th 4";
        case 3:
          return "Th 5";
        case 4:
          return "Th 6";
        case 5:
          return "Th 7";
        case 6:
          return "CN";
      }
    }else if (day == 0){
      return DateFormat('HH:mm').format(dateTime);
    }else{
      return "Ngày" + dateTime.day.toString() + " tháng " + dateTime.month.toString();
    }
  }
}