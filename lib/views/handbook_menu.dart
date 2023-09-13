import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lpu_app/views/handbook.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// Global variable to store cached PDF content
Uint8List? cachedPdfContent;

Future<void> loadAndCachePdf(BuildContext context) async {
  if (cachedPdfContent == null) {
    try {
      // Load the PDF from the asset or network
      final ByteData data = await DefaultAssetBundle.of(context)
          .load('assets/handbook/LPU_M_SHSGuidebook2018.pdf');
      cachedPdfContent = data.buffer.asUint8List();
    } catch (e) {
      // Handle any loading errors here
      print('Error loading PDF: $e');
    }
  }
}

class HandbookMenu extends StatefulWidget {
  const HandbookMenu({Key? key}) : super(key: key);

  @override
  _HandbookMenuState createState() => _HandbookMenuState();
}

class _HandbookMenuState extends State<HandbookMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Help()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/images/handbook.png',
                    width: double.infinity,
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                ),
                Center( // Center the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Load and cache the PDF when the button is pressed
                      loadAndCachePdf(context).then((_) {
                        // Check if PDF content is cached, and navigate to Handbook if available
                        if (cachedPdfContent != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Handbook(),
                            ),
                          );
                        } else {
                          // Handle the case when the PDF content is not cached
                          // You can show a loading indicator or an error message
                        }
                      });
                    },
                    child: Text('View Student Handbook'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
