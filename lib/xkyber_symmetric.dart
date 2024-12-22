// xkyber_symmetric.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class XKyberCrypto {
  /// Generates a 256-bit symmetric key using AES-GCM and returns it as a `Uint8List`.
  ///
  /// The returned key is suitable for use with the `encryptData` and `decryptData`
  /// functions in this class.
  static Future<Uint8List> generateSymmetricKey() async {
    final AesGcm algorithm = AesGcm.with256bits();
    final SecretKey secretKey = await algorithm.newSecretKey();

    final List<int> bytes = await secretKey.extractBytes();

    return Uint8List.fromList(bytes);
  }

  /// Encrypts the given plaintext using the given keyBytes with AES-GCM and returns
  /// the result as a base64-encoded string.
  ///
  /// The output string is of the form:
  ///
  ///   <nonce (12 bytes)><ciphertext (variable length)><MAC (16 bytes)>
  ///
  /// The nonce is randomly generated and is included in the output string.
  ///
  /// The caller is responsible for storing the nonce securely, as it is
  /// necessary for decryption.
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

  /// Decrypts the given ciphertextBase64 using the given keyBytes with AES-GCM and
  /// returns the result as a UTF-8-decoded string.
  ///
  /// The input ciphertextBase64 is expected to be a base64-encoded string of the
  /// form:
  ///
  ///   <nonce (12 bytes)><ciphertext (variable length)><MAC (16 bytes)>
  ///
  /// The nonce is expected to be present in the ciphertext and is not stored
  /// separately.
  ///
  /// The caller is responsible for ensuring that the keyBytes are the same as
  /// those used for encryption.
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
