import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neural_graph/node.dart';

part 'adding_node_state.freezed.dart';

@freezed
abstract class AddingConnectionState implements _$AddingConnectionState {
  const AddingConnectionState._();
  const factory AddingConnectionState.none() = _None;
  const factory AddingConnectionState.adding() = _Adding;
  const factory AddingConnectionState.addedInput(Node input) = _Added;

  bool isNone() => maybeWhen(orElse: () => false, none: () => true);
  bool isAddedInput() =>
      maybeWhen(orElse: () => false, addedInput: (_) => true);
}
