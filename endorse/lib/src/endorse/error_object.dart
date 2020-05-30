class ErrorObject {
  final String field;
  final Object input;
  final String ruleName;
  final String msg;
  final Object testValue;
  final Object wantValue;
  
  ErrorObject(this.field, this.input, this.ruleName, this.msg, [this.testValue, this.wantValue]);
  
  @override
  String toString() {
    if (testValue == null) {
      return '$field $msg';
    } else {
      return '$field $msg ${testValue.toString()}';
    }
  } 
  
  Map<String, Object> map() {
    if (testValue == null) {
      return {
        'validation': ruleName,
        'message': this.toString(),
        'got': input.toString()
      };
    } else {
      return {
        'validation': ruleName,
        'message': this.toString(),
        'want': wantValue.toString(),
        'got': input.toString()
      };
    }
  }

}