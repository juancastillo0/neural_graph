// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RootStore on _RootStore, Store {
  Computed<String>? _$generatedSourceCodeComputed;

  @override
  String get generatedSourceCode => (_$generatedSourceCodeComputed ??=
          Computed<String>(() => super.generatedSourceCode,
              name: '_RootStore.generatedSourceCode'))
      .value;

  late final _$selectedNetworkAtom =
      Atom(name: '_RootStore.selectedNetwork', context: context);

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

  late final _$languageAtom =
      Atom(name: '_RootStore.language', context: context);

  @override
  ProgrammingLanguage get language {
    _$languageAtom.reportRead();
    return super.language;
  }

  @override
  set language(ProgrammingLanguage value) {
    _$languageAtom.reportWrite(value, super.language, () {
      super.language = value;
    });
  }

  @override
  String toString() {
    return '''
selectedNetwork: ${selectedNetwork},
language: ${language},
generatedSourceCode: ${generatedSourceCode}
    ''';
  }
}
