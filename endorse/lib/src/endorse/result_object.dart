import 'package:endorse/src/endorse/validation_error.dart';

abstract class ResultObject {
  Object get $value;
  String get $fieldName;
  bool? get $isValid;
  bool get $isNotValid;
  List<ValidationError> get $errors;
  Object get $errorsJson;
}
