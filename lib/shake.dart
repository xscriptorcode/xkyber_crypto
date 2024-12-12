// shake.dart
//
// Implementación de SHAKE128 (XOF) basada en Keccak tal como lo define FIPS 202.
// SHAKE128 permite generar una salida de longitud arbitraria a partir de una entrada.
//
// Características de SHAKE128:
// - Seguridad: 128 bits
// - Rate: 168 bytes (r=1344 bits)
// - Uso de padding según SHAKE (0x1F)
//
// Esta implementación:
// - Absorbe el input usando 'absorb'.
// - Después de 'finalizeAbsorption', se puede extraer (squeeze) tantos bytes como se desee.
// - La función auxiliar 'shake128(input, outlen)' facilita obtener de una sola vez
//   la salida deseada.
//
// Se recomienda verificar esta implementación contra vectores de prueba oficiales
// para garantizar su corrección.

import 'dart:typed_data';

class SHAKE128 {
  static const int _rate = 168; // 168 bytes = 1344 bits, rate de SHAKE128
  // La capacidad se deriva, no es necesaria almacenar, ya que se usa Keccak-f[1600].
  // _capacity = 1600 - 1344 = 256 bits, pero no se usa directamente aquí.

  // Estado interno de Keccak: 25 palabras de 64 bits = 200 bytes.
  final Uint64List _state = Uint64List(25);

  bool _squeezing = false; 
  final Uint8List _buffer = Uint8List(_rate);
  int _bufferPos = 0;

  SHAKE128();

  /// Absorbe datos en el estado. Puede llamarse múltiples veces antes de finalizar.
  void absorb(Uint8List input) {
    if (_squeezing) {
      throw StateError("No se puede absorber después de comenzar el 'squeeze'.");
    }

    int offset = 0;
    while (offset < input.length) {
      int toCopy = _rate - _bufferPos;
      if (toCopy > input.length - offset) {
        toCopy = input.length - offset;
      }
      _buffer.setRange(_bufferPos, _bufferPos + toCopy, input, offset);
      _bufferPos += toCopy;
      offset += toCopy;

      if (_bufferPos == _rate) {
        _absorbBlock(_buffer);
        _bufferPos = 0;
      }
    }
  }

  /// Finaliza la fase de absorción. Aplica el padding para SHAKE (0x1F) y prepara para exprimir.
  void finalizeAbsorption() {
    if (!_squeezing) {
      // Padding para SHAKE: añadir 0x1F (00011111)
      _buffer[_bufferPos++] = 0x1F;
      while (_bufferPos < _rate) {
        _buffer[_bufferPos++] = 0x00;
      }
      // Establecer el bit final (0x80) en el último byte
      _buffer[_rate - 1] |= 0x80;

      _absorbBlock(_buffer);
      _bufferPos = 0;
      _squeezing = true;
    }
  }

  /// Extrae 'length' bytes. Puede llamarse tantas veces como se desee después de finalizar la absorción.
  Uint8List squeeze(int length) {
    if (!_squeezing) {
      finalizeAbsorption();
    }
    Uint8List output = Uint8List(length);
    int offset = 0;
    while (offset < length) {
      if (_bufferPos == _rate) {
        _keccakf();
        _extractBlock(_buffer);
        _bufferPos = 0;
      }
      int toCopy = _rate - _bufferPos;
      if (toCopy > length - offset) {
        toCopy = length - offset;
      }
      output.setRange(offset, offset + toCopy, _buffer.sublist(_bufferPos, _bufferPos + toCopy));
      _bufferPos += toCopy;
      offset += toCopy;
    }
    return output;
  }

  void _absorbBlock(Uint8List block) {
    for (int i = 0; i < _rate ~/ 8; i++) {
      _state[i] ^= _load64(block, 8 * i);
    }
    _keccakf();
  }

  void _extractBlock(Uint8List block) {
    for (int i = 0; i < _rate ~/ 8; i++) {
      _store64(block, 8 * i, _state[i]);
    }
  }

