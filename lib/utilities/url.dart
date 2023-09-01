import 'package:url_launcher/url_launcher.dart';

class URL {
  static launch(String url) async {
    var urlToLaunch = Uri.parse(url);

    if (await canLaunchUrl(urlToLaunch)) {
      await launchUrl(urlToLaunch);
    }
  }
}
