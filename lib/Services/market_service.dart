import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketService {
final String apiKey = '99d5fd4055f54f4d88ba1ca5de5d42cd';

Future<Map<String, dynamic>> getMultipleMarketData(List<String> symbols) async {
  final String symbolList = symbols.join(','); // Gabungkan simbol dengan koma
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


