typedef bool PassFuntion(Object input, Object test);
typedef Object GotFunction(Object input, Object test);
typedef Object WantFunction(Object input, Object test);
typedef Object CastFunction(Object input);
typedef String ErrorMessage(Object input, Object test);

abstract class Rule {
  final String name = '';
  final bool skipIfNull = true;
  final bool causesBail = false;
  final bool escapesBail = false;
  final PassFuntion pass = (input, test) => true; 
  final GotFunction got = (input, test) => null;
  final WantFunction want = (input, test) => null;
  final CastFunction cast = (input) => input;
  final ErrorMessage errorMsg = (input, test) => '';
}