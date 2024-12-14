import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/Controllers/StockController.dart';
import 'package:FFinance/Services/news_service.dart';
import 'package:FFinance/Models/NewsArticle.dart';

class AsynchronousComputingHome extends StatelessWidget {
  final ConnectivityController connectivityController = Get.put(ConnectivityController());
  final StockController stockController = Get.put(StockController());
  final NewsService newsService = NewsService();

  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs;

  AsynchronousComputingHome({super.key}) {
    // Initial data fetch when the app starts
    _fetchData();
  }

  // Fetch data only if connected
  void _fetchData() {
    if (connectivityController.isConnected.value) {
      _fetchFinanceNews();
      stockController.fetchStockData("AAPL,MSFT,GOOGL");
    } else {
      connectivityController.checkConnectivity();
    }
  }

  // Fetch finance news asynchronously
  void _fetchFinanceNews() async {
    try {
      final articles = await newsService.fetchFinanceNews();
      newsArticles.assignAll(articles);
    } catch (e) {
      _showErrorSnackbar('Failed to fetch news');
    }
  }

  // Show error message in the form of a snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  // Show no internet connection message in the form of a snackbar
  void _showNoConnectionSnackbar() {
    Get.snackbar(
      'No Internet',
      'Please check your network settings and try again (ACH)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Show UI based on connection status
        if (!connectivityController.isConnected.value) {
          return _buildNoInternetView();
        }
        return _buildMainContent();
      }),
    );
  }

  // View shown when there is no internet connection
  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 120,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Internet Connection',
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please check your network settings and try again (ACH)',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: () => connectivityController.checkConnectivity(),
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  // Main content when the app is connected
  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        if (connectivityController.isConnected.value) {
          _fetchData();
        }
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Finance Dashboard',
              style: Theme.of(Get.context!).textTheme.titleLarge,
            ),
            floating: true,
            snap: true,
            backgroundColor: Theme.of(Get.context!).colorScheme.surface,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Quick Overview'),
                  const SizedBox(height: 16),
                  _buildPortfolioCard(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Market News'),
                  const SizedBox(height: 16),
                  _buildNewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header for each section
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Portfolio card to display portfolio details
  Widget _buildPortfolioCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Portfolio Value',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$54,320.45', // Placeholder value, integrate live data later.
              style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPortfolioMetric('Today\'s Gain', '+2.3%', Colors.green),
                _buildPortfolioMetric('Total Gain', '+12.5%', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Portfolio metrics (e.g. Today's Gain, Total Gain)
  Widget _buildPortfolioMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(Get.context!).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // News section to display finance news articles
  Widget _buildNewsSection() {
    return Obx(() {
      if (newsArticles.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: newsArticles.take(3).map((article) {
          return _buildNewsArticleCard(article);
        }).toList(),
      );
    });
  }

  // Display individual news articles
  Widget _buildNewsArticleCard(NewsArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            article.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(Get.context!).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
