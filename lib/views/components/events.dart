import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

final today = DateTime.now();
final eventFirstDay = DateTime(today.year, today.month - 3, today.day);
final eventLastDay = DateTime(today.year, today.month + 3, today.day);
final events = LinkedHashMap<DateTime, List<Events>>(
  equals: isSameDay,
  hashCode: (DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  },
)..addAll({for (var item in List.generate(50, (index) => index)) DateTime.utc(eventFirstDay.year, eventFirstDay.month, item * 5): List.generate(item % 4 + 1, (index) => Events('Event $item | ${index + 1}'))}..addAll({}));

class Events {
  final String title;

  const Events(this.title);

  @override
  String toString() => title;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
