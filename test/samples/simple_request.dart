import 'package:endorse/endorse.dart';

part 'simple_request.g.dart';

/// Simple flat request — tests basic field validation, auto-coercion,
/// optional fields, and toJson generation.
@Endorse()
class CreateItemRequest {
  @EndorseField(rules: [MinLength(1), MaxLength(100)])
  final String name;

  @EndorseField(rules: [Min(0)])
  final int quantity;

  final String? description;

  const CreateItemRequest._({
    required this.name,
    required this.quantity,
    this.description,
  });

  Map<String, dynamic> toJson() => _$CreateItemRequestToJson(this);
  static final $endorse = _$CreateItemRequestValidator();
}

/// Tests email validation, custom field name mapping, and OneOf.
@Endorse()
class UserProfile {
  @EndorseField(rules: [MinLength(2), MaxLength(50)])
  final String displayName;

  @EndorseField(rules: [Email()])
  final String email;

  @EndorseField(name: 'user_role', rules: [OneOf(['admin', 'user', 'guest'])])
  final String role;

  final int? age;

  const UserProfile._({
    required this.displayName,
    required this.email,
    required this.role,
    this.age,
  });

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
  static final $endorse = _$UserProfileValidator();
}
