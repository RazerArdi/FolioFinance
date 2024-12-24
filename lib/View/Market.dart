import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'package:FFinance/Controllers/MarketController.dart';
import 'AsynchronousComputingHome/AsynchronousComputingHome.dart';

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    final MarketController marketController = Get.put(MarketController());
    marketController.fetchStockData("EUR/USD");

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Obx(() {
        if (!Get.find<ConnectivityController>().isConnected.value) {
          return AsynchronousComputingHome();
        }

        if (marketController.stockData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2D3142),
            ),
          );
        }

        final timeSeriesData = marketController.stockData['values'] as List<dynamic>?;
        if (timeSeriesData == null || timeSeriesData.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Market Overview',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF2D3142),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildMicrosoftSection(marketController),
                  _buildDetailsSection(marketController),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMicrosoftSection(MarketController controller) {
    final timeSeriesData = controller.stockData['values'] as List<dynamic>?;
    if (timeSeriesData == null || timeSeriesData.isEmpty) return Container();

    final latestData = timeSeriesData.first;
    final close = double.tryParse(latestData['close']) ?? 0.0;
    final open = double.tryParse(latestData['open']) ?? 0.0;
    final change = close - open;
    final percentChange = (change / open * 100).toStringAsFixed(2);

    // Create chart data points
    final List<FlSpot> chartData = timeSeriesData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final close = double.tryParse(entry.value['close'] ?? '0') ?? 0;
      return FlSpot(index, close);
    }).toList().reversed.toList(); // Reverse to show oldest to newest

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EUR/USD',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${close.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: change >= 0
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} ($percentChange%)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: change >= 0 ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    barWidth: 3,
                    color: const Color(0xFF6C63FF),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(MarketController controller) {
    final timeSeriesData = controller.stockData['values'] as List<dynamic>?;
    if (timeSeriesData == null || timeSeriesData.isEmpty) return Container();

    final latestData = timeSeriesData.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Open', latestData['open'] ?? '-', 'Opening price'),
              _buildDetailItem('High', latestData['high'] ?? '-', 'Highest price'),
              _buildDetailItem('Low', latestData['low'] ?? '-', 'Lowest price'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Close', latestData['close'] ?? '-', 'Closing price'),
              _buildDetailItem('Volume', latestData['volume'] ?? '-', 'Trading volume'),
              _buildDetailItem('Date', latestData['datetime']?.toString().split(' ')[0] ?? '-', 'Trading date'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value, String description) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}