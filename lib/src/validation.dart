import 'package:endorse/src/value.dart';

abstract class Validation {
  bool _isValid;

  get isValid => _isValid;
}

class ValidationSchema extends Validation {
  Map<String, Value> _values = Map<String, Value>();
  Map<String, ValidationSchema> _maps = Map<String, ValidationSchema>();
  Map<String, List<Value>> _valueLists = Map<String, List<Value>>();
  Map<String, List<ValidationSchema>> _objectLists =
      Map<String, List<ValidationSchema>>();

  ValidationSchema(
      this._values, this._valueLists, this._objectLists, this._maps) {
    if (_values.isEmpty &&
        _valueLists.isEmpty &&
        _objectLists.isEmpty &&
        _maps.isEmpty) {
      _isValid = false;
    }
    if (_isValid == null) {
      _crawl((Value v) {
        if (v.isValid == false) _isValid = false;
      }, stopOnFirstError: true);
    }
    if (_isValid == null) _isValid = true;
  }

  Map<String, dynamic> _crawl(Function f, {bool stopOnFirstError: false}) {
    var r = Map<String, dynamic>();
    if (_values != null && _values.isNotEmpty) {
      for (var k in _values.keys) {
        var v = f(_values[k]);
        bool isEmpty = false;
        try {
          isEmpty = v.isEmpty;
        } catch (e) {
          isEmpty = false;
        }
        if (v != null && !isEmpty) {
          r[k] = v;
          if (stopOnFirstError) return r;
        }
      }
    }
    if (_valueLists != null && _valueLists.isNotEmpty) {
      for (var k in _valueLists.keys) {
        var l = List<dynamic>();
        for (var i in _valueLists[k]) {
          var v = f(i);
          l.add(v);
        }
        if (l.length > 0) {
          r[k] = l;
          if (stopOnFirstError) return r;
        }
      }
    }
    if (_objectLists != null && _objectLists.isNotEmpty) {
      for (var k in _objectLists.keys) {
        var l = List<dynamic>();
        for (var i in _objectLists[k]) {
          l.add(i._crawl(f, stopOnFirstError: stopOnFirstError));
        }
        r[k] = l;
      }
    }
    if (_maps != null && _maps.isNotEmpty) {
      for (var k in _maps.keys) {
        r[k] = _maps[k]._crawl(f, stopOnFirstError: stopOnFirstError);
      }
    }
    return r;
  }

  Map<String, dynamic> values({bool unsafe: false}) {
    if (_isValid || unsafe) {
      return _crawl((Value v) => v?.value);
    } else {
      return null;
    }
  }

  Map<String, dynamic> errorMessages() {
    if (!_isValid) {
      return _crawl((Value v) {
        var m = v.errorMessages();
        if (m.isNotEmpty) return m;
        if (m.isEmpty) return [];
        return null;
      });
    } else {
      return {};
    }
  }

  Map<String, dynamic> errorMap() {
    if (!isValid) {
      var map = _crawl((Value v) {
        var m = v.errorMap();
        if (m.isNotEmpty) return m;
        if (m.isEmpty) return {};
        return null;
      });
      return {'validationErrors': map};
    } else {
      return {};
    }
  }

  Map<String, dynamic> allErrors() {
    if (!isValid) {
      return _crawl((Value v) {
        var m = v.allErrors();
        if (m != null && m.isNotEmpty) return m;
        return null;
      });
    } else {
      return {};
    }
  }
}

class ValidationValue extends Validation {
  Value _value;

  ValidationValue(this._value) {
    _isValid = _value.errorMessages().length == 0;
  }

  dynamic values({bool unsafe: false}) {
    if (_isValid || unsafe) {
      return _value.value;
    }
    return null;
  }

  List<dynamic> errorMessages() {
    if (!_isValid) {
      return _value.errorMessages();
    }
    return [];
  }

  Map<String, dynamic> errorMap() {
    if (!_isValid) {
      return _value.errorMap();
    }
    return {};
  }
}
