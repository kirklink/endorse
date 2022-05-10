
class ValidationError {
  final String rule;
  final String message;
  final Object got;
  final String want;

  const ValidationError(this.rule, this.message, this.got, [this.want = '']);

  @override
  String toString() => message;

  Map<String, Map<String, String>> toJson() {
    final result = <String, Map<String, String>>{};

    final content = <String, String>{};
    content['message'] = message;
    content['got'] = got.toString();
    if (want != null && want.isNotEmpty) {
      content['want'] = want.toString();
    }
    result[rule] = content;
    return result;
  }
}
