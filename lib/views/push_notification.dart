

// Initialize the notification plugin
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/models/task_model.dart';
import 'package:lpu_app/models/user_model.dart';


late Future<UserModel?> userDetails;
String? userID;
final CollectionReference _notifreference =
      FirebaseFirestore.instance.collection('users');

@override
  void initState() {
    
  }

void fetchUserID() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {

        userID = user.uid;
        userDetails = getUserDetails(user.uid);
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

void initializeNotifications() {
  AwesomeNotifications().initialize(
    'resource://drawable/layag_icon', // Replace 'app_icon' with your app icon name
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: AppConfig.appSecondaryTheme,
        ledColor: Colors.white,
      ),
    ],
  );
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

      if (!task.dueSoonNotificationSent &&
          timeDifferenceInSeconds <= 7 * 24 * 60 * 60 && timeDifferenceInSeconds > 24 * 60 * 60) {
        _notifreference.doc(userID).set({
        'Notifications': {
          '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
            'notifName':'Task Due Soon',
            'notifTitle': 'Task "${task.todoTask}" is due next week.',
          }
        }
      }, SetOptions(merge: true));
        sendReminderNotification(
            'Task Due Soon', 'Task "${task.todoTask}" is due next week.');
            task.dueSoonNotificationSent = true;
      } else if (!task.dueTomNotificationSent &&
          timeDifferenceInSeconds == 24 * 60 * 60) {
        _notifreference.doc(userID).set({
        'Notifications': {
          '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
            'notifName': 'Task Due Tomorrow',
            'notifTitle': 'Task "${task.todoTask}" is due tomorrow.',
          }
        }
      }, SetOptions(merge: true));
        sendReminderNotification(
            'Task Due Tomorrow', 'Task "${task.todoTask}" is due tomorrow.');
        task.dueTomNotificationSent = true;
      } else if (!task.dueSixNotificationSent && timeDifferenceInSeconds == 6 * 60 * 60) {
       _notifreference.doc(userID).set({
        'Notifications': {
          '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
            'notifName': 'Task Due 6 Hours',
            'notifTitle': 'Task "${task.todoTask}" is due within 6 hours.',
          }
        }
      }, SetOptions(merge: true));
      sendReminderNotification(
        'Task Due 6 Hours', 'Task "${task.todoTask}" is due within 6 hours.');
        task.dueSixNotificationSent = true;
      } else if (!task.almostDueNotificationSent &&
          timeDifferenceInSeconds == 60 * 60) {
        _notifreference.doc(userID).set({
        'Notifications': {
          '${task.todoTask}_${DateTime.now().millisecondsSinceEpoch}': {
            'notifName': 'Task Almost Due',
            'notifTitle': 'Task "${task.todoTask}" is almost due.',
          }
        }
      }, SetOptions(merge: true));
        sendReminderNotification(
            'Task Almost Due', 'Task "${task.todoTask}" is almost due.');
        task.almostDueNotificationSent = true;
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
        sendReminderNotification(
            'Task Overdue', 'Task "${task.todoTask}" is overdue.');
        task.overdueNotificationSent = true;
      }
    }
  }