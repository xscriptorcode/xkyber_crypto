import 'dart:math';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void testNTT() {
  Random rnd = Random(42);
  Poly p = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    p.coeffs[i] = rnd.nextInt(KYBER_Q);
  }

  List<int> original = List.from(p.coeffs);
  poly_ntt(p);
  poly_invntt_tomont(p);

  // Después de NTT y iNTT, el polinomio debería ser equivalente al original mod q
  for (int i = 0; i < KYBER_N; i++) {
    if ((p.coeffs[i] - original[i]) % KYBER_Q != 0) {
      print("NTT/iNTT test failed at index $i");
      return;
    }
  }
  print("NTT/iNTT test passed!");
}
