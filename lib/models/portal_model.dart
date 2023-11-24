import 'package:cloud_firestore/cloud_firestore.dart';

class Portal {
  final String id;
  final String title;
  final String link;
  final String color;
  final String imageUrl;
  final DateTime dateAdded; // Changed the type to DateTime
  final DateTime dateEdited; // Changed the type to DateTime
  final bool visibleToEmployees;
  final bool visibleToStudents;
  final bool archived;

  Portal({
    required this.id,
    required this.title,
    required this.link,
    required this.color,
    required this.imageUrl,
    required this.dateAdded,
    required this.dateEdited,
    required this.visibleToEmployees,
    required this.visibleToStudents,
    required this.archived,
  });

  factory Portal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Portal(
      id: snapshot.id,
      title: data['title'],
      link: data['link'],
      color: data['color'],
      imageUrl: data['imageUrl'],
      dateAdded: (data['dateAdded'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      dateEdited: (data['dateEdited'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      visibleToEmployees: data['visibleToEmployees'],
      visibleToStudents: data['visibleToStudents'],
      archived: data['archived'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "link": link,
      "color": color,
      "imageUrl": imageUrl,
      "dateAdded": dateAdded,
      "dateEdited": dateEdited,
      "visibleToEmployees": visibleToEmployees,
      "visibleToStudents": visibleToStudents,
      "archived": archived,
    };
  }
}