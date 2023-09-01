import 'package:mysql1/mysql1.dart';
import 'package:lpu_app/config/db_config.dart';

class DB {
  static late dynamic dbConnection;

  static Future<dynamic> init() async {
    dbConnection = await MySqlConnection.connect(ConnectionSettings(host: DBConfig.dbHostname, port: DBConfig.dbPort, user: DBConfig.dbUsername, password: DBConfig.dbPassword, db: DBConfig.dbName));
  }

  static Future<dynamic> query(String queryString, List<dynamic> queryParameters) async {
    if (queryParameters.isEmpty) {
      return await dbConnection.query(queryString);
    } else {
      return await dbConnection.query(queryString, queryParameters);
    }
  }
}
