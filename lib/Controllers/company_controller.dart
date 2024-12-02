import 'dart:convert';
import 'package:FFinance/Models/company.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

// Updated CompanyController
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
      final lines = LineSplitter.split(data).toList();

      if (lines.isEmpty) return;

      final headers = lines[0].split(',');

      companies.value = lines.skip(1).map((line) {
        final values = line.split(',');
        final companyData = {
          for (var i = 0; i < headers.length; i++) headers[i]: values[i],
        };
        return Company.fromJson(companyData);
      }).toList();

      // Initially, filtered companies are the same as all companies
      filteredCompanies.value = companies;
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
          .where((company) {
        // Split the company name into words
        final nameParts = company.name.toLowerCase().split(' ');

        // Check if any word starts with the query
        return nameParts.any((part) =>
        part.startsWith(normalizedQuery) ||
            part.contains(normalizedQuery)
        );
      })
          .toList();
    }
  }

  void selectCompany(Company company) {
    selectedCompany.value = company;
  }
}