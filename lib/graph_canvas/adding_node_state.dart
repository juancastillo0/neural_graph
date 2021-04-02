import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neural_graph/diagram/connection.dart';
import 'package:neural_graph/diagram/node.dart';

part 'adding_node_state.freezed.dart';

@freezed
class AddingConnectionState<N extends NodeData>
    with _$AddingConnectionState<N> {
  const AddingConnectionState._();
  const factory AddingConnectionState.none() = _None<N>;
  const factory AddingConnectionState.addedInput(Port<N> input) = _Added<N>;

  bool isNone() => maybeWhen(orElse: () => false, none: () => true);
  bool isAddedInput() =>
      maybeWhen(orElse: () => false, addedInput: (_) => true);
}
