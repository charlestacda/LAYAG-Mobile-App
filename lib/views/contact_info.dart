import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lpu_app/config/app_config.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

void main() => runApp(const ContactInfo());

class ContactInfo extends StatelessWidget {
  const ContactInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _ContactInfo extends StatefulWidget {
  const _ContactInfo({Key? key}) : super(key: key);

  @override
  _ContactInfoState createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfo> {
  List<dynamic> academicContacts = [];
  List<dynamic> administrativeContacts = [];

  TextStyle titleStyle = TextStyle(
    fontFamily: 'Futura',
    color: Color(0xFFD94141),
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  TextStyle unitNameStyle = TextStyle(
    // Define a different style for unit_name
    fontSize: 16, // Adjust the font size
  );

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final response = await http.get(
      Uri.parse('http://charlestacda-layag_cms.mdbgo.io/contacts_view.php'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        academicContacts = data.where((contact) => contact['unit_type'] == 'Academic').toList();
        administrativeContacts = data.where((contact) => contact['unit_type'] == 'Administrative').toList();
      });
    }
  }

  Widget buildExpansionTileCard(String title, List<dynamic> contacts) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(30),
          width: double.infinity,
          child: Center(
            child: Text(
              title,
              style: titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        ...contacts.map((contact) {
          return ExpansionTileCard(
            baseColor: Colors.white,
            expandedColor: AppConfig.appSecondaryTheme,
            title: Text(contact['unit_name'], style: unitNameStyle), // Apply unitNameStyle to unit_name
            children: <Widget>[
              Container(
                color: const Color(0xFFD0D0D0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(contact['unit_contact']),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Container( // Container for "ACADEMIC UNIT CONTACT INFO"
                width: double.infinity,
                child: buildExpansionTileCard("ACADEMIC UNIT CONTACT INFO", academicContacts),
              ),
              SizedBox(height: 20), // Add some space between the two sections
              Container( // Container for "ADMINISTRATIVE UNIT CONTACT INFO"
                width: double.infinity,
                child: buildExpansionTileCard("ADMINISTRATIVE UNIT CONTACT INFO", administrativeContacts),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
