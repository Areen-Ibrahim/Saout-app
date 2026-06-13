String formatDate(DateTime dateTime) {
  return "${_getWeekday(dateTime.weekday)}, ${dateTime.day} ${_getMonth(dateTime.month)}";
}

// دالة لتنسيق الوقت
String formatTime(DateTime dateTime) {
  return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
}



// دالة لتحويل الرقم إلى اسم اليوم
String _getWeekday(int weekday) {
  switch (weekday) {
    case DateTime.monday: return "Mon";
    case DateTime.tuesday: return "Tue";
    case DateTime.wednesday: return "Wed";
    case DateTime.thursday: return "Thu";
    case DateTime.friday: return "Fri";
    case DateTime.saturday: return "Sat";
    case DateTime.sunday: return "Sun";
    default: return "";
  }
}

// دالة لتحويل الرقم إلى اسم الشهر
String _getMonth(int month) {
  switch (month) {
    case 1: return "Jan";
    case 2: return "Feb";
    case 3: return "Mar";
    case 4: return "Apr";
    case 5: return "May";
    case 6: return "Jun";
    case 7: return "Jul";
    case 8: return "Aug";
    case 9: return "Sep";
    case 10: return "Oct";
    case 11: return "Nov";
    case 12: return "Dec";
    default: return "";
  }
}
String formatDateTime(String dateTimeStr) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return "${_getWeekday(dateTime.weekday)}, ${dateTime.day} ${_getMonth(dateTime.month)}, ${formatTime(dateTime)}";
  } catch (e) {
    print("Error parsing date: $e");
    return "Invalid Date"; // النص الافتراضي عند الفشل
  }
}

String formatDateAch(String dateTimeStr) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    return "${_getWeekday(dateTime.weekday)}, ${dateTime.day} ${_getMonth(dateTime.month)}";
  } catch (e) {
    print("Error parsing date: $e");
    return "Invalid Date"; // النص الافتراضي عند الفشل
  }
}





