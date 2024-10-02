
import 'package:FFinance/Models/stock_data.dart';

class ChartData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final List<StockData> stockHistory;
  final String image;

  ChartData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.stockHistory,
    required this.image,
  });
}

final List<ChartData> chartData = [
  ChartData(
    symbol: 'GD',
    name: 'General Dynamics',
    price: 300.13,
    change: -0.12,
    stockHistory: [
      StockData('10:00', 300.00),
      StockData('10:15', 300.10),
      StockData('10:30', 300.20),
      StockData('10:45', 300.13),
    ],
    image: 'assets/Images/General-Dynamics-Symbol.png',
  ),
  ChartData(
    symbol: 'PLTR',
    name: 'Palantir Technologies',
    price: 36.84,
    change: -0.70,
    stockHistory: [
      StockData('10:00', 36.80),
      StockData('10:15', 36.90),
      StockData('10:30', 36.70),
      StockData('10:45', 36.84),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'AES',
    name: 'AES Corp',
    price: 20.08,
    change: 2.21,
    stockHistory: [
      StockData('10:00', 20.00),
      StockData('10:15', 20.10),
      StockData('10:30', 20.20),
      StockData('10:45', 20.08),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'SIRI',
    name: 'Sirius XM Holdings',
    price: 24.38,
    change: 0.12,
    stockHistory: [
      StockData('10:00', 24.30),
      StockData('10:15', 24.40),
      StockData('10:30', 24.50),
      StockData('10:45', 24.38),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'MANU',
    name: 'Manchester United',
    price: 16.48,
    change: -0.06,
    stockHistory: [
      StockData('10:00', 16.50),
      StockData('10:15', 16.40),
      StockData('10:30', 16.30),
      StockData('10:45', 16.48),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'VALE',
    name: 'Vale S.A.',
    price: 11.79,
    change: -0.08,
    stockHistory: [
      StockData('10:00', 11.80),
      StockData('10:15', 11.90),
      StockData('10:30', 11.70),
      StockData('10:45', 11.79),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'FOX',
    name: 'Fox Corporation',
    price: 38.84,
    change: 0.44,
    stockHistory: [
      StockData('10:00', 38.80),
      StockData('10:15', 38.90),
      StockData('10:30', 38.70),
      StockData('10:45', 38.84),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'CMCSA',
    name: 'Comcast Corporation',
    price: 41.63,
    change: 1.49,
    stockHistory: [
      StockData('10:00', 41.60),
      StockData('10:15', 41.70),
      StockData('10:30', 41.50),
      StockData('10:45', 41.63),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
  ChartData(
    symbol: 'NYT',
    name: 'The New York Times Company',
    price: 43.19,
    change: 0.19,
    stockHistory: [
      StockData('10:00', 43.20),
      StockData('10:15', 43.30),
      StockData('10:30', 43.10),
      StockData('10:45', 43.19),
    ],
    image: 'assets/Images/Intel_icon.png',
  ),
];
