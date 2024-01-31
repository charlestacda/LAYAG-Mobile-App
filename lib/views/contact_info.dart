import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/services.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lpu_app/views/components/app_drawer.dart';
import 'package:lpu_app/views/notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const ContactInfo());

class ContactInfo extends StatelessWidget {
  const ContactInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            // Fetch the current user details
            final user = FirebaseAuth.instance.currentUser;
            return IconButton(
              icon: ClipOval(
                child: user != null && user.photoURL != null
                    ? Image.network(
                        user.photoURL!,
                        width: 24,
                        height: 24,
                      )
                    : Image.asset(
                        'assets/images/user.png',
                        width: 24,
                        height: 24,
                      ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Image.asset('assets/images/lpu_title.png'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const Notifications(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: const _ContactInfo(),
    );
  }
}

class _ContactInfo extends StatefulWidget {
  const _ContactInfo({Key? key}) : super(key: key);

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfo> {
  late Future<List<DocumentSnapshot>> academicDataFetchFuture;
  late Future<List<DocumentSnapshot>> administrativeDataFetchFuture;
  Map<String, Color> expansionTileTextColors = {};

  @override
  void initState() {
    super.initState();
    academicDataFetchFuture = fetchDataFromFirestore('academic');
    administrativeDataFetchFuture = fetchDataFromFirestore('administrative');
  }

  Future<List<DocumentSnapshot>> fetchDataFromFirestore(String unitType) async {
    // Fetch data from Firestore based on unitType
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('contact_info').get();

    if (unitType == 'academic') {
      return snapshot.docs
          .where((doc) => doc['visible'] == true && doc['type'] == 'academic')
          .toList()
        ..sort((a, b) => a['created_on'].compareTo(b['created_on']));
    } else if (unitType == 'administrative') {
      return snapshot.docs
          .where((doc) =>
              doc['visible'] == true && doc['type'] == 'administrative')
          .toList()
        ..sort((a, b) => a['created_on'].compareTo(b['created_on']));
    }

    return [];
  }

  Widget buildExpansionTileCards(List<DocumentSnapshot> data) {
    return Column(
      children: data.map((doc) {
        List<Map<String, dynamic>> contactInfo =
            List<Map<String, dynamic>>.from(doc['contact']);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ExpansionTileCard(
            onExpansionChanged: (expanded) {
              setState(() {
                // Update text color for the expanded tile only
                expansionTileTextColors[doc['name']] =
                    expanded ? Colors.white : Colors.black;
              });
            },
            baseColor: Colors.white,
            expandedColor: AppConfig
                .appSecondaryTheme, // Change this to your desired color
            title: Text(
              doc['name'] ?? '',
              style: TextStyle(
                color: expansionTileTextColors[doc['name']] ?? Colors.black,
              ),
            ),
            children: <Widget>[
              Container(
                color: const Color(0xFFD0D0D0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (contactInfo.any((info) => info['type'] == 'email'))
                          ..._buildContactInfo(
                            'Email:',
                            contactInfo
                                .where((info) => info['type'] == 'email'),
                          ),
                        if (contactInfo
                            .any((info) => info['type'] == 'phone_number'))
                          ..._buildContactInfo(
                            'Phone Number:',
                            contactInfo.where(
                                (info) => info['type'] == 'phone_number'),
                          ),
                        if (contactInfo
                            .any((info) => info['type'] == 'facebook'))
                          ..._buildContactInfo(
                            'Facebook:',
                            contactInfo
                                .where((info) => info['type'] == 'facebook'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Modify the _buildContactInfo method
  List<Widget> _buildContactInfo(
      String label, Iterable<Map<String, dynamic>> infos) {
    List<Widget> widgets = [];

    // Apply the style to the label (header)
    widgets.add(
      Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    );

    if (infos.length == 1) {
      if (infos.first['type'] == 'email') {
        widgets.add(
          InkWell(
            onTap: () => _launchEmail(infos.first['value'], context),
            child: Text(
              infos.first['value'],
              style: TextStyle(
                  color: Colors.blue, // Change color as desired
                  decoration: TextDecoration.underline,
                  fontSize: 16),
            ),
          ),
        );
      } else if (infos.first['type'] == 'phone_number') {
        widgets.add(
          InkWell(
            onTap: () => _launchPhoneNumber(infos.first['value'], context),
            child: Text(
              infos.first['value'],
              style: TextStyle(
                  color: Colors.blue, // Change color as desired
                  decoration: TextDecoration.underline,
                  fontSize: 16),
            ),
          ),
        );
      } else if (infos.first['type'] == 'facebook') {
        widgets.add(
          InkWell(
            onTap: () => _launchFacebook(infos.first['value'], context),
            child: Text(
              infos.first['value'],
              style: TextStyle(
                  color: Colors.blue, // Change color as desired
                  decoration: TextDecoration.underline,
                  fontSize: 16),
            ),
          ),
        );
      } else {
        widgets.add(Text(infos.first['value']));
      }
    } else if (infos.length > 1) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infos
                .map(
                  (info) => InkWell(
                    onTap: () {
                      if (info['type'] == 'email') {
                        _launchEmail(
                            info['value']
                                .substring(info['value'].indexOf(": ") + 2),
                            context);
                      } else if (info['type'] == 'phone_number') {
                        _launchPhoneNumber(
                            info['value']
                                .substring(info['value'].indexOf(": ") + 2),
                            context);
                      } else if (info['type'] == 'facebook') {
                        _launchFacebook(
                            info['value']
                                .substring(info['value'].indexOf(": ") + 2),
                            context);
                      }
                    },
                    child: Text(
                      info['value'],
                      style: TextStyle(
                          color: Colors.blue, // Change color as desired
                          decoration: TextDecoration.underline,
                          fontSize: 16),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return widgets;
  }

  _launchPhoneNumber(String phoneNumber, BuildContext context) async {
    final Uri _phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    final String uriString = _phoneLaunchUri.toString();

    await _showLaunchDialog(phoneNumber, uriString, context);
  }

  _launchEmail(String email, BuildContext context) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    final String uriString = _emailLaunchUri.toString();

    await _showLaunchDialog(email, uriString, context);
  }

  _launchFacebook(String facebookHandle, BuildContext context) async {
    String uriString;
    if (facebookHandle.startsWith('https://bit.ly')) {
      // If the handle is a bit.ly link, use it directly
      uriString = facebookHandle;
    } else {
      // If the handle is a regular handle, construct the Facebook URL
      final String facebookUrl = 'https://www.facebook.com/$facebookHandle';
      uriString = facebookUrl;
    }

    await _showLaunchDialog(uriString, uriString, context);
  }

  Future<void> _showLaunchDialog(
      String text, String uriString, BuildContext context) async {
    TextEditingController textEditingController =
        TextEditingController(text: text.trim());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Contact Us'),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textEditingController,
              readOnly: true, // Make the TextField non-editable
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    // Implement copy to clipboard functionality
                    Clipboard.setData(ClipboardData(text: text));
                    Fluttertoast.showToast(
                      msg: '$text copied to the clipboard',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          color:
                              Colors.black)), // Replace 'Close' with 'Cancel'
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    if (await canLaunchUrl(Uri.parse(uriString))) {
                      await launchUrl(Uri.parse(uriString));
                    } else {
                      throw 'Could not launch URL';
                    }
                  },
                  child: Text('Go'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 30),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/contact_info.png',
                width: double.infinity,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppConfig.appSecondaryTheme,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                'ACADEMIC UNIT \nCONTACT INFO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appWhiteAlphaTheme,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Academic Unit Data
          Container(
            // Set your desired background color
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: academicDataFetchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConfig.appSecondaryTheme),
                  ); // Loading Indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No Data Available');
                } else {
                  return Column(
                    children: <Widget>[
                      buildExpansionTileCards(snapshot.data!),
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppConfig.appSecondaryTheme, // Trapezoid background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                'ADMINISTRATIVE UNIT \nCONTACT INFO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Futura',
                  color: AppConfig.appWhiteAlphaTheme,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Administrative Unit Data
          FutureBuilder<List<DocumentSnapshot>>(
            future: administrativeDataFetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppConfig.appSecondaryTheme),
                ); // Loading Indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No Data Available');
              } else {
                return Column(
                  children: <Widget>[
                    buildExpansionTileCards(snapshot.data!),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
