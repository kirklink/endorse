typedef String PreCondition(Object? input, Object? test);
typedef bool PassFuntion(Object? input, Object? test);
typedef String GotFunction(Object? input, Object? test);
typedef String WantFunction(Object? input, Object? test);
typedef Object? CastFunction(Object? input);
typedef String ErrorMessage(Object? input, Object? test);

abstract class Rule {
  final String name = '';
  final bool skipIfNull = true;
  final bool causesBail = false;
  final bool escapesBail = false;
  final PreCondition check = (input, test) => '';
  final PassFuntion pass = (input, test) => true;
  final GotFunction got = (input, test) => '';
  final WantFunction want = (input, test) => '';
  final CastFunction cast = (input) => input;
  final ErrorMessage errorMsg = (input, test) => '';
}
