class ErrorExpander {
  final Object input;
  final String ruleName;
  final String msg;
  final Object wantValue;
  
  ErrorExpander(this.input, this.ruleName, this.msg, [this.wantValue]);
  
  @override
  String toString() => '$msg';
  
  Map<String, Object> expand() {
    if (wantValue == null) {
      return {
        'rule': ruleName,
        'message': this.toString(),
        'got': input.toString()  
      };
    } else {
      return {
        'rule': ruleName,
        'message': this.toString(),
        'want': wantValue.toString(),
        'got': input.toString()
      };
    }
  }

}