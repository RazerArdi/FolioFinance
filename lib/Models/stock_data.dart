class StockData {
  final String time;
  final double price;

  StockData(this.time, this.price);

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'price': price,
    };
  }

  factory StockData.fromMap(Map<String, dynamic> map) {
    return StockData(
      map['time'],
      map['price'],
    );
  }
}
