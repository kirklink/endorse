// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acquire_chat.dart';

// **************************************************************************
// EndorseEntityGenerator
// **************************************************************************

class _$AcquireChatValidationResult extends ClassResult {
  ValueResult _id;
  ValueResult get id => _id;
  ValueResult _account_id;
  ValueResult get account_id => _account_id;
  ValueResult _date_ended;
  ValueResult get date_ended => _date_ended;
  ValueResult _department_id;
  ValueResult get department_id => _department_id;
  ValueResult _event;
  ValueResult get event => _event;
  ValueResult _conversation_url;
  ValueResult get conversation_url => _conversation_url;
  ValueResult _session_id;
  ValueResult get session_id => _session_id;
  ValueResult _room_id;
  ValueResult get room_id => _room_id;
  ValueResult _os;
  ValueResult get os => _os;
  ValueResult _browser;
  ValueResult get browser => _browser;
  ValueResult _location;
  ValueResult get location => _location;
  ValueResult _chat_wait_time;
  ValueResult get chat_wait_time => _chat_wait_time;
  ValueResult _chat_duration;
  ValueResult get chat_duration => _chat_duration;
  ValueResult _type;
  ValueResult get type => _type;
  ValueResult _visitor_id;
  ValueResult get visitor_id => _visitor_id;
  ValueResult _country_code;
  ValueResult get country_code => _country_code;
  _$AcquireChatUsersValidationResult _users;
  _$AcquireChatUsersValidationResult get users => _users;
  ListResult _chat_messages;
  ListResult get chat_messages => _chat_messages;
  _$AcquireChatValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._id,
    this._account_id,
    this._date_ended,
    this._department_id,
    this._event,
    this._conversation_url,
    this._session_id,
    this._room_id,
    this._os,
    this._browser,
    this._location,
    this._chat_wait_time,
    this._chat_duration,
    this._type,
    this._visitor_id,
    this._country_code,
    this._users,
    this._chat_messages,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChat implements EndorseClassValidator {
  _$AcquireChatValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['id'] = (ValidateValue()..isInt()).from(input['id'], 'id');
    r['account_id'] = (ValidateValue()..isInt()).from(
      input['account_id'],
      'account_id',
    );
    r['date_ended'] = (ValidateValue()..isDateTime()).from(
      input['date_ended'],
      'date_ended',
    );
    r['department_id'] = (ValidateValue()..isInt()).from(
      input['department_id'],
      'department_id',
    );
    r['event'] = (ValidateValue()..isString()).from(input['event'], 'event');
    r['conversation_url'] = (ValidateValue()..isString()).from(
      input['conversation_url'],
      'conversation_url',
    );
    r['session_id'] = (ValidateValue()..isInt()).from(
      input['session_id'],
      'session_id',
    );
    r['room_id'] = (ValidateValue()..isString()).from(
      input['room_id'],
      'room_id',
    );
    r['os'] = (ValidateValue()..isString()).from(input['os'], 'os');
    r['browser'] = (ValidateValue()..isString()).from(
      input['browser'],
      'browser',
    );
    r['location'] = (ValidateValue()..isString()).from(
      input['location'],
      'location',
    );
    r['chat_wait_time'] = (ValidateValue()..isInt()).from(
      input['chat_wait_time'],
      'chat_wait_time',
    );
    r['chat_duration'] = (ValidateValue()..isInt()).from(
      input['chat_duration'],
      'chat_duration',
    );
    r['type'] = (ValidateValue()..isString()).from(input['type'], 'type');
    r['visitor_id'] = (ValidateValue()..isInt()).from(
      input['visitor_id'],
      'visitor_id',
    );
    r['country_code'] = (ValidateValue()..isString()).from(
      input['country_code'],
      'country_code',
    );
    r['users'] = (ValidateMap<_$AcquireChatUsersValidationResult>(
      ValidateValue()..isMap(),
      _$EndorseAcquireChatUsers(),
    )).from(input['users'], 'users');
    r['chat_messages'] = (ValidateList.fromEndorse(
      ValidateValue()..isList(),
      _$EndorseAcquireChatMessage(),
    )).from(input['chat_messages'], 'chat_messages');
    return _$AcquireChatValidationResult(
      r,
      null,
      r['id'],
      r['account_id'],
      r['date_ended'],
      r['department_id'],
      r['event'],
      r['conversation_url'],
      r['session_id'],
      r['room_id'],
      r['os'],
      r['browser'],
      r['location'],
      r['chat_wait_time'],
      r['chat_duration'],
      r['type'],
      r['visitor_id'],
      r['country_code'],
      r['users'],
      r['chat_messages'],
    );
  }

  _$AcquireChatValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatValidationResult(null, mapResult);
  }
}