  static int _load64(Uint8List x, int offset) {
    return (x[offset + 0] & 0xFF)
        | ((x[offset + 1] & 0xFF) << 8)
        | ((x[offset + 2] & 0xFF) << 16)
        | ((x[offset + 3] & 0xFF) << 24)
        | ((x[offset + 4] & 0xFF) << 32)
        | ((x[offset + 5] & 0xFF) << 40)
        | ((x[offset + 6] & 0xFF) << 48)
        | ((x[offset + 7] & 0xFF) << 56);
  }

  static void _store64(Uint8List x, int offset, int val) {
    x[offset + 0] = val & 0xFF;
    x[offset + 1] = (val >> 8) & 0xFF;
    x[offset + 2] = (val >> 16) & 0xFF;
    x[offset + 3] = (val >> 24) & 0xFF;
    x[offset + 4] = (val >> 32) & 0xFF;
    x[offset + 5] = (val >> 40) & 0xFF;
    x[offset + 6] = (val >> 48) & 0xFF;
    x[offset + 7] = (val >> 56) & 0xFF;
  }

  // Constantes y rotaciones de Keccak-f[1600]
  static const List<int> _rho = [
    1, 3, 6, 10, 15, 21, 28, 36, 45, 55,
    2, 14, 27, 41, 56, 8, 25, 43, 62,
    18, 39, 61, 20, 44
  ];

  static const List<int> _pi = [
    10, 7, 11, 17, 18, 3, 5, 16, 8, 21,
    24, 4, 15, 23, 19, 13, 12, 2, 20,
    14, 22, 9, 6, 1
  ];

  static const List<int> _roundConstants = [
    0x0000000000000001,
    0x0000000000008082,
    0x800000000000808A,
    0x8000000080008000,
    0x000000000000808B,
    0x0000000080000001,
    0x8000000080008081,
    0x8000000000008009,
    0x000000000000008A,
    0x0000000000000088,
    0x0000000080008009,
    0x000000008000000A,
    0x000000008000808B,
    0x800000000000008B,
    0x8000000000008089,
    0x8000000000008003,
    0x8000000000008002,
    0x8000000000000080,
    0x000000000000800A,
    0x800000008000000A,
    0x8000000080008081,
    0x8000000000008080,
    0x0000000080000001,
    0x8000000080008008
  ];

  void _keccakf() {
    Uint64List a = _state;
    Uint64List b = Uint64List(5);
    Uint64List t = Uint64List(25);
    for (int round = 0; round < 24; round++) {
      // Theta
      for (int i = 0; i < 5; i++) {
        b[i] = a[i] ^ a[i + 5] ^ a[i + 10] ^ a[i + 15] ^ a[i + 20];
      }
      for (int i = 0; i < 5; i++) {
        int tmp = b[(i + 4) % 5] ^ _rotl64(b[(i + 1) % 5], 1);
        for (int j = 0; j < 25; j += 5) {
          a[j + i] ^= tmp;
        }
      }

      // Rho and Pi
      int tVal = a[1];
      for (int i = 0; i < 24; i++) {
        int j = _pi[i];
        b[0] = a[j];
        a[j] = _rotl64(tVal, _rho[i]);
        tVal = b[0];
      }

      // Chi
      for (int j = 0; j < 25; j += 5) {
        for (int i = 0; i < 5; i++) {
          t[i] = a[j + i];
        }
        for (int i = 0; i < 5; i++) {
          a[j + i] = t[i] ^ ((~t[(i + 1) % 5]) & t[(i + 2) % 5]);
        }
      }

      // Iota
      a[0] ^= _roundConstants[round];
    }
  }

  static int _rotl64(int x, int n) {
    return ((x << n) & 0xFFFFFFFFFFFFFFFF) | (x >> (64 - n));
  }
}

/// Función auxiliar para usar SHAKE128 fácilmente.
/// Absorbe [input] y extrae [outlen] bytes del XOF.
Uint8List shake128(Uint8List input, int outlen) {
  final shake = SHAKE128();
  shake.absorb(input);
  shake.finalizeAbsorption();
  return shake.squeeze(outlen);
}

// Ejemplo de uso:
//
// void main() {
//   Uint8List input = Uint8List.fromList([1, 2, 3]);
//   Uint8List out = shake128(input, 64); // 64 bytes de salida
//   print(out);
// }
