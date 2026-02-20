/// AI-first validation library for Dart with code generation.
///
/// Annotate classes with `@Endorse()` and fields with `@EndorseField()`,
/// then run `dart run build_runner build` to generate validators.
///
/// ```dart
/// import 'package:endorse/endorse.dart';
///
/// part 'my_request.g.dart';
///
/// @Endorse()
/// class CreateItemRequest {
///   @EndorseField(rules: [MinLength(1), MaxLength(100)])
///   final String name;
///
///   @EndorseField(rules: [Min(0)])
///   final int quantity;
///
///   final String? description;
///
///   const CreateItemRequest._({
///     required this.name,
///     required this.quantity,
///     this.description,
///   });
///
///   Map<String, dynamic> toJson() => _$CreateItemRequestToJson(this);
///   static final $endorse = _$CreateItemRequestValidator();
/// }
/// ```
library;

export 'src/annotations.dart';
export 'src/registry.dart';
export 'src/result.dart';
export 'src/rules.dart';
export 'src/validator.dart';
