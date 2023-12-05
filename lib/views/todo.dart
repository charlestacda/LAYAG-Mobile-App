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

  @override
  void initState() {
    super.initState();
    fetchUserID();
    getToDo();
    timeController.text = DateFormat('h:mm a').format(
      DateTime.now().toUtc().add(const Duration(hours: 8)),
    );
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
    DateFormat format = DateFormat('yyyy-MM-dd h:mm a');
    return format.parse(dateString);
  }

  Color _getTaskColor(String deadlineDate) {
    DateTime today = DateTime.now();
    DateTime taskDueDate = getDateTimeFromString(deadlineDate);

    // Calculate the difference in days between today and the task's due date
    int differenceInDays = taskDueDate.difference(today).inDays;

    if (differenceInDays > 2) {
      return Colors.green; // Greater than two days
    } else if (differenceInDays >= 1 && differenceInDays <= 2) {
      return Colors.yellow; // One or two days
    } else {
      return AppConfig.appSecondaryTheme; // Due or less than a day
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
                            try {
                              DateTime selectedDateTime =
                                  DateFormat('yyyy-MM-dd hh:mm a')
                                      .parse('$fDate $fTime');
                              DateTime currentDateTime = DateTime.now();

                              if (selectedDateTime.isBefore(currentDateTime)) {
                                Fluttertoast.showToast(
                                    msg: 'Please select a future Time');
                              } else {
                                addToDo(newID!);
                                setState(() {
                                  todoList.add(TaskModel(
                                    createdDate: DateTime.now().toString() +
                                        ' ' +
                                        TimeOfDay.now().toString(),
                                    deadlineDate: fDate + ' ' + fTime,
                                    todoTask: todoTask.text,
                                    todoStatus: 'Pending',
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
                ListView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    Color taskColor =
                        _getTaskColor(todoList[index].deadlineDate);
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                        title: Text(todoList[index].todoTask),
                        subtitle: Text(todoList[index].deadlineDate),
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
                      'Completed (' + completedList.length.toString() + ')',
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
                              },
                            ),
                          ));
                    }),
              ]),
            ),
          ),
        ),
      );

  void addToDo(String ID) async {
    await _todoreference.doc(ID).set({
      todoTask.text: {
        'todoTask': todoTask.text,
        'createdDate':
            newForm.toString() + ' ' + CreateTimeNow.format(context).toString(),
        'targetDate': fDate.toString() + ' ' + fTime.toString(),
        'todoStatus': 'Pending',
      }
    }, SetOptions(merge: true)).asStream();
    await _notifreference.doc(ID).set({
      'Notifications': {
        todoTask.text: {
          'notifName': todoTask.text,
          'notifTitle': 'Added To Do: ' + todoTask.text
        }
      }
    }, SetOptions(merge: true));
  }

  Future<void> getToDo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final todoSnapshot = await FirebaseFirestore.instance
            .collection('todo_list')
            .doc(user.uid)
            .get();
        final completedSnapshot = await FirebaseFirestore.instance
            .collection('completed_list')
            .doc(user.uid)
            .get();

        if (todoSnapshot.exists) {
          final _tasksMap = Map<String, dynamic>.from(
              todoSnapshot.data() as Map<String, dynamic>);
          final tasksList = _tasksMap.entries
              .map((entry) =>
                  TaskModel.fromMap(Map<String, dynamic>.from(entry.value)))
              .toList();

          setState(() {
            todoList = tasksList; // Update todoList with fetched tasks
          });
        } else {
          setState(() {
            todoList = []; // If no tasks found, set todoList as an empty list
          });
        }

        if (completedSnapshot.exists) {
          final cTasksMap = Map<String, dynamic>.from(
              completedSnapshot.data() as Map<String, dynamic>);
          final cTasksList = cTasksMap.entries
              .map((entry) => CompleteTaskModel.fromMap(
                  Map<String, dynamic>.from(entry.value)))
              .toList();

          setState(() {
            completedList =
                cTasksList; // Update completedList with fetched tasks
          });
        } else {
          setState(() {
            completedList =
                []; // If no completed tasks found, set completedList as an empty list
          });
        }
      } catch (e) {
        print('Error fetching tasks: $e');
        // Handle error as needed
      }
    }
  }
}
