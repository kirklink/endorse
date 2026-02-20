// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extended_request.dart';

// **************************************************************************
// EndorseGenerator
// **************************************************************************

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$EventRequestValidator implements EndorseValidator<EventRequest> {
  const _$EventRequestValidator();

  @override
  Set<String> get fieldNames => const {'name', 'startDate', 'deadline'};

  static final _nameRules = <Rule>[
    const Required(),
    const IsString(),
    const Trim(),
    const MinLength(1, message: 'event name is required')
  ];
  static (List<String>, Object?) _checkName(Object? value) =>
      checkRules(value, _nameRules);

  static final _startDateRules = <Rule>[
    const Required(),
    const IsDateTime(),
    const IsAfterDate('today', message: 'must be a future date')
  ];
  static (List<String>, Object?) _checkStartDate(Object? value) =>
      checkRules(value, _startDateRules);

  static final _deadlineRules = <Rule>[
    const IsDateTime(),
    const IsFutureDatetime()
  ];
  static (List<String>, Object?) _checkDeadline(Object? value) =>
      checkRules(value, _deadlineRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'name' => _checkName(value).$1,
      'startDate' => _checkStartDate(value).$1,
      'deadline' => _checkDeadline(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<EventRequest> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (nameErrors, nameVal) = _checkName(input['name']);
    if (nameErrors.isNotEmpty) errors['name'] = nameErrors;
    values['name'] = nameVal;

    final (startDateErrors, startDateVal) = _checkStartDate(input['startDate']);
    if (startDateErrors.isNotEmpty) errors['startDate'] = startDateErrors;
    values['startDate'] = startDateVal;

    final (deadlineErrors, deadlineVal) = _checkDeadline(input['deadline']);
    if (deadlineErrors.isNotEmpty) errors['deadline'] = deadlineErrors;
    values['deadline'] = deadlineVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(EventRequest._(
      name: values['name'] as String,
      startDate: values['startDate'] as DateTime,
      deadline: values['deadline'] as DateTime?,
    ));
  }
}

Map<String, dynamic> _$EventRequestToJson(EventRequest instance) => {
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      if (instance.deadline != null) 'deadline': instance.deadline,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$ServerConfigValidator implements EndorseValidator<ServerConfig> {
  const _$ServerConfigValidator();

  @override
  Set<String> get fieldNames => const {'host', 'port', 'callbackUrl'};

  static final _hostRules = <Rule>[
    const Required(),
    const IsString(),
    const IpAddress(message: 'enter a valid IP')
  ];
  static (List<String>, Object?) _checkHost(Object? value) =>
      checkRules(value, _hostRules);

  static final _portRules = <Rule>[
    const Required(),
    const IsInt(),
    const Min(1, message: 'port must be positive'),
    const Max(65535)
  ];
  static (List<String>, Object?) _checkPort(Object? value) =>
      checkRules(value, _portRules);

  static final _callbackUrlRules = <Rule>[
    const IsString(),
    const Trim(),
    const Url()
  ];
  static (List<String>, Object?) _checkCallbackUrl(Object? value) =>
      checkRules(value, _callbackUrlRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'host' => _checkHost(value).$1,
      'port' => _checkPort(value).$1,
      'callbackUrl' => _checkCallbackUrl(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<ServerConfig> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (hostErrors, hostVal) = _checkHost(input['host']);
    if (hostErrors.isNotEmpty) errors['host'] = hostErrors;
    values['host'] = hostVal;

    final (portErrors, portVal) = _checkPort(input['port']);
    if (portErrors.isNotEmpty) errors['port'] = portErrors;
    values['port'] = portVal;

    final (callbackUrlErrors, callbackUrlVal) =
        _checkCallbackUrl(input['callbackUrl']);
    if (callbackUrlErrors.isNotEmpty) errors['callbackUrl'] = callbackUrlErrors;
    values['callbackUrl'] = callbackUrlVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(ServerConfig._(
      host: values['host'] as String,
      port: values['port'] as int,
      callbackUrl: values['callbackUrl'] as String?,
    ));
  }
}

Map<String, dynamic> _$ServerConfigToJson(ServerConfig instance) => {
      'host': instance.host,
      'port': instance.port,
      if (instance.callbackUrl != null) 'callbackUrl': instance.callbackUrl,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$NormalizedInputValidator implements EndorseValidator<NormalizedInput> {
  const _$NormalizedInputValidator();

  @override
  Set<String> get fieldNames => const {'email', 'countryCode'};

  static final _emailRules = <Rule>[
    const Required(),
    const IsString(),
    const Trim(),
    const LowerCase(),
    const Email()
  ];
  static (List<String>, Object?) _checkEmail(Object? value) =>
      checkRules(value, _emailRules);

  static final _countryCodeRules = <Rule>[
    const Required(),
    const IsString(),
    const UpperCase(),
    const OneOf(['US', 'CA', 'UK'])
  ];
  static (List<String>, Object?) _checkCountryCode(Object? value) =>
      checkRules(value, _countryCodeRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'email' => _checkEmail(value).$1,
      'countryCode' => _checkCountryCode(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<NormalizedInput> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (emailErrors, emailVal) = _checkEmail(input['email']);
    if (emailErrors.isNotEmpty) errors['email'] = emailErrors;
    values['email'] = emailVal;

    final (countryCodeErrors, countryCodeVal) =
        _checkCountryCode(input['countryCode']);
    if (countryCodeErrors.isNotEmpty) errors['countryCode'] = countryCodeErrors;
    values['countryCode'] = countryCodeVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(NormalizedInput._(
      email: values['email'] as String,
      countryCode: values['countryCode'] as String,
    ));
  }
}

Map<String, dynamic> _$NormalizedInputToJson(NormalizedInput instance) => {
      'email': instance.email,
      'countryCode': instance.countryCode,
    };
