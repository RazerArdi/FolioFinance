import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class Aes256Helper {
  static AesKeys generateRandomKeyAndIV() {
    final key = Key.fromSecureRandom(32); // 32 bytes for AES-256
    final iv = IV.fromSecureRandom(16); // 16 bytes for AES-256 in GCM mode

    return AesKeys(key: base64Encode(key.bytes), iv: base64Encode(iv.bytes));
  }

  static String encrypt(String text, AesKeys keys) {
    Key key = Key.fromBase64(keys.key);
    IV iv = IV.fromBase64(keys.iv);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    final encryptedBase64 = encrypted.base64;

    return encryptedBase64;
  }

  static String decrypt(String cipherText, AesKeys keys) {
    Key key = Key.fromBase64(keys.key);
    IV iv = IV.fromBase64(keys.iv);

    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: iv);
    final decryptedText = decrypted;

    return decryptedText;
  }
}

class AesKeys {
  final String key, iv;
  const AesKeys({required this.key, required this.iv});
}


/*
final text = 'Hello, World!';

final keys = Aes256Helper.generateRandomKeyAndIV();

final cipherText = Aes256Helper.encrypt(text, keys);

final decryptText = Aes256Helper.decrypt(cipherText, keys);

print('Encrypted: $cipherText\n');
print('Decrypted: $decryptText\n');
 */