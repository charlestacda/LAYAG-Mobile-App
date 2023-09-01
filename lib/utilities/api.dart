import 'package:lpu_app/config/api_config.dart';
import 'package:lpu_app/utilities/http_handler.dart';

class API {
  static Future fetch(Map<String, dynamic> queryParameters) async {
    return HTTPHandler.getRequest(APIConfig.apiFetchURL, queryParameters);
  }

  static Future push(Map<String, dynamic> queryParameters) async {
    HTTPHandler.postRequest(APIConfig.apiPushURL, queryParameters);
  }

  static Future update(Map<String, dynamic> queryParameters) async {
    HTTPHandler.postRequest(APIConfig.apiUpdateURL, queryParameters);
  }

  static Future delete(Map<String, dynamic> queryParameters) async {
    HTTPHandler.postRequest(APIConfig.apiDeleteURL, queryParameters);
  }
}
