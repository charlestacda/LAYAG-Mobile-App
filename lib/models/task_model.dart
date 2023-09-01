class TaskModel {
  String createdDate, deadlineDate, todoTask, todoStatus;

  TaskModel({
    required this.createdDate,
    required this.deadlineDate,
    required this.todoTask,
    required this.todoStatus,
  });

  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      createdDate: map['createdDate'],
      deadlineDate: map['targetDate'],
      todoStatus: map['todoStatus'],
      todoTask: map['todoTask'],
    );
  }
}
