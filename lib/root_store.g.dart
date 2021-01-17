// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$RootStore on _RootStore, Store {
  final _$networksAtom = Atom(name: '_RootStore.networks');

  @override
  ObservableMap<String, NeuralNetwork> get networks {
    _$networksAtom.reportRead();
    return super.networks;
  }

  @override
  set networks(ObservableMap<String, NeuralNetwork> value) {
    _$networksAtom.reportWrite(value, super.networks, () {
      super.networks = value;
    });
  }

  final _$selectedNetworkAtom = Atom(name: '_RootStore.selectedNetwork');

  @override
  NeuralNetwork get selectedNetwork {
    _$selectedNetworkAtom.reportRead();
    return super.selectedNetwork;
  }

  @override
  set selectedNetwork(NeuralNetwork value) {
    _$selectedNetworkAtom.reportWrite(value, super.selectedNetwork, () {
      super.selectedNetwork = value;
    });
  }

  @override
  String toString() {
    return '''
networks: ${networks},
selectedNetwork: ${selectedNetwork}
    ''';
  }
}
