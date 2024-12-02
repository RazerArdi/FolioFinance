// Keep the existing Company class
class Company {
  final String symbol;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Company({
    required this.symbol,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      symbol: json['Symbol'],
      name: json['Full Company Name'],
      address: json['Address'],
      latitude: double.parse(json['Latitude']),
      longitude: double.parse(json['Longitude']),
    );
  }
}