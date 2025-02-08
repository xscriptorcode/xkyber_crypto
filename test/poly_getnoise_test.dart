// poly_getnoise_test.dart
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  group('Poly GetNoise', () {
    test('polygetnoise generates a non-zero polynomial', () {
      // Create a seed with length KYBER_SYMBYTES (32 bytes)
      Uint8List seed = Uint8List.fromList(List<int>.generate(KYBER_SYMBYTES, (i) => i));
      
      Poly r = Poly();
      polygetnoise(r, seed, 0);
      
      // Check that at least one coefficient is non-zero.
      bool nonZeroFound = r.coeffs.any((c) => c != 0);
      expect(nonZeroFound, isTrue,
          reason: "All coefficients are zero, expected some noise.");
    });
  });
}
