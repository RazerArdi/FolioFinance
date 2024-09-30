import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Routes/app_routes.dart'; // Import your app routes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Folio Finance',
      initialRoute: AppRoutes.splashScreen, // Set initial route
      getPages: AppRoutes.routes, // Set up the routes
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}
