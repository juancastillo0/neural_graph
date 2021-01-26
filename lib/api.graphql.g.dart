// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.graphql.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Signal$MutationRoot _$Signal$MutationRootFromJson(Map<String, dynamic> json) {
  return Signal$MutationRoot()..signal = json['signal'] as bool;
}

Map<String, dynamic> _$Signal$MutationRootToJson(
        Signal$MutationRoot instance) =>
    <String, dynamic>{
      'signal': instance.signal,
    };

LogIn$SubscriptionRoot$Signal _$LogIn$SubscriptionRoot$SignalFromJson(
    Map<String, dynamic> json) {
  return LogIn$SubscriptionRoot$Signal()
    ..payload = json['payload'] as String
    ..peerId = json['peerId'] as String;
}

Map<String, dynamic> _$LogIn$SubscriptionRoot$SignalToJson(
        LogIn$SubscriptionRoot$Signal instance) =>
    <String, dynamic>{
      'payload': instance.payload,
      'peerId': instance.peerId,
    };

LogIn$SubscriptionRoot _$LogIn$SubscriptionRootFromJson(
    Map<String, dynamic> json) {
  return LogIn$SubscriptionRoot()
    ..logIn = json['logIn'] == null
        ? null
        : LogIn$SubscriptionRoot$Signal.fromJson(
            json['logIn'] as Map<String, dynamic>);
}

Map<String, dynamic> _$LogIn$SubscriptionRootToJson(
        LogIn$SubscriptionRoot instance) =>
    <String, dynamic>{
      'logIn': instance.logIn?.toJson(),
    };

Room$SubscriptionRoot$RoomObj _$Room$SubscriptionRoot$RoomObjFromJson(
    Map<String, dynamic> json) {
  return Room$SubscriptionRoot$RoomObj()
    ..users = (json['users'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$Room$SubscriptionRoot$RoomObjToJson(
        Room$SubscriptionRoot$RoomObj instance) =>
    <String, dynamic>{
      'users': instance.users,
    };

Room$SubscriptionRoot _$Room$SubscriptionRootFromJson(
    Map<String, dynamic> json) {
  return Room$SubscriptionRoot()
    ..room = json['room'] == null
        ? null
        : Room$SubscriptionRoot$RoomObj.fromJson(
            json['room'] as Map<String, dynamic>);
}

Map<String, dynamic> _$Room$SubscriptionRootToJson(
        Room$SubscriptionRoot instance) =>
    <String, dynamic>{
      'room': instance.room?.toJson(),
    };

SignalArguments _$SignalArgumentsFromJson(Map<String, dynamic> json) {
  return SignalArguments(
    peerId: json['peerId'] as String,
    signal: json['signal'] as String,
    userId: json['userId'] as String,
  );
}

Map<String, dynamic> _$SignalArgumentsToJson(SignalArguments instance) =>
    <String, dynamic>{
      'peerId': instance.peerId,
      'signal': instance.signal,
      'userId': instance.userId,
    };

LogInArguments _$LogInArgumentsFromJson(Map<String, dynamic> json) {
  return LogInArguments(
    userId: json['userId'] as String,
  );
}

Map<String, dynamic> _$LogInArgumentsToJson(LogInArguments instance) =>
    <String, dynamic>{
      'userId': instance.userId,
    };

RoomArguments _$RoomArgumentsFromJson(Map<String, dynamic> json) {
  return RoomArguments(
    roomId: json['roomId'] as String,
    userId: json['userId'] as String,
  );
}

Map<String, dynamic> _$RoomArgumentsToJson(RoomArguments instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'userId': instance.userId,
    };
