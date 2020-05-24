import 'package:json_annotation/json_annotation.dart';
import 'package:stanza/annotations.dart';

part 'echo.g.dart';

@StanzaEntity()
@JsonSerializable()
class Echo {
  @StanzaField(name: 'id', readOnly: true)
  @JsonKey(name: 'id')
  int entityId;
  String echo;
  
  Echo();

  factory Echo.fromJson(Map<String, dynamic> json) => _$EchoFromJson(json);
  Map<String, dynamic> toJson() => _$EchoToJson(this);

  static _$EchoTable $table = _$EchoTable();
}