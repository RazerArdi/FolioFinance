class StockData {
  final String time;
  final double price;

  StockData(this.time, this.price);
}

class ChartData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final List<StockData> stockData;
  final String image;

  ChartData(this.symbol, this.name, this.price, this.change, this.stockData, this.image);
}
