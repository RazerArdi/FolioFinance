import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:FFinance/Controllers/auth_controller.dart';
import 'package:get_storage/get_storage.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    // Ini harus jalan pertama sebelum apapun yang berhubungan dengan Flutter
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables dengan optional flag true
    await dotenv.load(
      fileName: "assets/.env",
      mergeWith: Platform.environment,
      isOptional: true // Tambahkan ini agar file .env menjadi optional
    );

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase App Check setelah Firebase diinisialisasi
    await FirebaseAppCheck.instance.activate(
      // Gunakan webProvider untuk web platform
      // androidProvider: AndroidProvider.debug,
      // appleProvider: AppleProvider.debug,
    );

    // Initialize Auth Controller
    Get.put(AuthController());

    runApp(const MyApp());
  } catch (e) {
    print('Initialization Error: $e');
    // Tetap jalankan app meski ada error
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Folio Finance',
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}
