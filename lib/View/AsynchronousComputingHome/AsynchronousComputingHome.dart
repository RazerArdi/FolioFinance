import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/Controllers/StockController.dart';
import 'package:FFinance/Services/news_service.dart';
import 'package:FFinance/Models/NewsArticle.dart';

class AsynchronousComputingHome extends StatelessWidget {
  final ConnectivityController connectivityController = Get.put(
      ConnectivityController());
  final StockController stockController = Get.put(StockController());
  final NewsService newsService = NewsService();
  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs;

  AsynchronousComputingHome({super.key}) {
    _fetchData();
  }

  void _fetchData() {
    if (connectivityController.isConnected.value) {
      _fetchFinanceNews();
      stockController.fetchStockData("AAPL,MSFT,GOOGL");
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
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      body: Obx(() {
        if (!connectivityController.isConnected.value) {
          return _buildNoInternetView();
        }
        return _buildMainContent();
      }),
    );
  }

  Widget _buildNoInternetView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Internet Connection',
                style: Theme
                    .of(Get.context!)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your network settings and try again',
                style: Theme
                    .of(Get.context!)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => connectivityController.checkConnectivity(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}