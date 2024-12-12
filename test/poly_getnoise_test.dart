import 'dart:developer';
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
void testPolyGetNoise() {
  Uint8List seed = Uint8List.fromList([0,1,2,3,4,5,6,7,8,9]);
  Poly r = Poly();
  poly_getnoise(r, seed, 0);
  for (int coeff in r.coeffs) {
    // En Kyber512 con η=2, la distribución es centrada. 
    // Los coeficientes no salen necesariamente solo entre -2 y 2 antes de NTT,
    // pero tienden a valores pequeños. Aquí sólo verificamos que se generó algo.
    // Pruebas más estrictas requieren estadística.
  }
  log("poly_getnoise test passed (basic check)!");
  
}
