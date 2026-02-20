import 'package:endorse/endorse.dart';

part 'advanced_request.g.dart';

/// Tests conditional validation with When.
@Endorse()
class ShippingForm {
  @EndorseField(rules: [OneOf(['US', 'CA', 'UK'])])
  final String country;

  @EndorseField(
    rules: [MinLength(2)],
    when: When('country', equals: 'US'),
  )
  final String? state;

  @EndorseField(rules: [MinLength(1)])
  final String city;

  const ShippingForm._({
    required this.country,
    this.state,
    required this.city,
  });

  Map<String, dynamic> toJson() => _$ShippingFormToJson(this);
  static final $endorse = _$ShippingFormValidator();
}

/// Tests either constraint and crossValidate.
@Endorse(either: [
  ['email', 'phone'],
])
class ContactForm {
  @EndorseField(rules: [Email()])
  final String? email;

  @EndorseField(rules: [MinLength(7)])
  final String? phone;

  @EndorseField(rules: [MinLength(1)])
  final String message;

  const ContactForm._({this.email, this.phone, required this.message});

  Map<String, dynamic> toJson() => _$ContactFormToJson(this);
  static final $endorse = _$ContactFormValidator();

  static Map<String, List<String>> crossValidate(
      Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final msg = input['message'];
    if (msg is String && msg.length > 500) {
      errors['message'] = ['must be at most 500 characters'];
    }
    return errors;
  }
}

/// Tests custom validation via static method.
@Endorse()
class NumberForm {
  @EndorseField(rules: [Min(0), Custom('isEven', message: 'must be an even number')])
  final int value;

  const NumberForm._({required this.value});

  Map<String, dynamic> toJson() => _$NumberFormToJson(this);
  static final $endorse = _$NumberFormValidator();

  static bool isEven(Object? value) => value is int && value.isEven;
}

/// Tests primitive list with item rules.
@Endorse()
class TagRequest {
  @EndorseField(rules: [MinElements(1), UniqueElements()], itemRules: [MinLength(1)])
  final List<String> tags;

  const TagRequest._({required this.tags});

  Map<String, dynamic> toJson() => _$TagRequestToJson(this);
  static final $endorse = _$TagRequestValidator();
}
