import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockData {
  final String time;
  final double price;

  StockData(this.time, this.price);
}

class HalamanUtama extends StatefulWidget {
  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  List<_ChartData> chartData = [
    _ChartData('GD', 'General Dynamics', 300.13, -0.12, [
      StockData('10:00', 300.00),
      StockData('10:15', 300.10),
      StockData('10:30', 300.20),
      StockData('10:45', 300.13),
    ], 'assets/Images/General-Dynamics-Symbol.png'),
    _ChartData('PLTR', 'Palantir Technologies', 36.84, -0.70, [
      StockData('10:00', 36.80),
      StockData('10:15', 36.90),
      StockData('10:30', 36.70),
      StockData('10:45', 36.84),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('AES', 'AES Corp', 20.08, 2.21, [
      StockData('10:00', 20.00),
      StockData('10:15', 20.10),
      StockData('10:30', 20.20),
      StockData('10:45', 20.08),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('SIRI', 'Sirius XM Holdings', 24.38, 0.12, [
      StockData('10:00', 24.30),
      StockData('10:15', 24.40),
      StockData('10:30', 24.50),
      StockData('10:45', 24.38),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('MANU', 'Manchester United', 16.48, -0.06, [
      StockData('10:00', 16.50),
      StockData('10:15', 16.40),
      StockData('10:30', 16.30),
      StockData('10:45', 16.48),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('VALE', 'Vale S.A.', 11.79, -0.08, [
      StockData('10:00', 11.80),
      StockData('10:15', 11.90),
      StockData('10:30', 11.70),
      StockData('10:45', 11.79),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('FOX', 'Fox Corporation', 38.84, 0.44, [
      StockData('10:00', 38.80),
      StockData('10:15', 38.90),
      StockData('10:30', 38.70),
      StockData('10:45', 38.84),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('CMCSA', 'Comcast Corporation', 41.63, 1.49, [
      StockData('10:00', 41.60),
      StockData('10:15', 41.70),
      StockData('10:30', 41.50),
      StockData('10:45', 41.63),
    ], 'assets/Images/Intel_icon.png'),
    _ChartData('NYT', 'The New York Times Company', 43.19, 0.19, [
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
            onPressed: () {},
            icon: Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Stack( // Use Stack to overlay the button
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portofolio',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rp2.331.201',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Imbal Hasil +Rp345.406 (17,39%)',
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Use spaceEvenly for even spacing
                    children: [
                      _buildMenuButton(
                        icon: Icons.card_giftcard,
                        text: 'Academy',
                        onTap: () {},
                      ),
                      _buildMenuButton(
                        icon: Icons.compare_arrows,
                        text: 'Share Send\nAnd Receive',
                        onTap: () {},
                      ),
                      _buildMenuButton(
                        icon: Icons.wifi,
                        text: 'Signals',
                        onTap: () {},
                      ),
                      _buildMenuButton(
                        icon: Icons.more_horiz_sharp,
                        text: 'Lainnya',
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: 16),
                  _buildBreakingNewsCarousel(context),
                  SizedBox(height: 16),
                  _buildCashbackBanner(),
                  SizedBox(height: 16),
                  _buildCategorySelector(),
                  SizedBox(height: 16),
                  Text(
                    'List',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: chartData.map((data) => _buildListCard(data)).toList(),
                  ),
                  SizedBox(height: 16),
                  _buildAddAssetButton(), // New button at the bottom
                ],
              ),
            ),
          ),
          Positioned( // Fix position of the floating action button
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF6750A4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }


  Widget _buildListCard(_ChartData data) {
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
                    '\$${data.price}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Display percentage below the price
                  Text(
                    '${data.change}%',
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
                    dataSource: data.stockData,
                    xValueMapper: (data, _) => data.time,
                    yValueMapper: (data, _) => data.price,
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
    final breakingNewsList = [
      'Breaking News 1...',
      'Breaking News 2...',
      'Breaking News 3...',
    ];

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breaking News',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              newsText,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            InkWell(
              onTap: () => _showFullTextDialog(context, newsText),
              child: Text(
                'Baca Selengkapnya',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        };
        },
      ),
    );
  }
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

class _ChartData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final List<StockData> stockData;
  final String image;

  _ChartData(this.symbol, this.name, this.price, this.change, this.stockData, this.image);
}
