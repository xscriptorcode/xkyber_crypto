/*
import 'dart:io';
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() async {
  final xkyber = XKyberCryptoBase();

  // Paso 1: Generar claves
  final keyPair = xkyber.generateKeyPair();

  // Paso 2: Leer un archivo de texto
  final file = File('example.txt');
  final content = await file.readAsString();
  final message = Uint8List.fromList(content.codeUnits);

  // Paso 3: Cifrar el contenido del archivo
  final ciphertext = xkyber.encrypt(
    message,
    Uint8List.fromList(keyPair.publicKey.coefficients),
  );
  print('Encrypted file content: $ciphertext');

  // Paso 4: Descifrar el contenido
  final decrypted = xkyber.decrypt(
    ciphertext,
    Uint8List.fromList(keyPair.privateKey.coefficients),
  );
  final decryptedContent = String.fromCharCodes(decrypted);
  print('Decrypted file content: $decryptedContent');

  // Validar que el contenido descifrado sea igual al original
  assert(decryptedContent == content);
}
*/