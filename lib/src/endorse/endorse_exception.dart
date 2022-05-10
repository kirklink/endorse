class EndorseException implements Exception {
  final String cause;
  EndorseException(this.cause);
  @override
  String toString() => cause;
}
