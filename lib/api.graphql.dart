// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:meta/meta.dart';
import 'package:artemis/artemis.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:gql/ast.dart';
part 'api.graphql.g.dart';

@JsonSerializable(explicitToJson: true)
class Signal$MutationRoot with EquatableMixin {
  Signal$MutationRoot();

  factory Signal$MutationRoot.fromJson(Map<String, dynamic> json) =>
      _$Signal$MutationRootFromJson(json);

  bool signal;

  @override
  List<Object> get props => [signal];
  Map<String, dynamic> toJson() => _$Signal$MutationRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LogIn$SubscriptionRoot$Signal with EquatableMixin {
  LogIn$SubscriptionRoot$Signal();

  factory LogIn$SubscriptionRoot$Signal.fromJson(Map<String, dynamic> json) =>
      _$LogIn$SubscriptionRoot$SignalFromJson(json);

  String payload;

  String peerId;

  @override
  List<Object> get props => [payload, peerId];
  Map<String, dynamic> toJson() => _$LogIn$SubscriptionRoot$SignalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LogIn$SubscriptionRoot with EquatableMixin {
  LogIn$SubscriptionRoot();

  factory LogIn$SubscriptionRoot.fromJson(Map<String, dynamic> json) =>
      _$LogIn$SubscriptionRootFromJson(json);

  LogIn$SubscriptionRoot$Signal logIn;

  @override
  List<Object> get props => [logIn];
  Map<String, dynamic> toJson() => _$LogIn$SubscriptionRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Room$SubscriptionRoot$RoomObj with EquatableMixin {
  Room$SubscriptionRoot$RoomObj();

  factory Room$SubscriptionRoot$RoomObj.fromJson(Map<String, dynamic> json) =>
      _$Room$SubscriptionRoot$RoomObjFromJson(json);

  List<String> users;

  @override
  List<Object> get props => [users];
  Map<String, dynamic> toJson() => _$Room$SubscriptionRoot$RoomObjToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Room$SubscriptionRoot with EquatableMixin {
  Room$SubscriptionRoot();

  factory Room$SubscriptionRoot.fromJson(Map<String, dynamic> json) =>
      _$Room$SubscriptionRootFromJson(json);

  Room$SubscriptionRoot$RoomObj room;

  @override
  List<Object> get props => [room];
  Map<String, dynamic> toJson() => _$Room$SubscriptionRootToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SignalArguments extends JsonSerializable with EquatableMixin {
  SignalArguments(
      {@required this.peerId, @required this.signal, @required this.userId});

  @override
  factory SignalArguments.fromJson(Map<String, dynamic> json) =>
      _$SignalArgumentsFromJson(json);

  final String peerId;

  final String signal;

  final String userId;

  @override
  List<Object> get props => [peerId, signal, userId];
  @override
  Map<String, dynamic> toJson() => _$SignalArgumentsToJson(this);
}

class SignalMutation
    extends GraphQLQuery<Signal$MutationRoot, SignalArguments> {
  SignalMutation({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: [
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
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    value: VariableNode(name: NameNode(value: 'signal'))),
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
              directives: [],
              selectionSet: null)
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'LogIn'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'logIn'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
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
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'Room'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'roomId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId'))),
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
  final String operationName = 'Signal';

  @override
  final SignalArguments variables;

  @override
  List<Object> get props => [document, operationName, variables];
  @override
  Signal$MutationRoot parse(Map<String, dynamic> json) =>
      Signal$MutationRoot.fromJson(json);
}

@JsonSerializable(explicitToJson: true)
class LogInArguments extends JsonSerializable with EquatableMixin {
  LogInArguments({@required this.userId});

  @override
  factory LogInArguments.fromJson(Map<String, dynamic> json) =>
      _$LogInArgumentsFromJson(json);

  final String userId;

  @override
  List<Object> get props => [userId];
  @override
  Map<String, dynamic> toJson() => _$LogInArgumentsToJson(this);
}

class LogInSubscription
    extends GraphQLQuery<LogIn$SubscriptionRoot, LogInArguments> {
  LogInSubscription({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: [
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
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    value: VariableNode(name: NameNode(value: 'signal'))),
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
              directives: [],
              selectionSet: null)
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'LogIn'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'logIn'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
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
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'Room'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'roomId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId'))),
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
  final String operationName = 'LogIn';

  @override
  final LogInArguments variables;

  @override
  List<Object> get props => [document, operationName, variables];
  @override
  LogIn$SubscriptionRoot parse(Map<String, dynamic> json) =>
      LogIn$SubscriptionRoot.fromJson(json);
}

@JsonSerializable(explicitToJson: true)
class RoomArguments extends JsonSerializable with EquatableMixin {
  RoomArguments({@required this.roomId, @required this.userId});

  @override
  factory RoomArguments.fromJson(Map<String, dynamic> json) =>
      _$RoomArgumentsFromJson(json);

  final String roomId;

  final String userId;

  @override
  List<Object> get props => [roomId, userId];
  @override
  Map<String, dynamic> toJson() => _$RoomArgumentsToJson(this);
}

class RoomSubscription
    extends GraphQLQuery<Room$SubscriptionRoot, RoomArguments> {
  RoomSubscription({this.variables});

  @override
  final DocumentNode document = DocumentNode(definitions: [
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
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    value: VariableNode(name: NameNode(value: 'signal'))),
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
              directives: [],
              selectionSet: null)
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'LogIn'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: [])
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
              name: NameNode(value: 'logIn'),
              alias: null,
              arguments: [
                ArgumentNode(
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId')))
              ],
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
        ])),
    OperationDefinitionNode(
        type: OperationType.subscription,
        name: NameNode(value: 'Room'),
        variableDefinitions: [
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'roomId')),
              type: NamedTypeNode(
                  name: NameNode(value: 'String'), isNonNull: true),
              defaultValue: DefaultValueNode(value: null),
              directives: []),
          VariableDefinitionNode(
              variable: VariableNode(name: NameNode(value: 'userId')),
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
                    name: NameNode(value: 'userId'),
                    value: VariableNode(name: NameNode(value: 'userId'))),
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
  final RoomArguments variables;

  @override
  List<Object> get props => [document, operationName, variables];
  @override
  Room$SubscriptionRoot parse(Map<String, dynamic> json) =>
      Room$SubscriptionRoot.fromJson(json);
}
