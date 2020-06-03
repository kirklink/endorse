typedef bool PassFuntion(Object input, Object test);
typedef bool RestrictFunction(Object input);
typedef Object GotFunction(Object input, Object test);
typedef Object WantFunction(Object input, Object test);
typedef Object CastFuntion(Object input);

abstract class Rule {
  final String name = '';
  final bool causesBail = false;
  final bool escapesBail = false;
  final PassFuntion pass = (input, test) => true; 
  final RestrictFunction restriction = (input) => true;
  final GotFunction got = (input, test) => null;
  final WantFunction want = (input, test) => null;
  final CastFuntion cast = (input) => input;
  final String  restrictionError = '';
  final String errorMsg = '';
}