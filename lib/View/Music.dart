import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/MusicPlayerController.dart';
import 'package:FFinance/Controllers/ConnectivityController.dart';
import 'AsynchronousComputingHome/AsynchronousComputingHome.dart';

class MusicPage extends StatelessWidget {
  final MusicPlayerController controller = Get.put(MusicPlayerController());
  final ConnectivityController connectivityController = Get.put(ConnectivityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Obx(() {
        // Jika tidak ada koneksi, tampilkan halaman No Internet
        if (!connectivityController.isConnected.value) {
          return AsynchronousComputingHome();
        }
        // Jika ada koneksi, tampilkan halaman Music Player
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cover Album
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: AssetImage('assets/images/eve.jpg'), // Path gambar
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 32),
              // Judul dan Artis
              Text(
                'Music1', // Judul lagu
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Kirouch', // Nama artis
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
              SizedBox(height: 32),
              // Slider
              Slider(
                value: controller.currentPosition.value,
                min: 0.0,
                max: controller.duration.value,
                onChanged: (value) {
                  controller.seek(value);
                },
              ),
              SizedBox(height: 32),
              // Tombol Play/Pause
              IconButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.black,
                ),
                iconSize: 60,
                onPressed: () {
                  if (controller.isPlaying.value) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
