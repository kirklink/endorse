import 'package:endorse/endorse.dart';

part 'nested_request.g.dart';

/// Nested object — tests recursive validation and dot-path errors.
@Endorse()
class Address {
  @EndorseField(rules: [MinLength(1)])
  final String street;

  @EndorseField(rules: [MinLength(1)])
  final String city;

  @EndorseField(rules: [Matches(r'^\d{5}$', message: 'must be a 5-digit zip code')])
  final String zip;

  const Address._({
    required this.street,
    required this.city,
    required this.zip,
  });

  Map<String, dynamic> toJson() => _$AddressToJson(this);
  static final $endorse = _$AddressValidator();
}

/// Nested entity in a list — tests list-of-nested validation.
@Endorse()
class OrderLine {
  final String productId;

  @EndorseField(rules: [Min(1)])
  final int quantity;

  const OrderLine._({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => _$OrderLineToJson(this);
  static final $endorse = _$OrderLineValidator();
}

/// Parent with nested object + nested list — tests all nesting patterns.
@Endorse()
class CreateOrderRequest {
  @EndorseField(rules: [Uuid()])
  final String customerId;

  final Address address;

  @EndorseField(rules: [MinElements(1)])
  final List<OrderLine> lines;

  final Address? billingAddress;

  const CreateOrderRequest._({
    required this.customerId,
    required this.address,
    required this.lines,
    this.billingAddress,
  });

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
  static final $endorse = _$CreateOrderRequestValidator();
}
