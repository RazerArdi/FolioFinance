import 'dart:convert';
import 'package:FFinance/Services/Encrypt/aes_helper.dart';
import 'package:http/http.dart' as http;
import 'package:FFinance/Models/NewsArticle.dart';
import 'package:encrypt/encrypt.dart';

class NewsService {
  late final AesKeys keys;  // Use late keyword
  late final String encryptedApiKey; // Use late keyword

  final String rawApiKey = 'fac6927930f3406792166f827bd3085c';

  NewsService() {
    // Initialize keys and encryptedApiKey inside the constructor
    keys = Aes256Helper.generateRandomKeyAndIV();
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