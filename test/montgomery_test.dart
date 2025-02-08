// montgomery_test.dart
// ignore_for_file: always_specify_types

import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart'; // Asegúrate de que exporte toMontgomery y fromMontgomery

void main() {
  group('Montgomery Conversion', () {
    test('fromMontgomery(toMontgomery(1)) equals 169 mod q', () {
      // According to the Kyber/PQClean implementation,
      // toMontgomery(1) = fqmul(1, 2285) yields 3328,
      // and fromMontgomery(3328) yields 169.
      expect(fromMontgomery(toMontgomery(1)) % 3329, equals(169));
    });
    // Puedes agregar más tests con valores conocidos si se dispone de ellos.
  });
}