class _$AcquireChatUsersValidationResult extends ClassResult {
  _$AcquireChatAgentValidationResult _agent;
  _$AcquireChatAgentValidationResult get agent => _agent;
  _$AcquireChatVisitorValidationResult _visitor;
  _$AcquireChatVisitorValidationResult get visitor => _visitor;
  _$AcquireChatUsersValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._agent,
    this._visitor,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatUsers implements EndorseClassValidator {
  _$AcquireChatUsersValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['agent'] = (ValidateMap<_$AcquireChatAgentValidationResult>(
      ValidateValue()..isMap(),
      _$EndorseAcquireChatAgent(),
    )).from(input['agent'], 'agent');
    r['visitor'] = (ValidateMap<_$AcquireChatVisitorValidationResult>(
      ValidateValue()..isMap(),
      _$EndorseAcquireChatVisitor(),
    )).from(input['visitor'], 'visitor');
    return _$AcquireChatUsersValidationResult(
      r,
      null,
      r['agent'],
      r['visitor'],
    );
  }

  _$AcquireChatUsersValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatUsersValidationResult(null, mapResult);
  }
}

class _$AcquireChatAgentValidationResult extends ClassResult {
  ValueResult _name;
  ValueResult get name => _name;
  ValueResult _email;
  ValueResult get email => _email;
  ValueResult _role;
  ValueResult get role => _role;
  _$AcquireChatAgentValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._name,
    this._email,
    this._role,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatAgent implements EndorseClassValidator {
  _$AcquireChatAgentValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['name'] = (ValidateValue()..isString()).from(input['name'], 'name');
    r['email'] = (ValidateValue()..isString()).from(input['email'], 'email');
    r['role'] = (ValidateValue()..isString()).from(input['role'], 'role');
    return _$AcquireChatAgentValidationResult(
      r,
      null,
      r['name'],
      r['email'],
      r['role'],
    );
  }

  _$AcquireChatAgentValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatAgentValidationResult(null, mapResult);
  }
}

class _$AcquireChatVisitorValidationResult extends ClassResult {
  ValueResult _name;
  ValueResult get name => _name;
  ValueResult _email;
  ValueResult get email => _email;
  ValueResult _phone;
  ValueResult get phone => _phone;
  ValueResult _remarks;
  ValueResult get remarks => _remarks;
  _$AcquireChatVisitorFieldsValidationResult _fields;
  _$AcquireChatVisitorFieldsValidationResult get fields => _fields;
  _$AcquireChatVisitorValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._name,
    this._email,
    this._phone,
    this._remarks,
    this._fields,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatVisitor implements EndorseClassValidator {
  _$AcquireChatVisitorValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['name'] = (ValidateValue()..isString()).from(input['name'], 'name');
    r['email'] = (ValidateValue()..isString()).from(input['email'], 'email');
    r['phone'] = (ValidateValue()..isString()).from(input['phone'], 'phone');
    r['remarks'] = (ValidateValue()..isString()).from(
      input['remarks'],
      'remarks',
    );
    r['fields'] = (ValidateMap<_$AcquireChatVisitorFieldsValidationResult>(
      ValidateValue()..isMap(),
      _$EndorseAcquireChatVisitorFields(),
    )).from(input['fields'], 'fields');
    return _$AcquireChatVisitorValidationResult(
      r,
      null,
      r['name'],
      r['email'],
      r['phone'],
      r['remarks'],
      r['fields'],
    );
  }

  _$AcquireChatVisitorValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatVisitorValidationResult(null, mapResult);
  }
}

class _$AcquireChatVisitorFieldsValidationResult extends ClassResult {
  ValueResult _Remark;
  ValueResult get Remark => _Remark;
  ValueResult _bot_lead_type;
  ValueResult get bot_lead_type => _bot_lead_type;
  ValueResult _bot_comment1;
  ValueResult get bot_comment1 => _bot_comment1;
  ValueResult _form_lead_type;
  ValueResult get form_lead_type => _form_lead_type;
  _$AcquireChatVisitorFieldsValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._Remark,
    this._bot_lead_type,
    this._bot_comment1,
    this._form_lead_type,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatVisitorFields implements EndorseClassValidator {
  _$AcquireChatVisitorFieldsValidationResult validate(
    Map<String, Object> input,
  ) {
    final r = <String, ResultObject>{};
    r['Remark'] = (ValidateValue()..isString()).from(input['Remark'], 'Remark');
    r['bot_lead_type'] = (ValidateValue()..isString()).from(
      input['bot_lead_type'],
      'bot_lead_type',
    );
    r['bot_comment1'] = (ValidateValue()..isString()).from(
      input['bot_comment1'],
      'bot_comment1',
    );
    r['form_lead_type'] = (ValidateValue()..isString()).from(
      input['form_lead_type'],
      'form_lead_type',
    );
    return _$AcquireChatVisitorFieldsValidationResult(
      r,
      null,
      r['Remark'],
      r['bot_lead_type'],
      r['bot_comment1'],
      r['form_lead_type'],
    );
  }

  _$AcquireChatVisitorFieldsValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatVisitorFieldsValidationResult(null, mapResult);
  }
}

