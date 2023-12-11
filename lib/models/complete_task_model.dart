class CompleteTaskModel {
  String CreatedDate;
  String DeadlineDate;
  String TodoTask;
  String TodoStatus;
  bool DueSoonNotificationSent = false;
  bool DueTomNotificationSent = false;
  bool DueSixNotificationSent = false;
  bool AlmostDueNotificationSent = false;
  bool OverdueNotificationSent = false;

  CompleteTaskModel({
    required this.CreatedDate,
    required this.DeadlineDate,
    required this.TodoTask,
    required this.TodoStatus,
    required this.DueSoonNotificationSent,
    required this.DueTomNotificationSent,
    required this.DueSixNotificationSent,
    required this.AlmostDueNotificationSent,
    required this.OverdueNotificationSent,
  });

  // Add a factory method to create CompleteTaskModel from Firestore data
  factory CompleteTaskModel.fromMap(Map<String, dynamic> map) {
    return CompleteTaskModel(
      CreatedDate: map['CreatedDate'],
      DeadlineDate: map['DeadlineDate'],
      TodoStatus: map['TodoStatus'],
      TodoTask: map['TodoTask'],
      DueSoonNotificationSent: map['DueSoonNotificationSent'],
      DueTomNotificationSent: map['DueTomNotificationSent'],
      DueSixNotificationSent: map['DueSixNotificationSent'],
      AlmostDueNotificationSent: map['AlmostDueNotificationSent'],
      OverdueNotificationSent: map['OverdueNotificationSent'],
    );
  }
}