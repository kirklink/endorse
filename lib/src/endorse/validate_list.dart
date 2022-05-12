import 'package:endorse/src/endorse/validate_value.dart';
import 'package:endorse/src/endorse/endorse_class_validator.dart';
import 'package:endorse/src/endorse/value_result.dart';
import 'package:endorse/src/endorse/list_result.dart';
import 'package:endorse/src/endorse/class_result.dart';

class ValidateList {
  final ValidateValue _fieldRules;
  ValidateValue? _itemRules;
  EndorseClassValidator? _validator;

  ValidateList.fromCore(this._fieldRules, this._itemRules);

  ValidateList.fromEndorse(this._fieldRules, this._validator);

  ListResult from(Object? items, String fieldName) {
    final fieldResult = _fieldRules.from(items, fieldName);

    if (items == null || !(items is List)) {
      return ListResult(fieldName, fieldResult, const []);
    } else {
      if (_validator != null) {
        final elements = <ClassResult>[];
        items.asMap().forEach((index, item) {
          final r = _validator!.validate(item);
          elements.add(r);
        });
        return ListResult(fieldName, fieldResult, elements);
      } else {
        final elements = <ValueResult>[];
        items.asMap().forEach((index, item) {
          final r = _itemRules!.from(item, '[$index]');
          elements.add(r);
        });
        return ListResult(fieldName, fieldResult, elements);
      }
    }
  }
}