class _$AcquireChatMessageValidationResult extends ClassResult {
  ValueResult _id;
  ValueResult get id => _id;
  ValueResult _chat_id;
  ValueResult get chat_id => _chat_id;
  ValueResult _sender_type;
  ValueResult get sender_type => _sender_type;
  ValueResult _sender_id;
  ValueResult get sender_id => _sender_id;
  ValueResult _type;
  ValueResult get type => _type;
  ValueResult _message;
  ValueResult get message => _message;
  ValueResult _date_created;
  ValueResult get date_created => _date_created;
  _$AcquireChatMessageUserValidationResult _user;
  _$AcquireChatMessageUserValidationResult get user => _user;
  _$AcquireChatMessageValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._id,
    this._chat_id,
    this._sender_type,
    this._sender_id,
    this._type,
    this._message,
    this._date_created,
    this._user,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatMessage implements EndorseClassValidator {
  _$AcquireChatMessageValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['id'] =
        (ValidateValue()
              ..isString(toString: true)
              ..isNum()
              ..makeString())
            .from(input['id'], 'id');
    r['chat_id'] = (ValidateValue()..isInt()).from(input['chat_id'], 'chat_id');
    r['sender_type'] = (ValidateValue()..isString()).from(
      input['sender_type'],
      'sender_type',
    );
    r['sender_id'] = (ValidateValue()..isInt()).from(
      input['sender_id'],
      'sender_id',
    );
    r['type'] = (ValidateValue()..isString()).from(input['type'], 'type');
    r['message'] = (ValidateValue()..isString()).from(
      input['message'],
      'message',
    );
    r['date_created'] = (ValidateValue()..isDateTime()).from(
      input['date_created'],
      'date_created',
    );
    r['user'] = (ValidateMap<_$AcquireChatMessageUserValidationResult>(
      ValidateValue()..isMap(),
      _$EndorseAcquireChatMessageUser(),
    )).from(input['user'], 'user');
    return _$AcquireChatMessageValidationResult(
      r,
      null,
      r['id'],
      r['chat_id'],
      r['sender_type'],
      r['sender_id'],
      r['type'],
      r['message'],
      r['date_created'],
      r['user'],
    );
  }

  _$AcquireChatMessageValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatMessageValidationResult(null, mapResult);
  }
}

class _$AcquireChatMessageUserValidationResult extends ClassResult {
  ValueResult _id;
  ValueResult get id => _id;
  ValueResult _type;
  ValueResult get type => _type;
  ValueResult _name;
  ValueResult get name => _name;
  _$AcquireChatMessageUserValidationResult(
    Map<String, ResultObject> fields,
    ValueResult mapResult, [
    this._id,
    this._type,
    this._name,
  ]) : super(fields, mapResult);
}

class _$EndorseAcquireChatMessageUser implements EndorseClassValidator {
  _$AcquireChatMessageUserValidationResult validate(Map<String, Object> input) {
    final r = <String, ResultObject>{};
    r['id'] = (ValidateValue()..isInt()).from(input['id'], 'id');
    r['type'] = (ValidateValue()..isString()).from(input['type'], 'type');
    r['name'] = (ValidateValue()..isString()).from(input['name'], 'name');
    return _$AcquireChatMessageUserValidationResult(
      r,
      null,
      r['id'],
      r['type'],
      r['name'],
    );
  }

