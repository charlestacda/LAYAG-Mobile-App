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
import 'package:permission_handler/permission_handler.dart';

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

  bool _isLoading = false;

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

  void sortTodoListByDeadline() {
    todoList.sort((a, b) {
      DateTime deadlineA = getDateTimeFromString(a.deadlineDate);
      DateTime deadlineB = getDateTimeFromString(b.deadlineDate);
      return deadlineA.compareTo(deadlineB);
    });
  }

// Function to sort completedList based on the deadlineDate
  void sortCompletedListByDeadline() {
    completedList.sort((a, b) {
      DateTime deadlineA = getDateTimeFromString(a.DeadlineDate);
      DateTime deadlineB = getDateTimeFromString(b.DeadlineDate);
      return deadlineA.compareTo(deadlineB);
    });
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
    try {
      return DateFormat('yyyy-MM-dd hh:mm a').parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
      // Handle the error as needed
      return DateTime.now(); // Return current date and time in case of an error
    }
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

  void removeTodoTask(int index) async {
    try {
      // Store the information that needs to be deleted
      final taskToRemove = todoList[index];

      // Remove the card immediately from the UI
      setState(() {
        todoList.removeAt(index);
      });

      // Delete the stored information from the `completed_list` collection in Firestore
      await firestore.collection('todo_list').doc(userID).update({
        taskToRemove.todoTask: FieldValue.delete(),
      }).then((_) {
        // Successfully deleted from Firestore
      }).catchError((error) {
        // Handle error while deleting from Firestore
        setState(() {
          // Add the task back to the list if deletion from Firestore fails
          todoList.insert(index, taskToRemove);
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
            List<String> existingTasks =
                todoList.map((task) => task.todoTask).toList();

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
                          decoration:
                              const InputDecoration(labelText: 'Task Name'),
                        ),
                        TextField(
                          controller: dateController,
                          readOnly: true,
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
                            labelText: 'Deadline Date',
                            suffixIcon: Icon(Icons.calendar_today,
                                color: AppConfig.appSecondaryTheme),
                            hintText: 'Select Date',
                          ),
                        ),
                        TextField(
                          controller: timeController,
                          readOnly: true,
                          onTap: () async {
                            TimeOfDay currentTime = TimeOfDay.fromDateTime(
                              DateTime.now()
                                  .toUtc()
                                  .add(const Duration(hours: 8)),
                            );
                            TimeOfDay? newTime = await showTimePicker(
                              context: context,
                              initialTime: currentTime,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context)
                                      .copyWith(alwaysUse24HourFormat: false),
                                  child: child!,
                                );
                              },
                            );

                            if (newTime == null) {
                              return;
                            }

                            setState(() {
                              time = newTime;

                              // Create a DateTime object for the selected time
                              DateTime selectedDateTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                time.hour,
                                time.minute,
                              );

                              // Format the TimeOfDay object to match the 12-hour time format 'h:mm a'
                              fTime = DateFormat('h:mm a').format(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  time.hour,
                                  time.minute,
                                ),
                              );

                              timeController.text =
                                  fTime; // Update the text field with the selected time
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Deadline Time',
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
                          Navigator.of(context)
                              .pop(); // Close the dialog without adding
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey, // Set the color to grey
                          ),
                        ),
                      ),
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
                          } else if (existingTasks.contains(todoTask.text)) {
                            Fluttertoast.showToast(msg: 'Task already exists');
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
                                  sortTodoListByDeadline();
                                  sortCompletedListByDeadline();
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
                        borderRadius: BorderRadius.circular(4),
                      ),
                      color: taskColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        title: Text(
                          todoList[index].todoTask,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          todoList[index].deadlineDate,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.check_box_outline_blank),
                          color: Colors.white,
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

                            sortTodoListByDeadline();
                            sortCompletedListByDeadline();
                          },
                        ),
                        trailing: PopupMenuButton<String>(
                          icon:
                              const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (String value) {
                            if (value == 'edit') {
                              // Show dialog for editing task
                              _showEditDialog(context, todoList[index]);
                            } else if (value == 'delete'){
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                              'Are you sure you want to delete the following task?'),
                                          const SizedBox(height: 10),
                                          Text(todoTask.text,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                            todoList[index].todoTask,
                                            style: const TextStyle(
                                                color: AppConfig
                                                    .appSecondaryTheme),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors
                                                  .grey, // Set the color to grey
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            cancelScheduledNotifications(
                                                todoList[index].todoTask);
                                            removeTodoTask(index);
                                            sortTodoListByDeadline();
                                            sortCompletedListByDeadline();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            // Add other options if needed
                          ],
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
                                sortTodoListByDeadline();
                                sortCompletedListByDeadline();
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              color: const Color(0xff606060),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                              'Are you sure you want to delete the following task?'),
                                          const SizedBox(height: 10),
                                          Text(todoTask.text,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                            completedList[index].TodoTask,
                                            style: const TextStyle(
                                                color: AppConfig
                                                    .appSecondaryTheme),
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors
                                                  .grey, // Set the color to grey
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            cancelScheduledNotifications(
                                                completedList[index].TodoTask);
                                            removeCompletedTask(index);
                                            sortTodoListByDeadline();
                                            sortCompletedListByDeadline();
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
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
    await AwesomeNotifications().cancelAll();
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

      // Schedule notifications for each date with unique IDs
      scheduleNotification('Task Due Soon', 'id_1', oneWeekBefore,
          'Task "${todoTask.text}" is due next week.', todoTask.text);
      scheduleNotification('Task Due Tomorrow', 'id_2', oneDayBefore,
          'Task "${todoTask.text}" is due tomorrow.', todoTask.text);
      scheduleNotification('Task Due in 6 Hours', 'id_3', sixHoursBefore,
          'Task "${todoTask.text}" is due within 6 hours.', todoTask.text);
      scheduleNotification('Task Almost Due', 'id_4', oneHourBefore,
          'Task "${todoTask.text}" is almost due.', todoTask.text);
      scheduleNotification('Task Overdue', 'id_5', dueTime,
          'Task "${todoTask.text}" is overdue.', todoTask.text);

      // Send a notification for adding the task
      sendReminderNotification('Task Added', 'Added To Do: "${todoTask.text}"');

      // Clear the input field after task addition
      todoTask.text = '';
    } catch (e) {
      print('Error parsing date/time: $e');
      Fluttertoast.showToast(msg: 'Error parsing date/time');
    }
  }

  _showEditDialog(BuildContext context, TaskModel task) {
    TextEditingController taskController =
        TextEditingController(text: task.todoTask);
    String prevTask = task.todoTask;
    DateTime selectedDate = getDateTimeFromString(task.deadlineDate);
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    TextEditingController dateController = TextEditingController(
      text: formattedDate(selectedDate),
    );

    TextEditingController timeController = TextEditingController(
      text: formattedTime(selectedTime),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit To Do Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text = formattedDate(
                            selectedDate); // Update the date field text
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Deadline Date',
                        suffixIcon: Icon(Icons.calendar_today,
                            color: AppConfig.appSecondaryTheme),
                      ),
                      controller: dateController,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null && pickedTime != selectedTime) {
                      setState(() {
                        selectedTime = pickedTime;
                        timeController.text = formattedTime(
                            selectedTime); // Update the time field text
                      });
                    }
                  },
                  child: IgnorePointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Deadline Time',
                        suffixIcon: Icon(Icons.access_time,
                            color: AppConfig.appSecondaryTheme),
                      ),
                      controller: timeController,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey, // Set the color to grey
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                String? userId = userID; // Replace with actual user ID
                String taskId = prevTask; // Replace with actual task ID
                String newTaskText = taskController
                    .text; // Get the text from the TextEditingController
                String editedDeadlineDateTime =
                    formattedDateTime(selectedDate, selectedTime);
                Navigator.of(context).pop();
                cancelScheduledNotifications(taskId);
                updateTaskDetailsInFirestore(
                    userId!, taskId, newTaskText, editedDeadlineDateTime);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateTaskDetailsInFirestore(String userId, String taskId,
      String newTaskText, String editedDeadlineDateTime) async {
    try {
      // Show loading dialog
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing while updating
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Updating...'),
              ],
            ),
          );
        },
      );
      DateTime selectedDateTime =
          DateFormat('yyyy-MM-dd h:mm a').parse(editedDeadlineDateTime);
      DocumentReference taskRef =
          FirebaseFirestore.instance.collection('todo_list').doc(userId);
      DocumentSnapshot userDocSnapshot = await taskRef.get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData =
            userDocSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic>? taskData =
            userData[taskId] as Map<String, dynamic>?;

        if (taskData != null) {
          // Remove the old entry with the old ID
          userData.remove(taskId);

          // Create a new entry with the new ID (newTaskText)
          userData[newTaskText] = {
            'todoTask': newTaskText,
            'deadlineDate': editedDeadlineDateTime,
            'todoStatus': 'Pending',
            'dueSoonNotificationSent': false,
            'dueTomNotificationSent': false,
            'dueSixNotificationSent': false,
            'almostDueNotificationSent': false,
            'overdueNotificationSent': false,
            // Other fields if needed
          };

          // Update the Firestore document with the modified data
          await taskRef.set(userData);
        }

        // Calculate dates for notifications
        DateTime oneWeekBefore = selectedDateTime.subtract(Duration(days: 7));
        DateTime oneDayBefore = selectedDateTime.subtract(Duration(days: 1));
        DateTime sixHoursBefore = selectedDateTime.subtract(Duration(hours: 6));
        DateTime oneHourBefore = selectedDateTime.subtract(Duration(hours: 1));
        DateTime dueTime = selectedDateTime;

        print('Sample: $sixHoursBefore');

        // Schedule notifications for each date with unique IDs
        scheduleNotification('Task Due Soon', 'id_1', oneWeekBefore,
            'Task "$newTaskText" is due next week.', newTaskText);
        scheduleNotification('Task Due Tomorrow', 'id_2', oneDayBefore,
            'Task "$newTaskText" is due tomorrow.', newTaskText);
        scheduleNotification('Task Due in 6 Hours', 'id_3', sixHoursBefore,
            'Task "$newTaskText" is due within 6 hours.', newTaskText);
        scheduleNotification('Task Almost Due', 'id_4', oneHourBefore,
            'Task "$newTaskText" is almost due.', newTaskText);
        scheduleNotification('Task Overdue', 'id_5', dueTime,
            'Task "$newTaskText" is overdue.', newTaskText);
      }
      await getToDo();
      Navigator.of(context).pop();
    } catch (error) {
      print('Error updating task: $error');

      setState(() {
        _isLoading = false; // Close loading dialog on error
      });
      print('Error updating task: $error');

      // Close the loading dialog if an error occurs
      Navigator.of(context, rootNavigator: true).pop();

      // Show an error message to the user if needed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update task. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String formattedDateTime(DateTime date, TimeOfDay time) {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String formattedTime = formatTimeOfDay(time);
      return '$formattedDate $formattedTime';
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    try {
      String period = time.period == DayPeriod.am ? 'AM' : 'PM';
      int hour = time.hourOfPeriod;
      int minute = time.minute;
      // Adjust the hour to 12-hour format without leading zero
      hour = hour == 0 ? 12 : hour; // Handle 12 AM
      String formatted = '${hour}:${minute.toString().padLeft(2, '0')} $period';
      return formatted;
    } catch (e) {
      print('Error formatting time: $e');
      return '';
    }
  }

  String formattedDate(DateTime date) {
    try {
      // Format the DateTime object for displaying just the date
      return DateFormat('yyyy-MM-dd').format(date);
      // Adjust the date format according to your requirements
    } catch (e) {
      print('Error formatting date: $e');
      // Handle the error as needed
      return ''; // Return empty string in case of an error
    }
  }

  String formattedTime(TimeOfDay time) {
    try {
      String period = time.period == DayPeriod.am ? 'AM' : 'PM';
      int hour = time.hourOfPeriod;
      int minute = time.minute;

      // Adjust the hour to 12-hour format
      if (hour == 0) {
        hour = 12; // 12 AM
      } else if (hour > 12) {
        hour -= 12; // Convert to 12-hour format for PM hours
      }

      // Create a formatted string in 12-hour format (h:mm AM/PM)
      String formatted = '${hour}:${minute.toString().padLeft(2, '0')} $period';

      return formatted;
      // Adjust the time format according to your requirements
    } catch (e) {
      print('Error formatting time: $e');
      // Handle the error as needed
      return ''; // Return empty string in case of an error
    }
  }

  Future<void> scheduleNotification(String title, String id,
      DateTime scheduledTime, String body, String group) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id.hashCode,
        channelKey: 'basic_channel', // Replace with your channel key
        groupKey: group,
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );
    print("Schedule group: $id");
  }

  Future<void> cancelScheduledNotifications(String groupKey) async {
    try {
      // Cancel notifications based on the provided string ID
      await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
      print("Cancelled notifications with group key: $groupKey");

      // Fetch documents from Firestore based on the provided string ID
      QuerySnapshot querySnapshot = await _notifreference.get();
      List<QueryDocumentSnapshot> notifications = querySnapshot.docs;

      for (QueryDocumentSnapshot doc in notifications) {
        String docId = doc.id;
        if (docId.startsWith(groupKey)) {
          await _notifreference.doc(docId).delete();
        }
      }
    } catch (e) {
      print('Error cancelling notifications: $e');
      // Handle the error as per your application's requirements
    }
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
              dueSoonNotificationSent:
                  taskData['dueSoonNotificationSent'] as bool? ?? false,
              dueTomNotificationSent:
                  taskData['dueTomNotificationSent'] as bool? ?? false,
              dueSixNotificationSent:
                  taskData['dueSixNotificationSent'] as bool? ?? false,
              almostDueNotificationSent:
                  taskData['almostDueNotificationSent'] as bool? ?? false,
              overdueNotificationSent:
                  taskData['overdueNotificationSent'] as bool? ?? false,
            );
          }).toList();

          setState(() {
            todoList = tasksList;
            sortTodoListByDeadline(); // Sort todoList after setting state
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
            sortCompletedListByDeadline(); // Sort completedList after setting state
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
