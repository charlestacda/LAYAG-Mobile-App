class NotificationModel {
  String notifTitle, notifName;

  NotificationModel({required this.notifTitle, required this.notifName});

  static NotificationModel fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notifTitle: map['notifTitle'],
      notifName: map['notifName'],
    );
  }
}
