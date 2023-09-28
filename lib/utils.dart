import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Event {
  final String title;
  final String description;
  final String startDatetime;
  final String endDatetime;
  final String location;
  final int userId;

  Event({
    required this.title,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    required this.location,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
      startDatetime: json['start_datetime'],
      endDatetime: json['end_datetime'],
      location: json['location'],
      userId: json['user_id'],
    );
  }
}

Future<Map<DateTime, List<Event>>> fetchEvents() async {
  final response = await http.get(
      Uri.parse('http://charlestacda-layag_cms.mdbgo.io/events_view.php')); // Replace with your API endpoint

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    final events = data.map((e) => Event.fromJson(e)).toList();

    final LinkedHashMap<DateTime, List<Event>> eventsMap =
        LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    for (final event in events) {
      final DateTime startDate = DateTime.parse(event.startDatetime);
      final DateTime endDate = DateTime.parse(event.endDatetime);

      for (var date = startDate;
          date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
          date = date.add(Duration(days: 1))) {
        eventsMap.update(
          DateTime(date.year, date.month, date.day),
          (value) {
            value.add(event);
            return value;
          },
          ifAbsent: () => [event],
        );
      }
    }

    return eventsMap;
  } else {
    throw Exception('Failed to fetch events');
  }
}

// Initialize kEvents with empty data initially
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);

// Load events from API and populate kEvents
Future<void> loadEvents() async {
  final events = await fetchEvents();
  kEvents.clear();
  kEvents.addAll(events);
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
