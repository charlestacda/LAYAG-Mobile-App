import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  final bool isTodoEvent;

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
    required this.isTodoEvent,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
  final Map<String, dynamic> data = snapshot.data()!;
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
    isTodoEvent: false,
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
  
factory Event.fromTodoTask(String id, Map<String, dynamic> todoTask) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm a');

    return Event(
      id: id,
      title: todoTask['todoTask'],
      description: todoTask['todoStatus'], // You can customize this based on your requirements
      startDateTime: dateFormat.parse(todoTask['deadlineDate']),
      endDateTime: dateFormat.parse(todoTask['deadlineDate']),
      location: '', // You can customize this based on your requirements
      dateAdded: DateTime.now(),
      dateEdited: DateTime.now(),
      visibleToEmployees: true, // You can customize this based on your requirements
      visibleToStudents: true, // You can customize this based on your requirements
      archived: false, // You can customize this based on your requirements
      isTodoEvent: true, 
    );
  }
}

Stream<Map<DateTime, List<Event>>> fetchEventsRealtime(BuildContext context) {
  try {
    final userType = Provider.of<UserTypeProvider>(context, listen: false).userType;

    final eventsStream = FirebaseFirestore.instance.collection('events').snapshots();
    final todoListStream = _fetchTodoList(context);

    return eventsStream.asyncMap((eventsSnapshot) async {
      final events = eventsSnapshot.docs.map((doc) {
        return Event.fromFirestore(doc);
      }).toList();

      final todoTasks = await todoListStream;

      final allItems = [...events, ...todoTasks];

      LinkedHashMap<DateTime, List<Event>> eventsMap = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );

      for (final item in allItems) {
        final bool isAdmin = userType == 'Admin';
        final bool isVisibleToStudents = item.visibleToStudents && !item.archived;
        final bool isVisibleToEmployees = item.visibleToEmployees && !item.archived;

        // Filter items based on user type and visibility settings
        if ((userType == 'Student' && isVisibleToStudents) ||
            (userType == 'Faculty' && isVisibleToEmployees) ||
            isAdmin) {
          final DateTime startDate = tz.TZDateTime.from(item.startDateTime, tz.local);

          if (isSameDay(startDate, item.endDateTime)) {
            // Event or todo task lasts for only one day, add to that specific date only
            if (eventsMap[startDate] == null) {
              eventsMap[startDate] = [item];
            } else {
              eventsMap[startDate]!.add(item);
            }
          } else {
            // Loop through each date between the start and end date and add the item to the corresponding date in the map
            DateTime date = startDate;
            while (!isSameDay(date, item.endDateTime.add(Duration(days: 1)))) {
              if (eventsMap[date] == null) {
                eventsMap[date] = [item];
              } else {
                eventsMap[date]!.add(item);
              }
              date = date.add(Duration(days: 1));
            }
          }
        }
      }

      return eventsMap;
    });
  } catch (e) {
    print('Error fetching events and todo tasks: $e');
    throw Exception('Failed to fetch events and todo tasks');
  }
}


Future<List<Event>> _fetchTodoList(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userId = currentUser.uid;
    final todoListCollection = FirebaseFirestore.instance.collection('todo_list').doc(userId);

    final todoListSnapshot = await todoListCollection.get();
    if (todoListSnapshot.exists) {
      final todoListData = todoListSnapshot.data();
      if (todoListData != null) {
        return todoListData.entries.map((entry) {
          final taskId = entry.key;
          final todoTask = entry.value as Map<String, dynamic>;
          return Event.fromTodoTask(taskId, todoTask);
        }).toList();
      }
    }
  }

  return [];
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