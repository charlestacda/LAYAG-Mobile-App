import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../utils.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/home.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<dynamic>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  StreamSubscription<Map<DateTime, List<dynamic>>>? _eventsSubscription;
  late User? _user;
  late String userType;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;

    loadEventsRealtime(); // Start listening to real-time updates

    _selectedEvents.value = _getEventsForDay(_selectedDay!);

    checkForNewHandbooks();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _eventsSubscription?.cancel(); // Cancel the subscription if it exists
    super.dispose();
  }

  Future<void> checkForNewHandbooks() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  if (_auth.currentUser != null) {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid;

    // Reference to the user's handbook collection
    final userHandbookCollectionRef = _firestore.collection('users').doc(userId).collection('handbooks');

    // Get a list of handbook IDs the user already has
    final userHandbookIds = await userHandbookCollectionRef.get().then((querySnapshot) => querySnapshot.docs.map((doc) => doc.id).toList());

    // Reference to the 'handbooks' collection
    final handbooksRef = _firestore.collection('handbooks');

    // Update existing handbooks
    await Future.forEach(userHandbookIds, (handbookId) async {
      final userHandbookDocRef = userHandbookCollectionRef.doc(handbookId);
      final handbookDocSnapshot = await handbooksRef.doc(handbookId).get();
      if (handbookDocSnapshot.exists) {
        final handbookTitle = handbookDocSnapshot.data()?['title'];
        final handbookContent = handbookDocSnapshot.data()?['content'];
        
        // Update the title and content fields in the user's handbook document
        await userHandbookDocRef.update({
          'title': handbookTitle,
          'content': handbookContent,
        });

        // Call function to update notification when content is updated
        await updateHandbookContent(handbookId, handbookContent, userId!);

        print('Notification added for user: ${currentUser?.email} - Handbook ID: $handbookId');
      }
    });

    // Fetch all handbooks that are not yet stored for the user
    final handbooksSnapshot = await handbooksRef.get();

    if (handbooksSnapshot.docs.isNotEmpty) {
      // Loop through each handbook and store it in the user's collection if not already present
      for (final handbookDoc in handbooksSnapshot.docs) {
        final handbookId = handbookDoc.id;
        if (!userHandbookIds.contains(handbookId)) {
          final title = handbookDoc.data()['title'];
          final content = handbookDoc.data()['content'];

          // Store the handbook in the user's collection with the ID as the document name
          await userHandbookCollectionRef.doc(handbookId).set({
            'title': title,
            'content': content,
          });

          // Do something with the new handbook, like showing a notification or updating UI
          print('New handbook stored for user: ${currentUser?.email} - ID: $handbookId');
        }
      }
    } else {
      print('No handbooks found in the database.');
    }
  } else {
    print('No user is currently logged in.');
  }
}

Future<void> updateHandbookContent(String handbookId, String newContent, String userId) async {
  final handbookRef = _firestore.collection('handbooks').doc(handbookId);

  // Update the content of the handbook
  await handbookRef.update({
    'content': newContent,
  });

  // Call the notification function only when content is updated
  final handbookDoc = await handbookRef.get();
  if (handbookDoc.exists) {
    final handbookTitle = handbookDoc.data()?['title'];
    final handbookContent = handbookDoc.data()?['content'];
    await checkAndUpdateNotification(handbookId, handbookTitle, handbookContent, userId, _firestore);
  }
}

