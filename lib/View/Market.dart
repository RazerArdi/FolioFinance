import 'package:FFinance/View/navigator.dart';
import 'package:flutter/material.dart';

class Market extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Market Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Latest Market Trends', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  // Example content: Replace with actual market data
                  Text('Stock A: \$120.50', style: TextStyle(fontSize: 18)),
                  Text('Stock B: \$98.30', style: TextStyle(fontSize: 18)),
                  Text('Stock C: \$76.15', style: TextStyle(fontSize: 18)),
                  // You can add more content, charts, or widgets here
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Action for adding a new market item or similar
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
