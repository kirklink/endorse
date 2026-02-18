import 'package:recase/recase.dart';

String recaseFieldName(int enumValue, String fieldName) {
  final rc = ReCase(fieldName);
  switch (enumValue) {
    case 0: return fieldName;
    case 1: return rc.camelCase;
    case 2: return rc.snakeCase;
    case 3: return rc.pascalCase;
    case 4: return rc.paramCase;
    default: return fieldName;
  }
}
