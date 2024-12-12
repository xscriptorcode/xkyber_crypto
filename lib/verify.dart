// verify.dart
//
// Este archivo proporciona funciones para realizar ciertas operaciones
// en tiempo constante, evitando filtraciones de información a través
// de canales laterales como el tiempo de ejecución.
//
// Estas funciones son críticas para la seguridad de Kyber en su modo IND-CCA2,
// ya que garantizan que la respuesta del descifrado no dependa de diferencias
// sutiles cuando la entrada es incorrecta.
//
// "verify" compara dos vectores de bytes en tiempo constante.
// "cmov" copia condicionalmente un vector en otro, también en tiempo constante.

import 'dart:typed_data';

/// Compara dos arreglos de bytes [a] y [b] en tiempo constante.
/// Retorna `true` si son idénticos, `false` en caso contrario.
/// Esta función evita atajos de tiempo (early exits) que podrían filtrar información.
bool verify(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  int r = 0;
  for (int i = 0; i < a.length; i++) {
    r |= a[i] ^ b[i];
  }
  return r == 0;
}

/// Copia el contenido de [x] en [r] si [b] es 1, de lo contrario no hace nada.
/// La operación se realiza en tiempo constante, sin que su tiempo varíe
/// en función de los datos, sólo de la longitud.
///
/// - [r]: buffer de destino.
/// - [x]: buffer de origen.
/// - [len]: cantidad de bytes a copiar.
/// - [b]: bit de control (0 o 1).
void cmov(Uint8List r, Uint8List x, int len, int b) {
  // Si b=1, debemos copiar x en r.
  // Si b=0, no copiamos nada.
  // Convertimos b a -b & 0xFF para crear una máscara completa si b=1.
  b = -b & 0xFF;
  for (int i = 0; i < len; i++) {
    r[i] ^= b & (r[i] ^ x[i]);
  }
}
