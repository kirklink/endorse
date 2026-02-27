// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nested_request.dart';

// **************************************************************************
// EndorseGenerator
// **************************************************************************

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$AddressValidator implements EndorseValidator<Address> {
  const _$AddressValidator();

  @override
  Set<String> get fieldNames => const {'street', 'city', 'zip'};

  static final _streetRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(1)
  ];
  static (List<String>, Object?) _checkStreet(Object? value) =>
      checkRules(value, _streetRules);

  static final _cityRules = <Rule>[
    const Required(),
    const IsString(),
    const MinLength(1)
  ];
  static (List<String>, Object?) _checkCity(Object? value) =>
      checkRules(value, _cityRules);

  static final _zipRules = <Rule>[
    const Required(),
    const IsString(),
    const Matches(r'^\d{5}$', message: 'must be a 5-digit zip code')
  ];
  static (List<String>, Object?) _checkZip(Object? value) =>
      checkRules(value, _zipRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'street' => _checkStreet(value).$1,
      'city' => _checkCity(value).$1,
      'zip' => _checkZip(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<Address> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (streetErrors, streetVal) = _checkStreet(input['street']);
    if (streetErrors.isNotEmpty) errors['street'] = streetErrors;
    values['street'] = streetVal;

    final (cityErrors, cityVal) = _checkCity(input['city']);
    if (cityErrors.isNotEmpty) errors['city'] = cityErrors;
    values['city'] = cityVal;

    final (zipErrors, zipVal) = _checkZip(input['zip']);
    if (zipErrors.isNotEmpty) errors['zip'] = zipErrors;
    values['zip'] = zipVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(Address._(
      street: values['street'] as String,
      city: values['city'] as String,
      zip: values['zip'] as String,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'street': {'required': '', 'minlength': '1'},
        'city': {'required': '', 'minlength': '1'},
        'zip': {'required': '', 'pattern': r'^\d{5}$'},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'street': [
          {'rule': 'Required'},
          {'rule': 'MinLength', 'min': 1},
        ],
        'city': [
          {'rule': 'Required'},
          {'rule': 'MinLength', 'min': 1},
        ],
        'zip': [
          {'rule': 'Required'},
          {
            'rule': 'Matches',
            'pattern': r'^\d{5}$',
            'message': 'must be a 5-digit zip code'
          },
        ],
      };
}

Map<String, dynamic> _$AddressToJson(Address instance) => {
      'street': instance.street,
      'city': instance.city,
      'zip': instance.zip,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$OrderLineValidator implements EndorseValidator<OrderLine> {
  const _$OrderLineValidator();

  @override
  Set<String> get fieldNames => const {'productId', 'quantity'};

  static final _productIdRules = <Rule>[const Required(), const IsString()];
  static (List<String>, Object?) _checkProductId(Object? value) =>
      checkRules(value, _productIdRules);

  static final _quantityRules = <Rule>[
    const Required(),
    const IsInt(),
    const Min(1)
  ];
  static (List<String>, Object?) _checkQuantity(Object? value) =>
      checkRules(value, _quantityRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'productId' => _checkProductId(value).$1,
      'quantity' => _checkQuantity(value).$1,
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  @override
  EndorseResult<OrderLine> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (productIdErrors, productIdVal) = _checkProductId(input['productId']);
    if (productIdErrors.isNotEmpty) errors['productId'] = productIdErrors;
    values['productId'] = productIdVal;

    final (quantityErrors, quantityVal) = _checkQuantity(input['quantity']);
    if (quantityErrors.isNotEmpty) errors['quantity'] = quantityErrors;
    values['quantity'] = quantityVal;

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(OrderLine._(
      productId: values['productId'] as String,
      quantity: values['quantity'] as int,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'productId': {'required': ''},
        'quantity': {'required': '', 'type': 'number', 'min': '1'},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'productId': [
          {'rule': 'Required'},
        ],
        'quantity': [
          {'rule': 'Required'},
          {'rule': 'Min', 'min': 1},
        ],
      };
}

Map<String, dynamic> _$OrderLineToJson(OrderLine instance) => {
      'productId': instance.productId,
      'quantity': instance.quantity,
    };

// ignore_for_file: unnecessary_cast, prefer_is_empty, curly_braces_in_flow_control_structures

class _$CreateOrderRequestValidator
    implements EndorseValidator<CreateOrderRequest> {
  const _$CreateOrderRequestValidator();

  @override
  Set<String> get fieldNames =>
      const {'customerId', 'address', 'lines', 'billingAddress'};

  static final _customerIdRules = <Rule>[
    const Required(),
    const IsString(),
    const Uuid()
  ];
  static (List<String>, Object?) _checkCustomerId(Object? value) =>
      checkRules(value, _customerIdRules);

  @override
  List<String> validateField(String fieldName, Object? value) {
    return switch (fieldName) {
      'customerId' => _checkCustomerId(value).$1,
      'address' => _checkNested(value, isRequired: true),
      'lines' => _checkNestedList(value, isRequired: true),
      'billingAddress' => _checkNested(value, isRequired: false),
      _ => throw ArgumentError('Unknown field: $fieldName'),
    };
  }

  static List<String> _checkNested(Object? value, {required bool isRequired}) {
    if (value == null) return isRequired ? ['is required'] : [];
    if (value is! Map) return ['must be an object'];
    return [];
  }

  static List<String> _checkNestedList(Object? value,
      {required bool isRequired}) {
    if (value == null) return isRequired ? ['is required'] : [];
    if (value is! List) return ['must be a list'];
    return [];
  }

  @override
  EndorseResult<CreateOrderRequest> validate(Map<String, Object?> input) {
    final errors = <String, List<String>>{};
    final values = <String, Object?>{};

    final (customerIdErrors, customerIdVal) =
        _checkCustomerId(input['customerId']);
    if (customerIdErrors.isNotEmpty) errors['customerId'] = customerIdErrors;
    values['customerId'] = customerIdVal;

    final addressRaw = input['address'];
    if (addressRaw == null) {
      errors['address'] = ['is required'];
    } else if (addressRaw is! Map<String, Object?>) {
      errors['address'] = ['must be an object'];
    } else {
      final addressResult = Address.$endorse.validate(addressRaw);
      switch (addressResult) {
        case ValidResult(:final value):
          values['address'] = value;
        case InvalidResult(:final fieldErrors):
          for (final entry in fieldErrors.entries) {
            errors['address.${entry.key}'] = entry.value;
          }
      }
    }

    final linesRaw = input['lines'];
    if (linesRaw == null) {
      errors['lines'] = ['is required'];
    } else if (linesRaw is! List) {
      errors['lines'] = ['must be a list'];
    } else {
      final linesList = linesRaw as List;
      final linesListErrors = <String>[];
      if (linesList.length < 1) linesListErrors.add('must not be empty');
      if (linesListErrors.isNotEmpty) errors['lines'] = linesListErrors;
      final linesItems = <OrderLine>[];
      for (var i = 0; i < (linesRaw as List).length; i++) {
        final item = (linesRaw as List)[i];
        if (item is! Map<String, Object?>) {
          errors['lines.$i'] = ['must be an object'];
        } else {
          final itemResult = OrderLine.$endorse.validate(item);
          switch (itemResult) {
            case ValidResult(:final value):
              linesItems.add(value);
            case InvalidResult(:final fieldErrors):
              for (final entry in fieldErrors.entries) {
                errors['lines.$i.${entry.key}'] = entry.value;
              }
          }
        }
      }
      if (!errors.keys.any((k) => k.startsWith('lines'))) {
        values['lines'] = linesItems;
      }
    }

    final billingAddressRaw = input['billingAddress'];
    if (billingAddressRaw != null) {
      if (billingAddressRaw is! Map<String, Object?>) {
        errors['billingAddress'] = ['must be an object'];
      } else {
        final billingAddressResult = Address.$endorse
            .validate(billingAddressRaw as Map<String, Object?>);
        switch (billingAddressResult) {
          case ValidResult(:final value):
            values['billingAddress'] = value;
          case InvalidResult(:final fieldErrors):
            for (final entry in fieldErrors.entries) {
              errors['billingAddress.${entry.key}'] = entry.value;
            }
        }
      }
    }

    if (errors.isNotEmpty) return InvalidResult(errors);

    return ValidResult(CreateOrderRequest._(
      customerId: values['customerId'] as String,
      address: values['address'] as Address,
      lines: values['lines'] as List<OrderLine>,
      billingAddress: values['billingAddress'] as Address?,
    ));
  }

  @override
  Map<String, Map<String, String>> get html5Attrs => const {
        'customerId': {'required': ''},
      };

  @override
  Map<String, List<Map<String, Object?>>> get clientRules => const {
        'customerId': [
          {'rule': 'Required'},
          {'rule': 'Uuid'},
        ],
      };
}

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) =>
    {
      'customerId': instance.customerId,
      'address': _$AddressToJson(instance.address),
      'lines': instance.lines.map((e) => _$OrderLineToJson(e)).toList(),
      if (instance.billingAddress != null)
        'billingAddress': _$AddressToJson(instance.billingAddress!),
    };
