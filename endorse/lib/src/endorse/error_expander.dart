class ErrorExpander {
  final String field;
  final Object input;
  final String ruleName;
  final String msg;
  final Object wantValue;
  
  ErrorExpander(this.field, this.input, this.ruleName, this.msg, [this.wantValue]);
  
  @override
  String toString() {
    if (wantValue == null) {
      return '$field $msg';
    } else {
      return '$field $msg ${wantValue.toString()}';
    }
  } 
  
  Map<String, Object> expand() {
    if (wantValue == null) {
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