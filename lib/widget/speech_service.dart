import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:get/get.dart';
import 'package:FFinance/Controllers/ProfileController.dart'; // Pastikan Anda telah mengimport ProfileController

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _text = '';

  Future<void> speechToText() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
        onError: (e) {
          print('Speech recognition error: $e');
        },
      );
      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (result) {
            _text = result.recognizedWords;

            // Update postController di ProfileController
            final profileController = Get.find<ProfileController>();
            profileController.postController.text = _text;
            profileController.update();
          },
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
      // Simpan _text ke Firebase (opsional)
      // await _saveTextToFirebase(_text);
    }
  }

  // Fungsi untuk menyimpan teks ke Firebase (opsional)
  Future<void> _saveTextToFirebase(String text) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final timestamp = DateTime.now();

        await FirebaseFirestore.instance.collection('speech_data').add({
          'userId': userId,
          'text': text,
          'timestamp': timestamp,
        });

        print('Text saved to Firebase');
      }
    } catch (e) {
      print('Error saving text to Firebase: $e');
    }
  }
}