import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/models/complete_task_model.dart';
import 'package:lpu_app/models/task_model.dart';
import 'package:lpu_app/models/user_model.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'dart:async';

DateTime dateNow = DateTime.now();
DateTime date = DateTime(dateNow.year, dateNow.month, dateNow.day);
TimeOfDay timeNow = TimeOfDay.now();
TimeOfDay time = TimeOfDay(hour: timeNow.hour, minute: timeNow.minute);

DateTime CreateDateNow = DateTime.now();
TimeOfDay CreateTimeNow = TimeOfDay.now();

dynamic newFormDate = new DateFormat('yyyy-MM-dd');
dynamic newForm = newFormDate.format(CreateDateNow);

List<CompleteTaskModel> completedList = [];
List<TaskModel> todoList = [];

FirebaseFirestore firestore = FirebaseFirestore.instance;

class ToDo extends StatefulWidget {
  const ToDo({Key? key}) : super(key: key);

  @override
  ToDoState createState() => ToDoState();
}

class ToDoState extends State<ToDo> {
  final CollectionReference _todoreference =
      FirebaseFirestore.instance.collection('todo_list');
  final CollectionReference _notifreference =
      FirebaseFirestore.instance.collection('users');

  TextEditingController todoTask = TextEditingController();

  dynamic fTime, fDate;
  var startDate = DateTime.now();
  late DateTime date = DateTime.now();
  late TimeOfDay time = TimeOfDay.now();
  TextEditingController timeController = TextEditingController(
      text: ''); // Ensure it's initialized with an empty string
  TextEditingController dateController = TextEditingController();
  late Future<UserModel?> userDetails;
  String? userID;
  List<dynamic> combinedTasks = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchUserID();
    getToDo();
    getUserDetails(userID!);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update the UI every minute
      setState(() {});
      checkAndSendReminders(todoList);
    });
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  Future<void> sendReminderNotification(String title, String message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Unique ID for the notification
        channelKey: 'basic_channel', // Channel key defined in initialization
        title: title,
        body: message,
      ),
    );
  }

  void checkAndSendReminders(List<TaskModel> tasks) {
    final now = DateTime.now();

    for (final task in tasks) {
      DateFormat format = DateFormat('yyyy-MM-dd h:mm a');
      final timeDifferenceInSeconds =
          format.parse(task.deadlineDate).difference(now).inSeconds;
      print(task.overdueNotificationSent);

      if (!task.dueSoonNotificationSent &&
          timeDifferenceInSeconds <= 7 * 24 * 60 * 60 &&
          timeDifferenceInSeconds > 24 * 60 * 60) {
        _notifreference.doc(userID).set({
          'Notifications': {
            '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
              'notifName': 'Task Due Soon',
              'notifTitle': 'Task "${task.todoTask}" is due next week.',
            }
          }
        }, SetOptions(merge: true));
        task.dueSoonNotificationSent = true;
        _todoreference.doc(userID).set({
          task.todoTask: {
            'todoTask': task.todoTask,
            'dueSoonNotificationSent': true,
          }
        }, SetOptions(merge: true));
      } else if (!task.dueTomNotificationSent &&
          timeDifferenceInSeconds <= 24 * 60 * 60 &&
          timeDifferenceInSeconds > 6 * 60 * 60) {
        _notifreference.doc(userID).set({
          'Notifications': {
            '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
              'notifName': 'Task Due Tomorrow',
              'notifTitle': 'Task "${task.todoTask}" is due tomorrow.',
            }
          }
        }, SetOptions(merge: true));
        task.dueTomNotificationSent = true;
        _todoreference.doc(userID).set({
          task.todoTask: {
            'todoTask': task.todoTask,
            'dueTomNotificationSent': true,
          }
        }, SetOptions(merge: true));
      } else if (!task.dueSixNotificationSent &&
          timeDifferenceInSeconds <= 6 * 60 * 60 &&
          timeDifferenceInSeconds > 60 * 60) {
        _notifreference.doc(userID).set({
          'Notifications': {
            '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
              'notifName': 'Task Due 6 Hours',
              'notifTitle': 'Task "${task.todoTask}" is due within 6 hours.',
            }
          }
        }, SetOptions(merge: true));
        task.dueSixNotificationSent = true;
        _todoreference.doc(userID).set({
          task.todoTask: {
            'todoTask': task.todoTask,
            'dueSixNotificationSent': true,
          }
        }, SetOptions(merge: true));
      } else if (!task.almostDueNotificationSent &&
          timeDifferenceInSeconds <= 60 * 60 &&
          timeDifferenceInSeconds > 0) {
        _notifreference.doc(userID).set({
          'Notifications': {
            '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
              'notifName': 'Task Almost Due',
              'notifTitle': 'Task "${task.todoTask}" is almost due.',
            }
          }
        }, SetOptions(merge: true));
        task.almostDueNotificationSent = true;
        _todoreference.doc(userID).set({
          task.todoTask: {
            'todoTask': task.todoTask,
            'almostDueNotificationSent': true,
          }
        }, SetOptions(merge: true));
      } else if (!task.overdueNotificationSent &&
          timeDifferenceInSeconds <= 0) {
        _notifreference.doc(userID).set({
          'Notifications': {
            '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
              'notifName': 'Task Overdue',
              'notifTitle': 'Task "${task.todoTask}" is overdue.',
            }
          }
        }, SetOptions(merge: true));
        task.overdueNotificationSent = true;
        _todoreference.doc(userID).set({
          task.todoTask: {
            'todoTask': task.todoTask,
            'overdueNotificationSent': true,
          }
        }, SetOptions(merge: true));
      }
    }
  }

  void fetchUserID() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        userID = user.uid;
        userDetails = getUserDetails(user.uid);
      });
    }
  }

  Future<UserModel?> getUserDetails(String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('users').doc(userId).get();

    if (snapshot.exists) {
      return UserModel.fromMap(snapshot.data()!);
    } else {
      return null;
    }
  }

  DateTime getDateTimeFromString(String dateString) {
    DateFormat format = DateFormat("yyyy-MM-dd h:mm a");
    DateTime? parsedDateTime = format.parse(dateString);
    print("$parsedDateTime'");
    return parsedDateTime;
  }

  Color _getTaskColor(DateTime deadlineDate) {
    DateTime today = DateTime.now();
    int differenceInSeconds = deadlineDate.difference(today).inSeconds;

    if (differenceInSeconds <= 0) {
      return AppConfig.appSecondaryTheme;
    } else if (differenceInSeconds <= 60 * 60) {
      return Colors.red;
    } else if (differenceInSeconds <= 6 * 60 * 60) {
      return Colors.orange;
    } else if (differenceInSeconds <= 24 * 60 * 60) {
      return Colors.yellow;
    } else if (differenceInSeconds <= 7 * 24 * 60 * 60 &&
        differenceInSeconds > 24 * 60 * 60) {
      return Colors.green;
    } else {
      return Color.fromARGB(255, 38, 235, 110);
    }
  }

  void updateFirestoreForCompletion(
    TaskModel completedTask,
    CompleteTaskModel convertedCompletedTask,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('completed_list')
          .doc(userID)
          .set({
        convertedCompletedTask.TodoTask: {
          'TodoTask': convertedCompletedTask.TodoTask,
          'CreatedDate': convertedCompletedTask.CreatedDate,
          'DeadlineDate': convertedCompletedTask.DeadlineDate,
          'TodoStatus': 'Completed',
          'DueSoonNotificationSent':
              convertedCompletedTask.DueSoonNotificationSent,
          'DueTomNotificationSent':
              convertedCompletedTask.DueTomNotificationSent,
          'DueSixNotificationSent':
              convertedCompletedTask.DueSixNotificationSent,
          'AlmostDueNotificationSent':
              convertedCompletedTask.AlmostDueNotificationSent,
          'OverdueNotificationSent':
              convertedCompletedTask.OverdueNotificationSent,
        }
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('todo_list')
          .doc(userID)
          .update({
        completedTask.todoTask: FieldValue.delete(),
      });
    } catch (e) {
      print('Error updating Firestore: $e');
      // Handle error as needed
    }
  }

  void updateFirestoreForIncompletion(
    CompleteTaskModel incompleteTask,
    TaskModel convertedIncompleteTask,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('todo_list').doc(userID).set({
        convertedIncompleteTask.todoTask: {
          'todoTask': convertedIncompleteTask.todoTask,
          'createdDate': convertedIncompleteTask.createdDate,
          'deadlineDate': convertedIncompleteTask.deadlineDate,
          'todoStatus': 'Pending',
          'DueSoonNotificationSent':
              convertedIncompleteTask.dueSoonNotificationSent,
          'DueTomNotificationSent':
              convertedIncompleteTask.dueSixNotificationSent,
          'DueSixNotificationSent':
              convertedIncompleteTask.dueSixNotificationSent,
          'AlmostDueNotificationSent':
              convertedIncompleteTask.almostDueNotificationSent,
          'OverdueNotificationSent':
              convertedIncompleteTask.overdueNotificationSent,
        }
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('completed_list')
          .doc(userID)
          .update({
        incompleteTask.TodoTask: FieldValue.delete(),
      });
    } catch (e) {
      print('Error updating Firestore: $e');
      // Handle error as needed
    }
  }

  void removeCompletedTask(int index) async {
    try {
      // Store the information that needs to be deleted
      final taskToRemove = completedList[index];

      // Remove the card immediately from the UI
      setState(() {
        completedList.removeAt(index);
      });

      // Delete the stored information from the `completed_list` collection in Firestore
      await firestore.collection('completed_list').doc(userID).update({
        taskToRemove.TodoTask: FieldValue.delete(),
      }).then((_) {
        // Successfully deleted from Firestore
      }).catchError((error) {
        // Handle error while deleting from Firestore
        setState(() {
          // Add the task back to the list if deletion from Firestore fails
          completedList.insert(index, taskToRemove);
        });
        Fluttertoast.showToast(msg: 'Failed to remove task');
      });
    } catch (e) {
      print('Error removing task: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: ClipOval(
                child: Image.asset(
                  'assets/images/user.png',
                  width: 24,
                  height: 24,
                ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Image.asset('assets/images/lpu_title.png'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Help()));
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          onPressed: () {
            timeController.text = DateFormat('h:mm a').format(
              DateTime.now().toUtc().add(const Duration(hours: 8)),
            );
            dateController.text =
                DateFormat('yyyy-MM-dd').format(DateTime.now());
            date = DateTime.now().toUtc().add(const Duration(hours: 8));
            time = TimeOfDay.fromDateTime(
                DateTime.now().toUtc().add(const Duration(hours: 8)));
            fDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
            fTime = DateFormat('h:mm a').format(DateTime.now());

            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add To Do Item'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          onChanged: (value) => todoTask.text = value,
                        ),
                        TextField(
                          controller: dateController,
                          onTap: () async {
                            DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (newDate == null) {
                              return;
                            }

                            setState(() {
                              date = newDate;
                              fDate = date;
                              dynamic dateformatter = DateFormat('yyyy-MM-dd');
                              fDate = dateformatter.format(date);
                              dateController.text =
                                  fDate; // Update the text field with the selected date
                            });
                          },
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.calendar_today,
                                color: AppConfig.appSecondaryTheme),
                            hintText: 'Select Date',
                          ),
                        ),
                        TextField(
                          controller: timeController,
                          onTap: () async {
                            TimeOfDay currentTime = TimeOfDay.fromDateTime(
                              DateTime.now()
                                  .toUtc()
                                  .add(const Duration(hours: 8)),
                            );
                            TimeOfDay? newTime = await showTimePicker(
                              context: context,
                              initialTime: currentTime,
                            );

                            if (newTime == null) {
                              return;
                            }

                            setState(() {
                              time =
                                  newTime; // Set the selected time from the picker
                              fTime = time.format(
                                  context); // Format the selected time for displaying in the TextField
                              timeController.text =
                                  fTime; // Update the text field with the selected time
                            });
                          },
                          decoration: InputDecoration(
                            suffixIcon: Icon(Icons.access_time,
                                color: AppConfig.appSecondaryTheme),
                            hintText: 'Select Time',
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          final newTodo = FirebaseAuth.instance.currentUser;
                          final newID = newTodo?.uid;

                          fDate ??= newForm;
                          fTime ??= CreateTimeNow.format(context);

                          if (todoTask.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: 'Please set task title');
                          } else if (fDate == null || fTime == null) {
                            Fluttertoast.showToast(
                                msg: 'Please set Date and Time');
                          } else {
                            fDate ??=
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            fTime ??=
                                DateFormat('h:mm a').format(DateTime.now());
                            try {
                              DateTime selectedDateTime =
                                  DateFormat('yyyy-MM-dd h:mm a')
                                      .parse('$fDate $fTime');
                              DateTime currentDateTime = DateTime.now();

                              if (selectedDateTime.isBefore(currentDateTime)) {
                                Fluttertoast.showToast(
                                    msg: 'Please select a future Time');
                              } else {
                                addToDo(newID!);
                                DateTime selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );

                                final now = DateTime.now();
                                final timeDifferenceInSeconds =
                                    selectedDateTime.difference(now).inSeconds;

                                print(timeDifferenceInSeconds);

                                String formattedNow =
                                    DateFormat('yyyy-MM-dd h:mm a').format(now);
                                String formattedSelectedDateTime =
                                    DateFormat('yyyy-MM-dd h:mm a')
                                        .format(selectedDateTime);

                                setState(() {
                                  todoList.add(TaskModel(
                                    createdDate: formattedNow,
                                    deadlineDate: formattedSelectedDateTime,
                                    todoTask: todoTask.text,
                                    todoStatus: 'Pending',
                                    dueSoonNotificationSent:
                                        timeDifferenceInSeconds <=
                                                7 * 24 * 60 * 60 &&
                                            timeDifferenceInSeconds >
                                                24 * 60 * 60,
                                    dueTomNotificationSent:
                                        timeDifferenceInSeconds <=
                                                24 * 60 * 60 &&
                                            timeDifferenceInSeconds >
                                                6 * 60 * 60,
                                    dueSixNotificationSent:
                                        timeDifferenceInSeconds <=
                                                6 * 60 * 60 &&
                                            timeDifferenceInSeconds > 60 * 60,
                                    almostDueNotificationSent:
                                        timeDifferenceInSeconds <= 60 * 60 &&
                                            timeDifferenceInSeconds > 0,
                                    overdueNotificationSent:
                                        timeDifferenceInSeconds <= 0,
                                  ));
                                });

                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              print('Error parsing date/time: $e');
                              Fluttertoast.showToast(
                                  msg: 'Error parsing date/time');
                            }
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                });
          },
          backgroundColor: AppConfig.appSecondaryTheme,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    child: Image.asset(
                      'assets/images/todo_list_header.png',
                      width: double.infinity,
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 16)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                    child: Text(
                      todoList.length == 0
                          ? 'No Ongoing Task'
                          : 'Ongoing (${todoList.length})',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    DateTime deadlineDate =
                        getDateTimeFromString(todoList[index].deadlineDate);
                    Color taskColor = _getTaskColor(deadlineDate);
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        title: Text(todoList[index].todoTask),
                        subtitle: Text(
                          todoList[index].deadlineDate,
                          // Format the deadlineDate as per your requirement
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.check_box_outline_blank),
                          color: const Color(0xFF606060),
                          onPressed: () {
                            setState(() {
                              final completedTask = todoList.removeAt(index);
                              final convertedCompletedTask = CompleteTaskModel(
                                CreatedDate: completedTask.createdDate,
                                DeadlineDate: completedTask.deadlineDate,
                                TodoTask: completedTask.todoTask,
                                TodoStatus: 'Completed',
                                DueSoonNotificationSent:
                                    completedTask.dueSoonNotificationSent,
                                DueTomNotificationSent:
                                    completedTask.dueTomNotificationSent,
                                DueSixNotificationSent:
                                    completedTask.dueSixNotificationSent,
                                AlmostDueNotificationSent:
                                    completedTask.almostDueNotificationSent,
                                OverdueNotificationSent:
                                    completedTask.overdueNotificationSent,
                              );
                              completedList.add(convertedCompletedTask);

                              updateFirestoreForCompletion(
                                  completedTask, convertedCompletedTask);
                            });
                          },
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color:
                                taskColor, // Set the color based on the due date
                          ),
                          width: 35,
                          height: 56,
                        ),
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
                    child: Text(
                      completedList.length == 0
                          ? 'No Completed Task'
                          : 'Completed (${completedList.length})',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Futura',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: completedList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            title: Text(
                              completedList[index].TodoTask,
                              style: const TextStyle(
                                  color: Color(0xff606060),
                                  decoration: TextDecoration.lineThrough),
                            ),
                            subtitle: Text(
                              completedList[index].DeadlineDate,
                              style: const TextStyle(
                                color: Color(0xff606060),
                              ),
                            ),
                            leading: IconButton(
                              icon: const Icon(Icons.check_box_outlined),
                              color: const Color(0xff606060),
                              onPressed: () {
                                setState(() {
                                  final incompleteTask =
                                      completedList.removeAt(index);
                                  final convertedIncompleteTask = TaskModel(
                                    createdDate: incompleteTask.CreatedDate,
                                    deadlineDate: incompleteTask.DeadlineDate,
                                    todoTask: incompleteTask.TodoTask,
                                    todoStatus: 'Pending',
                                    dueSoonNotificationSent:
                                        incompleteTask.DueSoonNotificationSent,
                                    dueTomNotificationSent:
                                        incompleteTask.DueTomNotificationSent,
                                    dueSixNotificationSent:
                                        incompleteTask.DueSixNotificationSent,
                                    almostDueNotificationSent: incompleteTask
                                        .AlmostDueNotificationSent,
                                    overdueNotificationSent:
                                        incompleteTask.OverdueNotificationSent,
                                  );
                                  todoList.add(convertedIncompleteTask);

                                  updateFirestoreForIncompletion(
                                      incompleteTask, convertedIncompleteTask);
                                });
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              color: const Color(0xff606060),
                              onPressed: () {
                                removeCompletedTask(index);
                                //cancelAllScheduledNotifications();
                              },
                            ),
                          ));
                    }),
              ]),
            ),
          ),
        ),
      );

  Future<void> cancelAllScheduledNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  void addToDo(String ID) async {
    try {
      DateTime selectedDateTime =
          DateFormat('yyyy-MM-dd h:mm a').parse('$fDate $fTime');
      DateTime currentDateTime = DateTime.now();

      if (selectedDateTime.isBefore(currentDateTime)) {
        Fluttertoast.showToast(msg: 'Please select a future Time');
        return;
      }

      await _todoreference.doc(ID).set({
        todoTask.text: {
          'todoTask': todoTask.text,
          'createdDate':
              '${newForm.toString()} ${CreateTimeNow.format(context).toString()}',
          'deadlineDate': '$fDate ${fTime.toString()}',
          'todoStatus': 'Pending',
          'dueSoonNotificationSent': false,
          'dueTomNotificationSent': false,
          'dueSixNotificationSent': false,
          'almostDueNotificationSent': false,
          'overdueNotificationSent': false,
        }
      }, SetOptions(merge: true));

      await _notifreference.doc(ID).set({
        'Notifications': {
          '${todoTask.text}_${DateTime.now().millisecondsSinceEpoch}': {
            'notifName': '${todoTask.text}',
            'notifTitle': 'Added To Do: ${todoTask.text}',
          }
        }
      }, SetOptions(merge: true));

      // Calculate dates for notifications
      DateTime oneWeekBefore = selectedDateTime.subtract(Duration(days: 7));
      DateTime oneDayBefore = selectedDateTime.subtract(Duration(days: 1));
      DateTime sixHoursBefore = selectedDateTime.subtract(Duration(hours: 6));
      DateTime oneHourBefore = selectedDateTime.subtract(Duration(hours: 1));
      DateTime dueTime = selectedDateTime;

      // Schedule notifications for each date
      scheduleNotification('Task Due Soon', oneWeekBefore,
          'Task "${todoTask.text}" is due next week.');
      scheduleNotification('Task Due Tomorrow', oneDayBefore,
          'Task "${todoTask.text}" is due tomorrow.');
      scheduleNotification('Task Due in 6 Hours', sixHoursBefore,
          'Task "${todoTask.text}" is due within 6 hours.');
      scheduleNotification('Task Almost Due', oneHourBefore,
          'Task "${todoTask.text}" is almost due.');
      scheduleNotification(
          'Task Overdue', dueTime, 'Task "${todoTask.text}" is overdue.');

      // Send a notification for adding the task
      sendReminderNotification('Task Added', 'Added To Do: "${todoTask.text}"');

      // Clear the input field after task addition
      todoTask.text = '';
    } catch (e) {
      print('Error parsing date/time: $e');
      Fluttertoast.showToast(msg: 'Error parsing date/time');
    }
  }

  Future<void> scheduleNotification(
      String title, DateTime scheduledTime, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: scheduledTime.millisecondsSinceEpoch.hashCode,
        channelKey: 'basic_channel', // Replace with your channel key
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
  }

  Future<void> getToDo() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        print('Current user detected: ${user.uid}');
        final todoSnapshot = await FirebaseFirestore.instance
            .collection('todo_list')
            .doc(user.uid) // Fetch using user's UID
            .get();
        final completedSnapshot = await FirebaseFirestore.instance
            .collection('completed_list')
            .doc(user.uid) // Fetch using user's UID
            .get();

        if (todoSnapshot.exists) {
          final _tasksMap = Map<String, dynamic>.from(
            todoSnapshot.data() as Map<String, dynamic>,
          );
          print(_tasksMap);
          final tasksList = _tasksMap.entries.map((entry) {
            final Map<String, dynamic> taskData =
                entry.value as Map<String, dynamic>;
            return TaskModel(
              createdDate: taskData['createdDate'] ?? '',
              deadlineDate: taskData['deadlineDate'] ?? '',
              todoTask: taskData['todoTask'] ?? '',
              todoStatus: taskData['todoStatus'] ?? '',
              dueSoonNotificationSent: taskData['dueSoonNotificationSent'] as bool? ?? false,
              dueTomNotificationSent: taskData['dueTomNotificationSent'] as bool? ?? false,
              dueSixNotificationSent: taskData['dueSixNotificationSent'] as bool? ?? false,
              almostDueNotificationSent: taskData['almostDueNotificationSent'] as bool? ?? false,
              overdueNotificationSent: taskData['overdueNotificationSent'] as bool? ?? false,

            );
          }).toList();

          setState(() {
            todoList = tasksList;
          });
        } else {
          setState(() {
            todoList = [];
          });
        }

        if (completedSnapshot.exists) {
          final cTasksMap = Map<String, dynamic>.from(
            completedSnapshot.data() as Map<String, dynamic>,
          );
          final cTasksList = cTasksMap.entries
              .map((entry) => CompleteTaskModel.fromMap(
                  Map<String, dynamic>.from(entry.value)))
              .toList();

          setState(() {
            completedList = cTasksList;
          });
        } else {
          setState(() {
            completedList = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      // Handle error as needed
    }
  }
}
