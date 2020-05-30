import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:endorse/endorse.dart';

class MockValidationError extends Mock implements ValidationError {}

main() {
  test('Validation error has an error message.', () {
    var s = 'Error';
    var m = {'error': true};
    var v = ValidationError(s, m);
    expect(v.msg, equals('Error'));
  });
  test('Validation error has a map of errors', () {
    var s = 'Error';
    var m = {'error': true};
    var v = ValidationError(s, m);
    expect(v.expand, equals({'error': true}));
  });
}
