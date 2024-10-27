import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/auth_controller.dart';
import 'package:FFinance/gen/assets.gen.dart'; // Ensure correct import
import 'package:video_player/video_player.dart'; // Import the video player package

class FirstLogORRegister extends StatefulWidget {
  const FirstLogORRegister({super.key});

  @override
  _FirstLogORRegisterState createState() => _FirstLogORRegisterState();
}

class _FirstLogORRegisterState extends State<FirstLogORRegister> {
  final AuthController controller = Get.put(AuthController()); // Initialize the controller
  late VideoPlayerController _videoController; // Declare the video controller

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with the local video asset
    _videoController = VideoPlayerController.asset('assets/videos/Intro.mp4')
      ..setLooping(true) // Loop the video
      ..initialize().then((_) {
        setState(() {}); // Update state when initialized
        _videoController.play(); // Start playing the video
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // Dispose of the controller when not in use
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter, // Start from bottom
            end: Alignment.topCenter, // End at top
            colors: [
              Color(0xFF5B247A), // Purple at the bottom
              Color(0xFF004e92), // Blue in the middle
              Color(0xFF000000), // Black at the top
            ],
            stops: [0.0, 0.3, 0.55], // Control where each color stops
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: _buildHeader(),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildVideoPlayer(),
                      const SizedBox(height: 20),
                      _buildMainText(),
                      const SizedBox(height: 10),
                      _buildSubText(),
                      const SizedBox(height: 30),
                      _buildEmailInput(),
                      const SizedBox(height: 20),
                      _buildPasswordInput(),
                      const SizedBox(height: 20),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildSocialIcons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Eksplor Saham',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text('ID', style: TextStyle(color: Colors.white)),
              SizedBox(width: 5),
              Text('EN', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      width: 300,
      height: 250,
      child: _videoController.value.isInitialized
          ? VideoPlayer(_videoController)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMainText() {
    return const Text(
      'Mulai investasi kamu',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubText() {
    return const Text(
      'Daftar, verifikasi identitas kamu, dan top up untuk mendapatkan BTC senilai Rp5rb.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14, color: Colors.white),
    );
  }

  Widget _buildEmailInput() {
    return TextField(
      onChanged: controller.updateEmail,
      decoration: InputDecoration(
        hintText: 'Email',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return TextField(
      onChanged: controller.updatePassword,
      decoration: InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      obscureText: true, // Hides the password
    );
  }

  Widget _buildLoginButton() {
    return Obx(() {
      bool isButtonEnabled =
          controller.email.value.isNotEmpty && controller.password.value.isNotEmpty;

      return ElevatedButton(
        onPressed: isButtonEnabled ? controller.loginOrRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.orange : Colors.grey,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Daftar atau Log In'),
      );
    });
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Container(
            width: 45,
            height: 45,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Assets.images.google.image(width: 40, height: 40),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Assets.images.microsoft.image(width: 40, height: 40),
            onPressed: () {
              Get.snackbar('WhatsApp', 'WhatsApp login is not implemented yet.');
            },
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Assets.images.github_logo.image(width: 40, height: 40),
            onPressed: () {
              Get.snackbar('GitHub', 'GitHub login is not implemented yet.');
            },
          ),
        ),
      ],
    );
  }
}