  _$AcquireChatMessageUserValidationResult invalid(ValueResult mapResult) {
    return _$AcquireChatMessageUserValidationResult(null, mapResult);
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcquireChat _$AcquireChatFromJson(Map<String, dynamic> json) {
  return AcquireChat()
    ..id = json['id'] as int
    ..accountId = json['account_id'] as int
    ..dateEnded = json['date_ended'] == null
        ? null
        : DateTime.parse(json['date_ended'] as String)
    ..departmentId = json['department_id'] as int
    ..event = json['event'] as String
    ..conversationUrl = json['conversation_url'] as String
    ..sessionId = json['session_id'] as int
    ..roomId = json['room_id'] as String
    ..os = json['os'] as String
    ..browser = json['browser'] as String
    ..location = json['location'] as String
    ..chatWaitTime = json['chat_wait_time'] as int
    ..chatDuration = json['chat_duration'] as int
    ..type = json['type'] as String
    ..visitorId = json['visitor_id'] as int
    ..countryCode = json['country_code'] as String
    ..users = json['users'] == null
        ? null
        : AcquireChatUsers.fromJson(json['users'] as Map<String, dynamic>)
    ..chatMessages = (json['chat_messages'] as List)
        ?.map(
          (e) => e == null
              ? null
              : AcquireChatMessage.fromJson(e as Map<String, dynamic>),
        )
        ?.toList();
}

Map<String, dynamic> _$AcquireChatToJson(AcquireChat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account_id': instance.accountId,
      'date_ended': instance.dateEnded?.toIso8601String(),
      'department_id': instance.departmentId,
      'event': instance.event,
      'conversation_url': instance.conversationUrl,
      'session_id': instance.sessionId,
      'room_id': instance.roomId,
      'os': instance.os,
      'browser': instance.browser,
      'location': instance.location,
      'chat_wait_time': instance.chatWaitTime,
      'chat_duration': instance.chatDuration,
      'type': instance.type,
      'visitor_id': instance.visitorId,
      'country_code': instance.countryCode,
      'users': instance.users,
      'chat_messages': instance.chatMessages,
    };

AcquireChatUsers _$AcquireChatUsersFromJson(Map<String, dynamic> json) {
  return AcquireChatUsers()
    ..agent = json['agent'] == null
        ? null
        : AcquireChatAgent.fromJson(json['agent'] as Map<String, dynamic>)
    ..visitor = json['visitor'] == null
        ? null
        : AcquireChatVisitor.fromJson(json['visitor'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AcquireChatUsersToJson(AcquireChatUsers instance) =>
    <String, dynamic>{'agent': instance.agent, 'visitor': instance.visitor};

AcquireChatAgent _$AcquireChatAgentFromJson(Map<String, dynamic> json) {
  return AcquireChatAgent()
    ..name = json['name'] as String
    ..email = json['email'] as String
    ..role = json['role'] as String;
}

Map<String, dynamic> _$AcquireChatAgentToJson(AcquireChatAgent instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };

AcquireChatVisitor _$AcquireChatVisitorFromJson(Map<String, dynamic> json) {
  return AcquireChatVisitor()
    ..name = json['name'] as String
    ..email = json['email'] as String
    ..phone = json['phone'] as String
    ..remarks = json['remarks'] as String
    ..fields = json['fields'] == null
        ? null
        : AcquireChatVisitorFields.fromJson(
            json['fields'] as Map<String, dynamic>,
          );
}

Map<String, dynamic> _$AcquireChatVisitorToJson(AcquireChatVisitor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'remarks': instance.remarks,
      'fields': instance.fields,
    };

AcquireChatVisitorFields _$AcquireChatVisitorFieldsFromJson(
  Map<String, dynamic> json,
) {
  return AcquireChatVisitorFields()
    ..remark = json['Remark'] as String
    ..botLeadType = json['bot_lead_type'] as String
    ..botComment1 = json['bot_comment1'] as String
    ..formLeadType = json['form_lead_type'] as String;
}

Map<String, dynamic> _$AcquireChatVisitorFieldsToJson(
  AcquireChatVisitorFields instance,
) => <String, dynamic>{
  'Remark': instance.remark,
  'bot_lead_type': instance.botLeadType,
  'bot_comment1': instance.botComment1,
  'form_lead_type': instance.formLeadType,
};

AcquireChatMessage _$AcquireChatMessageFromJson(Map<String, dynamic> json) {
  return AcquireChatMessage()
    ..id = AcquireChatMessage._numToString(json['id'] as num)
    ..chatId = json['chat_id'] as int
    ..senderType = json['sender_type'] as String
    ..senderId = json['sender_id'] as int
    ..type = json['type'] as String
    ..message = json['message'] as String
    ..dateCreated = json['date_created'] == null
        ? null
        : DateTime.parse(json['date_created'] as String)
    ..user = json['user'] == null
        ? null
        : AcquireChatMessageUser.fromJson(json['user'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AcquireChatMessageToJson(AcquireChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_type': instance.senderType,
      'sender_id': instance.senderId,
      'type': instance.type,
      'message': instance.message,
      'date_created': instance.dateCreated?.toIso8601String(),
      'user': instance.user,
    };

AcquireChatMessageUser _$AcquireChatMessageUserFromJson(
  Map<String, dynamic> json,
) {
  return AcquireChatMessageUser()
    ..id = json['id'] as int
    ..type = json['type'] as String
    ..name = json['name'] as String;
}

Map<String, dynamic> _$AcquireChatMessageUserToJson(
  AcquireChatMessageUser instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'name': instance.name,
};
