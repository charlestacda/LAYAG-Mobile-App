import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Handbook extends StatefulWidget {
  const Handbook({Key? key}) : super(key:key);
  @override
  _PDFViewerAppState createState() => _PDFViewerAppState();
}

class _PDFViewerAppState extends State<Handbook> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Handbook'),
      ),
      body: SfPdfViewer.asset(
        'assets/handbook/LPU_M_SHSGuidebook2018.pdf', // Replace with the path to your PDF file
        canShowScrollHead: true,
      ),
    );
  }
}