// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_request.dart';

// **************************************************************************
// EndorseGenerator
// **************************************************************************

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$ShippingFormValidator implements EndorseValidator<ShippingForm> {
  const _$ShippingFormValidator();

  @override
  Set<String> get fieldNames => const {'country', 'state', 'city'};

  static final _countryRules = <Rule>[
    const Required(),
    const IsString(),
    const OneOf(['US', 'CA', 'UK'])
  ];
  static (List<String>, Object?) _checkCountry(Object? value) =>
      checkRules(value, _countryRules);

  static final _stateRules = <Rule>[const IsString(), const MinLength(2)];
  static (List<String>, Object?) _checkState(Object? value) =>
      checkRules(value, _stateRules);

  static final _cityRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(1)
  ];
  static (List<String>, Object?) _checkCity(Object? value) =>
      checkRules(value, _cityRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'country' => _checkCountry(value).$1,
      'state' => _checkState(value).$1,
      'city' => _checkCity(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<ShippingForm> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (countryErrors, countryVal) = _checkCountry(input['country']);
    if (countryErrors.isNotEmpty) errors['country'] = countryErrors;
    values['country'] = countryVal;

    if (input['country'] == 'US') {
      final (stateErrors, stateVal) =
          checkRules(input['state'], [const Required(), ..._stateRules]);
      if (stateErrors.isNotEmpty) errors['state'] = stateErrors;
      values['state'] = stateVal;
    }

    final (cityErrors, cityVal) = _checkCity(input['city']);
    if (cityErrors.isNotEmpty) errors['city'] = cityErrors;
    values['city'] = cityVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(ShippingForm._(
      country: values['country'] as String,
      state: values['state'] as String?,
      city: values['city'] as String,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'country': {'required': ''},
        'state': {'minlength': '2'},
        'city': {'required': '', 'minlength': '1'},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'country': [
          {'rule': 'Required'},
          {
            'rule': 'OneOf',
            'allowed': ['US', 'CA', 'UK']
          },
        ],
        'state': [
          {'rule': 'MinLength', 'min': 2},
        ],
        'city': [
          {'rule': 'Required'},
          {'rule': 'MinLength', 'min': 1},
        ],
      };
}

Map<String, dynamic> _$ShippingFormToJson(ShippingForm instance) => {
      'country': instance.country,
      if (instance.state != null) 'state': instance.state,
      'city': instance.city,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$ContactFormValidator implements EndorseValidator<ContactForm> {
  const _$ContactFormValidator();

  @override
  Set<String> get fieldNames => const {'email', 'phone', 'message'};

  static final _emailRules = <Rule>[const IsString(), const Email()];
  static (List<String>, Object?) _checkEmail(Object? value) =>
      checkRules(value, _emailRules);

  static final _phoneRules = <Rule>[const IsString(), const MinLength(7)];
  static (List<String>, Object?) _checkPhone(Object? value) =>
      checkRules(value, _phoneRules);

  static final _messageRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(1)
  ];
  static (List<String>, Object?) _checkMessage(Object? value) =>
      checkRules(value, _messageRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'email' => _checkEmail(value).$1,
      'phone' => _checkPhone(value).$1,
      'message' => _checkMessage(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<ContactForm> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (emailErrors, emailVal) = _checkEmail(input['email']);
    if (emailErrors.isNotEmpty) errors['email'] = emailErrors;
    values['email'] = emailVal;

    final (phoneErrors, phoneVal) = _checkPhone(input['phone']);
    if (phoneErrors.isNotEmpty) errors['phone'] = phoneErrors;
    values['phone'] = phoneVal;

    final (messageErrors, messageVal) = _checkMessage(input['message']);
    if (messageErrors.isNotEmpty) errors['message'] = messageErrors;
    values['message'] = messageVal;

    if (input['email'] == null && input['phone'] == null) {
      errors
          .putIfAbsent('email', () => [])
          .add('at least one of [email, phone] is required');
      errors
          .putIfAbsent('phone', () => [])
          .add('at least one of [email, phone] is required');
    }

    if (errors.isEmpty) {
      final crossErrors = ContactForm.crossValidate(input);
      for (final entry in crossErrors.entries) {
        errors.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(ContactForm._(
      email: values['email'] as String?,
      phone: values['phone'] as String?,
      message: values['message'] as String,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'email': {'type': 'email'},
        'phone': {'minlength': '7'},
        'message': {'required': '', 'minlength': '1'},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'email': [
          {'rule': 'Email'},
        ],
        'phone': [
          {'rule': 'MinLength', 'min': 7},
        ],
        'message': [
          {'rule': 'Required'},
          {'rule': 'MinLength', 'min': 1},
        ],
      };
}

Map<String, dynamic> _$ContactFormToJson(ContactForm instance) => {
      if (instance.email != null) 'email': instance.email,
      if (instance.phone != null) 'phone': instance.phone,
      'message': instance.message,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$NumberFormValidator implements EndorseValidator<NumberForm> {
  const _$NumberFormValidator();

  @override
  Set<String> get fieldNames => const {'value'};

  static final _valueRules = <Rule>[
    const Required(),
    const IsInt(),
    const Min(0)
  ];
  static (List<String>, Object?) _checkValue(Object? value) {
    var (errors, coerced) = checkRules(value, _valueRules);
    if (errors.isNotEmpty) return (errors, coerced);
    if (!NumberForm.isEven(coerced))
      errors = [...errors, 'must be an even number'];
    return (errors, coerced);
  }

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'value' => _checkValue(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<NumberForm> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (valueErrors, valueVal) = _checkValue(input['value']);
    if (valueErrors.isNotEmpty) errors['value'] = valueErrors;
    values['value'] = valueVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(NumberForm._(
      value: values['value'] as int,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'value': {'required': '', 'type': 'number', 'min': '0'},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'value': [
          {'rule': 'Required'},
          {'rule': 'Min', 'min': 0},
        ],
      };
}

Map<String, dynamic> _$NumberFormToJson(NumberForm instance) => {
      'value': instance.value,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$TagRequestValidator implements EndorseValidator<TagRequest> {
  const _$TagRequestValidator();

  @override
  Set<String> get fieldNames => const {'tags'};

  static final _tagsRules = <Rule>[
    const Required(),
    const IsList(),
    const MinElements(1),
    const UniqueElements()
  ];
  static (List<String>, Object?) _checkTags(Object? value) =>
      checkRules(value, _tagsRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'tags' => _checkTags(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<TagRequest> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (tagsErrors, tagsVal) = _checkTags(input['tags']);
    if (tagsErrors.isNotEmpty) errors['tags'] = tagsErrors;
    if (tagsErrors.isEmpty && tagsVal is List) {
      final itemRules = <Rule>[const MinLength(1)];
      for (var i = 0; i < (tagsVal as List).length; i++) {
        final (itemErrors, _) = checkRules((tagsVal as List)[i], itemRules);
        if (itemErrors.isNotEmpty) errors['tags.$i'] = itemErrors;
      }
    }
    values['tags'] = tagsVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(TagRequest._(
      tags: values['tags'] as List<String>,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {};

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {};
}

Map<String, dynamic> _$TagRequestToJson(TagRequest instance) => {
      'tags': instance.tags,
    };
