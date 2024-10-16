import 'package:FFinance/Controllers/main_controller.dart';
import 'package:FFinance/Controllers/StockController.dart'; // Import StockController
import 'package:FFinance/Models/stock_data.dart';
import 'package:FFinance/Services/logo_service.dart';
import 'package:FFinance/View/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:FFinance/Models/NewsArticle.dart';
import 'package:FFinance/Services/news_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HalamanUtama extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final StockController stockController = Get.put(StockController());
  final NewsService newsService = NewsService();
  final LogoService stockService = LogoService();
  final RxList<NewsArticle> newsArticles = <NewsArticle>[].obs;

  HalamanUtama({Key? key}) : super(key: key) {
    _fetchFinanceNews();
    stockController.fetchStockData("AAPL,MSFT,GOOGL");
  }

  void _fetchFinanceNews() async {
    try {
      final articles = await newsService.fetchFinanceNews();
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
              Text('Stocks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildStockList(),
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
                onTap: () => Get.to(WebViewScreen(url: article.url)), // Navigate directly to WebView
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

  Widget _buildAddAssetButton() {
    return GestureDetector(
      onTap: () {
        print("Add Asset tapped");
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_sharp, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Tambahkan Asset',
              style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList() {
    return Obx(() {
      if (stockController.stockData.isEmpty) {
        return Center(child: CircularProgressIndicator());
      } else {
        return Column(
          children: stockController.stockData.entries.map((entry) {
            final symbol = entry.key;
            final values = entry.value['values'];
            final logoUrl = stockService.getLogoUrl(symbol);

            if (values is List && values.isNotEmpty) {
              final timeSeries = values[0];
              final price = timeSeries['close'] ?? 'N/A';
              final percentChange = timeSeries['percent_change'] ?? '0.00';

              List<StockData> stockHistory = values.map((data) {
                return StockData(
                  time: data['datetime'],
                  price: double.tryParse(data['close'] ?? '0.0') ?? 0.0,
                );
              }).toList();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          logoUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, size: 50);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(symbol, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Price: \$${price}'),
                            Text(
                              '${percentChange}%',
                              style: TextStyle(
                                color: double.tryParse(percentChange) != null &&
                                    double.parse(percentChange) >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(isVisible: false),
                          primaryYAxis: NumericAxis(isVisible: false),
                          series: [
                            LineSeries<StockData, String>(
                              dataSource: stockHistory,
                              xValueMapper: (StockData stockData, _) => stockData.time,
                              yValueMapper: (StockData stockData, _) => stockData.price,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text('No stock data available for $symbol.'));
            }
          }).toList(),
        );
      }
    });
  }
}
