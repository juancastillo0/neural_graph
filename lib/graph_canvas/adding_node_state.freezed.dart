// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'adding_node_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$AddingConnectionStateTearOff {
  const _$AddingConnectionStateTearOff();

// ignore: unused_element
  _None<N> none<N extends NodeData>() {
    return _None<N>();
  }

// ignore: unused_element
  _Added<N> addedInput<N extends NodeData>(Port<N> input) {
    return _Added<N>(
      input,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $AddingConnectionState = _$AddingConnectionStateTearOff();

/// @nodoc
mixin _$AddingConnectionState<N extends NodeData> {
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult none(),
    @required TResult addedInput(Port<N> input),
  });
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult none(),
    TResult addedInput(Port<N> input),
    @required TResult orElse(),
  });
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult none(_None<N> value),
    @required TResult addedInput(_Added<N> value),
  });
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult none(_None<N> value),
    TResult addedInput(_Added<N> value),
    @required TResult orElse(),
  });
}

/// @nodoc
abstract class $AddingConnectionStateCopyWith<N extends NodeData, $Res> {
  factory $AddingConnectionStateCopyWith(AddingConnectionState<N> value,
          $Res Function(AddingConnectionState<N>) then) =
      _$AddingConnectionStateCopyWithImpl<N, $Res>;
}

/// @nodoc
class _$AddingConnectionStateCopyWithImpl<N extends NodeData, $Res>
    implements $AddingConnectionStateCopyWith<N, $Res> {
  _$AddingConnectionStateCopyWithImpl(this._value, this._then);

  final AddingConnectionState<N> _value;
  // ignore: unused_field
  final $Res Function(AddingConnectionState<N>) _then;
}

/// @nodoc
abstract class _$NoneCopyWith<N extends NodeData, $Res> {
  factory _$NoneCopyWith(_None<N> value, $Res Function(_None<N>) then) =
      __$NoneCopyWithImpl<N, $Res>;
}

/// @nodoc
class __$NoneCopyWithImpl<N extends NodeData, $Res>
    extends _$AddingConnectionStateCopyWithImpl<N, $Res>
    implements _$NoneCopyWith<N, $Res> {
  __$NoneCopyWithImpl(_None<N> _value, $Res Function(_None<N>) _then)
      : super(_value, (v) => _then(v as _None<N>));

  @override
  _None<N> get _value => super._value as _None<N>;
}

/// @nodoc
class _$_None<N extends NodeData> extends _None<N>
    with DiagnosticableTreeMixin {
  const _$_None() : super._();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AddingConnectionState<$N>.none()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AddingConnectionState<$N>.none'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is _None<N>);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult none(),
    @required TResult addedInput(Port<N> input),
  }) {
    assert(none != null);
    assert(addedInput != null);
    return none();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult none(),
    TResult addedInput(Port<N> input),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (none != null) {
      return none();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult none(_None<N> value),
    @required TResult addedInput(_Added<N> value),
  }) {
    assert(none != null);
    assert(addedInput != null);
    return none(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult none(_None<N> value),
    TResult addedInput(_Added<N> value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (none != null) {
      return none(this);
    }
    return orElse();
  }
}

abstract class _None<N extends NodeData> extends AddingConnectionState<N> {
  const _None._() : super._();
  const factory _None() = _$_None<N>;
}

/// @nodoc
abstract class _$AddedCopyWith<N extends NodeData, $Res> {
  factory _$AddedCopyWith(_Added<N> value, $Res Function(_Added<N>) then) =
      __$AddedCopyWithImpl<N, $Res>;
  $Res call({Port<N> input});
}

/// @nodoc
class __$AddedCopyWithImpl<N extends NodeData, $Res>
    extends _$AddingConnectionStateCopyWithImpl<N, $Res>
    implements _$AddedCopyWith<N, $Res> {
  __$AddedCopyWithImpl(_Added<N> _value, $Res Function(_Added<N>) _then)
      : super(_value, (v) => _then(v as _Added<N>));

  @override
  _Added<N> get _value => super._value as _Added<N>;

  @override
  $Res call({
    Object input = freezed,
  }) {
    return _then(_Added<N>(
      input == freezed ? _value.input : input as Port<N>,
    ));
  }
}

/// @nodoc
class _$_Added<N extends NodeData> extends _Added<N>
    with DiagnosticableTreeMixin {
  const _$_Added(this.input)
      : assert(input != null),
        super._();

  @override
  final Port<N> input;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AddingConnectionState<$N>.addedInput(input: $input)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AddingConnectionState<$N>.addedInput'))
      ..add(DiagnosticsProperty('input', input));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Added<N> &&
            (identical(other.input, input) ||
                const DeepCollectionEquality().equals(other.input, input)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(input);

  @override
  _$AddedCopyWith<N, _Added<N>> get copyWith =>
      __$AddedCopyWithImpl<N, _Added<N>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object>({
    @required TResult none(),
    @required TResult addedInput(Port<N> input),
  }) {
    assert(none != null);
    assert(addedInput != null);
    return addedInput(input);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object>({
    TResult none(),
    TResult addedInput(Port<N> input),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (addedInput != null) {
      return addedInput(input);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object>({
    @required TResult none(_None<N> value),
    @required TResult addedInput(_Added<N> value),
  }) {
    assert(none != null);
    assert(addedInput != null);
    return addedInput(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object>({
    TResult none(_None<N> value),
    TResult addedInput(_Added<N> value),
    @required TResult orElse(),
  }) {
    assert(orElse != null);
    if (addedInput != null) {
      return addedInput(this);
    }
    return orElse();
  }
}

abstract class _Added<N extends NodeData> extends AddingConnectionState<N> {
  const _Added._() : super._();
  const factory _Added(Port<N> input) = _$_Added<N>;

  Port<N> get input;
  _$AddedCopyWith<N, _Added<N>> get copyWith;
}
