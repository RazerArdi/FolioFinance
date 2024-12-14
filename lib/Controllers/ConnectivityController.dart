import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _connectivitySubscription;

  final RxBool isConnected = false.obs;
  final RxBool isCheckingConnectivity = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkConnectivity();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        print("Connectivity changed: $results"); // Tambahkan debug print
        bool newConnectionStatus = results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.mobile);

        if (isConnected.value != newConnectionStatus) {
          isConnected.value = newConnectionStatus;
          _showConnectivitySnackbar(newConnectionStatus);
        }
      },
    );
  }

  Future<void> checkConnectivity() async {
    try {
      isCheckingConnectivity.value = true;
      var connectivityResult = await _connectivity.checkConnectivity();

      print("Connectivity check result: $connectivityResult"); // Tambahkan debug print

      bool newConnectionStatus = connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile);

      isConnected.value = newConnectionStatus;
      _showConnectivitySnackbar(newConnectionStatus);
    } catch (e) {
      print("Connectivity check error: $e"); // Tambahkan debug print
      isConnected.value = false;
      _showConnectivitySnackbar(false);
    } finally {
      isCheckingConnectivity.value = false;
    }
  }

  void _showConnectivitySnackbar(bool connected) {
    // Pastikan snackbar ditampilkan menggunakan metode GetX
    if (!connected) {
      Get.rawSnackbar(
        title: "No Internet",
        message: "Please check your network settings",
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        duration: const Duration(seconds: 3), // Persistent
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    } else {
      Get.rawSnackbar(
        title: "Connected",
        message: "Internet connection restored",
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.wifi, color: Colors.white),
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}