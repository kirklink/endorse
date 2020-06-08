import 'package:endorse/src/endorse/result_object.dart';
import 'package:endorse/src/endorse/value_result.dart';


class ListResult extends ResultObject {
  final ValueResult valueResult;
  final List<ResultObject> _itemResults;

  ListResult(this.valueResult, this._itemResults);

  bool get isValid => valueResult.isValid && _itemResults != null && !(_itemResults.any((e) => e.isValid == false));

  Object get value {
    if (_itemResults == null) {
      return null;
    }
    final r = <Object>[];
    for (final i in _itemResults) {
      r.add(i.value);
    }
    return r;
  }

  List<ResultObject> get list => _itemResults;
  
  Object get errors {
    
    if (!valueResult.isValid) {
      return valueResult.errors;
    }

    if (_itemResults != null && _itemResults.any((e) => !e.isValid)) {
      final itemErrors = <String, Object>{};

      _itemResults.asMap().forEach((index, item) {
        if (!item.isValid) {
          itemErrors['[$index]'] = item.errors;
        }
      });

      return List.from(_itemResults.map((i) => i.errors));
    }
    return [];
  }

}