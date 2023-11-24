import 'package:cloud_firestore/cloud_firestore.dart';

class Tip {
  final String id;
  final String content;
  final DateTime dateAdded; 
  final DateTime dateEdited; 
  final bool visibleToEmployees;
  final bool visibleToStudents;
  final bool archived;

  Tip({
    required this.id,
    required this.content,
    required this.dateAdded,
    required this.dateEdited,
    required this.visibleToEmployees,
    required this.visibleToStudents,
    required this.archived,
  });

  factory Tip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Tip(
      id: snapshot.id,
      content: data['content'],
      dateAdded: (data['dateAdded'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      dateEdited: (data['dateEdited'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      visibleToEmployees: data['visibleToEmployees'],
      visibleToStudents: data['visibleToStudents'],
      archived: data['archived'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "content": content,
      "dateAdded": dateAdded,
      "dateEdited": dateEdited,
      "visibleToEmployees": visibleToEmployees,
      "visibleToStudents": visibleToStudents,
      "archived": archived,
    };
  }
}