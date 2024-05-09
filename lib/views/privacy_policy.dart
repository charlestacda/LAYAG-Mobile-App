import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lpu_app/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  PrivacyPolicyState createState() => PrivacyPolicyState();
}

class PrivacyPolicyState extends State<PrivacyPolicy> {
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('privacy_policy')
            .doc('pnyMVFNjEtYqOwxzg7Go') // Replace 'document' with your specific document ID
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          final bool isVisible = data?['visible'] ?? false;
          String privacyPolicyContent = data?['content'] ?? '';

          if (!isVisible) {
            return Center(
              child: Text(
                'Privacy Policy is not available.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        'PRIVACY POLICY',
                        style: TextStyle(
                          fontFamily: 'Futura',
                          color: Color(0xffD94141),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    privacyPolicyContent.isNotEmpty
                        ? MarkdownBody(
                          selectable: true,
                            data: privacyPolicyContent,
                            styleSheet: MarkdownStyleSheet(
                              
                            ),
                          onTapLink: (text, href, title) {
                              // Handle link taps
                              launchLink(href!);
                            },
                          )
                        : CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Future<void> launchLink(String url) async {
    if (await canLaunchUrl (Uri.parse(url))) {
      await launchUrl (Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
