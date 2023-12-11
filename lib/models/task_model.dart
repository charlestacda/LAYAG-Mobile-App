import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String createdDate;
  String deadlineDate;
  String todoTask;
  String todoStatus;
  bool dueSoonNotificationSent = false;
  bool dueTomNotificationSent = false;
  bool dueSixNotificationSent = false;
  bool almostDueNotificationSent = false;
  bool overdueNotificationSent = false;

  TaskModel({
    required this.createdDate,
    required this.deadlineDate,
    required this.todoTask,
    required this.todoStatus,
    required this.dueSoonNotificationSent,
    required this.dueTomNotificationSent,
    required this.dueSixNotificationSent,
    required this.almostDueNotificationSent,
    required this.overdueNotificationSent,
  });

  // Add a factory method to create TaskModel from Firestore data
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      createdDate: map['createdDate'],
      deadlineDate: map['deadlineDate'],
      todoStatus: map['todoStatus'],
      todoTask: map['todoTask'],
      dueSoonNotificationSent: map['dueSoonNotificationSent'],
      dueTomNotificationSent: map['dueTomNotificationSent'],
      dueSixNotificationSent: map['dueSixNotificationSent'],
      almostDueNotificationSent: map['almostDueNotificationSent'],
      overdueNotificationSent: map['overdueNotificationSent'],
    );
  }
}