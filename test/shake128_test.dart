// shake128_test.dart
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  group('SHAKE128', () {
    test('Generates output of correct length and non-empty', () {
      // Create a simple input vector.
      Uint8List input = Uint8List.fromList([1, 2, 3]);
      
      // Generate 64 bytes of output using SHAKE128.
      Uint8List output = shake128(input, 64);
      
      // Check that the output has the expected length.
      expect(output.length, equals(64));
      
      // Check that the output is not all zeros.
      bool nonZero = output.any((byte) => byte != 0);
      expect(nonZero, isTrue, reason: "SHAKE128 output is all zeros.");
      
      // Optionally: Compare against a known test vector.
      // Example:
      // final Uint8List expected = Uint8List.fromList([...]);
      // expect(output, equals(expected));
    });
  });
}
