import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const ContactInfo());

class ContactInfo extends StatelessWidget {
  const ContactInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
            ),
            color: AppConfig.appSecondaryTheme,
            onPressed: () => Navigator.pop(context, false),
          ),
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
          .where((doc) =>
              doc['visible'] == true && doc['type'] == 'academic')
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
            expandedColor: AppConfig.appSecondaryTheme, // Change this to your desired color
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
                        if (contactInfo.any((info) => info['type'] == 'facebook'))
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


  List<Widget> _buildContactInfo(
    String label, Iterable<Map<String, dynamic>> infos) {
    List<Widget> widgets = [];
    if (infos.length == 1) {
      widgets.addAll([
        SelectableText('$label ${infos.first['value']}'),
      ]);
    } else if (infos.length > 1) {
      widgets.add(SelectableText(label));
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infos
                .map((info) => Text(info['value'],
                      textAlign: TextAlign.left,
                    ))
                .toList(),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              'ACADEMIC UNIT \nCONTACT INFO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Futura',
                color: Color(0xFFD94141),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Academic Unit Data
          FutureBuilder<List<DocumentSnapshot>>(
            future: academicDataFetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppConfig.appSecondaryTheme), ); // Loading Indicator
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
          Center(
            child: Text(
              'ADMINISTRATIVE UNIT \nCONTACT INFO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Futura',
                color: Color(0xFFD94141),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Administrative Unit Data
          FutureBuilder<List<DocumentSnapshot>>(
            future: administrativeDataFetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppConfig.appSecondaryTheme), ); // Loading Indicator
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
