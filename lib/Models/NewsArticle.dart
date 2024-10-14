class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '1970-01-01T00:00:00Z') ?? DateTime.now(),
    );
  }
}
