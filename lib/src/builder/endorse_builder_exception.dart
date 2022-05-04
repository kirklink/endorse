class EndorseBuilderException implements Exception {
  String cause;
  EndorseBuilderException(this.cause);

  String toString() => cause;
}
