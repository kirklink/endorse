import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

import 'samples/simple_request.dart';
import 'samples/extended_request.dart';
import 'samples/nested_request.dart';
import 'samples/advanced_request.dart';

/// Finds the first rule descriptor with the given [name] in [rules].
Map<String, Object?> _findRule(List<Map<String, Object?>> rules, String name) =>
    rules.firstWhere((r) => r['rule'] == name);

/// Whether [rules] contains a descriptor with the given rule [name].
bool _hasRule(List<Map<String, Object?>> rules, String name) =>
    rules.any((r) => r['rule'] == name);

void main() {
  group('EndorseValidator interface', () {
    test('generated validators implement EndorseValidator', () {
      expect(CreateItemRequest.$endorse, isA<EndorseValidator>());
      expect(UserProfile.$endorse, isA<EndorseValidator>());
      expect(EventRequest.$endorse, isA<EndorseValidator>());
      expect(Address.$endorse, isA<EndorseValidator>());
    });
  });

  group('html5Attrs', () {
    test('required field emits required attribute', () {
      final attrs = CreateItemRequest.$endorse.html5Attrs;
      expect(attrs['name'], containsPair('required', ''));
      expect(attrs['quantity'], containsPair('required', ''));
    });

    test('optional field omits required attribute', () {
      final attrs = CreateItemRequest.$endorse.html5Attrs;
      expect(attrs.containsKey('description'), isFalse);
    });

    test('MinLength/MaxLength emit minlength/maxlength', () {
      final attrs = CreateItemRequest.$endorse.html5Attrs;
      expect(attrs['name'], containsPair('minlength', '1'));
      expect(attrs['name'], containsPair('maxlength', '100'));
    });

    test('Min emits min attribute', () {
      final attrs = CreateItemRequest.$endorse.html5Attrs;
      expect(attrs['quantity'], containsPair('min', '0'));
    });

    test('int/num type emits type=number', () {
      final attrs = CreateItemRequest.$endorse.html5Attrs;
      expect(attrs['quantity'], containsPair('type', 'number'));
    });

    test('Email rule emits type=email', () {
      final attrs = UserProfile.$endorse.html5Attrs;
      expect(attrs['email'], containsPair('type', 'email'));
    });

    test('Url rule emits type=url', () {
      final attrs = ServerConfig.$endorse.html5Attrs;
      expect(attrs['callbackUrl'], containsPair('type', 'url'));
    });

    test('DateTime type emits type=date', () {
      final attrs = EventRequest.$endorse.html5Attrs;
      expect(attrs['startDate'], containsPair('type', 'date'));
    });

    test('Matches rule emits pattern attribute', () {
      final attrs = Address.$endorse.html5Attrs;
      expect(attrs['zip'], containsPair('pattern', r'^\d{5}$'));
    });

    test('Min and Max together emit both attributes', () {
      final attrs = ServerConfig.$endorse.html5Attrs;
      expect(attrs['port'], containsPair('min', '1'));
      expect(attrs['port'], containsPair('max', '65535'));
    });

    test('nested/list fields are excluded', () {
      final attrs = CreateOrderRequest.$endorse.html5Attrs;
      expect(attrs.containsKey('address'), isFalse);
      expect(attrs.containsKey('items'), isFalse);
      expect(attrs.containsKey('customerId'), isTrue);
    });

    test('primitive list fields are excluded', () {
      final attrs = TagRequest.$endorse.html5Attrs;
      expect(attrs.isEmpty, isTrue);
    });

    test('optional int field has type=number without required', () {
      final attrs = UserProfile.$endorse.html5Attrs;
      expect(attrs['age'], containsPair('type', 'number'));
      expect(attrs['age']!.containsKey('required'), isFalse);
    });
  });

  group('clientRules', () {
    test('required field has Required descriptor', () {
      final rules = CreateItemRequest.$endorse.clientRules;
      expect(_hasRule(rules['name']!, 'Required'), isTrue);
    });

    test('MinLength emits correct params', () {
      final rules = CreateItemRequest.$endorse.clientRules;
      final minLength = _findRule(rules['name']!, 'MinLength');
      expect(minLength['min'], equals(1));
    });

    test('MaxLength emits correct params', () {
      final rules = CreateItemRequest.$endorse.clientRules;
      final maxLength = _findRule(rules['name']!, 'MaxLength');
      expect(maxLength['max'], equals(100));
    });

    test('Min emits numeric value', () {
      final rules = CreateItemRequest.$endorse.clientRules;
      final min = _findRule(rules['quantity']!, 'Min');
      expect(min['min'], equals(0));
    });

    test('Email rule emits descriptor', () {
      final rules = UserProfile.$endorse.clientRules;
      expect(_hasRule(rules['email']!, 'Email'), isTrue);
    });

    test('OneOf emits allowed list', () {
      final rules = UserProfile.$endorse.clientRules;
      final oneOf = _findRule(rules['role']!, 'OneOf');
      expect(oneOf['allowed'], equals(['admin', 'user', 'guest']));
    });

    test('Matches emits pattern as raw string', () {
      final rules = Address.$endorse.clientRules;
      final matches = _findRule(rules['zip']!, 'Matches');
      expect(matches['pattern'], equals(r'^\d{5}$'));
    });

    test('custom message is included', () {
      final rules = EventRequest.$endorse.clientRules;
      final minLength = _findRule(rules['name']!, 'MinLength');
      expect(minLength['message'], equals('event name is required'));
    });

    test('transform-only rules excluded (Trim, LowerCase, etc.)', () {
      final rules = NormalizedInput.$endorse.clientRules;
      final emailRules = rules['email']!;
      expect(_hasRule(emailRules, 'Trim'), isFalse);
      expect(_hasRule(emailRules, 'LowerCase'), isFalse);
    });

    test('optional field without validation rules is excluded', () {
      final rules = CreateItemRequest.$endorse.clientRules;
      expect(rules.containsKey('description'), isFalse);
    });

    test('nested/list fields are excluded', () {
      final rules = CreateOrderRequest.$endorse.clientRules;
      expect(rules.containsKey('address'), isFalse);
      expect(rules.containsKey('items'), isFalse);
    });

    test('IpAddress rule emits descriptor with message', () {
      final rules = ServerConfig.$endorse.clientRules;
      final ip = _findRule(rules['host']!, 'IpAddress');
      expect(ip['message'], equals('enter a valid IP'));
    });

    test('Url rule emits descriptor', () {
      final rules = ServerConfig.$endorse.clientRules;
      expect(_hasRule(rules['callbackUrl']!, 'Url'), isTrue);
    });

    test('date rules emit descriptors', () {
      final rules = EventRequest.$endorse.clientRules;
      final afterDate = _findRule(rules['startDate']!, 'IsAfterDate');
      expect(afterDate['date'], equals('today'));
      expect(_hasRule(rules['deadline']!, 'IsFutureDatetime'), isTrue);
    });
  });
}
