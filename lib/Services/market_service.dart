import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class MarketService {
  late final String apiKey;

  MarketService() {
    apiKey = dotenv.env['Market_Service_API_KEY'] ?? ''; // Retrieve API key from .env
  }

  Future<Map<String, dynamic>> getMultipleMarketData(List<String> symbols) async {
    final String symbolList = symbols.join(','); // Combine symbols with comma
    final url = Uri.parse(
        'https://api.twelvedata.com/time_series?symbol=$symbolList&interval=1day&apikey=$apiKey'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load market data');
    }
  }
}
