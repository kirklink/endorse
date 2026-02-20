import 'package:endorse/endorse.dart';

part 'extended_request.g.dart';

/// Tests Trim transform, custom messages, DateTime rules, and IpAddress.
@Endorse()
class EventRequest {
  @EndorseField(rules: [Trim(), MinLength(1, message: 'event name is required')])
  final String name;

  @EndorseField(rules: [IsAfterDate('today', message: 'must be a future date')])
  final DateTime startDate;

  @EndorseField(rules: [IsFutureDatetime()])
  final DateTime? deadline;

  const EventRequest._({
    required this.name,
    required this.startDate,
    this.deadline,
  });

  Map<String, dynamic> toJson() => _$EventRequestToJson(this);
  static final $endorse = _$EventRequestValidator();
}

/// Tests IpAddress and custom messages on various rules.
@Endorse()
class ServerConfig {
  @EndorseField(rules: [IpAddress(message: 'enter a valid IP')])
  final String host;

  @EndorseField(rules: [Min(1, message: 'port must be positive'), Max(65535)])
  final int port;

  @EndorseField(rules: [Trim(), Url()])
  final String? callbackUrl;

  const ServerConfig._({
    required this.host,
    required this.port,
    this.callbackUrl,
  });

  Map<String, dynamic> toJson() => _$ServerConfigToJson(this);
  static final $endorse = _$ServerConfigValidator();
}

/// Tests LowerCase and UpperCase transforms.
@Endorse()
class NormalizedInput {
  @EndorseField(rules: [Trim(), LowerCase(), Email()])
  final String email;

  @EndorseField(rules: [UpperCase(), OneOf(['US', 'CA', 'UK'])])
  final String countryCode;

  const NormalizedInput._({
    required this.email,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() => _$NormalizedInputToJson(this);
  static final $endorse = _$NormalizedInputValidator();
}
