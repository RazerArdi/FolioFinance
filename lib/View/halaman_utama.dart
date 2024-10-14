// lib/View/halaman_utama.dart

import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/View/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:FFinance/Database/chart_data.dart';
import 'package:FFinance/Database/database_helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:FFinance/Models/stock_data.dart';
import 'package:FFinance/Models/NewsArticle.dart'; // Import the NewsArticle model
import 'package:FFinance/Services/news_service.dart';
import 'package:intl/intl.dart';

class HalamanUtama extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final NewsService newsService = NewsService();
  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs; // List of news articles

  HalamanUtama({Key? key}) : super(key: key) {
    _fetchFinanceNews(); // Fetch finance news when the widget is created
  }

  void _fetchFinanceNews() async {
    try {
      final articles = await newsService.fetchFinanceNews(); // Fetch news articles
      newsArticles.assignAll(articles);
    } catch (e) {
      print('Error fetching finance news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Portofolio', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Obx(() => Text(
                'Rp${controller.portfolioValue.value}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 4),
              Obx(() => Text(
                'Imbal Hasil +Rp${controller.returnValue.value} (${controller.returnPercentage.value}%)',
                style: TextStyle(color: Colors.green),
              )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(icon: Icons.card_giftcard, text: 'Academy', onTap: () {}),
                  _buildMenuButton(icon: Icons.compare_arrows, text: 'Share Send\nAnd Receive', onTap: () {}),
                  _buildMenuButton(icon: Icons.wifi, text: 'Signals', onTap: () {}),
                  _buildMenuButton(icon: Icons.more_horiz_sharp, text: 'Lainnya', onTap: () {}),
                ],
              ),
              SizedBox(height: 16),
              _buildBreakingNewsCarousel(context),
              SizedBox(height: 16),
              _buildCashbackBanner(),
              SizedBox(height: 16),
              _buildCategorySelector(),
              SizedBox(height: 16),
              Text('List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...chartData.map((data) => _buildListCard(data)).toList(),
              SizedBox(height: 16),
              _buildAddAssetButton(),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 4),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBreakingNewsCarousel(BuildContext context) {
    return Container(
      height: 200,
      child: Obx(() {
        if (newsArticles.isEmpty) {
          return Center(child: CircularProgressIndicator());
        } else {
          return CardSwiper(
            cardsCount: newsArticles.length,
            cardBuilder: (context, index, realIndex, direction) {
              final article = newsArticles[index];
              return GestureDetector(
                onTap: () => _showFullTextDialog(context, article),
                child: Hero(
                  tag: article.title,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        if (article.urlToImage.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            child: Image.network(
                              article.urlToImage,
                              fit: BoxFit.cover,
                              height: 50,
                              width: double.infinity,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy-MM-dd – kk:mm').format(article.publishedAt),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    DateTime parsedDate = DateTime.parse(date);
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}"; // Format the date as per your requirement
  }

  void _showFullTextDialog(BuildContext context, NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: article.url), // Navigate to WebView
      ),
    );
  }

  Widget _buildCashbackBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.white),
          SizedBox(width: 8),
          Text('Save Up to 50% off!!!', style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Kategori 1', 'Kategori 2', 'Kategori 3', 'Kategori 4', 'Kategori 5'];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index < categories.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(label: Text(categories[index])),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add, color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildListCard(ChartData data) {
    Color lineColor = data.change > 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                data.image,
                width: 60,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.symbol,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data.name,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${data.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${data.change}%',
                    style: TextStyle(fontSize: 14, color: lineColor),
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              height: 60,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: [
                  LineSeries<StockData, String>(
                    dataSource: data.stockHistory,
                    xValueMapper: (StockData stockData, _) => stockData.time,
                    yValueMapper: (StockData stockData, _) => stockData.price,
                    color: lineColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAssetButton() {
    return GestureDetector(
      onTap: () {
        print("Add Asset tapped");
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_sharp, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Tambahkan Asset',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
