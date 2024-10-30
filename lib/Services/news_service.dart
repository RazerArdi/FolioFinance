import 'dart:convert';
import 'package:FFinance/Services/Encrypt/aes_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:FFinance/Models/NewsArticle.dart';

class NewsService {
  late final AesKeys keys;  // Use late keyword
  late final String encryptedApiKey; // Use late keyword

  NewsService() {
    // Initialize keys and encrypt the API key from the .env file
    keys = Aes256Helper.generateRandomKeyAndIV();
    final rawApiKey = dotenv.env['NEWS_API_KEY'] ?? ''; // Get API key from .env
    encryptedApiKey = Aes256Helper.encrypt(rawApiKey, keys);
  }

  final String baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsArticle>> fetchFinanceNews() async {
    // Decrypt the API key before using it
    final String decryptedApiKey = Aes256Helper.decrypt(encryptedApiKey, keys);

    final response = await http.get(
      Uri.parse('$baseUrl/everything?q=NASDAQ+finance&apiKey=$decryptedApiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List articles = jsonResponse['articles'];
      return articles.map((article) => NewsArticle.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load finance news');
    }
  }
}
