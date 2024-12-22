// shake.dart

import 'dart:typed_data';

/// Implementation of SHAKE128 (XOF) based on Keccak as defined in FIPS 202.
/// SHAKE128 allows generating an output of arbitrary length from an input.
///
/// Characteristics of SHAKE128:
/// - Security: 128 bits
/// - Rate: 168 bytes (r=1344 bits)
/// - Padding according to SHAKE (0x1F)
///
/// This implementation:
/// - Absorbs the input using 'absorb'.
/// - After 'finalizeAbsorption', you can extract (squeeze) as many bytes as needed.
/// - The auxiliary function 'shake128(input, outlen)' facilitates obtaining the desired
///   output in a single call.
class SHAKE128 {
  static const int _rate = 168; // 168 bytes = 1344 bits, rate: SHAKE128
  // The capacity is derived, no need to store it, since Keccak-f[1600] is used.
  // _capacity = 1600 - 1344 = 256 bits, but it is not used directly here.

  // Internal state of Keccak: 25 words of 64 bits = 200 bytes.
  final Uint64List _state = Uint64List(25);

  bool _squeezing = false;
  final Uint8List _buffer = Uint8List(_rate);
  int _bufferPos = 0;

  SHAKE128();

  /// Absorbs data into the state. Can be called multiple times before finalizing.
  void absorb(Uint8List input) {
    if (_squeezing) {
      throw StateError(
          "No se puede absorber después de comenzar el 'squeeze'.");
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

  /// Finalizes the absorption phase. Applies SHAKE padding (0x1F) and prepares for squeezing.
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

  /// Extracts 'length' bytes. Can be called as many times as desired after absorption is finalized.
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
      output.setRange(offset, offset + toCopy,
          _buffer.sublist(_bufferPos, _bufferPos + toCopy));
      _bufferPos += toCopy;
      offset += toCopy;
    }
    return output;
  }

  /// Absorbs a block of data into the internal state, applying the permutation
  /// function after absorption.
  ///
  /// This function is used to absorb the input data into the internal state.
  /// It takes a block of data in the form of a list of bytes and XORs it into
  /// the internal state. After absorption, the permutation function is applied
  /// to the state to mix the data.
  ///
  /// The block size is determined by the rate of the XOF, which is 168 bytes
  /// for SHAKE128. The block is divided into 64-bit words, and each word is
  /// XORed into the corresponding 64-bit word of the internal state. After
  /// the absorption, the permutation function is applied to the state to mix
  /// the data.
  void _absorbBlock(Uint8List block) {
    for (int i = 0; i < _rate ~/ 8; i++) {
      _state[i] ^= _load64(block, 8 * i);
    }
    _keccakf();
  }

  /// Extracts a block of data from the internal state into the provided buffer.
  ///
  /// This function writes `_rate` bits (divided by 8 to convert to bytes)
  /// of the internal state into the `block` buffer, starting at index 0.
  /// The state is stored as 64-bit integers, and each integer is written
  /// into the buffer using the `_store64` function. This is typically used
  /// after the permutation function to retrieve the block of data for output.
  ///
  /// - [block]: The buffer into which the block of data is extracted. It is
  ///   assumed to be large enough to hold the extracted data.
  void _extractBlock(Uint8List block) {
    for (int i = 0; i < _rate ~/ 8; i++) {
      _store64(block, 8 * i, _state[i]);
    }
  }

  /// Loads a 64-bit integer value from 8 consecutive bytes in the list.
  ///
  /// The list is considered a list of bytes. The offset is treated as
  /// an index in the list, and the value is loaded from the 8 consecutive
  /// bytes starting at that index.
  ///
  /// The value is loaded in little-endian (the least significant byte
  /// is stored at the lowest index position).
  static int _load64(Uint8List x, int offset) {
    return (x[offset + 0] & 0xFF) |
        ((x[offset + 1] & 0xFF) << 8) |
        ((x[offset + 2] & 0xFF) << 16) |
        ((x[offset + 3] & 0xFF) << 24) |
        ((x[offset + 4] & 0xFF) << 32) |
        ((x[offset + 5] & 0xFF) << 40) |
        ((x[offset + 6] & 0xFF) << 48) |
        ((x[offset + 7] & 0xFF) << 56);
  }

  /// Stores a 64-bit integer value in 8 consecutive bytes in the list.
  ///
  /// The list is considered a list of bytes. The offset is treated as
  /// an index in the list, and the value is stored in the 8 consecutive
  /// bytes starting at that index.
  ///
  /// The value is stored in little-endian (the least significant byte
  /// is stored at the lowest index position).
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

  // Constants and rotations of Keccak-f[1600] (Keccak permutation)
  static const List<int> _rho = <int>[
    1,
    3,
    6,
    10,
    15,
    21,
    28,
    36,
    45,
    55,
    2,
    14,
    27,
    41,
    56,
    8,
    25,
    43,
    62,
    18,
    39,
    61,
    20,
    44
  ];

  static const List<int> _pi = <int>[
    10,
    7,
    11,
    17,
    18,
    3,
    5,
    16,
    8,
    21,
    24,
    4,
    15,
    23,
    19,
    13,
    12,
    2,
    20,
    14,
    22,
    9,
    6,
    1
  ];

  static const List<int> _roundConstants = <int>[
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

  /// Implements the Keccak-f[1600] permutation function.
  ///
  /// This is a core component of the SHAKE family of XOFs. It is a
  /// 1600-bit permutation function that takes a 1600-bit input and
  /// produces a 1600-bit output. The permutation is a sponge
  /// construction, which is a type of cryptographic permutation.
  ///
  /// The permutation is composed of 24 rounds of the following
  /// operations:
  ///
  /// 1. Theta: a linear transformation that computes the parity of
  ///    each row of the input, and then XORs each row with the
  ///    parity of the previous row.
  ///
  /// 2. Rho and Pi: a sequence of 24 rotations and permutations of
  ///    the input bits, which is designed to be invertible and
  ///    uniformly distribute the input bits.
  ///
  /// 3. Chi: a non-linear transformation that takes the output of
  ///    Rho and Pi, and computes the bitwise XOR of each row with
  ///    the output of the previous row.
  ///
  /// 4. Iota: a linear transformation that takes the output of Chi,
  ///    and XORs it with a round constant.
  ///
  /// The output of the permutation is the output of the final round
  /// of Iota.
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

  /// Rotates the bits of a 64-bit integer [x] to the left by [n] positions.
  ///
  /// The bits that overflow on the left are reintroduced on the right, effectively
  /// creating a circular shift. This operation is commonly used in cryptographic
  /// algorithms to provide diffusion.
  static int _rotl64(int x, int n) {
    return ((x << n) & 0xFFFFFFFFFFFFFFFF) | (x >> (64 - n));
  }
}

/// Helper function for easy use of SHAKE128.
/// Absorbs [input] and extracts [outlen] bytes from the XOF.
Uint8List shake128(Uint8List input, int outlen) {
  final SHAKE128 shake = SHAKE128();
  shake.absorb(input);
  shake.finalizeAbsorption();
  return shake.squeeze(outlen);
}

// Example of use:
//
// void main() {
//   Uint8List input = Uint8List.fromList([1, 2, 3]);
//   Uint8List out = shake128(input, 64); // 64 bytes of output
//   print(out);
// }
