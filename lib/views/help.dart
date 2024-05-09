import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  HelpState createState() => HelpState();
}

class HelpState extends State<Help> {
  late Stream<QuerySnapshot> _helpStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    // Initialize the stream with documents where 'visible' is true and sort by 'order'
    _helpStream = FirebaseFirestore.instance
        .collection('help')
        .where('visible', isEqualTo: true)
        .orderBy('order') // Sorting by 'order' field
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: AppConfig.appSecondaryTheme,
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _helpStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No help documents available'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 50, 40, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'HOW TO USE',
                        style: TextStyle(
                          fontFamily: 'Futura',
                          color: Color(0xffD94141),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                for (var document in snapshot.data!.docs)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (document['title'] != null &&
                            document['title'].toString().isNotEmpty)
                          SelectableText(
                            document['title'],
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        const SizedBox(height: 5),
                        for (var content in document['content'])
                          if (content['type'] == 'image')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: GestureDetector(
                                onTap: () {
                                  // Handle image selection
                                },
                                child: Image.network(
                                  content['value'] as String,
                                  width: double.infinity,
                                  height: 300,
                                ),
                              ),
                            )
                          else if (content['type'] == 'text')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: SelectableText(
                                content['value'] as String,
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(
                              text: 'To know more about LPU-App, please ',
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                child: const Text(
                                  'click here',
                                  style: TextStyle(
                                    color: AppConfig.appSecondaryTheme,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  URL.launch(
                                    'https://drive.google.com/file/d/1mTH-5GG_Zf8QohVUrwwOROdHiArxTmZz/view?usp=sharing',
                                  );
                                },
                              ),
                            ),
                            const TextSpan(
                              text: ' for more information.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
