import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lpu_app/views/handbook.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/help.dart';

class HandbookMenu extends StatefulWidget {
  const HandbookMenu({Key? key}) : super(key: key);

  @override
  _HandbookMenuState createState() => _HandbookMenuState();
}

class _HandbookMenuState extends State<HandbookMenu> {
  // Define a global variable to store the fetched handbooks
  static List<Map<String, dynamic>> cachedHandbooks = [];

  List<Map<String, dynamic>> handbooks = [];

  // Define a timestamp for the last cache refresh
  DateTime lastCacheRefresh = DateTime(0);

  Future<void> fetchHandbooks() async {
    if (cachedHandbooks.isNotEmpty &&
        DateTime.now().difference(lastCacheRefresh).inMinutes <= 30) {
      // If handbooks are already cached and cache is not expired, use them
      setState(() {
        handbooks = cachedHandbooks;
      });
      return;
    }

    final response =
        await http.get(Uri.parse('http://charlestacda-layag_cms.mdbgo.io/handbooks_view.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        handbooks = data.cast<Map<String, dynamic>>();
        // Cache the fetched handbooks
        cachedHandbooks = handbooks;
        lastCacheRefresh = DateTime.now(); // Update the cache refresh timestamp
      });
    } else {
      throw Exception('Failed to load handbooks');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHandbooks();
  }

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
                Center(
                  child: Column(
                    children: handbooks.map((handbook) {
                      return ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Handbook(
                                handbookTitle: handbook['title'],
                                handbookContent: handbook['content'],
                              ),
                            ),
                          );
                        },
                        child: Text(handbook['title']),
                      );
                    }).toList(),
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
