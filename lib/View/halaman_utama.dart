import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/Controllers/StockController.dart';
import 'package:FFinance/Models/stock_data.dart';
import 'package:FFinance/Services/logo_service.dart';
import 'package:FFinance/View/AsynchronousComputingHome/AsynchronousComputingHome.dart';
import 'package:FFinance/View/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:FFinance/Models/NewsArticle.dart';
import 'package:FFinance/Services/news_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HalamanUtama extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final StockController stockController = Get.put(StockController());
  final ConnectivityController connectivityController = Get.put(ConnectivityController());
  final LogoService stockService = LogoService();
  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs;

  HalamanUtama({Key? key}) : super(key: key) {
    _initializeData();
  }

  void _initializeData() {
    if (connectivityController.isConnected.value) {
      _fetchFinanceNews();
      stockController.fetchStockData("AAPL,MSFT,GOOGL");
    }
  }

  void _fetchFinanceNews() async {
    try {
      final articles = await NewsService().fetchFinanceNews();
      newsArticles.assignAll(articles);
    } catch (e) {
      print('Error fetching finance news: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch news',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (!connectivityController.isConnected.value) {
          return AsynchronousComputingHome();
        }
        return _buildMainContent(context);
      }),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _initializeData();
      },
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPortfolioCard(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildNewsSection(),
                      const SizedBox(height: 24),
                      _buildPromotionCard(),
                      const SizedBox(height: 24),
                      _buildWatchlist(context),
                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildConnectivityBanner(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Portfolio Overview',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.black87),
          onPressed: () {},
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio Value',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            'Rp${controller.portfolioValue.value}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Text(
              '+Rp${controller.returnValue.value} (${controller.returnPercentage.value}%)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.school_outlined, 'text': 'Academy', 'color': Colors.blue},
      {'icon': Icons.sync_alt_outlined, 'text': 'Transfer', 'color': Colors.green},
      {'icon': Icons.analytics_outlined, 'text': 'Signals', 'color': Colors.orange},
      {'icon': Icons.grid_view_outlined, 'text': 'More', 'color': Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) => _buildActionButton(
        icon: action['icon'] as IconData,
        text: action['text'] as String,
        color: action['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: 80,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          child: Text(
            'Market News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 280, // Increased height for better content display
          child: Obx(() {
            if (newsArticles.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: newsArticles.length,
              itemBuilder: (context, index) {
                return _buildNewsCard(newsArticles[index]);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => Get.to(
              () => WebViewScreen(url: article.url),
          fullscreenDialog: true,
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: article.urlToImage.isNotEmpty
                    ? Image.network(
                  article.urlToImage,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                )
                    : Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: Icon(Icons.article,
                    color: Colors.grey[400],
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(article.publishedAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[400]!, Colors.purple[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Save up to 50% on trading fees',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildWatchlist(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watchlist',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        Obx(() {
          if (stockController.stockData.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: stockController.stockData.entries.map((entry) {
              return _buildStockCard(entry.key, entry.value);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStockCard(String symbol, Map<String, dynamic> data) {
    final values = data['values'] as List;
    if (values.isEmpty) return SizedBox.shrink();

    final timeSeries = values[0];
    final price = timeSeries['close'] ?? 'N/A';
    final percentChange = timeSeries['percent_change'] ?? '0.00';
    final logoUrl = stockService.getLogoUrl(symbol);

    List<StockData> stockHistory = values.map((data) {
      return StockData(
        time: data['datetime'],
        price: double.tryParse(data['close'] ?? '0.0') ?? 0.0,
      );
    }).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              logoUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey[200],
                  child: Icon(Icons.business, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$$price',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: double.parse(percentChange) >= 0
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${double.parse(percentChange) >= 0 ? '+' : ''}$percentChange%',
                  style: TextStyle(
                    color: double.parse(percentChange) >= 0
                        ? Colors.green[700]
                        : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: 80,
                height: 30,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: CategoryAxis(isVisible: false),
                  primaryYAxis: NumericAxis(isVisible: false),
                  margin: EdgeInsets.zero,
                  series: [
                    LineSeries<StockData, String>(
                      dataSource: stockHistory,
                      xValueMapper: (StockData stockData, _) => stockData.time,
                      yValueMapper: (StockData stockData, _) => stockData.price,
                      color: double.parse(percentChange) >= 0
                          ? Colors.green[400]
                          : Colors.red[400],
                      width: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildConnectivityBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Obx(() => connectivityController.isConnected.value
          ? SizedBox.shrink()
          : Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.red[600],
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )),
    );
  }
}