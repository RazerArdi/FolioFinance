import 'package:FFinance/Controllers/company_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';


// Explore Widget
class Explore extends StatelessWidget {
  final CompanyController companyController = Get.put(CompanyController());
  final TextEditingController _searchController = TextEditingController();

  Explore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                companyController.filterCompanies(query);
              },
              decoration: InputDecoration(
                hintText: 'Search companies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredCompanies = companyController.filteredCompanies;

              return FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(37.7749, -122.4194), // Default center
                  minZoom: 5.0,
                  onTap: (tapPosition, point) =>
                  companyController.selectedCompany.value = null,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: filteredCompanies.map((company) {
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(company.latitude, company.longitude),
                        child: GestureDetector(
                          onTap: () => companyController.selectCompany(company),
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final selectedCompany = companyController.selectedCompany.value;
            if (selectedCompany != null) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCompany.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Symbol: ${selectedCompany.symbol}'),
                    Text('Address: ${selectedCompany.address}'),
                    Text('Latitude: ${selectedCompany.latitude}'),
                    Text('Longitude: ${selectedCompany.longitude}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.snackbar('Navigation',
                            'Navigating to ${selectedCompany.name} location');
                      },
                      child: const Text('Navigate'),
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
    );
  }
}