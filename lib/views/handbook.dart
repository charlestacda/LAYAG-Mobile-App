import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Handbook extends StatelessWidget {
  final String handbookTitle;
  final String handbookContent;

  const Handbook({
    Key? key,
    required this.handbookTitle,
    required this.handbookContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(handbookTitle),
      ),
      body: SfPdfViewer.network(
        'http://charlestacda-layag_cms.mdbgo.io/handbooks/$handbookContent',
        canShowScrollHead: true,
      ),
    );
  }
}
