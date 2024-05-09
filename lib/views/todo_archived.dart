import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lpu_app/models/complete_task_model.dart';
import 'package:lpu_app/models/task_model.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:intl/intl.dart';

class TodoArchivedScreen extends StatefulWidget {
  final VoidCallback? reloadData;

  const TodoArchivedScreen({Key? key, this.reloadData}) : super(key: key);

  @override
  _TodoArchivedScreenState createState() => _TodoArchivedScreenState();
}

class _TodoArchivedScreenState extends State<TodoArchivedScreen> {
  // Define variables for sorting
  String _selectedSortOption = 'Title';
  bool _isAscending = true;
  DateTime? selectedCreatedDateTime;
  DateTime? selectedDeadlineDateTime;
  String _selectedDateType = 'Created Date';
  List<dynamic> _archivedTasks = [];

  // Define sorting options
  List<String> _sortOptions = [
    'Title',
    'Created Date/Time',
    'Deadline Date/Time'
  ];

  Future<List<dynamic>>? _archivedTasksFuture;

  @override
  void initState() {
    super.initState();
    _archivedTasksFuture = fetchArchivedTasks(keyword);
  }

  String keyword = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.reloadData?.call();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Archived Tasks'),
          actions: [
            PopupMenuButton<String>(
              initialValue: _selectedSortOption,
              icon: Icon(Icons.sort), // Change the icon to "sort" icon
              onSelected: (String value) {
                if (_sortOptions.contains(value)) {
                  setState(() {
                    _selectedSortOption = value;
                  });
                } else if (value == 'Ascending') {
                  setState(() {
                    _isAscending = true;
                  });
                } else if (value == 'Descending') {
                  setState(() {
                    _isAscending = false;
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                for (String option in _sortOptions)
                  PopupMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style: TextStyle(
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                    textStyle: TextStyle(
                      color: Colors.black, // Set text color to black
                      fontWeight: option == _selectedSortOption
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'Ascending',
                  child: Text(
                    'Ascending',
                    style: TextStyle(
                      color: _isAscending
                          ? Colors.black
                          : Colors
                              .grey, // Set text color based on sorting order
                    ),
                  ),
                  textStyle: TextStyle(
                    fontWeight:
                        _isAscending ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Descending',
                  child: Text(
                    'Descending',
                    style: TextStyle(
                      color: !_isAscending
                          ? Colors.black
                          : Colors
                              .grey, // Set text color based on sorting order
                    ),
                  ),
                  textStyle: TextStyle(
                    fontWeight:
                        !_isAscending ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.search), // Change the icon to "search" icon
              onPressed: () {
                _showFilterDialog(context);
              },
            ),
          ],
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _archivedTasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty) {
              return Center(child: Text('No archived tasks'));
            } else {
              // Sort tasks based on selected option and order
              List<dynamic> sortedTasks = _sortTasks(snapshot.data!);

              return _buildTaskList(
                  sortedTasks); // Extracted widget for task list
            }
          },
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Initially set the keyword to the current value
    String currentKeyword = keyword;

    // Create a TextEditingController and set its initial value
    TextEditingController textEditingController =
        TextEditingController(text: currentKeyword);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter keywords...',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            // Clear the text field
                            setState(() {
                              textEditingController.clear();
                              currentKeyword = '';
                            });
                          },
                        ),
                      ),
                      // Set the controller to the persistent TextEditingController
                      controller: textEditingController,
                      onChanged: (value) {
                        setState(() {
                          currentKeyword = value.toLowerCase();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel', style: TextStyle(color: AppConfig.appLPUGrayColor)),
            ),
            TextButton(
              onPressed: () {
                // Apply filter logic here
                if (currentKeyword.isEmpty) {
                  keyword = '';
                } else {
                  keyword = currentKeyword;
                }
                _applyFiltersAndReload();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<int>> _getMonthDropdownItems(List<String> months) {
    return months.asMap().entries.map((entry) {
      int index = entry.key + 1; // Month index (1-based)
      String month = entry.value;
      return DropdownMenuItem<int>(
        value: index,
        child: Text(month),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _getYearDropdownItems(List<int> years) {
    return years.map((int year) {
      return DropdownMenuItem<int>(
        value: year,
        child: Text(year.toString()),
      );
    }).toList();
  }

  List<int> _extractArchivedYears() {
    List<int> years = [];
    // Logic to extract archived years from your data
    // For demonstration, I'm assuming a list of integers here
    // Replace this with your actual logic
    for (int i = 2000; i <= 2024; i++) {
      years.add(i);
    }
    return years;
  }

  List<String> _extractArchivedMonths() {
    List<String> months = [];
    // Logic to extract archived months from your data
    // For demonstration, I'm assuming a list of strings here
    // Replace this with your actual logic
    months.addAll([
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ]);
    return months;
  }

  DateTime? _updateDateTime(DateTime? dateTime,
      {int? year, int? month, int? day}) {
    if (dateTime == null) return null;
    return DateTime(
      year ?? dateTime.year,
      month ?? dateTime.month,
      day ?? dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  void _applyFiltersAndReload() {
  setState(() {
    _archivedTasksFuture = fetchArchivedTasks(keyword);
  });

  // Reload the list with the new sorting order if Descending is selected
  if (_selectedSortOption == 'Created Date/Time' ||
      _selectedSortOption == 'Deadline Date/Time') {
    _archivedTasksFuture?.then((tasks) {
  if (!_isAscending) {
    tasks = tasks.reversed.toList(); // Sort archived tasks in descending order
  }
  setState(() {
    _archivedTasks = tasks;
  });
});

  }
}


  void _toggleSortingOrder() {
  setState(() {
    // Toggle the sorting order flag
    _isAscending = !_isAscending;
    // Trigger re-sorting of tasks when the sorting order changes
    _applyFiltersAndReload();
  });
}

  List<dynamic> _sortTasks(List<dynamic> tasks) {
  tasks.sort((a, b) {
    switch (_selectedSortOption) {
      case 'Title':
        return _compareTasksByTitle(a, b);
      case 'Created Date/Time':
        return _compareTasksByCreatedDateTime(a, b);
      case 'Deadline Date/Time':
        return _compareTasksByDeadlineDateTime(a, b);
      default:
        return 0;
    }
  });

  // Reverse the sorted list if descending order is selected
  if (!_isAscending) {
    tasks = tasks.reversed.toList();
  }

  return tasks;
}

  int _compareTasksByTitle(dynamic a, dynamic b) {
    String titleA =
        (a is TaskModel) ? a.todoTask : (a as CompleteTaskModel).TodoTask;
    String titleB =
        (b is TaskModel) ? b.todoTask : (b as CompleteTaskModel).TodoTask;
    return titleA.compareTo(titleB);
  }

  int _compareTasksByCreatedDateTime(dynamic a, dynamic b) {
  DateFormat format = DateFormat("yyyy-MM-dd HH:mm");

  DateTime createdDateTimeA = (a is TaskModel)
      ? format.parse(a.createdDate)
      : format.parse((a as CompleteTaskModel).CreatedDate);
  DateTime createdDateTimeB = (b is TaskModel)
      ? format.parse(b.createdDate)
      : format.parse((b as CompleteTaskModel).CreatedDate);
  return createdDateTimeA.compareTo(createdDateTimeB);
}


int _compareTasksByDeadlineDateTime(dynamic a, dynamic b) {
  DateFormat format = DateFormat("yyyy-MM-dd HH:mm");

  DateTime deadlineDateTimeA = (a is TaskModel)
      ? format.parse(a.deadlineDate)
      : format.parse((a as CompleteTaskModel).DeadlineDate);
  DateTime deadlineDateTimeB = (b is TaskModel)
      ? format.parse(b.deadlineDate)
      : format.parse((b as CompleteTaskModel).DeadlineDate);
  return deadlineDateTimeA.compareTo(deadlineDateTimeB);
}



  Widget _buildCompleteTaskTile(CompleteTaskModel task, BuildContext context) {
  return Column(
    children: [
      ListTile(
        title: Text(task.TodoTask),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Created Date/Time: ${task.CreatedDate}",
                style: TextStyle(fontSize: 12)),
            Text("Deadline Date/Time: ${task.DeadlineDate}",
                style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) async {
            if (value == 'restore') {
              _showRestoreConfirmationDialog(context, task);
            } else if (value == 'delete') {
              _showDeleteConfirmationDialog(context, task);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'restore',
              child: Text('Restore'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
      Divider(), // Add a divider between each task item
    ],
  );
}




Widget _buildTaskTileForTask(TaskModel task, BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(task.todoTask),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Created Date/Time: ${task.createdDate}",
                  style: TextStyle(fontSize: 12)),
              Text("Deadline Date/Time: ${task.deadlineDate}",
                  style: TextStyle(fontSize: 12)),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'restore') {
                _showRestoreConfirmationDialog(context, task);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context, task);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'restore',
                child: Text('Restore'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),
        Divider(), // Add a divider between each task item
      ],
    );
}

Widget _buildTaskTileForCompleteTask(CompleteTaskModel task, BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(task.TodoTask),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Created Date/Time: ${task.CreatedDate}",
                  style: TextStyle(fontSize: 12)),
              Text("Deadline Date/Time: ${task.DeadlineDate}",
                  style: TextStyle(fontSize: 12)),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (String value) async {
              if (value == 'restore') {
                _showRestoreConfirmationDialog(context, task);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context, task);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'restore',
                child: Text('Restore'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ),
        Divider(), // Add a divider between each task item
      ],
    );
}



  Widget _buildTaskList(List<dynamic> tasks) {
  if (_selectedSortOption == 'Title') {
    // Display tasks without expansion tiles
    return _buildTaskListWithoutExpansionTiles(tasks);
  } else if (_selectedSortOption == 'Deadline Date/Time') {
    // Display tasks within expansion tiles sorted by deadline date/time
    return _buildTaskListByDeadlineDateTime(tasks);
  } else if (_selectedSortOption == 'Created Date/Time') {
    // Display tasks within expansion tiles sorted by created date/time
    return _buildTaskListByCreatedDateTime(tasks);
  } else {
    // Default case, display tasks within expansion tiles
    return _buildTaskListWithExpansionTiles(tasks);
  }
}




Widget _buildTaskListWithoutExpansionTiles(List<dynamic> tasks) {
  // Build the list view of task tile cards directly
  return Padding(
    padding: const EdgeInsets.only(top: 8.0), // Add top padding
    child: ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        dynamic task = tasks[index];
        if (task is TaskModel) {
          return _buildTaskTileForTask(task, context);
        } else if (task is CompleteTaskModel) {
          return _buildTaskTileForCompleteTask(task, context);
        } else {
          // Handle other types of tasks or errors
          return Container(); // Placeholder widget, replace with appropriate handling
        }
      },
    ),
  );
}



Widget _buildTaskListWithExpansionTiles(List<dynamic> tasks) {
  // Sort tasks based on the selected option and order
  tasks = _sortTasks(tasks);

  // Group tasks by year, month, and day
  Map<int, Map<int, Map<int, List<dynamic>>>> groupedTasks = {};

  tasks.forEach((task) {
    int year = 0; // Initialize with a default value
    int month = 0; // Initialize with a default value
    int day = 0; // Initialize with a default value

    // Determine the date based on the selected date type
    if (_selectedDateType == 'Created Date') {
      if (task is TaskModel) {
        var format = DateFormat("yyyy-MM-dd hh:mm a");
        var createdDate = format.parse(task.createdDate);
        year = createdDate.year;
        month = createdDate.month;
        day = createdDate.day;
      } else if (task is CompleteTaskModel) {
        var format = DateFormat("yyyy-MM-dd hh:mm a");
        var createdDate = format.parse(task.CreatedDate);
        year = createdDate.year;
        month = createdDate.month;
        day = createdDate.day;
      }
    } else {
      if (task is TaskModel) {
        var deadlineDate = DateTime.parse(task.deadlineDate);
        year = deadlineDate.year;
        month = deadlineDate.month;
        day = deadlineDate.day;
      } else if (task is CompleteTaskModel) {
        var deadlineDate = DateTime.parse(task.DeadlineDate);
        year = deadlineDate.year;
        month = deadlineDate.month;
        day = deadlineDate.day;
      }
    }

    // Group tasks by year, month, and day
    groupedTasks.putIfAbsent(year, () => {});
    groupedTasks[year]!.putIfAbsent(month, () => {});
    groupedTasks[year]![month]!.putIfAbsent(day, () => []);
    groupedTasks[year]![month]![day]!.add(task);
  });

  // Build the list view
  return ListView.builder(
    itemCount: groupedTasks.length,
    itemBuilder: (context, yearIndex) {
      int year = groupedTasks.keys.elementAt(yearIndex);
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ExpansionTile(
          title: Text(year.toString()),
          initiallyExpanded: true, // Open by default
          children: [
            ...groupedTasks[year]!.entries.map((monthEntry) {
              int month = monthEntry.key;
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ExpansionTile(
                  title: Text(DateFormat('MMMM').format(DateTime(year, month))),
                  initiallyExpanded: true, // Open by default
                  children: [
                    ...monthEntry.value.entries.map((dayEntry) {
                      int day = dayEntry.key;
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ExpansionTile(
                          title: Text(day.toString()),
                          initiallyExpanded: true, // Open by default
                          children: dayEntry.value
                            .map((task) {
                              if (task is TaskModel) {
                                return _buildTaskTileForTask(task, context);
                              } else if (task is CompleteTaskModel) {
                                return _buildTaskTileForCompleteTask(task, context);
                              } else {
                                // Handle other types of tasks or errors
                                return Container(); // Placeholder widget, replace with appropriate handling
                              }
                            })
                            .toList(),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

Widget _buildTaskListByCreatedDateTime(List<dynamic> tasks) {
  // Sort all tasks by created date/time
  tasks = _sortTasksByCreatedDateTime(tasks);

  // Group tasks by year, month, and day
  Map<int, Map<int, Map<int, List<dynamic>>>> groupedTasks = {};

  tasks.forEach((task) {
    DateTime createdDateTime = _getTaskCreatedDateTime(task);
    int year = createdDateTime.year;
    int month = createdDateTime.month;
    int day = createdDateTime.day;

    // Group tasks by year, month, and day
    groupedTasks.putIfAbsent(year, () => {});
    groupedTasks[year]!.putIfAbsent(month, () => {});
    groupedTasks[year]![month]!.putIfAbsent(day, () => []);
    groupedTasks[year]![month]![day]!.add(task);
  });

  // Reverse the order if descending sort is selected
  if (!_isAscending) {
    groupedTasks = Map.fromEntries(groupedTasks.entries.toList().reversed);
    groupedTasks.forEach((year, months) {
      groupedTasks[year] = Map.fromEntries(months.entries.toList().reversed);
      months.forEach((month, days) {
        groupedTasks[year]![month] = Map.fromEntries(days.entries.toList().reversed);
      });
    });
  }

  // Rebuild the list view
  return ListView.builder(
    itemCount: groupedTasks.length,
    itemBuilder: (context, yearIndex) {
      int year = groupedTasks.keys.elementAt(yearIndex);
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ExpansionTile(
          title: Text(year.toString()),
          initiallyExpanded: true, // Open by default
          children: [
            ...groupedTasks[year]!.entries.map((monthEntry) {
              int month = monthEntry.key;
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ExpansionTile(
                  title: Text(DateFormat('MMMM').format(DateTime(year, month))),
                  initiallyExpanded: true, // Open by default
                  children: [
                    ...monthEntry.value.entries.map((dayEntry) {
                      int day = dayEntry.key;
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ExpansionTile(
                          title: Text(day.toString()),
                          initiallyExpanded: true, // Open by default
                          children: dayEntry.value
                              .map((task) => _buildTaskTile(task, context))
                              .toList(),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}

Widget _buildTaskTile(dynamic task, BuildContext context) {
  if (task is TaskModel) {
    return _buildTaskTileForTask(task, context);
  } else if (task is CompleteTaskModel) {
    return _buildTaskTileForCompleteTask(task, context);
  } else {
    // Handle other types of tasks or errors
    return Container(); // Placeholder widget, replace with appropriate handling
  }
}


Widget _buildTaskListByDeadlineDateTime(List<dynamic> tasks) {
  // Sort all tasks by deadline date/time
  tasks = _sortTasksByDeadlineDateTime(tasks);

  // Group tasks by year, month, and day
  Map<int, Map<int, Map<int, List<dynamic>>>> groupedTasks = {};

  tasks.forEach((task) {
    DateTime deadlineDateTime = _getTaskDeadlineDateTime(task);
    int year = deadlineDateTime.year;
    int month = deadlineDateTime.month;
    int day = deadlineDateTime.day;

    // Group tasks by year, month, and day
    groupedTasks.putIfAbsent(year, () => {});
    groupedTasks[year]!.putIfAbsent(month, () => {});
    groupedTasks[year]![month]!.putIfAbsent(day, () => []);
    groupedTasks[year]![month]![day]!.add(task);
  });

  // Reverse the order if descending sort is selected
  if (!_isAscending) {
    groupedTasks = Map.fromEntries(groupedTasks.entries.toList().reversed);
    groupedTasks.forEach((year, months) {
      groupedTasks[year] = Map.fromEntries(months.entries.toList().reversed);
      months.forEach((month, days) {
        groupedTasks[year]![month] = Map.fromEntries(days.entries.toList().reversed);
      });
    });
  }

  // Rebuild the list view
  return ListView.builder(
    itemCount: groupedTasks.length,
    itemBuilder: (context, yearIndex) {
      int year = groupedTasks.keys.elementAt(yearIndex);
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ExpansionTile(
          title: Text(year.toString()),
          initiallyExpanded: true, // Open by default
          children: [
            ...groupedTasks[year]!.entries.map((monthEntry) {
              int month = monthEntry.key;
              return Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ExpansionTile(
                  title: Text(DateFormat('MMMM').format(DateTime(year, month))),
                  initiallyExpanded: true, // Open by default
                  children: [
                    ...monthEntry.value.entries.map((dayEntry) {
                      int day = dayEntry.key;
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ExpansionTile(
                          title: Text(day.toString()),
                          initiallyExpanded: true, // Open by default
                          children: dayEntry.value
                              .map((task) => _buildTaskTile(task, context))
                              .toList(),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    },
  );
}



List<dynamic> _sortTasksByCreatedDateTime(List<dynamic> tasks) {
  tasks.sort((a, b) {
    DateTime createdDateTimeA = _getTaskCreatedDateTime(a);
    DateTime createdDateTimeB = _getTaskCreatedDateTime(b);
    return createdDateTimeA.compareTo(createdDateTimeB); // Sort in ascending order
  });
  return tasks;
}

List<dynamic> _sortTasksByDeadlineDateTime(List<dynamic> tasks) {
  tasks.sort((a, b) {
    DateTime deadlineDateTimeA = _getTaskDeadlineDateTime(a);
    DateTime deadlineDateTimeB = _getTaskDeadlineDateTime(b);
    return deadlineDateTimeA.compareTo(deadlineDateTimeB); // Sort in ascending order
  });
  return tasks;
}

DateTime _getTaskCreatedDateTime(dynamic task) {
  if (task is TaskModel) {
    return DateFormat('yyyy-MM-dd hh:mm a').parse(task.createdDate);
  }
  // Handle other cases or return null if appropriate
  return DateTime.now(); // Example return, replace it with appropriate handling
}


DateTime _getTaskDeadlineDateTime(dynamic task) {
  if (task is TaskModel) {
    return DateFormat('yyyy-MM-dd hh:mm a').parse(task.deadlineDate);
  }
  // Handle other cases or return null if appropriate
  return DateTime.now(); // Example return, replace it with appropriate handling
}






  void _showRestoreConfirmationDialog(BuildContext context, dynamic task) {
    String taskName = task is TaskModel
        ? task.todoTask
        : (task as CompleteTaskModel).TodoTask;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Restore", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Are you sure you want to restore the following task?"),
              SizedBox(height: 10),
              Text(
                taskName,
                style: TextStyle(fontWeight: FontWeight.bold,
                color: AppConfig.appLPUYellowColor),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey, // Set the color to grey
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _restoreTask(task);
              },
              child: Text("Restore"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic task) {
    String taskName = task is TaskModel
        ? task.todoTask
        : (task as CompleteTaskModel).TodoTask;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Are you sure you want to permanently delete the following task?"),
              SizedBox(height: 10),
              Text(
                taskName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConfig.appSecondaryTheme),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey, // Set the color to grey
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteTask(task);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(dynamic task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (task is TaskModel) {
          await FirebaseFirestore.instance
              .collection('todo_list')
              .doc(user.uid)
              .update({
            '${task.todoTask}': FieldValue.delete(),
          });
        } else if (task is CompleteTaskModel) {
          await FirebaseFirestore.instance
              .collection('completed_list')
              .doc(user.uid)
              .update({
            '${task.TodoTask}': FieldValue.delete(),
          });
        }

        setState(() {
          _archivedTasksFuture = fetchArchivedTasks(keyword);
        });
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('User not logged in.');
    }
  }

  Future<void> _restoreTask(dynamic task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (task is TaskModel) {
          await FirebaseFirestore.instance
              .collection('todo_list')
              .doc(user.uid)
              .update({
            '${task.todoTask}.todoStatus': 'Pending',
          });
        } else if (task is CompleteTaskModel) {
          await FirebaseFirestore.instance
              .collection('completed_list')
              .doc(user.uid)
              .update({
            '${task.TodoTask}.TodoStatus': 'Completed',
          });
        }

        setState(() {
          _archivedTasksFuture = fetchArchivedTasks(keyword);
        });
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('User not logged in.');
    }
  }
}

Future<List<dynamic>> fetchArchivedTasks(String keyword) async {
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

      List<dynamic> archivedTasks = [];

      if (todoSnapshot.exists) {
        final Map<String, dynamic> todoData =
            todoSnapshot.data() as Map<String, dynamic>;
        archivedTasks.addAll(_extractFilteredTasks<TaskModel>(todoData));
      }

      if (completedSnapshot.exists) {
        final Map<String, dynamic> completedData =
            completedSnapshot.data() as Map<String, dynamic>;
        archivedTasks
            .addAll(_extractFilteredTasks<CompleteTaskModel>(completedData));
      }

      // Apply keyword filter
      if (keyword.isNotEmpty) {
        archivedTasks = archivedTasks.where((task) {
          if (task is TaskModel) {
            return task.todoTask.toLowerCase().contains(keyword);
          } else if (task is CompleteTaskModel) {
            return task.TodoTask.toLowerCase().contains(keyword);
          }
          return false;
        }).toList();
      }

      return archivedTasks;
    } catch (e) {
      print('Error fetching archived tasks: $e');
    }
  }
  return [];
}

List<T> _extractFilteredTasks<T>(Map<String, dynamic> data) {
  List<T> archivedTasks = [];

  if (T == TaskModel) {
    archivedTasks.addAll(data.entries
        .where((entry) =>
            entry.value != null && entry.value['todoStatus'] == 'Archived')
        .map((entry) => TaskModel.fromMap(entry.value))
        .toList() as List<T>);
  } else if (T == CompleteTaskModel) {
    archivedTasks.addAll(data.entries
        .where((entry) =>
            entry.value != null && entry.value['TodoStatus'] == 'Archived')
        .map((entry) => CompleteTaskModel.fromMap(entry.value))
        .toList() as List<T>);
  } else {
    throw ArgumentError('Unsupported type');
  }

  return archivedTasks;
}
