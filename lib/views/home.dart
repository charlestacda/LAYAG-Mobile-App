import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:lpu_app/config/list_config.dart';
import 'package:lpu_app/utilities/url.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/contact_info.dart';
import 'package:lpu_app/views/help.dart';
import 'package:lpu_app/views/payment_procedures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lpu_app/views/borrow_return.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Portal {
  final int id;
  final String title;
  final String link;
  final String color;
  final String img;

  Portal({
    required this.id,
    required this.title,
    required this.link,
    required this.color,
    required this.img,
  });

  factory Portal.fromJson(Map<String, dynamic> json) {
    return Portal(
      id: json['id'],
      title: json['title'],
      link: json['link'],
      color: json['color'],
      img: json['img'],
    );
  }
}

class Tip {
  final int id;
  final String content;

  Tip({
    required this.id,
    required this.content,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      content: json['content'],
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isPopedUp = false;
  Random random = Random();
  int randomNumber = 0;
  List<Portal> portals = [];
  List<String> fetchedTips = [];
  String randomTip = '';

  List<Portal> cachedPortals = [];
  DateTime lastCacheRefresh = DateTime(0);

  @override
  void initState() {
    super.initState();
    randomNumber = random.nextInt(8);
    fetchTips();

    // Check if portals are already cached and cache is expired
    if (cachedPortals.isEmpty || DateTime.now().difference(lastCacheRefresh).inMinutes > 30) {
      fetchPortals(); // Fetch portals if they are not cached or cache is expired (e.g., after 30 minutes)
    }
  }


  Future<void> fetchTips() async {
  try {
    final response = await http.get(
      Uri.parse('http://charlestacda-layag_cms.mdbgo.io/tips_view.php'),
    );

    if (response.statusCode == 200) {
      List<dynamic> tipList = json.decode(response.body);
      List<String> fetchedTipsList =
          tipList.map((json) => json['content'].toString()).toList();
      setState(() {
        fetchedTips = fetchedTipsList; // Populate the fetchedTips list

        if (fetchedTips.isNotEmpty) {
          // Generate a random number within the valid range
          int randomIndex = random.nextInt(fetchedTips.length);
          // Access the random tip
          randomTip = fetchedTips[randomIndex]; // Set the randomTip variable
          
          // Call checkAndShowDialog here, as data has been fetched successfully
          checkAndShowDialog();
        }
      });
    } else {
      print('Failed to load tips: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching tips: $e');
  }
}





void checkAndShowDialog() async {
    // Get the shared preferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if the dialog has been shown before
    bool dialogShown = prefs.getBool('dialogShown') ?? false;
    if (!dialogShown) {
      // If the dialog has not been shown, show it
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Image.asset(
                  'assets/images/register_complete.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            content: Text(
              randomTip,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 22,
                  fontWeight: FontWeight.w600),
            ),
          );
        },
      );          
      prefs.setBool('dialogShown', true);
    }
  }




  Future<void> fetchPortals() async {
    try {
      final response = await http.get(
        Uri.parse('http://charlestacda-layag_cms.mdbgo.io/portals_view.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> portalList = json.decode(response.body);

        List<Portal> fetchedPortals =
            portalList.map((json) => Portal.fromJson(json)).toList();

        setState(() {
          portals = fetchedPortals;
          cachedPortals = fetchedPortals; // Cache the fetched portals
          lastCacheRefresh = DateTime.now(); // Update the cache refresh timestamp
        });
      } else {
        print('Failed to load portals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching portals: $e');
    }
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/images/home_header.png',
              width: double.infinity,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 8.0,
                shrinkWrap: true, // Added this to allow content to wrap its height
                children: portals.map((portal) {
                  Color cardColor = Color(int.parse(portal.color.replaceAll("#", "0xFF")));
                  return GestureDetector(
                    onTap: () {
                      // Open the portal link
                      URL.launch(portal.link);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: portal.img.isNotEmpty
                                    ? Image.network(
                                  'http://charlestacda-layag_cms.mdbgo.io/images/${portal.img}',
                                  fit: BoxFit.contain,
                                )
                                    : SizedBox(), // Check if img is empty
                              ),
                              const SizedBox(height: 16),
                              Text(
                                portal.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
