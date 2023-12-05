import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PaymentContent extends StatelessWidget {
  final Map<String, dynamic> paymentMethod;
  final double itemPadding = 8.0; // Padding between each image

  const PaymentContent({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> contentList = paymentMethod['content'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(paymentMethod['channels'] ?? 'Default Title'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), // Padding around the whole body
        child: ListView.builder(
          itemCount: contentList.length,
          itemBuilder: (context, index) {
            return _buildContentItem(contentList[index]);
          },
        ),
      ),
    );
  }

  Widget _buildContentItem(dynamic content) {
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
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Adjust the value as needed
        child: MarkdownBody(
          data: markdownContent,
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