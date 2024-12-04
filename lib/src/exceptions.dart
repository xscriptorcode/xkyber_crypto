class InvalidInputException implements Exception {
  final String message;
  InvalidInputException(this.message);

  @override
  String toString() => 'InvalidInputException: $message';
}

class NoiseGenerationException implements Exception {
  final String message;
  NoiseGenerationException(this.message);

  @override
  String toString() => 'NoiseGenerationException: $message';
}
