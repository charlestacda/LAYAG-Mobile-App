import 'package:flutter/material.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

class Handbook extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final bool visibleToEmployees;
  final bool visibleToStudents;
  final DateTime dateAdded;
  final DateTime dateEdited;
  final bool archived;

  Handbook({
    required this.id,
    required this.title,
    required this.content,
    required this.dateAdded,
    required this.dateEdited,
    required this.visibleToEmployees,
    required this.visibleToStudents,
    required this.archived,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
        future: openHandbookContent(content),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load handbook content'));
          } else {
            return Container(); // Display PDF using PDFtron's viewer
          }
        },
      ),
    );
  }

  Future<void> openHandbookContent(String content) async {
    try {
      // Open the handbook content using PDFtron's viewer
      await PdftronFlutter.openDocument(content);
    } catch (e) {
      // Handle failure to open the handbook content
      print('Failed to open handbook content: $e');
      throw Exception('Failed to open handbook content');
    }
  }
}
