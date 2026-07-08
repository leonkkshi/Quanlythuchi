/// Lời chào theo thời gian trong ngày.
class GreetingUtils {
  GreetingUtils._();

  static String greetingForHour(int hour) {
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  static String greetingNow() => greetingForHour(DateTime.now().hour);
}
