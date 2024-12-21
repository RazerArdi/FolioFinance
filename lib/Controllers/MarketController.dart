import 'package:FFinance/Services/TwelveDataServiceSEC.dart';
import 'package:get/get.dart';

class MarketController extends GetxController {
  var stockData = {}.obs; // Observable map to hold stock data
  final TwelveDataServiceSEC service = TwelveDataServiceSEC();

  void fetchStockData(String symbols) async {
    try {
      var data = await service.fetchTimeSeries(symbols);
      print(data); // Debug: Print the response to inspect its structure
      stockData.value = data; // Update observable variable
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }
}
