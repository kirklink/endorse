import 'package:endorse/src/endorse/class_result.dart';

abstract class EndorseClassValidator {
  ClassResult validate(Map<String, Object?> input);
}
