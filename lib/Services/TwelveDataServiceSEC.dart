import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:FFinance/Services/Encrypt/aes_helper.dart';

class TwelveDataServiceSEC {
  late final AesKeys keys;  // Use late keyword for keys
  late final String encryptedApiKey; // Encrypted API Key

  TwelveDataServiceSEC() {
    // Initialize keys and encrypt the API key from the .env file
    keys = Aes256Helper.generateRandomKeyAndIV();
    final rawApiKey = dotenv.env['API_KEYSEC'] ?? ''; // Get API key from .env
    encryptedApiKey = Aes256Helper.encrypt(rawApiKey, keys);
  }

  Future<Map<String, dynamic>> fetchTimeSeries(String symbols) async {
    // Decrypt the API key before using it
    final String decryptedApiKey = Aes256Helper.decrypt(encryptedApiKey, keys);

    // Construct the URL using the decrypted API key
    final url = 'https://api.twelvedata.com/time_series?symbol=$symbols&interval=1min&apikey=$decryptedApiKey';

    // Make the HTTP GET request
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
