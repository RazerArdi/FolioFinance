import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:FFinance/Controllers/MusicPlayerController.dart';

class MusicPage extends StatelessWidget {
  final controller = Get.put(MusicPlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Container(
        child: Center(
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cover Album (Contoh)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: AssetImage('assets/images/eve.jpg'), // Ganti dengan path gambar Anda
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 32),
              // Judul dan Artis (Contoh)
              Text(
                'Music1', // Ganti dengan judul lagu
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              SizedBox(height: 8),
              Text(
                'Kirouch', // Ganti dengan nama artis
                style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 0, 0, 0)),
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
                  color: const Color.fromARGB(255, 0, 0, 0),
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
          )),
        ),
      ),
    );
  }
}