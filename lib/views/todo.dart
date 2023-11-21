import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final DatabaseReference _todoreference = FirebaseDatabase.instance.ref().child('Todo List');
  final DatabaseReference _notifreference = FirebaseDatabase.instance.ref().child('Accounts');

  TextEditingController todoTask = TextEditingController();

  dynamic fTime, fDate;
  var startDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    getToDo();
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
          },
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
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
                      controller: TextEditingController(text: '${date.day}/${date.month}/${date.year}'),
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(1900), lastDate: DateTime(2100));

                        if (newDate == null) {
                          return;
                        }

                        setState(() {
                          date = newDate;
                          fDate = date;
                          dynamic dateformatter = DateFormat('yyyy-MM-dd');
                          fDate = dateformatter.format(date);
                        });
                      },
                      decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_month_outlined, color: AppConfig.appSecondaryTheme)),
                    ),
                    TextField(
                      controller: TextEditingController(
                        text: '${time.hour}:${time.minute}',
                      ),
                      onTap: () async {
                        TimeOfDay? newTime = await showTimePicker(
                          context: context,
                          initialTime: time,
                        );

                        if (newTime == null) {
                          return;
                        }

                        setState(() {
                          time = newTime;
                          fTime = time.format(context);
                        });
                      },
                      decoration: const InputDecoration(suffixIcon: Icon(Icons.schedule_outlined, color: AppConfig.appSecondaryTheme)),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        final newTodo = FirebaseAuth.instance.currentUser;
                        final newID = newTodo?.uid;

                        if (todoTask.text.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please set task title');
                        } else if (fDate == null || fTime == null) {
                          Fluttertoast.showToast(msg: 'Please set Date and Time');
                        } else if (fDate.toString().compareTo(newForm.toString()) == 0) {
                          if (fTime.toString().compareTo(CreateTimeNow.format(context).toString()) < 1) {
                            Fluttertoast.showToast(msg: 'Please select time properly');
                          } else if (fTime.toString().compareTo(CreateTimeNow.format(context).toString()) == 0) {
                            Fluttertoast.showToast(msg: 'Please select time properly');
                          } else if (fTime.toString().compareTo(CreateTimeNow.format(context).toString()) > -1) {
                            addToDo(newID!);
                            setState(() {
                              todoList.add(TaskModel(createdDate: DateTime.now().toString() + ' ' + TimeOfDay.now().toString(), deadlineDate: fDate + ' ' + fTime, todoTask: todoTask.text, todoStatus: 'Pending'));
                            });
                            Navigator.of(context).pop();
                          } else {
                            Fluttertoast.showToast(msg: 'Error');
                          }
                        } else if (fDate.toString().compareTo(newForm.toString()) < 0) {
                          Fluttertoast.showToast(msg: 'Please dont enter Date lower than the Date today');
                        } else if (fDate.toString().compareTo(newForm.toString()) > -1) {
                          addToDo(newID!);
                          setState(() {
                            todoList.add(TaskModel(createdDate: DateTime.now().toString() + ' ' + TimeOfDay.now().toString(), deadlineDate: fDate + ' ' + fTime, todoTask: todoTask.text, todoStatus: 'Pending'));
                          });
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(msg: 'Error');
                        }
                      },
                      child: const Text('Add')),
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
                  return Dismissible(
                      key: ValueKey<TaskModel>(todoList[index]),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          title: Text(todoList[index].todoTask),
                          subtitle: Text(todoList[index].deadlineDate),
                          leading: IconButton(
                            icon: const Icon(Icons.check_box_outline_blank),
                            color: const Color(0xFF606060),
                            onPressed: () async {
                              await FirebaseDatabase.instance.ref().child('Completed List').child(userID).child(todoList[index].todoTask).set({
                                'TodoTask': todoList[index].todoTask,
                                'CreatedDate': newForm.toString() + ' ' + CreateTimeNow.format(context).toString(),
                                'TargetDate': todoList[index].deadlineDate,
                                'TodoStatus': 'Completed',
                              });

                              completedList.add(CompleteTaskModel(CreatedDate: newForm.toString() + ' ' + CreateTimeNow.format(context).toString(), DeadlineDate: todoList[index].deadlineDate.toString(), TodoTask: todoList[index].todoTask, TodoStatus: 'Completed'));

                              await FirebaseDatabase.instance.ref().child('Todo List').child(userID).child(todoList[index].todoTask).remove();

                              setState(() {
                                todoList.removeAt(index);
                              });
                            },
                          ),
                          trailing: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              color: AppConfig.appSecondaryTheme,
                            ),
                            width: 35,
                            height: 56,
                          ),
                        ),
                      ));
                }),
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
                      key: ValueKey<CompleteTaskModel>(completedList[index]),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          title: Text(
                            completedList[index].TodoTask,
                            style: const TextStyle(color: Color(0xFF8C0001), decoration: TextDecoration.lineThrough),
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
                              await FirebaseDatabase.instance.ref().child('Todo List').child(userID).child(completedList[index].TodoTask).set({
                                'todoTask': completedList[index].TodoTask,
                                'createdDate': newForm.toString() + ' ' + CreateTimeNow.format(context).toString(),
                                'targetDate': completedList[index].DeadlineDate,
                                'todoStatus': 'Pending',
                              });

                              todoList.add(TaskModel(createdDate: newForm.toString() + ' ' + CreateTimeNow.format(context).toString(), deadlineDate: completedList[index].DeadlineDate, todoTask: completedList[index].TodoTask, todoStatus: 'Pending'));

                              await FirebaseDatabase.instance.ref().child('Completed List').child(userID).child(completedList[index].TodoTask).remove();

                              setState(() {
                                completedList.removeAt(index);
                              });
                            },
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            color: const Color(0xff606060),
                            onPressed: () async {
                              await FirebaseDatabase.instance.ref().child('Completed List').child(userID).child(completedList[index].TodoTask).remove();

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
      'createdDate': newForm.toString() + ' ' + CreateTimeNow.format(context).toString(),
      'targetDate': fDate.toString() + ' ' + fTime.toString(),
      'todoStatus': 'Pending',
    }).asStream();
    await _notifreference.child(ID).child('Notifications').child(todoTask.text).set({'notifName': todoTask.text, 'notifTitle': 'Added To Do: ' + todoTask.text});
  }
}

Future getToDo() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userID = user.uid;
    todoList.clear();
    completedList.clear();
    DatabaseReference referenceData = await FirebaseDatabase.instance.ref().child('Todo List').child(userID);
    referenceData.get().then((snapshot) {
      if (snapshot.exists) {
        final _tasksMap = Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        _tasksMap.forEach((key, value) {
          final tasks = TaskModel.fromMap(Map<String, dynamic>.from(value));
          todoList.add(tasks);
        });
      }
    });
    DatabaseReference cReferenceData = await FirebaseDatabase.instance.ref().child('Completed List').child(userID);
    cReferenceData.get().then((csnapshot) {
      if (csnapshot.exists) {
        final cTasksMap = Map<dynamic, dynamic>.from(csnapshot.value as Map<dynamic, dynamic>);
        cTasksMap.forEach((ckey, cvalue) {
          final cTasks = CompleteTaskModel.fromMap(Map<String, dynamic>.from(cvalue));
          completedList.add(cTasks);
        });
      }
    });
  }
}