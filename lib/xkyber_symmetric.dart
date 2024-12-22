// xkyber_symmetric.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class XKyberCrypto {
  static Future<Uint8List> generateSymmetricKey() async {
    final AesGcm algorithm = AesGcm.with256bits();
    final SecretKey secretKey = await algorithm.newSecretKey();

    final List<int> bytes = await secretKey.extractBytes();

    return Uint8List.fromList(bytes);
  }

  static Future<String> symmetricEncrypt(String plaintext, Uint8List keyBytes) async {
    final AesGcm algorithm = AesGcm.with256bits();
    final List<int> nonce = algorithm.newNonce();
    final SecretKey secretKey = SecretKey(keyBytes);

    final SecretBox secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    final Uint8List combined = Uint8List.fromList([
      ...nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
    return base64Encode(combined);
  }

  static Future<String> symmetricDecrypt(String ciphertextBase64, Uint8List keyBytes) async {
    final AesGcm algorithm = AesGcm.with256bits();
    final Uint8List decoded = base64Decode(ciphertextBase64);

    final int nonceLength = algorithm.nonceLength;
    final List<int> nonce = decoded.sublist(0, nonceLength);
    final List<int> cipherText = decoded.sublist(nonceLength, decoded.length - 16);
    final List<int> macBytes = decoded.sublist(decoded.length - 16);

    final SecretBox secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));
    final SecretKey secretKey = SecretKey(keyBytes);

    final List<int> decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return utf8.decode(decrypted);
  }
}
