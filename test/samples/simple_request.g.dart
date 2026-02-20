// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_request.dart';

// **************************************************************************
// EndorseGenerator
// **************************************************************************

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$CreateItemRequestValidator
    implements EndorseValidator<CreateItemRequest> {
  const _$CreateItemRequestValidator();

  @override
  Set<String> get fieldNames => const {'name', 'quantity', 'description'};

  static final _nameRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(1),
    const MaxLength(100)
  ];
  static (List<String>, Object?) _checkName(Object? value) =>
      checkRules(value, _nameRules);

  static final _quantityRules = <Rule>[
    const Required(),
    const IsInt(),
    const Min(0)
  ];
  static (List<String>, Object?) _checkQuantity(Object? value) =>
      checkRules(value, _quantityRules);

  static final _descriptionRules = <Rule>[const IsString()];
  static (List<String>, Object?) _checkDescription(Object? value) =>
      checkRules(value, _descriptionRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'name' => _checkName(value).$1,
      'quantity' => _checkQuantity(value).$1,
      'description' => _checkDescription(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<CreateItemRequest> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (nameErrors, nameVal) = _checkName(input['name']);
    if (nameErrors.isNotEmpty) errors['name'] = nameErrors;
    values['name'] = nameVal;

    final (quantityErrors, quantityVal) = _checkQuantity(input['quantity']);
    if (quantityErrors.isNotEmpty) errors['quantity'] = quantityErrors;
    values['quantity'] = quantityVal;

    final (descriptionErrors, descriptionVal) =
        _checkDescription(input['description']);
    if (descriptionErrors.isNotEmpty) errors['description'] = descriptionErrors;
    values['description'] = descriptionVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(CreateItemRequest._(
      name: values['name'] as String,
      quantity: values['quantity'] as int,
      description: values['description'] as String?,
    ));
  }
}

Map<String, dynamic> _$CreateItemRequestToJson(CreateItemRequest instance) => {
      'name': instance.name,
      'quantity': instance.quantity,
      if (instance.description != null) 'description': instance.description,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$UserProfileValidator implements EndorseValidator<UserProfile> {
  const _$UserProfileValidator();

  @override
  Set<String> get fieldNames => const {'displayName', 'email', 'role', 'age'};

  static final _displayNameRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(2),
    const MaxLength(50)
  ];
  static (List<String>, Object?) _checkDisplayName(Object? value) =>
      checkRules(value, _displayNameRules);

  static final _emailRules = <Rule>[
    const Required(),
    const IsString(),
    const Email()
  ];
  static (List<String>, Object?) _checkEmail(Object? value) =>
      checkRules(value, _emailRules);

  static final _roleRules = <Rule>[
    const Required(),
    const IsString(),
    const OneOf(['admin', 'user', 'guest'])
  ];
  static (List<String>, Object?) _checkRole(Object? value) =>
      checkRules(value, _roleRules);

  static final _ageRules = <Rule>[const IsInt()];
  static (List<String>, Object?) _checkAge(Object? value) =>
      checkRules(value, _ageRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'displayName' => _checkDisplayName(value).$1,
      'email' => _checkEmail(value).$1,
      'role' => _checkRole(value).$1,
      'age' => _checkAge(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<UserProfile> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (displayNameErrors, displayNameVal) =
        _checkDisplayName(input['displayName']);
    if (displayNameErrors.isNotEmpty) errors['displayName'] = displayNameErrors;
    values['displayName'] = displayNameVal;

    final (emailErrors, emailVal) = _checkEmail(input['email']);
    if (emailErrors.isNotEmpty) errors['email'] = emailErrors;
    values['email'] = emailVal;

    final (roleErrors, roleVal) = _checkRole(input['user_role']);
    if (roleErrors.isNotEmpty) errors['role'] = roleErrors;
    values['role'] = roleVal;

    final (ageErrors, ageVal) = _checkAge(input['age']);
    if (ageErrors.isNotEmpty) errors['age'] = ageErrors;
    values['age'] = ageVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(UserProfile._(
      displayName: values['displayName'] as String,
      email: values['email'] as String,
      role: values['role'] as String,
      age: values['age'] as int?,
    ));
  }
}

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) => {
      'displayName': instance.displayName,
      'email': instance.email,
      'user_role': instance.role,
      if (instance.age != null) 'age': instance.age,
    };
