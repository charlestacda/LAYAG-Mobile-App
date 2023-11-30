import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Handbook extends StatelessWidget {
  final String id;
  final String title;
  final String content;
  final bool visibleToEmployees;
  final bool visibleToStudents;
  final DateTime dateAdded; // Changed the type to DateTime
  final DateTime dateEdited; // Changed the type to DateTime
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
      body: SfPdfViewer.network(
        content,
        canShowScrollHead: true,
      ),
    );
  }
}
