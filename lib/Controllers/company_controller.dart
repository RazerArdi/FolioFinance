import 'dart:convert';
import 'package:FFinance/Models/company.dart'; // Pastikan path ini benar
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:latlong2/latlong.dart'; // Import latlong2
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map


class CompanyController extends GetxController {
  final RxList<Company> companies = <Company>[].obs;
  final RxList<Company> filteredCompanies = <Company>[].obs;
  final Rx<Company?> selectedCompany = Rx<Company?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
  }

  Future<void> loadCompanies() async {
    try {
      final data = await rootBundle.loadString('assets/NASDAQ_companies.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

      companies.value = csvTable.skip(1).map((row) {
        return Company(
          symbol: row[0].toString().trim(),
          name: row[1].toString().trim(),
          address: row[2].toString().trim(),
          latitude: double.tryParse(row[3].toString().trim()) ?? 0.0,
          longitude: double.tryParse(row[4].toString().trim()) ?? 0.0,
        );
      }).toList();

      filteredCompanies.value = companies;

      print('Loaded ${companies.length} companies');
    } catch (e) {
      print('Error loading companies: $e');
    }
  }

  void filterCompanies(String query) {
    if (query.isEmpty) {
      filteredCompanies.value = companies;
    } else {
      final normalizedQuery = query.toLowerCase().trim();

      filteredCompanies.value = companies
          .where((company) =>
      company.name.toLowerCase().contains(normalizedQuery) ||
          company.symbol.toLowerCase().contains(normalizedQuery) ||
          company.address.toLowerCase().contains(normalizedQuery))
          .toList();

      print('Filtered companies: ${filteredCompanies.length}');
    }
  }

  void selectCompany(Company company) {
    selectedCompany.value = company;
    print('Selected company: ${company.name}');
  }

  void goToCompanyLocation(Company company) {
    if (company.latitude != null && company.longitude != null) {
      // Correctly access the MapController instance
      Get.find<MapController>().move(
          LatLng(company.latitude!, company.longitude!), 15.0);
      selectCompany(company);
    } else {
      Get.snackbar('Error', 'Coordinates not available for this company');
    }
  }
}