import 'dart:convert';
import 'package:http/http.dart' as http;
// Import the encryption package
import 'package:FFinance/Services/Encrypt/aes_helper.dart'; // Import the Aes256Helper class

class TwelveDataService {
  late final AesKeys keys;  // Use late keyword for keys
  late final String encryptedApiKey; // Encrypted API Key

  final String rawApiKey = 'e30b20fbd4514ec6856399cbdb4c8838';

  TwelveDataService() {
    // Initialize keys and encryptedApiKey in the constructor
    keys = Aes256Helper.generateRandomKeyAndIV();
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
