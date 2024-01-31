import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lpu_app/utilities/webviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class PaymentContent extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final double itemPadding = 8.0; // Padding between each image

  const PaymentContent({Key? key, required this.paymentMethod})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> contentList = paymentMethod['content'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(paymentMethod['channels'] ?? 'Default Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
            20, 0, 20, 0), // Padding around the whole body
        child: ListView.builder(
          itemCount: contentList.length,
          itemBuilder: (context, index) {
            return _buildContentItem(context, contentList[index]);
          },
        ),
      ),
    );
  }

  Widget _buildContentItem(BuildContext context, dynamic content) {
    if (content is Map<String, dynamic>) {
      if (content['type'] == 'image' && content['value'] is String) {
        // If content is an image type, display the image from Firebase Storage
        String imageUrl = content['value'];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: itemPadding),
          child: Image.network(
            imageUrl,
            // Remove BoxFit.cover to display the image without cropping
          ),
        );
      } else if (content['type'] == 'headline' && content['value'] is String) {
        // If content is of type 'headline', display the text in a specific style
        String headlineText = content['value'];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
          child: Center(
            child: Text(
              headlineText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Futura',
                color: Color(0xffD94141),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      } else if (content['type'] == 'text' && content['value'] is String) {
        String markdownContent = content['value'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: MarkdownBody(
            selectable: true,
            data: markdownContent,
            onTapLink: (String text, String? href, String title) async {
              if (Uri.tryParse(href ?? '') != null) {
                if (paymentMethod['channels'] == 'GCash') {
                  if (content['type'] == 'text' &&
                      href == 'com.globe.gcash.android') {
                    // If content is in bold, try to open the GCash app using its package name
                    LaunchApp.openApp(
                      androidPackageName: 'com.globe.gcash.android',
                    );
                  } else {
                    // Open default email app with the link as the to address
                    await launchUrl((Uri.parse('$href')));
                  }
                } else {
                  // Open the WebViewer for other types of links
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewer(
                        initialUrl: href!,
                        pageTitle: paymentMethod['channels'],
                        type: '#00a62d',
                      ),
                    ),
                  );
                }
              } else {
                // Handle other types of links or invalid URLs
              }
            },
            styleSheet: MarkdownStyleSheet(
              // Define the styles for Markdown elements
              p: TextStyle(fontSize: 18.0), // Example style for paragraphs
              // Add more styles for different Markdown elements as needed
            ),
          ),
        );
      }
    }

    // Handle other content types or invalid data as needed
    return SizedBox(); // Return an empty widget for invalid content or other types
  }
}
