import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:FFinance/Controllers/SplashController.dart'; // Import your SplashController

// Halaman untuk menampilkan animasi splash screen
class AnimatedSplashScreenPage extends StatelessWidget {
  const AnimatedSplashScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar belakang dengan gradien warna
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xffD488D4), const Color(0xff6E35B1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Widget AnimatedSplashScreen untuk menampilkan logo dengan animasi transisi
          AnimatedSplashScreen(
            splash: 'assets/Images/Logo_umm.png', // Your splash image
            nextScreen: const SplashScreen(), // Halaman berikutnya setelah splash
            splashTransition: SplashTransition.fadeTransition, // Transition effect
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: Colors.transparent,
            duration: 1000,
          ),
        ],
      ),
    );
  }
}

// Halaman SplashScreen yang ditampilkan setelah animasi splash
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SplashController controller = Get.put(SplashController());
    controller.navigateToHome(); // Start navigation

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xffD488D4), const Color(0xff6E35B1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/Images/Logo_umm.png', // Your splash image
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Folio Finance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Official Mobile Application',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Powered by Pratikum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
