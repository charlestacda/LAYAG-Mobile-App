import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class HTTPHandler {
  static Future getRequest(String url, Map<String, dynamic> queryParameters) async {
    Response response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(queryParameters),
    );

    if (response.body.isEmpty) {
      return null;
    }

    return json.decode(response.body);
  }

  static Future postRequest(String url, Map<String, dynamic> queryParameters) async {
    await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(queryParameters),
    );
  }

  static Future getHTTPContent(String url) async {
    Response response = await http.get(Uri.parse(url));

    if (response.body.isEmpty) {
      return null;
    }

    return response.body;
  }
}
