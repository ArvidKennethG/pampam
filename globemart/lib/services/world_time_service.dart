import 'dart:convert';
import 'package:http/http.dart' as http;

class WorldTimeService {

  static Future<String> getTime(String zone) async {
    try {
      final res = await http
          .get(Uri.parse("https://worldtimeapi.org/api/timezone/$zone"))
          .timeout(const Duration(seconds: 7));

      if (res.statusCode != 200) return "N/A";

      final data = jsonDecode(res.body);
      final dt = data['datetime'];
      if (dt == null) return "N/A";

      return dt.toString().substring(11, 19); // HH:mm:ss

    } catch (_) {
      return "Offline";
    }
  }

  static Future<Map<String, String>> getAll() async {
    return {
      'WIB': await getTime("Asia/Jakarta"),
      'WITA': await getTime("Asia/Makassar"),
      'WIT': await getTime("Asia/Jayapura"),
      'London': await getTime("Europe/London"),
    };
  }
}
