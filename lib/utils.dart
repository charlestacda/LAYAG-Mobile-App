import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:lpu_app/main.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;

import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description; 
  final DateTime startDateTime; 
  final DateTime endDateTime;
  final String location; 
  final DateTime dateAdded;
  final DateTime dateEdited;
  final bool visibleToEmployees;
  final bool visibleToStudents;
  final bool archived;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    required this.dateAdded,
    required this.dateEdited,
    required this.visibleToEmployees,
    required this.visibleToStudents,
    required this.archived,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
  Map<String, dynamic> data = snapshot.data()!;
  return Event(
    id: snapshot.id,
    title: data['title'],
    description: data['description'],
    startDateTime: tz.TZDateTime.from((data['startDateTime'] as Timestamp).toDate(), tz.local),
    endDateTime: tz.TZDateTime.from((data['endDateTime'] as Timestamp).toDate(), tz.local),
    location: data['location'],
    dateAdded: tz.TZDateTime.from((data['dateAdded'] as Timestamp).toDate(), tz.local),
    dateEdited: tz.TZDateTime.from((data['dateEdited'] as Timestamp).toDate(), tz.local),
    visibleToEmployees: data['visibleToEmployees'],
    visibleToStudents: data['visibleToStudents'],
    archived: data['archived'],
  );
}


  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "description": description,
      "startDateTime": startDateTime,
      "endDateTime": endDateTime,
      "location": location,
      "dateAdded": dateAdded,
      "dateEdited": dateEdited,
      "visibleToEmployees": visibleToEmployees,
      "visibleToStudents": visibleToStudents,
      "archived": archived,
    };
  }
}

Stream<Map<DateTime, List<Event>>> fetchEventsRealtime(BuildContext context) {
  try {
    return FirebaseFirestore.instance.collection('events').snapshots().map((snapshot) {
      final userType = Provider.of<UserTypeProvider>(context, listen: false).userType;
      
      List<Event> events = snapshot.docs.map((doc) {
        return Event.fromFirestore(doc);
      }).toList();

      LinkedHashMap<DateTime, List<Event>> eventsMap = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );

      for (final event in events) {
        final bool isAdmin = userType == 'Admin';
        final bool isVisibleToStudents = event.visibleToStudents && !event.archived;
        final bool isVisibleToEmployees = event.visibleToEmployees && !event.archived;
        
        // Filter events based on user type and visibility settings
        if ((userType == 'Student' && isVisibleToStudents) ||
            (userType == 'Faculty' && isVisibleToEmployees) ||
            isAdmin) {
          final DateTime startDate = tz.TZDateTime.from(event.startDateTime, tz.local);
          final DateTime endDate = tz.TZDateTime.from(event.endDateTime, tz.local);

          if (isSameDay(startDate, endDate)) {
            // Event lasts for only one day, add to that specific date only
            if (eventsMap[startDate] == null) {
              eventsMap[startDate] = [event];
            } else {
              eventsMap[startDate]!.add(event);
            }
          } else {
            // Loop through each date between the start and end date and add the event to the corresponding date in the map
            DateTime date = startDate;
            while (!isSameDay(date, endDate.add(Duration(days: 1)))) {
              if (eventsMap[date] == null) {
                eventsMap[date] = [event];
              } else {
                eventsMap[date]!.add(event);
              }
              date = date.add(Duration(days: 1));
            }
          }
        }
      }

      return eventsMap;
    });
  } catch (e) {
    print('Error fetching events: $e');
    throw Exception('Failed to fetch events');
  }
}






// Initialize kEvents with empty data initially
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
);


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
final kFirstDay = DateTime(kToday.year - 1, kToday.month, kToday.day); // Go back 1 year
final kLastDay = DateTime(kToday.year + 1, kToday.month, kToday.day); // Go forward 1 year

