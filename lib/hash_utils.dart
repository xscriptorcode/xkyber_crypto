// lib/crypto/hash_utils.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';

/// Simulación de SHAKE-128 usando SHA-256 en múltiples rondas
Uint8List generateExpandedSHA256(Uint8List data, int outputLength) {
  Uint8List result = Uint8List(outputLength);
  int offset = 0;
  int counter = 0;

  while (offset < outputLength) {
    // Combina los datos originales con el contador como parte de la expansión
    var counterBytes = Uint8List(4)..buffer.asByteData().setInt32(0, counter++, Endian.big);
    var combined = Uint8List.fromList(data + counterBytes);
    
    var hash = sha256.convert(combined).bytes;
    for (int i = 0; i < hash.length && offset < outputLength; i++) {
      result[offset++] = hash[i];
    }
  }
  return result;
}

// Uso: para generar un hash "expandido" de 64 bytes
Uint8List expandedHash = generateExpandedSHA256(Uint8List.fromList([1, 2, 3]), 64);
