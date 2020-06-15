import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neural_graph/node.dart';

part 'adding_node_state.freezed.dart';

@freezed
abstract class AddingConnectionState with _$AddingConnectionState {
  const factory AddingConnectionState.none() = _None; 
  const factory AddingConnectionState.adding() = _Adding;
  const factory AddingConnectionState.addedInput(Node input) = _Added;
}