// ntt_invntt_test.dart
// ignore_for_file: avoid_print, always_specify_types, constant_identifier_names

import 'dart:math';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart'; // Asegúrate de que este paquete exporte ntt, invntt, toMontgomery, and fromMontgomery

// Kyber parameters.
const int KYBER_N = 256;
const int KYBER_Q = 3329;

void main() {
  group('NTT/iNTT', () {
    test('Recovered polynomial is congruent to the original modulo KYBER_Q',
        () {
      final Random rnd = Random(42);

      // Generate a random polynomial of length KYBER_N with coefficients in [0, KYBER_Q-1].
      final List<int> poly =
          List<int>.generate(KYBER_N, (_) => rnd.nextInt(KYBER_Q));

      // Save the original polynomial for later comparison.
      final List<int> original = List<int>.from(poly);

      // Convert the polynomial to Montgomery representation.
      final List<int> polyMont = poly.map((x) => toMontgomery(x)).toList();

      // Apply the forward NTT transform.
      final List<int> polyNTT = ntt(polyMont);

      // Apply the inverse NTT transform.
      final List<int> polyInvNTT = invntt(polyNTT);

      // Si invntt ya multiplica por el factor de escala y devuelve el resultado en el dominio estándar,
      // no es necesario aplicar fromMontgomery nuevamente.
      final List<int> polyRecovered =
          polyInvNTT; // O, si fuera necesario, aplicar fromMontgomery a cada coeficiente.

      // Verify that the recovered polynomial is congruent to the original modulo KYBER_Q.
      for (int i = 0; i < KYBER_N; i++) {
        final int diff = (polyRecovered[i] - original[i]) % KYBER_Q;
        expect(diff, equals(0),
            reason:
                'Mismatch at index $i: original ${original[i]}, recovered ${polyRecovered[i]}');
      }
    });
  });
}
