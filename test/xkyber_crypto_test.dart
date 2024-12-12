/*
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  final xkyber = XKyberCryptoBase();

  // Generación de claves pública y privada
  final keyPair = xkyber.generateKeyPair();
  print('Clave pública: ${keyPair.publicKey.coefficients}');
  print('Clave privada: ${keyPair.privateKey.coefficients}');

  // Mensaje de ejemplo a cifrar
  final mensaje = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

  // Cifrado utilizando la clave pública
  final publicKeyUint8List = Uint8List.fromList(keyPair.publicKey.coefficients);
  final ciphertext = xkyber.encrypt(mensaje, publicKeyUint8List);
  print('Mensaje cifrado: $ciphertext');

  // Descifrado utilizando la clave privada
  final privateKeyUint8List =
      Uint8List.fromList(keyPair.privateKey.coefficients);
  final mensajeDescifrado = xkyber.decrypt(ciphertext, privateKeyUint8List);
  print('Mensaje descifrado: $mensajeDescifrado');

  // Generación de ruido determinístico
  final seed = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]);
  final ruido = xkyber.generateNoise(seed);
  print('Ruido determinístico generado: $ruido');
}
*/

