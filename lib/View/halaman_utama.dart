import 'dart:io';
import 'package:FFinance/Controllers/main_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:FFinance/Models/stock_data.dart';

class HalamanUtama extends StatelessWidget {
  final MainController controller = Get.put(MainController());
  final List<ChartData> chartData = [
    ChartData('GD', 'General Dynamics', 300.13, -0.12, [
      StockData('10:00', 300.00),
      StockData('10:15', 300.10),
      StockData('10:30', 300.20),
      StockData('10:45', 300.13),
    ], 'assets/Images/General-Dynamics-Symbol.png'),
    ChartData('PLTR', 'Palantir Technologies', 36.84, -0.70, [
      StockData('10:00', 36.80),
      StockData('10:15', 36.90),
      StockData('10:30', 36.70),
      StockData('10:45', 36.84),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('AES', 'AES Corp', 20.08, 2.21, [
      StockData('10:00', 20.00),
      StockData('10:15', 20.10),
      StockData('10:30', 20.20),
      StockData('10:45', 20.08),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('SIRI', 'Sirius XM Holdings', 24.38, 0.12, [
      StockData('10:00', 24.30),
      StockData('10:15', 24.40),
      StockData('10:30', 24.50),
      StockData('10:45', 24.38),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('MANU', 'Manchester United', 16.48, -0.06, [
      StockData('10:00', 16.50),
      StockData('10:15', 16.40),
      StockData('10:30', 16.30),
      StockData('10:45', 16.48),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('VALE', 'Vale S.A.', 11.79, -0.08, [
      StockData('10:00', 11.80),
      StockData('10:15', 11.90),
      StockData('10:30', 11.70),
      StockData('10:45', 11.79),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('FOX', 'Fox Corporation', 38.84, 0.44, [
      StockData('10:00', 38.80),
      StockData('10:15', 38.90),
      StockData('10:30', 38.70),
      StockData('10:45', 38.84),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('CMCSA', 'Comcast Corporation', 41.63, 1.49, [
      StockData('10:00', 41.60),
      StockData('10:15', 41.70),
      StockData('10:30', 41.50),
      StockData('10:45', 41.63),
    ], 'assets/Images/Intel_icon.png'),
    ChartData('NYT', 'The New York Times Company', 43.19, 0.19, [
      StockData('10:00', 43.20),
      StockData('10:15', 43.30),
      StockData('10:30', 43.10),
      StockData('10:45', 43.19),
    ], 'assets/Images/Intel_icon.png'),
  ];

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
          SingleChildScrollView(
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
                  Column(
                    children: chartData.map((data) => _buildListCard(data)).toList(),
                  ),
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

  Widget _buildMenuButton({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon),
          SizedBox(height: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildBreakingNewsCarousel(BuildContext context) {
    final breakingNewsList = ['Breaking News 1...', 'Breaking News 2...', 'Breaking News 3...'];

    return Container(
      height: 180,
      width: double.infinity,
      child: CardSwiper(
        cardsCount: breakingNewsList.length,
        cardBuilder: (context, index, realIndex, direction) {
          return _buildBreakingNewsCard(context, breakingNewsList[index]);
        },
      ),
    );
  }

  Widget _buildBreakingNewsCard(BuildContext context, String newsText) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breaking News', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(newsText, style: TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            InkWell(
              onTap: () => _showFullTextDialog(context, newsText),
              child: Text('Baca Selengkapnya', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Breaking News'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))],
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
      };
    },
    ),
    );
  }

  Widget _buildListCard(ChartData data) {
    return Card(
      child: ListTile(
        leading: Image.asset(data.image, width: 50, height: 50),
        title: Text(data.name),
        subtitle: Text(data.symbol),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rp${data.price.toStringAsFixed(2)}'),
            Text(
              '${data.change.toStringAsFixed(2)}%',
              style: TextStyle(color: data.change >= 0 ? Colors.green : Colors.red),
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
