import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/Controllers/StockController.dart';
import 'package:FFinance/Services/news_service.dart';
import 'package:FFinance/Models/NewsArticle.dart';
import 'package:FFinance/View/webview_screen.dart';

class StockPortfolioDashboard extends StatelessWidget {
  final ConnectivityController connectivityController = Get.put(ConnectivityController());
  final StockController stockController = Get.put(StockController());
  final NewsService newsService = NewsService();
  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs;

  StockPortfolioDashboard({super.key}) {
    _fetchData();
  }

  void _fetchData() {
    if (connectivityController.isConnected.value) {
      _fetchFinanceNews();
      stockController.fetchStockData("AAPL,MSFT,GOOGL,AMZN,TSLA");
    } else {
      connectivityController.checkConnectivity();
    }
  }

  void _fetchFinanceNews() async {
    try {
      final articles = await newsService.fetchFinanceNews();
      newsArticles.assignAll(articles);
    } catch (e) {
      _showErrorSnackbar('Failed to fetch news');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Obx(() {
        if (!connectivityController.isConnected.value) {
          return _buildNoInternetView();
        }
        return _buildMainContent();
      }),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        if (connectivityController.isConnected.value) {
          _fetchData();
        }
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPortfolioSummary(),
                  const SizedBox(height: 24),
                  _buildPortfolioPerformance(),
                  const SizedBox(height: 24),
                  _buildStockHoldings(),
                  const SizedBox(height: 24),
                  _buildWatchlist(),
                  const SizedBox(height: 24),
                  _buildNewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(Get.context!).colorScheme.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Portfolio',
          style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(Get.context!).colorScheme.onBackground,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            // Add new stock to portfolio
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPortfolioSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(Get.context!).colorScheme.primary,
            Theme.of(Get.context!).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Value',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+12.5% All Time',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$54,320.45',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPortfolioMetric('Day\'s Gain', '+\$1,245.23', '+2.3%'),
              _buildPortfolioMetric('Total Gain', '+\$6,790.45', '+12.5%'),
              _buildPortfolioMetric('Cash', '\$2,530.12', '4.7%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioMetric(String label, String value, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio Performance',
          style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          // Add your chart widget here
          child: const Center(
            child: Text('Performance Chart'),
          ),
        ),
      ],
    );
  }

  Widget _buildStockHoldings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Holdings',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStockCard('AAPL', 'Apple Inc.', 150.23, 2.3, 15420.50, 28.4),
        _buildStockCard('MSFT', 'Microsoft', 290.45, 1.8, 11618.00, 21.4),
        _buildStockCard('GOOGL', 'Alphabet', 2780.12, 3.1, 8340.36, 15.4),
      ],
    );
  }

  Widget _buildStockCard(String symbol, String name, double price,
      double change, double value, double weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '+${change.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${weight.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Watchlist',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildWatchlistCard('TSLA', '\$780.23', '+4.3%'),
              _buildWatchlistCard('AMZN', '\$3,180.45', '+2.1%'),
              _buildWatchlistCard('NFLX', '\$590.12', '-1.2%'),
              _buildWatchlistCard('META', '\$330.67', '+0.8%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWatchlistCard(String symbol, String price, String change) {
    final isPositive = !change.startsWith('-');
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            symbol,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market News',
              style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('More'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (newsArticles.isEmpty) {
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(Get.context!).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading market news...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: newsArticles.take(5).map((article) {
              return _buildNewsArticleCard(article);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildNewsArticleCard(NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(Get.context!).push(
            MaterialPageRoute(
              builder: (context) => WebViewScreen(url: article.url),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      article.urlToImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatNewsDate(article.publishedAt),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.bookmark_border_rounded,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          // Add bookmark functionality
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          // Add share functionality
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNewsDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildNoInternetView() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.background,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your connection and try again',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => connectivityController.checkConnectivity(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}