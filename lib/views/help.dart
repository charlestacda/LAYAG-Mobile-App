import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:http/http.dart' as http;

class HelpModel {
  final int helpId;
  final String title;
  final String content;
  final String img;

  HelpModel({
    required this.helpId,
    required this.title,
    required this.content,
    required this.img,
  });
}

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  HelpState createState() => HelpState();
}

Future<List<HelpModel>> fetchHelpData() async {
  final response = await http.get(
    Uri.parse('http://charlestacda-layag_cms.mdbgo.io/helps_view.php'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    final List<HelpModel> helpList = data
        .map((item) => HelpModel(
              helpId: item['help_id'],
              title: item['title'],
              content: item['content'],
              img: item['img'],
            ))
        .toList();
    return helpList;
  } else {
    throw Exception('Failed to load data');
  }
}
class HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
          color: AppConfig.appSecondaryTheme,
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: FutureBuilder<List<HelpModel>>(
        future: fetchHelpData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final helpData = snapshot.data!;
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // "HOW TO USE" text with reduced top padding
                      Padding(
                        padding: const EdgeInsets.only(top: 50), // Reduced padding
                        child: Text(
                          'HOW TO USE',
                          style: TextStyle(
                            fontFamily: 'Futura',
                            color: Color(0xffD94141),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Reduced space
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final item = helpData[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10), // Reduced padding
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (item.img != 'default.png')
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Image.network(
                                'http://charlestacda-layag_cms.mdbgo.io/images/${item.img}',
                                width: double.infinity,
                                height: 400,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10), // Reduced padding
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 15, color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: item.content,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10), // Reduced space
                        ],
                      );
                    },
                    childCount: helpData.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Reduced padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'To know more about LAYAG, please',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              child: const Text(
                                'click here',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppConfig.appSecondaryTheme,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                URL.launch(
                                  'https://drive.google.com/file/d/1mTH-5GG_Zf8QohVUrwwOROdHiArxTmZz/view?usp=sharing');
                              },
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(text: 'for more information.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Text('No data available');
          }
        },
      ),
    );
  }
}
