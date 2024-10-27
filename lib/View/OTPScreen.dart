import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/phone_auth_controller.dart';

class OTPScreen extends StatelessWidget {
  final PhoneAuthController controller = Get.find();
  final TextEditingController otpController = TextEditingController();

  OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            Obx(() {
              return ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.verifyOTP(otpController.text),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Verify'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
