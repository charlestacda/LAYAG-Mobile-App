class CompleteTaskModel {
  String CreatedDate, DeadlineDate, TodoTask, TodoStatus;

  CompleteTaskModel({
    required this.CreatedDate,
    required this.DeadlineDate,
    required this.TodoTask,
    required this.TodoStatus,
  });

  static CompleteTaskModel fromMap(Map<String, dynamic> map) {
    return CompleteTaskModel(
      CreatedDate: map['CreatedDate'],
      DeadlineDate: map['TargetDate'],
      TodoStatus: map['TodoStatus'],
      TodoTask: map['TodoTask'],
    );
  }
}
