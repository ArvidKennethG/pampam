import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String apiKey = "9ee514d7374850d1999c8c1a";
  static const String baseUrl =
      "https://v6.exchangerate-api.com/v6/$apiKey/latest/USD";

  static Future<Map<String, double>> getRates() async {
    final res = await http.get(Uri.parse(baseUrl));
    final data = jsonDecode(res.body);
    final Map<String, dynamic> rates =
        Map<String, dynamic>.from(data['conversion_rates']);

    return {
      'USD': rates['USD'].toDouble(),
      'IDR': rates['IDR'].toDouble(),
      'JPY': rates['JPY'].toDouble(),
      'EUR': rates['EUR'].toDouble(),
      'GBP': rates['GBP'].toDouble(),
    };
  }
}
