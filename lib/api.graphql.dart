// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:artemis/artemis.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class Signal$MutationRoot extends JsonSerializable with EquatableMixin {
  Signal$MutationRoot();

  factory Signal$MutationRoot.fromJson(Map<String, dynamic> json) =>
      _$Signal$MutationRootFromJson(json);

  late bool signal;

  @override
  List<Object?> get props => [signal];
  @override
  Map<String, dynamic> toJson() => _$Signal$MutationRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateSession$MutationRoot$UserSession extends JsonSerializable
    with EquatableMixin {
  CreateSession$MutationRoot$UserSession();

  factory CreateSession$MutationRoot$UserSession.fromJson(
          Map<String, dynamic> json) =>
      _$CreateSession$MutationRoot$UserSessionFromJson(json);

  late String userId;

  late String? token;

  @override
  List<Object?> get props => [userId, token];
  @override
  Map<String, dynamic> toJson() =>
      _$CreateSession$MutationRoot$UserSessionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateSession$MutationRoot extends JsonSerializable with EquatableMixin {
  CreateSession$MutationRoot();

  factory CreateSession$MutationRoot.fromJson(Map<String, dynamic> json) =>
      _$CreateSession$MutationRootFromJson(json);

  late CreateSession$MutationRoot$UserSession createSessionId;

  @override
  List<Object?> get props => [createSessionId];
  @override
  Map<String, dynamic> toJson() => _$CreateSession$MutationRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Signals$SubscriptionRoot$Signal extends JsonSerializable
    with EquatableMixin {
  Signals$SubscriptionRoot$Signal();

  factory Signals$SubscriptionRoot$Signal.fromJson(Map<String, dynamic> json) =>
      _$Signals$SubscriptionRoot$SignalFromJson(json);

  late String payload;

  late String peerId;

  @override
  List<Object?> get props => [payload, peerId];
  @override
  Map<String, dynamic> toJson() =>
      _$Signals$SubscriptionRoot$SignalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Signals$SubscriptionRoot extends JsonSerializable with EquatableMixin {
  Signals$SubscriptionRoot();

  factory Signals$SubscriptionRoot.fromJson(Map<String, dynamic> json) =>
      _$Signals$SubscriptionRootFromJson(json);

  late Signals$SubscriptionRoot$Signal signals;

  @override
  List<Object?> get props => [signals];
  @override
  Map<String, dynamic> toJson() => _$Signals$SubscriptionRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Room$SubscriptionRoot$Room extends JsonSerializable with EquatableMixin {
  Room$SubscriptionRoot$Room();

  factory Room$SubscriptionRoot$Room.fromJson(Map<String, dynamic> json) =>
      _$Room$SubscriptionRoot$RoomFromJson(json);

  late List<String> users;

  @override
  List<Object?> get props => [users];
  @override
  Map<String, dynamic> toJson() => _$Room$SubscriptionRoot$RoomToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Room$SubscriptionRoot extends JsonSerializable with EquatableMixin {
  Room$SubscriptionRoot();

  factory Room$SubscriptionRoot.fromJson(Map<String, dynamic> json) =>
      _$Room$SubscriptionRootFromJson(json);

  late Room$SubscriptionRoot$Room room;

  @override
  List<Object?> get props => [room];
  @override
  Map<String, dynamic> toJson() => _$Room$SubscriptionRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SignalArguments extends JsonSerializable with EquatableMixin {
  SignalArguments({required this.peerId, required this.signal});

  @override
  factory SignalArguments.fromJson(Map<String, dynamic> json) =>
      _$SignalArgumentsFromJson(json);

  final String peerId;

  final String signal;

  @override
  List<Object?> get props => [peerId, signal];
  @override
  Map<String, dynamic> toJson() => _$SignalArgumentsToJson(this);
}

class SignalMutation
    extends GraphQLQuery<Signal$MutationRoot, SignalArguments> {
  SignalMutation({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: const [
    OperationDefinitionNode(
        type: OperationType.mutation,
        name: NameNode(value: 'Signal'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'peerId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'signal')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'signal'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'peerId'),
                    value: VariableNode(name: NameNode(value: 'peerId'))),
                ArgumentNode(
                    name: NameNode(value: 'signal'),
                    value: VariableNode(name: NameNode(value: 'signal')))
              ],
              directives: [],
              selectionSet: null)
        ]))
  ]);

  @override
  final String operationName = 'Signal';

  @override
  final SignalArguments? variables;

  @override
  List<Object?> get props => [document, operationName, variables];
  @override
  Signal$MutationRoot parse(Map<String, dynamic> json) =>
      Signal$MutationRoot.fromJson(json);
}

class CreateSessionMutation
    extends GraphQLQuery<CreateSession$MutationRoot, JsonSerializable> {
  CreateSessionMutation();

  @override
  final DocumentNode document = DocumentNode(definitions: const [
    OperationDefinitionNode(
        type: OperationType.mutation,
        name: NameNode(value: 'CreateSession'),
        variableDefinitions: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'createSessionId'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(selections: [
                FieldNode(
                    name: NameNode(value: 'userId'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null),
                FieldNode(
                    name: NameNode(value: 'token'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null)
              ]))
        ]))
  ]);

  @override
  final String operationName = 'CreateSession';

  @override
  List<Object?> get props => [document, operationName];
  @override
  CreateSession$MutationRoot parse(Map<String, dynamic> json) =>
      CreateSession$MutationRoot.fromJson(json);
}

class SignalsSubscription
    extends GraphQLQuery<Signals$SubscriptionRoot, JsonSerializable> {
  SignalsSubscription();

  @override
  final DocumentNode document = DocumentNode(definitions: const [
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'Signals'),
        variableDefinitions: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'signals'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: SelectionSetNode(selections: [
                FieldNode(
                    name: NameNode(value: 'payload'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null),
                FieldNode(
                    name: NameNode(value: 'peerId'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null)
              ]))
        ]))
  ]);

  @override
  final String operationName = 'Signals';

  @override
  List<Object?> get props => [document, operationName];
  @override
  Signals$SubscriptionRoot parse(Map<String, dynamic> json) =>
      Signals$SubscriptionRoot.fromJson(json);
}

@JsonSerializable(explicitToJson: true)
class RoomArguments extends JsonSerializable with EquatableMixin {
  RoomArguments({required this.roomId});

  @override
  factory RoomArguments.fromJson(Map<String, dynamic> json) =>
      _$RoomArgumentsFromJson(json);

  final String roomId;

  @override
  List<Object?> get props => [roomId];
  @override
  Map<String, dynamic> toJson() => _$RoomArgumentsToJson(this);
}

class RoomSubscription
    extends GraphQLQuery<Room$SubscriptionRoot, RoomArguments> {
  RoomSubscription({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: const [
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'Room'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'roomId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'room'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'roomId'),
                    value: VariableNode(name: NameNode(value: 'roomId')))
              ],
              directives: [],
              selectionSet: SelectionSetNode(selections: [
                FieldNode(
                    name: NameNode(value: 'users'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null)
              ]))
        ]))
  ]);

  @override
  final String operationName = 'Room';

  @override
  final RoomArguments? variables;

  @override
  List<Object?> get props => [document, operationName, variables];
  @override
  Room$SubscriptionRoot parse(Map<String, dynamic> json) =>
      Room$SubscriptionRoot.fromJson(json);
}
