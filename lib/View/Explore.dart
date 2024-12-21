import 'package:FFinance/Controllers/company_controller.dart';
import 'package:FFinance/Models/company.dart'; // Sesuaikan jalur jika diperlukan
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart'; // Tambahkan import
import 'AsynchronousComputingHome/AsynchronousComputingHome.dart'; // Tambahkan import

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final CompanyController companyController = Get.put(CompanyController());
  final ConnectivityController connectivityController = Get.put(ConnectivityController()); // Tambahkan instance dari ConnectivityController
  final TextEditingController searchController = TextEditingController();
  late final MapController _mapController;
  LatLng? initialCenter;
  LatLng? userLocation;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    Get.put(_mapController);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          initialCenter = LatLng(position.latitude, position.longitude);
          userLocation = LatLng(position.latitude, position.longitude);
          isLoadingLocation = false;
        });
      } else {
        Get.snackbar('Permission Denied',
            'Location permission is required to show your location on the map.');
        setState(() {
          isLoadingLocation = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to retrieve location');
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  void _launchGoogleMaps(LatLng location) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        Get.snackbar('Error', 'Could not launch Google Maps');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void _centerOnUserLocation() {
    if (userLocation != null) {
      _mapController.move(userLocation!, 10.0);
    } else {
      Get.snackbar('Location Unavailable',
          'Unable to find your current location');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika tidak ada koneksi, tampilkan halaman No Internet
    if (!connectivityController.isConnected.value) {
      return AsynchronousComputingHome();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              tooltip: 'Center on My Location',
              onPressed: _centerOnUserLocation,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Autocomplete<Company>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Company>.empty();
                }
                return companyController.companies.where((Company option) {
                  return option.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()) ||
                      option.symbol
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (Company option) => option.name,
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search companies by name or symbol...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        fieldTextEditingController.clear();
                        companyController.filterCompanies('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                );
              },
              onSelected: (Company selection) {
                companyController.goToCompanyLocation(selection);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredCompanies = companyController.filteredCompanies;

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter ?? LatLng(32.377716, -86.300568),
                  initialZoom: 10.0,
                  maxZoom: 18.0,
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
                        child: Tooltip(
                          message: '${company.name} (${company.symbol})',
                          child: GestureDetector(
                            onTap: () =>
                                companyController.selectCompany(company),
                            child: const Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (userLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 50.0,
                          height: 50.0,
                          point: userLocation!,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('My Location'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Latitude: ${userLocation!.latitude}'),
                                        Text(
                                            'Longitude: ${userLocation!.longitude}'),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () =>
                                              _launchGoogleMaps(userLocation!),
                                          child: Text(
                                            'Open in Google Maps',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                              TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.person_pin_circle,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
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
                        _mapController.move(
                          LatLng(
                            selectedCompany.latitude,
                            selectedCompany.longitude,
                          ),
                          12.0,
                        );
                      },
                      child: const Text('Center on Company'),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _launchGoogleMaps(
                        LatLng(
                          selectedCompany.latitude,
                          selectedCompany.longitude,
                        ),
                      ),
                      child: Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
