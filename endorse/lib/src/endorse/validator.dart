import 'package:endorse/src/endorse/result_object.dart';

abstract class Validator {
  ResultObject validate(Map<String, Object> input);
  List<ResultObject> validateList(List<Object> input);
}
