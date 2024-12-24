import 'package:FFinance/Controllers/company_controller.dart';
import 'package:FFinance/Models/company.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreController extends GetxController {
  final CompanyController companyController = Get.put(CompanyController());
  late final MapController mapController;
  Rx<LatLng?> initialCenter = Rx<LatLng?>(null);
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  RxBool isLoadingLocation = RxBool(true);

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    Get.put(mapController);
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
        userLocation.value = LatLng(position.latitude, position.longitude);
        initialCenter.value = LatLng(position.latitude, position.longitude);
        isLoadingLocation.value = false;
      } else {
        isLoadingLocation.value = false;
      }
    } catch (e) {
      isLoadingLocation.value = false;
    }
  }

  void centerOnUserLocation() {
    if (userLocation.value != null) {
      mapController.move(userLocation.value!, 10.0);
    }
  }

  void launchGoogleMaps(LatLng location) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      }
    } catch (e) {
      // Handle error if necessary
    }
  }

  void selectCompany(Company company) {
    companyController.selectedCompany.value = company;
  }
}
