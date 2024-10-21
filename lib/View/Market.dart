import 'package:flutter/material.dart';

class Market extends StatelessWidget {
  final Map<String, dynamic>? marketData;

  Market({this.marketData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIHSGSection(),
            _buildDetailsSection(),
            _buildTrendingSection(),
            _buildMoversSection(),
          ],
        ),
      ),
    );
  }

  // Bagian IHSG Chart
  Widget _buildIHSGSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IHSG 7,520.60', // Data IHSG
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '+40.52 (+0.54%)', // Perubahan IHSG
            style: TextStyle(
              fontSize: 18,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16),
          // Placeholder untuk chart IHSG
          Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Text(
                  'IHSG Chart Placeholder'), // Bisa diganti dengan widget Chart
            ),
          ),
        ],
      ),
    );
  }

  // Bagian detail IHSG seperti Open, High, Low, Volume
  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intraday',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailItem('Open', '7,480.08'),
              _buildDetailItem('High', '7,549.54'),
              _buildDetailItem('Low', '7,480.08'),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'All Market',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailItem('Value', '7.68T'),
              _buildDetailItem('Freq', '1.00M'),
              _buildDetailItem('Volume', '170.50M'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat tampilan detail IHSG
  Widget _buildDetailItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> getTrendingStocks(
      Map<String, dynamic> marketData) {
    // Pastikan key sesuai dengan data yang dikembalikan dari API
    if (marketData['popular_stocks'] != null &&
        marketData['popular_stocks'] is List) {
      return List<Map<String, dynamic>>.from(marketData['popular_stocks']);
    } else {
      return [];
    }
  }


  // Bagian Trending Stocks
  Widget _buildTrendingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          marketData != null && getTrendingStocks(marketData!).isNotEmpty
              ? _buildTrendingStocks(getTrendingStocks(marketData!))
              : Text('No trending data available'),
          // Fallback jika data trending tidak ada
        ],
      ),
    );
  }


  // Fungsi untuk menampilkan list trending stocks
  Widget _buildTrendingStocks(List<Map<String, dynamic>> trendingStocks) {
    return Column(
      children: trendingStocks.map((stock) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(stock['symbol'] != null && stock['symbol']!.isNotEmpty
                ? stock['symbol']![0]
                : '?'),
          ),
          title: Text(stock['symbol'] ?? 'Unknown Symbol'),
          trailing: Text(stock['price'].toString() ?? 'No Data'),
        );
      }).toList(),
    );
  }


  // Bagian Movers (Top Value, Top Volume, dll)
  Widget _buildMoversSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildMoversList(),
        ],
      ),
    );
  }

  // Placeholder list untuk movers
  Widget _buildMoversList() {
    // Data movers sementara
    final movers = [
      {'symbol': 'BBRI', 'value': '515.19B'},
      {'symbol': 'BBCA', 'value': '467.04B'},
      {'symbol': 'BMRI', 'value': '316.14B'},
    ];


    return Column(
      children: movers.map((mover) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(mover['symbol'] != null && mover['symbol']!.isNotEmpty
                ? mover['symbol']![0]
                : '?'), // Tampilkan '?' jika data symbol kosong atau null
          ),
          title: Text(mover['symbol'] ?? 'Unknown Symbol'),
          // Jika symbol null, tampilkan 'Unknown Symbol'
          trailing: Text(mover['value'] ??
              'No Data'), // Jika value null, tampilkan 'No Data'
        );
      }).toList(),
    );
  }
}