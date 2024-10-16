import 'package:get/get.dart';
import 'package:FFinance/Services/twelve_data_service.dart';

class StockController extends GetxController {
  var stockData = {}.obs; // Observable map to hold stock data
  final TwelveDataService service = TwelveDataService();

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
