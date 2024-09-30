// Pages/halaman_utama.dart
import 'dart:io';
import 'package:FFinance/Controllers/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:FFinance/Database/chart_data.dart'; // Import chart data
import 'package:FFinance/Database/database_helper.dart'; // Import database helper
import 'package:syncfusion_flutter_charts/charts.dart'; // Ensure to import this if you're using Syncfusion charts
import 'package:FFinance/Models/stock_data.dart'; // Import the StockData model

class HalamanUtama extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folio Finance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () => controller.pickImage(),
            icon: Obx(() {
              return controller.pickedImage.value == null
                  ? Icon(Icons.person_outline)
                  : CircleAvatar(
                backgroundImage: Image.file(
                  File(controller.pickedImage.value!.path),
                ).image,
              );
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView( // This enables scrolling for the entire page
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Instead of ListView.builder, use Column
                  ...chartData.map((data) => _buildListCard(data)).toList(), // Mapping chart data to widgets

                  SizedBox(height: 16),
                  _buildAddAssetButton(),
                ],
              ),
            ),
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
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.selectedIndex.value,
        onTap: controller.onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF6750A4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Markets'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      )),
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
      child: CardSwiper(
        cardsCount: 3, // Adjust based on your news length
        cardBuilder: (context, index, realIndex, direction) {
          return GestureDetector(
            onTap: () => _showFullTextDialog(context, 'This is breaking news detail for item $index.'),
            child: Card(
              child: Center(child: Text('Breaking News $index')),
            ),
          );
        },
      ),
    );
  }

  void _showFullTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Breaking News'),
        content: SingleChildScrollView(
          child: Text(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
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
          Text(
            'Save Up to 50% off!!!',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
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
        itemCount: categories.length + 1, // Adding one for the "+" button
        itemBuilder: (context, index) {
          if (index < categories.length) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(categories[index]),
              ),
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
    Color lineColor = data.change > 0 ? Colors.green : Colors.red; // Set line color based on price change

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
                height: 60,
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
                    '\$${data.price.toStringAsFixed(2)}', // Formatting price
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Display percentage below the price
                  Text(
                    '${data.change}%', // Displaying change percentage
                    style: TextStyle(
                      fontSize: 14,
                      color: lineColor,
                    ),
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
                    dataSource: data.stockHistory, // Use the correct property
                    xValueMapper: (StockData stockData, _) => stockData.time,
                    yValueMapper: (StockData stockData, _) => stockData.price,
                    color: lineColor, // Set line color based on price change
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
        // Add your action here
        print("Add Asset tapped");
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 16), // Padding for the button
        decoration: BoxDecoration(
          color: Colors.transparent, // Transparent background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_sharp, color: Colors.blue), // Add icon
            SizedBox(width: 8),
            Text(
              'Tambahakan Asset', // Button text
              style: TextStyle(
                color: Colors.blue, // Blue text color
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
