import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/models/complete_task_model.dart';
import 'package:lpu_app/models/task_model.dart';
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

class ToDo extends StatefulWidget {
  const ToDo({Key? key}) : super(key: key);

  @override
  ToDoState createState() => ToDoState();
}

class ToDoState extends State<ToDo> {
  final DatabaseReference _todoreference =
      FirebaseDatabase.instance.ref().child('Todo List');
  final DatabaseReference _notifreference =
      FirebaseDatabase.instance.ref().child('Accounts');

  TextEditingController todoTask = TextEditingController();

  dynamic fTime, fDate;
  var startDate = DateTime.now();
  late DateTime date = DateTime.now();
  late TimeOfDay time = TimeOfDay.now();
  TextEditingController timeController = TextEditingController(text: ''); // Ensure it's initialized with an empty string
  TextEditingController dateController = TextEditingController();

  @override
void initState() {
  super.initState();
  timeController.text = DateFormat('h:mm a').format(
    DateTime.now().toUtc().add(const Duration(hours: 8)),
  );
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
      dateController.text = fDate; // Update the text field with the selected date
    });
  },
  decoration: InputDecoration(
    suffixIcon: Icon(Icons.calendar_today, color: AppConfig.appSecondaryTheme),
    hintText: 'Select Date',
  ),
),
TextField(
  controller: timeController,
  onTap: () async {
    TimeOfDay currentTime = TimeOfDay.fromDateTime(
      DateTime.now().toUtc().add(const Duration(hours: 8)),
    );
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (newTime == null) {
      return;
    }

    setState(() {
      time = newTime; // Set the selected time from the picker
      fTime = time.format(context); // Format the selected time for displaying in the TextField
      timeController.text = fTime; // Update the text field with the selected time
    });
  },
  decoration: InputDecoration(
    suffixIcon: Icon(Icons.access_time, color: AppConfig.appSecondaryTheme),
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
      Fluttertoast.showToast(msg: 'Please set task title');
    } else if (fDate == null || fTime == null) {
      Fluttertoast.showToast(msg: 'Please set Date and Time');
    } else {
      try {
        DateTime selectedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse('$fDate $fTime');
        DateTime currentDateTime = DateTime.now();

        if (selectedDateTime.isBefore(currentDateTime)) {
          Fluttertoast.showToast(msg: 'Please select a future Time');
        } else {
          addToDo(newID!);
          setState(() {
            todoList.add(TaskModel(
              createdDate: DateTime.now().toString() + ' ' + TimeOfDay.now().toString(),
              deadlineDate: fDate + ' ' + fTime,
              todoTask: todoTask.text,
              todoStatus: 'Pending',
            ));
          });
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error parsing date/time: $e');
        Fluttertoast.showToast(msg: 'Error parsing date/time');
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
                    return Dismissible(
                      key: ValueKey<TaskModel>(todoList[index]),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          title: Text(todoList[index].todoTask),
                          subtitle: Text(todoList[index].deadlineDate),
                          leading: IconButton(
                            icon: const Icon(Icons.check_box_outline_blank),
                            color: const Color(0xFF606060),
                            onPressed: () async {
                              await FirebaseDatabase.instance
                                  .ref()
                                  .child('Completed List')
                                  .child(userID)
                                  .child(todoList[index].todoTask)
                                  .set({
                                'TodoTask': todoList[index].todoTask,
                                'CreatedDate': newForm.toString() +
                                    ' ' +
                                    CreateTimeNow.format(context).toString(),
                                'TargetDate': todoList[index].deadlineDate,
                                'TodoStatus': 'Completed',
                              });

                              completedList.add(CompleteTaskModel(
                                  CreatedDate: newForm.toString() +
                                      ' ' +
                                      CreateTimeNow.format(context).toString(),
                                  DeadlineDate:
                                      todoList[index].deadlineDate.toString(),
                                  TodoTask: todoList[index].todoTask,
                                  TodoStatus: 'Completed'));

                              await FirebaseDatabase.instance
                                  .ref()
                                  .child('Todo List')
                                  .child(userID)
                                  .child(todoList[index].todoTask)
                                  .remove();

                              setState(() {
                                todoList.removeAt(index);
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
                      return Dismissible(
                          key:
                              ValueKey<CompleteTaskModel>(completedList[index]),
                          child: Card(
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
                                onPressed: () async {
                                  await FirebaseDatabase.instance
                                      .ref()
                                      .child('Todo List')
                                      .child(userID)
                                      .child(completedList[index].TodoTask)
                                      .set({
                                    'todoTask': completedList[index].TodoTask,
                                    'createdDate': newForm.toString() +
                                        ' ' +
                                        CreateTimeNow.format(context)
                                            .toString(),
                                    'targetDate':
                                        completedList[index].DeadlineDate,
                                    'todoStatus': 'Pending',
                                  });

                                  todoList.add(TaskModel(
                                      createdDate: newForm.toString() +
                                          ' ' +
                                          CreateTimeNow.format(context)
                                              .toString(),
                                      deadlineDate:
                                          completedList[index].DeadlineDate,
                                      todoTask: completedList[index].TodoTask,
                                      todoStatus: 'Pending'));

                                  await FirebaseDatabase.instance
                                      .ref()
                                      .child('Completed List')
                                      .child(userID)
                                      .child(completedList[index].TodoTask)
                                      .remove();

                                  setState(() {
                                    completedList.removeAt(index);
                                  });
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                color: const Color(0xff606060),
                                onPressed: () async {
                                  await FirebaseDatabase.instance
                                      .ref()
                                      .child('Completed List')
                                      .child(userID)
                                      .child(completedList[index].TodoTask)
                                      .remove();

                                  setState(() {
                                    completedList.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ));
                    }),
              ]),
            ),
          ),
        ),
      );

  void addToDo(String ID) async {
    await _todoreference.child(ID).child(todoTask.text).set({
      'todoTask': todoTask.text,
      'createdDate':
          newForm.toString() + ' ' + CreateTimeNow.format(context).toString(),
      'targetDate': fDate.toString() + ' ' + fTime.toString(),
      'todoStatus': 'Pending',
    }).asStream();
    await _notifreference
        .child(ID)
        .child('Notifications')
        .child(todoTask.text)
        .set({
      'notifName': todoTask.text,
      'notifTitle': 'Added To Do: ' + todoTask.text
    });
  }
}
