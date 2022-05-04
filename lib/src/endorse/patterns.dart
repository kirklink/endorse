/// Patterns matching UUID types 3, 4, 5 and "all"
abstract class UUID {
  static const three =
      r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$';
  static const four =
      r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$';
  static const five =
      r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$';
  static const all =
      r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$';
}

/// Patterns for country postal codes.
///
/// Currently only US and Canada.
abstract class PostalCodes {
  static const ca =
      r'^[ABCEGHJKLMNPRSTVXY][0-9]([ABCEGHJKLMNPRSTVWXYZ][0-9]){2}$';
  static const us = r'^\\d{5}(-{0,1}\\d{4})?$';
}

/// Patterns for various strings.
abstract class Patterns {
  /// Single word containing only letter characters (upper and lower case).
  static const alphaWord = r'^[a-zA-Z]+$';

  /// Sentence containing only letter characters and common punctuation. Use
  /// with care.
  static const alphaSentence = r'''^[\s]*[A-Za-z,;'"\s.?!]+$''';

  /// Single word containing letter characters (upper and lower case) and
  /// digits (0-9).
  static const alphanumericWord = r'^[a-zA-Z0-9]+$';

  /// Single string of positive or negative (leading -) digits (0-9).
  static const numeric = r'^-?[0-9]+$';

  /// String that matches an integer pattern.
  static const integer = r'^(?:-?(?:0|[1-9][0-9]*))$';

  /// String that matches a float/double pattern.
  static const float =
      r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$';

  /// String of hexadecimal characters.
  static const hexadecimal = r'^[0-9a-fA-F]+$';

  /// String that matches a six character hexadecimal color.
  static const hexcolor = r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$';

  /// String that matches a standard email address pattern.
  // reference: https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
  static const email =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  /// String that matches a 10 digit phone number
  static const phone10digit = r'^[0-9]{10}$';
}
