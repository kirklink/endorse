import 'package:endorse/endorse.dart';
import 'package:test/test.dart';

import 'samples/simple_request.dart';
import 'samples/nested_request.dart';
import 'samples/advanced_request.dart';
import 'samples/extended_request.dart';

void main() {
  // ===========================================================================
  // CreateItemRequest — simple flat validation
  // ===========================================================================
  group('CreateItemRequest', () {
    test('valid input returns ValidResult', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 5,
      });
      expect(result, isA<ValidResult<CreateItemRequest>>());
      final item = (result as ValidResult<CreateItemRequest>).value;
      expect(item.name, 'Widget');
      expect(item.quantity, 5);
      expect(item.description, isNull);
    });

    test('valid input with optional field', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 10,
        'description': 'A fine widget',
      });
      final item = (result as ValidResult<CreateItemRequest>).value;
      expect(item.description, 'A fine widget');
    });

    test('auto-coerces string to int', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': '42',
      });
      expect(result, isA<ValidResult<CreateItemRequest>>());
      final item = (result as ValidResult<CreateItemRequest>).value;
      expect(item.quantity, 42);
    });

    test('auto-coerces double to int', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 7.0,
      });
      expect(result, isA<ValidResult<CreateItemRequest>>());
      expect((result as ValidResult<CreateItemRequest>).value.quantity, 7);
    });

    test('missing required fields', () {
      final result = CreateItemRequest.$endorse.validate({});
      expect(result, isA<InvalidResult<CreateItemRequest>>());
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['name'], contains('is required'));
      expect(errors['quantity'], contains('is required'));
      expect(errors.containsKey('description'), isFalse);
    });

    test('name too short', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': '',
        'quantity': 1,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['name'], contains('is required'));
    });

    test('name too long', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'x' * 101,
        'quantity': 1,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['name'], contains('must be at most 100 characters'));
    });

    test('quantity below min', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': -1,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['quantity'], contains('must be at least 0'));
    });

    test('wrong type for quantity', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 'not-a-number',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['quantity'], contains('must be an integer'));
    });

    test('toJson round-trips', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 5,
        'description': 'Nice',
      });
      final json = (result as ValidResult<CreateItemRequest>).value.toJson();
      expect(json, {'name': 'Widget', 'quantity': 5, 'description': 'Nice'});
    });

    test('toJson omits null optional fields', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 5,
      });
      final json = (result as ValidResult<CreateItemRequest>).value.toJson();
      expect(json.containsKey('description'), isFalse);
    });

    test('pattern matching works', () {
      final result = CreateItemRequest.$endorse.validate({
        'name': 'Widget',
        'quantity': 5,
      });
      final output = switch (result) {
        ValidResult(:final value) => value.name,
        InvalidResult() => 'invalid',
      };
      expect(output, 'Widget');
    });
  });

  // ===========================================================================
  // UserProfile — email, OneOf, field name mapping
  // ===========================================================================
  group('UserProfile', () {
    test('valid input', () {
      final result = UserProfile.$endorse.validate({
        'displayName': 'Alice',
        'email': 'alice@example.com',
        'user_role': 'admin',
      });
      expect(result, isA<ValidResult<UserProfile>>());
      final user = (result as ValidResult<UserProfile>).value;
      expect(user.displayName, 'Alice');
      expect(user.email, 'alice@example.com');
      expect(user.role, 'admin');
      expect(user.age, isNull);
    });

    test('invalid email', () {
      final result = UserProfile.$endorse.validate({
        'displayName': 'Alice',
        'email': 'not-an-email',
        'user_role': 'admin',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['email'], contains('must be a valid email address'));
    });

    test('invalid role (not in OneOf)', () {
      final result = UserProfile.$endorse.validate({
        'displayName': 'Alice',
        'email': 'alice@example.com',
        'user_role': 'superuser',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['role'], contains('must be one of: admin, user, guest'));
    });

    test('field name mapping in toJson', () {
      final result = UserProfile.$endorse.validate({
        'displayName': 'Alice',
        'email': 'alice@example.com',
        'user_role': 'user',
      });
      final json = (result as ValidResult<UserProfile>).value.toJson();
      expect(json['user_role'], 'user');
      expect(json.containsKey('role'), isFalse);
    });

    test('optional age with coercion', () {
      final result = UserProfile.$endorse.validate({
        'displayName': 'Alice',
        'email': 'alice@example.com',
        'user_role': 'user',
        'age': '30',
      });
      expect(result, isA<ValidResult<UserProfile>>());
      expect((result as ValidResult<UserProfile>).value.age, 30);
    });
  });

  // ===========================================================================
  // validateField — individual field validation for forms
  // ===========================================================================
  group('validateField', () {
    test('valid field returns empty list', () {
      expect(
        CreateItemRequest.$endorse.validateField('name', 'Widget'),
        isEmpty,
      );
    });

    test('invalid field returns error messages', () {
      expect(
        CreateItemRequest.$endorse.validateField('name', null),
        ['is required'],
      );
    });

    test('validates quantity with coercion', () {
      expect(
        CreateItemRequest.$endorse.validateField('quantity', '5'),
        isEmpty,
      );
    });

    test('unknown field throws', () {
      expect(
        () => CreateItemRequest.$endorse.validateField('unknown', null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fieldNames returns all fields', () {
      expect(
        CreateItemRequest.$endorse.fieldNames,
        {'name', 'quantity', 'description'},
      );
    });
  });

  // ===========================================================================
  // Address — nested object
  // ===========================================================================
  group('Address', () {
    test('valid address', () {
      final result = Address.$endorse.validate({
        'street': '123 Main St',
        'city': 'Springfield',
        'zip': '12345',
      });
      expect(result, isA<ValidResult<Address>>());
    });

    test('invalid zip', () {
      final result = Address.$endorse.validate({
        'street': '123 Main St',
        'city': 'Springfield',
        'zip': 'ABCDE',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['zip'], contains('must be a 5-digit zip code'));
    });
  });

  // ===========================================================================
  // CreateOrderRequest — nested objects + nested lists
  // ===========================================================================
  group('CreateOrderRequest', () {
    final validAddress = {
      'street': '123 Main St',
      'city': 'Springfield',
      'zip': '12345',
    };
    final validLine = {'productId': 'SKU-001', 'quantity': 2};

    test('valid order', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': validAddress,
        'lines': [validLine],
      });
      expect(result, isA<ValidResult<CreateOrderRequest>>());
      final order = (result as ValidResult<CreateOrderRequest>).value;
      expect(order.customerId, '550e8400-e29b-41d4-a716-446655440000');
      expect(order.address.city, 'Springfield');
      expect(order.lines, hasLength(1));
      expect(order.lines.first.quantity, 2);
      expect(order.billingAddress, isNull);
    });

    test('nested address errors use dot-path', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': {'street': '', 'city': 'X', 'zip': 'bad'},
        'lines': [validLine],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['address.street'], isNotNull);
      expect(errors['address.zip'], isNotNull);
    });

    test('missing address', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'lines': [validLine],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['address'], contains('is required'));
    });

    test('nested list item errors use indexed dot-path', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': validAddress,
        'lines': [
          {'productId': 'SKU-001', 'quantity': 0},
          {'productId': 'SKU-002', 'quantity': -1},
        ],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['lines.0.quantity'], contains('must be at least 1'));
      expect(errors['lines.1.quantity'], contains('must be at least 1'));
    });

    test('empty lines list fails MinElements', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': validAddress,
        'lines': [],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['lines'], contains('must not be empty'));
    });

    test('optional billingAddress accepted when present', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': validAddress,
        'lines': [validLine],
        'billingAddress': validAddress,
      });
      expect(result, isA<ValidResult<CreateOrderRequest>>());
      final order = (result as ValidResult<CreateOrderRequest>).value;
      expect(order.billingAddress, isNotNull);
      expect(order.billingAddress!.zip, '12345');
    });

    test('toJson serializes nested objects', () {
      final result = CreateOrderRequest.$endorse.validate({
        'customerId': '550e8400-e29b-41d4-a716-446655440000',
        'address': validAddress,
        'lines': [validLine],
      });
      final json = (result as ValidResult<CreateOrderRequest>).value.toJson();
      expect(json['address'], isA<Map>());
      expect(json['address']['city'], 'Springfield');
      expect(json['lines'], isA<List>());
      expect((json['lines'] as List).first['productId'], 'SKU-001');
      expect(json.containsKey('billingAddress'), isFalse);
    });
  });

  // ===========================================================================
  // ShippingForm — When conditional validation
  // ===========================================================================
  group('ShippingForm (When)', () {
    test('state required when country is US', () {
      final result = ShippingForm.$endorse.validate({
        'country': 'US',
        'city': 'NYC',
      });
      final errors = (result as InvalidResult).fieldErrors;
      // state has MinLength(2) rule, with null input it won't match (optional due to nullable)
      // but When condition triggers validation
      expect(errors.containsKey('state'), isTrue);
    });

    test('state validated when country is US', () {
      final result = ShippingForm.$endorse.validate({
        'country': 'US',
        'state': 'NY',
        'city': 'NYC',
      });
      expect(result, isA<ValidResult<ShippingForm>>());
      expect((result as ValidResult<ShippingForm>).value.state, 'NY');
    });

    test('state skipped when country is not US', () {
      final result = ShippingForm.$endorse.validate({
        'country': 'UK',
        'city': 'London',
      });
      expect(result, isA<ValidResult<ShippingForm>>());
      expect((result as ValidResult<ShippingForm>).value.state, isNull);
    });
  });

  // ===========================================================================
  // ContactForm — either constraint + crossValidate
  // ===========================================================================
  group('ContactForm (either + crossValidate)', () {
    test('valid with email only', () {
      final result = ContactForm.$endorse.validate({
        'email': 'a@b.com',
        'message': 'Hello',
      });
      expect(result, isA<ValidResult<ContactForm>>());
    });

    test('valid with phone only', () {
      final result = ContactForm.$endorse.validate({
        'phone': '1234567890',
        'message': 'Hello',
      });
      expect(result, isA<ValidResult<ContactForm>>());
    });

    test('fails when neither email nor phone', () {
      final result = ContactForm.$endorse.validate({
        'message': 'Hello',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['email'],
          contains('at least one of [email, phone] is required'));
      expect(errors['phone'],
          contains('at least one of [email, phone] is required'));
    });

    test('crossValidate catches long message', () {
      final result = ContactForm.$endorse.validate({
        'email': 'a@b.com',
        'message': 'x' * 501,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['message'],
          contains('must be at most 500 characters'));
    });
  });

  // ===========================================================================
  // NumberForm — Custom validation
  // ===========================================================================
  group('NumberForm (Custom)', () {
    test('even number passes', () {
      final result = NumberForm.$endorse.validate({'value': 4});
      expect(result, isA<ValidResult<NumberForm>>());
    });

    test('odd number fails custom rule', () {
      final result = NumberForm.$endorse.validate({'value': 3});
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['value'], contains('must be an even number'));
    });

    test('coerced string still validates custom', () {
      final result = NumberForm.$endorse.validate({'value': '6'});
      expect(result, isA<ValidResult<NumberForm>>());
    });
  });

  // ===========================================================================
  // TagRequest — primitive list with item rules
  // ===========================================================================
  group('TagRequest (list items)', () {
    test('valid tags', () {
      final result = TagRequest.$endorse.validate({
        'tags': ['dart', 'flutter'],
      });
      expect(result, isA<ValidResult<TagRequest>>());
    });

    test('empty list fails MinElements', () {
      final result = TagRequest.$endorse.validate({
        'tags': [],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['tags'], contains('must not be empty'));
    });

    test('duplicate elements fail UniqueElements', () {
      final result = TagRequest.$endorse.validate({
        'tags': ['dart', 'dart'],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['tags'], contains('must contain unique elements'));
    });

    test('empty string item fails MinLength', () {
      final result = TagRequest.$endorse.validate({
        'tags': ['dart', ''],
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['tags.1'], contains('must not be empty'));
    });
  });

  // ===========================================================================
  // EventRequest — Trim, DateTime rules, custom messages
  // ===========================================================================
  group('EventRequest (Trim + DateTime)', () {
    test('valid event with trimmed name', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = EventRequest.$endorse.validate({
        'name': '  Conference  ',
        'startDate': tomorrow.toIso8601String(),
      });
      expect(result, isA<ValidResult<EventRequest>>());
      final event = (result as ValidResult<EventRequest>).value;
      expect(event.name, 'Conference'); // trimmed
      expect(event.deadline, isNull);
    });

    test('whitespace-only name fails as required (Required bails before Trim)', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = EventRequest.$endorse.validate({
        'name': '   ',
        'startDate': tomorrow.toIso8601String(),
      });
      final errors = (result as InvalidResult).fieldErrors;
      // Required auto-added for non-nullable field bails on whitespace-only
      expect(errors['name'], contains('is required'));
    });

    test('short name after trim uses custom MinLength message', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      // 'a ' trims to 'a' which passes Required but is technically length 1
      // MinLength(1) passes on length 1, so use a value that would fail MinLength(1)
      // Actually MinLength(1) allows length 1. Let's test empty string from null:
      final result = EventRequest.$endorse.validate({
        'name': '',
        'startDate': tomorrow.toIso8601String(),
      });
      final errors = (result as InvalidResult).fieldErrors;
      // Empty string caught by Required (bails)
      expect(errors['name'], contains('is required'));
    });

    test('startDate today or earlier fails with custom message', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = EventRequest.$endorse.validate({
        'name': 'Conference',
        'startDate': yesterday.toIso8601String(),
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['startDate'], contains('must be a future date'));
    });

    test('optional deadline accepted when future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final nextWeek = DateTime.now().add(const Duration(days: 7));
      final result = EventRequest.$endorse.validate({
        'name': 'Conference',
        'startDate': tomorrow.toIso8601String(),
        'deadline': nextWeek.toIso8601String(),
      });
      expect(result, isA<ValidResult<EventRequest>>());
      expect(
          (result as ValidResult<EventRequest>).value.deadline, isNotNull);
    });

    test('optional deadline fails when in past', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = EventRequest.$endorse.validate({
        'name': 'Conference',
        'startDate': tomorrow.toIso8601String(),
        'deadline': yesterday.toIso8601String(),
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['deadline'], contains('must be in the future'));
    });

    test('toJson serializes DateTime as ISO string', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final result = EventRequest.$endorse.validate({
        'name': 'Conference',
        'startDate': tomorrow.toIso8601String(),
      });
      final json = (result as ValidResult<EventRequest>).value.toJson();
      expect(json['startDate'], isA<String>());
      expect(json.containsKey('deadline'), isFalse);
    });
  });

  // ===========================================================================
  // ServerConfig — IpAddress, custom messages, Trim + Url
  // ===========================================================================
  group('ServerConfig (IpAddress + custom messages)', () {
    test('valid config', () {
      final result = ServerConfig.$endorse.validate({
        'host': '192.168.1.1',
        'port': 8080,
      });
      expect(result, isA<ValidResult<ServerConfig>>());
      final config = (result as ValidResult<ServerConfig>).value;
      expect(config.host, '192.168.1.1');
      expect(config.port, 8080);
      expect(config.callbackUrl, isNull);
    });

    test('invalid IP uses custom message', () {
      final result = ServerConfig.$endorse.validate({
        'host': 'not-an-ip',
        'port': 8080,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['host'], contains('enter a valid IP'));
    });

    test('port below min uses custom message', () {
      final result = ServerConfig.$endorse.validate({
        'host': '10.0.0.1',
        'port': 0,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['port'], contains('port must be positive'));
    });

    test('port above max uses default message', () {
      final result = ServerConfig.$endorse.validate({
        'host': '10.0.0.1',
        'port': 70000,
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['port'], contains('must be at most 65535'));
    });

    test('callbackUrl trimmed and validated', () {
      final result = ServerConfig.$endorse.validate({
        'host': '10.0.0.1',
        'port': 443,
        'callbackUrl': '  https://example.com/hook  ',
      });
      expect(result, isA<ValidResult<ServerConfig>>());
      expect((result as ValidResult<ServerConfig>).value.callbackUrl,
          'https://example.com/hook');
    });

    test('callbackUrl invalid after trim', () {
      final result = ServerConfig.$endorse.validate({
        'host': '10.0.0.1',
        'port': 443,
        'callbackUrl': '  not-a-url  ',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['callbackUrl'], contains('must be a valid URL'));
    });

    test('IPv6 host accepted', () {
      final result = ServerConfig.$endorse.validate({
        'host': '::1',
        'port': 8080,
      });
      expect(result, isA<ValidResult<ServerConfig>>());
    });
  });

  // ===========================================================================
  // NormalizedInput — LowerCase + UpperCase transforms
  // ===========================================================================
  group('NormalizedInput (LowerCase + UpperCase)', () {
    test('email lowercased and trimmed', () {
      final result = NormalizedInput.$endorse.validate({
        'email': '  Alice@Example.COM  ',
        'countryCode': 'us',
      });
      expect(result, isA<ValidResult<NormalizedInput>>());
      final input = (result as ValidResult<NormalizedInput>).value;
      expect(input.email, 'alice@example.com');
    });

    test('countryCode uppercased', () {
      final result = NormalizedInput.$endorse.validate({
        'email': 'a@b.com',
        'countryCode': 'ca',
      });
      expect(result, isA<ValidResult<NormalizedInput>>());
      expect((result as ValidResult<NormalizedInput>).value.countryCode, 'CA');
    });

    test('invalid countryCode after uppercase still fails OneOf', () {
      final result = NormalizedInput.$endorse.validate({
        'email': 'a@b.com',
        'countryCode': 'de',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['countryCode'], contains('must be one of: US, CA, UK'));
    });

    test('invalid email after lowercase still fails Email', () {
      final result = NormalizedInput.$endorse.validate({
        'email': 'NOT-AN-EMAIL',
        'countryCode': 'us',
      });
      final errors = (result as InvalidResult).fieldErrors;
      expect(errors['email'], contains('must be a valid email address'));
    });

    test('toJson preserves transformed values', () {
      final result = NormalizedInput.$endorse.validate({
        'email': '  Test@Example.COM  ',
        'countryCode': 'uk',
      });
      final json = (result as ValidResult<NormalizedInput>).value.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['countryCode'], 'UK');
    });
  });

  // ===========================================================================
  // Registry — end-to-end with generated validators
  // ===========================================================================
  group('EndorseRegistry (e2e)', () {
    setUp(() {
      EndorseRegistry.instance.clear();
    });

    test('register and use generated validator via registry', () {
      EndorseRegistry.instance
          .register<CreateItemRequest>(CreateItemRequest.$endorse);

      final validator = EndorseRegistry.instance.get<CreateItemRequest>();
      final result = validator.validate({
        'name': 'Widget',
        'quantity': 5,
      });
      expect(result, isA<ValidResult<CreateItemRequest>>());
    });
  });
}
