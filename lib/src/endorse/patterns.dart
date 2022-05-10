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

abstract class PostalCodes {
  static const ca =
      r'^[ABCEGHJKLMNPRSTVXY][0-9]([ABCEGHJKLMNPRSTVWXYZ][0-9]){2}$';
  static const us = r'^\\d{5}(-{0,1}\\d{4})?$';
}

abstract class Patterns {
  static const alphaWord = r'^[a-zA-Z]+$';
  static const alphaSentence = r'''^[\s]*[A-Za-z,;'"\s.?!]+$''';
  static const alphanumericWord = r'^[a-zA-Z0-9]+$';
  static const numeric = r'^-?[0-9]+$';
  static const integer = r'^(?:-?(?:0|[1-9][0-9]*))$';
  static const float =
      r'^(?:-?(?:[0-9]+))?(?:\.[0-9]*)?(?:[eE][\+\-]?(?:[0-9]+))?$';
  static const hexadecimal = r'^[0-9a-fA-F]+$';
  static const hexcolor = r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$';
  // reference: https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
  static const email =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static const phone10digit = r'^[0-9]{10}$';
}