Future<void> checkAndUpdateNotification(String handbookId, String handbookTitle, String handbookContent, String userId, FirebaseFirestore firestore) async {
  // Reference to the 'handbooks' collection
  final handbooksRef = firestore.collection('handbooks');

  // Get the previous content of the handbook
  final prevContentQuery = await handbooksRef.doc(handbookId)
      .collection('previous_content')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  String prevContent = '';
  if (prevContentQuery.docs.isNotEmpty) {
    prevContent = prevContentQuery.docs.first.data()['content'];
  }

  // Check if content has been updated
  if (prevContent != handbookContent) {
    final notificationName = '$handbookTitle updated';
    final notificationTitle = 'The $handbookTitle has been updated!';

    final uniqueNotificationId = Uuid().v4(); // Generate a unique ID for the notification

    // Add the notification directly under the 'Notifications' map within the user's document
    final notificationRef = firestore.collection('users').doc(userId);
    await notificationRef.update({
      'Notifications.$uniqueNotificationId': { // Use the unique ID as the key
        'notifName': notificationName,
        'notifTitle': notificationTitle,
      },
    });

    print('Notification added for user: $userId - Handbook ID: $handbookId');
    sendUpdateNotification(uniqueNotificationId, '$handbookTitle updated!', 'The $handbookTitle has been updated!');

    // Update the previous content in the database
    await handbooksRef.doc(handbookId).collection('previous_content').add({
      'content': handbookContent,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> sendUpdateNotification(String uniqueId, String title, String message) async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: uniqueId.hashCode, // Use the unique ID as the notification ID
          channelKey: 'basic_channel', // Channel key defined in initialization
          title: title,
          body: message,
        ),
      );
    } else {
      // Handle the case when notification permission is not granted
      // You may choose to show a message or log a warning
      print("Notification permission is not granted. Notification not sent.");
    }
  }

  void loadEventsRealtime() {
  _eventsSubscription = fetchEventsRealtime(context).listen((eventsMap) {
    setState(() {
      kEvents.clear();
      kEvents.addAll(eventsMap.map((key, value) =>
          MapEntry(key, value.cast<Event>())
      ));

      // Cast the items to Event type
      _selectedEvents.value = _getItemsForDay(_selectedDay!).cast<Event>();
    });
  });
}


List<dynamic> _getItemsForDay(DateTime day) {
  final List<Event> events = kEvents[day] ?? [];
  final List<Event> todoTasks = _getTodoTasksForDay(day);

  return [...events, ...todoTasks];
}

List<Event> _getTodoTasksForDay(DateTime day) {
  final List<Event> todoTasks = [];

  // Iterate over the todo_list collection for the current user
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userId = currentUser.uid;
    final todoListCollection = FirebaseFirestore.instance.collection('todo_list').doc(userId);

    todoListCollection.get().then((snapshot) {
      if (snapshot.exists) {
        final todoListData = snapshot.data();
        if (todoListData != null) {
          todoListData.forEach((taskId, todoTask) {
            final deadlineDateString = todoTask['deadlineDate'] as String;
            final event = Event.fromTodoTask(taskId, {
              ...todoTask,
              'deadlineDate': deadlineDateString,
            });
            todoTasks.add(event);
          });
        }
      }
    });
  }

  return todoTasks;
}



  String _formatTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  void _showEventDetails(Event event) {
  final startTimeLocal = event.startDateTime.toLocal();
  final endTimeLocal = event.endDateTime.toLocal();
  final formattedStartTime = DateFormat('h:mm a').format(startTimeLocal);
  final formattedEndTime = DateFormat('h:mm a').format(endTimeLocal);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(event.isTodoEvent ? 'Todo Details' : 'Event Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Title: ${event.title}'),
            Text('Description: ${event.description}'),
            Text(event.isTodoEvent ? 'Deadline Date $formattedStartTime' : 'Start Time: $formattedStartTime'),
            if (!event.isTodoEvent) // Show "Location" only for regular events
              Text('End Time: $formattedEndTime'),
            if (!event.isTodoEvent)
              Text('Location: ${event.location}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
  if (!isSameDay(_selectedDay, selectedDay)) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = _getItemsForDay(selectedDay);
  }
}

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            // Fetch the current user details
            final user = FirebaseAuth.instance.currentUser;
            return IconButton(
              icon: ClipOval(
                child: user != null && user.photoURL != null
                    ? Image.network(
                        user.photoURL!,
                        width: 24,
                        height: 24,
                      )
                    : Image.asset(
                        'assets/images/user.png',
                        width: 24,
                        height: 24,
                      ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Notifications(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 30),
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/calendar_activities.png',
                  width: double.infinity,
                ),
              ),
            ),
            TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 129, 126, 126),
                ),
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFA33334),
                ),
              ),
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 8.0),
            ValueListenableBuilder<List<dynamic>>(
  valueListenable: _selectedEvents,
  builder: (context, value, _) {
    return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return GestureDetector(
                      onTap: () => _showEventDetails(event),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            '${event.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          ],
        ),
      ),
    );
  }
}