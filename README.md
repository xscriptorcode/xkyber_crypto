# xKyberCrypto

**xKyberCrypto** es una biblioteca que busca resolver inicialmente cifrado post-cuántico en fluter basándose en el algoritmo de Kyber, implementada en Dart. Esta biblioteca proporciona funcionalidades de generación de claves, cifrado y descifrado, diseñadas para aplicaciones que requieren alta seguridad criptográfica.

## Características

- Generación de pares de claves públicas y privadas mediante el algoritmo Kyber.
- Cifrado de mensajes usando una clave pública para producir una clave compartida.
- Descifrado de mensajes cifrados usando una clave privada para recuperar la clave compartida.
- Generación de ruido determinístico seguro utilizando AES en modo CTR.

## Instalación

Para instalar esta biblioteca en tu proyecto de Dart, agrega `xkyber_crypto` como dependencia en tu archivo `pubspec.yaml`:

```yaml
dependencies:
  xkyber_crypto:
    git:
      url: https://github.com/xscriptorcodexkyber_crypto.git
dart pub get
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  final xkyber = XKyberCryptoBase();

  // Generación de claves pública y privada
  final keyPair = xkyber.generateKeyPair();
  print('Clave pública: ${keyPair.publicKey}');
  print('Clave privada: ${keyPair.privateKey}');

  // Mensaje de ejemplo a cifrar
  final mensaje = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

  // Cifrado utilizando la clave pública
  final ciphertext = xkyber.encrypt(mensaje, keyPair.publicKey.coefficients);
  print('Mensaje cifrado: $ciphertext');

  // Descifrado utilizando la clave privada
  final mensajeDescifrado = xkyber.decrypt(ciphertext, keyPair.privateKey.coefficients);
  print('Mensaje descifrado: $mensajeDescifrado');

  // Generación de ruido determinístico
  final seed = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]);
  final ruido = xkyber.generateNoise(seed);
  print('Ruido determinístico generado: $ruido');
}

Este ejemplo muestra:

Cómo generar un par de claves pública y privada.
Cómo cifrar y descifrar un mensaje.
Cómo generar ruido determinístico seguro.
API
XKyberCryptoBase
La clase principal para interactuar con la biblioteca xKyberCrypto. Proporciona los siguientes métodos:

generateKeyPair(): Genera un par de claves públicas y privadas.
encrypt(Uint8List message, Uint8List publicKey): Cifra un mensaje usando la clave pública.
decrypt(List<int> ciphertext, Uint8List privateKey): Descifra un mensaje cifrado usando la clave privada.
generateNoise(Uint8List seed): Genera ruido determinístico a partir de una semilla.
Contribuciones
Las contribuciones son bienvenidas. Para contribuir:

Haz un fork de este repositorio.
Crea una rama nueva para tus cambios (git checkout -b feature/nueva-funcionalidad).
Realiza los cambios y haz commit (git commit -m 'Añade nueva funcionalidad').
Sube los cambios a tu repositorio (git push origin feature/nueva-funcionalidad).
Abre un Pull Request en este repositorio.

Licencia
Este proyecto está licenciado bajo la licencia MIT. Esta implementación de cifrado está inspirada en el algoritmo de Kyber y cumple con sus estándares para cifrado post-cuántico.