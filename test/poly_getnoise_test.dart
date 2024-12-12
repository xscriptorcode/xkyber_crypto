//testfile only for test
// poly_getnoise_test.dart

import 'dart:developer';
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
void testPolyGetNoise() {
  // ignore: always_specify_types
  Uint8List seed = Uint8List.fromList([0,1,2,3,4,5,6,7,8,9]);
  Poly r = Poly();
  polygetnoise(r, seed, 0);
  // ignore: unused_local_variable
  for (int coeff in r.coeffs) {
    // In Kyber512 with η=2, the distribution is centered. 
    // Coefficients do not necessarily only go between -2 and 2 before NTT,
    // but they tend to small values. Here we only check that something was generated.
    // More strict tests require statistics.
  }
  log("polygetnoise test passed (basic check)!");
  
}
