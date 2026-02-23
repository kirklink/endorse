import 'package:endorse/annotations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'acquire_chat.g.dart';

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChat {
  int id;
  int accountId;
  DateTime dateEnded;
  int departmentId;
  String event;
  String conversationUrl;
  int sessionId;
  String roomId;
  String os;
  String browser;
  String location;
  int chatWaitTime;
  int chatDuration;
  String type;
  int visitorId;
  String countryCode;
  AcquireChatUsers users;
  List<AcquireChatMessage> chatMessages;

  AcquireChat();

  factory AcquireChat.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatToJson(this);

  static final $endorse = _$EndorseAcquireChat();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatUsers {
  AcquireChatAgent agent;
  AcquireChatVisitor visitor;

  AcquireChatUsers();

  factory AcquireChatUsers.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatUsersFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatUsersToJson(this);

  static final $endorse = _$EndorseAcquireChatUsers();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatAgent {
  String name;
  String email;
  String role;

  AcquireChatAgent();

  factory AcquireChatAgent.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatAgentFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatAgentToJson(this);

  static final $endorse = _$EndorseAcquireChatAgent();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatVisitor {
  String name;
  String email;
  String phone;
  String remarks;
  AcquireChatVisitorFields fields = AcquireChatVisitorFields();

  AcquireChatVisitor();

  factory AcquireChatVisitor.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatVisitorFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatVisitorToJson(this);

  static final $endorse = _$EndorseAcquireChatVisitor();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatVisitorFields {
  @JsonKey(name: 'Remark')
  @EndorseField(name: 'Remark')
  String remark;
  String botLeadType;
  String botComment1;
  String formLeadType;

  AcquireChatVisitorFields();

  factory AcquireChatVisitorFields.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatVisitorFieldsFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatVisitorFieldsToJson(this);

  static final $endorse = _$EndorseAcquireChatVisitorFields();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatMessage {
  @JsonKey(fromJson: _numToString)
  @EndorseField(validate: [ToStringFromNum()])
  String id;
  int chatId;
  String senderType;
  int senderId;
  String type;
  String message;
  DateTime dateCreated;
  AcquireChatMessageUser user = AcquireChatMessageUser();

  AcquireChatMessage();

  factory AcquireChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatMessageToJson(this);

  static final $endorse = _$EndorseAcquireChatMessage();

  static String _numToString(num n) => n.toString();
}

@EndorseEntity(useCase: Case.snakeCase)
@JsonSerializable(fieldRename: FieldRename.snake)
class AcquireChatMessageUser {
  int id;
  String type;
  String name;

  AcquireChatMessageUser();

  factory AcquireChatMessageUser.fromJson(Map<String, dynamic> json) =>
      _$AcquireChatMessageUserFromJson(json);
  Map<String, dynamic> toJson() => _$AcquireChatMessageUserToJson(this);

  static final $endorse = _$EndorseAcquireChatMessageUser();
}
