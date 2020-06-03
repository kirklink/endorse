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
  
  Map<String, Object> expand([String field = '']) {
    if (wantValue == null) {
      return {
        ruleName: {
          'message': this.toString(),
          'got': input.toString()  
        }
      };
    } else {
      return {
        ruleName: {
          'message': this.toString(),
          'want': wantValue.toString(),
          'got': input.toString()
        }
      };
    }
  }

}