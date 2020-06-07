import 'package:endorse/annotations.dart';
import 'package:endorse/src/endorse/class_result.dart';

abstract class EndorseClassValidator {
  ClassResult validate(Map<String, Object> input);
  ClassResult invalid(ValueResult mapMetaResult);
}
