import 'package:FFinance/View/FirstLogORRegister.dart';
import 'package:FFinance/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/auth_controller.dart';

class DaftarPage extends StatefulWidget {
  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final AuthController controller = Get.put(AuthController());
  bool _isChecked = false; // Checkbox state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FirstLogORRegister()),
            );
          },
        ),
        title: const Text('Daftar'),
        actions: [
          Row(
            children: const [
              Icon(Icons.lock, size: 20),
              SizedBox(width: 5),
              Text('Terproteksi', style: TextStyle(fontSize: 14)),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(label: 'Alamat Email', hintText: 'Masukkan Email Anda'),
              const SizedBox(height: 15),
              _buildTextField(label: 'Password', hintText: 'Masukkan Password', obscureText: true),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                        controller.updateTermsAccepted(_isChecked); // Update the controller
                      });
                    },
                  ),
                  const Flexible(
                    child: Text(
                      'Saya menyetujui Syarat dan Ketentuan Kami',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  controller.registerWithEmail(); // Register the user
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4a90e2),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                  _showSocialMediaDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Daftar dengan Media Sosial',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscureText,
          onChanged: (value) {
            if (label == 'Alamat Email') {
              controller.updateEmail(value);
            } else if (label == 'Password') {
              controller.updatePassword(value);
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          ),
        ),
      ],
    );
  }

  void _showSocialMediaDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to scroll
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250, // Adjust the height as needed
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Daftar dengan Media Sosial',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Handle Google login
                  controller.signInWithGoogle();
                  Navigator.pop(context); // Close the modal
                },
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.google.path, // Replace with your Google image path
                      width: 40, // Adjust width as needed
                      height: 40, // Adjust height as needed
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Google',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Handle GitHub login (coming soon)
                  Get.snackbar('Coming Soon', 'GitHub login will be available soon.');
                  Navigator.pop(context); // Close the modal
                },
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.github_logo.path, // Replace with your GitHub image path
                      width: 40, // Adjust width as needed
                      height: 40, // Adjust height as needed
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'GitHub (Coming Soon)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Handle Microsoft login (coming soon)
                  Get.snackbar('Coming Soon', 'Microsoft login will be available soon.');
                  Navigator.pop(context); // Close the modal
                },
                child: Row(
                  children: [
                    Image.asset(
                      Assets.images.microsoft.path, // Replace with your Microsoft image path
                      width: 40, // Adjust width as needed
                      height: 40, // Adjust height as needed
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Microsoft (Coming Soon)',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
