//testfile only for test
// ignore: file_names
// ntt_invntt_test.dart
// ignore_for_file: avoid_print

import 'dart:math';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void testNTT() {
  Random rnd = Random(42);
  Poly p = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    p.coeffs[i] = rnd.nextInt(KYBER_Q);
  }

  // ignore: always_specify_types
  List<int> original = List.from(p.coeffs);
  polyntt(p);
  polyinvntttomont(p);

  // After NTT and iNTT, the polynomial should be equivalent to the original mod q
  for (int i = 0; i < KYBER_N; i++) {
    if ((p.coeffs[i] - original[i]) % KYBER_Q != 0) {
      print("NTT/iNTT test failed at index $i");
      return;
    }
  }
  print("NTT/iNTT test passed!");
}
